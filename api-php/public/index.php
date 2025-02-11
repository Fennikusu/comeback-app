<?php

// Chargement automatique des classes avec Composer
require_once '../vendor/autoload.php';

// Chargement des routes
require_once '../src/routes/routes.php';

// Configuration des en-têtes HTTP
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Gérer les requêtes OPTIONS (préflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit();
}

// Initialisation et exécution du routeur
use App\Routes\Router;

try {
    $router = new Router();
    $router->dispatch();
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "error" => "Internal Server Error",
        "message" => $e->getMessage()
    ]);
}