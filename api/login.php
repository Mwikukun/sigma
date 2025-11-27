<?php
error_reporting(0);
ini_set('display_errors', 0);

include 'cors.php';

include 'config_api.php';

// Ambil JSON dari Flutter
$data = json_decode(file_get_contents("php://input"), true);
$username = $data['username'] ?? '';
$password = $data['password'] ?? '';

if (empty($username) || empty($password)) {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap"]);
    exit;
}

/*
    ⚡ LOGIN UNIVERSAL:
    Bisa login dengan:
    - username (users.username)
    - NIM mahasiswa (students.student_number)
    - NIP dosen (lecturers.employee_number)
*/

$query = "
    SELECT 
        u.id AS user_id,
        u.name,
        u.username,
        u.user_type,
        u.password,
        s.student_number,
        l.employee_number
    FROM users u
    LEFT JOIN students s ON s.user_id = u.id
    LEFT JOIN lecturers l ON l.user_id = u.id
    WHERE 
        u.username = ?
        OR s.student_number = ?
        OR l.employee_number = ?
    LIMIT 1
";

$stmt = $conn->prepare($query);
$stmt->bind_param("sss", $username, $username, $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["success" => false, "message" => "Akun tidak ditemukan"]);
    exit;
}

$row = $result->fetch_assoc();

// 🔐 Validasi password (plain / hashed)
if ($row['password'] !== $password && !password_verify($password, $row['password'])) {
    echo json_encode(["success" => false, "message" => "Password salah"]);
    exit;
}

// 🎉 Respons rapi untuk Flutter
$response = [
    "success" => true,
    "message" => "Login berhasil",
    "name" => $row['name'],
    "user_type" => $row['user_type'],
    "user_id" => $row['user_id']
];

// Jika mahasiswa → kirim student_number
if ($row['user_type'] === 'student') {
    $response["student_number"] = $row['student_number'];
}

// Jika dosen → kirim employee_number sebagai lecturer_id final
if ($row['user_type'] === 'lecturer') {
    $response["lecturer_id"] = $row['employee_number']; 
}

echo json_encode($response);

$stmt->close();
$conn->close();
?>
