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

# Calculate Revenue per Client
revenue_per_client = total_revenue / total_visitors

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
print (revenue_per_client)
print (client_retention_rate * 100)
print (mean(CLV$customer_revenue))

# Outputs
# Average Order Value: 369.4815 
# Month with the Highest Revenue Growth: December
# Month with the Lowest Revenue Growth: June
# Client Retention Rate: 55.904 %
# Revenue per Client: 1128.544
# Average Customer Lifetime Value: 1128.544

# Recommendations:
# Focus on high-growth period: It is suggested to capitalise on the high-growth period (December) by creating targeted marketing campaigns, offering 
# seasonal promotions, and optimising inventory management.

# Enhance customer retention strategies: The client retention rate stands at 55.9%, indicating that there is room for improvement in retaining customers. 
# Implementing loyalty programs, offering personalised discounts, and providing excellent customer service can help increase repeat purchases and improve
# the overall retention rate.

# Increase average order value (AOV): With an AOV of 369.48, there is potential to increase this metric by offering bundled products, upselling or 
# cross-selling items, and providing incentives for customers to spend more during their purchases.

# Focus on high-value customers: The average customer lifetime value is 1128.54. Identifying high-value customers and targeting them with tailored 
# marketing campaigns can help improve revenue per client, which currently stands at 1128.54. Additionally, investing in acquiring new customers with 
# similar characteristics to high-value customers can also contribute to revenue growth.
