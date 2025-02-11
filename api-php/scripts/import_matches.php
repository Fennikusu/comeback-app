<?php
// scripts/import_matches.php

require_once __DIR__ . '/../vendor/autoload.php';

use App\Services\LolEsportsImporter;

$importer = new LolEsportsImporter();
$result = $importer->importUpcomingMatches();

if ($result['success']) {
    echo "Successfully imported {$result['imported_matches']} matches\n";
} else {
    echo "Import failed: {$result['error']}\n";
    exit(1);
}