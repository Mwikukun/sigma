<?php
include 'cors.php';
include 'config_api.php';

$student_id = $_POST['student_id'] ?? '';

if (empty($student_id)) {
    echo json_encode([
        "success" => false,
        "message" => "Student ID required"
    ]);
    exit;
}

// Ambil semua dokumen mahasiswa
$q = $conn->prepare("
    SELECT id, attachment, title, chapter, note, status 
    FROM documents 
    WHERE student_id = ?
    ORDER BY id DESC
");
$q->bind_param("s", $student_id);
$q->execute();
$res = $q->get_result();

$data = [];
while ($doc = $res->fetch_assoc()) {

    $document_id = $doc['id'];

    // 🔥 Ambil semua feedback untuk dokumen ini
    $feedback_query = $conn->prepare("
        SELECT 
            df.comment,
            df.attachment,
            CONCAT('http://127.0.0.1/SIGMA/uploads/feedbacks/', df.attachment) AS attachment_url,
            u.name AS lecturer_name
        FROM document_feedbacks df
        LEFT JOIN documents d ON d.id = df.document_id
        LEFT JOIN guidances g ON g.student_id = d.student_id
        LEFT JOIN lecturers l ON l.employee_number = g.lecturer_id
        LEFT JOIN users u ON u.id = l.user_id
        WHERE df.document_id = ?
        ORDER BY df.id DESC
    ");

    $feedback_query->bind_param("i", $document_id);
    $feedback_query->execute();
    $feedback_res = $feedback_query->get_result();

    $feedbacks = [];
    while ($fb = $feedback_res->fetch_assoc()) {
        $feedbacks[] = [
            "lecturer_name" => $fb["lecturer_name"] ?? "Dosen",
            "comment"       => $fb["comment"] ?? "",
            "attachment"    => $fb["attachment"] ?? "",
            "attachment_url" => $fb["attachment_url"] ?? null
        ];
    }

    // 🔥 Tambahkan feedbacks ke dokumen
    $doc["feedbacks"] = $feedbacks;

    // 🔥 Tambahkan URL dokumen juga
    $doc["attachment_url"] = "http://127.0.0.1/SIGMA/uploads/documents/" . $doc["attachment"];

    $data[] = $doc;
}

echo json_encode([
    "success" => true,
    "data" => $data
]);
?>
