<?php
include "config_api.php";

if (!isset($_GET['file'])) {
    echo "File tidak ditemukan.";
    exit;
}

$filename = basename($_GET['file']);
$filepath = "../uploads/documents/" . $filename;

if (!file_exists($filepath)) {
    echo "File tidak ditemukan.";
    exit;
}

// paksa download
header("Content-Description: File Transfer");
header("Content-Type: application/octet-stream");
header("Content-Disposition: attachment; filename=\"$filename\"");
header("Content-Length: " . filesize($filepath));

readfile($filepath);
exit;
?>
