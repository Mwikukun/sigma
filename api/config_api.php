<?php
$host = "localhost";
$user = "root";
$pass = "";
$db   = "sigma_db";

$conn = mysqli_connect($host, $user, $pass, $db);

if (!$conn) {
    echo json_encode([
        "status" => false,
        "message" => "Koneksi gagal: " . mysqli_connect_error()
    ]);
    exit;
}
?>
