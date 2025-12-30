<?php
ob_start(); // MULAI output buffering

header("Content-Type: application/json");

require_once "guard.php";
require_once "config.php";

$title = $_POST['title'] ?? '';
$start = $_POST['start_date'] ?? '';
$end = $_POST['end_date'] ?? '';
$desc = $_POST['description'] ?? '';
$link = null;

// Upload File
if (!empty($_FILES["file"]["name"])) {
    $filename = time() . "_" . basename($_FILES["file"]["name"]);
    move_uploaded_file($_FILES["file"]["tmp_name"], "../uploads/" . $filename);
    $link = $filename;
}

$sql = "INSERT INTO announcements (title, start_date, end_date, description, link)
        VALUES ('$title', '$start', '$end', '$desc', '$link')";

$response = [
    "success" => $conn->query($sql),
    "message" => $conn->error
];

// BUANG semua output sampah (warning, spasi, bom, notice)
ob_end_clean();

// KIRIM JSON BERSIH
echo json_encode($response);
exit;
