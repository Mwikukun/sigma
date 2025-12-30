<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

if (session_status() == PHP_SESSION_NONE) {
    session_start();
}

include "config.php";
header("Content-Type: application/json");

// Ambil data JSON dari fetch()
$input = json_decode(file_get_contents("php://input"), true);

// Cek kalau data kosong
if (!$input || !isset($input['username']) || !isset($input['password'])) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Data tidak lengkap!'
    ]);
    exit;
}

$username = $input['username'];
$password = $input['password'];

// Cek user admin
$query  = "SELECT * FROM users WHERE username='$username' AND user_type='admin' LIMIT 1";
$result = mysqli_query($conn, $query);

if (mysqli_num_rows($result) === 1) {
    $user = mysqli_fetch_assoc($result);

    // Cek password (support hash & plaintext lama)
   if (password_verify($password, $user['password']) || $password === $user['password']) {

    $_SESSION['admin_id'] = $user['id']; // 🔥 WAJIB

    $_SESSION['admin_logged_in'] = true;
    $_SESSION['admin_name']      = $user['name'];

    $_SESSION['user'] = [
        'id'        => $user['id'],
        'name'      => $user['name'],
        'username'  => $user['username'],
        'user_type' => $user['user_type']
    ];

    echo json_encode([
        'status'  => 'success',
        'message' => 'Login berhasil!'
    ]);
} else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Password salah!'
        ]);
    }
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Username tidak ditemukan!'
    ]);
}
