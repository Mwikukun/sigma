<?php
include 'cors.php';
require_once("config_api.php");

$data = json_decode(file_get_contents("php://input"), true);
$lecturer_id = $data['lecturer_id'] ?? '';

if (empty($lecturer_id)) {
    echo json_encode(["success" => false, "message" => "Lecturer ID kosong"]);
    exit;
}

$query = "
    SELECT 
        u.name,
        u.phone_number,
        u.email,
        l.employee_number,
        l.expertise,
        sp.title AS study_program
    FROM lecturers l
    JOIN users u ON u.id = l.user_id
    JOIN study_programs sp ON sp.id = l.study_program_id
    WHERE l.employee_number = ?
    LIMIT 1
";

$stmt = $conn->prepare($query);
$stmt->bind_param("s", $lecturer_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["success" => false, "message" => "Data dosen tidak ditemukan"]);
    exit;
}

$data = $result->fetch_assoc();

echo json_encode([
    "success" => true,
    "data" => $data
]);

$stmt->close();
$conn->close();
