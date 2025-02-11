<?php

namespace App\Models;

use App\Helpers\DB;


class ShopItem
{
    public static function getAll()
    {
        $db = DB::getInstance();
        $stmt = $db->query("SELECT * FROM shop_items ORDER BY type, price");
        return $stmt->fetchAll(\PDO::FETCH_ASSOC);
    }

    public static function getById($id)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("SELECT * FROM shop_items WHERE id = :id");
        $stmt->execute([':id' => $id]);
        return $stmt->fetch(\PDO::FETCH_ASSOC);
    }
}