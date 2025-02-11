<?php

namespace App\Helpers;

use PDO;
use PDOException;

class DB
{
    // Instance unique de la connexion PDO
    private static $instance = null;

    // Configuration de la base de données
    private static $host = 'localhost';       // Hôte de la base de données
    private static $dbname = 'comeback_db';   // Nom de la base de données
    private static $username = 'root';        // Nom d'utilisateur
    private static $password = '';            // Mot de passe

    // Méthode pour obtenir l'instance unique
    public static function getInstance()
    {
        if (self::$instance === null) {
            try {
                // Création d'une nouvelle instance PDO
                self::$instance = new PDO(
                    "mysql:host=" . self::$host . ";dbname=" . self::$dbname . ";charset=utf8mb4",
                    self::$username,
                    self::$password
                );

                // Configuration des options PDO
                self::$instance->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
                self::$instance->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

            } catch (PDOException $e) {
                // Gestion des erreurs de connexion
                die(json_encode([
                    "error" => "Database Connection Failed",
                    "message" => $e->getMessage()
                ]));
            }
        }

        return self::$instance;
    }

    // Méthode pour fermer la connexion (optionnelle)
    public static function closeConnection()
    {
        self::$instance = null;
    }
}
