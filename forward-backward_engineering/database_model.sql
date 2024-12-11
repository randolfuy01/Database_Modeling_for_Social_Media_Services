-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
DROP DATABASE IF EXISTS SocialMediaBackendDB;
CREATE DATABASE IF NOT EXISTS SocialMediaBackendDB;
USE SocialMediaBackendDB;

-- -----------------------------------------------------
-- Table `RegisteredUser`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `RegisteredUser` ;

CREATE TABLE IF NOT EXISTS `RegisteredUser` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(128) NOT NULL,
  `description` VARCHAR(256) NULL,
  `profile_picture` BLOB NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `user_id_UNIQUE` (`user_id` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Account`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Account` ;

CREATE TABLE IF NOT EXISTS `Account` (
  `account_id` INT NOT NULL,
  `password` VARCHAR(255) NULL,
  `email` VARCHAR(32) NOT NULL,
  `user_id` INT NOT NULL,
  PRIMARY KEY (`account_id`, `user_id`),
  INDEX `fk_Account_RegisteredUser1_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_Account_RegisteredUser1`
    FOREIGN KEY (`user_id`)
    REFERENCES `RegisteredUser` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `EmailReminder`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `EmailReminder` ;

CREATE TABLE IF NOT EXISTS `EmailReminder` (
  `email_reminder_id` INT NOT NULL AUTO_INCREMENT,
  `last_update` DATETIME NULL,
  `custom_message` VARCHAR(255) NULL,
  `Account_account_id` INT NOT NULL,
  `Account_user_id` INT NOT NULL,
  PRIMARY KEY (`email_reminder_id`),
  INDEX `fk_EmailReminder_Account1_idx` (`Account_account_id`, `Account_user_id`),
  CONSTRAINT `fk_EmailReminder_Account1`
    FOREIGN KEY (`Account_account_id`, `Account_user_id`)
    REFERENCES `Account` (`account_id`, `user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Address`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Address` ;

CREATE TABLE IF NOT EXISTS `Address` (
  `idAddress` INT NOT NULL,
  `City` VARCHAR(45) NULL,
  `Country` VARCHAR(45) NULL,
  `Zipcode` VARCHAR(45) NULL,
  `Street` VARCHAR(45) NULL,
  PRIMARY KEY (`idAddress`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Device`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Device` ;

CREATE TABLE IF NOT EXISTS `Device` (
  `device_id` INT NOT NULL,
  `mac_address` VARCHAR(45) NULL,
  `operating_system` VARCHAR(45) NULL,
  `Address_idAddress` INT NOT NULL,
  PRIMARY KEY (`device_id`, `Address_idAddress`),
  UNIQUE INDEX `idDevice_UNIQUE` (`device_id` ASC) VISIBLE,
  INDEX `fk_Device_Address1_idx` (`Address_idAddress` ASC) VISIBLE,
  CONSTRAINT `fk_Device_Address1`
    FOREIGN KEY (`Address_idAddress`)
    REFERENCES `Address` (`idAddress`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Login`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Login` ;

CREATE TABLE IF NOT EXISTS `Login` (
  `Account_account_id` INT NOT NULL,
  `Account_user_id` INT NOT NULL,
  `Device_device_id` INT NOT NULL,
  `time_login` DATETIME NULL,
  `valid_login` TINYINT NULL,
  PRIMARY KEY (`Account_account_id`, `Account_user_id`, `Device_device_id`),
  INDEX `fk_Account_has_Device_Device1_idx` (`Device_device_id`),
  INDEX `fk_Account_has_Device_Account1_idx` (`Account_account_id`, `Account_user_id`),
  CONSTRAINT `fk_Account_has_Device_Account1`
    FOREIGN KEY (`Account_account_id`, `Account_user_id`)
    REFERENCES `Account` (`account_id`, `user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Account_has_Device_Device1`
    FOREIGN KEY (`Device_device_id`)
    REFERENCES `Device` (`device_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



-- -----------------------------------------------------
-- Table `MetaData`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `MetaData` ;

CREATE TABLE IF NOT EXISTS `MetaData` (
  `meta_data_id` INT NOT NULL AUTO_INCREMENT,
  `date` DATETIME NULL,
  `tags` JSON NULL,
  `Account_account_id` INT NOT NULL,
  `Account_user_id` INT NOT NULL,
  PRIMARY KEY (`meta_data_id`),
  UNIQUE INDEX `idMetaData_UNIQUE` (`meta_data_id` ASC) VISIBLE,
  INDEX `fk_MetaData_Account1_idx` (`Account_account_id` ASC, `Account_user_id` ASC) VISIBLE,
  CONSTRAINT `fk_MetaData_Account1`
    FOREIGN KEY (`Account_account_id` , `Account_user_id`)
    REFERENCES `Account` (`account_id` , `user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SearchHistory`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `SearchHistory` ;

CREATE TABLE IF NOT EXISTS `SearchHistory` (
  `search_id` INT NOT NULL,
  `timestamp` VARCHAR(45) NULL,
  `query` VARCHAR(45) NULL,
  `Account_account_id` INT NOT NULL,
  `Account_user_id` INT NOT NULL,
  PRIMARY KEY (`search_id`),
  INDEX `fk_SearchHistory_Account1_idx` (`Account_account_id` ASC, `Account_user_id` ASC) VISIBLE,
  CONSTRAINT `fk_SearchHistory_Account1`
    FOREIGN KEY (`Account_account_id` , `Account_user_id`)
    REFERENCES `Account` (`account_id` , `user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Follow`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Follow` ;

CREATE TABLE IF NOT EXISTS `Follow` (
  `user` INT NOT NULL,
  `follow` INT NOT NULL,
  `date` DATETIME NULL,
  PRIMARY KEY (`user`, `follow`),
  INDEX `fk_RegisteredUser_has_RegisteredUser_RegisteredUser2_idx` (`follow` ASC) VISIBLE,
  INDEX `fk_RegisteredUser_has_RegisteredUser_RegisteredUser1_idx` (`user` ASC) VISIBLE,
  CONSTRAINT `fk_RegisteredUser_has_RegisteredUser_RegisteredUser1`
    FOREIGN KEY (`user`)
    REFERENCES `RegisteredUser` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_RegisteredUser_has_RegisteredUser_RegisteredUser2`
    FOREIGN KEY (`follow`)
    REFERENCES `RegisteredUser` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Event`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Event` ;

CREATE TABLE IF NOT EXISTS `Event` (
  `event_id` INT NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(255) NULL,
  `event_name` VARCHAR(128) NULL,
  `image` BLOB NULL,
  `location` VARCHAR(45) NULL,
  PRIMARY KEY (`event_id`),
  UNIQUE INDEX `event_id_UNIQUE` (`event_id` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Chat`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Chat` ;

CREATE TABLE IF NOT EXISTS `Chat` (
  `chat_id` INT NOT NULL AUTO_INCREMENT,
  `chat_name` VARCHAR(100) NULL,
  `icon` VARCHAR(45) NULL,
  `background_image` BLOB NULL,
  PRIMARY KEY (`chat_id`),
  UNIQUE INDEX `chat_id_UNIQUE` (`chat_id` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Message`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Message` ;

CREATE TABLE IF NOT EXISTS `Message` (
  `message_id` INT NOT NULL AUTO_INCREMENT,
  `text` TEXT(255) NULL,
  `timestamp` DATETIME NULL,
  `Chat_chat_id` INT NOT NULL,
  `RegisteredUser_user_id` INT NOT NULL,
  PRIMARY KEY (`message_id`),
  UNIQUE INDEX `message_id_UNIQUE` (`message_id` ASC) VISIBLE,
  INDEX `fk_Message_Chat1_idx` (`Chat_chat_id` ASC) VISIBLE,
  INDEX `fk_Message_RegisteredUser1_idx` (`RegisteredUser_user_id` ASC) VISIBLE,
  CONSTRAINT `fk_Message_Chat1`
    FOREIGN KEY (`Chat_chat_id`)
    REFERENCES `Chat` (`chat_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Message_RegisteredUser1`
    FOREIGN KEY (`RegisteredUser_user_id`)
    REFERENCES `RegisteredUser` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Payment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Payment` ;

CREATE TABLE IF NOT EXISTS `Payment` (
  `payment_id` INT NOT NULL AUTO_INCREMENT,
  `charge_amount` VARCHAR(45) NULL,
  `paid` TINYINT NULL,
  `payment_type` VARCHAR(45) NULL,
  `date` DATETIME NULL,
  `RegisteredUser_user_id` INT NOT NULL,
  PRIMARY KEY (`payment_id`),
  INDEX `fk_Payment_RegisteredUser1_idx` (`RegisteredUser_user_id` ASC) VISIBLE,
  CONSTRAINT `fk_Payment_RegisteredUser1`
    FOREIGN KEY (`RegisteredUser_user_id`)
    REFERENCES `RegisteredUser` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Post`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Post` ;

CREATE TABLE IF NOT EXISTS `Post` (
  `post_id` INT NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(255) NULL,
  `image` BLOB NULL,
  `date` DATETIME NULL,
  `RegisteredUser_user_id` INT NOT NULL,
  `PostType` CHAR(1) NOT NULL,
  PRIMARY KEY (`post_id`),
  UNIQUE INDEX `post_id_UNIQUE` (`post_id` ASC) VISIBLE,
  INDEX `fk_Post_RegisteredUser1_idx` (`RegisteredUser_user_id` ASC) VISIBLE,
  CONSTRAINT `fk_Post_RegisteredUser1`
    FOREIGN KEY (`RegisteredUser_user_id`)
    REFERENCES `RegisteredUser` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Comment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Comment` ;

CREATE TABLE IF NOT EXISTS `Comment` (
  `comment_id` INT NOT NULL AUTO_INCREMENT,
  `timestamp` DATETIME NOT NULL,
  `text` VARCHAR(255) NOT NULL,
  `Post_post_id` INT NOT NULL,
  `RegisteredUser_user_id` INT NOT NULL,
  PRIMARY KEY (`comment_id`, `Post_post_id`),
  INDEX `fk_Comment_Post1_idx` (`Post_post_id` ASC) VISIBLE,
  INDEX `fk_Comment_RegisteredUser1_idx` (`RegisteredUser_user_id` ASC) VISIBLE,
  CONSTRAINT `fk_Comment_Post1`
    FOREIGN KEY (`Post_post_id`)
    REFERENCES `Post` (`post_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Comment_RegisteredUser1`
    FOREIGN KEY (`RegisteredUser_user_id`)
    REFERENCES `RegisteredUser` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Reaction`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Reaction` ;

CREATE TABLE IF NOT EXISTS `Reaction` (
  `Emoji` INT NOT NULL,
  `reaction_id` VARCHAR(45) NULL,
  `RegisteredUser_user_id` INT NOT NULL,
  `Post_post_id` INT NOT NULL,
  PRIMARY KEY (`Emoji`),
  INDEX `fk_Reaction_RegisteredUser1_idx` (`RegisteredUser_user_id` ASC) VISIBLE,
  INDEX `fk_Reaction_Post1_idx` (`Post_post_id` ASC) VISIBLE,
  CONSTRAINT `fk_Reaction_RegisteredUser1`
    FOREIGN KEY (`RegisteredUser_user_id`)
    REFERENCES `RegisteredUser` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Reaction_Post1`
    FOREIGN KEY (`Post_post_id`)
    REFERENCES `Post` (`post_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Tag`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Tag` ;

CREATE TABLE IF NOT EXISTS `Tag` (
  `tag_id` INT NOT NULL AUTO_INCREMENT,
  `use_count` INT NULL,
  `hashtag_text` VARCHAR(45) NULL,
  `RegisteredUser_user_id` INT NOT NULL,
  PRIMARY KEY (`tag_id`, `RegisteredUser_user_id`),
  INDEX `fk_Tag_RegisteredUser1_idx` (`RegisteredUser_user_id` ASC) VISIBLE,
  CONSTRAINT `fk_Tag_RegisteredUser1`
    FOREIGN KEY (`RegisteredUser_user_id`)
    REFERENCES `RegisteredUser` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Feed`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Feed` ;

CREATE TABLE IF NOT EXISTS `Feed` (
  `feed_id` INT NOT NULL,
  `time_added` VARCHAR(45) NULL,
  `time_spend` VARCHAR(45) NULL,
  `RegisteredUser_user_id` INT NOT NULL,
  PRIMARY KEY (`feed_id`, `RegisteredUser_user_id`),
  INDEX `fk_Feed_RegisteredUser1_idx` (`RegisteredUser_user_id` ASC) VISIBLE,
  CONSTRAINT `fk_Feed_RegisteredUser1`
    FOREIGN KEY (`RegisteredUser_user_id`)
    REFERENCES `RegisteredUser` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Permissions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Permissions` ;

CREATE TABLE IF NOT EXISTS `Permissions` (
  `permission_id` INT NOT NULL,
  `permission_title` VARCHAR(45) NOT NULL,
  `description` VARCHAR(45) NULL,
  `level` VARCHAR(45) NOT NULL,
  `PermissionType` CHAR(1) NOT NULL,
  PRIMARY KEY (`permission_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Role`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Role` ;

CREATE TABLE IF NOT EXISTS `Role` (
  `role_id` INT NOT NULL AUTO_INCREMENT,
  `status` VARCHAR(45) NULL,
  `Permissions_permission_id` INT NOT NULL,
  PRIMARY KEY (`role_id`),
  INDEX `fk_Role_Permissions1_idx` (`Permissions_permission_id` ASC) VISIBLE,
  CONSTRAINT `fk_Role_Permissions1`
    FOREIGN KEY (`Permissions_permission_id`)
    REFERENCES `Permissions` (`permission_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Community`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Community` ;

CREATE TABLE IF NOT EXISTS `Community` (
  `community_id` INT NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(255) NULL,
  `logo` BLOB NULL,
  `name` VARCHAR(45) NULL,
  PRIMARY KEY (`community_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Inbox`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Inbox` ;

CREATE TABLE IF NOT EXISTS `Inbox` (
  `updated` DATETIME NOT NULL,
  `read` TINYINT NOT NULL,
  `RegisteredUser_user_id` INT NOT NULL,
  `Chat_chat_id` INT NOT NULL,
  PRIMARY KEY (`RegisteredUser_user_id`, `Chat_chat_id`),
  INDEX `fk_Inbox_Chat1_idx` (`Chat_chat_id` ASC) VISIBLE,
  CONSTRAINT `fk_Inbox_RegisteredUser1`
    FOREIGN KEY (`RegisteredUser_user_id`)
    REFERENCES `RegisteredUser` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Inbox_Chat1`
    FOREIGN KEY (`Chat_chat_id`)
    REFERENCES `Chat` (`chat_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Post_has_Tag`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Post_has_Tag` ;

CREATE TABLE IF NOT EXISTS `Post_has_Tag` (
  `Post_post_id` INT NOT NULL,
  `Tag_tag_id` INT NOT NULL,
  `Tag_RegisteredUser_user_id` INT NOT NULL,
  `date_posted` DATETIME NOT NULL,
  PRIMARY KEY (`Post_post_id`, `Tag_tag_id`, `Tag_RegisteredUser_user_id`),
  INDEX `fk_Post_has_Tag_Tag1_idx` (`Tag_tag_id` ASC, `Tag_RegisteredUser_user_id` ASC) VISIBLE,
  INDEX `fk_Post_has_Tag_Post1_idx` (`Post_post_id` ASC) VISIBLE,
  CONSTRAINT `fk_Post_has_Tag_Post1`
    FOREIGN KEY (`Post_post_id`)
    REFERENCES `Post` (`post_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Post_has_Tag_Tag1`
    FOREIGN KEY (`Tag_tag_id` , `Tag_RegisteredUser_user_id`)
    REFERENCES `Tag` (`tag_id` , `RegisteredUser_user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Feed_has_Post`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Feed_has_Post` ;

CREATE TABLE IF NOT EXISTS `Feed_has_Post` (
  `Feed_feed_id` INT NOT NULL,
  `Feed_RegisteredUser_user_id` INT NOT NULL,
  `Post_post_id` INT NOT NULL,
  `date_posted` DATETIME NULL,
  `viewed` TINYINT NULL,
  PRIMARY KEY (`Feed_feed_id`, `Feed_RegisteredUser_user_id`, `Post_post_id`),
  INDEX `fk_Feed_has_Post_Post1_idx` (`Post_post_id` ASC) VISIBLE,
  INDEX `fk_Feed_has_Post_Feed1_idx` (`Feed_feed_id` ASC, `Feed_RegisteredUser_user_id` ASC) VISIBLE,
  CONSTRAINT `fk_Feed_has_Post_Feed1`
    FOREIGN KEY (`Feed_feed_id` , `Feed_RegisteredUser_user_id`)
    REFERENCES `Feed` (`feed_id` , `RegisteredUser_user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Feed_has_Post_Post1`
    FOREIGN KEY (`Post_post_id`)
    REFERENCES `Post` (`post_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `CommunityFeed`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CommunityFeed` ;

CREATE TABLE IF NOT EXISTS `CommunityFeed` (
  `Community_community_id` INT NOT NULL,
  `Post_post_id` INT NOT NULL,
  `Updated` VARCHAR(45) NULL,
  PRIMARY KEY (`Community_community_id`, `Post_post_id`),
  INDEX `fk_Community_has_Post_Post1_idx` (`Post_post_id` ASC) VISIBLE,
  INDEX `fk_Community_has_Post_Community1_idx` (`Community_community_id` ASC) VISIBLE,
  CONSTRAINT `fk_Community_has_Post_Community1`
    FOREIGN KEY (`Community_community_id`)
    REFERENCES `Community` (`community_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Community_has_Post_Post1`
    FOREIGN KEY (`Post_post_id`)
    REFERENCES `Post` (`post_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Membership`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Membership` ;

CREATE TABLE IF NOT EXISTS `Membership` (
  `RegisteredUser_user_id` INT NOT NULL,
  `Community_community_id` INT NOT NULL,
  `date_joined` DATETIME NOT NULL,
  `community_status` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`RegisteredUser_user_id`, `Community_community_id`),
  INDEX `fk_RegisteredUser_has_Community_Community1_idx` (`Community_community_id` ASC) VISIBLE,
  INDEX `fk_RegisteredUser_has_Community_RegisteredUser1_idx` (`RegisteredUser_user_id` ASC) VISIBLE,
  CONSTRAINT `fk_RegisteredUser_has_Community_RegisteredUser1`
    FOREIGN KEY (`RegisteredUser_user_id`)
    REFERENCES `RegisteredUser` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_RegisteredUser_has_Community_Community1`
    FOREIGN KEY (`Community_community_id`)
    REFERENCES `Community` (`community_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Assignment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Assignment` ;

CREATE TABLE IF NOT EXISTS `Assignment` (
  `RegisteredUser_user_id` INT NOT NULL,
  `Role_role_id` INT NOT NULL,
  `assigned_date` DATETIME NOT NULL,
  PRIMARY KEY (`RegisteredUser_user_id`, `Role_role_id`),
  INDEX `fk_RegisteredUser_has_Role_Role1_idx` (`Role_role_id` ASC) VISIBLE,
  INDEX `fk_RegisteredUser_has_Role_RegisteredUser1_idx` (`RegisteredUser_user_id` ASC) VISIBLE,
  CONSTRAINT `fk_RegisteredUser_has_Role_RegisteredUser1`
    FOREIGN KEY (`RegisteredUser_user_id`)
    REFERENCES `RegisteredUser` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_RegisteredUser_has_Role_Role1`
    FOREIGN KEY (`Role_role_id`)
    REFERENCES `Role` (`role_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Host`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Host` ;

CREATE TABLE IF NOT EXISTS `Host` (
  `Community_community_id` INT NOT NULL,
  `Event_event_id` INT NOT NULL,
  `host_id` INT UNSIGNED NULL,
  `date_posted` DATETIME NULL,
  PRIMARY KEY (`Community_community_id`, `Event_event_id`),
  INDEX `fk_Community_has_Event_Event1_idx` (`Event_event_id` ASC) VISIBLE,
  INDEX `fk_Community_has_Event_Community1_idx` (`Community_community_id` ASC) VISIBLE,
  CONSTRAINT `fk_Community_has_Event_Community1`
    FOREIGN KEY (`Community_community_id`)
    REFERENCES `Community` (`community_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Community_has_Event_Event1`
    FOREIGN KEY (`Event_event_id`)
    REFERENCES `Event` (`event_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `EventApplication`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `EventApplication` ;

CREATE TABLE IF NOT EXISTS `EventApplication` (
  `RegisteredUser_user_id` INT NOT NULL,
  `Event_event_id` INT NOT NULL,
  `application_date` DATETIME NULL,
  PRIMARY KEY (`RegisteredUser_user_id`, `Event_event_id`),
  INDEX `fk_RegisteredUser_has_Event_Event1_idx` (`Event_event_id` ASC) VISIBLE,
  INDEX `fk_RegisteredUser_has_Event_RegisteredUser1_idx` (`RegisteredUser_user_id` ASC) VISIBLE,
  CONSTRAINT `fk_RegisteredUser_has_Event_RegisteredUser1`
    FOREIGN KEY (`RegisteredUser_user_id`)
    REFERENCES `RegisteredUser` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_RegisteredUser_has_Event_Event1`
    FOREIGN KEY (`Event_event_id`)
    REFERENCES `Event` (`event_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
