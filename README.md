# Instacart_DB
![](instacart_logo.jpg)
___
### INTRODUCTION
___
An American delivery firm called Instacart offers grocery delivery and pickup services in both the US and Canada. Both a website and a mobile app are used by the business to provide its services. The sales analysis of "instacart store" is the subject of this sql project. The goal of the project is to analyze and generate insights to enable the store make data-driven decisions and respond to stakeholder questions.

### PROBLEM STATEMENT
___
1. On which day(s) of the week are condoms mostly sold?
2. At what time of the day is condom mostly sold?
3. Which aisle/s can I find all Non-Alcholic drinks?
4. What is the top-selling product by revenue, and how much revenue have they generated?
5. which department has the highest average spend per customer?
6. Which product generated more profit?
7. What are the 3 aisles with the most orders, and which departments do these orders belong to
8. Which 3 users generated the highest revenue and how many aisles did they order from?
9. What is the average number of orders placed by days of the week?
10. What is the hour of the day with the highest number of orders?

### SKILL DEMONSTRATED
___
This project put my understanding of database design and normalization to the test; postgresql was used in this project.
Before I proceed I would like to briefly explain Nomalization of a database.

##### NORMALIZATION
___
Nomalization is the process of designing a database effectively such that we can avoid data redundancy i.e data duplication.

##### Different levels of normalization
Genarally, we have different levels of normalization and each level has different rules. Below are the ff levels of normalization:
1. First Normal form
   - Every column/attribute need to have a single value
   - Each row should be unique. Either through a single or multiple column.
2. Second Normal form
   - Must be in 1 Normal form
   - All Non Key attributes must be fully dependent on candidate key.
3. Third Normal form
   - Transitive dependecies: No Non-primary column should depend on another non-primary column.

##### Denormalization process
I created a Table to house my denormalized dataset.The code for creating the table is shown below.
![](denormalization.png)

Then I imported the data into the table I created using this code;
![](importing.png)

In order to store the codes before importing them into their various tables later, I denormalize the data by establishing 4 view tables.
Product view              |         order view
:------------------------:|:------------------------:
![](product_view.png)     |   ![](order_view.png)

aisle_view                |       department_view
:------------------------:|:------------------------:
![](aisle_view.png)       |   ![](dept_view.png)

I then established 4 tables so I could insert my data into them and finish the normalization process after generating those views.
Below is the code I wrote to create those tables, I also established my primary key and foreign key in the tables so there can be a relationship between those 4 tables.
Product table                   |         order table
:------------------------------:|:---------------------------:
![](product_table.png)          |   ![](order_table.png)

aisle table                     |       department table
:------------------------------:|:------------------------------:
![](aisles_table.png)           |    ![](department_table.png)

Data was then inserted into the tables from the corresponding views I built after creating the tables; below is the code used to insert the data;

Product insert                   |         order insert
:------------------------------:|:---------------------------:
![](product_insert.png)          |   ![](order_insert.png)

aisle insert                    |       department insert
:------------------------------:|:------------------------------:
![](aisle_insert.png)           |    ![](dept_insert.png)
___

## DATA MODELLING
___
1. The modelling comprises of 4 different tables.
2. The denormalized table was normalized up to the 3NF.
3. A **Star Schema** is the end product of normalization.

#### DATA MODEL
![](ERD_diagram.png)
