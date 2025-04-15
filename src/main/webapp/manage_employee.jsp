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
    String action = request.getParameter("action");
    if ("add".equals(action)) {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String department = request.getParameter("department");
        PreparedStatement pst = conn.prepareStatement("INSERT INTO employees(name, email, department) VALUES (?, ?, ?)");
        pst.setString(1, name);
        pst.setString(2, email);
        pst.setString(3, department);
        pst.executeUpdate();
        response.sendRedirect("manage_employee.jsp");
    } else if ("update".equals(action)) {
        int id = Integer.parseInt(request.getParameter("id"));
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String department = request.getParameter("department");
        PreparedStatement pst = conn.prepareStatement("UPDATE employees SET name=?, email=?, department=? WHERE id=?");
        pst.setString(1, name);
        pst.setString(2, email);
        pst.setString(3, department);
        pst.setInt(4, id);
        pst.executeUpdate();
        response.sendRedirect("manage_employee.jsp");
    } else if ("delete".equals(action)) {
        int id = Integer.parseInt(request.getParameter("id"));
        PreparedStatement pst = conn.prepareStatement("DELETE FROM employees WHERE id=?");
        pst.setInt(1, id);
        pst.executeUpdate();
        response.sendRedirect("manage_employee.jsp");
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Employees</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            padding-top: 70px;
        }
    </style>
</head>
<body class="bg-light">

<!-- Navbar -->
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
          <a class="nav-link text-dark" href="manage_salary.jsp">Salary</a>
        </li>
        <li class="nav-item">
          <a class="nav-link text-dark" href="logout.jsp">Logout</a>
        </li>
      </ul>
    </div>
  </div>
</nav>

<div class="container mt-5">
    <h3 class="mb-4">Manage Employees</h3>

    <!-- Add Employee Form -->
    <form action="manage_employee.jsp?action=add" method="post" class="row g-3 mb-4">
        <div class="col-md-3">
            <input type="text" name="name" class="form-control" placeholder="Name" required>
        </div>
        <div class="col-md-3">
            <input type="email" name="email" class="form-control" placeholder="Email" required>
        </div>
        <div class="col-md-3">
            <input type="text" name="department" class="form-control" placeholder="Department" required>
        </div>
        <div class="col-md-3">
            <button class="btn btn-success w-100">Add Employee</button>
        </div>
    </form>

    <!-- Employee Table -->
    <table class="table table-bordered">
        <thead class="table-dark">
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Department</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <%
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT id, name, email, department FROM employees");
                while (rs.next()) {
            %>
            <tr>
                <form action="manage_employee.jsp?action=update&id=<%= rs.getInt("id") %>" method="post">
                    <td><%= rs.getInt("id") %></td>
                    <td><input type="text" name="name" value="<%= rs.getString("name") %>" class="form-control" required></td>
                    <td><input type="email" name="email" value="<%= rs.getString("email") %>" class="form-control" required></td>
                    <td><input type="text" name="department" value="<%= rs.getString("department") %>" class="form-control" required></td>
                    <td>
                        <button class="btn btn-sm btn-primary">Update</button>
                        <a href="manage_employee.jsp?action=delete&id=<%= rs.getInt("id") %>" class="btn btn-sm btn-danger"
                           onclick="return confirm('Are you sure you want to delete this employee?');">Delete</a>
                    </td>
                </form>
            </tr>
            <% } %>
        </tbody>
    </table>

    <a href="dashboard.jsp" class="btn btn-secondary mt-3">Back to Dashboard</a>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
