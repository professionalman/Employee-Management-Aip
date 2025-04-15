<%-- 
    Document   : dbconnection
    Created on : 28 Feb 2025, 3:43:50?pm
    Author     : 
--%>

<%@ page import="java.sql.*" %>
<%
    String url = "jdbc:mysql://localhost:3307/your_database";
    String user = "root";
    String pass = "root";
    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, user, pass);
    } catch (Exception e) {
        e.printStackTrace();
    }
%>