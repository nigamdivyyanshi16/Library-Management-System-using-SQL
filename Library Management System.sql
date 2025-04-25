create database Library_management_system;
use Library_management_system;
/*tables*/
-- Library System Management SQL Project

-- CREATE DATABASE library;

-- Create table "Branch"
DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);

-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);

-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);
-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

/* TO ADD FOREIGN KEY AFTERWARDS*/
/*ALTER TABLE TABLE_NAME
/*ADD CONSTRAINT CN_NAME
FOREIGN KEY () REFERENCES TABLE()*/
select count(*) from books;
select * from issued_status;
-- Project TASK
-- ### 2. CRUD Operations
-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books
(isbn,book_title,category,rental_price,status,author,publisher)
values
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
-- Task 2: Update an Existing Member's Address
select * from members;
update members
set member_address="127 Main St"
where member_id="C101";

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.
select * from issued_status;
Delete from issued_status
where issued_id = 'IS104';
/* as there is no record of this, we are deleting it, however others cant be deleted as they are referenced "foreign key"*/
-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
select issued_emp_id,issued_book_name from issued_status
where issued_emp_id="E101";
-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.
select  issued_member_id , count(issued_id) as "book_count"
from issued_status 
group by issued_member_id
having count(issued_id)>1;
-- ### 3. CTAS (Create Table As Select)
-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
/*creating table will help it to automate everytime a new book is issued, or make it dynamic and it get stores in the database*/
create table books_cnt
as
select books.isbn,books.book_title,
count(issued_status.issued_id)
from books
join issued_status 
on books.isbn=issued_status.issued_book_isbn
group by 1,2;

select * from books_cnt;
/*inside this table there are some logics stored, that even if it gets deleted it will remain accessible*/
-- ### 4. Data Analysis & Findings
-- Task 7. **Retrieve All Books in a Specific Category:
select category, count(distinct isbn)
from books
group by category;
/*specific category*/
select category, count(distinct isbn)
from books
group by category
having category="Classic";
-- Task 8: Find Total Rental Income by Category:
select category, sum(rental_price)
from books
group by category;
/* so as books is just showing rental price of each category wise books, but issued_status table shows how many times issued to calculate total rental income*/
select books.category,sum(books.rental_price),count(*)
from books
join 
issued_status
on books.isbn=issued_status.issued_book_isbn
group by books.category;
-- Task 9. **List Members Who Registered in the Last 180 Days**:
select * from members
where reg_date>=date_sub(current_date(),interval 180 day);
-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:
select e1.emp_name,b.manager_id,e2.emp_name,b.branch_address,b.contact_no
from employees as e1
join branch  as b
on e1.branch_id=b.branch_id
join employees as e2
on e2.emp_id=b.manager_id;
select * from books;
-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD
create table books_rental_price_greater_7usd as 
select book_title,rental_price
from books
where rental_price>7.00;
-- Task 12: Retrieve the List of Books Not Yet Returned*/
select distinct issued_book_name
from issued_status
left join return_status
on issued_status.issued_id=return_status.issued_id
/*books that are returned have returned id */
where return_id is null;
/*
### Advanced SQL Operations

Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.


Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "available" when they are returned (based on entries in the return_status table).



Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.


Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.



Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.


Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    


Task 19: Stored Procedure
Objective: Create a stored procedure to manage the status of books in a library system.
    Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
    If a book is issued, the status should change to 'no'.
    If a book is returned, the status should change to 'yes'.

Task 20: Create Table As Select (CTAS)
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
*/