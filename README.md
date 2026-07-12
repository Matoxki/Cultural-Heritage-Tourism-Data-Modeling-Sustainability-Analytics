# 🏛️ Cultural Heritage Tourism: Data Modeling & Sustainability Analytics

Hello! 👋 Welcome to my portfolio project. 

I built a data model. It ran without a single error. It was completely wrong.

Here's what happened: I was modeling a heritage tourism dataset (15,000 records, 50 sites) and needed a dimension table for each site's region and type. Standard move — GROUP BY the site ID, take MAX() of the categorical columns, done.

Except when I checked it against the raw data, every single one of my 50 sites had collapsed to the exact same values. Same region. Same heritage type. Same level. All 50. MAX() had just grabbed whatever sorted last alphabetically, because the real data didn't have one fixed region per site at all, it varied row by row.

I fixed it with a junk dimension instead of pretending the categories were fixed, then built out the rest: a validated SQL Server star schema, a Power BI semantic model, and DAX measures that compute real statistics, not just SUM and AVERAGE.

What I found once the model was actually right: 
1. Maintenance spend tracks damage severity (r = 0.93); reactive, not preventive.
2. Overcrowding tanks visitor satisfaction (r = -0.78) 
3. Revenue per visitor is flat everywhere (~$123-125); totals vary because of volume, not value 
4. Environmental impact scales almost 1:1 with visitor count (r = 0.95)



📂 Repository Contents
* `Tourism_Data_Transformation.sql`: The complete T-SQL script containing the ELT logic, Junk Dimension creation, and foreign key constraints.
* I can not include the `Tourism_Sustainability_Dashboard.pbix`: Size limitations 
* `Dashboard_Preview.pdf`: High-resolution exports of the final dashboard pages.
* `Model View.png`: The Model Screenshot from Power BI.

*Thank you for checking out my work! Feel free to reach out if you want to chat about data modeling, DAX, or heritage conservation.*
