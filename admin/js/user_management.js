const BASE_URL = "http://localhost/SIGMA/admin/php/";

// ===================== 🔹 Load Data User
function loadUsers() {
  fetch(BASE_URL + "get_users.php")
    .then((res) => res.json())
    .then((data) => {
      const tbody = document.getElementById("userTable");
      tbody.innerHTML = "";
      data.forEach((u) => {
        tbody.innerHTML += `
          <tr>
            <td>${u.name}</td>
            <td>${u.email}</td>
            <td>${u.user_type}</td>
            <td><span class="status active">Active</span></td>
            <td>${u.nim_nik || "-"}</td>
            <td>${u.phone_number || "-"}</td>
            <td>
              <span onclick="openEdit(${u.id}, '${u.name}', '${u.email}', '${u.user_type}', '${u.nim_nik || ""}', '${u.phone_number || ""}')">✏️</span>
              <span onclick="openDelete(${u.id}, '${u.name}')">🗑️</span>
            </td>
          </tr>
        `;
      });
    })
    .catch((err) => console.error("Error:", err));
}
loadUsers();

// ===================== 🔹 Tambah User
document.getElementById("addUserForm").addEventListener("submit", (e) => {
  e.preventDefault();

  const userData = {
    name: document.getElementById("addName").value,
    email: document.getElementById("addEmail").value,
    role: document.getElementById("addRole").value,
    nim_nik: document.getElementById("addNimNik").value,
    phone_number: document.getElementById("addPhone").value,
  };

  fetch(BASE_URL + "add_user.php", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(userData),
  })
    .then((res) => res.json())
    .then((data) => {
      alert(data.message);
      closeAdd();
      loadUsers();
    })
    .catch(() => alert("Terjadi kesalahan saat menambah user!"));
});

// ===================== 🔹 Edit User
function openEdit(id, name, email, role, nim, phone) {
  document.getElementById("editModal").style.display = "flex";
  document.getElementById("editId").value = id;
  document.getElementById("editName").value = name;
  document.getElementById("editEmail").value = email;
  document.getElementById("editRole").value = role;
  document.getElementById("editNimNik").value = nim;
  document.getElementById("editPhone").value = phone;
}

document.getElementById("editUserForm").addEventListener("submit", (e) => {
  e.preventDefault();

  const updatedUser = {
    id: document.getElementById("editId").value,
    name: document.getElementById("editName").value,
    email: document.getElementById("editEmail").value,
    role: document.getElementById("editRole").value,
    nim_nik: document.getElementById("editNimNik").value,
    phone_number: document.getElementById("editPhone").value,
  };

  fetch(BASE_URL + "update_user.php", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(updatedUser),
  })
    .then((res) => res.json())
    .then((data) => {
      alert(data.message);
      closeEdit();
      loadUsers();
    })
    .catch(() => alert("Terjadi kesalahan saat memperbarui user!"));
});

// ===================== 🔹 Hapus User
let deleteId = null;

function openDelete(id, name) {
  deleteId = id;
  document.getElementById("deleteUserName").textContent = name;
  document.getElementById("deleteModal").style.display = "flex";
}

function confirmDelete() {
  if (!deleteId) return;

  fetch(BASE_URL + "delete_user.php", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ id: deleteId }),
  })
    .then((res) => res.json())
    .then((data) => {
      alert(data.message);
      closeDelete();
      loadUsers();
    })
    .catch(() => alert("Terjadi kesalahan saat menghapus user!"));
}
