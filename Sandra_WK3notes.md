## SUBQUERIES
A *subquery* is a query inside another query. Subqueries allow complex filtering, aggregation and data manipulation by using the result of
one query inside another.
Clauses that can be used with subqueries are:
- WHERE: filter rows based on subquery results
- FROM: treat subquery as a temporary (derived) table
- HAVING: filter aggregated results after grouping
  
## Types of Subqueries
### 1. Scalar Subquery
- returns a single value (one row and one column). Example:
    SELECT prod_name, price
    FROM products
    WHERE price > (SELECT AVG(price) FROM products);
  
### 2. Nested/Uncorrelated Subquery
- nested subquery is a subquery indepent of the outer query.
- executes completely before  the outer query begins and its result set is then used by the outer query.
- the inner query doesn't reference any columns from the outer query. Example:
    SELECT employee_name
    FROM employees
    WHERE dept_id IN ( SELECT dept_id
                          FROM departments
                            WHERE location = 'Nairobi');

### 3. Correlated Subquery
- a subquery that depends on the outer query for its execution.
- references one/more columns from the outer query; its re-evaluated for each row processed by the outer query.
- powerful for row-level analysis but can cause perfomance issues if not optimized. Example:
      SELECT employee_name, salary
      FROM employees e1
      WHERE salary > ( SELECT AVG(salary)
                          FROM employees e2
                            WHERE e2.department_id = e1.department-id);

## CASE WHEN ...
When to Use Cases:
- *Categorizing data*: assigning categories/labels to data based on specific criteria.
- *Conditional calculation*: performing different calculations based on certain conditions.
- *Data transformation*: converting/reformatting data based on its value/other related data.
- *Ordering data*: combine with ORDER BY to define custom sorting logic
- *Aggregating data*: combine with aggregate functions to perform conditional aggregations e.g
                      SUM(CASE WHEN Country = 'USA' THEN sales ELSE 0 END)

## SQL Operators
Operators enable powerful row-level logic without additional complexity.
We use operators because they make queries expressive, can be combined with other exoressions for enhanced filters, and are key to writing
clean, declarative business logic.
SQL evaluates operators in hierarchy as follows:
    1. Arithmetic
    2. Comparison
    3. Logical
**NB**: *Parentheses override precedence. Expressions enclosed in parentheses are always evaluated first from the innermost to the outermost.*

## SET Operators
These are techniques for combining/comparing the results of two or more SELECT statements.
They combine the results of two or more SELECT statements into a single result set.
Set operators require the SELECT statements to have same number of columns, compatible data types for corresponding columns, and the columns 
should be in the same order.
Set operators combine tables vertically by stacking one result set on top of another/by comparing them while JOINS combine tables horizontally 
by linking attributes.

### Constraints of using set operators
- Each query must return the same number of columns
- corresponding columns must have compatible data types
- columns muust align by  position and not alias.
- a global ORDER BY can only appear after the final set operation.
- ORDER BY clauses inside the individual queries are ignored unless wrapped in subqueries.

#### 1. UNION 
Combines the results of twwo or more SELECT queries into a single result set removing duplicate rows by default.
NB: *UNION does not remove NULL values.*

#### 2. UNION ALL
Combines the results of multiple SELECT queries, including all rows from each result set, regardless of whether they are duplicates or 
contain NULL values.

#### 3. INTERSECT
This returns only the rows that appear in the result sets of all SELECT statements. Returns only the rows common to both queries.

#### 4. EXCEPT/MINUS
Returns only the rows unique to the first query but absent in the second query.

## JOINS
A join is a piece of syntax that allows you to combine rows from two or more tables based on related columns.
Types are:

#### Inner Join
Returns only rows  with matching keys in both tables. Filters out rows without matches.

#### Left Join
Returns all rows from the left table and matching rows from the right table. If there is no match, fills with NULL.

#### Full Outer Join
Combines all records from both tables including unmatched rows.

#### Right Join
Returns all rows from the right table and matching rows from the left table.

#### Cross Join
Matches every row with every row (no condition).
