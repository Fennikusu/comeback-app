<?php

namespace App\Controllers;

use App\Models\User;

class LeaderboardController
{
    public function getGlobalLeaderboard()
    {
        // Récupérer les utilisateurs triés par nombre de coins décroissant
        $users = User::getAllSortedByCoins();
        echo json_encode($users);
    }

    public function getFriendsLeaderboard($userId)
    {
        // Récupérer les amis triés par nombre de coins
        $friends = User::getFriendsSortedByCoins($userId);
        echo json_encode($friends);
    }

    public function getAudaciousLeaderboard()
    {
        // Récupérer le plus gros gagnant et le plus gros perdant du jour
        $winner = User::getBiggestWinnerOfDay();
        $loser = User::getBiggestLoserOfDay();

        echo json_encode([
            'winner' => $winner,
            'loser' => $loser
        ]);
    }
}