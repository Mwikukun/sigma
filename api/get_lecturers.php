<?php
include 'cors.php';
require_once("config_api.php");

try {
    // ✅ FIX UTAMA: Hitung hanya is_approved = 1
    $query = "
        SELECT 
            lec.employee_number,
            lec.user_id AS lecturer_user_id,
            u.name AS lecturer_name,
            lec.expertise,
            sp.title AS study_program,
            m.title AS major,
            (
                SELECT COUNT(*) 
                FROM guidances g 
                WHERE g.lecturer_id = lec.employee_number
                AND g.is_approved = 1
            ) AS current_students,
            10 AS max_students
        FROM lecturers lec
        JOIN users u ON lec.user_id = u.id
        JOIN study_programs sp ON lec.study_program_id = sp.id
        JOIN majors m ON sp.major_id = m.id
        ORDER BY u.name ASC
    ";

    $result = mysqli_query($conn, $query);

    if (!$result) {
        throw new Exception("Query gagal: " . mysqli_error($conn));
    }

    $lecturers = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $lecturers[] = [
            "lecturer_name" => $row["lecturer_name"],
            "employee_number" => $row["employee_number"],
            "lecturer_id" => $row["lecturer_user_id"],
            "expertise" => $row["expertise"],
            "study_program" => $row["study_program"],
            "major" => $row["major"],
            "current_students" => (int)$row["current_students"],
            "max_students" => (int)$row["max_students"],
            "is_full" => ((int)$row["current_students"] >= (int)$row["max_students"])
        ];
    }

    echo json_encode([
        "success" => true,
        "message" => "Daftar dosen berhasil diambil.",
        "data" => $lecturers
    ]);

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
}
?>
