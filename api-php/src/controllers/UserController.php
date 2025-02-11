<?php

namespace App\Controllers;

use App\Models\User;
use App\Services\JWTService;
use App\Helpers\DB;


class UserController
{
    // Récupérer le profil utilisateur
    public function getProfile()
{
    try {
        $userId = $this->getUserIdFromToken();
        
        $db = DB::getInstance();
        $stmt = $db->prepare("
            SELECT u.*,
                   af_profile.file_path as profile_picture_path,
                   af_banner.file_path as banner_path
            FROM users u
            LEFT JOIN shop_items si_profile ON u.profile_picture = si_profile.id
            LEFT JOIN asset_files af_profile ON si_profile.asset_id = af_profile.id
            LEFT JOIN shop_items si_banner ON u.banner = si_banner.id
            LEFT JOIN asset_files af_banner ON si_banner.asset_id = af_banner.id
            WHERE u.id = :user_id
        ");
        
        $stmt->execute([':user_id' => $userId]);
        $user = $stmt->fetch(\PDO::FETCH_ASSOC);
    
        if ($user) {
            // Ajouter les assets au format attendu
            if ($user['profile_picture_path']) {
                $user['profile_picture_asset'] = [
                    'file_path' => $user['profile_picture_path']
                ];
            }
            
            if ($user['banner_path']) {
                $user['banner_asset'] = [
                    'file_path' => $user['banner_path']
                ];
            }
    
            // Nettoyer les champs temporaires
            unset($user['profile_picture_path']);
            unset($user['banner_path']);
            
            echo json_encode($user);
        } else {
            http_response_code(404);
            echo json_encode(["message" => "Utilisateur non trouvé"]);
        }
    } catch (\Exception $e) {
        http_response_code(500);
        echo json_encode([
            "message" => "Erreur serveur: " . $e->getMessage(),
            "trace" => $e->getTraceAsString()
        ]);
    }
}



    private function getUserIdFromToken()
    {
        $headers = getallheaders();

        if (!isset($headers['Authorization']) && !isset($headers['authorization'])) {
            http_response_code(401);
            echo json_encode(["message" => "Token non fourni"]);
            exit;
        }

        $authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : $headers['authorization'];
        $token = str_replace('Bearer ', '', $authHeader);

        try {
            $decoded = JWTService::validateToken($token);  // Utilisez votre service
            if ($decoded === null) {
                http_response_code(401);
                echo json_encode(["message" => "Token invalide"]);
                exit;
            }
            return $decoded->id;
        } catch (\Exception $e) {
            http_response_code(401);
            echo json_encode(["message" => "Token invalide"]);
            exit;
        }
    }



    // Mettre à jour le profil utilisateur
    public function updateProfile($userId)
    {
        $data = json_decode(file_get_contents("php://input"), true);

        if (User::updateProfile($userId, $data)) {
            echo json_encode(["message" => "Profile updated successfully"]);
        } else {
            http_response_code(500);
            echo json_encode(["message" => "Failed to update profile"]);
        }
    }

    // Récupérer le leaderboard
    public function getLeaderboard()
    {
        $leaderboard = User::getLeaderboard();
        echo json_encode($leaderboard);
    }

    public function getUserBalance($userId)
    {
        $user = User::getById($userId);
        if ($user) {
            echo json_encode([
                'coins' => $user['coins']
            ]);
        } else {
            http_response_code(404);
            echo json_encode(["message" => "User not found"]);
        }
    }

    public function getUserItems($userId)
    {
        try {
            $db = DB::getInstance();
            $stmt = $db->prepare("
                SELECT si.*, af.file_path as asset_path 
                FROM shop_items si
                LEFT JOIN asset_files af ON si.asset_id = af.id
                INNER JOIN user_items ui ON si.id = ui.item_id
                WHERE ui.user_id = :user_id
            ");

            $stmt->execute([':user_id' => $userId]);
            $items = $stmt->fetchAll(\PDO::FETCH_ASSOC);

            foreach ($items as &$item) {
                if ($item['asset_path']) {
                    $item['asset'] = [
                        'file_path' => $item['asset_path']
                    ];
                }
                unset($item['asset_path']);
            }

            echo json_encode($items);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode([
                "message" => "Failed to load user items",
                "error" => $e->getMessage()
            ]);
        }
    }


    public function getUserProfile($userId)
    {
        try {
            $db = DB::getInstance();

            $stmt = $db->prepare("
                SELECT u.*,
                       af_profile.file_path as profile_picture_path,
                       af_banner.file_path as banner_path
                FROM users u
                LEFT JOIN shop_items si_profile ON u.profile_picture = si_profile.id
                LEFT JOIN asset_files af_profile ON si_profile.asset_id = af_profile.id
                LEFT JOIN shop_items si_banner ON u.banner = si_banner.id
                LEFT JOIN asset_files af_banner ON si_banner.asset_id = af_banner.id
                WHERE u.id = :user_id
            ");

            $stmt->execute([':user_id' => $userId]);
            $user = $stmt->fetch(\PDO::FETCH_ASSOC);

            if ($user) {
                // Ajouter les assets
                if ($user['profile_picture_path']) {
                    $user['profile_picture_asset'] = [
                        'file_path' => $user['profile_picture_path']
                    ];
                }

                if ($user['banner_path']) {
                    $user['banner_asset'] = [
                        'file_path' => $user['banner_path']
                    ];
                }

                // Nettoyer les champs temporaires
                unset($user['profile_picture_path']);
                unset($user['banner_path']);
            }

            echo json_encode($user);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode([
                "message" => "Failed to load user profile",
                "error" => $e->getMessage()
            ]);
        }
    }

    public function getAvailableItems($userId)
    {
        $unlockedItems = User::getUserItems($userId);
        $allItems = User::getAllItems();

        // Marquer les items comme débloqués ou non
        $items = [
            'profile_pictures' => [],
            'banners' => [],
            'titles' => []
        ];

        foreach ($allItems as $item) {
            $item['is_unlocked'] = in_array($item['id'], array_column($unlockedItems, 'id'));
            $items[$item['type'] . 's'][] = $item;
        }

        echo json_encode($items);
    }

    // src/controllers/UserController.php

    public function getFriendsList($userId)
    {
        try {
            $friends = User::getFriendsList($userId);
            echo json_encode($friends);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(["message" => "Failed to load friends"]);
        }
    }

    public function addFriend($userId)
    {
        try {
            $data = json_decode(file_get_contents("php://input"), true);
            $friendId = $data['friend_id'];

            // Vérifier que l'utilisateur n'essaie pas de s'ajouter lui-même
            if ($userId == $friendId) {
                http_response_code(400);
                echo json_encode(["message" => "Impossible de s'ajouter soi-même en ami"]);
                return;
            }

            // Vérifier que l'ami existe
            $friend = User::getById($friendId);
            if (!$friend) {
                http_response_code(404);
                echo json_encode(["message" => "Utilisateur non trouvé"]);
                return;
            }

            // Vérifier que l'amitié n'existe pas déjà
            if (User::isFriend($userId, $friendId)) {
                http_response_code(400);
                echo json_encode(["message" => "Déjà ami avec cet utilisateur"]);
                return;
            }

            if (User::addFriend($userId, $friendId)) {
                echo json_encode(["message" => "Ami ajouté avec succès"]);
            } else {
                http_response_code(500);
                echo json_encode(["message" => "Erreur lors de l'ajout de l'ami"]);
            }
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(["message" => "Failed to add friend"]);
        }
    }

    public function removeFriend($userId, $friendId)
    {
        try {
            if (User::removeFriend($userId, $friendId)) {
                echo json_encode(["message" => "Ami supprimé avec succès"]);
            } else {
                http_response_code(500);
                echo json_encode(["message" => "Erreur lors de la suppression de l'ami"]);
            }
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(["message" => "Failed to remove friend"]);
        }
    }

    public function getRecentBets($userId)
    {
        try {
            $db = DB::getInstance();
            $stmt = $db->prepare("
            SELECT ub.*, b.game, b.league, b.team1, b.team2
            FROM user_bets ub
            JOIN bets b ON ub.bet_id = b.id
            WHERE ub.user_id = :user_id
            AND ub.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
            ORDER BY ub.created_at DESC
        ");
            $stmt->execute([':user_id' => $userId]);
            $bets = $stmt->fetchAll(\PDO::FETCH_ASSOC);

            echo json_encode($bets);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(["message" => "Failed to load recent bets"]);
        }
    }

    public function getDailyChest($userId)
    {
        try {
            $db = DB::getInstance();

            // Vérifier si le coffre a déjà été réclamé aujourd'hui
            $stmt = $db->prepare("
            SELECT last_chest_claim 
            FROM users 
            WHERE id = :user_id
            AND DATE(last_chest_claim) = CURDATE()
        ");
            $stmt->execute([':user_id' => $userId]);
            $lastClaim = $stmt->fetch(\PDO::FETCH_ASSOC);

            if ($lastClaim) {
                echo json_encode([
                    "available" => false,
                    "next_available" => date('Y-m-d H:i:s', strtotime('tomorrow'))
                ]);
                return;
            }

            // Si le coffre n'a pas été réclamé, générer une récompense
            $reward = [
                "coins" => rand(100, 500),
                "items" => []
            ];

            // 10% de chance d'obtenir un item aléatoire
            if (rand(1, 100) <= 10) {
                $stmt = $db->prepare("
                SELECT * FROM shop_items 
                WHERE id NOT IN (
                    SELECT item_id FROM user_items WHERE user_id = :user_id
                )
                ORDER BY RAND() LIMIT 1
            ");
                $stmt->execute([':user_id' => $userId]);
                $item = $stmt->fetch(\PDO::FETCH_ASSOC);

                if ($item) {
                    $reward["items"][] = $item;
                }
            }

            echo json_encode([
                "available" => true,
                "reward" => $reward
            ]);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(["message" => "Failed to check daily chest"]);
        }
    }

    public function claimDailyChest($userId)
    {
        try {
            $db = DB::getInstance();
            $db->beginTransaction();

            // Récupérer la récompense
            $stmt = $db->prepare("
            UPDATE users 
            SET coins = coins + :reward_coins,
                last_chest_claim = NOW()
            WHERE id = :user_id
        ");
            $rewardCoins = rand(1000, 5000);
            $stmt->execute([
                ':user_id' => $userId,
                ':reward_coins' => $rewardCoins
            ]);

            // 10% de chance d'obtenir un item
            /*
            if (rand(1, 100) <= 10) {
                $stmt = $db->prepare("
                INSERT INTO user_items (user_id, item_id)
                SELECT :user_id, id FROM shop_items 
                WHERE id NOT IN (
                    SELECT item_id FROM user_items WHERE user_id = :user_id
                )
                ORDER BY RAND() LIMIT 1
            ");
                $stmt->execute([':user_id' => $userId]);
            }*/

            $db->commit();
            echo json_encode([
                "success" => true,
                "reward" => [
                    "coins" => $rewardCoins,
                    "items" => [] // Ajouter les items si obtenus
                ]
            ]);
        } catch (\Exception $e) {
            $db->rollBack();
            http_response_code(500);
            echo json_encode(["message" => "Failed to claim daily chest"]);
        }
    }

    public function getLastSessionEarnings($userId)
    {
        try {
            $db = DB::getInstance();
            $stmt = $db->prepare("
            SELECT 
                COALESCE(SUM(
                    CASE 
                        WHEN ub.result = 'win' THEN ub.amount * b.odds_team1
                        ELSE -ub.amount 
                    END
                ), 0) as earnings
            FROM user_bets ub
            JOIN bets b ON ub.bet_id = b.id
            WHERE ub.user_id = :user_id
            AND ub.created_at >= (
                SELECT last_login 
                FROM users 
                WHERE id = :user_id
            )
        ");
            $stmt->execute([':user_id' => $userId]);
            $earnings = $stmt->fetch(\PDO::FETCH_ASSOC);

            echo json_encode([
                "earnings" => $earnings['earnings']
            ]);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(["message" => "Failed to get session earnings"]);
        }
    }


}
