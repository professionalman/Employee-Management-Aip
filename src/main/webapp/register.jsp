<%@ include file="dbconnection.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>Register</title>
    <!-- Bootstrap CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            padding-top: 70px;
        }
        .nav-link.disabled {
            pointer-events: none;
            opacity: 0.6;
        }
    </style>
</head>
<body class="bg-light">

<!-- Fixed Navbar -->
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
          <a class="nav-link text-dark " href="index.jsp">Home</a>
        </li>
        <li class="nav-item">
          <a class="nav-link text-dark " href="login.jsp">Login</a>
        </li>
        <li class="nav-item">
          <a class="nav-link text-dark disabled" href="#">Dashboard</a>
        </li>
      </ul>
    </div>
  </div>
</nav>

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card shadow-sm">
                <div class="card-header bg-success text-white">
                    <h4 class="mb-0">Register</h4>
                </div>
                <div class="card-body">
                    <form action="register.jsp" method="post">
                        <div class="mb-3">
                            <label for="name" class="form-label">Name</label>
                            <input type="text" class="form-control" id="name" name="name" required>
                        </div>
                        <div class="mb-3">
                            <label for="email" class="form-label">Email</label>
                            <input type="email" class="form-control" id="email" name="email" required>
                        </div>
                        <div class="mb-3">
                            <label for="password" class="form-label">Password</label>
                            <input type="password" class="form-control" id="password" name="password" required>
                        </div>
                        <div class="d-grid mb-3">
                            <input type="submit" class="btn btn-success" value="Register">
                        </div>
                        <div class="text-center">
                            <a href="index.jsp" class="btn btn-outline-secondary btn-sm">Back to Home</a>
                        </div>
                    </form>

                    <%
                        String name = request.getParameter("name");
                        String email = request.getParameter("email");
                        String password = request.getParameter("password");

                        if (name != null && email != null && password != null) {
                            try {
                                PreparedStatement pst = conn.prepareStatement("INSERT INTO users (name, email, password) VALUES (?, ?, ?)");
                                pst.setString(1, name);
                                pst.setString(2, email);
                                pst.setString(3, password);
                                pst.executeUpdate();
                    %>
                                <div class="alert alert-success mt-3" role="alert">
                                    Registration successful! <a href="login.jsp" class="alert-link">Login here</a>.
                                </div>
                    <%
                            } catch (Exception e) {
                    %>
                                <div class="alert alert-danger mt-3" role="alert">
                                    Error during registration: <%= e.getMessage() %>
                                </div>
                    <%
                            }
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
