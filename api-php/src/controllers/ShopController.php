<?php

namespace App\Controllers;

use App\Models\User;
use App\Models\ShopItem;
use App\Helpers\DB;
use App\Models\AssetFile;


class ShopController
{
    public function getItems($userId)
    {
        try {
            $db = DB::getInstance();

            $stmt = $db->prepare("
                SELECT 
                    si.*,
                    af.file_path,
                    af.file_name,
                    CASE WHEN ui.user_id IS NOT NULL OR u.coins >= si.price THEN 1 ELSE 0 END as is_unlocked
                FROM shop_items si
                LEFT JOIN asset_files af ON si.asset_id = af.id
                LEFT JOIN user_items ui ON si.id = ui.item_id AND ui.user_id = :user_id
                LEFT JOIN users u ON u.id = :user_id
                ORDER BY si.type, si.price
            ");

            $stmt->execute([':user_id' => $userId]);
            $items = $stmt->fetchAll();

            $groupedItems = [
                'profile_pictures' => [],
                'banners' => [],
                'titles' => []
            ];

            foreach ($items as $item) {
                $itemData = [
                    'id' => $item['id'],
                    'name' => $item['name'],
                    'type' => $item['type'],
                    'price' => $item['price'],
                    'is_unlocked' => (bool) $item['is_unlocked']
                ];

                if ($item['file_path']) {
                    $itemData['asset'] = [
                        'file_path' => $item['file_path']
                    ];
                }

                $groupedItems[$item['type'] . 's'][] = $itemData;
            }

            echo json_encode($groupedItems);

        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode([
                "message" => "Failed to load shop items",
                "error" => $e->getMessage()
            ]);
        }
    }

    public function unlockItems($userId)
    {
        try {
            $data = json_decode(file_get_contents("php://input"), true);
            if (!isset($data['items']) || !is_array($data['items'])) {
                http_response_code(400);
                echo json_encode(["message" => "Invalid request format"]);
                return;
            }

            $successCount = 0;
            foreach ($data['items'] as $itemId) {
                if (User::unlockItem($userId, $itemId)) {
                    $successCount++;
                }
            }

            echo json_encode([
                "message" => "Successfully unlocked $successCount items",
                "unlocked_count" => $successCount
            ]);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode([
                "message" => "Error unlocking items",
                "error" => $e->getMessage()
            ]);
        }
    }

    public function checkNewUnlocks($userId)
    {
        try {
            $user = User::getById($userId);
            if (!$user) {
                http_response_code(404);
                echo json_encode(["message" => "User not found"]);
                return;
            }

            $userCoins = $user['coins'];
            $db = DB::getInstance();

            $stmt = $db->prepare("
                SELECT * FROM shop_items si
                WHERE si.price <= :coins
                AND NOT EXISTS (
                    SELECT 1 FROM user_items ui
                    WHERE ui.user_id = :user_id
                    AND ui.item_id = si.id
                )
            ");

            $stmt->execute([
                ':coins' => $userCoins,
                ':user_id' => $userId
            ]);

            $newUnlocks = $stmt->fetchAll(\PDO::FETCH_ASSOC);

            echo json_encode([
                "new_unlocks" => $newUnlocks,
                "count" => count($newUnlocks)
            ]);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode([
                "message" => "Error checking new unlocks",
                "error" => $e->getMessage()
            ]);
        }
    }

    public function uploadAsset() {
        try {
            header('Content-Type: application/json');
            
            if (!isset($_FILES['file'])) {
                throw new \Exception("Aucun fichier n'a été envoyé");
            }

            $fileType = $_POST['type'] ?? null;
            $name = $_POST['name'] ?? null;
            $price = $_POST['price'] ?? null;

            if (!in_array($fileType, ['profile_picture', 'banner'])) {
                throw new \Exception("Type de fichier invalide");
            }

            $db = DB::getInstance();
            $db->beginTransaction();

            try {
                // Upload du fichier
                $assetId = AssetFile::upload($_FILES['file'], $fileType, 1);
                
                // Création de l'item dans la boutique
                $stmt = $db->prepare("
                    INSERT INTO shop_items (name, type, price, asset_id) 
                    VALUES (:name, :type, :price, :asset_id)
                ");

                $stmt->execute([
                    ':name' => $name,
                    ':type' => $fileType,
                    ':price' => $price,
                    ':asset_id' => $assetId
                ]);

                $asset = AssetFile::getById($assetId);
                
                $db->commit();
                
                echo json_encode([
                    "success" => true,
                    "message" => "Item créé avec succès",
                    "asset" => $asset
                ]);
            } catch (\Exception $e) {
                $db->rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            error_log('Error in uploadAsset: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode([
                "success" => false,
                "message" => $e->getMessage()
            ]);
        }
    }

    public function getAssets($type)
    {
        try {
            header('Content-Type: application/json');

            if (!in_array($type, ['profile_picture', 'banner'])) {
                throw new \Exception("Type invalide");
            }

            $assets = AssetFile::getAllByType($type);
            echo json_encode([
                "success" => true,
                "assets" => $assets
            ]);

        } catch (\Exception $e) {
            error_log('Erreur dans getAssets: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode([
                "success" => false,
                "message" => $e->getMessage()
            ]);
        }
    }

    public function assignAssetToItem()
    {
        try {
            $data = json_decode(file_get_contents("php://input"), true);

            if (!isset($data['item_id']) || !isset($data['asset_id'])) {
                throw new \Exception("item_id et asset_id sont requis");
            }

            $db = DB::getInstance();
            $stmt = $db->prepare("
                UPDATE shop_items 
                SET asset_id = :asset_id 
                WHERE id = :item_id
            ");

            $success = $stmt->execute([
                ':asset_id' => $data['asset_id'],
                ':item_id' => $data['item_id']
            ]);

            if (!$success) {
                throw new \Exception("Erreur lors de l'association de l'asset");
            }

            echo json_encode([
                "success" => true,
                "message" => "Asset associé avec succès"
            ]);

        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode([
                "success" => false,
                "message" => $e->getMessage()
            ]);
        }
    }

    public function deleteAsset($assetId)
    {
        try {
            // Vérifier si l'asset est utilisé
            $db = DB::getInstance();
            $stmt = $db->prepare("
                SELECT COUNT(*) FROM shop_items 
                WHERE asset_id = :asset_id
            ");
            $stmt->execute([':asset_id' => $assetId]);

            if ($stmt->fetchColumn() > 0) {
                throw new \Exception("Cet asset est utilisé par un ou plusieurs items");
            }

            if (AssetFile::delete($assetId)) {
                echo json_encode([
                    "success" => true,
                    "message" => "Asset supprimé avec succès"
                ]);
            } else {
                throw new \Exception("Erreur lors de la suppression de l'asset");
            }
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode([
                "success" => false,
                "message" => $e->getMessage()
            ]);
        }
    }
}