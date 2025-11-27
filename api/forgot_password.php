<?php
include 'config_api.php';
include 'cors.php';

$data = json_decode(file_get_contents('php://input'), true);
$email = $data['email'] ?? '';
$newPassword = $data['new_password'] ?? '';

if (empty($email) || empty($newPassword)) {
    echo json_encode(["success" => false, "message" => "Email dan password baru wajib diisi"]);
    exit;
}

/* ✅ Tambah validasi password (tanpa ubah logika lama)
   - Minimal 8 karakter
   - Harus ada huruf besar
   - Harus ada angka
*/
if (strlen($newPassword) < 8) {
    echo json_encode(["success" => false, "message" => "Password minimal 8 karakter"]);
    exit;
}
if (!preg_match('/[A-Z]/', $newPassword)) {
    echo json_encode(["success" => false, "message" => "Password harus mengandung huruf besar"]);
    exit;
}
if (!preg_match('/\d/', $newPassword)) {
    echo json_encode(["success" => false, "message" => "Password harus mengandung angka"]);
    exit;
}

// Cek apakah email ada di database
$query = $conn->prepare("SELECT id FROM users WHERE email = ?");
$query->bind_param("s", $email);
$query->execute();
$result = $query->get_result();

if ($result->num_rows > 0) {
    // Hash password biar aman
    $hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);
    $update = $conn->prepare("UPDATE users SET password = ? WHERE email = ?");
    $update->bind_param("ss", $hashedPassword, $email);

    if ($update->execute()) {
        echo json_encode(["success" => true, "message" => "Password berhasil diubah"]);
    } else {
        echo json_encode(["success" => false, "message" => "Gagal mengubah password"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Email tidak ditemukan"]);
}
?>
