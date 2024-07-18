/*
File to submit by each member: G0999_9999999.sql

INDIVIDUAL ASSIGNMENT SUBMISSION
Submit one individual report with SQL statements only (*.docx)
and one sql script (*.sql for oOacle)

Template save as "G999_YourStudentID.sql"
e.g. G001_999999.sql

GROUP NUMBER : G017
PROGRAMME : CS
STUDENT ID :2105524
STUDENT NAME :Seow Yi Xuan
Submission date and time: 16-04-24

Your information should appear in both files one individual report docx & one individual sql script, then save as G01_99ACB999999.zip
Should be obvious different transaction among the members

*/



/* Query 1 */

SELECT t.TABLE_ID AS "Table", f.FOOD_NAME, i.INVOICE_ID AS "Inv"
, i.INVOICE_Time AS "Time"
FROM "Table" t, Food f, Order_ o, Invoice i,Customer c
WHERE c.CUSTOMER_ID = t.CUSTOMER_ID
AND t.CUSTOMER_ID = i.CUSTOMER_ID
AND f.CUSTOMER_ID = i.CUSTOMER_ID
AND o.TABLE_ID = t.TABLE_ID
AND TABLE_STATUS = 'Occupied'
AND ORDER_STATUS = 'Completed';


/* Query 2 */

SELECT c.CUSTOMER_ID, f.FOOD_NAME, i.ITEM_NAME AS "Ingredients", i.ITEM_DESC AS "Description"
FROM CART c, FOOD f, Inventory i, CART_FOOD t
WHERE c.CART_ID = t.CART_ID
AND t.FOOD_ID = f.FOOD_ID
AND f.INVENTORY_ID = i.INVENTORY_ID
AND (ITEM_NAME = 'Tea bags' OR ITEM_NAME = 'Flour');


/* Stored procedure 1 */
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE insertTable (
    new_Table_ID IN VARCHAR2,
    new_Table_Location IN VARCHAR2,
    new_Table_Status IN VARCHAR2,
    new_CUSTOMER_ID IN VARCHAR2
)
IS
BEGIN
    INSERT INTO "Table" (Table_ID, TABLE_LOCATION, TABLE_STATUS, CUSTOMER_ID)
    VALUES (new_Table_ID, new_Table_Location, new_Table_Status, new_CUSTOMER_ID);
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Duplicate Value for a Unique Constraint.');
END;
/

EXECUTE insertTable ('T026','Indoor','Available','');


/* Stored procedure 2 */

CREATE OR REPLACE PROCEDURE updateInventory (
    new_INVENTORY_ID IN VARCHAR2,
    new_ITEM_Quantity IN NUMBER
)
IS
    -- Current item quantity
    current_item_stock NUMBER; 
BEGIN
    -- Retrieve current item quantity
    SELECT ITEM_Quantity INTO current_item_stock
    FROM Inventory
    WHERE INVENTORY_ID = new_INVENTORY_ID;

    -- Check if new quantity meets the constraint
    IF (new_ITEM_Quantity < 20) THEN
        DBMS_OUTPUT.PUT_LINE('Error: Quantity cannot be less than 20.');
        RETURN;
    END IF;

    -- Update inventory quantity and provide feedback
    IF (new_ITEM_Quantity < current_item_stock) THEN
        DBMS_OUTPUT.PUT_LINE('Item quantity decreases');
    ELSIF (new_ITEM_Quantity > current_item_stock) THEN
        DBMS_OUTPUT.PUT_LINE('Item restocked');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Item quantity unchanged');
    END IF;

    -- Update the inventory with the new quantity
    UPDATE Inventory
    SET ITEM_Quantity = new_ITEM_Quantity
    WHERE INVENTORY_ID = new_INVENTORY_ID;

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Inventory ID not in list.');
END;
/



EXECUTE updateInventory ('IT004',22);



/* Function 1 */

CREATE OR REPLACE FUNCTION ChefSalary(STAFF_SALARY IN VARCHAR2)
RETURN VARCHAR
IS
    total_salary NUMBER(10,2); 
BEGIN
    SELECT SUM(STAFF_SALARY) INTO total_salary
    FROM STAFF
    WHERE STAFF_ROLE = 'Chef';
    RETURN TO_CHAR(total_salary);
END;
/



DECLARE
    --Declare variable as NUMBER to hold 2 decimal place
    chef_total_salary NUMBER(10,2);
BEGIN
    --Convert result
    chef_total_salary := TO_NUMBER(ChefSalary('Chef')); 
    DBMS_OUTPUT.PUT_LINE('Total salary of all chefs: RM' || TO_CHAR(chef_total_salary, '9999.99'));
END;
/




/* Function 2 */

CREATE OR REPLACE FUNCTION OccupiedOutdoorTables(TABLE_LOCATION IN VARCHAR2)
RETURN NUMBER
IS
    occupied_tables NUMBER;
BEGIN
    SELECT COUNT(TABLE_LOCATION) INTO occupied_tables
    FROM "Table"
    WHERE TABLE_LOCATION = 'Outdoor'
    AND TABLE_STATUS = 'Occupied';
    RETURN occupied_tables;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
END;
/



DECLARE
    num_occupied_tables NUMBER;
BEGIN
    num_occupied_tables := OccupiedOutdoorTables('Outdoor');
    DBMS_OUTPUT.PUT_LINE('Number of occupied outdoor tables: ' || num_occupied_tables);
END;
/