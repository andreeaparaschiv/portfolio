/*Data Exploration of Video Game Sales in SQL */

/* The video game industry has experienced rapid growth and innovation in recent years. As 
competition intensifies, understanding market trends and consumer preferences becomes 
increasingly crucial for businesses in the sector. In this project, I analyze the "Video Game 
Sales with Ratings" dataset to uncover insights that can help businesses make informed decisions 
in game development and marketing. The dataset contains information on video game sales, 
platforms, publishers, genres, and critic and user ratings. By exploring this data, I will provide
valuable information for strategic decision-making in the video game industry.*/

/* Dataset used: https://www.kaggle.com/datasets/rush4ratio/video-game-sales-with-ratings 
Before starting the analysis, I deleted the columns irrelevant to this exploration in Excel and
then split the document into two different files: ratings.csv and video_game_sales.csv.*/

/* 1. Top 10 best-selling video game publishers
This information is useful for businesses in identifying the most successful publishers in the 
industry. Collaborating with these top publishers can increase the likelihood of a game's success
due to their expertise and market presence. */
SELECT Publisher, SUM(Global_Sales) AS total_sales
FROM video_game_sales
GROUP BY Publisher
ORDER BY total_sales DESC
LIMIT 10;

/* 2. Top 10 best-selling games per platform
This analysis provides insights into the top games for each platform, enabling businesses to 
optimize their game development for specific platforms and target markets. */
SELECT Platform, Name, Global_Sales
FROM (
    SELECT Platform, Name, Global_Sales, RANK() OVER (PARTITION BY Platform ORDER BY Global_Sales DESC) rank
    FROM video_game_sales
) subquery
WHERE rank <= 10
ORDER BY Platform, Global_Sales DESC;

/* 3. Average sales per genre:
By examining the average sales per genre, businesses can make informed decisions on which game 
genres are more profitable and popular. This can guide the focus of future game development 
projects and help allocate resources effectively. */
SELECT Genre, AVG(Global_Sales) AS avg_sales
FROM video_game_sales
WHERE Genre IS NOT ''
GROUP BY Genre
ORDER BY avg_sales DESC;

/* 4. Correlation between scores and global sales
The relationship between critic scores, user scores, and global sales can help businesses
understand the impact of reviews on sales performance. This insight can help businesses
focus on improving game quality and user experience, as well as leveraging positive reviews in 
marketing efforts. */
SELECT v.Name, v.Global_Sales, r.Critic_Score, r.User_Score
FROM video_game_sales AS v
JOIN ratings AS r ON v.Name = r.Name
WHERE r.Critic_Score IS NOT NULL AND r.User_Score IS NOT NULL
ORDER BY r.Critic_Score DESC, r.User_Score DESC;

/* 5. Top 10 games with the highest user scores 
By identifying games with the highest user scores, businesses can study these games to understand 
what factors contribute to their high ratings. These insights can be applied to future game 
development projects to enhance user satisfaction and increase the likelihood of success. */
SELECT v.Name, v.Platform, v.Publisher, r.User_Score
FROM video_game_sales AS v
JOIN ratings AS r ON v.Name = r.Name
WHERE r.User_Score IS NOT NULL
ORDER BY r.User_Score DESC
LIMIT 10;