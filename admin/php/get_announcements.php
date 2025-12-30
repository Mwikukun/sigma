<?php
ob_start(); // mulai buffer untuk cegah output sampah

header("Content-Type: application/json");

require_once "guard.php";
require_once "config.php";

$sql = "SELECT * FROM announcements ORDER BY id DESC";
$result = $conn->query($sql);

$data = [];

while ($row = $result->fetch_assoc()) {
    $row["file_url"] = $row["link"] ? "uploads/" . $row["link"] : null;
    $data[] = $row;
}

$response = [
    "success" => true,
    "announcements" => $data
];

ob_end_clean(); // bersihkan semua output sampah
echo json_encode($response);
exit;
