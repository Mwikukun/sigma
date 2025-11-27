<?php
include 'cors.php';

require_once("config_api.php"); // koneksi database

// ✅ AUTO REJECT 7 HARI
$conn->query("
    UPDATE guidances
    SET is_approved = 2
    WHERE is_approved = 0
    AND TIMESTAMPDIFF(DAY, created_at, NOW()) >= 7
");

try {
    // ✅ Ambil student_id dari POST
    $student_id = $_POST['student_id'] ?? null;

    if (!$student_id) {
        echo json_encode([
            "success" => false,
            "message" => "Parameter student_id tidak ditemukan."
        ]);
        exit;
    }

    // ✅ Gunakan prepared statement untuk keamanan
    $query = "
        SELECT 
            g.id AS guidance_id,
            g.is_approved,
            g.student_id,
            g.lecturer_id,
            u.name AS lecturer_name,
            lec.employee_number AS lecturer_number
        FROM guidances g
        JOIN lecturers lec ON g.lecturer_id = lec.employee_number
        JOIN users u ON lec.user_id = u.id
        WHERE g.student_id = ?
        ORDER BY g.id DESC
        LIMIT 1
    ";

    $stmt = $conn->prepare($query);
    $stmt->bind_param("s", $student_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        // Belum pernah ajukan dosen pembimbing
        echo json_encode([
            "success" => true,
            "message" => "Mahasiswa belum pernah mengajukan pembimbing.",
            "data" => null
        ]);
        exit;
    }

    $row = $result->fetch_assoc();

    // ✅ Pastikan nilai null diganti default agar aman di Flutter
    $data = [
        "guidance_id" => $row['guidance_id'] ?? 0,
        "is_approved" => $row['is_approved'] ?? "0",
        "lecturer_id" => $row['lecturer_id'] ?? "",
        "lecturer_name" => $row['lecturer_name'] ?? "Tidak diketahui",
        "lecturer_number" => $row['lecturer_number'] ?? ""
    ];

    echo json_encode([
        "success" => true,
        "message" => "Status bimbingan ditemukan.",
        "data" => $data
    ]);

    $stmt->close();
    $conn->close();
} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Terjadi kesalahan: " . $e->getMessage()
    ]);
}
?>
