# Laykin Consulting Order Database

A relational database built in MySQL for Laykin Consulting's order data. The project
takes a flat spreadsheet of 191 order lines, cleans the data, normalizes it to third normal form (3NF),
and answers business questions with SQL.

## Tools
- MySQL Server and MySQL Workbench
- Mr. Data Converter (to import the spreadsheet)
- Excel (to validate query results with pivot tables)

## Database design
The raw data is loaded into a staging table, `orderdetails`, then split into six tables:

| Table | Description |
|---|---|
| `company` | Each client company with its sector and industry |
| `product` | Each product and its category |
| `consultant` | Each consultant and hourly wage |
| `location` | Each state and its region |
| `orders` | One row per order: date, customer, company |
| `orderline` | One row per order line: quantity, rate, sale amount, and links to the other tables |

`companyid`, `productid`, `consultantid` and `stateid` are surrogate keys that were added
during normalization. The EER diagram is in `LaykinOrderTyagi.mwb` (also exported as a PNG).

## Repository contents
- `LaykinOrderTyagi.mwb` - MySQL Workbench model containing the EER diagram
- `laykin_schema.sql` - creates the tables, loads the data and adds foreign keys
- `Project1Tyagi.sql` - queries, one additional query per category, and a view
- `LaykinOrderEERDiagram.png` - image of the EER diagram
- `LaykinConsultingOrderData.xlsx` - laykinConsulting data spreadsheet 

## How to run
1. Create a schema (for example `LaykinOrderTyagi`) in MySQL Workbench.
2. Import the spreadsheet into a table named `orderdetails` with Mr. Data Converter
   and confirm it has 191 rows.
3. Run `laykin_schema.sql`. It creates the parent tables first, then the child tables,
   fills them with `INSERT ... SELECT DISTINCT`, and adds the foreign keys.
4. Run the queries file.

## Business questions answered
- Top company by total sales
- Sector with the lowest sales
- Top 10 consultants by sales, with hourly wage
- Customers with work done in states ending in "ee" (using REGEXP)
- Additional queries covering a three-table join, aggregation, a subquery, LIKE
- `ordersummary` view: one row per order with its company, customer, line count and total

## Normalization notes
- 1NF: `RowID` is the primary key of the original table.
- 2NF: no partial dependencies, since the key is a single column.
- 3NF: transitive dependencies were removed, for example `OrderID -> CustomerName -> CompanyName`
  and `ZipCode -> State -> Region`.

## Author
Gania Tyagi - Database Management Bus 440- 11/3/26
