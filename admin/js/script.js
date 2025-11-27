// 🧠 Fungsi Login Admin
function login() {
  const username = document.getElementById("username").value.trim();
  const password = document.getElementById("password").value.trim();

  if (!username || !password) {
    alert("Username dan password wajib diisi!");
    return;
  }

  fetch("http://localhost/SIGMA/admin/php/login_process.php", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ username, password }),
  })
    .then((response) => {
      // cek apakah response valid JSON
      if (!response.ok) {
        throw new Error("HTTP error! Status: " + response.status);
      }
      return response.json();
    })
    .then((data) => {
      if (data.status === "success") {
        // Redirect ke dashboard
        window.location.href = "dashboard.html";
      } else {
        alert(data.message);
      }
    })
    .catch((error) => {
      console.error("Error:", error);
      alert("Terjadi kesalahan pada server!");
    });
}

// 👁️ Toggle Show/Hide Password
function togglePassword() {
  const passField = document.getElementById("password");
  const icon = document.querySelector(".toggle-password i");

  if (!passField || !icon) return; // pastikan elemen ada

  if (passField.type === "password") {
    passField.type = "text";
    icon.classList.replace("fa-eye", "fa-eye-slash");
  } else {
    passField.type = "password";
    icon.classList.replace("fa-eye-slash", "fa-eye");
  }
}

// 📊 Chart.js donut chart (hanya jalan di halaman yang punya elemen "docChart")
document.addEventListener("DOMContentLoaded", function () {
  const ctx = document.getElementById("docChart");
  if (ctx && typeof Chart !== "undefined") {
    new Chart(ctx, {
      type: "doughnut",
      data: {
        labels: ["Pending", "Approved", "Revised"],
        datasets: [
          {
            data: [3, 2, 5],
            backgroundColor: ["orange", "limegreen", "red"],
            borderWidth: 0,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        cutout: "70%",
        plugins: {
          legend: {
            display: false,
          },
        },
      },
    });
  }
});
