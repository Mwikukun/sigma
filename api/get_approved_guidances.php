<?php
include 'cors.php';
require_once("config_api.php");

try {
    $lecturer_id = $_POST['lecturer_id'] ?? null;

    if (!$lecturer_id) {
        echo json_encode(["success" => false, "message" => "lecturer_id tidak dikirim"]);
        exit;
    }

    $query = "
        SELECT 
            g.id AS guidance_id,
            g.student_id,
            g.is_approved,
            s.student_number,
            s.thesis AS thesis_title,
            u.name AS student_name,

            (
                SELECT d.status
                FROM documents d
                WHERE d.student_id = s.student_number
                ORDER BY d.id DESC
                LIMIT 1
            ) AS last_document_status

        FROM guidances g
        JOIN students s ON g.student_id = s.student_number
        JOIN users u ON s.user_id = u.id
        WHERE g.lecturer_id = ?
        AND g.is_approved = 1
        ORDER BY g.id DESC
    ";

    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $lecturer_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $data = [];
    while ($row = $result->fetch_assoc()) {
        $row['is_approved'] = intval($row['is_approved']);

        // kalau belum pernah upload dokumen
        if ($row['last_document_status'] === null) {
            $row['last_document_status'] = "pending";
        }

        $data[] = $row;
    }

    echo json_encode([
        "success" => true,
        "message" => "Data ditemukan",
        "data" => $data
    ]);

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
