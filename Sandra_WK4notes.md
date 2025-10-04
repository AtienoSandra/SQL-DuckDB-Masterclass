## COMMON TABLE EXPRESSIONS (CTE)
A CTE is a temporary, named result set derived from a simple query, defined within the execution scope of a single SQL statement 
(such as SELECT, INSERT, UPDATE, DELETE, or MERGE). Think of it as creating a temporary, named result set inside your SQL query 
that you can reference later in the same query. A "query within a query," but cleaner and easier to read than subqueries.

### Uses of CTEs
**1. Improve query readability** by breaking complex queries into modular parts.
      - Complex queries can be broken into smaller, logical steps.
      - Makes SQL easier to write and debug.

**2. Reuse of Logic**
      - CTEs allow users to define a calculation once and reuse it in multiple parts of the query.
      - Avoids repeating the same subquery over and over.

**3. Recursive Queries**. CTEs allow recursion, which is super useful for:
      - Hierarchies (employees → managers → directors)
      - Tree/graph traversal (folders inside folders, bill of materials).

**4. Modularity** 
      - You can structure queries like "building blocks." Each CTE can represent one step of the analysis.

### CTEs vs Subquery

| **CTE** | **Subquery**|
| ----------------------: | ---------------------: |
| --- Declared at the start with WITH:                               | - Defined inline (inside SELECT, FROM WHERE)
| - Named - You can reference them multiple times in the main query. | - Usually anonymous and can't be reused easily
| - Readable - Breaks a big query into smaller steps.                | - Shorter and good for simpler conditions
| - Recursive - Can call themselves to handle hierarchies.           | - No recursion support
| - Exist only for the query execution (not stored in the DB).       |

#### Example (CTE):

      WITH sales_summary AS (
          SELECT customer_id, SUM(amount) AS total_spent
          FROM sales
          GROUP BY customer_id
            )
      SELECT customer_id, total_spent
      FROM sales_summary
      WHERE total_spent > 1000;

#### Example (subquery):

      SELECT customer_id, total_spent
      FROM (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM sales
    GROUP BY customer_id
      ) AS sales_summary
      WHERE total_spent > 1000;


## WINDOW FUNCTIONS
These are a set of syntax that allow row calculations in relation to another set of rows without using the rest of the result set.
Unlike aggregate functions, window functions don't need grouping rows of data into a single output row. The rows retain their separate 
identities other than having to loose some because of aggregate functions or GROUP BY.

### Categories of Window Functions

**1. Ranking window functions.**

Are utilized in creating a numerical sequence for the rows within a table. Suitable for solving prioritization problems or comparing
values based on their position in relation to others in your result set.
- ROW_NUMBER() – Creates an Index by assigning UNIQUE sequential numbers to all the rows in a table.
                       ROW_NUMBER() OVER ( ORDER BY).
                       
- RANK() – Assigns a rank to rows in table. Rows with the same rank are assigned identical values, but the next rank number will be
               skipped. For example, 1,1,3,4,4,4,4,8. RANK() OVER ( ORDER BY).
  
- DENSE_RANK() - Assigns a rank to rows in table. Rows with the same rank are assigned identical values, but the next rank number 
                     WILL NOT be skipped. For example, 1,1,2,3,4,5,5,5,6. DENSE_RANK OVER ( ORDER BY).
  
- PERCENT_RANK() – Assigns percentile rank between 0 and 1 in descending order i.e the lowest rank is 0 and thehigher rank is 1. Ranks in between are calculated based on the relative position of your value in the result set. Ranks can be duplicated and the subsequent rank will be skipped.PERCENT_RANK() OVER ( ORDER BY).
  
- NTILE() – Creates ranked partitions by which we spilt the result set. For example NTILE(3) OVER(ORDER BY some_column DESC) will assign each row a rank between 1-3. NTILE(x) OVER ( ORDER BY).
  
The ORDER BY clause inside a window function determines the sort order of the window i.e the rows with which the window function is acting on.

**2. Aggregate window functions (used with OVER).** 

Aggregate functions like SUM(), AVG(), COUNT(), MAX(), and MIN() normally collapse rows into a single result when used with GROUP BY.
Window functions let you apply those aggregates without collapsing rows — instead, they return the aggregate value alongside each row, based on a defined "window.
Aggregate window functions keep rows but add aggregate values as new columns.

**Common Aggregate Window Functions**

- SUM(...) OVER (...) - running totals, group totals without collapsing.
- AVG(...) OVER (...) - moving averages, group averages.
- COUNT(...) OVER (...) - counts per partition, counts per rolling frame.
- MIN(...) / MAX(...) OVER (...) - rolling min/max, group-level bounds.

  **Variants of OVER()**
  
- PARTITION BY - defines groups (like GROUP BY).
- ORDER BY - orders rows within each partition (for running totals, ranks, etc.).
- ROWS BETWEEN - defines sliding windows (moving averages, rolling sums).
  
**3. Value window functions**

- LAG() Returns the value for the row before the current row in a partition. If none then NULL.
- LEAD() Returns the value for the row after the current row in a partition. If none then NULL.
- FIRST_VALUE Returns the value specified with respect to the first row in the result set.
- LAST_VALUE Returns the value specified with respect to the last row in the result set.
- NTH_VALUE Returns the value in nth position of the result set.

**4. FRAMES**
Frames create a subset within windows to control the rows over which the query engine will operate. Think of the FRAME clause as drawing a 
window around your row to say: only use these specific rows near me for the calculation.
