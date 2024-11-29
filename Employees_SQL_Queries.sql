# What is the total amount spent on salaries for all contracts starting after the 1st Jan 1997---------
SELECT SUM(salary) FROM salaries
WHERE from_date > '1997-01-01';


# What is the Maximum salary that is disbursed from the company accounts?
SELECT MAX(salary) FROM salaries;


# What is the average annual salary paid to employees who started after the 1st Jan 1997?----------------------
SELECT AVG(salary) FROM salaries
WHERE from_date > '1997-01-01';


-- Handling NULL values in the rows of a column using IFNULL() function-------------------
SELECT 
    dept_no, 
    IFNULL(dept_name, "Department name not provided") as dept_name
FROM
    departments_duplicate
ORDER BY dept_no;


/*  Q. Select the department number and name from the 'departmets_duplicate' table and add a third column
where you name the department number ('dept_no') as 'dept_info'. If 'dept_no' does not have a value, use 'dept_name' 
*/

SELECT 
    dept_no, 
    dept_name,
    COALESCE(dept_no, dept_name) as dept_info
FROM
    departments_duplicate
ORDER BY dept_no;


/*	Join the 'employees' and the 'dept_manager' tables to return a subset of all the employees whose last name is Markovitch.
See if the output contains a manager with the name.
*/
SELECT e.emp_no, e.birth_date, e.first_name, e.last_name, e.gender, e.hire_date, dept_no
FROM employees e
LEFT JOIN dept_manager m
ON e.emp_no = m.emp_no
WHERE last_name ='Markovitch' and dept_no IS NOT NULL -- dept_no IS NOT NULL ==> give teh manager
ORDER BY dept_no DESC, emp_no;


/* we want to see the table containing the employee number and the first and last name of individuals whose annual 
remuneration has been more than 145000 dollars at a certain point in time
*/
SELECT 
	e.emp_no, e.first_name, e.last_name, s.salary
FROM employees e
INNER JOIN salaries s
ON e.emp_no = s.emp_no
WHERE s.salary > 145000
ORDER BY salary ;


/* CROSS JOIN is the cartesian product of the values in two or more tables*/
-- New Syntax-------
SELECT 
	dm.* , d.*
FROM dept_manager dm
CROSS JOIN departments d
ORDER BY dm.emp_no, d.dept_no;


/* Use a CROSS JOIN to return a list with all possible combinations between managers from the dept_manager
table and department number 9 */
SELECT 
	dm.emp_no, d.dept_no, d.dept_name
FROM dept_manager dm
CROSS JOIN departments d
WHERE d.dept_no ='d009';


# find the average salaries of men and women in the company #
SELECT 
	e.gender, AVG(salary) as average_salary
FROM employees e
JOIN salaries s
ON e.emp_no = s.emp_no
GROUP BY e.gender;


-- retreive the table containg the columns - first_name, last_name, hire_date, from_date, dept_name----
-- ====> this requires joining of 3 tables
SELECT 
    e.emp_no,
    e.first_name,
    e.last_name,
    e.hire_date,
    dm.from_date,
    d.dept_name
FROM
    employees e
        JOIN
    dept_manager dm ON e.emp_no = dm.emp_no
        JOIN
    departments d ON dm.dept_no = d.dept_no
ORDER BY e.emp_no;



/* retreive the information about each department with its average salary more than 
$60000(table to contain dept_name and avg_salary) */
SELECT 
	d.dept_name, AVG(s.salary) as average_salary
FROM dept_emp de
JOIN departments d ON de.dept_no=d.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
GROUP BY d.dept_name
HAVING average_salary > 60000
ORDER BY average_salary DESC;


/* How many male and how many female managers do we have in the employees database */
SELECT 
	e.gender as managers,
    COUNT(dm.emp_no) as count
FROM dept_manager dm
JOIN employees e
ON dm.emp_no = e.emp_no
GROUP BY e.gender;


-- ------------------UNION vs UNION ALL----------
/* pre-requisites before UNION of two tables
		1.we have to select the same number of columns from each table
        2. these columns should have same name
        3. these columns should be in same order
        4. these columns should contain related data-type
*/
-- take an example of UNION of employees and dept_managers tables whose columns are different totally
-- ---- what can we don now --> to each table, we can add the missing columns as 
########### UNION ----------------------------------------------------
SELECT 
	e.emp_no, 
    e. first_name, 
    e.last_name,
	NULL AS dept_no, 
	NULL AS from_date
FROM employee_dup e
WHERE emp_no = 10001
UNION
SELECT 
	NULL AS emp_no,
    NULL AS first_name, 
    NULL AS last_name,
    m.dept_no, 
    m.from_date
FROM dept_manager m;

########### UNION ALL----------------------------------------------------
SELECT 
	e.emp_no, 
    e. first_name, 
    e.last_name,
	NULL AS dept_no, 
	NULL AS from_date
FROM employee_dup e
WHERE emp_no = 10001
UNION ALL
SELECT 
	NULL AS emp_no,
    NULL AS first_name, 
    NULL AS last_name,
    m.dept_no, 
    m.from_date
FROM dept_manager m;
/* Main difference between UNION and UNION ALL is-
UNION =====> returns only the unique records upon union(thus use more computational power and 
				storage space while giving unique records) --> used for better results
                
UNION ALL =======>returns all the records including duplicates --> used for optimized performance 
*/

/*-- Create a view that will extract the average salary of all managers registered in the database.
Round this value to the nearest cent.  */
CREATE VIEW v_managers_average_salary AS
	SELECT 
		ROUND(AVG(s.salary), 2) AS average_salary
	FROM
		dept_manager dm
			JOIN
		salaries s ON dm.emp_no = s.emp_no;


/* Assign employee number 110022 as a manager to all employees from 10001 to 10020,
	and employee number 110039 as a manager to all employess from 10021 to 10040 ; and the output to 
	contain emp_id, dept_code, and manager_id*/

SELECT 
    A.*
FROM
    (SELECT 
        e.emp_no AS emp_ID,
            MIN(de.dept_no) AS dept_code,
            (SELECT 
                    dm.emp_no
                FROM
                    dept_manager dm
                WHERE
                    dm.emp_no = 110022) AS manager_ID
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no < 10020
    GROUP BY e.emp_no
    ORDER BY e.emp_no) AS A                    -- ===============> Subset A
UNION  
SELECT 
    B.*
FROM
    (SELECT 
        e.emp_no AS emp_ID,
            MIN(de.dept_no) AS dept_code,
            (SELECT 
                    dm.emp_no
                FROM
                    dept_manager dm
                WHERE
                    dm.emp_no = 110039) AS manager_ID
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no > 10020
    GROUP BY e.emp_no
    ORDER BY e.emp_no
    LIMIT 20) AS B;                           -- ===============> Subset B
    
    
    
    ########################## -- Obtain the average male and female employees salary values for each dept
-- using IF statement--
SELECT 
dept_name,
AVG(if(e.gender = 'f', s.salary, null)) as female_avg_salary,
AVG(if(e.gender = 'm', s.salary, null)) as male_avg_salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
JOIN dept_emp de on de.emp_no = e.emp_no
JOIN departments d on d.dept_no = de.dept_no
group by d.dept_name
ORDER BY d.dept_name;
 -- or -- using CASE statement
SELECT 
dept_name,
AVG(case when e.gender = 'f' then s.salary end) as female_avg_salary,
AVG(case when e.gender = 'm' then s.salary end) as male_avg_salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
JOIN dept_emp de on de.emp_no = e.emp_no
JOIN departments d on d.dept_no = de.dept_no
group by d.dept_name
ORDER BY d.dept_name;


############# -- create a stored routine which accepts the input as emp_no and returns output as emp_no, number and name of the 
##					last department the employee has  worked for.
-- here we create the stored procedure and not the function as our output returns more than one value
DROP procedure if exists last_dept;

DELIMITER $$
CREATE PROCEDURE last_dept(IN p_emp_no INTEGER)
BEGIN
	SELECT 
		e.emp_no,
        d.dept_no,
        d.dept_name
	FROM 
		employees e
	JOIN dept_emp de
		ON e.emp_no = de.emp_no
	JOIN departments d
		ON de.dept_no = d.dept_no
	WHERE p_emp_no = e.emp_no and 
			de.from_date = (select MAX(de.from_date) FROM dept_emp WHERE p_emp_no = e.emp_no);
END $$
DELIMITER ;
