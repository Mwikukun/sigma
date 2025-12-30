<?php
include 'config_api.php';

$student_id = $_GET['student_id'] ?? '';

$query = "SELECT 
            id,
            title,
            description,
            due_date,
            student_id,
            status AS section
          FROM activities
          WHERE student_id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $student_id);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode(["success" => true, "kanban" => $data]);
