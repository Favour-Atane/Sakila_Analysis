# Sakila_Analysis
An Analysis on the DVD Rentals Store database named Sakila.db. 

The Sakila database was sourced from MySQL, as documented here: MySQL Sakila Installation. The database was loaded into MySQL Workbench for querying and subsequently imported into Power Query for further data cleaning and transformation. As part of the exploratory data analysis, several key measures were created, including:

Average Rentals by Genre, Total Rentals, and Total Revenue to conduct a churn analysis. A specific measure was developed to identify customers who had churned (i.e., stopped renting) for over six months.
An Inventory Measure was also created to evaluate stock levels.
Each column’s datatype was verified to ensure accuracy, and necessary corrections were made to abbreviations. Some key measures created include:

RevenueByGenre: CALCULATE([TotalAmount], 'sakila category'[name]) – used to assess revenue by genre.
CustomerSegment: IF([TotalAmount] > 100, "High Value", IF([TotalAmount] > 50, "Medium Value", "Low Value")) – this segmented customers into high, medium, and low-value categories based on their rental behavior.
RevenueBySegment: CALCULATE([TotalAmount], 'sakila customer'[CustomerSegment]) – used to calculate revenue based on customer segments.
Additional measures were created but are not the focus here.

Analytical Questions Addressed:
Top-Rented Movies: Identification of the most frequently rented movies, along with analysis of rental patterns by customer demographics.
Customer Rental Behavior: Segmentation of customers based on their rental history, identifying high-value segments.
Revenue Analysis: Evaluation of revenue trends over time, broken down by genre, ratings, and customer segments.
Inventory Management: Assessment of DVD availability and turnover rates, providing recommendations for optimizing inventory levels.
Churn Analysis: Identification of factors contributing to customer churn, with a prediction of customers likely to churn.
The analysis and visualizations were conducted in Power BI, my preferred business intelligence tool. The analysis revealed the following key insights:

Total Rentals: 16,000
Number of Customers: 599
Countries Represented: 109
Cities Represented: 600
Top Renter: Eleanor Hunt with 46 rentals, followed by Karl Seal with 45 rentals
Top Renting City: Aurora
Total Revenue: $67,410
Average Rental Price: $4.20
Highest Revenue-Generating Genre: Sports, with $5,314.21
Most Revenue by Rating: PG-13
Peak Revenue Month: July 2005
Based on the insights from this analysis, I provided several recommendations aimed at reducing churn and improving rental performance. These included strategies for inventory optimization, such as identifying DVDs with high turnover rates to ensure sufficient availability, and analyzing rental patterns to adjust inventory levels during peak periods.

The comprehensive analysis of the Sakila database using Power BI yielded valuable insights into customer behavior, revenue trends, rental patterns, and inventory management, and formed the basis for actionable recommendations to improve rental performance and increase revenue.






