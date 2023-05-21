/*Data Exploration of Video Game Sales in SQL */

/* The video game industry has experienced rapid growth and innovation in recent years. As competition intensifies, understanding market trends and 
consumer preferences becomes increasingly crucial for businesses in the sector. In this project, I analyze the "Video Game Sales with Ratings" dataset
to uncover insights that can help businesses make informed decisions in game development and marketing. */

/* Dataset used: https://www.kaggle.com/datasets/rush4ratio/video-game-sales-with-ratings 
Before starting the analysis, I pre-processed the dataset in Excel and then split the document into two different files: video_game_sales.csv and
ratings.csv. */

/* 1. Top 10 best-selling games per platform
This analysis helps businesses understand which games are performing best on each platform. This knowledge can influence the design and development stages
of future games, ensuring they are well suited to their intended platform. */

SELECT Platform, Name, Global_Sales
FROM (
    SELECT Platform, Name, Global_Sales, RANK() OVER (PARTITION BY Platform ORDER BY Global_Sales DESC) rank
    FROM video_game_sales
) subquery
WHERE rank <= 10
ORDER BY Platform, Global_Sales DESC;

/* 2. Average sales per genre:
Understanding the average sales by genre can guide a company's strategic decisions. If certain genres are consistently high-sellers, the company may choose 
to focus more resources on developing games within those genres. */

SELECT Genre, AVG(Global_Sales) AS avg_sales
FROM video_game_sales
WHERE Genre IS NOT ''
GROUP BY Genre
ORDER BY avg_sales DESC;

/* 3. Top 10 games with the highest user scores 
This analysis helps businesses identify what games users rate highly and why. By studying these games, companies can learn what makes them popular, such as 
gameplay mechanics, story, graphics, or other factors. These insights can be incredibly useful for future game development, as they can guide the design and 
development process towards elements that are more likely to be well-received by players. */

SELECT v.Name, v.Platform, v.Publisher, r.User_Score
FROM video_game_sales AS v
JOIN ratings AS r ON v.Name = r.Name
WHERE r.User_Score IS NOT NULL
ORDER BY r.User_Score DESC
LIMIT 10;

/* 4. Impact of critic and user count on global sales
By obtaining the data on the count of critic and user reviews alongside the global sales of a game, businesses can understand the extent of engagement required 
to drive sales. If there is a strong correlation, businesses may consider strategies to encourage more user and critic engagement, like incentivized review 
programs or critic preview events. This can help them shape marketing strategies that drive interaction with their games, thereby increasing visibility and 
potential sales. */

SELECT v.Name, v.Global_Sales, r.Critic_Count, r.User_Count
FROM video_game_sales AS v
JOIN ratings AS r ON v.Name = r.Name
WHERE r.Critic_Count IS NOT NULL AND r.User_Count IS NOT NULL
ORDER BY v.Global_Sales DESC;

/* 5. Publisher performance by genre
This analysis helps publishers identify their strengths and weaknesses in different genres. If a publisher excels in a specific genre, they can leverage this 
strength by focusing more on it, potentially increasing their market share and profitability. Conversely, if a publisher's performance in a genre isn't up to 
par, they can analyze the reasons and adjust their strategies accordingly. */

SELECT v.Publisher, v.Genre, AVG(Global_Sales) as avg_sales
FROM video_game_sales v
GROUP BY v.Publisher, v.Genre
HAVING COUNT(*) > 10
ORDER BY avg_sales DESC;

/* 6. Top games by user score to sales ratio
This query helps businesses identify underappreciated gems in their portfolio. Games with high user scores but lower sales could indicate potential for market 
expansion or better marketing. These games might be offering a quality user experience, but are just not reaching a wide audience. Recognizing these games can 
help businesses realign their marketing strategies, potentially focusing on promoting these games to a larger audience or targeting advertising to the niche 
market that highly rates these games, thereby driving sales up. */

SELECT v.Name, v.Global_Sales, r.User_Score, (r.User_Score/v.Global_Sales) AS score_to_sales_ratio
FROM video_game_sales AS v
JOIN ratings AS r ON v.Name = r.Name
WHERE v.Global_Sales > 0 AND r.User_Score IS NOT NULL
ORDER BY score_to_sales_ratio DESC
LIMIT 10;

/* 7. Most improved games in terms of User_Score over the years
This query can highlight games that have improved in terms of user perception over the years, perhaps through updates or expansions. This could provide valuable 
insights for businesses about the importance of post-launch support and continual improvement for maintaining or improving user perception. */

WITH yearly_scores AS (
    SELECT v.Name, v.Year_of_Release, r.User_Score,
           LAG(r.User_Score) OVER(PARTITION BY v.Name ORDER BY v.Year_of_Release) as Previous_Year_Score
    FROM video_game_sales v
    JOIN ratings r ON v.Name = r.Name
),
score_diff AS (
    SELECT Name, Year_of_Release, (User_Score - Previous_Year_Score) as Score_Change
    FROM yearly_scores
)
SELECT Name, MAX(Score_Change) as Max_Score_Change
FROM score_diff
GROUP BY Name
ORDER BY Max_Score_Change DESC
LIMIT 10;
