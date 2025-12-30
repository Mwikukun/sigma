<?php
include 'cors.php';
require_once("config_api.php");

$studentNumber = $_POST['student_number'] ?? '';

if (empty($studentNumber)) {
    echo json_encode([
        "success" => false,
        "message" => "Student number kosong"
    ]);
    exit;
}

$query = "
    SELECT 
        u.name,
        u.email,
        u.phone_number AS phone,
        s.student_number
    FROM students s
    JOIN users u ON u.id = s.user_id
    WHERE s.student_number = ?
    LIMIT 1
";


$stmt = $conn->prepare($query);
$stmt->bind_param("s", $studentNumber);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode([
        "success" => false,
        "message" => "Data mahasiswa tidak ditemukan"
    ]);
    exit;
}

$data = $result->fetch_assoc();

echo json_encode([
    "success" => true,
    "data" => $data
]);

$stmt->close();
$conn->close();
