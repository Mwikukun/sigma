<?php
include 'cors.php';
include "config_api.php";

/* =====================================
   VALIDASI AWAL
===================================== */
$student_id = $_POST['student_id'] ?? null;
$chapter    = $_POST['chapter'] ?? null;
$title      = $_POST['title'] ?? '';
$note       = $_POST['note'] ?? '';

if (!$student_id || !$chapter || !isset($_FILES['file'])) {
    echo json_encode(["success"=>false,"message"=>"missing required data"]);
    exit;
}

/* =====================================
   FUNCTION INSERT ACTIVITY
===================================== */
function insertActivity($conn, $lecturer_id, $student_id, $type, $desc) {
    $stmt = $conn->prepare("
        INSERT INTO activity_logs
        (lecturer_id, student_id, activity_type, description)
        VALUES (?, ?, ?, ?)
    ");
    $stmt->bind_param("iiss", $lecturer_id, $student_id, $type, $desc);
    $stmt->execute();
}

/* =====================================
   HITUNG VERSI REVISI
===================================== */
$qv = $conn->prepare("
    SELECT COUNT(*) AS v 
    FROM documents 
    WHERE student_id = ? AND chapter = ?
");
$qv->bind_param("is", $student_id, $chapter);
$qv->execute();
$version = $qv->get_result()->fetch_assoc()['v'] + 1;

/* =====================================
   UPLOAD FILE
===================================== */
$dir = "uploads/documents/";
if (!is_dir($dir)) mkdir($dir, 0777, true);

$ext = pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION);
$filename = time() . "_{$student_id}_{$chapter}_v{$version}." . $ext;

move_uploaded_file($_FILES['file']['tmp_name'], $dir . $filename);

/* =====================================
   INSERT DOKUMEN REVISI
===================================== */
$stmt = $conn->prepare("
    INSERT INTO documents 
    (student_id, attachment, title, chapter, note, status)
    VALUES (?, ?, ?, ?, ?, 'pending')
");
$stmt->bind_param("issss", $student_id, $filename, $title, $chapter, $note);
$stmt->execute();

/* =====================================
   AMBIL DOSEN PEMBIMBING
===================================== */
$get = $conn->query("
    SELECT lecturer_id 
    FROM guidances 
    WHERE student_id='$student_id' AND is_approved=1
");

if ($get->num_rows > 0) {

    $lecturer_id = $get->fetch_assoc()['lecturer_id'];

    /* =================================
       AMBIL NAMA MAHASISWA
    ================================= */
    $sn = $conn->query("
        SELECT u.name 
        FROM students s 
        JOIN users u ON s.user_id = u.id
        WHERE s.student_number = '$student_id'
    ");
    $student_name = $sn->fetch_assoc()['name'] ?? "Mahasiswa";

    /* =================================
       🔔 NOTIFIKASI DOSEN
    ================================= */
    $n_title = "Dokumen Revisi";
    $n_desc  = "$student_name mengupload revisi dokumen $chapter.";

    $notif = $conn->prepare("
        INSERT INTO notifications 
        (student_id, lecturer_id, title, description) 
        VALUES (?, ?, ?, ?)
    ");
    $notif->bind_param("iiss", $student_id, $lecturer_id, $n_title, $n_desc);
    $notif->execute();

    /* =================================
       🧾 ACTIVITY LOG
    ================================= */
    insertActivity(
        $conn,
        $lecturer_id,
        $student_id,
        "document_revision",
        "$student_name mengupload revisi dokumen $chapter (v$version)"
    );
}

/* =====================================
   RESPONSE
===================================== */
echo json_encode([
    "success"  => true,
    "version"  => $version,
    "filename" => $filename
]);

$conn->close();
?>
