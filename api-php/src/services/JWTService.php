<?php

namespace App\Services;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JWTService
{
    private static $key = "your_secret_key";

    public static function generateToken($payload)
    {
        return JWT::encode($payload, self::$key, 'HS256');
    }

    public static function validateToken($token)
    {
        try {
            return JWT::decode($token, new Key(self::$key, 'HS256'));
        } catch (\Exception $e) {
            return null;
        }
    }
}
