<%@ page import="java.sql.*, java.io.*" %>
<%@ include file="dbconnection.jsp" %>
<%
    response.setContentType("application/vnd.ms-excel");
    response.setHeader("Content-Disposition", "attachment; filename=Attendance_Report.xls");

    String query = "SELECT a.id, e.name, a.att_date, a.status FROM attendance a JOIN employees e ON a.employee_id = e.id ORDER BY a.att_date DESC";
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery(query);
%>
<html>
<head>
    <meta charset="UTF-8">
</head>
<body>
    <table border="1">
        <thead>
            <tr style="background-color: #f2f2f2;">
                <th>ID</th>
                <th>Employee Name</th>
                <th>Date</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <%
                while(rs.next()) {
            %>
            <tr>
                <td><%= rs.getInt("id") %></td>
                <td><%= rs.getString("name") %></td>
                <td><%= rs.getString("att_date") %></td>
                <td><%= rs.getString("status") %></td>
            </tr>
            <%
                }
            %>
        </tbody>
    </table>
</body>
</html>
