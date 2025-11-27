<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

if (session_status() == PHP_SESSION_NONE) {
    session_start();
}

header('Content-Type: application/json');
include "config.php";

// Ambil data JSON dari fetch()
$input = json_decode(file_get_contents("php://input"), true);

// Cek kalau data kosong
if (!$input || !isset($input['username']) || !isset($input['password'])) {
    echo json_encode(['status' => 'error', 'message' => 'Data tidak lengkap!']);
    exit;
}

$username = $input['username'];
$password = $input['password'];

// Cek user di database
$query = "SELECT * FROM users WHERE username='$username' AND user_type='admin'";
$result = mysqli_query($conn, $query);

if (mysqli_num_rows($result) == 1) {
    $user = mysqli_fetch_assoc($result);

    // Cek password
    if (password_verify($password, $user['password']) || $password === $user['password']) {
        $_SESSION['admin_logged_in'] = true;
        $_SESSION['admin_name'] = $user['name'];
        echo json_encode(['status' => 'success', 'message' => 'Login berhasil!']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Password salah!']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Username tidak ditemukan!']);
}
?>
