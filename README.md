# 🏷️Products Dashboard
This started as an exercise in using SQL to prepare data, by completing <a href = "https://preppindata.blogspot.com/2024/03/2024-week-10-preppin-for-pulse.html">Preppin' Data Challenge 2024 week 10.</a> I then used the data source I had built to create a <a href="https://public.tableau.com/app/profile/dorinna/viz/ProductsDashboard_17155989437130/Dashboard1">retail product performance dashboard</a> in Tableau.

## 🔨Data prep
Data provided by the challenge came in three tables - Transactions, Products and Loyalty. <a href="https://github.com/dori104/ProductsDashboard/blob/main/Products_Data_Prep.sql">Products_Data_Prep.sql</a> is a SQL script I wrote in Snowflake to carry out the following transformations:
 <ul>
  <li>Converting fields to correct data type (e.g. VARCHAR to DATE)</li>
  <li>Updating values of categorical variables (e.g. grouping different spellings for loyalty tiers)</li>
  <li>Filtering dynamically to the last two years, to allow for year-on-year comparisons</li>
  <li>Generating rows for dates when the business was closed and no transactions were made, to ensure the dataset is complete with no gaps</li>
  <li>Reformatting fields (e.g. making the name field First Name Last Name)</li>
  <li>Creating ID fields to use when joining the tables together</li>
  <li>Adding calculated fields, such as sales after discount and profit.</li>
</ul>

## 📉The dashboard
With the dataset I had built, my plan was to create a dashboard that would allow a user to view overall performance of their business, with the ability to view this performance broken down over time and product. These were the key requirements I decided on:
<ul>
  <li>Overall performance of key metrics profit, sales, quantity and average profit per transaction</li>
  <li>Answer quesion of whether business is doing better compared to previous time periods</li>
  <li>Breakdown of performance over product features - are certain product lines doing better and hence worth investing in more?</li>
  <li>Ability to identify which product categories and specific products are performing the best, as well as the worst performing ones</li>
  <li>Ability to see interaction between metrics - for example, are there any products that have high sales but aren't very profitable?</li>
</ul>
<img src="https://github.com/dori104/ProductsDashboard/blob/main/Products%20Dashboard%201.png"> 
The key metrics I used were profit, sales, quantity sold and average profit per transaction. By selecting a month in the top right, a user can view the overall metrics in the KPI's for that month. To see if the business has been performing better over time, each KPI has a bar chart of the metric by month, with the selected month highlighted. There is also a percentage change figure compared to the previous month. I decided to also include a percentage change figure comparing that month's metric value to the same month last year, as a metric could experience a seasonal dip but still be an improvement from the same time last year.
<br></br>
Date calculations were used to pull the values for other time periods, referencing the month parameter.
<br></br>
<img src="https://github.com/dori104/ProductsDashboard/blob/main/Products%20Dashboard%202.png">
The rest of the dashboard shows the breakdown of a specific metric, according to what the user selects in the top right parameter. The main breakdown shows metric performance over product category (in this case product scent, as the business sells soap). The area charts show the performance of each product category over time for the selected month, where the day with the best performance is highlighted.
<br></br>
Total performance for the selected month is represented by the bars, with a gantt showing the value for the previous month. To further highlight performance vs last month, each bar is coloured according to whether the current month value exceeds last month's, and the bars are labelled with the percentage change. An additional percentage change figure is shown for product performance vs the same time last year.
<br></br>
The metric is also broken down by product type and size.
<br></br>
<img src="https://github.com/dori104/ProductsDashboard/blob/main/Products%20Dashboard%203.png">
As mentioned, good performance in one metric does not necessarily mean the product is worth keeping in production. With the scatter chart, a user can look at two metrics and identify products that perform well in both, perform badly in both, or perform well in one and poorly in another (for example, products with high sales but low profit). By default, the chart will highlight products in the top or bottom 10% of both metrics, but the user can chase the percentile. The percentile values are computed using window calculations.
<br></br>
The bar charts will show overall which specific products performed the best and worst for the selected month. As the user may want to see if the product is consistently performing poorly or if this is an unusual month, there is a viz in the tooltip when the user hovers over a bar. This will show the overall trend for that product.

### 🪄Dashboard actions
To allow the user to drill down into the data, they can focus on a specific product category, type or size by clicking on either of the middle three charts. This will filter the rest of the dashboard, and clicking off will reset everything.

### 📝Considerations
Accessibility was considered when designing the dashboard. In particular, I ran screenshots of the dashboard through a <a href="https://www.color-blindness.com/coblis-color-blindness-simulator/">colour blindness simulator</a> to ensure that the colours can be distinguished by users with various types of colour blindness.
<br></br>
<img src="https://github.com/dori104/ProductsDashboard/blob/main/Products%20Dashboard%20-%20Protanomaly.png" width="25%">
<img src="https://github.com/dori104/ProductsDashboard/blob/main/Products%20Dashboard%20-%20Protanopia.png" width="25%">
<img src="https://github.com/dori104/ProductsDashboard/blob/main/Products%20Dashboard%20Deuteranomaly.png" width="25%">
