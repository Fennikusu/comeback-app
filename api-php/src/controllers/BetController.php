<?php

namespace App\Controllers;

use App\Models\Bet;
use App\Models\User;


class BetController
{
    // Liste des paris
    public function listBets()
    {
        // Récupérer le paramètre game s'il existe
        $game = isset($_GET['game']) ? $_GET['game'] : null;

        if ($game) {
            // Si un jeu est spécifié, filtrer les paris
            $bets = Bet::getAllByGame($game);
        } else {
            // Sinon retourner tous les paris
            $bets = Bet::getAll();
        }

        echo json_encode($bets);
    }


    public function getBetById($id)
    {
        $bet = Bet::getById($id);
        if ($bet) {
            echo json_encode($bet);
        } else {
            http_response_code(404);
            echo json_encode(["message" => "Bet not found"]);
        }
    }

    public function placeBet()
    {
        // Récupérer les données envoyées
        $data = json_decode(file_get_contents('php://input'), true);

        // Vérifier que toutes les données requises sont présentes
        if (
            !isset($data['user_id']) || !isset($data['bet_id']) ||
            !isset($data['amount']) || !isset($data['selected_team'])
        ) {
            http_response_code(400);
            echo json_encode(["message" => "Missing required fields"]);
            return;
        }

        // Vérifier si l'utilisateur a assez de pièces
        $user = User::getById($data['user_id']);
        if (!$user || $user['coins'] < $data['amount']) {
            http_response_code(400);
            echo json_encode(["message" => "Insufficient funds"]);
            return;
        }

        // Créer le pari
        $userBet = [
            'user_id' => $data['user_id'],
            'bet_id' => $data['bet_id'],
            'sub_bet_id' => $data['sub_bet_id'] ?? null,
            'amount' => $data['amount'],
            'selected_team' => $data['selected_team'],
            'result' => 'pending',
            'created_at' => date('Y-m-d H:i:s')
        ];

        if (Bet::createUserBet($userBet)) {
            // Mettre à jour le solde de l'utilisateur
            User::updateCoins($data['user_id'], -$data['amount']);

            echo json_encode($userBet);
        } else {
            http_response_code(500);
            echo json_encode(["message" => "Failed to place bet"]);
        }
    }



    // Création d’un pari (administrateur)
    public function createBet()
    {
        $data = json_decode(file_get_contents("php://input"), true);

        if (Bet::create($data)) {
            echo json_encode(["message" => "Bet created successfully"]);
        } else {
            http_response_code(500);
            echo json_encode(["message" => "Failed to create bet"]);
        }
    }

    // Mise à jour d’un pari (administrateur)
    public function updateBet()
    {
        $data = json_decode(file_get_contents("php://input"), true);

        if (!isset($data['id'])) {
            http_response_code(400);
            echo json_encode(["message" => "Bet ID is required"]);
            return;
        }

        if (Bet::update($data['id'], $data)) {
            echo json_encode(["message" => "Bet updated successfully"]);
        } else {
            http_response_code(500);
            echo json_encode(["message" => "Failed to update bet"]);
        }
    }

    // Dans BetController.php
    public function getUserBets($userId)
    {
        $bets = Bet::getUserBets($userId);
        echo json_encode($bets ?: []);
    }

    // Dans le fichier BetController.php

    public function getBetStats($betId)
    {
        try {
            $stats = Bet::getStats($betId);

            if ($stats['success']) {
                echo json_encode($stats);
            } else {
                http_response_code(404);
                echo json_encode($stats);
            }
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => $e->getMessage()
            ]);
        }
    }

    public function updateBetStatus()
    {
        try {
            $data = json_decode(file_get_contents('php://input'), true);

            if (!isset($data['bet_id']) || !isset($data['status'])) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'message' => 'Missing required fields: bet_id and status'
                ]);
                return;
            }

            $result = Bet::updateStatus($data['bet_id'], $data['status']);
            echo json_encode($result);

        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => $e->getMessage()
            ]);
        }
    }

    public function finishBet()
    {
        try {
            $data = json_decode(file_get_contents('php://input'), true);

            if (!isset($data['bet_id']) || !isset($data['winning_team'])) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'message' => 'Missing required fields: bet_id and winning_team'
                ]);
                return;
            }

            if (!in_array($data['winning_team'], [1, 2])) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'message' => 'winning_team must be 1 or 2'
                ]);
                return;
            }

            $result = Bet::finishBet($data['bet_id'], $data['winning_team']);
            echo json_encode($result);

        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => $e->getMessage()
            ]);
        }
    }


}
