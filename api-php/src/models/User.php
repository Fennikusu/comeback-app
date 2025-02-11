<?php

namespace App\Models;

use App\Helpers\DB;

class User
{
    // Récupérer un utilisateur par ID
    public static function getById($id)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("SELECT id, pseudo, email, profile_picture, coins FROM users WHERE id = :id");
        $stmt->execute([':id' => $id]);
        return $stmt->fetch();
    }

    // Enregistrer un nouvel utilisateur
    public static function register($data)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("INSERT INTO users (pseudo, email, password, coins) VALUES (:pseudo, :email, :password, :coins)");
        return $stmt->execute([
            ':pseudo' => $data['pseudo'],
            ':email' => $data['email'],
            ':password' => password_hash($data['password'], PASSWORD_DEFAULT),
            ':coins' => $data['coins'] ?? 0,
        ]);
    }


    public static function getFriendsSortedByCoins($userId)
    {
        $db = DB::getInstance();
        // Cette requête récupère les informations des amis via la table friends
        $stmt = $db->prepare("
        SELECT DISTINCT u.id, u.pseudo, u.coins 
        FROM users u
        INNER JOIN friends f ON (u.id = f.friend_id AND f.user_id = :userId)
        ORDER BY u.coins DESC
    ");

        $stmt->execute([':userId' => $userId]);
        return $stmt->fetchAll(\PDO::FETCH_ASSOC);
    }

    public static function getBiggestWinnerOfDay()
    {
        $db = DB::getInstance();

        $sql = "
        SELECT u.id, u.pseudo, u.coins, SUM(ub.amount) as total_win
        FROM users u
        INNER JOIN user_bets ub ON u.id = ub.user_id
        WHERE ub.result = 'win'
        AND ub.created_at >= DATE_SUB(NOW(), INTERVAL 1 DAY)
        GROUP BY u.id, u.pseudo, u.coins
        ORDER BY total_win DESC
        LIMIT 1
    ";

        $stmt = $db->query($sql);
        return $stmt->fetch(\PDO::FETCH_ASSOC);
    }

    public static function getBiggestLoserOfDay()
    {
        $db = DB::getInstance();

        $sql = "
        SELECT u.id, u.pseudo, u.coins, SUM(ub.amount) as total_loss
        FROM users u
        INNER JOIN user_bets ub ON u.id = ub.user_id
        WHERE ub.result = 'lose'
        AND ub.created_at >= DATE_SUB(NOW(), INTERVAL 1 DAY)
        GROUP BY u.id, u.pseudo, u.coins
        ORDER BY total_loss DESC
        LIMIT 1
    ";

        $stmt = $db->query($sql);
        return $stmt->fetch(\PDO::FETCH_ASSOC);
    }

    public static function getAllSortedByCoins()
    {
        $db = DB::getInstance();
        $stmt = $db->query("SELECT id, pseudo, coins FROM users ORDER BY coins DESC");
        return $stmt->fetchAll(\PDO::FETCH_ASSOC);
    }



    public static function updateCoins($userId, $amount)
    {
        $db = DB::getInstance();
        $sql = "UPDATE users SET coins = coins + :amount WHERE id = :id";
        $stmt = $db->prepare($sql);
        return $stmt->execute([
            ':amount' => $amount,
            ':id' => $userId
        ]);
    }

    // Récupérer le leaderboard
    public static function getLeaderboard()
    {
        $db = DB::getInstance();
        $stmt = $db->query("SELECT id, pseudo, coins FROM users ORDER BY coins DESC LIMIT 100");
        return $stmt->fetchAll();
    }

    // Méthode pour récupérer un utilisateur par son email
    public static function getByEmail($email)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("SELECT * FROM users WHERE email = :email");
        $stmt->execute([':email' => $email]);
        return $stmt->fetch();
    }

    // src/models/User.php
    public static function getUserItems($userId)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("
        SELECT si.* 
        FROM shop_items si
        INNER JOIN user_items ui ON si.id = ui.item_id
        WHERE ui.user_id = :user_id
    ");
        $stmt->execute([':user_id' => $userId]);
        return $stmt->fetchAll(\PDO::FETCH_ASSOC);
    }

    public static function updateProfile($userId, $data)
    {
        $db = DB::getInstance();
        $validFields = ['profile_picture', 'banner', 'title'];
        $updates = [];
        $params = [':user_id' => $userId];

        foreach ($validFields as $field) {
            if (isset($data[$field])) {
                $updates[] = "$field = :$field";
                $params[":$field"] = $data[$field];
            }
        }

        if (empty($updates)) {
            return false;
        }

        $sql = "UPDATE users SET " . implode(', ', $updates) . " WHERE id = :user_id";
        $stmt = $db->prepare($sql);
        return $stmt->execute($params);
    }

    public static function getAllItems()
    {
        $db = DB::getInstance();
        $stmt = $db->query("SELECT * FROM shop_items");
        return $stmt->fetchAll(\PDO::FETCH_ASSOC);
    }

    // src/models/User.php

    public static function getFriendsList($userId)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("
        SELECT u.* 
        FROM users u
        INNER JOIN friends f ON u.id = f.friend_id
        WHERE f.user_id = :user_id
    ");
        $stmt->execute([':user_id' => $userId]);
        return $stmt->fetchAll(\PDO::FETCH_ASSOC);
    }

    public static function isFriend($userId, $friendId)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("
        SELECT COUNT(*) 
        FROM friends 
        WHERE user_id = :user_id AND friend_id = :friend_id
    ");
        $stmt->execute([
            ':user_id' => $userId,
            ':friend_id' => $friendId
        ]);
        return $stmt->fetchColumn() > 0;
    }

    public static function addFriend($userId, $friendId)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("
        INSERT INTO friends (user_id, friend_id) 
        VALUES (:user_id, :friend_id)
    ");
        return $stmt->execute([
            ':user_id' => $userId,
            ':friend_id' => $friendId
        ]);
    }

    public static function removeFriend($userId, $friendId)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("
        DELETE FROM friends 
        WHERE user_id = :user_id AND friend_id = :friend_id
    ");
        return $stmt->execute([
            ':user_id' => $userId,
            ':friend_id' => $friendId
        ]);
    }

    // Dans la classe User
    public static function hasItem($userId, $itemId)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("
        SELECT COUNT(*) 
        FROM user_items 
        WHERE user_id = :user_id AND item_id = :item_id
    ");
        $stmt->execute([
            ':user_id' => $userId,
            ':item_id' => $itemId
        ]);
        return $stmt->fetchColumn() > 0;
    }

    public static function unlockItem($userId, $itemId)
    {
        $db = DB::getInstance();
        try {
            $db->beginTransaction();

            // Vérifier si l'item n'est pas déjà débloqué
            $stmt = $db->prepare("
            SELECT COUNT(*) 
            FROM user_items 
            WHERE user_id = :user_id AND item_id = :item_id
        ");
            $stmt->execute([
                ':user_id' => $userId,
                ':item_id' => $itemId
            ]);

            if ($stmt->fetchColumn() > 0) {
                $db->rollBack();
                return true; // Déjà débloqué
            }

            // Débloquer l'item
            $stmt = $db->prepare("
            INSERT INTO user_items (user_id, item_id) 
            VALUES (:user_id, :item_id)
        ");
            $success = $stmt->execute([
                ':user_id' => $userId,
                ':item_id' => $itemId
            ]);

            if ($success) {
                $db->commit();
                return true;
            } else {
                $db->rollBack();
                return false;
            }
        } catch (\Exception $e) {
            $db->rollBack();
            return false;
        }
    }

    public static function getUnlockedItems($userId)
    {
        $db = DB::getInstance();
        try {
            $stmt = $db->prepare("
            SELECT si.* 
            FROM shop_items si
            INNER JOIN user_items ui ON si.id = ui.item_id
            WHERE ui.user_id = :user_id
        ");
            $stmt->execute([':user_id' => $userId]);
            return $stmt->fetchAll(\PDO::FETCH_ASSOC);
        } catch (\Exception $e) {
            return [];
        }
    }

    public static function getAllItemsWithUnlockStatus($userId)
    {
        $db = DB::getInstance();
        try {
            $unlockedItems = self::getUnlockedItems($userId);
            $unlockedIds = array_column($unlockedItems, 'id');

            $stmt = $db->query("SELECT * FROM shop_items ORDER BY type, price");
            $allItems = $stmt->fetchAll(\PDO::FETCH_ASSOC);

            $user = self::getById($userId);
            $userCoins = $user['coins'];

            $categorizedItems = [
                'profile_pictures' => [],
                'banners' => [],
                'titles' => []
            ];

            foreach ($allItems as $item) {
                $item['is_unlocked'] = in_array($item['id'], $unlockedIds) || $userCoins >= $item['price'];
                $categorizedItems[$item['type'] . 's'][] = $item;
            }

            return $categorizedItems;
        } catch (\Exception $e) {
            return [
                'profile_pictures' => [],
                'banners' => [],
                'titles' => []
            ];
        }
    }
}
