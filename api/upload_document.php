<?php
include 'cors.php';

include "config_api.php";

// Validasi input form
if (!isset($_POST['student_id']) || empty($_POST['student_id'])) {
    echo json_encode(["success" => false, "message" => "student_id missing"]);
    exit;
}

$student_id = $_POST['student_id'];
$chapter    = $_POST['chapter'] ?? null;
$title      = $_POST['title'] ?? null;
$note       = $_POST['note'] ?? null;

// Validasi file
if (!isset($_FILES['file'])) {
    echo json_encode(["success" => false, "message" => "File not uploaded"]);
    exit;
}

$uploadDir = "../uploads/documents/";
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

$filename = time() . "_" . basename($_FILES['file']['name']);
$targetFile = $uploadDir . $filename;

if (!move_uploaded_file($_FILES['file']['tmp_name'], $targetFile)) {
    echo json_encode(["success" => false, "message" => "Failed saving file"]);
    exit;
}

// Insert ke DB
$stmt = $conn->prepare("
    INSERT INTO documents (student_id, attachment, title, chapter, note, status)
    VALUES (?, ?, ?, ?, ?, 'pending')
");

$stmt->bind_param("issss", $student_id, $filename, $title, $chapter, $note);

if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "File uploaded successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Database insert failed"
    ]);
}

$stmt->close();
$conn->close();
?>
