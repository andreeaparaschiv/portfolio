/*Data Exploration of Video Game Sales in SQL */

/* The video game industry has experienced rapid growth and innovation in recent years. As competition intensifies, understanding market trends and 
consumer preferences becomes increasingly crucial for businesses in the sector. In this project, I analyze the "Video Game Sales with Ratings" dataset
to uncover insights that can help businesses make informed decisions in game development and marketing. The dataset contains information on video game 
sales, platforms, publishers, genres, and critic and user ratings. By exploring this data, I will provide valuable information for strategic decision 
making in the video game industry.*/

/* Dataset used: https://www.kaggle.com/datasets/rush4ratio/video-game-sales-with-ratings 
Before starting the analysis, I pre-processed the dataset in Excel and then split the document into two different files: video_game_sales.csv and
ratings.csv.*/

/* 1. Top 10 best-selling games per platform
This analysis provides insights into the top games for each platform, enabling businesses to  optimize their game development for specific platforms and 
target markets. */
SELECT Platform, Name, Global_Sales
FROM (
    SELECT Platform, Name, Global_Sales, RANK() OVER (PARTITION BY Platform ORDER BY Global_Sales DESC) rank
    FROM video_game_sales
) subquery
WHERE rank <= 10
ORDER BY Platform, Global_Sales DESC;

/* 2. Average sales per genre:
By examining the average sales per genre, businesses can make informed decisions on which game genres are more profitable and popular. This can guide the
focus of future game development projects and help allocate resources effectively. */
SELECT Genre, AVG(Global_Sales) AS avg_sales
FROM video_game_sales
WHERE Genre IS NOT ''
GROUP BY Genre
ORDER BY avg_sales DESC;

/* 3. Top 10 games with the highest user scores 
By identifying games with the highest user scores, businesses can study these games to understand what factors contribute to their high ratings. These 
insights can be applied to future game development projects to enhance user satisfaction and increase the likelihood of success. */
SELECT v.Name, v.Platform, v.Publisher, r.User_Score
FROM video_game_sales AS v
JOIN ratings AS r ON v.Name = r.Name
WHERE r.User_Score IS NOT NULL
ORDER BY r.User_Score DESC
LIMIT 10;

/* 4. Impact of critic and user count on global sales
Understanding the relationship between the number of critics and users who reviewed the game and the game's global sales can provide insights into the 
importance of user and critic engagement. */
SELECT v.Name, v.Global_Sales, r.Critic_Count, r.User_Count
FROM video_game_sales AS v
JOIN ratings AS r ON v.Name = r.Name
WHERE r.Critic_Count IS NOT NULL AND r.User_Count IS NOT NULL
ORDER BY v.Global_Sales DESC;

/* 5. Correlation between scores and global sales
The relationship between critic scores, user scores, and global sales can help businesses understand the impact of reviews on sales performance. This 
insight can help businesses focus on improving game quality and user experience, as well as leveraging positive reviews in marketing efforts. */
SELECT v.Name, v.Global_Sales, r.Critic_Score, r.User_Score
FROM video_game_sales AS v
JOIN ratings AS r ON v.Name = r.Name
WHERE r.Critic_Score IS NOT NULL AND r.User_Score IS NOT NULL
ORDER BY r.Critic_Score DESC, r.User_Score DESC;

/* 6. Publisher performance by genre
This query gives an understanding of how well each publisher performs in each genre, providing insights into the niche areas where each publisher excels. */
SELECT v.Publisher, v.Genre, AVG(Global_Sales) as avg_sales
FROM video_game_sales v
GROUP BY v.Publisher, v.Genre
HAVING COUNT(*) > 10
ORDER BY avg_sales DESC;

/* 7. Top games by user score to sales ratio
Identifying games that have high user scores but low sales could help find under-marketed or niche games that have potential for increased sales with greater 
exposure. */
SELECT v.Name, v.Global_Sales, r.User_Score, (r.User_Score/v.Global_Sales) AS score_to_sales_ratio
FROM video_game_sales AS v
JOIN ratings AS r ON v.Name = r.Name
WHERE v.Global_Sales > 0 AND r.User_Score IS NOT NULL
ORDER BY score_to_sales_ratio DESC
LIMIT 10;
