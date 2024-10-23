# Medical Test Management System

## Project Overview
This project is a **shell scripting application** designed to manage and retrieve patient medical test records efficiently. It acts as a simple **Medical Test Management System** where users can **add, update, delete**, and **retrieve** medical test results stored in a text file. The system also offers data validation, error handling, and the ability to calculate average test values.

### Features
1. **Add New Medical Test Record**:
   - Allows the user to add a new medical test for a patient.
   - The system validates inputs, ensuring that the entered test data is in the correct format.

2. **Search for a Test by Patient ID**:
   - Retrieve all tests for a specific patient.
   - Retrieve tests based on:
     - Abnormal results.
     - A specific period (given by date).
     - Test status (e.g., "Pending", "Completed", "Reviewed").

3. **Search for Abnormal Tests**:
   - Retrieves all abnormal tests based on the medical test's normal range from the test description file.

4. **Calculate Average Test Values**:
   - Calculates the average value of each test across all patients.

5. **Update Test Result**:
   - Allows updating the result of an existing medical test.

6. **File Input/Output**:
   - Medical test records are stored in a text file named `medicalRecord.txt`.
   - Another file `medicalTest.txt` stores information about each type of test (name, range, unit).

7. **Error Handling**:
   - Handles errors like missing files, invalid inputs, and non-existent patients or tests.
   - Validates input data such as patient ID (7 digits), test result (floating-point value), and status (valid predefined statuses).

8. **Data Validation**:
   - Ensures correct data types are entered (e.g., integers for patient ID, valid dates in `YYYY-MM` format).
   - Handles invalid data gracefully, ensuring system stability.
  
### System Functionality
1. **Main Menu**:
   - A text-based menu allows the user to interact with the system by selecting options to add, search, update, or calculate test data.
   
2. **Add a New Medical Test**:
   - Enter the patient's ID, test name, test date (in `YYYY-MM` format), result, and status.
   - The system validates the inputs and ensures that they conform to the correct data type and format.

3. **Search for a Patient’s Tests**:
   - Search by patient ID to retrieve:
     - All test results.
     - All abnormal test results.
     - Tests from a specific period.
     - Tests based on a specific status.

4. **Search for Abnormal Tests**:
   - Retrieve all tests with results outside the normal range for a specific test type.

5. **Calculate Average Test Values**:
   - Display the average result value for each medical test type, calculated across all patients.

6. **Update a Medical Test**:
   - Update the test result for a specific patient and test.

### Technologies
- **Language**: Shell Scripting
- **Tools**: Bash, Linux utilities (`grep`, `sed`, `awk`, `read`, etc.)
  
### How to Use
1. **Run the Program**:
   - Open a terminal and navigate to the directory containing the script and data files.
   - Use the command below to run the script:
     ```bash
     ./medical_test_management.sh
     ```

2. **File Preparation**:
   - Ensure that the `medicalRecord.txt` file contains the medical test records.
   - Ensure that the `medicalTest.txt` file contains the test descriptions and ranges.

3. **Menu Options**:
   - The menu will prompt you to choose between options like adding a new test, searching for test data, updating existing records, or calculating average test values.
Following the instructions, the user can manage patient medical tests efficiently.

### Error Handling
- **Invalid File Names**: If the file cannot be found, the system will prompt the user with an error message and ask for a valid file name.
- **Invalid Data Entries**: The system will check for valid data types (e.g., integers for IDs, valid date formats) and reject invalid inputs.
- **Non-Existent Records**: If a patient or test is not found, the system will handle it gracefully and display appropriate messages.

