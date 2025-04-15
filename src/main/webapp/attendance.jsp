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
    <title>Employee Attendance</title>
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
          <a class="nav-link text-dark" href="manage_employee.jsp">Employee</a>
        </li>
        <li class="nav-item">
          <a class="nav-link text-danger" href="logout.jsp">Logout</a>
        </li>
      </ul>
    </div>
  </div>
</nav>
<!-- Navbar End -->

<div class="container mt-3">
    <h2 class="mb-4">Employee Attendance Management</h2>

    <!-- Bulk Attendance Form -->
    <div class="card mb-4">
        <div class="card-header bg-primary text-white">Bulk Mark Attendance</div>
        <div class="card-body">
            <form method="post" action="attendance.jsp">
                <div class="mb-3">
                    <label class="form-label">Date</label>
                    <input type="date" name="att_date" class="form-control" required>
                </div>
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th>Employee Name</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Statement empStmt = conn.createStatement();
                            ResultSet empRs = empStmt.executeQuery("SELECT id, name FROM employees");
                            while (empRs.next()) {
                        %>
                        <tr>
                            <td>
                                <%= empRs.getString("name") %>
                                <input type="hidden" name="employee_ids" value="<%= empRs.getInt("id") %>">
                            </td>
                            <td>
                                <select name="status_<%= empRs.getInt("id") %>" class="form-control">
                                    <option value="Present">Present</option>
                                    <option value="Absent">Absent</option>
                                </select>
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
                <button type="submit" name="bulkMark" class="btn btn-success">Bulk Mark</button>
            </form>
        </div>
    </div>

    <!-- Bulk Mark Attendance Handler -->
    <%
        if (request.getParameter("bulkMark") != null) {
            String attDate = request.getParameter("att_date");
            String[] empIds = request.getParameterValues("employee_ids");

            for (String idStr : empIds) {
                int empId = Integer.parseInt(idStr);
                String status = request.getParameter("status_" + empId);

                PreparedStatement check = conn.prepareStatement("SELECT * FROM attendance WHERE employee_id=? AND att_date=?");
                check.setInt(1, empId);
                check.setString(2, attDate);
                ResultSet exists = check.executeQuery();

                if (exists.next()) {
                    PreparedStatement update = conn.prepareStatement("UPDATE attendance SET status=? WHERE employee_id=? AND att_date=?");
                    update.setString(1, status);
                    update.setInt(2, empId);
                    update.setString(3, attDate);
                    update.executeUpdate();
                } else {
                    PreparedStatement insert = conn.prepareStatement("INSERT INTO attendance (employee_id, att_date, status) VALUES (?, ?, ?)");
                    insert.setInt(1, empId);
                    insert.setString(2, attDate);
                    insert.setString(3, status);
                    insert.executeUpdate();
                }
            }
    %>
        <div class="alert alert-success">Attendance marked/updated for selected date.</div>
    <%
        }
    %>

    <!-- Attendance Records -->
    <div class="card mt-4">
        <div class="card-header bg-secondary text-white">Attendance Records</div>
        <div class="card-body">
            <form method="get" action="attendance.jsp" class="row mb-3 g-3">
                <div class="col-md-5">
                    <label>Employee Name</label>
                    <input type="text" name="filter_name" class="form-control" value="<%= request.getParameter("filter_name") != null ? request.getParameter("filter_name") : "" %>">
                </div>
                <div class="col-md-5">
                    <label>Date</label>
                    <input type="date" name="filter_date" class="form-control" value="<%= request.getParameter("filter_date") != null ? request.getParameter("filter_date") : "" %>">
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary w-100">Filter</button>
                </div>
            </form>

            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Employee</th>
                        <th>Date</th>
                        <th>Status</th>
                        <th>Update</th>
                        <th>Delete</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        String filterQuery = "SELECT a.id, e.name, a.att_date, a.status FROM attendance a JOIN employees e ON a.employee_id = e.id WHERE 1=1";
                        String filterName = request.getParameter("filter_name");
                        String filterDate = request.getParameter("filter_date");

                        if (filterName != null && !filterName.trim().isEmpty()) {
                            filterQuery += " AND e.name LIKE '%" + filterName + "%'";
                        }

                        if (filterDate != null && !filterDate.trim().isEmpty()) {
                            filterQuery += " AND a.att_date = '" + filterDate + "'";
                        }

                        filterQuery += " ORDER BY a.att_date DESC";

                        Statement filterStmt = conn.createStatement();
                        ResultSet rs = filterStmt.executeQuery(filterQuery);

                        while (rs.next()) {
                    %>
                    <tr>
                        <form method="post" action="attendance.jsp">
                            <td><%= rs.getInt("id") %></td>
                            <td><%= rs.getString("name") %></td>
                            <td><%= rs.getString("att_date") %>
                                <input type="hidden" name="att_id" value="<%= rs.getInt("id") %>">
                            </td>
                            <td>
                                <select name="new_status" class="form-control">
                                    <option value="Present" <%= rs.getString("status").equals("Present") ? "selected" : "" %>>Present</option>
                                    <option value="Absent" <%= rs.getString("status").equals("Absent") ? "selected" : "" %>>Absent</option>
                                </select>
                            </td>
                            <td>
                                <button type="submit" name="updateStatus" class="btn btn-sm btn-info">Update</button>
                            </td>
                            <td>
                                <a href="attendance.jsp?deleteId=<%= rs.getInt("id") %>" class="btn btn-sm btn-danger" onclick="return confirm('Delete this record?')">Delete</a>
                            </td>
                        </form>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Update Status Handler -->
    <%
        if (request.getParameter("updateStatus") != null) {
            int attId = Integer.parseInt(request.getParameter("att_id"));
            String newStatus = request.getParameter("new_status");

            PreparedStatement update = conn.prepareStatement("UPDATE attendance SET status=? WHERE id=?");
            update.setString(1, newStatus);
            update.setInt(2, attId);
            update.executeUpdate();
    %>
        <div class="alert alert-info mt-3">Attendance updated successfully!</div>
    <%
        }
    %>

    <!-- Handle Delete -->
    <%
        if (request.getParameter("deleteId") != null) {
            int delId = Integer.parseInt(request.getParameter("deleteId"));
            PreparedStatement delPst = conn.prepareStatement("DELETE FROM attendance WHERE id=?");
            delPst.setInt(1, delId);
            delPst.executeUpdate();
    %>
        <div class="alert alert-warning">Attendance record deleted.</div>
    <%
        }
    %>
    <!-- Attendance Summary Section -->
    <div class="card mt-5">
        <div class="card-header bg-info text-white">Attendance Summary (Monthly)</div>
        <div class="card-body">
            <form method="get" action="attendance.jsp" class="row g-3 mb-3">
                <div class="col-md-4">
                    <label class="form-label">Month</label>
                    <select name="summary_month" class="form-control">
                        <%
                            for (int m = 1; m <= 12; m++) {
                                String monthVal = m < 10 ? "0" + m : String.valueOf(m);
                                String selected = monthVal.equals(request.getParameter("summary_month")) ? "selected" : "";
                        %>
                            <option value="<%= monthVal %>" <%= selected %>><%= monthVal %></option>
                        <%
                            }
                        %>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Year</label>
                    <input type="number" name="summary_year" class="form-control" value="<%= request.getParameter("summary_year") != null ? request.getParameter("summary_year") : Calendar.getInstance().get(Calendar.YEAR) %>" required>
                </div>
                <div class="col-md-4 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary w-100">Show Summary</button>
                </div>
            </form>

            <%
                String summaryMonth = request.getParameter("summary_month");
                String summaryYear = request.getParameter("summary_year");

                if (summaryMonth != null && summaryYear != null) {
                    String summaryQuery = "SELECT e.name, " +
                            "SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_days, " +
                            "SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absent_days, " +
                            "COUNT(a.id) AS total_days " +
                            "FROM employees e " +
                            "LEFT JOIN attendance a ON e.id = a.employee_id " +
                            "AND MONTH(a.att_date) = ? AND YEAR(a.att_date) = ? " +
                            "GROUP BY e.name";

                    PreparedStatement summaryStmt = conn.prepareStatement(summaryQuery);
                    summaryStmt.setInt(1, Integer.parseInt(summaryMonth));
                    summaryStmt.setInt(2, Integer.parseInt(summaryYear));
                    ResultSet summaryRs = summaryStmt.executeQuery();
            %>
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th>Employee</th>
                        <th>Present Days</th>
                        <th>Absent Days</th>
                        <th>Total Days</th>
                        <th>Attendance %</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        while (summaryRs.next()) {
                            int present = summaryRs.getInt("present_days");
                            int total = summaryRs.getInt("total_days");
                            double percent = total > 0 ? (present * 100.0 / total) : 0;
                    %>
                    <tr>
                        <td><%= summaryRs.getString("name") %></td>
                        <td><%= present %></td>
                        <td><%= summaryRs.getInt("absent_days") %></td>
                        <td><%= total %></td>
                        <td><%= String.format("%.2f", percent) %> %</td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
            <%
                }
            %>
        </div>
    </div>

    <a href="dashboard.jsp" class="btn btn-secondary mt-3">Back to Dashboard</a>
</div>
</body>
</html>
