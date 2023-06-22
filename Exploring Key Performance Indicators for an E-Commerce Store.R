# Exploring Key Performance Indicators for an E-Commerce store in R

# This project aims to analyse a dataset from an e-commerce platform to uncover key performance indicators (KPIs) and growth opportunities.

# Dataset used: https://www.kaggle.com/datasets/carrie1/ecommerce-data

# Import Libraries
library(tidyverse)
library(lubridate)

# Data Preprocessing 
head(data)

colSums(is.na(data))

dataset_clean = data %>%
  drop_na() %>%
  mutate(InvoiceDate = ymd_hms(InvoiceDate, format = guess_formats(InvoiceDate, orders = c("Ymd HMS", "Ymd HM"))),
         Revenue = Quantity * UnitPrice)
dataset_clean = dataset_clean %>%
  filter(!is.na(InvoiceDate))

total_revenue = sum(dataset_clean$Revenue)
total_visitors = n_distinct(dataset_clean$CustomerID)
total_orders = n_distinct(dataset_clean$InvoiceNo)
conversion_rate = total_orders / total_visitors

dataset_monthly = dataset_clean %>%
  mutate(month = floor_date(InvoiceDate, "month")) %>%
  group_by(month)

# Calculate Average Order Value
AOV = total_revenue / n_distinct(dataset_clean$InvoiceNo)

# Calculate Revenue Growth
KPIs_monthly = dataset_monthly %>%
  summarise(revenue = sum(Revenue),
            orders = n_distinct(InvoiceNo),
            visitors = n_distinct(CustomerID),
            AOV = revenue / orders,
            conversion_rate = orders / visitors) %>%
  mutate(revenue_growth = (revenue - lag(revenue)) / lag(revenue) * 100)

revenue_growth_df = KPIs_monthly %>% select(month, revenue_growth)
revenue_growth_summary = revenue_growth_df %>%
summarise(mean_growth = mean(revenue_growth, na.rm = TRUE),
            min_growth = min(revenue_growth, na.rm = TRUE),
            max_growth = max(revenue_growth, na.rm = TRUE),
            sd_growth = sd(revenue_growth, na.rm = TRUE))
mean_growth = revenue_growth_summary$mean_growth
sd_growth = revenue_growth_summary$sd_growth
high_growth = revenue_growth_df %>% filter(revenue_growth > mean_growth + sd_growth) %>% top_n(1, revenue_growth)
low_growth = revenue_growth_df %>% filter(revenue_growth < mean_growth - sd_growth) %>% top_n(1, revenue_growth)

# Calculate Client Retention Rate
repeat_customers = dataset_clean %>%
  group_by(CustomerID) %>%
  summarise(num_orders = n_distinct(InvoiceNo)) %>%
  filter(num_orders > 1) %>%
  nrow()
client_retention_rate <- repeat_customers / total_visitors

# Calculate CLV
CLV = dataset_clean %>%
  group_by(CustomerID) %>%
  summarise(customer_revenue = sum(Revenue)) %>%
  mutate(avg_customer_revenue = mean(customer_revenue))

# Print the calculated KPIs
print (AOV)
print (high_growth)
print (low_growth)
print (client_retention_rate * 100)
print (mean(CLV$customer_revenue))

# Outputs
# Average Order Value: 369.4815 
# Month with the Highest Revenue Growth: December
# Month with the Lowest Revenue Growth: June
# Client Retention Rate: 55.904 %
# Average Customer Lifetime Value: 1128.544

# Comparison with industry standards:
# Average order value is significantly higher than the 128 industry standard (source: https://www.growcode.com/blog/average-order-value/)

# The industry standard is that the month with the highest revenue growth is January due to post-Christmas discounting. That is not the case for this
# store (source: https://webvizionglobal.com/what-are-the-best-and-worst-months-for-e-commerce/)

# Client retention rate is higher than the 31% industry standard (source: https://www.gorgias.com/blog/ecommerce-retention-rate)

# A good customer lifetime value is usually 3x higher than the customer acquisition costs 
# (source: https://www.verfacto.com/blog/customer-lifetime-value/in-ecommerce/)

# Recommendations:
# Leverage high order value: the average order value is considerably higher than the industry standard, which indicates that the store's customers are
# willing to spend more per order, thus it is worth considering introducing more premium or bundled products to further capitalise on this trend

# Seasonal marketing: consider post-Christmas promotions to extend the December high growth into January, as per industry standards, while also 
# improving June revenue growth through summer sales

# Customer acquisition costs: ensure that the customer acquisition costs are less than 3x the customer lifetime value
