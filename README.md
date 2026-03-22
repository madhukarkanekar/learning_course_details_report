# Oracle HCM Learning Course Details Report

This repository contains a SQL report developed in Oracle Fusion HCM to extract detailed Learning course assignment and completion information.

The report retrieves employee, assignment, organization, manager, and learning item details from Oracle Learning Cloud tables.

## Features

- Employee details (Person Number, Name, Email)
- Legal Employer, Business Unit, Department, Location
- Job, Job Family, Job Function, Contributor Type
- Course Name, Course Number, Learning Item ID
- Course Status, Reason Code, Comments
- Assigned Date, Completion Date, Due Date, Expiration Date
- Line Manager and Matrix Manager details
- Platform, Business Group, World Area mapping
- Supports parameter filtering

## Parameters

- Country
- Legal Employer
- Location
- Course Name
- Person Number
- Person Name
- World Area
- Business Group

## Tables Used

- WLF_LEARNING_ITEMS_F
- WLF_ASSIGNMENT_RECORDS_F
- PER_ALL_PEOPLE_F
- PER_ALL_ASSIGNMENTS_M
- PER_PERSON_NAMES_F
- PER_JOBS_F_VL
- PER_JOB_FAMILY_F_VL
- PER_LOCATION_DETAILS_F_VL
- FUN_ALL_BUSINESS_UNITS_V
- HR_ALL_ORGANIZATION_UNITS_F_VL
- FF_USER_TABLES_VL
- HZ_GEOGRAPHIES

## Use Case

Used for Learning compliance tracking, reporting, and audit purposes in Oracle Fusion HCM Learning module.
