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




<%@ include file="dbconnection.jsp" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Employee Salary</title>
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
              <a class="nav-link text-dark" href="manage_employee.jsp">Employees</a>
            </li>
            <li class="nav-item">
              <a class="nav-link text-dark" href="manage_salary.jsp">Salaries</a>
            </li>
            <li class="nav-item">
              <a class="nav-link text-danger" href="logout.jsp">Logout</a>
            </li>
          </ul>
        </div>
      </div>
    </nav>

    <div class="container mt-5">
        <h2 class="mb-4">Employee Salary Management</h2>

        <!-- Add or Edit Salary Form -->
        <div class="card mb-4">
            <div class="card-header bg-primary text-white">
                <%
                    String editId = request.getParameter("editId");
                    if (editId != null) {
                        out.print("Edit Salary Record");
                    } else {
                        out.print("Add Salary Record");
                    }
                %>
            </div>
            <div class="card-body">
                <form method="post" action="manage_salary.jsp">
                    <%
                        int employeeId = 0;
                        double baseSalary = 0;
                        double bonus = 0;
                        String salaryMonth = "";
                        if (editId != null) {
                            try {
                                PreparedStatement editPst = conn.prepareStatement("SELECT * FROM employee_salary WHERE salary_id = ?");
                                editPst.setInt(1, Integer.parseInt(editId));
                                ResultSet editRs = editPst.executeQuery();
                                if (editRs.next()) {
                                    employeeId = editRs.getInt("employee_id");
                                    baseSalary = editRs.getDouble("base_salary");
                                    bonus = editRs.getDouble("bonus");
                                    salaryMonth = editRs.getString("salary_month");
                                }
                            } catch (Exception e) {
                                out.println("Edit Error: " + e.getMessage());
                            }
                    %>
                        <input type="hidden" name="salary_id" value="<%= editId %>">
                    <% } %>

                    <div class="row mb-3">
                        <div class="col-md-4">
                            <label class="form-label">Employee</label>
                            <select name="employee_id" class="form-control" required>
                                <%
                                    try {
                                        Statement stmt = conn.createStatement();
                                        ResultSet empRs = stmt.executeQuery("SELECT id, name FROM employees");
                                        while (empRs.next()) {
                                            int empId = empRs.getInt("id");
                                            String selected = (empId == employeeId) ? "selected" : "";
                                %>
                                    <option value="<%= empId %>" <%= selected %>><%= empRs.getString("name") %></option>
                                <%
                                        }
                                    } catch (Exception e) {
                                        out.println("Employee load error: " + e.getMessage());
                                    }
                                %>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Base Salary</label>
                            <input type="number" step="0.01" name="base_salary" value="<%= baseSalary %>" class="form-control" required>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Bonus</label>
                            <input type="number" step="0.01" name="bonus" value="<%= bonus %>" class="form-control" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Salary Month</label>
                            <input type="text" name="salary_month" value="<%= salaryMonth %>" class="form-control" required placeholder="e.g. April 2025">
                        </div>
                    </div>
                    <input type="submit" name="<%= (editId != null) ? "updateSalary" : "addSalary" %>" class="btn btn-success" value="<%= (editId != null) ? "Update Salary" : "Add Salary" %>">
                </form>
            </div>
        </div>

        <!-- Handle Add -->
        <%
            if (request.getParameter("addSalary") != null) {
                try {
                    int empId = Integer.parseInt(request.getParameter("employee_id"));
                    double base = Double.parseDouble(request.getParameter("base_salary"));
                    double bon = Double.parseDouble(request.getParameter("bonus"));
                    String month = request.getParameter("salary_month");

                    PreparedStatement pst = conn.prepareStatement("INSERT INTO employee_salary (employee_id, base_salary, bonus, salary_month) VALUES (?, ?, ?, ?)");
                    pst.setInt(1, empId);
                    pst.setDouble(2, base);
                    pst.setDouble(3, bon);
                    pst.setString(4, month);
                    pst.executeUpdate();
        %>
                    <div class="alert alert-success">Salary record added successfully!</div>
        <%
                } catch (Exception e) {
        %>
                    <div class="alert alert-danger">Error: <%= e.getMessage() %></div>
        <%
                }
            }
        %>

        <!-- Handle Update -->
        <%
            if (request.getParameter("updateSalary") != null) {
                try {
                    int salaryId = Integer.parseInt(request.getParameter("salary_id"));
                    int empId = Integer.parseInt(request.getParameter("employee_id"));
                    double base = Double.parseDouble(request.getParameter("base_salary"));
                    double bon = Double.parseDouble(request.getParameter("bonus"));
                    String month = request.getParameter("salary_month");

                    PreparedStatement pst = conn.prepareStatement("UPDATE employee_salary SET employee_id=?, base_salary=?, bonus=?, salary_month=? WHERE salary_id=?");
                    pst.setInt(1, empId);
                    pst.setDouble(2, base);
                    pst.setDouble(3, bon);
                    pst.setString(4, month);
                    pst.setInt(5, salaryId);
                    pst.executeUpdate();
        %>
                    <div class="alert alert-info">Salary record updated successfully!</div>
        <%
                } catch (Exception e) {
        %>
                    <div class="alert alert-danger">Update Error: <%= e.getMessage() %></div>
        <%
                }
            }
        %>

        <!-- Handle Delete -->
        <%
            if (request.getParameter("deleteId") != null) {
                try {
                    int deleteId = Integer.parseInt(request.getParameter("deleteId"));
                    PreparedStatement delPst = conn.prepareStatement("DELETE FROM employee_salary WHERE salary_id=?");
                    delPst.setInt(1, deleteId);
                    delPst.executeUpdate();
        %>
                <div class="alert alert-warning">Salary record deleted.</div>
        <%
                } catch (Exception e) {
                    out.println("<div class='alert alert-danger'>Delete Error: " + e.getMessage() + "</div>");
                }
            }
        %>

        <!-- Filter Form -->
        <div class="card mb-4">
            <div class="card-header bg-info text-white">Filter Records</div>
            <div class="card-body">
                <form method="get" action="manage_salary.jsp" class="row g-3">
                    <div class="col-md-5">
                        <label class="form-label">Employee Name</label>
                        <input type="text" name="filter_name" value="<%= request.getParameter("filter_name") != null ? request.getParameter("filter_name") : "" %>" class="form-control" placeholder="Enter name">
                    </div>
                    <div class="col-md-5">
                        <label class="form-label">Salary Month</label>
                        <input type="text" name="filter_month" value="<%= request.getParameter("filter_month") != null ? request.getParameter("filter_month") : "" %>" class="form-control" placeholder="e.g. April 2025">
                    </div>
                    <div class="col-md-2 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary w-100">Filter</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Salary Records Table -->
        <div class="card">
            <div class="card-header bg-secondary text-white">Salary Records</div>
            <div class="card-body">
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th>Salary ID</th>
                            <th>Employee Name</th>
                            <th>Base Salary</th>
                            <th>Bonus</th>
                            <th>Month</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                String filterName = request.getParameter("filter_name");
                                String filterMonth = request.getParameter("filter_month");

                                String query = "SELECT s.salary_id, e.name, s.base_salary, s.bonus, s.salary_month " +
                                               "FROM employee_salary s JOIN employees e ON s.employee_id = e.id WHERE 1=1";

                                if (filterName != null && !filterName.trim().isEmpty()) {
                                    query += " AND e.name LIKE '%" + filterName + "%'";
                                }

                                if (filterMonth != null && !filterMonth.trim().isEmpty()) {
                                    query += " AND s.salary_month LIKE '%" + filterMonth + "%'";
                                }

                                query += " ORDER BY s.salary_id DESC";

                                Statement salaryStmt = conn.createStatement();
                                ResultSet rs = salaryStmt.executeQuery(query);

                                while (rs.next()) {
                        %>
                            <tr>
                                <td><%= rs.getInt("salary_id") %></td>
                                <td><%= rs.getString("name") %></td>
                                <td><%= rs.getDouble("base_salary") %></td>
                                <td><%= rs.getDouble("bonus") %></td>
                                <td><%= rs.getString("salary_month") %></td>
                                <td>
                                    <a href="manage_salary.jsp?editId=<%= rs.getInt("salary_id") %>" class="btn btn-sm btn-primary">Edit</a>
                                    <a href="manage_salary.jsp?deleteId=<%= rs.getInt("salary_id") %>" class="btn btn-sm btn-danger" onclick="return confirm('Delete this record?')">Delete</a>
                                </td>
                            </tr>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='6'><div class='alert alert-danger'>Error loading records: " + e.getMessage() + "</div></td></tr>");
                            }
                        %>
                    </tbody>
                </table>
                <a href="dashboard.jsp" class="btn btn-secondary mt-3">Back to Dashboard</a>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
