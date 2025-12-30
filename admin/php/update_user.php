<?php

header("Content-Type: application/json");

require_once "guard.php";
require_once "config.php";

$data = json_decode(file_get_contents("php://input"), true);

$id = $data["id"] ?? 0;
$name = $data["name"] ?? "";
$email = $data["email"] ?? "";
$role = $data["role"] ?? "";
$nim_nik = $data["nim_nik"] ?? "";
$phone_number = $data["phone_number"] ?? "";
$study_program_id = $data["study_program_id"] ?? 1;
$expertise = $data["expertise"] ?? null;

// 1️⃣ Update tabel users
$query = "UPDATE users 
          SET name = ?, email = ?, user_type = ?, phone_number = ?
          WHERE id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("ssssi", $name, $email, $role, $phone_number, $id);
$ok = $stmt->execute();

if (!$ok) {
    echo json_encode(["status" => "error", "message" => "Gagal memperbarui data user: " . $stmt->error]);
    exit;
}

// 2️⃣ Cek role dan update tabel sesuai
if ($role === "student") {
    $check = $conn->prepare("SELECT student_number FROM students WHERE user_id = ?");
    $check->bind_param("i", $id);
    $check->execute();
    $result = $check->get_result();

    if ($result->num_rows > 0) {
        $update = $conn->prepare("UPDATE students SET student_number = ? WHERE user_id = ?");
        $update->bind_param("si", $nim_nik, $id);
        $update->execute();
        $update->close();
    } else {
        $insert = $conn->prepare("INSERT INTO students (student_number, user_id) VALUES (?, ?)");
        $insert->bind_param("si", $nim_nik, $id);
        $insert->execute();
        $insert->close();
    }
    $check->close();

} elseif ($role === "lecturer") {
    $check = $conn->prepare("SELECT employee_number FROM lecturers WHERE user_id = ?");
    $check->bind_param("i", $id);
    $check->execute();
    $result = $check->get_result();

    if ($result->num_rows > 0) {
        // Sudah ada, update semua field
        $update = $conn->prepare("UPDATE lecturers SET employee_number = ?, study_program_id = ?, expertise = ? WHERE user_id = ?");
        $update->bind_param("sisi", $nim_nik, $study_program_id, $expertise, $id);
        $update->execute();
        $update->close();
    } else {
        // Belum ada, insert baru
        $insert = $conn->prepare("INSERT INTO lecturers (employee_number, user_id, study_program_id, expertise) VALUES (?, ?, ?, ?)");
        $insert->bind_param("siis", $nim_nik, $id, $study_program_id, $expertise);
        $insert->execute();
        $insert->close();
    }
    $check->close();
}

// 3️⃣ Balasan JSON ke frontend
echo json_encode(["status" => "success", "message" => "Data user berhasil diperbarui!"]);

$stmt->close();
$conn->close();
?>
