<?php
include 'cors.php';
require_once("config_api.php");

$data = json_decode(file_get_contents("php://input"), true);

$lecturer_id = $data['lecturer_id'] ?? '';
$name = $data['name'] ?? '';
$phone = $data['phone_number'] ?? '';
$expertise = $data['expertise'] ?? '';
$password = $data['password'] ?? '';

if (empty($lecturer_id) || empty($name) || empty($phone)) {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap"]);
    exit;
}

// update name, phone, expertise
$query = "
  UPDATE users u
  JOIN lecturers l ON u.id = l.user_id
  SET u.name = ?, u.phone_number = ?, l.expertise = ?
  WHERE l.employee_number = ?
";
$stmt = $conn->prepare($query);
$stmt->bind_param("ssss", $name, $phone, $expertise, $lecturer_id);
$stmt->execute();

// update password kalau diisi
if (!empty($password)) {
    $hash = password_hash($password, PASSWORD_DEFAULT);
    $q2 = "
      UPDATE users u
      JOIN lecturers l ON u.id = l.user_id
      SET u.password = ?
      WHERE l.employee_number = ?
    ";
    $stmt2 = $conn->prepare($q2);
    $stmt2->bind_param("ss", $hash, $lecturer_id);
    $stmt2->execute();
}

echo json_encode(["success" => true, "message" => "Profil berhasil diperbarui"]);

$stmt->close();
$conn->close();
