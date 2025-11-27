<?php
// ===== FIX CORS UNTUK FLUTTER WEB =====
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, X-Requested-With, Authorization");

// Handle preflight (Flutter Web OPTIONS request)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
?>
