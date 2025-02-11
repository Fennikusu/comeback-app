<?php
// src/services/LolEsportsImporter.php

namespace App\Services;

use App\Models\Bet;
use App\Helpers\DB;

class LolEsportsImporter
{
    private $baseUrl = 'https://esports-api.lolesports.com/persisted/gw';
    private $headers;

    public function __construct()
    {
        $this->headers = [
            'x-api-key' => '0TvQnueqKa5mxJntVWt0w4LpLfEkrV1Ta8rQBb9Z',  // Clé API publique utilisée par le site
            'Accept' => 'application/json'
        ];
    }

    public function importUpcomingMatches($selectedLeagues = null)
    {
        try {
            error_log("Starting importUpcomingMatches with leagues: " . json_encode($selectedLeagues));

            // Récupérer toutes les ligues
            $response = $this->makeRequest("{$this->baseUrl}/getLeagues?hl=fr-FR");
            error_log("Raw leagues response: " . json_encode($response));

            if (!isset($response['data']['leagues'])) {
                error_log("No leagues found in API response");
                return [
                    'success' => true,
                    'imported_matches' => 0
                ];
            }

            $leagues = $response['data']['leagues'];

            // Afficher toutes les ligues disponibles avec leurs slugs et IDs
            foreach ($leagues as $league) {
                error_log("Available league: {$league['name']} - slug: {$league['slug']} - id: {$league['id']}");
            }

            // Filtrer les ligues si une sélection est fournie
            if ($selectedLeagues && !empty($leagues)) {
                error_log("Filtering leagues for: " . json_encode($selectedLeagues));
                $leagues = array_filter($leagues, function ($league) use ($selectedLeagues) {
                    // Vérifier si le slug de la ligue est dans la liste des ligues sélectionnées
                    $result = in_array(strtolower($league['slug']), array_map('strtolower', $selectedLeagues));
                    error_log("Checking league {$league['slug']}: " . ($result ? 'selected' : 'filtered out'));
                    return $result;
                });

                error_log("Filtered leagues: " . json_encode(array_values($leagues)));
            }

            $importedMatches = 0;

            foreach ($leagues as $league) {
                error_log("Processing league: " . json_encode($league));

                // Récupérer le calendrier de la ligue
                $scheduleUrl = "{$this->baseUrl}/getSchedule?hl=fr-FR&leagueId=" . $league['id'];
                error_log("Fetching schedule from: " . $scheduleUrl);

                $scheduleResponse = $this->makeRequest($scheduleUrl);
                error_log("Schedule response for {$league['name']}: " . json_encode($scheduleResponse));

                if (!isset($scheduleResponse['data']['schedule']['events'])) {
                    error_log("No events found for league {$league['name']}");
                    continue;
                }

                $events = $scheduleResponse['data']['schedule']['events'];
                error_log("Found " . count($events) . " events for {$league['name']}");

                foreach ($events as $event) {
                    error_log("Processing event: " . json_encode($event));

                    if ($event['type'] === 'match' && ($event['state'] === 'unstarted' || $event['state'] === 'scheduled')) {
                        error_log("Processing unstarted/scheduled match: " . json_encode($event));

                        // Vérifier si le match existe déjà
                        $matchId = $event['match']['id'];
                        $db = DB::getInstance();
                        $stmt = $db->prepare("SELECT COUNT(*) FROM pending_matches WHERE external_match_id = ?");
                        $stmt->execute([$matchId]);
                        $exists = $stmt->fetchColumn() > 0;

                        error_log("Match {$matchId} exists in DB: " . ($exists ? 'yes' : 'no'));

                        if (!$exists) {
                            // Créer le pari
                            $teams = $event['match']['teams'];
                            if (count($teams) >= 2 && $teams[0]['name'] !== 'TBD' && $teams[1]['name'] !== 'TBD') {
                                error_log("Processing teams: {$teams[0]['name']} vs {$teams[1]['name']}");

                                // Calcul des cotes
                                $odds = $this->calculateOdds($teams[0]['code'], $teams[1]['code']);
                                error_log("Calculated odds: " . json_encode($odds));

                                $insertData = [
                                    'external_match_id' => $matchId,
                                    'game' => 'League of Legends',
                                    'league' => $league['name'],
                                    'team1' => $teams[0]['name'],
                                    'team2' => $teams[1]['name'],
                                    'odds_team1' => $odds['team1'],
                                    'odds_team2' => $odds['team2'],
                                    'scheduled_at' => $event['startTime']
                                ];

                                error_log("Attempting to insert match with data: " . json_encode($insertData));

                                $inserted = $this->createPendingMatch($insertData);

                                if ($inserted) {
                                    // Vérifier les valeurs insérées
                                    $stmt = $db->prepare("SELECT * FROM pending_matches WHERE external_match_id = ?");
                                    $stmt->execute([$matchId]);
                                    $insertedMatch = $stmt->fetch(\PDO::FETCH_ASSOC);
                                    error_log("Inserted match data: " . json_encode($insertedMatch));

                                    $importedMatches++;
                                    error_log("Successfully created pending match");
                                } else {
                                    error_log("Failed to create pending match");
                                }
                            } else {
                                error_log("Skipping match due to TBD teams or insufficient teams count");
                                error_log("Teams data: " . json_encode($teams));
                            }
                        }
                    } else {
                        error_log("Skipping event: type={$event['type']}, state={$event['state']}");
                    }
                }
            }

            error_log("Import completed. Total matches imported: " . $importedMatches);
            return [
                'success' => true,
                'imported_matches' => $importedMatches
            ];

        } catch (\Exception $e) {
            error_log("Error in importUpcomingMatches: " . $e->getMessage());
            error_log("Stack trace: " . $e->getTraceAsString());
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    public function listAvailableLeagues()
    {
        try {
            $response = $this->makeRequest("{$this->baseUrl}/getLeagues?hl=fr-FR");
            $leagues = $response['data']['leagues'];

            return [
                'success' => true,
                'leagues' => array_map(function ($league) {
                    return [
                        'name' => $league['name'],
                        'slug' => $league['slug'],
                        'region' => $league['region'] ?? 'UNKNOWN'
                    ];
                }, $leagues)
            ];
        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    private function getActiveLeagues()
    {
        try {
            // Récupérer les ligues actives
            $url = "{$this->baseUrl}/getLeagues?hl=fr-FR";
            error_log("Fetching leagues from: " . $url);

            $response = $this->makeRequest($url);
            error_log("Response: " . print_r($response, true));

            // Liste des IDs des ligues que nous voulons (à compléter)
            $targetLeagues = [
                'LFL',     // Ligue française
                'LEC',     // Europe
                'LCS',     // North America
                'LCK',     // Korea
                'WORLDS',  // Worlds
                'MSI',     // MSI
            ];

            $leagues = array_filter($response['data']['leagues'], function ($league) use ($targetLeagues) {
                return in_array($league['slug'], $targetLeagues);
            });

            return array_values($leagues); // Reset array keys
        } catch (\Exception $e) {
            error_log("Error getting leagues: " . $e->getMessage());
            throw $e;
        }
    }

    private function getUpcomingMatches($leagueId)
    {
        try {
            $url = "{$this->baseUrl}/getSchedule?hl=fr-FR&leagueId={$leagueId}";
            error_log("Fetching matches from: " . $url);

            $response = $this->makeRequest($url);
            error_log("League schedule: " . print_r($response, true));

            // Filtre pour n'avoir que les matchs à venir et uniques
            $matches = array_filter($response['data']['schedule']['events'], function ($match) {
                $startTime = strtotime($match['startTime']);
                return $match['type'] === 'match' && $startTime > time();
            });

            // Utiliser une liste temporaire pour éviter les doublons
            $processedMatches = [];
            $uniqueMatches = [];

            foreach ($matches as $match) {
                $matchKey = $match['match']['teams'][0]['code'] . '_vs_' .
                    $match['match']['teams'][1]['code'] . '_' .
                    $match['startTime'];

                if (!isset($processedMatches[$matchKey])) {
                    $processedMatches[$matchKey] = true;
                    $uniqueMatches[] = $match;
                }
            }

            return $uniqueMatches;
        } catch (\Exception $e) {
            error_log("Error getting matches: " . $e->getMessage());
            throw $e;
        }
    }

    private function makeRequest($url)
    {
        $ch = curl_init();
        $headers = [];
        foreach ($this->headers as $key => $value) {
            $headers[] = "$key: $value";
        }

        curl_setopt_array($ch, [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => $headers,
            CURLOPT_SSL_VERIFYPEER => false
        ]);

        $response = curl_exec($ch);
        error_log("API Response: " . $response);

        if ($error = curl_error($ch)) {
            throw new \Exception("CURL Error: " . $error);
        }

        curl_close($ch);

        $decoded = json_decode($response, true);
        if (json_last_error()) {
            throw new \Exception("JSON decode error: " . json_last_error_msg());
        }

        return $decoded;
    }


    private function shouldImportMatch($match)
    {
        if ($match['state'] !== 'unstarted') {
            return false;
        }

        $matchId = $match['match']['id']; // L'ID est dans l'objet match

        $db = DB::getInstance();
        $stmt = $db->prepare("
            SELECT COUNT(*) 
            FROM bets 
            WHERE external_match_id = ?
        ");
        $stmt->execute([$matchId]);

        return $stmt->fetchColumn() === 0;
    }


    private function createBetFromMatch($match, $league)
    {
        try {
            $db = DB::getInstance();
            $matchDetails = $match['match'];
            $teams = $matchDetails['teams'];

            if (count($teams) < 2 || empty($teams[0]['name']) || empty($teams[1]['name'])) {
                return false;
            }

            // N'importer que les matchs où les deux équipes sont connues
            if ($teams[0]['name'] === 'TBD' || $teams[1]['name'] === 'TBD') {
                return false;
            }

            $startTime = new \DateTime($match['startTime']);

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
                scheduled_at
            ) VALUES (
                'League of Legends',
                :league,
                :team1,
                :team2,
                :odds_team1,
                :odds_team2,
                'open',
                :external_match_id,
                :scheduled_at
            )
        ");

            return $stmt->execute([
                'league' => $league['name'],
                'team1' => $teams[0]['name'],
                'team2' => $teams[1]['name'],
                'odds_team1' => 2.0, // À ajuster selon vos besoins
                'odds_team2' => 2.0,
                'external_match_id' => $matchDetails['id'],
                'scheduled_at' => $startTime->format('Y-m-d H:i:s')
            ]);
        } catch (\Exception $e) {
            error_log("Error creating bet: " . $e->getMessage());
            error_log("Match data: " . print_r($match, true));
            throw $e;
        }
    }

    public function calculateOdds($teamCode1, $teamCode2)
    {
        try {
            error_log("Calculating odds for teams: $teamCode1 vs $teamCode2");

            // On va utiliser une approche plus simple pour commencer
            $standings = [];

            try {
                $leagueId = "98767991310872058"; // ID de la LCK
                $response = $this->makeRequest("{$this->baseUrl}/getStandings?hl=fr-FR&tournamentId=110761037147108446");
                error_log("Standings API response: " . json_encode($response));

                if (isset($response['data']) && isset($response['data']['standings'])) {
                    $standings = $response['data']['standings'];
                }
            } catch (\Exception $e) {
                error_log("Error fetching standings: " . $e->getMessage());
                // Ne pas échouer si on ne peut pas récupérer les standings
            }

            // Valeurs de base
            $team1Odds = 2.0;
            $team2Odds = 2.0;

            // Vérifier si nous avons les standings
            if (!empty($standings)) {
                try {
                    $team1Stats = null;
                    $team2Stats = null;

                    // Chercher les stats des équipes
                    foreach ($standings as $tournament) {
                        if (isset($tournament['stages'][0]['sections'][0]['rankings'])) {
                            foreach ($tournament['stages'][0]['sections'][0]['rankings'] as $ranking) {
                                if ($ranking['team']['code'] === $teamCode1) {
                                    $team1Stats = $ranking;
                                }
                                if ($ranking['team']['code'] === $teamCode2) {
                                    $team2Stats = $ranking;
                                }
                            }
                        }
                    }

                    if ($team1Stats && $team2Stats) {
                        // Ajuster les cotes basées sur le classement
                        $rankDiff = $team2Stats['rank'] - $team1Stats['rank'];
                        $team1Odds -= ($rankDiff * 0.1);
                        $team2Odds += ($rankDiff * 0.1);
                    }
                } catch (\Exception $e) {
                    error_log("Error processing standings: " . $e->getMessage());
                }
            } else {
                error_log("No standings data available, using default odds");
                // Si pas de données de classement, on utilise une légère variation aléatoire
                $randomFactor = (mt_rand(0, 20) - 10) / 100; // -0.10 à +0.10
                $team1Odds += $randomFactor;
                $team2Odds -= $randomFactor;
            }

            // S'assurer que les cotes restent dans des limites raisonnables
            $team1Odds = max(1.1, min(4.0, $team1Odds));
            $team2Odds = max(1.1, min(4.0, $team2Odds));

            // Arrondir à deux décimales
            $team1Odds = round($team1Odds, 2);
            $team2Odds = round($team2Odds, 2);

            error_log("Final calculated odds: team1=$team1Odds, team2=$team2Odds");

            return [
                'team1' => $team1Odds,
                'team2' => $team2Odds
            ];
        } catch (\Exception $e) {
            error_log("Error calculating odds: " . $e->getMessage());
            // En cas d'erreur, retourner des cotes par défaut
            return [
                'team1' => 2.0,
                'team2' => 2.0
            ];
        }
    }

    public function analyzeRecentMatches($events)
    {
        $recentMatches = 0;
        $wins = 0;
        $currentStreak = 0;
        $maxRecentMatches = 10;

        foreach ($events as $event) {
            if ($recentMatches >= $maxRecentMatches)
                break;
            if ($event['state'] !== 'completed')
                continue;

            $recentMatches++;
            if ($event['match']['winner']['code'] === $event['match']['teams'][0]['code']) {
                $wins++;
                $currentStreak++;
            } else {
                $currentStreak = 0;
            }
        }

        return [
            'winrate' => $recentMatches > 0 ? $wins / $recentMatches : 0.5,
            'streak' => $currentStreak
        ];
    }

    private function createPendingMatch($data)
    {
        try {
            $db = DB::getInstance();

            // Vérifier si le match existe déjà dans pending_matches ou bets
            $stmt = $db->prepare("
            SELECT COUNT(*) 
            FROM (
                SELECT external_match_id FROM pending_matches
                UNION
                SELECT external_match_id FROM bets
            ) as matches 
            WHERE external_match_id = ?
        ");
            $stmt->execute([$data['external_match_id']]);

            if ($stmt->fetchColumn() > 0) {
                return false; // Match déjà existant
            }

            // Insérer le nouveau match en attente
            $stmt = $db->prepare("
            INSERT INTO pending_matches (
                external_match_id,
                game,
                league,
                team1,
                team2,
                odds_team1,
                odds_team2,
                scheduled_at
            ) VALUES (
                :external_match_id,
                :game,
                :league,
                :team1,
                :team2,
                :odds_team1,
                :odds_team2,
                :scheduled_at
            )
        ");

            return $stmt->execute($data);
        } catch (\Exception $e) {
            error_log("Error creating pending match: " . $e->getMessage());
            return false;
        }
    }
}