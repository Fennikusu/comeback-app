<?php
namespace App\Routes;

use App\Controllers\AuthController;
use App\Controllers\BetController;
use App\Controllers\UserController;
use App\Controllers\ShopController;
use App\Controllers\LeaderboardController;
use App\Controllers\MatchesController;
use App\Services\LolEsportsImporter;



if (!class_exists(AuthController::class)) {
    die("Class AuthController not found");
}


class Router
{
    public function dispatch()
    {
        // Obtenir le chemin et la méthode de la requête
        $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
        $method = $_SERVER['REQUEST_METHOD'];




        // Définir les routes disponibles
        switch ($path) {
            // Routes pour l'authentification
            case '/api/public/login':
                if ($method === 'POST') {
                    (new AuthController())->login();
                }
                break;

            case '/api/public/register':
                if ($method === 'POST') {
                    (new AuthController())->register();
                }
                break;

            case '/api/public/logout':
                if ($method === 'POST') {
                    (new AuthController())->logout();
                }
                break;

            case '/api/public/leaderboard/audacious':
                if ($method === 'GET') {
                    (new LeaderboardController())->getAudaciousLeaderboard();
                }
                break;

            // Routes pour les paris
            case '/api/public/bets':
                if ($method === 'GET') {
                    (new BetController())->listBets();
                } elseif ($method === 'POST') {
                    (new BetController())->createBet();
                }
                break;

            case (preg_match('#^/api/public/profile/(\d+)/items$#', $path, $matches) ? $path : !$path):
                if ($method === 'GET') {
                    $userId = $matches[1];
                    (new UserController())->getUserItems($userId);
                }
                break;

            case (preg_match('#^/api/public/profile/(\d+)/update$#', $path, $matches) ? $path : !$path):
                if ($method === 'POST') {
                    $userId = $matches[1];
                    (new UserController())->updateProfile($userId);
                }
                break;

            case (preg_match('#^/api/public/profile/(\d+)$#', $path, $matches) ? $path : !$path):
                if ($method === 'GET') {
                    $userId = $matches[1];
                    (new UserController())->getUserProfile($userId);
                }
                break;

            case (preg_match('#^/api/public/profile/(\d+)/available-items$#', $path, $matches) ? $path : !$path):
                if ($method === 'GET') {
                    $userId = $matches[1];
                    (new UserController())->getAvailableItems($userId);
                }
                break;

            case (preg_match('#^/api/public/leaderboard/friends/(\d+)$#', $path, $matches) ? $path : !$path):
                if ($method === 'GET') {
                    $userId = $matches[1];
                    (new LeaderboardController())->getFriendsLeaderboard($userId);
                }
                break;

            case (preg_match('#^/api/public/bets/(\d+)$#', $path, $matches) ? $path : !$path):
                if ($method === 'GET') {
                    (new BetController())->getBetById($matches[1]);
                }
                break;

            case (preg_match('#^/api/public/users/(\d+)/balance$#', $path, $matches) ? $path : !$path):
                if ($method === 'GET') {
                    (new UserController())->getUserBalance($matches[1]);
                }
                break;

            case '/api/public/bets/update':
                if ($method === 'PUT') {
                    (new BetController())->updateBet();
                }
                break;

            case (preg_match('#^/api/public/users/(\d+)/bets$#', $path, $matches) ? $path : !$path):
                if ($method === 'GET') {
                    $userId = $matches[1];
                    (new BetController())->getUserBets($userId);
                }
                break;

            case '/api/public/leaderboard/global':
                if ($method === 'GET') {
                    (new LeaderboardController())->getGlobalLeaderboard();
                }
                break;

            case '/api/public/bets/place':
                if ($method === 'POST') {
                    (new BetController())->placeBet();
                }
                break;

            // Routes pour les utilisateurs
            case '/api/public/profile':
                if ($method === 'GET') {
                    (new UserController())->getProfile();
                } elseif ($method === 'POST') {
                    (new UserController())->updateProfile();
                }
                break;

            case '/api/public/leaderboard':
                if ($method === 'GET') {
                    (new UserController())->getLeaderboard();
                }
                break;

            case '/api/public/shop/buy':
                if ($method === 'POST') {
                    (new ShopController())->buyItem();
                }
                break;

            case (preg_match('#^/api/public/users/(\d+)/friends$#', $path, $matches) ? $path : !$path):
                $userId = $matches[1];
                if ($method === 'GET') {
                    (new UserController())->getFriendsList($userId);
                } elseif ($method === 'POST') {
                    (new UserController())->addFriend($userId);
                }
                break;

            case (preg_match('#^/api/public/users/(\d+)/friends/(\d+)$#', $path, $matches) ? $path : !$path):
                if ($method === 'DELETE') {
                    $userId = $matches[1];
                    $friendId = $matches[2];
                    (new UserController())->removeFriend($userId, $friendId);
                }
                break;

            case '/api/public/shop/items':
                if ($method === 'GET') {
                    $userId = $_GET['user_id'] ?? null;
                    if (!$userId) {
                        http_response_code(400);
                        echo json_encode(["message" => "User ID is required"]);
                        return;
                    }
                    (new ShopController())->getItems($userId);
                }
                break;

            case (preg_match('#^/api/public/users/(\d+)/unlocks/new$#', $path, $matches) ? $path : !$path):
                if ($method === 'GET') {
                    $userId = $matches[1];
                    (new ShopController())->checkNewUnlocks($userId);
                }
                break;

            case (preg_match('#^/api/public/users/(\d+)/unlocks$#', $path, $matches) ? $path : !$path):
                if ($method === 'POST') {
                    $userId = $matches[1];
                    (new ShopController())->unlockItems($userId);
                }
                break;

            case (preg_match('#^/api/public/profile/(\d+)/bets$#', $path, $matches) ? $path : !$path):
                if ($method === 'GET') {
                    $userId = $matches[1];
                    (new UserController())->getRecentBets($userId);
                }
                break;

            case (preg_match('#^/api/public/profile/(\d+)/daily-chest$#', $path, $matches) ? $path : !$path):
                if ($method === 'GET') {
                    $userId = $matches[1];
                    (new UserController())->getDailyChest($userId);
                } elseif ($method === 'POST') {
                    $userId = $matches[1];
                    (new UserController())->claimDailyChest($userId);
                }
                break;

            case (preg_match('#^/api/public/profile/(\d+)/last-session-earnings$#', $path, $matches) ? $path : !$path):
                if ($method === 'GET') {
                    $userId = $matches[1];
                    (new UserController())->getLastSessionEarnings($userId);
                }
                break;


            case '/api/public/bets/finish':
                if ($method === 'POST') {
                    (new BetController())->finishBet();
                }
                break;

            case (preg_match('#^/api/public/bets/(\d+)/stats$#', $path, $matches) ? $path : !$path):
                if ($method === 'GET') {
                    $betId = $matches[1];
                    (new BetController())->getBetStats($betId);
                }
                break;

            case '/api/public/bets/update-status':
                if ($method === 'POST') {
                    (new BetController())->updateBetStatus();
                }
                break;

            case '/api/public/matches/import':
                if ($method === 'POST') {
                    (new MatchesController())->importMatches();
                }
                break;

            case '/api/public/matches/import-settings':
                if ($method === 'GET') {
                    (new MatchesController())->getImportSettings();
                } elseif ($method === 'POST') {
                    (new MatchesController())->updateImportSettings();
                }
                break;

            case '/api/public/matches/auto-import':
                if ($method === 'POST') {
                    (new MatchesController())->setAutoImport();
                }
                break;

            case '/api/public/matches/pending':
                if ($method === 'GET') {
                    (new MatchesController())->getPendingMatches();
                }
                break;

            case '/api/public/matches/validate':
                if ($method === 'POST') {
                    (new MatchesController())->validateMatch();
                }
                break;

            case '/api/public/matches/available-leagues':
                if ($method === 'GET') {
                    $importer = new LolEsportsImporter();
                    echo json_encode($importer->listAvailableLeagues());
                }
                break;

            // Upload d'asset
            case '/api/public/assets/upload':
                if ($method === 'POST') {
                    (new ShopController())->uploadAsset();
                }
                break;

            // Récupération des assets par type
            case '/api/public/assets':
                if ($method === 'GET') {
                    $type = $_GET['type'] ?? null;
                    if (!$type) {
                        http_response_code(400);
                        echo json_encode(["message" => "Le type d'asset est requis"]);
                        return;
                    }
                    (new ShopController())->getAssets($type);
                }
                break;

            // Association d'un asset à un item
            case '/api/public/shop/items/asset':
                if ($method === 'POST') {
                    (new ShopController())->assignAssetToItem();
                }
                break;

            // Suppression d'un asset
            case (preg_match('#^/api/public/assets/(\d+)$#', $path, $matches) ? $path : !$path):
                if ($method === 'DELETE') {
                    $assetId = $matches[1];
                    (new ShopController())->deleteAsset($assetId);
                }
                break;

            // Route par défaut (404)
            default:
                http_response_code(404);
                echo json_encode([$method => $path]);
        }
    }
}
