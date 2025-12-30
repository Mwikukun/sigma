<?php
include 'cors.php';
include 'config_api.php';

$document_id = $_POST['document_id'];
$comment = $_POST['comment'];
$filename = null;

// Ambil student_id & lecturer_id
$doc = $conn->query("
    SELECT d.student_id, g.lecturer_id 
    FROM documents d 
    LEFT JOIN guidances g ON g.student_id = d.student_id AND g.is_approved = 1
    WHERE d.id = '$document_id'
")->fetch_assoc();

$student_id = $doc['student_id'];
$lecturer_id = $doc['lecturer_id'];

// Upload file feedback
if (!empty($_FILES['attachment']['name'])) {
    $filename = time() . "_" . basename($_FILES["attachment"]["name"]);
    $target_path = "../uploads/feedbacks/" . $filename;
    move_uploaded_file($_FILES["attachment"]["tmp_name"], $target_path);
}

// Insert feedback
$query = $conn->prepare("
    INSERT INTO document_feedbacks (document_id, comment, attachment)
    VALUES (?, ?, ?)
");
$query->bind_param("iss", $document_id, $comment, $filename);
$query->execute();

// =========================
// 🔔 NOTIFIKASI MAHASISWA
// =========================
$n_title = "Feedback Dokumen";
$n_desc  = "Dosen memberikan komentar pada dokumen Anda.";

$notif = $conn->prepare("
    INSERT INTO notifications (student_id, title, description)
    VALUES (?, ?, ?)
");
$notif->bind_param("iss", $student_id, $n_title, $n_desc);
$notif->execute();

echo json_encode(["success" => true]);
?>
