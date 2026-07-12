# 🏛️ Cultural Heritage Tourism: Data Modeling & Sustainability Analytics

Hello! 👋 Welcome to my portfolio project. 

I built this end-to-end analytics solution to assess the operational, financial, and environmental sustainability of 50 cultural heritage sites. My goal was to step beyond basic data visualization and truly focus on **Analytics Engineering**—taking a messy, denormalized 15,000-row dataset and building a robust, enterprise-grade Star Schema from the ground up.

**Role:** Junior Analytics Engineer / Data Analyst  
**Tech Stack:** MS SQL Server (T-SQL), Power BI, DAX, Data Modeling (Star Schema)

---

## 💡 Key Business Insights
Instead of just building charts, I used DAX to calculate Pearson correlation coefficients to answer actual business questions:

1. **The Volume vs. Value Reality:** Revenue per visitor is virtually locked at ~$124 across all regions. The $1B+ revenue gap between National and Local sites is driven entirely by foot traffic volume, not pricing power.
2. **The Cost of Overcrowding (r = -0.78):** There is a severe negative correlation between overcrowding risk and visitor satisfaction. Maximizing ticket sales without managing capacity actively destroys the visitor experience.
3. **The Environmental Toll (r = 0.95):** Environmental pressure rises in perfect lockstep with visitor volume. There are zero efficiency gains at scale; more visitors equal a proportionally higher environmental cost (carbon emission remains stubbornly flat at ~0.50 kg per visitor).

---

## 🚧 Challenges & How I Solved Them
Real-world data is rarely perfectly clean, and this project was no exception. Here are a few hurdles I hit and how I engineered around them:

**1. The "Junk Dimension" Pivot** During my initial data modeling, I tried to create a standard `Dim_Site` table by grouping the Site IDs. However, profiling the data revealed a massive structural quirk: attributes like `Region` and `Heritage_Type` actually varied *row-by-row* for the exact same site! If I had forced a standard dimension, I would have collapsed real data variation into fake constants. 
* *The Fix:* I pivoted to engineering a **Junk Dimension** (`Dim_Site_Profile`) to capture the exact unique combinations of those categories, leaving `Heritage_Site_ID` as a degenerate dimension on the Fact table. This preserved the true grain of the data.

**2. Adhering to Roche's Maxim (Pushing Transformations Upstream)** My raw data only contained numeric months (1-12), which looked terrible on a BI axis. My first instinct was to write an M-Code script in Power Query to generate a calendar. 
* *The Fix:* To practice proper enterprise architecture, I followed Roche's Maxim (*"Transform data as far upstream as possible"*). I wrote a T-SQL script using the `CHOOSE()` function to generate readable text (Months, Quarters) directly inside my MS SQL database. This kept my Power BI model incredibly lightweight and ensured the database remained the single source of truth.

**3. The Virtual Machine Networking Trap** I initially started this project using MySQL on a Mac host. However, Power BI was running inside a Windows Parallels VM, and the Mac's internal firewall absolutely refused to let the VM connect to the database via `localhost` or the IP bridge. 
* *The Fix:* Rather than fighting the firewall for hours, I made a strategic pivot. I migrated the entire backend to **MS SQL Server** inside the Windows environment. This completely solved the networking issue and better aligned my portfolio with the Microsoft stack (T-SQL) for my DP-600 / DP-203 certification goals.

---

## 📂 Repository Contents
* `Tourism_Data_Transformation.sql`: The complete T-SQL script containing the ELT logic, Junk Dimension creation, and foreign key constraints.
* `Tourism_Sustainability_Dashboard.pbix`: The final Power BI file containing the data model, DAX measures, and visual reports.
* `Dashboard_Preview.pdf`: High-resolution exports of the final dashboard pages.

*Thank you for checking out my work! Feel free to reach out if you want to chat about data modeling, DAX, or heritage conservation.*
