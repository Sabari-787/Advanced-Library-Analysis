
# 📚 Advanced Library Analysis using SQL – Project P2 Part 2 💻

## 📖 Project Overview
This project focuses on advanced database operations in a Library Management System using SQL. You’ll explore powerful SQL concepts including stored procedures, conditional logic, and performance reporting through a series of structured tasks.

---

## 🎯 Objectives
- 🚀 Create and manipulate a comprehensive SQL database.
- 📌 Practice advanced SQL queries for real-world scenarios.
- 🧠 Understand and implement stored procedures.
- 📊 Generate reports and analyze performance.
- ✅ Learn how to handle book returns and overdue calculations.

---

## 🛠️ How to Use This Project
1. Make sure you have access to a SQL database (like MySQL or PostgreSQL).
2. Execute each task step-by-step.
3. Observe how data manipulates through CRUD operations and procedures.
4. Customize or expand based on your learning!

---

## 📂 Project Tasks

### 🏗️ Create a Database

```sql
create database sql_project_p2_part2_advanced_library_analysis;
```

---

### 🕵️ Task 1: Identify Members with Overdue Books

```sql
select m.member_id, m.member_name, b.book_title, ist.issued_date, DATEDIFF(current_date(),issued_date)-30 as overdue_days from 
issued_status ist 
inner join members m on ist.issued_member_id = m.member_id
inner join books b on b.isbn=ist.issued_book_isbn 
left join return_status rst on rst.issued_id = ist.issued_id
where DATEDIFF(current_date(),issued_date)-30 > 0 order by 5 desc;
```

---

### 🔁 Task 2: Update Book Status on Return

```sql
DELIMITER //
CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURDATE(), p_book_quality);

    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;

END //
DELIMITER ;
```

---

### 📈 Task 3: Branch Performance Report

```sql
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
```

---

### 📊 Task 4: CTAS - Active Members Table

```sql
create table active_members as
select * from members
where member_id in ( select distinct issued_member_id from issued_status where issued_date >= curdate()-interval 6 month);
```

---

### 🧾 Task 5: Top 3 Employees by Book Issues

```sql
select emp_name, count(ist.issued_id) as issued_books , b.*
from
employees e join issued_status ist on ist.issued_emp_id = e.emp_id
join branch b on e.branch_id=b.branch_id group by emp_name , 3 order by 2 desc limit 3;
```

---

### 📚 Task 6: Members Issuing Damaged Books

```sql
select m.member_name, b.book_title, book_quality from
issued_status ist join 
books b on ist.issued_book_isbn = b.isbn join 
members m on m.member_id = issued_member_id join
return_status rst on rst.issued_id = ist.issued_id
where book_quality = 'Damaged';
```

---

### 🧠 Task 7: Book Issuance Procedure

```sql
DELIMITER //
CREATE PROCEDURE issue_book(p_issued_id varchar(10), p_issued_member_id varchar(30), p_issued_book_isbn varchar(30), p_issued_emp_id varchar(10))

Begin 
  Declare
  v_status varchar(10);
  
  select 
  status
  into 
  v_status
  from books where isbn = p_issued_book_isbn;
 
  IF v_status = 'yes' Then
	   insert into issued_status
					   (issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id) 
                 values(p_issued_id, p_issued_member_id, curdate(),p_issued_book_isbn,p_issued_emp_id);
	   update books set status = 'No' where isbn = p_issued_book_isbn;
	   SELECT CONCAT('Book Record Added Successfully for book isbn:', p_issued_book_isbn) AS message;
  ELSE 
	   SELECT CONCAT('Sorry the book is unavailable for isbn ', p_issued_book_isbn) AS message;
  END IF;
 
End;
// 
DELIMITER ;
```

---

### 💰 Task 8: Overdue Books and Fines Report

```sql
select m.member_id,m.member_name,sum((DATEDIFF(current_date(),issued_date)-30) * 0.50) as fine from 
issued_status ist 
inner join members m on ist.issued_member_id = m.member_id
inner join books b on b.isbn=ist.issued_book_isbn 
left join return_status rst on rst.issued_id = ist.issued_id
where DATEDIFF(current_date(),issued_date)-30 > 0 
group by 1 order by 1 asc ;
```

---

## 🎉 Conclusion

By completing this advanced SQL project, you have learned:

- 🔄 How to manage and automate updates using stored procedures.
- 📦 How to generate performance insights through reports.
- 🔍 How to find overdue book records and calculate penalties.
- 🧰 Mastery of SQL tools like CTAS, joins, grouping, and more!

Keep exploring and building! 🌟🚀📚💡
