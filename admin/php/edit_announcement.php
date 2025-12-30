<?php
ob_start(); // mulai buffer agar output sampah tidak bocor

header("Content-Type: application/json");

require_once "guard.php";
require_once "config.php";

$id   = $_POST['id'] ?? 0;
$title = $_POST['title'] ?? '';
$start = $_POST['start_date'] ?? '';
$end   = $_POST['end_date'] ?? '';
$desc  = $_POST['description'] ?? '';
$link  = $_POST['old_link'] ?? null;

// Jika upload file baru
if (!empty($_FILES["file"]["name"])) {
    $filename = time() . "_" . basename($_FILES["file"]["name"]);
    $path = "../uploads/" . $filename;
    move_uploaded_file($_FILES["file"]["tmp_name"], $path);
    $link = $filename;
}

$sql = "UPDATE announcements SET 
            title='$title',
            start_date='$start',
            end_date='$end',
            description='$desc',
            link='$link'
        WHERE id=$id";

$response = [
    "success" => $conn->query($sql),
    "message" => $conn->error
];

ob_end_clean(); // buang semua output sampah (warning, spasi, bom)
echo json_encode($response);
exit;
