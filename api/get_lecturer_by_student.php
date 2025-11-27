<?php
include 'cors.php';

require_once("config_api.php");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

// FIX: BACA POST atau GET (Chrome Flutter Web suka kosongkan POST)
$student_id = $_POST['student_id'] 
           ?? $_GET['student_id'] 
           ?? null;

// DEBUG:
file_put_contents("debug_student.txt", "student_id = ".$student_id);

if (!$student_id) {
    echo json_encode(["success" => false, "message" => "student_id is required"]);
    exit;
}

$stmt = $conn->prepare("
    SELECT lecturer_id 
    FROM guidances
    WHERE student_id = ?
      AND is_approved = 1
    LIMIT 1
");

$stmt->bind_param("s", $student_id);
$stmt->execute();
$res = $stmt->get_result();

if ($row = $res->fetch_assoc()) {
    echo json_encode([
        "success" => true,
        "lecturer_id" => $row['lecturer_id']
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Dosen pembimbing tidak ditemukan"
    ]);
}
?>
