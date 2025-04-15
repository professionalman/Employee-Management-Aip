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
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>

<!DOCTYPE html>
<html>
<head>
    <title>Salary Slip Generator</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
    body {
        padding-top: 100px;
    }
</style>
</head>
<body class="p-4">

<div class="container mt-5">

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
              <a class="nav-link text-dark" href="attendance.jsp">Attendance</a>
            </li>
            <li class="nav-item">
              <a class="nav-link text-danger" href="logout.jsp">Logout</a>
            </li>
          </ul>
        </div>
      </div>
    </nav>
<!-- Navbar End -->

    <h3 class="mb-4">Generate Salary Slip</h3>

    <form method="post" class="row g-3 mb-4">
        <div class="col-md-5">
            <label for="employeeId" class="form-label">Select Employee</label>
            <select name="employeeId" class="form-select" required>
                <option value="">-- Choose --</option>
                <%
                    try {
                        PreparedStatement ps = conn.prepareStatement("SELECT id, name FROM employees");
                        ResultSet rs = ps.executeQuery();
                        while (rs.next()) {
                %>
                <option value="<%= rs.getInt("id") %>"><%= rs.getString("name") %> (ID: <%= rs.getInt("id") %>)</option>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<option>Error loading employees</option>");
                    }
                %>
            </select>
        </div>

        <div class="col-md-4">
            <label for="month" class="form-label">Select Month</label>
            <select name="month" class="form-select" required>
    <%
        java.time.YearMonth now = java.time.YearMonth.now();
        java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("MMMM");
        for (int i = 0; i < 12; i++) {
            java.time.YearMonth ym = now.minusMonths(i);
            String monthName = ym.format(formatter); // "April"
    %>
    <option value="<%= monthName %>"><%= monthName %></option>
    <%
        }
    %>
</select>

        </div>

        <div class="col-md-3 d-flex align-items-end">
            <button type="submit" class="btn btn-primary">Generate Slip</button>
        </div>
    </form>

    <%
        if (request.getMethod().equalsIgnoreCase("POST")) {
            int empId = Integer.parseInt(request.getParameter("employeeId"));
            String month = request.getParameter("month");

            try {
                PreparedStatement stmt = conn.prepareStatement(
                    "SELECT e.name, s.base_salary, s.bonus FROM employee_salary s JOIN employees e ON s.employee_id = e.id WHERE s.employee_id = ? AND s.salary_month = ?"
                );
                stmt.setInt(1, empId);
                stmt.setString(2, month);
                ResultSet rs = stmt.executeQuery();

                if (rs.next()) {
                    String empName = rs.getString("name");
                    double base = rs.getDouble("base_salary");
                    double bonus = rs.getDouble("bonus");
                    double total = base + bonus;
    %>

    <!-- Salary Slip -->
    <div class="card mt-4" id="slipArea">
        <div class="card-body">
            <h4 class="text-center mb-3">Salary Slip</h4>
            <p><strong>Employee ID:</strong> <%= empId %></p>
            <p><strong>Name:</strong> <%= empName %></p>
            <p><strong>Month:</strong> <%= month %></p>
            <hr>
            <p><strong>Base Salary:</strong> ₹ <%= base %></p>
            <p><strong>Bonus:</strong> ₹ <%= bonus %></p>
            <p><strong>Total:</strong> ₹ <%= total %></p>
        </div>
    </div>

<!--    <button class="btn btn-success mt-3"
    onclick="downloadSalarySlipImage(<%= empId %>, '<%= empName.replaceAll("'", "\\\\'") %>', '<%= month %>', <%= base %>, <%= bonus %>, <%= total %>)">
    Download Salary Slip (Image)
</button>-->
    <button class="btn btn-danger mt-2"
    onclick="downloadSalarySlipPDF(<%= empId %>, '<%= empName.replaceAll("'", "\\\\'") %>', '<%= month %>', <%= base %>, <%= bonus %>, <%= total %>)">
    Download Salary Slip (PDF)
</button>




    <%
                } else {
                    out.println("<div class='alert alert-warning mt-3'>No salary record found for the selected employee and month.</div>");
                }
            } catch (Exception e) {
                out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
            }
        }
    %>

    <a href="dashboard.jsp" class="btn btn-secondary mt-4">Back to Dashboard</a>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>

<script>
    function downloadSalarySlipImage(empId, empName, month, base, bonus, total) {
        const formattedMonth = month.charAt(0).toUpperCase() + month.slice(1);
        const today = new Date().toLocaleDateString();

        // Populate the slip content
        document.getElementById("empIdText").innerText = empId;
        document.getElementById("empNameText").innerText = empName;
        document.getElementById("monthText").innerText = formattedMonth;
        document.getElementById("baseSalaryText").innerText = "₹ " + base.toFixed(2);
        document.getElementById("bonusText").innerText = "₹ " + bonus.toFixed(2);
        document.getElementById("totalText").innerText = "₹ " + total.toFixed(2);
        document.getElementById("generatedDate").innerText = today;

        const slip = document.getElementById("slip-content");
        slip.style.display = "block"; // Show for capture

        // Give browser time to render the visible element
        setTimeout(() => {
            html2canvas(slip, { scale: 2 }).then(canvas => {
                const link = document.createElement("a");
                link.download = `SalarySlip_E${empId}_${formattedMonth}.png`;
                link.href = canvas.toDataURL("image/png");
                link.click();
                
                slip.style.display = "none"; // Hide again after capture
            });
        }, 100); // 100ms delay is enough
    }
</script>

<!-- Hidden Salary Slip Container -->
<div id="slip-content" style="display: none; padding: 20px; font-family: Arial; max-width: 600px; margin: auto; background: white; border: 1px solid #ddd;">
<!--    <h2 style="text-align: center; color: #17485F;">Employee Management System</h2>
    --><h3 style="text-align: center; margin-bottom: 20px;">Salary Slip</h3>
    <table style="width: 100%; border-collapse: collapse; font-size: 15px;">
        <tr>
            <td style="font-weight: bold; padding: 8px; border-bottom: 1px solid #ccc;">Employee ID</td>
            <td style="padding: 8px; border-bottom: 1px solid #ccc;" id="empIdText"></td>
        </tr>
        <tr>
            <td style="font-weight: bold; padding: 8px; border-bottom: 1px solid #ccc;">Employee Name</td>
            <td style="padding: 8px; border-bottom: 1px solid #ccc;" id="empNameText"></td>
        </tr>
        <tr>
            <td style="font-weight: bold; padding: 8px; border-bottom: 1px solid #ccc;">Month & Year</td>
            <td style="padding: 8px; border-bottom: 1px solid #ccc;" id="monthText"></td>
        </tr>
        <tr>
            <td style="font-weight: bold; padding: 8px; border-bottom: 1px solid #ccc;">Base Salary</td>
            <td style="padding: 8px; border-bottom: 1px solid #ccc;" id="baseSalaryText"></td>
        </tr>
        <tr>
            <td style="font-weight: bold; padding: 8px; border-bottom: 1px solid #ccc;">Bonus</td>
            <td style="padding: 8px; border-bottom: 1px solid #ccc;" id="bonusText"></td>
        </tr>
        <tr>
            <td style="font-weight: bold; padding: 8px; border-bottom: 1px solid #ccc;">Total Salary</td>
            <td style="padding: 8px; border-bottom: 1px solid #ccc;" id="totalText"></td>
        </tr>
        <tr>
            <td style="font-weight: bold; padding: 8px;">Date Generated</td>
            <td style="padding: 8px;" id="generatedDate"></td>
        </tr>
    </table>
</div>




<script>
function downloadSalarySlipPDF(empId, empName, month, base, bonus, total) {
    const formattedMonth = month.charAt(0).toUpperCase() + month.slice(1);
    const today = new Date().toLocaleDateString();

    // Fill dynamic content
    document.getElementById("empIdText").innerText = empId;
    document.getElementById("empNameText").innerText = empName;
    document.getElementById("monthText").innerText = formattedMonth;
    document.getElementById("baseSalaryText").innerText = "₹ " + base.toFixed(2);
    document.getElementById("bonusText").innerText = "₹ " + bonus.toFixed(2);
    document.getElementById("totalText").innerText = "₹ " + total.toFixed(2);
    document.getElementById("generatedDate").innerText = today;

    const slip = document.getElementById("slip-content");
    slip.style.display = "block";

    setTimeout(() => {
        html2canvas(slip, { scale: 2 }).then(canvas => {
            const imgData = canvas.toDataURL("image/png");
            const pdf = new jspdf.jsPDF();
            const pdfWidth = pdf.internal.pageSize.getWidth();
            const pageHeight = pdf.internal.pageSize.getHeight();

            // === HEADER ===
            pdf.setFillColor(23, 72, 95); // Deep blue header
            pdf.rect(0, 0, pdfWidth, 25, 'F');
            pdf.setFont("helvetica", "bold");
            pdf.setFontSize(14);
            pdf.setTextColor(255);
            pdf.text("Employee Management System", pdfWidth / 2, 10, { align: "center" });

            pdf.setFontSize(10);
            pdf.text("123, Sector 21, New Delhi, India", pdfWidth / 2, 17, { align: "center" });

            // === INSERT SALARY SLIP CONTENT AS IMAGE ===
            const contentTop = 30;
            const imgProps = pdf.getImageProperties(imgData);
            const imgHeight = (imgProps.height * (pdfWidth - 20)) / imgProps.width;

            pdf.addImage(imgData, 'PNG', 10, contentTop, pdfWidth - 20, imgHeight);

            // === TABLE STYLE BOX ===
            const tableTop = contentTop + imgHeight + 10;
            const colX = 35;
            const rowHeight = 10;
            const colWidth = 40;

            pdf.setFontSize(11);
            pdf.setTextColor(0);
            pdf.setFont("helvetica", "bold");

            pdf.text("Salary Breakdown", pdfWidth / 2, tableTop, { align: "center" });

            // Table Header
            const tableStartY = tableTop + 6;
            pdf.setFillColor(240);
            pdf.setDrawColor(200);
            pdf.rect(colX, tableStartY, colWidth, rowHeight, 'FD');
            pdf.rect(colX + colWidth, tableStartY, colWidth, rowHeight, 'FD');
            pdf.rect(colX + colWidth * 2, tableStartY, colWidth, rowHeight, 'FD');

            pdf.setFont("helvetica", "bold");
            pdf.setTextColor(50);
            pdf.text("Base Salary", colX + 5, tableStartY + 7);
            pdf.text("Bonus", colX + colWidth + 5, tableStartY + 7);
            pdf.text("Total Salary", colX + colWidth * 2 + 5, tableStartY + 7);

            // Table Row
            const rowY = tableStartY + rowHeight;
            pdf.setFont("helvetica", "normal");
            pdf.setTextColor(0);
            pdf.rect(colX, rowY, colWidth, rowHeight);
            pdf.rect(colX + colWidth, rowY, colWidth, rowHeight);
            pdf.rect(colX + colWidth * 2, rowY, colWidth, rowHeight);

            pdf.text(" " + base.toFixed(2), colX + 5, rowY + 7);
            pdf.text(" " + bonus.toFixed(2), colX + colWidth + 5, rowY + 7);
            pdf.text(" " + total.toFixed(2), colX + colWidth * 2 + 5, rowY + 7);

            // === FOOTER ===
            const footerY = pageHeight - 25;
            pdf.setDrawColor(200);
            pdf.line(15, footerY, pdfWidth - 15, footerY); // horizontal line

            pdf.setFontSize(10);
            pdf.setTextColor(80);
            pdf.setFont("helvetica", "italic");
            pdf.text("This is a system-generated salary slip. No signature is required.", pdfWidth / 2, footerY + 7, { align: "center" });

            pdf.setFont("helvetica", "normal");
            pdf.text("For queries, contact HR at hr@employeemanagement.com", pdfWidth / 2, footerY + 13, { align: "center" });

            pdf.setFontSize(8);
            pdf.setTextColor(150);
            pdf.text("© " + new Date().getFullYear() + " Employee Management System", pdfWidth / 2, footerY + 19, { align: "center" });

            // === SAVE PDF ===
            pdf.save(`SalarySlip_E${empId}_${formattedMonth}.pdf`);
            slip.style.display = "none";
        });
    }, 100);
}
</script>





<!-- 👇 Add this just before </body> -->
<div id="slip-content" style="width: 600px; font-family: Arial, sans-serif; padding: 20px; background: #fff; color: #000; display: none;">
    <h2 style="text-align:center; margin-bottom: 20px;">Salary Slip</h2>
    <table style="width: 100%; font-size: 14px;">
        <tr><td><strong>Employee ID:</strong></td><td id="empIdText"></td></tr>
        <tr><td><strong>Name:</strong></td><td id="empNameText"></td></tr>
        <tr><td><strong>Month:</strong></td><td id="monthText"></td></tr>
        <tr><td colspan="2"><hr></td></tr>
        <tr><td><strong>Base Salary:</strong></td><td id="baseSalaryText"></td></tr>
        <tr><td><strong>Bonus:</strong></td><td id="bonusText"></td></tr>
        <tr><td><strong>Total Salary:</strong></td><td id="totalText"></td></tr>
    </table>
    <p style="margin-top: 30px;">Generated on: <span id="generatedDate"></span></p>
</div>

</body>
</html>



</body>
</html>
