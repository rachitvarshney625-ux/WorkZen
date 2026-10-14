# COLLEGE PROJECT REPORT
# EMPLOYEE TIME MANAGEMENT SYSTEM
## Enterprise Full-Stack Web Application

---

## 1. Abstract

In contemporary enterprise and institutional settings, workforce attendance tracking, shift scheduling, and time-off administration are vital to operational productivity, labor compliance, and payroll accuracy. Traditional manual processes—such as paper-based log sheets and unmonitored spreadsheets—are notoriously error-prone, vulnerable to unauthorized manipulation, lack audit trails, and present significant managerial bottlenecks.

The **Employee Time Management System** is a robust, responsive, and secure Java Full-Stack web application engineered using **Spring Boot 3**, **Spring Data JPA**, **Spring Security**, **Thymeleaf**, **Bootstrap 5**, **Chart.js**, and **MySQL 8.x**. The system delivers a role-based environment catering to two distinct stakeholders: **HR Managers** and **Employees**. 

Employees can record daily working hours with automated net duration calculations, review personal attendance history, submit time-off requests with conflict prevention, and monitor assigned weekly shift schedules. HR Managers possess comprehensive administrative capabilities: managing workforce rosters, approving or rejecting leave requests with managerial decision notes, planning employee schedules, executing auditable time-log corrections with mandatory justification logs, and analyzing workforce metrics through interactive charts and filtered CSV data exports.

---

## 2. Objectives and Scope

### 2.1 Project Objectives
1. **Automate Attendance & Shift Tracking**: Replace manual paper logs with an automated digital logging portal.
2. **Eliminate Scheduling Conflicts**: Prevent overlapping leave requests and conflicting shifts using automated server-side validations.
3. **Enforce Role-Based Access Control (RBAC)**: Ensure strict authorization boundaries using Spring Security so that employees cannot access managerial portals or tamper with other employees' records.
4. **Establish Audit Integrity**: Guarantee that any managerial correction made to an employee's submitted time log generates an immutable historical audit record.
5. **Provide Data-Driven Dashboards**: Offer visual workforce analytics via Chart.js charts and summary metrics calculated directly from relational database records.
6. **Ensure Intermediate-Level Viva Readiness**: Maintain a clean, maintainable MVC architecture that an intermediate Java student can easily understand, run, demonstrate, and defend in a viva examination.

### 2.2 Project Scope
- **In-Scope**:
  - Secure authentication with BCrypt password hashing and session management.
  - Role-based dashboard redirection (`ROLE_HR_MANAGER` to `/hr/dashboard`, `ROLE_EMPLOYEE` to `/employee/dashboard`).
  - Employee daily time-log submission with overnight shift policy support.
  - Single submission enforcement (one log per employee per date).
  - Time-off application with date validation and conflict rejection.
  - HR review and approval/rejection workflow with decision feedback notes.
  - Shift planning with start/end times or designated rest days.
  - HR time log correction with mandatory audit reasoning stored in a dedicated audit table.
  - Analytical reports with date/employee filtering and CSV data export.
  - Comprehensive unit and integration test suite using JUnit 5 and Spring Boot Test.
  - Standalone in-memory H2 demo profile for viva presentations where MySQL is unavailable.
- **Out-of-Scope (Future Enhancements)**:
  - Biometric hardware reader integration (facial recognition/fingerprint scanners).
  - External payroll gateway disbursement (e.g. Stripe, Razorpay).
  - Native mobile application (iOS/Android) — the responsive Bootstrap web UI satisfies mobile browser access.

---

## 3. Requirements Specification

### 3.1 Functional Requirements
- **FR1: User Authentication & Authorization**: Users authenticate via email and password. Passwords must never be stored in plain text. Spring Security handles session management and enforces access rules.
- **FR2: Time Logging & Shift Calculations**: Employees submit daily work times specifying start time, end time, and break duration. The server calculates net duration (`Gross - Break`). Overnight shifts (spanning across midnight) are automatically recognized and calculated.
- **FR3: Duplicate Submission Prevention**: The system enforces a unique database constraint `(employee_id, work_date)` ensuring an employee can only submit one time log per calendar date.
- **FR4: Time-Off Management**: Employees submit leave requests with start date, end date, and reason. The system blocks requests if the end date is before the start date or if the requested range overlaps with an existing approved or pending leave.
- **FR5: HR Decision Workflow**: HR Managers review pending leave requests. Once approved or rejected, the status is finalized, and a decision note and reviewer timestamp are recorded.
- **FR6: Shift Scheduling**: HR Managers assign work shifts or designate days off for employees. Duplicate schedules on the same day for an employee are prevented.
- **FR7: Auditable Time Log Corrections**: HR Managers can correct employee punch times. A mandatory reason must be provided. The original and corrected values, manager ID, and timestamp are committed to `time_log_audit`.
- **FR8: Analytics & Data Export**: The HR dashboard displays three Chart.js visual graphs. The reports module supports filtering by employee, date range, and report category with instant CSV generation.

### 3.2 Non-Functional Requirements
- **Security**: BCrypt encryption (cost factor 10), protection against SQL Injection via parameterized JPA queries, Cross-Site Request Forgery (CSRF) protection on forms, and prevention of sensitive stack trace leakage.
- **Performance**: Sub-second page load times utilizing indexed foreign keys and database columns (`email`, `work_date`, `status`).
- **Usability**: Responsive Bootstrap 5 UI themed with navy slate navigation, intuitive icons, interactive password toggles, and live client-side duration previews.
- **Maintainability**: Layered separation of concerns (Controller $\rightarrow$ Service $\rightarrow$ Repository $\rightarrow$ Database).
- **Portability**: Runs on any operating system supporting Java 17+ (Windows, macOS, Linux).

---

## 4. System Architecture and Design

The system implements the classic **Model-View-Controller (MVC)** architectural pattern:

```
[ Web Browser / Client ]
           │
           │  HTTP GET / POST (HTML, Forms, CSRF)
           ▼
[ Spring Security Filter Chain ]  <── Authentication & Role Verification
           │
           ▼
[ Spring MVC Controllers ]  <─────── Receives requests, maps DTOs, returns Thymeleaf Views
           │
           ▼
[ Service Layer ]  <──────────────── Core Business Logic, Calculations & Validations
           │
           ▼
[ Spring Data JPA Repositories ]  <─ Data Access Object (DAO) Abstraction
           │
           ▼
[ Hibernate ORM ]
           │
           ▼
[ MySQL 8.x / H2 Relational Database ]
```

### Architectural Tiers:
1. **Presentation Tier (Thymeleaf + Bootstrap 5 + JS)**: Server-side rendering generates standard HTML5 markup enriched with dynamic model data and CSRF tokens.
2. **Security Tier (Spring Security 6)**: Intercepts all incoming HTTP requests, verifies session cookies, validates credentials against `CustomUserDetailsService`, and guards routes according to authorities.
3. **Application / Controller Tier (Spring MVC)**: Dispatches requests to controller endpoints, triggers Bean Validation annotations, and attaches flash attributes for user feedback.
4. **Business Logic Tier (Services)**: Encapsulates transactional business logic (`@Transactional`), shift calculation algorithms, overlap detection, and audit logging.
5. **Persistence Tier (Spring Data JPA & Hibernate)**: Maps Java entities to MySQL relational tables and provides type-safe queries.

---

## 5. User Workflows

### 5.1 Employee Workflow
```
[ Login ] ──> [ Employee Dashboard ]
                     │
     ┌───────────────┼───────────────┐
     ▼               ▼               ▼
[ Log Hours ]   [ Request Leave ] [ View Schedule ]
  - Enter times   - Select dates    - Weekly calendar
  - Live preview  - Check overlap   - View shifts & days off
  - Save to DB    - Submit pending
```

### 5.2 HR Manager Workflow
```
[ Login ] ──> [ HR Operations Dashboard ] (KPI Cards & Charts)
                     │
     ┌───────────────┼───────────────┬───────────────┐
     ▼               ▼               ▼               ▼
[ Employees ]  [ Time-Off ]     [ Schedules ]   [ Time Logs & Audit ]
 - Register     - Filter status  - Assign shift  - Review logs
 - View list    - Approve/Reject - Assign day-off- Correct log with reason
                - Add note       - Edit/Delete   - View audit trail history
```

---

## 6. Database Schema & Relational Design

The system is backed by 5 normalized tables in the `employee_time_management` database:

```
┌────────────────────────┐         1:N         ┌────────────────────────┐
│         users          │────────────────────<│       time_logs        │
├────────────────────────┤                     ├────────────────────────┤
│ id (PK)                │                     │ id (PK)                │
│ full_name              │                     │ employee_id (FK)       │
│ email (UQ)             │                     │ work_date              │
│ password_hash          │                     │ start_time, end_time   │
│ role                   │                     │ break_minutes          │
│ enabled                │                     │ total_working_minutes  │
│ created_at, updated_at │                     │ status, notes          │
└────────────────────────┘                     └────────────────────────┘
     │            │                                         │ 1
     │ 1:N        │ 1:N                                     │
     │            │                                         │ 1:N
     │            ▼                                         ▼
     │   ┌────────────────────────┐            ┌────────────────────────┐
     │   │   employee_schedules   │            │    time_log_audit      │
     │   ├────────────────────────┤            ├────────────────────────┤
     │   │ id (PK)                │            │ id (PK)                │
     │   │ employee_id (FK)       │            │ time_log_id (FK)       │
     │   │ work_date              │            │ corrected_by (FK)      │
     │   │ shift_start_time       │            │ correction_reason      │
     │   │ shift_end_time         │            │ original_start_time    │
     │   │ day_off                │            │ original_end_time      │
     │   │ notes                  │            │ original_break_minutes │
     │   └────────────────────────┘            │ corrected_start_time   │
     ▼                                         │ corrected_end_time     │
┌────────────────────────┐                     │ corrected_break_minutes│
│   time_off_requests    │                     │ correction_timestamp   │
├────────────────────────┤                     └────────────────────────┘
│ id (PK)                │
│ employee_id (FK)       │
│ start_date, end_date   │
│ reason, status         │
│ decision_note          │
│ reviewed_by (FK)       │
│ submitted_at           │
│ reviewed_at            │
└────────────────────────┘
```

---

## 7. Verification and Testing Results

### 7.1 Automated Unit & Integration Tests
1. **`TimeLogCalculationTest`**:
   - `testRegularShiftCalculation`: 09:00 to 17:30 with 45m break computes to 465 net minutes (7.75 hours) $\rightarrow$ **PASS**.
   - `testOvernightShiftCalculation`: 22:00 to 06:00 with 60m break computes to 420 net minutes (7.0 hours) across midnight $\rightarrow$ **PASS**.
   - `testBreakExceedingShiftThrowsException`: Break duration $\ge$ shift duration triggers `BusinessValidationException` $\rightarrow$ **PASS**.
   - `testNegativeBreakThrowsException`: Negative break duration triggers `BusinessValidationException` $\rightarrow$ **PASS**.
2. **`TimeLogServiceTest`**:
   - `testDuplicateTimeLogSubmission`: Verified that attempting to insert a second log for the same employee and date is blocked $\rightarrow$ **PASS**.
   - `testCorrectTimeLogWithAudit`: Verified that HR correction updates log status to `CORRECTED` and generates an audit log record with previous and new values $\rightarrow$ **PASS**.
3. **`TimeOffServiceTest`**:
   - `testEndDateBeforeStartDate`: Rejects invalid date intervals $\rightarrow$ **PASS**.
   - `testOverlappingApprovedLeave`: Blocks leave overlapping with existing approved periods $\rightarrow$ **PASS**.
   - `testApprovePendingRequest`: Successfully updates status to `APPROVED` and records reviewer info $\rightarrow$ **PASS**.
   - `testPreventReDecidingRequest`: Blocks secondary modification of already finalized requests $\rightarrow$ **PASS**.
4. **`SecurityAndAccessTest`**:
   - Verified unauthenticated visitors are redirected to `/login` $\rightarrow$ **PASS**.
   - Verified employees attempting to visit `/hr/dashboard` receive HTTP 403 Forbidden $\rightarrow$ **PASS**.
   - Verified authenticated HR managers and Employees can access their designated dashboards $\rightarrow$ **PASS**.

---

## 8. Conclusion and Future Work

The **Employee Time Management System** fulfills all requirements for a complete, functional, and responsive enterprise web application. By leveraging modern Spring Boot 3 standards, robust relational constraints, and a secure layered architecture, the application eliminates manual record-keeping errors, enforces role-based boundaries, and guarantees auditing compliance. The clean design and thorough documentation make the project an exemplary showcase for academic demonstration and viva evaluations.
