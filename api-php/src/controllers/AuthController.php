<?php

namespace App\Controllers;

use App\Models\User;
use App\Services\JWTService;

class AuthController
{
    // Connexion utilisateur
    public function login()
    {
        $data = json_decode(file_get_contents("php://input"), true);

        if (!isset($data['email']) || !isset($data['password'])) {
            http_response_code(400);
            echo json_encode(["message" => "Email and password are required"]);
            return;
        }

        $user = User::getByEmail($data['email']);
        if ($user && password_verify($data['password'], $user['password'])) {
            $token = JWTService::generateToken(['id' => $user['id'], 'email' => $user['email']]);
            echo json_encode(["token" => $token, "user" => $user]);
        } else {
            http_response_code(401);
            echo json_encode(["message" => "Invalid credentials"]);
            var_dump($data['password']); // Mot de passe entré
            var_dump($user['password']); // Hash stocké en base de données
            var_dump(password_verify($data['password'], $user['password'])); // Vérification du hash
        }
    }

    // Inscription utilisateur
    public function register()
    {
        $data = json_decode(file_get_contents("php://input"), true);

        if (!isset($data['pseudo'], $data['email'], $data['password'])) {
            http_response_code(400);
            echo json_encode(["message" => "pseudo, email, and password are required"]);
            return;
        }

        if (User::register($data)) {
            echo json_encode(["message" => "User registered successfully"]);
        } else {
            http_response_code(500);
            echo json_encode(["message" => "Registration failed"]);
        }
    }

    // Déconnexion (simulé, rien à faire avec JWT)
    public function logout()
    {
        echo json_encode(["message" => "Logout successful"]);
    }

    

    
}
