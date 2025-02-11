<?php

namespace App\Models;

use App\Helpers\DB;
use Exception;

class AssetFile
{
    private static function getUploadPath($fileType)
    {
        // Utiliser le chemin absolu du serveur
        $basePath = $_SERVER['DOCUMENT_ROOT'] . '/api/public/uploads/';
        
        switch ($fileType) {
            case 'profile_picture':
                return $basePath . 'profile_pictures/';
            case 'banner':
                return $basePath . 'banners/';
            default:
                throw new Exception("Type de fichier non supporté");
        }
    }

    public static function upload($file, $fileType, $uploadedBy)
    {
        $db = DB::getInstance();
        
        try {
            // Vérification du type MIME
            $finfo = finfo_open(FILEINFO_MIME_TYPE);
            $mimeType = finfo_file($finfo, $file['tmp_name']);
            finfo_close($finfo);

            // Vérifier si c'est une image
            if (!str_starts_with($mimeType, 'image/')) {
                throw new Exception("Le fichier doit être une image");
            }

            // Générer un nom de fichier unique
            $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
            $fileName = uniqid() . '.' . $extension;
            
            // Chemin de destination
            $uploadPath = self::getUploadPath($fileType);
            $filePath = $uploadPath . $fileName;

            // Vérifier si le dossier existe, sinon le créer
            if (!file_exists($uploadPath)) {
                if (!mkdir($uploadPath, 0755, true)) {
                    throw new Exception("Impossible de créer le dossier de destination");
                }
            }

            // Déplacer le fichier
            if (!move_uploaded_file($file['tmp_name'], $filePath)) {
                error_log("Échec de l'upload. De: " . $file['tmp_name'] . " Vers: " . $filePath);
                throw new Exception("Échec de l'upload du fichier");
            }

            // Chemin relatif pour la base de données
            $dbFilePath = str_replace($_SERVER['DOCUMENT_ROOT'] . '/api/public/', '', $filePath);

            // Enregistrer dans la base de données
            $stmt = $db->prepare("
                INSERT INTO asset_files (
                    file_name, file_path, file_type, mime_type, file_size, uploaded_by
                ) VALUES (
                    :file_name, :file_path, :file_type, :mime_type, :file_size, :uploaded_by
                )
            ");

            $stmt->execute([
                ':file_name' => $fileName,
                ':file_path' => $dbFilePath,
                ':file_type' => $fileType,
                ':mime_type' => $mimeType,
                ':file_size' => $file['size'],
                ':uploaded_by' => $uploadedBy
            ]);

            return $db->lastInsertId();
        } catch (Exception $e) {
            error_log("Erreur lors de l'upload: " . $e->getMessage());
            if (isset($filePath) && file_exists($filePath)) {
                unlink($filePath);
            }
            throw $e;
        }
    }

    public static function getById($id)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("SELECT * FROM asset_files WHERE id = :id");
        $stmt->execute([':id' => $id]);
        return $stmt->fetch();
    }

    public static function getAllByType($fileType)
    {
        $db = DB::getInstance();
        $stmt = $db->prepare("SELECT * FROM asset_files WHERE file_type = :type");
        $stmt->execute([':type' => $fileType]);
        return $stmt->fetchAll();
    }

    public static function delete($id)
    {
        $db = DB::getInstance();
        $asset = self::getById($id);
        
        if ($asset) {
            $filePath = $_SERVER['DOCUMENT_ROOT'] . '/api/public/' . $asset['file_path'];
            if (file_exists($filePath)) {
                unlink($filePath);
            }
        }

        $stmt = $db->prepare("DELETE FROM asset_files WHERE id = :id");
        return $stmt->execute([':id' => $id]);
    }
}