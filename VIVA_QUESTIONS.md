# COLLEGE VIVA QUESTIONS & ANSWERS
## Employee Time Management System (Java Full-Stack)

This guide provides answers to the most frequently asked questions during college viva examinations and project presentations.

---

### Q1: What is Spring Boot and why did you choose it over standard Spring MVC or plain Servlets?
**Answer:**
Spring Boot is an opinionated, production-ready framework built on top of the Spring framework. We chose it because:
1. **Auto-Configuration**: Automatically configures dependencies (e.g. data source, Thymeleaf, Spring Security) based on the classpath.
2. **Embedded Server**: Includes an embedded Tomcat container, eliminating the need to install or configure external WAR deployment servers.
3. **Starter Dependencies**: Simplifies Maven dependency management through consolidated parent starters (e.g., `spring-boot-starter-web`, `spring-boot-starter-data-jpa`).
4. **Rapid Prototyping & Maintainability**: Drastically reduces boilerplate XML or Java configurations, allowing focus on core business logic.

---

### Q2: Explain the architecture of your application.
**Answer:**
Our application follows the **Layered Model-View-Controller (MVC)** architecture:
- **Presentation Layer (View)**: HTML5, CSS3, JavaScript, Bootstrap 5, and Thymeleaf templates render dynamic server-side content and display Chart.js visualizations.
- **Controller Layer (Controller)**: Spring MVC controllers (`HrTimeOffController`, `EmployeeTimeLogController`, etc.) map HTTP GET/POST requests, validate incoming DTO forms, and return view names.
- **Business Layer (Service)**: Service classes (`TimeLogService`, `TimeOffService`, etc.) execute business validation rules, shift calculations, conflict checking, and transaction boundaries using `@Transactional`.
- **Persistence Layer (Repository)**: Spring Data JPA repository interfaces extend `JpaRepository` to perform CRUD and custom JPQL queries.
- **Database Layer (Model)**: MySQL 8.x relational database (with optional in-memory H2 profile) holding persistent tables and constraints.

---

### Q3: How is authentication and role-based authorization implemented?
**Answer:**
We utilize **Spring Security 6**:
1. **Authentication**: Users submit their email and password. `CustomUserDetailsService` retrieves the user entity from `UserRepository`. Passwords are validated using `BCryptPasswordEncoder` which salts and hashes passwords.
2. **Role-Based Authorization**:
   - In `SecurityConfig`, we define HTTP route security:
     - `.requestMatchers("/hr/**").hasRole("HR_MANAGER")`
     - `.requestMatchers("/employee/**").hasRole("EMPLOYEE")`
   - If an employee tries to access an `/hr/*` URL, Spring Security denies access with an **HTTP 403 Forbidden** error.
3. **Dynamic Redirection**: A custom `CustomAuthenticationSuccessHandler` checks the user's granted authorities upon successful login and redirects HR Managers to `/hr/dashboard` and Employees to `/employee/dashboard`.

---

### Q4: How do you handle password security? Why not store MD5 or plain text?
**Answer:**
Plain text passwords are completely vulnerable to data leaks, and algorithms like MD5 or SHA-1 are cryptographically broken and prone to rainbow table attacks.
We use **BCrypt** (`BCryptPasswordEncoder`). BCrypt incorporates a random 128-bit salt and an adaptive work factor (cost parameter 10). It produces a 60-character hash (e.g., `$2a$10$...`) where identical passwords result in completely different hashes, protecting against rainbow table and brute-force attacks.

---

### Q5: How does your application prevent duplicate time logs for the same employee on the same date?
**Answer:**
Duplicate prevention is enforced at two levels (**defense-in-depth**):
1. **Database Constraint**: On the `time_logs` table, we define a composite unique constraint:
   `CONSTRAINT uq_employee_work_date UNIQUE (employee_id, work_date)`
   This physically blocks any database insertion of duplicate logs on the same date.
2. **Service Validation**: Before saving, `TimeLogService` calls `timeLogRepository.existsByEmployeeIdAndWorkDate(...)`. If a record exists, it throws a user-friendly `BusinessValidationException`, notifying the user immediately without triggering a raw database exception.

---

### Q6: How does the application calculate shift durations, especially for overnight shifts?
**Answer:**
The duration logic resides in `TimeLogService.calculateNetWorkingMinutes()`:
1. Both `startTime` and `endTime` are converted into total minutes from midnight:
   $$\text{startMinute} = \text{hour} \times 60 + \text{minute}$$
2. **Overnight Shift Policy**:
   - If `endMinute <= startMinute` (e.g., 22:00 to 06:00), the shift spans past midnight into the next day.
   - The gross minutes are calculated as:
     $$\text{Gross} = (24 \times 60 - \text{startMinute}) + \text{endMinute}$$
   - Otherwise (standard day shift), $\text{Gross} = \text{endMinute} - \text{startMinute}$.
3. **Net Duration**:
   $$\text{Net Minutes} = \text{Gross Minutes} - \text{breakMinutes}$$
4. Validation checks verify that `breakMinutes >= 0` and that break time does not equal or exceed total shift duration.

---

### Q7: What happens when an HR Manager corrects an employee's time log? How is auditability maintained?
**Answer:**
The application strictly prohibits silent overwriting of historical records.
When an HR Manager corrects a log:
1. The HR Manager must provide a mandatory **Correction Reason**.
2. An immutable record is created in the `time_log_audit` table saving:
   - Reference to the `time_log_id`.
   - The reviewing HR Manager (`corrected_by`).
   - Original values (`original_start_time`, `original_end_time`, `original_break_minutes`).
   - Corrected values (`corrected_start_time`, `corrected_end_time`, `corrected_break_minutes`).
   - Justification (`correction_reason`) and timestamp (`correction_timestamp`).
3. The original time log entry is updated with the new times, total minutes are recalculated, and the status changes from `SUBMITTED` to `CORRECTED`.
4. Anyone inspecting the log can click **"View Audit Trail"** to review the exact modification history.

---

### Q8: How are conflicting or overlapping leave requests prevented?
**Answer:**
In `TimeOffService.submitRequest()`:
1. We validate that `endDate >= startDate`.
2. We query the database using `TimeOffRequestRepository.findOverlappingApprovedRequests(...)`.
   - The mathematical condition for interval $[A_1, A_2]$ overlapping $[B_1, B_2]$ is:
     $$\text{StartDate} \le B_2 \quad \text{AND} \quad \text{EndDate} \ge B_1$$
3. If an overlapping approved or pending leave exists for that employee, the application rejects the submission with a clear explanation.

---

### Q9: Why use Thymeleaf instead of a separate React or Angular frontend?
**Answer:**
1. **Natural Templating**: Thymeleaf templates are valid HTML5 files that can be opened and styled in any browser without running a server.
2. **Unified Java Tech Stack**: Keeps the application lightweight, eliminating the overhead of managing `npm`, Webpack/Vite build pipelines, CORS policies, or JWT token refresh lifecycles.
3. **Seamless Spring Integration**: Direct binding with Spring MVC models, Form validation errors (`#fields.hasErrors`), and Spring Security expressions (`sec:authentication`, `#authorization.expression`).
4. **Ideal for Viva Demonstrations**: Clean and straightforward to package and run as a single executable JAR.

---

### Q10: How does your application protect against SQL Injection and Cross-Site Request Forgery (CSRF)?
**Answer:**
- **SQL Injection**: We use Spring Data JPA and Hibernate. Queries use parameterized statements (e.g. `:employeeId`, `:startDate`) or criteria queries where user inputs are safely escaped and bound as parameters, completely neutralizing SQL injection vectors.
- **CSRF Protection**: Spring Security enables CSRF tokens by default. Every POST form rendered by Thymeleaf includes a hidden `_csrf` token parameter. Any unauthorized external cross-site request lacking the matching token is immediately rejected with HTTP 403.

---

### Q11: What is the purpose of the `@Transactional` annotation in your service methods?
**Answer:**
The `@Transactional` annotation ensures **ACID** properties (Atomicity, Consistency, Isolation, Durability) for database operations:
- For example, when HR corrects a time log, both the update to `time_logs` and the insert into `time_log_audit` must succeed together.
- If an exception occurs halfway through, Spring automatically rolls back the transaction, preventing partial or inconsistent data states.

---

### Q12: How do you support running the project without a running MySQL server?
**Answer:**
We created a separate Spring profile (`application-demo.properties`) that configures an **in-memory H2 database** in MySQL compatibility mode.
By executing:
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=demo
```
The application spins up an embedded database, runs `DataInitializer` to seed the HR and Employee accounts, schedules, time logs, and leave requests in memory. This ensures the viva presentation can be performed reliably anywhere.
