# Employee Time Management System
## Full-Stack Spring Boot 3 & MySQL Web Application

A complete, responsive, and secure **Employee Time Management System** designed for enterprise workforce attendance tracking, shift scheduling, and time-off administration.

---

## 🌟 Key Features

### HR Manager Portal (`/hr/dashboard`)
- **Executive Operations Dashboard**: Real-time KPI summary cards (Total Employees, Pending Leave Requests, Total Hours Logged in past 30 days, Missing Logs today) and interactive Chart.js visualizations (bar chart, doughnut chart, trend line).
- **Employee Directory (`/hr/employees`)**: Search employee database, view account statuses, and safely register new employees with automatic BCrypt password hashing.
- **Time-Off Administration (`/hr/time-off`)**: Review leave applications, filter by status (All, Pending, Approved, Rejected), approve/reject requests with custom managerial decision notes and audit timestamps. Overlapping leave is prevented.
- **Shift Scheduling (`/hr/schedules`)**: Assign working shift hours (start/end) or designated days off, search schedules across date ranges, edit existing shifts, and delete records with confirmation.
- **Auditable Time Log Review (`/hr/time-logs`)**: Review daily employee time records. If an error is spotted, HR can correct start/end times or break duration by submitting a mandatory compliance reason. All changes are recorded in an immutable `time_log_audit` table.
- **Reports & Analytics (`/hr/reports`)**: Multi-criteria reporting (by employee, date range, report type) with live statistics and one-click **CSV export** for audit and payroll teams.

### Employee Portal (`/employee/dashboard`)
- **Personal Dashboard**: View daily hours worked today, weekly accumulated hours, next scheduled shift, upcoming days off, and pending/approved leave metrics.
- **Work Hours Logging (`/employee/time-logs`)**: Clean submission form with **real-time JavaScript net working hours calculator** that automatically detects and computes overnight shifts across midnight. Enforces **one log entry per employee per work date** to prevent duplicate entries.
- **Time-Off Requests (`/employee/time-off`)**: Submit leave applications with start/end date validation, reason text, and conflict checking against existing approved or pending leaves. View decision status and HR feedback notes.
- **Personal Schedule Calendar (`/employee/schedule`)**: Interactive weekly calendar view with previous/next week navigation, highlighting today's shift and rest days. Read-only permissions enforced.

---

## 🛠️ Technology Stack

| Layer | Technologies |
| :--- | :--- |
| **Backend** | Java 17+, Spring Boot 3.3.4, Spring MVC, Spring Data JPA, Hibernate, Spring Security 6, Bean Validation |
| **Frontend** | HTML5, CSS3, JavaScript, Bootstrap 5.3, Bootstrap Icons, Thymeleaf, Chart.js 4.4 |
| **Database** | MySQL 8.x (Default Production) & H2 (In-Memory Demo/Testing Profile) |
| **Build & Tooling** | Maven 3.9+, Maven Wrapper (`mvnw.cmd`) |

---

## 🚀 Quick Start Guide

### Prerequisites
1. **Java Development Kit (JDK 17 or higher)** installed (`java -version`).
2. **MySQL 8.x Server** (optional for instant demo, required for permanent MySQL storage).
3. **Maven** (included via bundled `mvnw.cmd` or system `mvn`).

---

### Running with MySQL (Default)

1. Open MySQL Workbench or MySQL CLI:
   ```sql
   CREATE DATABASE employee_time_management;
   ```
2. Open `src/main/resources/application.properties` and verify your MySQL credentials:
   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3306/employee_time_management?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
   spring.datasource.username=root
   spring.datasource.password=root
   ```
3. Run the application from the project root:
   ```powershell
   .\mvnw.cmd spring-boot:run
   ```
   *Or with system Maven:*
   ```bash
   mvn spring-boot:run
   ```
4. Access the web application at:
   **[http://localhost:8080](http://localhost:8080)**

---

### Running in Instant Demo Mode (No MySQL Server Required)

If you are demonstrating the project on a college lab computer or laptop without MySQL installed, run with the in-memory H2 profile:

```powershell
.\mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=demo
```

The database, tables, seed users, shifts, historical logs, and leave requests will be initialized automatically in memory!

---

## 🔑 Default Login Credentials

The application includes an automated `DataInitializer` that seeds realistic accounts and records upon first launch:

| Role | Email Address | Password | Dashboard URL |
| :--- | :--- | :--- | :--- |
| **HR Manager** | `hr@company.com` | `Admin@123` | `/hr/dashboard` |
| **Employee 1** | `john.doe@company.com` | `Employee@123` | `/employee/dashboard` |
| **Employee 2** | `jane.smith@company.com` | `Employee@123` | `/employee/dashboard` |
| **Employee 3** | `alex.turner@company.com` | `Employee@123` | `/employee/dashboard` |

> 💡 **Tip:** On the login page (`/login`), click the **"Use"** button under **Demo Accounts** for one-click credential auto-fill!

---

## 📂 Project Architecture

```
src/main/java/com/example/employeetimemanagement/
├── EmployeeTimeManagementApplication.java  # Main entry point
├── config/
│   └── DataInitializer.java               # Database seeder (BCrypt passwords & test data)
├── controller/
│   ├── AuthController.java                # /login, /logout, root routing
│   ├── CustomErrorController.java         # 403, 404, 500 error views
│   ├── EmployeeDashboardController.java   # /employee/dashboard
│   ├── EmployeeScheduleController.java    # /employee/schedule
│   ├── EmployeeTimeLogController.java     # /employee/time-logs
│   ├── EmployeeTimeOffController.java     # /employee/time-off
│   ├── HrDashboardController.java         # /hr/dashboard
│   ├── HrEmployeeController.java          # /hr/employees
│   ├── HrReportController.java            # /hr/reports & CSV export
│   ├── HrScheduleController.java          # /hr/schedules
│   ├── HrTimeLogController.java           # /hr/time-logs & audit history
│   └── HrTimeOffController.java           # /hr/time-off decisions
├── dto/                                   # Form validation & transfer objects
├── entity/
│   ├── User.java                          # User entity (HR & Employee)
│   ├── TimeLog.java                       # Daily work time records
│   ├── TimeOffRequest.java                # Leave requests & decisions
│   ├── EmployeeSchedule.java              # Work shifts & rest days
│   └── TimeLogAudit.java                  # Immutable HR correction history
├── enums/
│   ├── Role.java                          # ROLE_HR_MANAGER, ROLE_EMPLOYEE
│   ├── RequestStatus.java                 # PENDING, APPROVED, REJECTED
│   └── TimeLogStatus.java                 # SUBMITTED, CORRECTED
├── exception/
│   ├── BusinessValidationException.java   # Clean business rule exceptions
│   ├── GlobalExceptionHandler.java        # Centralized exception handler
│   ├── ResourceNotFoundException.java     # Missing entity exceptions
│   └── UnauthorizedException.java         # Security boundary exceptions
├── repository/                            # Spring Data JPA repositories
├── security/
│   ├── CustomAuthenticationSuccessHandler.java # Role-based redirect logic
│   ├── CustomUserDetails.java             # Spring Security user representation
│   ├── CustomUserDetailsService.java      # User lookup by email
│   └── SecurityConfig.java                # Route authorization & filters
└── service/                               # Core business logic layer
    ├── AuditService.java
    ├── DashboardService.java
    ├── ReportService.java
    ├── ScheduleService.java
    ├── TimeLogService.java
    ├── TimeOffService.java
    └── UserService.java
```

---

## 🧪 Automated Testing

Execute the test suite to verify business rules, security permissions, shift calculations, and audit logging:

```powershell
.\mvnw.cmd test
```

Test coverage includes:
- **`TimeLogCalculationTest`**: Day shift net minutes, overnight shift detection crossing midnight, break duration subtraction, negative duration rejection.
- **`TimeLogServiceTest`**: Single time-log per date constraint, manager correction recording original & corrected values in audit history.
- **`TimeOffServiceTest`**: Start/end date ordering, overlapping approved leave conflict detection, preventing re-decision of processed requests.
- **`SecurityAndAccessTest`**: Redirection of unauthenticated users, HTTP 403 Forbidden enforcement when Employees attempt to access HR endpoints, and role-based dashboard authorization.
