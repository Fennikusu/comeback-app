<?php
// src/Controllers/MatchesController.php

namespace App\Controllers;

use App\Services\LolEsportsImporter;
use App\Helpers\DB;

class MatchesController
{
    public function importMatches()
    {
        try {
            $rawInput = file_get_contents('php://input');
            error_log("Raw input received: " . $rawInput);

            $data = json_decode($rawInput, true);
            error_log("Decoded data: " . json_encode($data));

            $selectedLeagues = $data['leagues'] ?? null;
            error_log("Selected leagues: " . json_encode($selectedLeagues));

            $importer = new LolEsportsImporter();
            $result = $importer->importUpcomingMatches($selectedLeagues);

            echo json_encode($result);
        } catch (\Exception $e) {
            error_log("Error in importMatches: " . $e->getMessage());
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => $e->getMessage()
            ]);
        }
    }

    public function getAvailableLeagues()
    {
        $importer = new LolEsportsImporter();
        echo json_encode($importer->listAvailableLeagues());
    }

    public function getImportSettings()
    {
        try {
            $db = DB::getInstance();
            $stmt = $db->prepare("SELECT * FROM import_settings WHERE id = 1");
            $stmt->execute();
            $settings = $stmt->fetch(\PDO::FETCH_ASSOC);

            if (!$settings) {
                // Si pas de settings, créer des settings par défaut
                $defaultSettings = [
                    'selected_leagues' => [],
                    'auto_validate_leagues' => [],
                    'region_filters' => [],
                    'last_import' => null,
                ];

                $stmt = $db->prepare("
                INSERT INTO import_settings (
                    selected_leagues, 
                    auto_validate_leagues, 
                    region_filters
                ) VALUES (
                    :selected_leagues,
                    :auto_validate_leagues,
                    :region_filters
                )
            ");

                $stmt->execute([
                    'selected_leagues' => json_encode($defaultSettings['selected_leagues']),
                    'auto_validate_leagues' => json_encode($defaultSettings['auto_validate_leagues']),
                    'region_filters' => json_encode($defaultSettings['region_filters'])
                ]);

                echo json_encode($defaultSettings);
                return;
            }

            // S'assurer que tous les champs JSON sont décodés
            $response = [
                'selected_leagues' => json_decode($settings['selected_leagues'] ?? '[]'),
                'auto_validate_leagues' => json_decode($settings['auto_validate_leagues'] ?? '[]'),
                'region_filters' => json_decode($settings['region_filters'] ?? '[]'),
                'last_import' => $settings['last_import']
            ];

            header('Content-Type: application/json');
            echo json_encode($response);

        } catch (\Exception $e) {
            error_log("Error in getImportSettings: " . $e->getMessage());
            http_response_code(500);
            header('Content-Type: application/json');
            echo json_encode([
                'success' => false,
                'error' => $e->getMessage()
            ]);
        }
    }

    public function setAutoImport()
    {
        try {
            $data = json_decode(file_get_contents('php://input'), true);

            if (!isset($data['enabled'])) {
                throw new \Exception('Missing enabled parameter');
            }

            $db = DB::getInstance();
            $stmt = $db->prepare("
                UPDATE import_settings 
                SET auto_import_enabled = :enabled 
                WHERE id = 1
            ");
            $stmt->execute(['enabled' => $data['enabled']]);

            echo json_encode([
                'success' => true,
                'message' => 'Auto-import settings updated'
            ]);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => $e->getMessage()
            ]);
        }
    }

    public function getPendingMatches()
    {
        try {
            $db = DB::getInstance();
            $stmt = $db->prepare("
            SELECT * 
            FROM pending_matches 
            WHERE is_validated = FALSE 
            ORDER BY scheduled_at ASC
        ");
            $stmt->execute();
            $matches = $stmt->fetchAll(\PDO::FETCH_ASSOC);

            echo json_encode($matches);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => $e->getMessage()
            ]);
        }
    }

    public function validateMatch()
    {
        try {
            $data = json_decode(file_get_contents('php://input'), true);
            error_log("Validation data: " . json_encode($data));

            if (!isset($data['match_id'])) {
                throw new \Exception("Missing match_id");
            }

            $db = DB::getInstance();

            // Récupérer le match en attente
            $stmt = $db->prepare("
            SELECT * FROM pending_matches 
            WHERE id = :match_id AND is_validated = FALSE
        ");
            $stmt->execute(['match_id' => $data['match_id']]);
            $match = $stmt->fetch(\PDO::FETCH_ASSOC);

            if (!$match) {
                throw new \Exception("Match not found or already validated");
            }

            // Démarrer une transaction
            $db->beginTransaction();

            try {
                // Calculer les cotes à jour
                $importer = new LolEsportsImporter();
                $odds = $importer->calculateOdds($match['team1_code'], $match['team2_code']);
                error_log("Calculated odds at validation: " . json_encode($odds));

                // Créer le bet
                $stmt = $db->prepare("
                INSERT INTO bets (
                    game,
                    league,
                    team1,
                    team2,
                    odds_team1,
                    odds_team2,
                    status,
                    external_match_id,
                    scheduled_at,
                    is_validated
                ) VALUES (
                    :game,
                    :league,
                    :team1,
                    :team2,
                    :odds_team1,
                    :odds_team2,
                    'open',
                    :external_match_id,
                    :scheduled_at,
                    true
                )
            ");

                $stmt->execute([
                    'game' => $match['game'],
                    'league' => $match['league'],
                    'team1' => $match['team1'],
                    'team2' => $match['team2'],
                    'odds_team1' => $odds['team1'],
                    'odds_team2' => $odds['team2'],
                    'external_match_id' => $match['external_match_id'],
                    'scheduled_at' => $match['scheduled_at']
                ]);

                // Marquer comme validé
                $stmt = $db->prepare("
                UPDATE pending_matches 
                SET is_validated = TRUE 
                WHERE id = :match_id
            ");
                $stmt->execute(['match_id' => $data['match_id']]);

                $db->commit();
                echo json_encode([
                    'success' => true,
                    'message' => 'Match validé avec succès'
                ]);
            } catch (\Exception $e) {
                $db->rollBack();
                throw $e;
            }
        } catch (\Exception $e) {
            error_log("Error in validateMatch: " . $e->getMessage());
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => $e->getMessage()
            ]);
        }
    }

    public function updateImportSettings()
    {
        try {
            $data = json_decode(file_get_contents('php://input'), true);

            $db = DB::getInstance();
            $stmt = $db->prepare("
                UPDATE import_settings 
                SET 
                    selected_leagues = :selected_leagues,
                    auto_validate_leagues = :auto_validate_leagues,
                    region_filters = :region_filters
                WHERE id = 1
            ");

            $stmt->execute([
                'selected_leagues' => json_encode($data['selected_leagues'] ?? []),
                'auto_validate_leagues' => json_encode($data['auto_validate_leagues'] ?? []),
                'region_filters' => json_encode($data['region_filters'] ?? [])
            ]);

            echo json_encode(['success' => true]);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => $e->getMessage()
            ]);
        }
    }


}