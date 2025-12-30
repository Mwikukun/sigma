<?php
include 'cors.php';
include "config_api.php";

$student_id  = $_POST['student_id'] ?? '';
$lecturer_id = $_POST['lecturer_id'] ?? '';

if (empty($student_id) || empty($lecturer_id)) {
    echo json_encode([
        "success" => false,
        "message" => "Data tidak lengkap"
    ]);
    exit;
}

$query = "
    UPDATE guidances
    SET is_approved = 3
    WHERE student_id = ? AND lecturer_id = ?
";

$stmt = $conn->prepare($query);
$stmt->bind_param("ii", $student_id, $lecturer_id);

if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Mahasiswa berhasil ditandai selesai"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Gagal memperbarui status"
    ]);
}

$stmt->close();
$conn->close();
