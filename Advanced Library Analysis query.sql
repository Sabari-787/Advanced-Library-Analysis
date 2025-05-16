--- Create a Database
create database sql_project_p2_part2_advanced_library_analysis;

--- Task 1: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.

select m.member_id, m.member_name, b.book_title, ist.issued_date, DATEDIFF(current_date(),issued_date)-30 as overdue_days from 
issued_status ist 
inner join members m on ist.issued_member_id = m.member_id
inner join books b on b.isbn=ist.issued_book_isbn 
left join return_status rst on rst.issued_id = ist.issued_id
where DATEDIFF(current_date(),issued_date)-30 > 0 order by 5 desc;

--- Task 2: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" 
-- when they are returned (based on entries in the return_status table).
DELIMITER //
CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    -- Insert into return_status
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURDATE(), p_book_quality);

    -- Get book ISBN and name from issued_status
    SELECT issued_book_isbn, issued_book_name
    -- storing into variables
    INTO v_isbn, v_book_name
    --          --
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Update book status in books table
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    -- Display message
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;

END //

DELIMITER ;


-- Testing FUNCTION add_return_records

-- issued_id = IS135
-- ISBN = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');


--- Task 3: Branch Performance Report
--  Create a query that generates a performance report for each 
--  branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
create table branch_report as
select 
b.branch_id,
b.manager_id,
count(ist.issued_book_isbn) as issued,
count(rst.return_date) as returned,
sum(bk.rental_price) as Total_revenue
 from 
issued_status ist 
join employees e on ist.issued_emp_id=e.emp_id 
join branch b on e.branch_id=b.branch_id 
join books bk on bk.isbn = ist.issued_book_isbn
left join return_status rst on rst.issued_id = ist.issued_id
group by 1,2;

select * from branch_report;

--- Task 4: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to 
-- create a new table active_members containing members who have issued at least one book in the last 2 months.

create table active_members as
select * from members
where member_id in ( select distinct issued_member_id from issued_status where issued_date >= curdate()-interval 6 month);

--- Task 5: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branch.

select emp_name, count(ist.issued_id) as issued_books , b.*
from
employees e join issued_status ist on ist.issued_emp_id = e.emp_id
join branch b on e.branch_id=b.branch_id group by emp_name , 3 order by 2 desc limit 3;

--- Task 18: Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued books with "damaged" in the books table. 
-- Display the member name, book title, and the issued damaged books.

select m.member_name, b.book_title, book_quality from
issued_status ist join 
books b on ist.issued_book_isbn = b.isbn join 
members m on m.member_id = issued_member_id join
return_status rst on rst.issued_id = ist.issued_id
where book_quality = 'Damaged';

---