<?php
include "config.php";
header("Content-Type: application/json");

$data = json_decode(file_get_contents("php://input"), true);

$name = $data["name"] ?? "";
$role = $data["role"] ?? "";
$email = $data["email"] ?? "";
$nim_nik = $data["nim_nik"] ?? "";
$phone = $data["phone_number"] ?? "";
$study_program_id = $data["study_program_id"] ?? 1; // default sementara
$expertise = $data["expertise"] ?? NULL; // bisa kosong dulu
$username = strtolower(str_replace(" ", "", $name)); // auto username dari nama
$password = "123456"; // default password

if (empty($name) || empty($email) || empty($role)) {
    echo json_encode([
        "status" => "error",
        "message" => "Name, Role, dan Email wajib diisi."
    ]);
    exit;
}

// ======================
// Insert ke tabel users
// ======================
$stmt = $conn->prepare("
    INSERT INTO users (name, user_type, phone_number, email, username, password)
    VALUES (?, ?, ?, ?, ?, ?)
");
$stmt->bind_param("ssssss", $name, $role, $phone, $email, $username, $password);

if ($stmt->execute()) {
    $user_id = $conn->insert_id;

    // ====================================
    // Masukkan ke tabel students / lecturers
    // ====================================
    if ($role === "student") {
        // nim boleh kosong
        if (empty($nim_nik)) $nim_nik = NULL;
        $stmt2 = $conn->prepare("
            INSERT INTO students (student_number, user_id)
            VALUES (?, ?)
        ");
        $stmt2->bind_param("si", $nim_nik, $user_id);
        $stmt2->execute();
        $stmt2->close();

    } elseif ($role === "lecturer") {
        // nik boleh kosong
        if (empty($nim_nik)) $nim_nik = NULL;

        // pastikan study_program_id valid (ada di tabel)
        $check = $conn->prepare("SELECT id FROM study_programs WHERE id = ?");
        $check->bind_param("i", $study_program_id);
        $check->execute();
        $check->store_result();

        if ($check->num_rows === 0) {
            // kalau tidak ada, fallback ke 1
            $study_program_id = 1;
        }
        $check->close();

        // insert lecturer
        $stmt3 = $conn->prepare("
            INSERT INTO lecturers (employee_number, user_id, study_program_id, expertise)
            VALUES (?, ?, ?, ?)
        ");
        $stmt3->bind_param("siis", $nim_nik, $user_id, $study_program_id, $expertise);
        $stmt3->execute();
        $stmt3->close();
    }

    echo json_encode([
        "status" => "success",
        "message" => "User berhasil ditambahkan!"
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Gagal menambah user: " . $conn->error
    ]);
}

$stmt->close();
$conn->close();
?>
