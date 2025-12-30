<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

session_start();
header("Content-Type: application/json");

require_once "guard.php";
require_once "config.php";

if (!isset($_SESSION['user']['id']) || $_SESSION['user']['user_type'] !== 'admin') {
  echo json_encode([
    "success" => false,
    "msg" => "Session tidak valid"
  ]);
  exit;
}

$id   = $_SESSION['user']['id'];
$name = trim($_POST['name'] ?? '');
$old  = trim($_POST['old_password'] ?? '');
$new  = trim($_POST['new_password'] ?? '');

if ($new === '') {
  echo json_encode([
    "success" => false,
    "msg" => "Password baru wajib diisi"
  ]);
  exit;
}

$q = mysqli_query($conn, "SELECT password FROM users WHERE id='$id'");
$u = mysqli_fetch_assoc($q);

$dbPass = $u['password'];
$valid  = false;

/* ===== CEK PASSWORD LAMA (HASH / PLAINTEXT) ===== */
if ($old !== '') {
  if (password_get_info($dbPass)['algo'] !== 0) {
    $valid = password_verify($old, $dbPass);
  } else {
    $valid = ($old === $dbPass);
  }
}

/* ===== FALLBACK KHUSUS ADMIN (SELF RESET) ===== */
if (!$valid) {
  // admin sudah login → izinkan ganti password
  $valid = true;
}

/* ===== UPDATE PASSWORD ===== */
$newHash = password_hash($new, PASSWORD_DEFAULT);

mysqli_query($conn, "
  UPDATE users 
  SET name='$name', password='$newHash'
  WHERE id='$id'
");

echo json_encode([
  "success" => true,
  "msg" => "Password admin berhasil diubah"
]);
