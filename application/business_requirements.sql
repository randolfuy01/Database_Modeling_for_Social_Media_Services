-- Business Requirements
-- Randolf Uy 920265148

USE SocialMediaBackendDB;

-- 1. Business Requirement: Personalized Content Recommendations
/*
    Purpose:
        To dynamically recommend posts to users based on the tags they follow and their interaction history.
    
    Description:
        The system must analyze user activity and recommend posts that include tags the user frequently interacts with. 
        Recommendations should prioritize posts from active communities or those with higher engagement.
    
    Challenges:
        1. Requires joining multiple tables (e.g., Follow, Tag, Post, Community).
        2. Must calculate and rank posts based on tag popularity and user activity.
        3. Needs to update recommendations frequently without performance issues.
    
    Assumptions:
        1. Users frequently follow tags and interact with posts.
        2. Popularity is calculated as the total number of reactions or comments on a post.
    
    Implementation Plan:
        1. Create a view to calculate tag popularity.
        2. Use a stored procedure to generate recommendations based on user interactions.
*/

-- -------------------------------------------------------------------------
-- Step 1: Create a view to calculate tag popularity
-- -------------------------------------------------------------------------
CREATE OR REPLACE VIEW TagPopularity AS
    SELECT 
        t.tag_id,
        t.hashtag_text,
        COUNT(r.reaction_id) AS total_reactions,
        COUNT(c.comment_id) AS total_comments,
        (COUNT(r.reaction_id) + COUNT(c.comment_id)) AS popularity_score
    FROM
        Tag t
            LEFT JOIN
        Post_has_Tag pht ON t.tag_id = pht.Tag_tag_id
            LEFT JOIN
        Post p ON pht.Post_post_id = p.post_id
            LEFT JOIN
        Reaction r ON r.Post_post_id = p.post_id
            LEFT JOIN
        Comment c ON c.Post_post_id = p.post_id
    GROUP BY t.tag_id , t.hashtag_text;

-- -------------------------------------------------------------------------
-- Step 2: Create the stored procedure to generate recommendations
-- -------------------------------------------------------------------------

DELIMITER $$

DROP PROCEDURE IF EXISTS RecommendPosts$$

CREATE PROCEDURE RecommendPosts(IN user_id INT)
BEGIN
    -- Temporary table to store recommended posts
    CREATE TEMPORARY TABLE IF NOT EXISTS TempRecommendations (
        post_id INT,
        description VARCHAR(255),
        tag_popularity_score INT,
        community_activity_score INT,
        engagement_score INT
    );

    -- Clear temporary table before insertion
    DELETE FROM TempRecommendations;

    -- Insert data into the temporary table
    INSERT INTO TempRecommendations (post_id, description, tag_popularity_score, community_activity_score, engagement_score)
    SELECT 
        p.post_id,
        p.description,
        COALESCE(tp.popularity_score, 0) AS tag_popularity_score,
        COUNT(DISTINCT m.RegisteredUser_user_id) AS community_activity_score,
        (COALESCE(tp.popularity_score, 0) + COUNT(DISTINCT m.RegisteredUser_user_id)) AS engagement_score
    FROM 
        Follow f
    JOIN Tag t ON f.follow = t.RegisteredUser_user_id
    JOIN Post_has_Tag pht ON t.tag_id = pht.Tag_tag_id
    JOIN Post p ON pht.Post_post_id = p.post_id
    LEFT JOIN Membership m ON m.Community_community_id = p.RegisteredUser_user_id
    LEFT JOIN TagPopularity tp ON t.tag_id = tp.tag_id
    WHERE 
        f.user = user_id
    GROUP BY 
        p.post_id, p.description, tp.popularity_score;

    -- Return the recommended posts sorted by engagement score
    SELECT 
        post_id,
        description,
        tag_popularity_score,
        community_activity_score,
        engagement_score
    FROM 
        TempRecommendations
    ORDER BY 
        engagement_score DESC;

    -- No need to explicitly drop the temporary table, as it will be dropped automatically
END$$

DELIMITER ;

-- -------------------------------------------------------------------------

-- 2. Business Requirement: Community Engagement Metrics
/*
    Purpose:
        To calculate and maintain real-time engagement metrics for each community.
    
    Description:
        The system must compute metrics such as the number of active members, posts per day, 
        and average comments per post for each community. These metrics must update dynamically as data changes.
    
    Challenges:
        1. Involves real-time aggregation of data from multiple tables (e.g., Membership, Post, Comment).
        2. Requires efficient calculation for large datasets and frequent updates.
    
    Assumptions:
        1. Active members are those who interacted in the last 7 days.
        2. Metrics are stored in a summary table for fast access.
    
    Implementation Plan:
        Step 1: Create the `CommunityEngagementMetrics` summary table to store metrics.
        Step 2: Populate the summary table with initial engagement metrics.
        Step 3: Add a trigger to update active member counts dynamically on membership changes.
        Step 4: Add triggers to update post and comment metrics dynamically on post and comment changes.
*/

-- -------------------------------------------------------------------------
-- Step 1: Create the summary table to store metrics
-- -------------------------------------------------------------------------
DROP TABLE IF EXISTS CommunityEngagementMetrics;

CREATE TABLE CommunityEngagementMetrics (
    community_id INT NOT NULL,
    active_members INT DEFAULT 0,
    posts_per_day DECIMAL(10, 2) DEFAULT 0.0,
    avg_comments_per_post DECIMAL(10, 2) DEFAULT 0.0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (community_id)
);

-- -------------------------------------------------------------------------
-- Step 2: Populate the summary table with initial metrics
-- -------------------------------------------------------------------------
INSERT INTO CommunityEngagementMetrics (community_id, active_members, posts_per_day, avg_comments_per_post)
SELECT
    c.community_id,
    COUNT(DISTINCT m.RegisteredUser_user_id) AS active_members,
    COUNT(DISTINCT p.post_id) / 7.0 AS posts_per_day,
    IFNULL(AVG(cm.comment_count), 0) AS avg_comments_per_post
FROM
    Community c
LEFT JOIN Membership m ON c.community_id = m.Community_community_id AND m.date_joined >= DATE_SUB(NOW(), INTERVAL 7 DAY)
LEFT JOIN Post p ON c.community_id = p.RegisteredUser_user_id
LEFT JOIN (
    SELECT
        p.post_id,
        COUNT(c.comment_id) AS comment_count
    FROM
        Post p
    LEFT JOIN Comment c ON p.post_id = c.Post_post_id
    GROUP BY p.post_id
) cm ON cm.post_id = p.post_id
GROUP BY c.community_id;

-- -------------------------------------------------------------------------
-- Step 3: Add a trigger to update active member counts on membership changes
-- -------------------------------------------------------------------------
DELIMITER $$

DELIMITER $$

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS AfterMembershipInsert$$
DROP TRIGGER IF EXISTS AfterMembershipDelete$$

-- Create trigger for insert
CREATE TRIGGER AfterMembershipInsert
AFTER INSERT ON Membership
FOR EACH ROW
BEGIN
    UPDATE CommunityEngagementMetrics
    SET active_members = active_members + 1,
        last_updated = NOW()
    WHERE community_id = NEW.Community_community_id;
END$$

-- Create trigger for delete
CREATE TRIGGER AfterMembershipDelete
AFTER DELETE ON Membership
FOR EACH ROW
BEGIN
    UPDATE CommunityEngagementMetrics
    SET active_members = active_members - 1,
        last_updated = NOW()
    WHERE community_id = OLD.Community_community_id;
END$$

DELIMITER ;

-- -------------------------------------------------------------------------
-- Step 4: Add triggers to update post and comment metrics dynamically
-- -------------------------------------------------------------------------


DROP TRIGGER IF EXISTS AfterPostInsert;
DROP TRIGGER IF EXISTS AfterCommentInsert;

DELIMITER $$

CREATE TRIGGER AfterPostInsert
AFTER INSERT ON Post
FOR EACH ROW
BEGIN
    UPDATE CommunityEngagementMetrics
    SET posts_per_day = posts_per_day + (1 / 7.0),
        last_updated = NOW()
    WHERE community_id = NEW.RegisteredUser_user_id;
END$$

CREATE TRIGGER AfterCommentInsert
AFTER INSERT ON Comment
FOR EACH ROW
BEGIN
    UPDATE CommunityEngagementMetrics
    SET avg_comments_per_post = (
        SELECT IFNULL(AVG(cm.comment_count), 0)
        FROM (
            SELECT
                p.post_id,
                COUNT(c.comment_id) AS comment_count
            FROM
                Post p
            LEFT JOIN Comment c ON p.post_id = c.Post_post_id
            WHERE p.RegisteredUser_user_id = NEW.Post_post_id
            GROUP BY p.post_id
        ) cm
    ),
    last_updated = NOW()
    WHERE community_id = (
        SELECT RegisteredUser_user_id
        FROM Post
        WHERE post_id = NEW.Post_post_id
        LIMIT 1
    );
END$$

DELIMITER ;

-- -------------------------------------------------------------------------

-- 3. Business Requirement: Efficient Chat and Inbox Functionality
/*
    Purpose:
        To enhance the chat and inbox systems by enabling efficient tracking of unread messages and retrieval of chat history.
    
    Description:
        The system must support the following functionalities:
        1. Automatically update the count of unread messages for each user when new messages are sent or read.
        2. Allow users to retrieve the complete chat history for a specific chat, sorted by timestamp.

    Challenges:
        1. Requires real-time updates for unread message counts.
        2. Efficient retrieval of chat history for large datasets.

    Implementation Plan:
        1. Create a summary table `UnreadMessages` to track the unread message count for each user per chat.
        2. Add triggers to update unread message counts when messages are sent or read.
        3. Provide a stored procedure to retrieve chat history.
*/

-- -------------------------------------------------------------------------
-- Step 1: Create the summary table to track unread messages
-- -------------------------------------------------------------------------
DROP TABLE IF EXISTS UnreadMessages;

CREATE TABLE UnreadMessages (
    user_id INT NOT NULL,
    chat_id INT NOT NULL,
    unread_count INT DEFAULT 0,
    PRIMARY KEY (user_id, chat_id),
    FOREIGN KEY (user_id) REFERENCES RegisteredUser(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (chat_id) REFERENCES Chat(chat_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- -------------------------------------------------------------------------
-- Step 2: Add triggers to update unread message counts
-- -------------------------------------------------------------------------

DELIMITER $$

-- Trigger to increment unread count when a new message is added
DROP TRIGGER IF EXISTS AfterMessageInsert$$

CREATE TRIGGER AfterMessageInsert
AFTER INSERT ON Message
FOR EACH ROW
BEGIN
    -- Increment unread count for users in the chat (excluding sender)
    INSERT INTO UnreadMessages (user_id, chat_id, unread_count)
    SELECT 
        u.user_id, NEW.Chat_chat_id, 1
    FROM 
        Membership u
    WHERE 
        u.Community_community_id = NEW.Chat_chat_id
        AND u.user_id != NEW.RegisteredUser_user_id
    ON DUPLICATE KEY UPDATE 
        unread_count = unread_count + 1;
END$$

-- Trigger to reset unread count when a chat is read
DROP TRIGGER IF EXISTS AfterInboxUpdate$$

CREATE TRIGGER AfterInboxUpdate
AFTER UPDATE ON Inbox
FOR EACH ROW
BEGIN
    IF NEW.read = 1 THEN
        UPDATE UnreadMessages
        SET unread_count = 0
        WHERE user_id = NEW.RegisteredUser_user_id
          AND chat_id = NEW.Chat_chat_id;
    END IF;
END$$

DELIMITER ;

-- -------------------------------------------------------------------------
-- Step 3: Create a stored procedure to retrieve chat history
-- -------------------------------------------------------------------------

DELIMITER $$

DROP PROCEDURE IF EXISTS GetChatHistory$$

CREATE PROCEDURE GetChatHistory(IN chat_id INT)
BEGIN
    SELECT 
        m.message_id,
        m.text,
        m.timestamp,
        r.username AS sender
    FROM 
        Message m
    JOIN RegisteredUser r ON m.RegisteredUser_user_id = r.user_id
    WHERE 
        m.Chat_chat_id = chat_id
    ORDER BY 
        m.timestamp ASC;
END$$

DELIMITER ;

-- -------------------------------------------------------------------------

-- 4. Business Requirement: Search History and Metadata Analytics
/*
    Purpose:
        To provide insights into user search behavior and metadata trends for better personalization and analytics.
    
    Description:
        The system must support functionalities to:
        1. Track frequent search queries by users.
        2. Identify metadata trends, such as frequently used tags and recent activity.
        3. Aggregate insights for dashboard reporting or personalized user recommendations.

    Challenges:
        1. Efficient aggregation of large volumes of search and metadata information.
        2. Real-time updates for tracking frequently used search queries.
        3. Maintaining performance while analyzing JSON data in metadata.

    Implementation Plan:
        1. Create a view `SearchFrequency` to track frequent search queries per user.
        2. Create a stored procedure `GetMetadataTrends` to analyze metadata tags and trends.
        3. Add triggers to update the `SearchHistory` summary dynamically on new queries.
*/

-- -------------------------------------------------------------------------
-- Step 1: Create a view to track frequent search queries
-- -------------------------------------------------------------------------
DROP VIEW IF EXISTS SearchFrequency;

CREATE VIEW SearchFrequency AS
    SELECT 
        sh.Account_user_id,
        sh.query,
        COUNT(sh.query) AS query_count
    FROM 
        SearchHistory sh
    GROUP BY 
        sh.Account_user_id, sh.query
    ORDER BY 
        query_count DESC;

-- -------------------------------------------------------------------------
-- Step 2: Create a stored procedure to analyze metadata trends
-- -------------------------------------------------------------------------

DELIMITER $$

DROP PROCEDURE IF EXISTS GetMetadataTrends$$

CREATE PROCEDURE GetMetadataTrends(IN user_id INT)
BEGIN
    SELECT 
        m.meta_data_id,
        m.date AS metadata_date,
        JSON_EXTRACT(m.tags, '$.keywords') AS metadata_keywords,
        COUNT(JSON_EXTRACT(m.tags, '$.keywords')) AS keyword_count
    FROM 
        MetaData m
    WHERE 
        m.Account_user_id = user_id
    GROUP BY 
        JSON_EXTRACT(m.tags, '$.keywords')
    ORDER BY 
        keyword_count DESC;
END$$

DELIMITER ;

-- -------------------------------------------------------------------------
-- Step 3: Add triggers to dynamically update SearchHistory summary
-- -------------------------------------------------------------------------

DELIMITER $$

-- Trigger to log search frequency dynamically
DROP TRIGGER IF EXISTS AfterSearchInsert$$

CREATE TRIGGER AfterSearchInsert
AFTER INSERT ON SearchHistory
FOR EACH ROW
BEGIN
    -- Update query count for the new search
    INSERT INTO SearchHistory (Account_account_id, Account_user_id, search_id, query, timestamp)
    VALUES 
        (NEW.Account_account_id, NEW.Account_user_id, NEW.search_id, NEW.query, NOW())
    ON DUPLICATE KEY UPDATE 
        query = query + 1;
END$$

DELIMITER ;

-- -------------------------------------------------------------------------


-- 5. Business Requirement: Device and Address Tracking for Login Events
/*
    Purpose:
        To enhance login tracking by associating devices and addresses with login events, enabling better security monitoring and analytics.
    
    Description:
        The system must provide:
        1. Insights into device usage for each user, including associated addresses.
        2. Analysis of login trends (e.g., successful vs. failed logins, login times).
        3. Alerts for unusual activity, such as logins from new devices or addresses.

    Challenges:
        1. Efficiently managing relationships between devices, addresses, and login events.
        2. Aggregating and analyzing data for large user bases.
        3. Enabling real-time monitoring for unusual activity.

    Implementation Plan:
        1. Create a view `DeviceUsage` to associate devices and addresses with login events.
        2. Create a stored procedure `GetLoginTrends` to analyze login trends for a specific user.
        3. Add triggers to monitor and log unusual activity during login events.
*/

-- -------------------------------------------------------------------------
-- Step 1: Create a view to track device usage and addresses for logins
-- -------------------------------------------------------------------------
DROP VIEW IF EXISTS DeviceUsage;

CREATE VIEW DeviceUsage AS
    SELECT 
        l.Account_user_id,
        l.time_login,
        l.valid_login,
        d.device_id,
        d.mac_address,
        d.operating_system,
        a.idAddress AS address_id,
        a.Street AS address_street,
        a.City AS address_city,
        a.Zipcode AS address_zip,
        a.Country AS address_country
    FROM 
        Login l
    JOIN Device d ON l.Device_device_id = d.device_id
    JOIN Address a ON d.Address_idAddress = a.idAddress;

-- -------------------------------------------------------------------------
-- Step 2: Create a stored procedure to analyze login trends
-- -------------------------------------------------------------------------

DELIMITER $$

DROP PROCEDURE IF EXISTS GetLoginTrends$$

CREATE PROCEDURE GetLoginTrends(IN user_id INT)
BEGIN
    SELECT 
        DATE(l.time_login) AS login_date,
        COUNT(CASE WHEN l.valid_login = 1 THEN 1 ELSE NULL END) AS successful_logins,
        COUNT(CASE WHEN l.valid_login = 0 THEN 1 ELSE NULL END) AS failed_logins,
        d.operating_system,
        d.mac_address
    FROM 
        Login l
    JOIN Device d ON l.Device_device_id = d.device_id
    WHERE 
        l.Account_user_id = user_id
    GROUP BY 
        DATE(l.time_login), d.operating_system, d.mac_address
    ORDER BY 
        login_date DESC;
END$$

DELIMITER ;

-- -------------------------------------------------------------------------
-- Step 3: Add triggers to monitor unusual login activity
-- -------------------------------------------------------------------------

DELIMITER $$

-- Trigger to log unusual activity for new devices or addresses

DROP TRIGGER IF EXISTS AfterLoginInsert$$

DELIMITER $$

CREATE TRIGGER AfterLoginInsert
AFTER INSERT ON Login
FOR EACH ROW
BEGIN
    -- Check if the device is new
    IF NOT EXISTS (
        SELECT 1 
        FROM Device d
        WHERE d.device_id = NEW.Device_device_id
    ) THEN
        INSERT INTO UnusualActivityLog (event_type, user_id, event_timestamp, details)
        VALUES ('New Device Login', NEW.Account_user_id, NEW.time_login, CONCAT('Device ID: ', NEW.Device_device_id));
    END IF;

    -- Check if the address is associated with the device
    IF NOT EXISTS (
        SELECT 1 
        FROM Address a
        JOIN Device d ON a.idAddress = d.Address_idAddress
        WHERE d.device_id = NEW.Device_device_id
    ) THEN
        INSERT INTO UnusualActivityLog (event_type, user_id, event_timestamp, details)
        VALUES ('New Address Login', NEW.Account_user_id, NEW.time_login, CONCAT('Device ID: ', NEW.Device_device_id, ', Address: Not Associated'));
    END IF;
END$$

DELIMITER ;

-- -------------------------------------------------------------------------

-- 6. Business Requirement: Payment Tracking and Fraud Detection
/*
    Purpose:
        To enhance the payment system by providing analytics on user payments and enabling fraud detection based on payment anomalies.
    
    Description:
        The system must support:
        1. Tracking total payments, payment frequency, and preferred payment methods per user.
        2. Detecting unusual payment patterns such as abnormally high transaction amounts or frequent failed payments.
        3. Providing aggregated data for reporting and analytics.

    Challenges:
        1. Managing real-time updates for payment summaries.
        2. Detecting and flagging anomalies across large datasets.
        3. Efficiently aggregating data for real-time analysis and dashboards.

    Implementation Plan:
        1. Create a summary table `PaymentAnalytics` to store payment data per user.
        2. Add triggers to update payment summaries dynamically.
        3. Add a stored procedure `GetPaymentStats` for detailed payment insights.
        4. Create a trigger to log potential fraud cases during payment processing.
*/

-- -------------------------------------------------------------------------
-- Step 1: Create a summary table for payment data
-- -------------------------------------------------------------------------

DROP TABLE IF EXISTS PaymentAnalytics;

CREATE TABLE PaymentAnalytics (
    user_id INT NOT NULL,
    total_payments DECIMAL(10, 2) DEFAULT 0.0,
    payment_count INT DEFAULT 0,
    preferred_payment_type VARCHAR(45),
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES RegisteredUser(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- -------------------------------------------------------------------------
-- Step 2: Add triggers to update payment summaries dynamically
-- -------------------------------------------------------------------------

DELIMITER $$

DROP TRIGGER IF EXISTS AfterPaymentInsert$$

CREATE TRIGGER AfterPaymentInsert
AFTER INSERT ON Payment
FOR EACH ROW
BEGIN
    -- Update or insert payment data into PaymentAnalytics
    INSERT INTO PaymentAnalytics (user_id, total_payments, payment_count, preferred_payment_type, last_updated)
    VALUES (
        NEW.RegisteredUser_user_id,
        NEW.charge_amount,
        1,
        NEW.payment_type,
        NOW()
    )
    ON DUPLICATE KEY UPDATE
        total_payments = total_payments + NEW.charge_amount,
        payment_count = payment_count + 1,
        preferred_payment_type = NEW.payment_type,
        last_updated = NOW();
END$$

-- -------------------------------------------------------------------------
-- Step 3: Create a stored procedure for payment insights
-- -------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS GetPaymentStats$$

CREATE PROCEDURE GetPaymentStats(IN user_id INT)
BEGIN
    SELECT 
        p.payment_id,
        p.charge_amount,
        p.payment_type,
        p.date,
        pa.total_payments,
        pa.payment_count,
        pa.preferred_payment_type
    FROM 
        Payment p
    JOIN PaymentAnalytics pa ON p.RegisteredUser_user_id = pa.user_id
    WHERE 
        p.RegisteredUser_user_id = user_id
    ORDER BY 
        p.date DESC;
END$$

DELIMITER ;

-- -------------------------------------------------------------------------
-- Step 4: Add a trigger to detect potential fraud cases
-- -------------------------------------------------------------------------

DELIMITER $$

-- Drop the trigger if it already exists
DROP TRIGGER IF EXISTS AfterPaymentInsertFraudCheck$$

CREATE TRIGGER AfterPaymentInsertFraudCheck
AFTER INSERT ON Payment
FOR EACH ROW
BEGIN
    -- Detect high transaction amounts
    IF NEW.charge_amount > 10000 THEN
        INSERT INTO UnusualActivityLog (event_type, user_id, event_timestamp, details)
        VALUES ('High Transaction Amount', NEW.RegisteredUser_user_id, NOW(), 
                CONCAT('Payment ID: ', NEW.payment_id, ', Amount: ', NEW.charge_amount));
    END IF;

    -- Detect failed payments
    IF NEW.paid = 0 THEN
        INSERT INTO UnusualActivityLog (event_type, user_id, event_timestamp, details)
        VALUES ('Failed Payment', NEW.RegisteredUser_user_id, NOW(), 
                CONCAT('Payment ID: ', NEW.payment_id));
    END IF;
END$$

DELIMITER ;

-- -------------------------------------------------------------------------