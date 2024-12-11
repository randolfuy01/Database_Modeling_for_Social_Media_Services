-- This script populates the social media backend database
-- Randolf Uy 920265148
-- Milestone 4

USE SocialMediaBackendDB;

-- 1. RegisteredUser
INSERT INTO `RegisteredUser` (`username`, `description`, `profile_picture`)
VALUES
    ('john_doe', 'A passionate photographer.', NULL),
    ('jane_smith', 'Loves coding and design.', NULL),
    ('alex_jones', 'Tech enthusiast and writer.', NULL),
    ('emily_davis', 'Food blogger and traveler.', NULL),
    ('michael_brown', 'Fitness trainer and motivator.', NULL),
    ('sarah_wilson', 'Entrepreneur and speaker.', NULL),
    ('david_clark', 'Musician and artist.', NULL),
    ('laura_adams', 'Nature lover and photographer.', NULL),
    ('daniel_taylor', 'Software engineer and gamer.', NULL),
    ('emma_walker', 'Bookworm and writer.', NULL);


-- 2. Account
INSERT INTO `Account` (`account_id`, `password`, `email`, `user_id`)
VALUES
    (1, 'password123', 'john_doe@example.com', 1),
    (2, 'securepass', 'jane_smith@example.com', 2),
    (3, 'alex123!', 'alex_jones@example.com', 3),
    (4, 'travel@life', 'emily_davis@example.com', 4),
    (5, 'fit4life', 'michael_brown@example.com', 5),
    (6, 'bizwoman99', 'sarah_wilson@example.com', 6),
    (7, 'musicislife', 'david_clark@example.com', 7),
    (8, 'nature@123', 'laura_adams@example.com', 8),
    (9, 'code@work', 'daniel_taylor@example.com', 9),
    (10, 'booksrule', 'emma_walker@example.com', 10);

-- 3. Address
INSERT INTO `Address` (`idAddress`, `City`, `Country`, `Zipcode`) 
VALUES
    (1, 'New York', 'USA', '10001'),
    (2, 'Los Angeles', 'USA', '90001'),
    (3, 'Chicago', 'USA', '60601'),
    (4, 'Houston', 'USA', '77001'),
    (5, 'Phoenix', 'USA', '85001'),
    (6, 'Philadelphia', 'USA', '19101'),
    (7, 'San Antonio', 'USA', '78201'),
    (8, 'San Diego', 'USA', '92101'),
    (9, 'Dallas', 'USA', '75201'),
    (10, 'San Jose', 'USA', '95101');

-- 4. Device
INSERT INTO `Device` (`device_id`, `mac_address`, `operating_system`, `Address_idAddress`) 
VALUES
    (1, 'AA:BB:CC:DD:EE:01', 'Windows 10', 1),
    (2, 'AA:BB:CC:DD:EE:02', 'MacOS Monterey', 2),
    (3, 'AA:BB:CC:DD:EE:03', 'Ubuntu 22.04', 3),
    (4, 'AA:BB:CC:DD:EE:04', 'Windows 11', 4),
    (5, 'AA:BB:CC:DD:EE:05', 'iOS 15', 5),
    (6, 'AA:BB:CC:DD:EE:06', 'Android 12', 6),
    (7, 'AA:BB:CC:DD:EE:07', 'Windows 10', 7),
    (8, 'AA:BB:CC:DD:EE:08', 'MacOS Big Sur', 8),
    (9, 'AA:BB:CC:DD:EE:09', 'Linux Mint', 9),
    (10, 'AA:BB:CC:DD:EE:10', 'ChromeOS', 10);

-- 5. SearchHistory
INSERT INTO `SearchHistory` (`search_id`, `query`, `timestamp`, `Account_account_id`, `Account_user_id`) 
VALUES
    (1, 'How to build a website?', NOW(), 1, 1),
    (2, 'Top design tools in 2024', NOW(), 2, 2),
    (3, 'Best laptops for developers', NOW(), 3, 3),
    (4, 'Travel destinations 2024', NOW(), 4, 4),
    (5, 'Fitness tips for beginners', NOW(), 5, 5),
    (6, 'How to start a business?', NOW(), 6, 6),
    (7, 'Guitar tutorials for beginners', NOW(), 7, 7),
    (8, 'Photography tips', NOW(), 8, 8),
    (9, 'Best gaming laptops', NOW(), 9, 9),
    (10, 'How to write a novel?', NOW(), 10, 10);

    
-- 6. Follow
INSERT INTO `Follow` (`user`, `follow`, `date`) 
VALUES
    (1, 2, NOW()),
    (2, 3, NOW()),
    (3, 4, NOW()),
    (4, 5, NOW()),
    (5, 6, NOW()),
    (6, 7, NOW()),
    (7, 8, NOW()),
    (8, 9, NOW()),
    (9, 10, NOW()),
    (10, 1, NOW());


-- 7. Post
INSERT INTO `Post` (`post_id`, `description`, `image`, `date`, `RegisteredUser_user_id`, `PostType`) 
VALUES
    (1, 'Exploring the city!', NULL, NOW(), 1, 'I'),
    (2, 'New design trends', NULL, NOW(), 2, 'T'),
    (3, 'Linux is amazing!', NULL, NOW(), 3, 'T'),
    (4, 'Vacation pictures', NULL, NOW(), 4, 'I'),
    (5, 'Starting my fitness journey!', NULL, NOW(), 5, 'T'),
    (6, 'Business updates', NULL, NOW(), 6, 'T'),
    (7, 'New music release!', NULL, NOW(), 7, 'T'),
    (8, 'Photography challenge', NULL, NOW(), 8, 'I'),
    (9, 'Gaming marathon', NULL, NOW(), 9, 'T'),
    (10, 'Writing tips', NULL, NOW(), 10, 'T');


-- 8. Reaction
INSERT INTO `Reaction` (`Emoji`, `reaction_id`, `RegisteredUser_user_id`, `Post_post_id`) 
VALUES
    (1, 'like', 2, 1),
    (2, 'love', 3, 2),
    (3, 'haha', 4, 3),
    (4, 'wow', 5, 4),
    (5, 'sad', 6, 5),
    (6, 'angry', 7, 6),
    (7, 'like', 8, 7),
    (8, 'love', 9, 8),
    (9, 'wow', 10, 9),
    (10, 'sad', 1, 10);


-- 9. Comment
INSERT INTO `Comment` (`comment_id`, `timestamp`, `text`, `Post_post_id`, `RegisteredUser_user_id`)
VALUES
    (1, NOW(), 'Great shot!', 1, 2),
    (2, NOW(), 'Very useful!', 2, 3),
    (3, NOW(), 'Linux rules!', 3, 4),
    (4, NOW(), 'Looks awesome!', 4, 5),
    (5, NOW(), 'Good luck!', 5, 6),
    (6, NOW(), 'Inspiring!', 6, 7),
    (7, NOW(), 'Amazing!', 7, 8),
    (8, NOW(), 'Love this!', 8, 9),
    (9, NOW(), 'Great idea!', 9, 10),
    (10, NOW(), 'Fantastic!', 10, 1);

-- 10. Tag
INSERT INTO `Tag` (`tag_id`, `use_count`, `hashtag_text`, `RegisteredUser_user_id`) 
VALUES
    (1, 5, '#photography', 1),
    (2, 8, '#coding', 2),
    (3, 12, '#linux', 3),
    (4, 6, '#travel', 4),
    (5, 10, '#fitness', 5),
    (6, 7, '#business', 6),
    (7, 3, '#music', 7),
    (8, 4, '#nature', 8),
    (9, 2, '#gaming', 9),
    (10, 9, '#writing', 10);

-- 11. Feed
INSERT INTO `Feed` (`feed_id`, `time_added`, `time_spend`, `RegisteredUser_user_id`) 
VALUES
    (1, '2024-01-01 10:00:00', '15 mins', 1),
    (2, '2024-01-01 11:00:00', '10 mins', 2),
    (3, '2024-01-01 12:00:00', '20 mins', 3),
    (4, '2024-01-01 13:00:00', '25 mins', 4),
    (5, '2024-01-01 14:00:00', '30 mins', 5),
    (6, '2024-01-01 15:00:00', '35 mins', 6),
    (7, '2024-01-01 16:00:00', '40 mins', 7),
    (8, '2024-01-01 17:00:00', '45 mins', 8),
    (9, '2024-01-01 18:00:00', '50 mins', 9),
    (10, '2024-01-01 19:00:00', '60 mins', 10);

-- 12. Permissions
INSERT INTO `Permissions` (`permission_id`, `permission_title`, `description`, `level`, `PermissionType`) 
VALUES
    (1, 'Create Post', 'Can create posts', 'Low', 'A'),
    (2, 'Delete Post', 'Can delete posts', 'Medium', 'A'),
    (3, 'Edit Post', 'Can edit posts', 'Medium', 'B'),
    (4, 'Manage Users', 'Can manage user accounts', 'High', 'C'),
    (5, 'Moderate Comments', 'Can moderate comments', 'High', 'B');
    
-- 13. Role
INSERT INTO `Role` (`role_id`, `status`, `Permissions_permission_id`) 
VALUES
    (1, 'Active', 1),
    (2, 'Active', 2),
    (3, 'Inactive', 3),
    (4, 'Active', 4),
    (5, 'Active', 5);

-- 14. Community
INSERT INTO `Community` (`community_id`, `description`, `logo`, `name`) 
VALUES
    (1, 'A community for photographers', NULL, 'Photography Club'),
    (2, 'A place for coding enthusiasts', NULL, 'Coders Hub'),
    (3, 'All things Linux', NULL, 'Linux Lovers'),
    (4, 'For travelers around the world', NULL, 'Travelers Group'),
    (5, 'Fitness inspiration and tips', NULL, 'Fitness Squad');

-- 15. Membership
INSERT INTO `Membership` (`RegisteredUser_user_id`, `Community_community_id`, `date_joined`, `community_status`) 
VALUES
    (1, 1, '2024-01-01', 'Active'),
    (2, 2, '2024-01-02', 'Active'),
    (3, 3, '2024-01-03', 'Active'),
    (4, 4, '2024-01-04', 'Inactive'),
    (5, 5, '2024-01-05', 'Active'),
    (6, 1, '2024-01-06', 'Active'),
    (7, 2, '2024-01-07', 'Inactive'),
    (8, 3, '2024-01-08', 'Active'),
    (9, 4, '2024-01-09', 'Active'),
    (10, 5, '2024-01-10', 'Active');

-- 16. Assignment
INSERT INTO `Assignment` (`RegisteredUser_user_id`, `Role_role_id`, `assigned_date`) 
VALUES
    (1, 1, '2024-01-01'),
    (2, 2, '2024-01-02'),
    (3, 3, '2024-01-03'),
    (4, 4, '2024-01-04'),
    (5, 5, '2024-01-05'),
    (6, 1, '2024-01-06'),
    (7, 2, '2024-01-07'),
    (8, 3, '2024-01-08'),
    (9, 4, '2024-01-09'),
    (10, 5, '2024-01-10');

-- 17. Event
INSERT INTO `Event` (`event_id`, `description`, `event_name`, `image`, `location`)
VALUES
    (1, 'Photography Workshop', 'Photography 101', NULL, 'New York'),
    (2, 'Coding Bootcamp', 'Learn to Code', NULL, 'San Francisco'),
    (3, 'Linux Meetup', 'Linux for Beginners', NULL, 'Chicago'),
    (4, 'Travel Hacks', 'Smart Traveling', NULL, 'Houston'),
    (5, 'Fitness Seminar', 'Get Fit Today', NULL, 'Los Angeles');

-- 18. Host
INSERT INTO `Host` (`Community_community_id`, `Event_event_id`, `host_id`, `date_posted`) 
VALUES
    (1, 1, NULL, '2024-01-01'),
    (2, 2, NULL, '2024-01-02'),
    (3, 3, NULL, '2024-01-03'),
    (4, 4, NULL, '2024-01-04'),
    (5, 5, NULL, '2024-01-05');

-- 19. EventApplication
INSERT INTO `EventApplication` (`RegisteredUser_user_id`, `Event_event_id`, `application_date`) 
VALUES
    (1, 1, '2024-01-01'),
    (2, 2, '2024-01-02'),
    (3, 3, '2024-01-03'),
    (4, 4, '2024-01-04'),
    (5, 5, '2024-01-05'),
    (6, 1, '2024-01-06'),
    (7, 2, '2024-01-07'),
    (8, 3, '2024-01-08'),
    (9, 4, '2024-01-09'),
    (10, 5, '2024-01-10');

-- 20. Post_has_Tag
INSERT INTO `Post_has_Tag` (`Post_post_id`, `Tag_tag_id`, `Tag_RegisteredUser_user_id`, `date_posted`)
VALUES
    (1, 1, 1, '2024-01-01'),
    (2, 2, 2, '2024-01-02'),
    (3, 3, 3, '2024-01-03'),
    (4, 4, 4, '2024-01-04'),
    (5, 5, 5, '2024-01-05'),
    (6, 6, 6, '2024-01-06'),
    (7, 7, 7, '2024-01-07'),
    (8, 8, 8, '2024-01-08'),
    (9, 9, 9, '2024-01-09'),
    (10, 10, 10, '2024-01-10');

-- 21. Feed_has_Post
INSERT INTO `Feed_has_Post` (`Feed_feed_id`, `Feed_RegisteredUser_user_id`, `Post_post_id`, `date_posted`, `viewed`)
VALUES
    (1, 1, 1, '2024-01-01', 1),
    (2, 2, 2, '2024-01-02', 1),
    (3, 3, 3, '2024-01-03', 0),
    (4, 4, 4, '2024-01-04', 1),
    (5, 5, 5, '2024-01-05', 1),
    (6, 6, 6, '2024-01-06', 0),
    (7, 7, 7, '2024-01-07', 1),
    (8, 8, 8, '2024-01-08', 1),
    (9, 9, 9, '2024-01-09', 1),
    (10, 10, 10, '2024-01-10', 0);

-- 24. Chat
INSERT INTO `Chat` (`chat_id`, `chat_name`, `icon`, `background_image`)
VALUES
    (1, 'Photography Chat', NULL, NULL),
    (2, 'Coding Chat', NULL, NULL),
    (3, 'Linux Chat', NULL, NULL),
    (4, 'Travel Chat', NULL, NULL),
    (5, 'Fitness Chat', NULL, NULL),
    (6, 'Business Chat', NULL, NULL),
    (7, 'Music Chat', NULL, NULL),
    (8, 'Nature Chat', NULL, NULL),
    (9, 'Gaming Chat', NULL, NULL),
    (10, 'Writing Chat', NULL, NULL);

-- 23. Inbox
INSERT INTO `Inbox` (`updated`, `read`, `RegisteredUser_user_id`, `Chat_chat_id`)
VALUES
    ('2024-01-01 10:00:00', 0, 1, 1),
    ('2024-01-01 11:00:00', 1, 2, 2),
    ('2024-01-01 12:00:00', 0, 3, 3),
    ('2024-01-01 13:00:00', 1, 4, 4),
    ('2024-01-01 14:00:00', 1, 5, 5),
    ('2024-01-01 15:00:00', 0, 6, 6),
    ('2024-01-01 16:00:00', 1, 7, 7),
    ('2024-01-01 17:00:00', 0, 8, 8),
    ('2024-01-01 18:00:00', 1, 9, 9),
    ('2024-01-01 19:00:00', 0, 10, 10);

-- 25. CommunityFeed
INSERT INTO `CommunityFeed` (`Community_community_id`, `Post_post_id`, `Updated`)
VALUES
    (1, 1, '2024-01-01'),
    (2, 2, '2024-01-02'),
    (3, 3, '2024-01-03'),
    (4, 4, '2024-01-04'),
    (5, 5, '2024-01-05'),
    (1, 6, '2024-01-06'),
    (2, 7, '2024-01-07'),
    (3, 8, '2024-01-08'),
    (4, 9, '2024-01-09'),
    (5, 10, '2024-01-10');
