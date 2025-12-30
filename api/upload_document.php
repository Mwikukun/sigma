<?php
include 'cors.php';
include 'config_api.php';

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

/* =====================================
   HELPER RESPONSE
===================================== */
function response($success, $message) {
    echo json_encode([
        "success" => $success,
        "message" => $message
    ]);
    exit;
}

/* =====================================
   VALIDASI AWAL
===================================== */
if (empty($_POST['student_id'])) {
    response(false, "student_id missing");
}

if (!isset($_FILES['file'])) {
    response(false, "File not uploaded");
}

$student_id = $_POST['student_id'];
$title      = $_POST['title']   ?? null;
$chapter    = $_POST['chapter'] ?? null;
$note       = $_POST['note']    ?? null;
$is_final   = ($_POST['is_final'] ?? "false") === "true";

/* =====================================
   UPLOAD FILE
===================================== */
$uploadDir = "../uploads/documents/";
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

$filename = time() . "_" . basename($_FILES['file']['name']);
$target   = $uploadDir . $filename;

if (!move_uploaded_file($_FILES['file']['tmp_name'], $target)) {
    response(false, "Failed saving file");
}

/* =====================================
   AMBIL DOSEN PEMBIMBING (TERAKHIR)
===================================== */
$lecturer_id = null;
$stmt = $conn->prepare("
    SELECT lecturer_id
    FROM guidances
    WHERE student_id = ?
      AND is_approved IN (1,2,3)
    ORDER BY created_at DESC
    LIMIT 1
");
$stmt->bind_param("s", $student_id);
$stmt->execute();
$res = $stmt->get_result();
if ($res->num_rows > 0) {
    $lecturer_id = $res->fetch_assoc()['lecturer_id'];
}

/* =====================================
   AMBIL NAMA MAHASISWA
===================================== */
$student_name = "Mahasiswa";
$stmt = $conn->prepare("
    SELECT u.name
    FROM students s
    JOIN users u ON s.user_id = u.id
    WHERE s.student_number = ?
");
$stmt->bind_param("s", $student_id);
$stmt->execute();
$res = $stmt->get_result();
if ($res->num_rows > 0) {
    $student_name = $res->fetch_assoc()['name'];
}

/* =====================================
   INSERT ACTIVITY LOG (FIXED)
===================================== */
function insertActivity($conn, $lecturer_id, $student_id, $type, $desc) {
    if ($lecturer_id === null) return;

    $stmt = $conn->prepare("
        INSERT INTO activity_logs
        (lecturer_id, student_id, activity_type, description)
        VALUES (?, ?, ?, ?)
    ");
    $stmt->bind_param("ssss", $lecturer_id, $student_id, $type, $desc);
    $stmt->execute();
}

/* =========================================================
   🔥 FINAL THESIS
========================================================= */
if ($is_final) {

    $stmt = $conn->prepare("
        SELECT id FROM final_thesises WHERE student_id = ?
    ");
    $stmt->bind_param("s", $student_id);
    $stmt->execute();
    $res = $stmt->get_result();

    if ($res->num_rows > 0) {
        $stmt = $conn->prepare("
            UPDATE final_thesises
            SET file = ?, created_at = NOW()
            WHERE student_id = ?
        ");
        $stmt->bind_param("ss", $filename, $student_id);
    } else {
        $stmt = $conn->prepare("
            INSERT INTO final_thesises (student_id, file)
            VALUES (?, ?)
        ");
        $stmt->bind_param("ss", $student_id, $filename);
    }
    $stmt->execute();

    if ($lecturer_id !== null) {
        $stmt = $conn->prepare("
            INSERT INTO notifications
            (student_id, lecturer_id, title, description)
            VALUES (?, ?, ?, ?)
        ");
        $titleN = "Final Thesis";
        $descN  = "$student_name mengupload FINAL Tugas Akhir.";
        $stmt->bind_param("ssss", $student_id, $lecturer_id, $titleN, $descN);
        $stmt->execute();
    }

    insertActivity(
        $conn,
        $lecturer_id,
        $student_id,
        "final_thesis",
        "$student_name mengupload FINAL Tugas Akhir"
    );

    response(true, "Final thesis uploaded successfully");
}

/* =========================================================
   📄 DOKUMEN BIASA
========================================================= */
$stmt = $conn->prepare("
    INSERT INTO documents
    (student_id, attachment, title, chapter, note, status)
    VALUES (?, ?, ?, ?, ?, 'pending')
");
$stmt->bind_param("sssss", $student_id, $filename, $title, $chapter, $note);
$stmt->execute();

if ($lecturer_id !== null) {
    $stmt = $conn->prepare("
        INSERT INTO notifications
        (student_id, lecturer_id, title, description)
        VALUES (?, ?, ?, ?)
    ");
    $titleN = "Dokumen Baru";
    $descN  = "$student_name mengupload dokumen $chapter.";
    $stmt->bind_param("ssss", $student_id, $lecturer_id, $titleN, $descN);
    $stmt->execute();
}

insertActivity(
    $conn,
    $lecturer_id,
    $student_id,
    "document_upload",
    "$student_name mengupload dokumen $chapter"
);

response(true, "File uploaded successfully");
