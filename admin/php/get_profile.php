<?php
session_start();

header("Content-Type: application/json");

require_once "guard.php";
require_once "config.php";

if (!isset($_SESSION['user'])) {
    echo json_encode(["success" => false]);
    exit;
}

echo json_encode([
    "success" => true,
    "name" => $_SESSION['user']['name'],
    "username" => $_SESSION['user']['username']
]);
