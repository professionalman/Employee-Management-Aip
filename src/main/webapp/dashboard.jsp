<%@ page session="true" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
    response.setDateHeader("Expires", 0); // Proxies.

    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>



<%@ page import="java.sql.*" %>
<%@ include file="dbconnection.jsp" %>
<%
    String userSession = (String) session.getAttribute("user");
    String adminName = "";
    int totalEmployees = 0;
    int todaysPresent = 0;

    if (userSession == null) {
        response.sendRedirect("login.jsp");
    } else {
        try {
            PreparedStatement pst = conn.prepareStatement("SELECT name FROM users WHERE email = ?");
            pst.setString(1, userSession);
            ResultSet rs = pst.executeQuery();
            if (rs.next()) {
                adminName = rs.getString("name");
            }

            Statement empStmt = conn.createStatement();
            ResultSet empRs = empStmt.executeQuery("SELECT COUNT(*) AS total FROM employees");
            if (empRs.next()) {
                totalEmployees = empRs.getInt("total");
            }

            PreparedStatement presentStmt = conn.prepareStatement(
                "SELECT COUNT(*) AS present_count FROM attendance WHERE att_date = CURDATE() AND status = 'Present'"
            );
            ResultSet presentRs = presentStmt.executeQuery();
            if (presentRs.next()) {
                todaysPresent = presentRs.getInt("present_count");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    String[] labels = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
    int[] present = new int[6];
    int[] absent = new int[6];

    try {
        PreparedStatement chartStmt = conn.prepareStatement(
            "SELECT att_date, " +
            "SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) AS present_count, " +
            "SUM(CASE WHEN status = 'Absent' THEN 1 ELSE 0 END) AS absent_count " +
            "FROM attendance " +
            "WHERE att_date >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) " +
            "GROUP BY att_date ORDER BY att_date"
        );

        ResultSet chartRs = chartStmt.executeQuery();
        int index = 0;
        while (chartRs.next() && index < 6) {
            present[index] = chartRs.getInt("present_count");
            absent[index] = chartRs.getInt("absent_count");
            index++;
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        .sidebar {
            width: 250px;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 56px; /* Adjusted for sticky navbar */
            background-color: #343a40;
            padding-top: 20px;
        }
        .sidebar a {
            color: #fff;
            display: block;
            padding: 12px 20px;
            text-decoration: none;
        }
        .sidebar a:hover {
            background-color: #495057;
        }
        .main-content {
            margin-left: 250px;
            margin-top: 70px; /* Space below navbar */
            padding: 30px;
            background-color: #f8f9fa;
        }
        .sidebar {
    top: 56px; /* Height of the fixed navbar */
}
.main-content {
    margin-top: 80px; /* Avoid overlap with fixed navbar */
}

    </style>
</head>
<body>

<<!-- Fixed Navbar -->
<nav class="navbar navbar-expand-lg navbar-light fixed-top" style="background-color: #e9ecef; box-shadow: 0 2px 4px rgba(0,0,0,0.1); z-index: 1030;">
  <div class="container-fluid">
    <a class="navbar-brand fw-bold text-dark" href="#">Employee Management System</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav"
      aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav ms-auto">
        <li class="nav-item">
          <a class="nav-link text-dark" href="dashboard.jsp">Dashboard</a>
        </li>
        <li class="nav-item">
          <a class="nav-link text-dark" href="manage_employee.jsp">Employees</a>
        </li>
        <li class="nav-item">
          <a class="nav-link text-dark" href="attendance.jsp">Attendance</a>
        </li>
        <li class="nav-item">
          <a class="nav-link text-dark" href="manage_salary.jsp">Salaries</a>
        </li>
<!--        <li class="nav-item">
          <a class="nav-link text-dark" href="export_salary_excel.jsp">Export Salary</a>
        </li>
        <li class="nav-item">
          <a class="nav-link text-dark" href="exportAttendanceExcel.jsp">Export Attendance</a>
        </li>-->
        <li class="nav-item">
          <a class="nav-link text-danger" href="logout.jsp">Logout</a>
        </li>
      </ul>
    </div>
  </div>
</nav>


<!-- Sidebar -->
<div class="sidebar " style="background-color: #e9ecef;">
    <!--<h5 class="text-white text-center mb-4">Admin Panel</h5>-->
    <a href="dashboard.jsp" class="text-dark">Dashboard</a>
    <a href="manage_employee.jsp" class="text-dark">Manage Employees</a>
    <a href="manage_salary.jsp" class="text-dark">Manage Salary</a>
    <a href="attendance.jsp" class="text-dark">Attendance</a>
    <a href="generate_salary_slip.jsp" class="text-dark">Salary Slip</a>
    <a href="#" class="text-dark">Settings</a>
    <a href="logout.jsp" class="text-danger">Logout</a>
</div>

<!-- Main Content -->
<div class="main-content">
    <div class="container">
        <!-- Admin Info -->
        <div class="mt-4 p-3 bg-light border rounded">
            <h3>Admin Profile</h3>
            <p><strong>Name:</strong> <%= adminName %></p>
            <p><strong>Email:</strong> <%= userSession %></p>
        </div>

        <!-- Dashboard Cards -->
        <div class="row mt-4">
            <div class="col-md-4">
                <div class="card text-white bg-info mb-3">
                    <div class="card-body">
                        <h5 class="card-title">Total Employees</h5>
                        <p class="card-text"><%= totalEmployees %></p>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card text-white bg-success mb-3">
                    <div class="card-body">
                        <h5 class="card-title">Today's Attendance</h5>
                        <p class="card-text"><%= todaysPresent %> Present</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Chart -->
        <div class="card mt-4">
            <div class="card-header">
                Attendance Summary (Last 6 Days)
            </div>
            <div class="card-body">
                <canvas id="attendanceChart" height="100"></canvas>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="mt-4">
            <h5>Quick Actions</h5>
            <div class="d-flex flex-wrap gap-2">
                <a href="manage_employee.jsp" class="btn btn-outline-primary mt-3">Add Employee</a>
                <a href="attendance.jsp" class="btn btn-outline-primary mt-3">Mark Attendance</a>
                <a href="manage_salary.jsp" class="btn btn-outline-primary mt-3">View Salary</a>
                <a href="export_salary_excel.jsp" class="btn btn-outline-danger mt-3">Export Salary</a>
                <a href="exportAttendanceExcel.jsp" class="btn btn-outline-danger mt-3">Export Attendance</a>
            </div>
        </div>

        <!-- Recent Activities -->
        <div class="mt-5">
            <h5>Recent Attendance Activity</h5>
            <table class="table table-bordered bg-white">
                <thead>
                    <tr>
                        <th>Employee</th>
                        <th>Date</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        PreparedStatement logStmt = conn.prepareStatement(
                            "SELECT e.name, a.att_date, a.status FROM attendance a JOIN employees e ON a.employee_id = e.id ORDER BY a.att_date DESC LIMIT 5"
                        );
                        ResultSet logRs = logStmt.executeQuery();
                        while (logRs.next()) {
                    %>
                    <tr>
                        <td><%= logRs.getString("name") %></td>
                        <td><%= logRs.getString("att_date") %></td>
                        <td><%= logRs.getString("status") %></td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>

        <!-- Notifications -->
        <div class="mt-4">
            <h5>Notifications</h5>
            <div class="alert alert-info">Attendance report needs verification for today.</div>
            <div class="alert alert-warning">3 salary records need approval.</div>
        </div>
    </div>
</div>

<!-- Bootstrap & Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    const ctx = document.getElementById('attendanceChart').getContext('2d');
    const attendanceChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: <%= java.util.Arrays.toString(labels).replace("[", "['").replace("]", "']").replace(", ", "', '") %>,
            datasets: [{
                label: 'Present',
                data: <%= java.util.Arrays.toString(present) %>,
                backgroundColor: 'rgba(40, 167, 69, 0.7)'
            }, {
                label: 'Absent',
                data: <%= java.util.Arrays.toString(absent) %>,
                backgroundColor: 'rgba(220, 53, 69, 0.7)'
            }]
        },
        options: {
            responsive: true,
            scales: {
                y: { beginAtZero: true }
            }
        }
    });
</script>
</body>
</html>
