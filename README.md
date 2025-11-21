# Government Executive Projects Tracker

**GovExec Tracker** is a comprehensive Database Management System designed to streamline the monitoring and execution of government infrastructure projects.

##  Course Details
### Database Management Systems - UE23CS351A

---

## Team Members

Sudiksha Chindula - PES1UG23CS902  

Yatin Prabhakar - PES1UG23CS719

---

## Project Overview

### Problem Statement
Government Executive projects (e.g., road construction, sewage management, infrastructure construction) are often mismanaged and delayed beyond reasonable timelines. These projects are frequently executed in a haphazard manner with sub-optimal planning, causing great inconvenience to daily life. This mismanagement is often coupled with susceptibility to corruption. The quality of these projects and their timely completion remain a grave concern among taxpayers and citizens.

### Our Solution
We propose a publicly visible and accessible **Project Tracker** that monitors the progress of these projects alongside employee accountability.

**Key Features:**
* **Transparency:** Displays details of projects, contractors, employees, task updates, and costs.
* **Citizen Engagement:** Provides citizens with the option to raise tickets regarding concerns about specific projects.
* **Role-Based Access Control (RBAC):** Distinct portals for Admins, Government Employees, and Citizens.
* **Advanced DBMS Concepts:** Demonstrates the use of Stored Procedures, Triggers, Functions, and Complex Joins.

---

## Prerequisites

Before running the application, ensure you have the following installed:
* **Python 3.x**
* **MySQL Server** (running locally)

---

##  Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/sudiksha-chindula/gov-exec-tracker
cd gov-exec-tracker
```

### 2. Setup virtual environment
```bash
python -m venv .venv #create environment
.venv\Scripts\activate #activate the venv
```

### 3. Install dependencies
```bash
pip install -r requirements.txt
```

### 4. Run the server
```bash
flask run
```

The server should provide a link to access the web application
