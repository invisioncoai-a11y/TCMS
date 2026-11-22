# Training Courses Management System
## Final Project Submission — Clean & Reproducible Distribution Package

---

## A. Project Overview

The **Training Courses Management System** is an enterprise-grade, three-tier web application designed for academic course management, faculty directory scheduling, trainee self-onboarding, cohort seat inventory management, and administrative analytics.

The system replaces legacy, unnormalized flat databases with a production-ready three-tier architecture:
1. **Database Tier:** Oracle Database 19c Enterprise Edition utilizing 3NF normalized tables, SecureFile CLOBs, domain constraints, B-Tree indexes, and modular PL/SQL packages with row-level pessimistic locking (`FOR UPDATE`) for atomic seat reservation.
2. **Backend Tier:** High-performance ASP.NET Core 8.0 Web API utilizing the official Oracle Managed Data Access driver (`Oracle.ManagedDataAccess.Core`), calling PL/SQL package procedures via `RefCursor` parameters directly. Features stateless JWT Bearer authentication, salted SHA-256 password hashing, and interactive Swagger/OpenAPI documentation.
3. **Frontend Tier:** Modern Angular 21 Single Page Application (SPA) with standalone components, reactive routing, functional route guards, responsive styling, and dynamic Chart.js analytics.

---

## B. Technology Stack

| Layer | Component | Specification |
|---|---|---|
| **Database** | Oracle Database 19c | Multitenant architecture (CDB/PDB), PL/SQL Packages, RefCursors, 3NF schema |
| **Backend** | ASP.NET Core 8.0 Web API | C# 12, .NET 8.0 SDK (`net8.0`), ODP.NET Managed Data Access, JWT Bearer Auth |
| **Frontend** | Angular 21 SPA | TypeScript 5.9, HTML5, CSS3, RxJS 7.8, Chart.js 4.6 |
| **API Docs** | Swashbuckle OpenAPI | Swagger UI 3.0 specification at `/swagger` |
| **Protocol** | REST / JSON | HTTP/HTTPS, Stateless JWT Bearer tokens |

---

## C. Required Tools & Prerequisites

Before deploying the project, ensure the following developer tools and runtimes are installed on the target machine:

1. **Oracle Database 19c Enterprise Edition** (or Oracle 19c Standard / XE / Free 23c)
2. **Oracle SQL Developer** (v21.x, v22.x, v23.x, or v26.x) or Oracle SQLcl
3. **Microsoft Visual Studio 2022** (v17.8 or later) with the **ASP.NET and web development** workload selected, OR **.NET 8.0 SDK** (v8.0.x or v10.x with net8.0 target support)
4. **Visual Studio Code** (recommended editor for Angular frontend)
5. **Node.js** (LTS v18.x, v20.x, v22.x, or v24.x) and **npm** (v9.x, v10.x, or v11.x)
6. **Git** (optional, for version control)

---

## D. Required Dependencies & Verified Versions

### 1. Backend NuGet Packages (`Backend/TrainingCourses.Api/TrainingCourses.Api.csproj`)
These packages are automatically restored during build:
- `Oracle.ManagedDataAccess.Core` — Version **23.6.0** (Official Oracle 19c/23c ADO.NET driver)
- `Microsoft.AspNetCore.Authentication.JwtBearer` — Version **8.0.4** (JWT Bearer authentication middleware)
- `System.IdentityModel.Tokens.Jwt` — Version **8.0.1** (JSON Web Token generation and validation)
- `Swashbuckle.AspNetCore` — Version **6.6.2** (Swagger OpenAPI documentation generator)

### 2. Frontend npm Packages (`Frontend/package.json`)
Installed via `npm install`:
- `@angular/core`, `@angular/common`, `@angular/router`, `@angular/forms`, `@angular/platform-browser` — Version **^21.2.0**
- `chart.js` — Version **^4.6.1** (Executive dashboard analytics charting)
- `rxjs` — Version **~7.8.0** (Reactive stream extensions)
- `tslib` — Version **^2.3.0** (TypeScript runtime library)
- `@angular/build`, `@angular/cli`, `@angular/compiler-cli` — Version **^21.2.1**
- `typescript` — Version **~5.9.2**

---

## E. Oracle Database Setup

All database creation scripts are located in the `Database/` directory. They contain no hardcoded file paths or machine-specific credentials and can be executed against any Oracle 19c Pluggable Database (PDB).

### Step 1: Open Oracle SQL Developer and Connect as DBA (SYS or SYSTEM)
Connect to your target Pluggable Database (e.g., `ORCLPDB` or your chosen PDB):
```sql
-- Switch session to your target Pluggable Database
ALTER SESSION SET CONTAINER = YOUR_PDB_NAME;
```

### Step 2: Create a Dedicated Application Schema User
Execute the following statements to create your application user and grant the required privileges:
```sql
-- Create application user (replace YOUR_APP_USER and your password)
CREATE USER YOUR_APP_USER IDENTIFIED BY "YourSecurePassword123!"
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;

-- Grant required developer privileges (packages, tables, views, sequences)
GRANT CONNECT, RESOURCE TO YOUR_APP_USER;
GRANT CREATE TABLE TO YOUR_APP_USER;
GRANT CREATE VIEW TO YOUR_APP_USER;
GRANT CREATE PROCEDURE TO YOUR_APP_USER;
GRANT CREATE SEQUENCE TO YOUR_APP_USER;
```

### Step 3: Connect to Oracle SQL Developer as the Application User
Create a new Connection in Oracle SQL Developer:
- **Connection Name:** `TrainingCourses_App`
- **Username:** `YOUR_APP_USER`
- **Password:** `YourSecurePassword123!`
- **Hostname:** `localhost` (or your database server IP)
- **Port:** `1521`
- **Service Name:** `YOUR_PDB_NAME`

### Step 4: Execute Database Scripts
Open and execute the scripts in the `Database/` directory in sequential order:

| Order | Script File | Purpose & Contents |
|---|---|---|
| **Option A** | [`00_setup_all.sql`](file:///A:/Final-Project/My-Work/TrainingCourses_Final_Submission/Database/00_setup_all.sql) | **Master Runner:** Executes all steps 1 through 10 in a single automated pass. |
| **1** | `00_preflight.sql` | Verifies connected user and container name. |
| **2** | `01_create_tables.sql` | Creates 7 normalized 3NF tables (`ADMINS`, `CATEGORIES`, `TRAINERS`, `COURSES`, `COURSEOFFERINGS`, `TRAINEES`, `REGISTRATIONS`) with identity columns and SecureFile CLOBs. |
| **3** | `02_constraints_indexes.sql` | Creates 7 Primary Keys, 5 Foreign Keys, 6 Unique constraints, 12 Domain CHECKs, and 31 B-Tree performance indexes. |
| **4** | `03_create_views.sql` | Compiles 11 multi-table join and reporting views. |
| **5** | `04_package_specs.sql` | Compiles 8 PL/SQL package specifications with `OUT SYS_REFCURSOR` signatures. |
| **6** | `05_package_bodies.sql` | Compiles 8 PL/SQL package bodies implementing atomic seat reservation with `SELECT ... FOR UPDATE` row locking. |
| **7** | `06_sample_data.sql` | Seeds initial sample categories (5), trainers (4), courses (5), course offerings (5), trainees (4), and registrations (8). |
| **8** | `07_database_tests.sql` | Runs 15-test automated validation suite (confirms constraints, packages, and atomic seat management). |
| **9** | `08_verify_database.sql` | Verifies data dictionary status (`USER_OBJECTS` and `USER_ERRORS` confirming 0 invalid objects). |
| **10** | `09_schema_inventory.sql` | Generates a complete object count and constraint audit. |

---

## F. Backend Setup — Visual Studio 2022

### Step 1: Open the Solution
1. Launch **Visual Studio 2022**.
2. Click **Open a project or solution** and select:
   `Backend/TrainingCourses.sln`
   *(Alternatively, open the folder in VS Code or Visual Studio).*

### Step 2: Configure Database Connection & JWT Settings
Open `Backend/TrainingCourses.Api/appsettings.json` (or copy from `appsettings.example.json`):
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "OracleDb": "Data Source=//localhost:1521/YOUR_PDB_NAME;User Id=YOUR_APP_USER;Password=YourSecurePassword123!;"
  },
  "Jwt": {
    "Key": "YourStrongSecretKeyMinimum32CharactersLong_Enterprise2026!",
    "Issuer": "TrainingCoursesApi",
    "Audience": "TrainingCoursesClient",
    "ExpiresHours": 24
  }
}
```
*Replace `YOUR_PDB_NAME`, `YOUR_APP_USER`, and `YourSecurePassword123!` with your actual Oracle connection settings.*

### Step 3: Restore NuGet Packages & Build
1. In Solution Explorer, right-click the solution and click **Restore NuGet Packages**.
2. Press `Ctrl + Shift + B` (or run `dotnet build` in terminal) to build the solution.
3. Confirm build succeeds with **0 warnings, 0 errors**.

### Step 4: Run the Web API
1. Set `TrainingCourses.Api` as the StartUp Project.
2. Select the `http` launch profile and press `Ctrl + F5` (Run Without Debugging) or `F5`.
3. The API will start on:
   - **Base URL:** `http://localhost:5000`
   - **Health Endpoint:** `http://localhost:5000/api/health` (returns `{"status":"Healthy", ...}`)
   - **Interactive Swagger UI:** `http://localhost:5000/swagger`

---

## G. Frontend Setup — Visual Studio Code

### Step 1: Open the Frontend Project
1. Launch **Visual Studio Code**.
2. Select **File > Open Folder...** and choose the `Frontend/` directory.

### Step 2: Install Node Dependencies
Open the integrated terminal in VS Code (`Ctrl + ~`) and run:
```bash
npm install
```
*(All required dependencies listed in `package.json` will be downloaded cleanly).*

### Step 3: Verify or Configure API Base URL
The API base URL is defined in `Frontend/src/app/services/api.service.ts`:
```typescript
private readonly baseUrl = 'http://localhost:5000/api';
```
Ensure this matches the port where your ASP.NET Core API is running (`http://localhost:5000/api`).

### Step 4: Start the Angular Application
In the terminal, run:
```bash
npm start
# or: npx ng serve --port 4200
```
Open your browser and navigate to:
**`http://localhost:4200`**

---

## H. Initial Administrator Account Setup

The application uses salted SHA-256 password hashing implemented in `AuthService.cs`:
$$\text{PasswordHash} = \text{SHA256}(\text{Password} \parallel \text{":"} \parallel \text{PasswordSalt})$$
where `PasswordSalt` is a unique 32-character hexadecimal string (`Guid.NewGuid().ToString("N")`).

To create your own secure initial administrator account on a fresh database:

### Method 1: Using PowerShell
Run the following script in PowerShell to generate your unique salt, hash, and SQL insert statement:
```powershell
$username = "admin"
$password = "YourSecurePassword123!"  # Replace with your desired password
$email    = "admin@example.com"
$fullName = "System Administrator"

# Generate 32-character GUID salt
$salt = [System.Guid]::NewGuid().ToString("N")

# Compute SHA-256 hash of password:salt
$combined = [System.Text.Encoding]::UTF8.GetBytes("$password:$salt")
$hashBytes = [System.Security.Cryptography.SHA256]::Create().ComputeHash($combined)
$hash = -join ($hashBytes | ForEach-Object { $_.ToString("x2") })

# Output the SQL insert statement
Write-Host "Execute this SQL in Oracle SQL Developer under your application schema:"
Write-Host "INSERT INTO ADMINS (Username, PasswordHash, PasswordSalt, Email, FullName, IsActive)"
Write-Host "VALUES ('$username', '$hash', '$salt', '$email', '$fullName', 1);"
Write-Host "COMMIT;"
```

### Method 2: Using Python
```python
import uuid, hashlib

username = "admin"
password = "YourSecurePassword123!"  # Replace with your desired password
email    = "admin@example.com"
fullName = "System Administrator"

salt = uuid.uuid4().hex
hash_val = hashlib.sha256(f"{password}:{salt}".encode('utf-8')).hexdigest().lower()

print(f"""
INSERT INTO ADMINS (Username, PasswordHash, PasswordSalt, Email, FullName, IsActive)
VALUES ('{username}', '{hash_val}', '{salt}', '{email}', '{fullName}', 1);
COMMIT;
""")
```
Execute the resulting `INSERT` statement in Oracle SQL Developer, and you can immediately log in via Swagger (`POST /api/Auth/login`) or the Angular Admin Portal (`http://localhost:4200/admin/login`).

---

## I. Quick Start Execution Order

1. **Start Oracle Database 19c:** Ensure Oracle service and TNS listener are running.
2. **Deploy Database Schema:** Open Oracle SQL Developer as your application user, open `Database/00_setup_all.sql`, and press `F5`.
3. **Start ASP.NET Core API:**
   ```bash
   cd Backend/TrainingCourses.Api
   dotnet run --launch-profile "http"
   ```
   Confirm `http://localhost:5000/swagger` is accessible.
4. **Start Angular Frontend:**
   ```bash
   cd Frontend
   npm install
   npm start
   ```
   Open `http://localhost:4200` in your browser.

---

## J. Troubleshooting

| Symptom / Error | Probable Cause | Recommended Resolution |
|---|---|---|
| **ORA-12541: TNS:no listener** | Oracle Listener service is stopped. | Open Windows Services (`services.msc`), locate `OracleOraDB19Home3TNSListener` (or your listener name), and click **Start**. Alternatively, run `lsnrctl start` in cmd. |
| **ORA-01017: invalid username/password** | Incorrect credentials in `appsettings.json`. | Verify that `User Id` and `Password` in `ConnectionStrings:OracleDb` match your Oracle user. |
| **ORA-12514: TNS:listener does not currently know of service** | Pluggable Database (PDB) is closed or service name is wrong. | Connect as `SYSDBA` in SQL*Plus and run: `ALTER PLUGGABLE DATABASE ALL OPEN;`. Check service name with `lsnrctl status`. |
| **HTTP 500 on API Requests** | Database connection failed or packages not compiled. | Check API terminal console logs. Verify database connectivity by running `Database/08_verify_database.sql` in SQL Developer to ensure 0 invalid objects. |
| **CORS Policy Error in Browser Console** | Backend does not allow frontend origin. | Ensure the frontend port (`http://localhost:4200`) is listed in `AddCors` in `Backend/TrainingCourses.Api/Program.cs`. |
| **Port 5000 or Port 4200 in Use** | Another process is holding the port. | In PowerShell, run `Get-NetTCPConnection -LocalPort 5000` to find the process ID, and stop it. For Angular, use `npx ng serve --port 4201`. |
| **npm install fails with peer dependency errors** | npm strict peer dependency check. | Run `npm install --legacy-peer-deps` or use Node LTS v20+. |
| **Visual Studio NuGet Restore fails** | Missing package source or network offline. | In Visual Studio, go to **Tools > NuGet Package Manager > Package Manager Settings > Package Sources**, and ensure `nuget.org` (`https://api.nuget.org/v3/index.json`) is enabled. |
