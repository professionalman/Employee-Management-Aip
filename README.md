# 🧑‍💼 Employee Management System

A web-based application to manage employees, attendance, and salaries efficiently using JSP, MySQL, and Bootstrap. This project is built as part of the Advanced Internet Programming Lab.

---

## 📌 Features

- User Registration & Login with Session Handling
- Add, Update, Delete Employees (CRUD)
- Attendance Tracking with Daily Summary
- Manage Salaries (Base + Bonus)
- Filter salary records by name/month
- Export Attendance and Salary data to Excel
- Dashboard with charts for attendance overview
- Responsive UI using Bootstrap

---

## 🖼️ Screenshots

| Dashboard | Salary Management | Attendance |
|----------|-------------------|------------|
| *(Insert image)* | *(Insert image)* | *(Insert image)* |

---

## 🚀 Technologies Used

### Frontend:
- HTML5 / CSS3
- Bootstrap 5.3
- Chart.js (for attendance summary)

### Backend:
- JSP (Java Server Pages)
- Java (Servlet optional)
- JDBC (Java Database Connectivity)
- MySQL (Database)

---

### 📁 Project File Structure

```bash
EmployeeManagementSystem/
│
├── WebContent/                    # Main web directory (served by Tomcat)
│   ├── css/                      # Stylesheets (if any custom styles used)
│   ├── js/                       # JavaScript files (optional)
│   ├── images/                   # Static images if any (logos, icons)
│   ├── index.jsp                 # Landing page
│   ├── login.jsp                 # Login form and logic
│   ├── register.jsp              # User registration form and logic
│   ├── dashboard.jsp            # Admin dashboard with stats and charts
│   ├── manage_employee.jsp      # Employee CRUD interface
│   ├── manage_salary.jsp        # Salary management form + filters
│   ├── attendance.jsp           # Attendance marking interface
│   ├── generate_salary_slip.jsp # Generate salary slip
│   ├── export_salary_excel.jsp  # Export salary data to Excel
│   ├── exportAttendanceExcel.jsp# Export attendance data to Excel
│   ├── logout.jsp               # Session termination
│   └── dbconnection.jsp         # DB connection reusable include
│
├── WEB-INF/                      # Protected config directory
│   └── web.xml                  # Deployment descriptor
│
└── README.md                     # Project readme
```

### 
```sql
use setup.sql
to restore database schemas and data
```
- to start fresh use sql queries below
```sql
create database your_database;

use your_database;

CREATE TABLE `users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) DEFAULT NULL,
  `email` VARCHAR(100) DEFAULT NULL,
  `password` VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
);

CREATE TABLE `employees` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) DEFAULT NULL,
  `department` VARCHAR(255) DEFAULT NULL,
  `salary` DOUBLE DEFAULT NULL,
  `email` VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE `employee_detail` (
  `emp_detail_id` INT NOT NULL AUTO_INCREMENT,
  `emp_id` INT DEFAULT NULL,
  `email` VARCHAR(100) NOT NULL,
  `phone_number` VARCHAR(15) DEFAULT NULL,
  `address` TEXT,
  PRIMARY KEY (`emp_detail_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `emp_id` (`emp_id`),
  CONSTRAINT `employee_detail_ibfk_1` FOREIGN KEY (`emp_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
);

CREATE TABLE `attendance` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `employee_id` INT DEFAULT NULL,
  `att_date` DATE DEFAULT NULL,
  `status` VARCHAR(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`)
);

CREATE TABLE `employee_salary` (
  `salary_id` INT NOT NULL AUTO_INCREMENT,
  `employee_id` INT DEFAULT NULL,
  `base_salary` DECIMAL(10,2) DEFAULT NULL,
  `bonus` DECIMAL(10,2) DEFAULT NULL,
  `salary_month` VARCHAR(20) DEFAULT NULL,
  PRIMARY KEY (`salary_id`),
  KEY `employee_id` (`employee_id`),
  CONSTRAINT `employee_salary_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
);
```
-- NOTE: use tomcat version 11 and jdk 22/23

## How to run
- clone github repo in a folder
- cd foldername
- open netbeans ide 24 (latest)
- navigate file-> open project and find folder
- in netbeans ide : navigate in project to Web Pages -> WEB-INF -> dbconnection.jsp
- edit your mysql port, username and password 
- clean and build the project
- then run

