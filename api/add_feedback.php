<?php
include 'cors.php';
include 'config_api.php';

$document_id = $_POST['document_id'];
$comment = $_POST['comment'];
$filename = null;

// Upload file jika ada
if (!empty($_FILES['attachment']['name'])) {

    // Simpan nama file
    $filename = time() . "_" . basename($_FILES["attachment"]["name"]);

    // ❗ DIR PERBAIKAN – pakai "feedbacks" (pakai S)
    $target_path = "../uploads/feedbacks/" . $filename;

    move_uploaded_file($_FILES["attachment"]["tmp_name"], $target_path);
}

$query = $conn->prepare("
    INSERT INTO document_feedbacks (document_id, comment, attachment)
    VALUES (?, ?, ?)
");

$query->bind_param("iss", $document_id, $comment, $filename);
$query->execute();

echo json_encode(["success" => true]);
