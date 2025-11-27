<?php
include 'cors.php';

include "config_api.php";

$student_id = $_POST['student_id'] ?? null;
$chapter = $_POST['chapter'] ?? null;
$title = $_POST['title'] ?? '';
$note = $_POST['note'] ?? '';

if (!$student_id || !$chapter || !isset($_FILES['file'])) {
    echo json_encode(["success"=>false,"message"=>"missing required data"]);
    exit;
}

// hitung versi (COUNT)
$qv = "SELECT COUNT(*) AS v FROM documents WHERE student_id = ? AND chapter = ?";
$stmt = $conn->prepare($qv);
$stmt->bind_param("is", $student_id, $chapter);
$stmt->execute();
$res = $stmt->get_result()->fetch_assoc();
$version = $res['v'] + 1;

// upload file
$dir = "uploads/documents/";
if (!is_dir($dir)) mkdir($dir, 0777, true);

$ext = pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION);
$filename = time() . "_{$student_id}_{$chapter}_v{$version}." . $ext;

move_uploaded_file($_FILES['file']['tmp_name'], $dir . $filename);

// INSERT documents (versi otomatis)
$q = "INSERT INTO documents (student_id, attachment, title, chapter, note, status) 
      VALUES (?, ?, ?, ?, ?, 'pending')";
$stmt = $conn->prepare($q);
$stmt->bind_param("issss", $student_id, $filename, $title, $chapter, $note);
$success = $stmt->execute();

echo json_encode([
    "success"=>$success,
    "version"=>$version,
    "filename"=>$filename
]);
?>
