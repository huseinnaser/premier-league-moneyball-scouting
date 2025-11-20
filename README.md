# ⚽ Premier League 2024/25: Moneyball Scouting Dashboard

![Dashboard Banner][(https://github.com/user-attachments/assets/placeholder-image](https://github.com/huseinnaser/premier-league-moneyball-scouting/blob/main/Player%20Scouting.png))
> *A data-driven approach to identifying undervalued talent in the Premier League.*

### 🔗 [View the Live Dashboard on Tableau Public](https://public.tableau.com/views/PremierLeague202425AData-DrivenScoutingDashboard/PlayerScouting?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

---

## 📋 Project Overview
In the modern transfer market, player value often correlates more with "hype" than with actual pitch performance. For mid-table clubs with limited budgets, the key to success isn't buying the most expensive players—it's identifying **efficiency**.

This project answers a specific business question: **Can we identify players who are statistically outperforming their market value?**

Using data from the **2024/25 season**, I built an ETL pipeline in **R** to engineer custom performance metrics and visualized them in **Tableau** to create a dynamic scouting tool.

---

## 🔍 Key Findings: The 2024/25 Scouting Shortlist

By filtering for regular starters (Min. 1500 mins) with high **Value Efficiency (VMI)**, the model identified the following "Hidden Gems":

### 1. The "Value" XI (High Performance / Low Cost)
* **🧤 Goalkeeper: Matz Sels (Nott'm Forest)**
    * **Insight:** Top-tier shot-stopping output (PSxG+/-) for a bottom-tier price. He offers elite efficiency compared to "Big 6" goalkeepers.
* **🛡️ Defender: Djed Spence (Spurs)**
    * **Insight:** Offers excellent value retention. His ball progression stats are solid relative to his low market cost, making him a low-risk investment compared to premium options like Antonee Robinson.
* **⚙️ Midfielder: Mikkel Damsgaard (Brentford)**
    * **Insight:** An efficiency monster in progression metrics. His ability to move the ball into the final third ranks highly in the TFS model, yet his market value has not yet spiked.
* **⚽ Forward: Harvey Barnes (Newcastle)**
    * **Insight:** Consistently outperforms his valuation. His underlying numbers (xG + xA) relative to his cost make him one of the smartest attacking assets in the league.

### 2. Critical Reflection: The "Saliba Anomaly"
While the model successfully identifies high-output players in mid-table teams, a post-analysis review highlighted a limitation regarding elite possession sides.

* **Observation:** Top-tier defenders like **William Saliba (Arsenal)** appeared to have lower *Tactical Fit Scores* than expected.
* **Cause (Possession Bias):** The model relies on volume-based defensive metrics (Tackles + Interceptions). Since Arsenal dominates possession, Saliba has fewer defensive actions to perform per 90 minutes.
* **Future Improvement:** Version 2.0 will implement **Possession-Adjusted (PAdj)** stats to normalize defensive actions based on time spent *out* of possession.

---

## ⚙️ Methodology: The "TFS" Algorithm

To score players objectively, I created the **Tactical Fit Score (TFS)**, a 0-100 composite rating derived from position-specific metrics.

### 📊 Weighting Logic (The "Football DNA")
I customized the weights to favor **modern, progressive** gameplay over traditional volume stats:

* **🛡️ Defenders (DF):** Prioritized **Ball Progression** (Carries + Passes = 26% weight) over pure defense. The model favors ball-playing center-backs.
* **⚡ Midfielders (MF):** Heavily weighted **Expected Assists (xAG)** and **Progressive Actions** (~40%). The model seeks playmakers rather than defensive destroyers.
* **🎯 Forwards (FW):** A ruthless focus on **End Product**. **Goals (20%)** and **Expected Goals (18%)** make up nearly 40% of the score.
* **🧤 Goalkeepers (GK):** Defined by **PSxG+/- (30%)**. This metric measures "Goals Prevented" relative to the average keeper, independent of team defense.

---

## 🛠️ Technical Implementation (R)

The project uses **R** for the heavy lifting (Data Cleaning, Normalization, and Scoring).

**Feature Engineering Highlight: Market-Adjusted Potential (MAPI)**
To find "Moneyball" candidates, I engineered a metric that divides performance by the log-transformed market value.

```r
# 1. Log Transformation
# Normalizes the massive skew in football transfer fees (e.g., €100m vs €5m)
all_players$VMI <- all_players$TFS / log1p(all_players$market_value_m)

# 2. Matrix Multiplication for Efficient Scoring
# Calculates weighted scores across all metrics instantly
d$TFS_raw <- as.numeric(as.matrix(d[, zcols]) %*% as.matrix(weights))

📁 Data Sources & Tools
Performance Data: FBref

Financial Data: Transfermarkt

Languages: R (Tidyverse, Janitor, Stringr)

Visualization: Tableau Public

🤝 Acknowledgments
Data collection inspired by the worldfootballR library.

Code optimization and debugging assisted by LLM tools (ChatGPT) to ensure efficient ETL processing.

👤 Author
Husein Naser
