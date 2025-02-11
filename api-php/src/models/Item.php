<?php

namespace App\Models;

use App\Helpers\DB;

class Item
{
    // Récupérer tous les items de la boutique
    public static function getAll()
    {
        $db = DB::getInstance();
        $stmt = $db->query("SELECT * FROM items");
        return $stmt->fetchAll();
    }

    // Acheter un item
    public static function purchase($userId, $itemId)
    {
        $db = DB::getInstance();

        // Récupérer le coût de l'item
        $stmt = $db->prepare("SELECT price FROM items WHERE id = :id");
        $stmt->execute([':id' => $itemId]);
        $item = $stmt->fetch();

        if (!$item) {
            return ["success" => false, "message" => "Item not found"];
        }

        $price = $item['price'];

        // Vérifier les coins de l'utilisateur
        $stmt = $db->prepare("SELECT coins FROM users WHERE id = :id");
        $stmt->execute([':id' => $userId]);
        $user = $stmt->fetch();

        if (!$user || $user['coins'] < $price) {
            return ["success" => false, "message" => "Not enough coins"];
        }

        // Effectuer l'achat
        $db->beginTransaction();
        try {
            // Déduire les coins de l'utilisateur
            $stmt = $db->prepare("UPDATE users SET coins = coins - :price WHERE id = :id");
            $stmt->execute([':price' => $price, ':id' => $userId]);

            // Ajouter l'item à l'inventaire de l'utilisateur
            $stmt = $db->prepare("INSERT INTO user_items (user_id, item_id) VALUES (:user_id, :item_id)");
            $stmt->execute([':user_id' => $userId, ':item_id' => $itemId]);

            $db->commit();
            return ["success" => true, "message" => "Item purchased successfully"];
        } catch (\Exception $e) {
            $db->rollBack();
            return ["success" => false, "message" => "Purchase failed"];
        }
    }
}
