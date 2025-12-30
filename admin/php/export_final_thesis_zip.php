<?php
ob_start(); // ⬅️ WAJIB
header("Content-Type: application/json");

require_once "guard.php";
require_once "config.php";

$zip = new ZipArchive();
$zipName = "final_thesis_" . date("Ymd_His") . ".zip";
$zipPath = sys_get_temp_dir() . "/" . $zipName;

if ($zip->open($zipPath, ZipArchive::CREATE | ZipArchive::OVERWRITE) !== TRUE) {
    ob_end_clean();
    die("Gagal membuat ZIP");
}

$q = mysqli_query($conn, "
    SELECT ft.file, u.name 
    FROM final_thesises ft
    JOIN students s ON ft.student_id = s.student_number
    JOIN users u ON s.user_id = u.id
");

$baseDir = realpath(__DIR__ . "/../../uploads/documents");
$fileCount = 0;

while ($row = mysqli_fetch_assoc($q)) {
    $filePath = $baseDir . DIRECTORY_SEPARATOR . $row['file'];

    if (is_file($filePath)) {
        $zip->addFile(
            $filePath,
            $row['name'] . "/" . $row['file']
        );
        $fileCount++;
    }
}

$zip->close();

/* ❌ kalau tidak ada file → STOP */
if ($fileCount === 0) {
    ob_end_clean();
    unlink($zipPath);
    die("ZIP kosong. Tidak ada file final thesis yang ditemukan.");
}

/* 🔥 BERSIHKAN OUTPUT */
ob_end_clean();

/* FORCE DOWNLOAD */
header("Content-Type: application/zip");
header("Content-Disposition: attachment; filename=\"$zipName\"");
header("Content-Length: " . filesize($zipPath));
header("Pragma: public");
header("Cache-Control: must-revalidate");

readfile($zipPath);
unlink($zipPath);
exit;
