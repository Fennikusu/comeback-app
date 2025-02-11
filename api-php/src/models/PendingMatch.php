<?php
// Dans PendingMatch.php

namespace App\Models;

use App\Helpers\DB;

class PendingMatch {
    public static function getAll() {
        $db = DB::getInstance();
        $stmt = $db->prepare("
            SELECT * FROM pending_matches 
            WHERE is_validated = FALSE 
            ORDER BY scheduled_at ASC
        ");
        $stmt->execute();
        return $stmt->fetchAll(\PDO::FETCH_ASSOC);
    }

    public static function validate($id) {
        $db = DB::getInstance();
        $db->beginTransaction();

        try {
            // Récupérer le match en attente
            $stmt = $db->prepare("
                SELECT * FROM pending_matches 
                WHERE id = ? AND is_validated = FALSE
            ");
            $stmt->execute([$id]);
            $match = $stmt->fetch(\PDO::FETCH_ASSOC);

            if (!$match) {
                throw new \Exception("Match not found or already validated");
            }

            // Créer le bet
            $stmt = $db->prepare("
                INSERT INTO bets (
                    game, league, team1, team2, 
                    odds_team1, odds_team2, status, 
                    external_match_id, scheduled_at
                ) VALUES (
                    :game, :league, :team1, :team2,
                    :odds_team1, :odds_team2, 'open',
                    :external_match_id, :scheduled_at
                )
            ");
            
            $stmt->execute([
                'game' => $match['game'],
                'league' => $match['league'],
                'team1' => $match['team1'],
                'team2' => $match['team2'],
                'odds_team1' => $match['odds_team1'],
                'odds_team2' => $match['odds_team2'],
                'external_match_id' => $match['external_match_id'],
                'scheduled_at' => $match['scheduled_at']
            ]);

            // Marquer comme validé
            $stmt = $db->prepare("
                UPDATE pending_matches 
                SET is_validated = TRUE 
                WHERE id = ?
            ");
            $stmt->execute([$id]);

            $db->commit();
            return true;
        } catch (\Exception $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function reject($id) {
        $db = DB::getInstance();
        $stmt = $db->prepare("DELETE FROM pending_matches WHERE id = ?");
        return $stmt->execute([$id]);
    }
}