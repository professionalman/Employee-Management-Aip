<%@ page import="java.sql.*" %>
<%@ page contentType="application/vnd.ms-excel" %>
<%@ page import="java.util.*" %>
<%@ include file="dbconnection.jsp" %>

<%
    response.setHeader("Content-Disposition", "attachment; filename=Employee_Salary_Report.xls");

    try {
        PreparedStatement stmt = conn.prepareStatement(
            "SELECT s.*, e.name FROM employee_salary s " +
            "JOIN employees e ON s.employee_id = e.id"
        );
        ResultSet rs = stmt.executeQuery();
%>

<table border="1">
    <thead>
        <tr style="background-color: #f2f2f2;">
            <th>Employee ID</th>
            <th>Employee Name</th>
            <th>Month</th>
            <th>Base Salary</th>
            <th>Bonus</th>
            <th>Total Salary</th>
        </tr>
    </thead>
    <tbody>
        <%
            while (rs.next()) {
                int empId = rs.getInt("employee_id");
                String name = rs.getString("name");
                String month = rs.getString("salary_month");
                double base = rs.getDouble("base_salary");
                double bonus = rs.getDouble("bonus");
                double total = base + bonus;
        %>
        <tr>
            <td><%= empId %></td>
            <td><%= name %></td>
            <td><%= month %></td>
            <td><%= base %></td>
            <td><%= bonus %></td>
            <td><%= total %></td>
        </tr>
        <%
            }
        %>
    </tbody>
</table>

<%
    } catch (Exception e) {
        out.println("Error exporting data: " + e.getMessage());
    }
%>
