<?php
// scripts/auto_import.php

require_once __DIR__ . '/../vendor/autoload.php';

use App\Services\LolEsportsImporter;
use App\Helpers\DB;

function shouldRunImport() {
    $db = DB::getInstance();
    $stmt = $db->prepare("
        SELECT 
            auto_import_enabled,
            last_import,
            import_interval
        FROM import_settings
        WHERE id = 1
    ");
    $stmt->execute();
    $settings = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$settings['auto_import_enabled']) {
        return false;
    }

    if (!$settings['last_import']) {
        return true;
    }

    $lastImport = new DateTime($settings['last_import']);
    $nextImport = $lastImport->add(new DateInterval("PT{$settings['import_interval']}S"));
    return new DateTime() >= $nextImport;
}

if (shouldRunImport()) {
    $importer = new LolEsportsImporter();
    $result = $importer->importUpcomingMatches();

    if ($result['success']) {
        $db = DB::getInstance();
        $stmt = $db->prepare("
            UPDATE import_settings 
            SET last_import = NOW() 
            WHERE id = 1
        ");
        $stmt->execute();
        echo "Import successful: {$result['imported_matches']} matches imported\n";
    } else {
        echo "Import failed: {$result['error']}\n";
        exit(1);
    }
} else {
    echo "Skipping import: Not due yet or disabled\n";
}