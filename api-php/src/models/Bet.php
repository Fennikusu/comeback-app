<?php

namespace App\Models;

use App\Helpers\DB;
use App\Models\User;
use PDO;


class Bet
{
    // Récupérer tous les paris
    public static function getAll()
    {
        $db = DB::getInstance();
        $stmt = $db->query("SELECT * FROM bets");
        return $stmt->fetchAll(\PDO::FETCH_ASSOC);
    }

    // Récupérer un pari par son ID
    public static function getById($id)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("SELECT * FROM bets WHERE id = :id");
        $stmt->execute([':id' => $id]);
        return $stmt->fetch(\PDO::FETCH_ASSOC);
    }

    public static function createUserBet($data)
    {
        $db = DB::getInstance();
        $sql = "INSERT INTO user_bets (user_id, bet_id, sub_bet_id, amount, result, created_at) 
            VALUES (:user_id, :bet_id, :sub_bet_id, :amount, :result, :created_at)";

        $stmt = $db->prepare($sql);
        return $stmt->execute([
            ':user_id' => $data['user_id'],
            ':bet_id' => $data['bet_id'],
            ':sub_bet_id' => $data['sub_bet_id'],
            ':amount' => $data['amount'],
            ':result' => $data['result'],
            ':created_at' => $data['created_at']
        ]);
    }

    // Créer un nouveau pari
    public static function create($data)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("
            INSERT INTO bets (game, league, team1, team2, odds_team1, odds_team2, status)
            VALUES (:game, :league, :team1, :team2, :odds_team1, :odds_team2, :status)
        ");

        return $stmt->execute([
            ':game' => $data['game'],
            ':league' => $data['league'],
            ':team1' => $data['team1'],
            ':team2' => $data['team2'],
            ':odds_team1' => $data['odds_team1'],
            ':odds_team2' => $data['odds_team2'],
            ':status' => $data['status'] ?? 'open',
        ]);
    }

    // Mettre à jour un pari
    public static function update($id, $data)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("
            UPDATE bets 
            SET 
                game = :game,
                league = :league,
                team1 = :team1,
                team2 = :team2,
                odds_team1 = :odds_team1,
                odds_team2 = :odds_team2,
                status = :status
            WHERE id = :id
        ");

        return $stmt->execute([
            ':game' => $data['game'],
            ':league' => $data['league'],
            ':team1' => $data['team1'],
            ':team2' => $data['team2'],
            ':odds_team1' => $data['odds_team1'],
            ':odds_team2' => $data['odds_team2'],
            ':status' => $data['status'] ?? 'open',
            ':id' => $id,
        ]);
    }

    // Dans votre classe Bet (probablement dans src/models/Bet.php)
    public static function getUserBets($userId)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("
        SELECT ub.*, b.game, b.league, b.team1, b.team2 
        FROM user_bets ub
        JOIN bets b ON ub.bet_id = b.id
        WHERE ub.user_id = :user_id
    ");
        $stmt->execute([':user_id' => $userId]);
        return $stmt->fetchAll(\PDO::FETCH_ASSOC);
    }

    // Supprimer un pari
    public static function delete($id)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("DELETE FROM bets WHERE id = :id");
        return $stmt->execute([':id' => $id]);
    }

    public static function getAllByGame($game)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("SELECT * FROM bets WHERE game = ?");
        $stmt->execute([$game]);
        return $stmt->fetchAll(\PDO::FETCH_ASSOC);
    }

    // Dans le fichier Bet.php

    // Dans le fichier Bet.php

    public static function getStats($betId)
    {
        $db = DB::getInstance();
        try {
            $query = "
            SELECT 
                b.*,
                COUNT(DISTINCT ub.id) as total_bets,
                COALESCE(SUM(ub.amount), 0) as total_amount,
                SUM(CASE WHEN ub.selected_team = 'team1' THEN 1 ELSE 0 END) as team1_bets,
                SUM(CASE WHEN ub.selected_team = 'team2' THEN 1 ELSE 0 END) as team2_bets,
                COALESCE(SUM(CASE WHEN ub.selected_team = 'team1' THEN ub.amount ELSE 0 END), 0) as team1_amount,
                COALESCE(SUM(CASE WHEN ub.selected_team = 'team2' THEN ub.amount ELSE 0 END), 0) as team2_amount
            FROM bets b
            LEFT JOIN user_bets ub ON b.id = ub.bet_id
            WHERE b.id = :bet_id
            GROUP BY b.id, b.game, b.league, b.team1, b.team2, b.odds_team1, b.odds_team2, b.status";

            $stmt = $db->prepare($query);
            $stmt->execute(['bet_id' => $betId]);

            $result = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($result) {
                return [
                    'success' => true,
                    'stats' => [
                        'total_bets' => (int) $result['total_bets'],
                        'total_amount' => (int) $result['total_amount'],
                        'team1_bets' => (int) $result['team1_bets'],
                        'team2_bets' => (int) $result['team2_bets'],
                        'team1_amount' => (int) $result['team1_amount'],
                        'team2_amount' => (int) $result['team2_amount'],
                        'game' => $result['game'],
                        'team1' => $result['team1'],
                        'team2' => $result['team2'],
                        'status' => $result['status']
                    ]
                ];
            }

            return ['success' => false, 'message' => 'Bet not found'];
        } catch (\PDOException $e) {
            throw new \Exception("Database error: " . $e->getMessage());
        }
    }

    public static function updateStatus($betId, $newStatus)
    {
        $db = DB::getInstance();
        try {
            // Vérifier si le statut est valide
            $validStatuses = ['open', 'closed', 'finished'];
            if (!in_array($newStatus, $validStatuses)) {
                throw new \Exception("Invalid status. Must be one of: " . implode(', ', $validStatuses));
            }

            // Vérifier si le pari existe
            $stmt = $db->prepare("SELECT * FROM bets WHERE id = :bet_id");
            $stmt->execute(['bet_id' => $betId]);
            $bet = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$bet) {
                throw new \Exception("Bet not found");
            }

            // Mettre à jour le statut
            $stmt = $db->prepare("
            UPDATE bets 
            SET status = :status 
            WHERE id = :bet_id
        ");

            $success = $stmt->execute([
                'bet_id' => $betId,
                'status' => $newStatus
            ]);

            if ($success) {
                return [
                    'success' => true,
                    'message' => "Bet status updated to $newStatus",
                    'data' => [
                        'bet_id' => $betId,
                        'new_status' => $newStatus
                    ]
                ];
            } else {
                throw new \Exception("Failed to update bet status");
            }
        } catch (\PDOException $e) {
            throw new \Exception("Database error: " . $e->getMessage());
        }
    }

    public static function finishBet($betId, $winningTeam)
    {
        $db = DB::getInstance();
        $db->beginTransaction();

        try {
            // 1. Vérifier si le pari existe et n'est pas déjà terminé
            $stmt = $db->prepare("SELECT * FROM bets WHERE id = :bet_id AND status != 'finished'");
            $stmt->execute(['bet_id' => $betId]);
            $bet = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$bet) {
                throw new \Exception("Bet not found or already finished");
            }

            // 2. Récupérer tous les paris utilisateurs
            $stmt = $db->prepare("
            SELECT ub.*, u.coins 
            FROM user_bets ub 
            JOIN users u ON u.id = ub.user_id 
            WHERE ub.bet_id = :bet_id AND ub.result = 'pending'
        ");
            $stmt->execute(['bet_id' => $betId]);
            $userBets = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $totalPaidOut = 0;
            $winningTeamStr = $winningTeam == 1 ? 'team1' : 'team2';

            // 3. Traiter chaque pari
            foreach ($userBets as $userBet) {
                $hasWon = $userBet['selected_team'] === $winningTeamStr;
                $odds = $winningTeam == 1 ? $bet['odds_team1'] : $bet['odds_team2'];
                $winnings = 0;

                if ($hasWon) {
                    $winnings = floor($userBet['amount'] * $odds);

                    // Mettre à jour les pièces de l'utilisateur
                    $stmt = $db->prepare("
                    UPDATE users 
                    SET coins = coins + :winnings,
                        total_earnings = total_earnings + :winnings
                    WHERE id = :user_id
                ");
                    $stmt->execute([
                        'winnings' => $winnings,
                        'user_id' => $userBet['user_id']
                    ]);

                    $totalPaidOut += $winnings;
                }

                // Mettre à jour le résultat du pari
                $stmt = $db->prepare("
                UPDATE user_bets 
                SET result = :result 
                WHERE id = :id
            ");
                $stmt->execute([
                    'result' => $hasWon ? 'win' : 'lose',
                    'id' => $userBet['id']
                ]);
            }

            // 4. Marquer le pari comme terminé
            $stmt = $db->prepare("UPDATE bets SET status = 'finished' WHERE id = :bet_id");
            $stmt->execute(['bet_id' => $betId]);

            $db->commit();

            return [
                'success' => true,
                'message' => 'Bet finished successfully',
                'data' => [
                    'total_paid_out' => $totalPaidOut,
                    'winning_team' => $winningTeamStr,
                    'bets_processed' => count($userBets)
                ]
            ];
        } catch (\Exception $e) {
            $db->rollBack();
            throw new \Exception("Error finishing bet: " . $e->getMessage());
        }
    }
}
