<%-- 
    Document   : index
    Created on : 28 Feb 2025, 3:42:08 PM
    Author     : kavya
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Employee Management System</title>
    <!-- Bootstrap CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <%
    String message = request.getParameter("message");
    if ("logout".equals(message)) {
%>
    <div class="alert alert-success alert-dismissible fade show text-center" role="alert" id="logoutAlert">
        You have been logged out successfully.
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
<%
    }
%>

    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card shadow-lg">
                    <div class="card-header bg-dark text-white text-center">
                        <h3 class="mb-0">Employee Management System</h3>
                    </div>
                    <div class="card-body text-center">
                        <p class="lead mb-4">Welcome to the Employee Management System. Please login or register to continue.</p>
                        <div class="d-flex justify-content-center">
                            <a href="register.jsp" class="btn btn-outline-success me-3">Register</a>
                            <a href="login.jsp" class="btn btn-outline-primary">Login</a>
                        </div>
                    </div>
                    <div class="card-footer text-muted text-center">
                        &copy; 2025 Employee Management Portal
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    // Auto-hide the alert after 3 seconds (3000ms)
    setTimeout(() => {
        const alert = document.getElementById('logoutAlert');
        if (alert) {
            let fadeEffect = setInterval(() => {
                if (!alert.style.opacity) {
                    alert.style.opacity = 1;
                }
                if (alert.style.opacity > 0) {
                    alert.style.opacity -= 0.1;
                } else {
                    clearInterval(fadeEffect);
                    alert.remove(); // remove from DOM after fading
                }
            }, 50);
        }
    }, 3000);
</script>

</body>
</html>
