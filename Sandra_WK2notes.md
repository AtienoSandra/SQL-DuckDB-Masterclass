## Anatomy of SQL Queries
*Query* - single action taken on a database. A request from a user for information from a database. 
SQL queries are composed of building blocks:
- SELECT: what columns to return
- FROM: which table(s) to query
- WHERE: filter conditions
- GROUP BY: aggregate grouping
- HAVING: filters on aggregates
- ORDER BY: sorting of output

## Query Processing Order
In SQL, the order in which we write our queries is not the same as the execution order. Understanding this order is important and 
will help us write accurate and efficient SQL queries. The execution order:
1. FROM/JOIN : FROM clause identifies the tables involved in the query, and JOIN clauses define how these tables are combined to
               form a single, virtual result set.
2. WHERE:      After the tables are joined, the WHERE clause filters the rows based on specified conditions. This narrows down the dataset
               before any grouping or aggregation occurs.
3. GROUP BY:   The GROUP BY clause groups the rows that share common values in specified columns into summary rows.
4. HAVING:     The HAVING clause filters these grouped rows based on conditions applied to aggregate functions.
               *HAVING operates on groups, whereas WHERE operates on individual rows.*
5. SELECT:     The SELECT clause then specifies which columns or expressions are to be included in the final result set. This is where aliases
               are often defined, and calculated columns are created. The DISTINCT keyword, if used, is applied here to remove duplicate rows
               from the selected data.
6. ORDER BY:   The ORDER BY clause sorts the final result set based on specified columns in ascending or descending order.
7. LIMIT:      LIMIT restricts the number of rows returned.

## SQL Operations
SQL evaluates operators in a hierarchy:
1. Arithmetic (*, /, +, -) → highest priority
2. Comparison (=, <>, >, <)
3. Logical (NOT → AND → OR)
4. Parentheses can override precedence.

## String Operations
String functions allow text cleaning & transformation:
- UPPER, LOWER - normalize case
- TRIM, LTRIM, RTRIM - remove spaces
- SUBSTRING, LEFT, RIGHT - extract characters
- CONCAT - join multiple strings

## Date Operations
These allow for creation, extraction, manipulation, and comparison of date values.
- DATE_TRUNC - round to month/week/day
- EXTRACT - pull year, month, weekday
- CURRENT_DATE - today’s date
- AGE - calculate differences

  
