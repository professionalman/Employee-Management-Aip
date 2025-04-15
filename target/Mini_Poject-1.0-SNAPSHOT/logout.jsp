<%-- 
    Document   : logout
    Created on : 28 Feb 2025, 3:49:46?pm
    Author     : kavya
--%>

<%@ page session="true" %>
<%
    session.invalidate(); // Destroy the session
    response.sendRedirect("index.jsp?message=logout"); // Redirect with a logout message
%>



