SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `default_schema` ;
USE `default_schema` ;

-- -----------------------------------------------------
-- Table `default_schema`.`ptms__hs_antibiotics`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__hs_antibiotics` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__hs_antibiotics` (
  `hs_entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `hs_uid` INT(16) NULL DEFAULT NULL ,
  `hs_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `hs_ip` VARCHAR(16) NULL DEFAULT NULL ,
  `hs_client` TINYTEXT NOT NULL ,
  `entry` INT(16) NOT NULL DEFAULT '0' ,
  `case_id` INT(16) NULL DEFAULT NULL ,
  `antibiotic` VARCHAR(64) NULL DEFAULT NULL ,
  `basis_empiric` INT(1) NULL DEFAULT NULL ,
  `basis_final` INT(1) NULL DEFAULT NULL ,
  `route` VARCHAR(8) NULL DEFAULT NULL ,
  `dose_amount_loading` VARCHAR(8) NULL DEFAULT NULL ,
  `dose_amount` VARCHAR(8) NULL DEFAULT NULL ,
  `dose_amount_units` VARCHAR(8) NULL DEFAULT NULL ,
  `dose_frequency` VARCHAR(8) NULL DEFAULT NULL ,
  `regimen_duration` INT(3) NULL DEFAULT NULL ,
  `date_start` DATE NULL DEFAULT NULL ,
  `date_end` DATE NULL DEFAULT NULL ,
  `date_stopped` DATE NULL DEFAULT NULL ,
  `comments` TEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `created` DATETIME NULL DEFAULT NULL ,
  `modified` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`hs_entry`) )
ENGINE = InnoDB
AUTO_INCREMENT = 1656
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__hs_cases`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__hs_cases` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__hs_cases` (
  `hs_entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `hs_uid` INT(16) NULL DEFAULT NULL ,
  `hs_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `hs_ip` VARCHAR(16) NULL DEFAULT NULL ,
  `hs_client` TINYTEXT NOT NULL ,
  `entry` INT(16) NOT NULL DEFAULT '0' ,
  `patient` INT(16) NULL DEFAULT NULL ,
  `is_peritonitis` TINYINT(1) NULL DEFAULT NULL ,
  `is_exit_site` TINYINT(1) NULL DEFAULT NULL ,
  `is_tunnel` TINYINT(1) NULL DEFAULT NULL ,
  `initial_wbc` VARCHAR(16) NULL DEFAULT NULL ,
  `initial_pmn` VARCHAR(16) NULL DEFAULT NULL ,
  `case_type` VARCHAR(32) NULL DEFAULT NULL ,
  `hospitalization_required` VARCHAR(16) NULL DEFAULT 'No' ,
  `hospitalization_location` VARCHAR(64) NULL DEFAULT 'RCH' ,
  `hospitalization_onset` VARCHAR(16) NULL DEFAULT NULL ,
  `outcome` VARCHAR(32) NULL DEFAULT 'Outstanding' ,
  `home_visit` VARCHAR(16) NULL DEFAULT 'Pending' ,
  `follow_up_culture` VARCHAR(16) NULL DEFAULT 'No' ,
  `next_step` INT(2) NULL DEFAULT NULL ,
  `closed` INT(1) NULL DEFAULT NULL ,
  `comments` TEXT NULL DEFAULT NULL ,
  `created` DATETIME NULL DEFAULT NULL ,
  `modified` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`hs_entry`) )
ENGINE = InnoDB
AUTO_INCREMENT = 243
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__hs_catheters`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__hs_catheters` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__hs_catheters` (
  `hs_entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `hs_uid` INT(16) NULL DEFAULT NULL ,
  `hs_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `hs_ip` VARCHAR(16) NULL DEFAULT NULL ,
  `hs_client` TINYTEXT NULL DEFAULT NULL ,
  `entry` INT(16) NOT NULL DEFAULT '0' ,
  `patient_id` INT(16) NULL DEFAULT NULL ,
  `insertion_location` VARCHAR(32) NULL DEFAULT NULL ,
  `insertion_method` VARCHAR(32) NULL DEFAULT NULL ,
  `type` VARCHAR(64) NULL DEFAULT NULL ,
  `surgeon` INT(16) NULL DEFAULT NULL ,
  `insertion_date` DATE NULL DEFAULT NULL ,
  `removal_date` DATE NULL DEFAULT NULL ,
  `created` DATETIME NULL DEFAULT NULL ,
  `modified` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`hs_entry`) )
ENGINE = MyISAM
AUTO_INCREMENT = 284
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__hs_dialysis`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__hs_dialysis` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__hs_dialysis` (
  `hs_entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `hs_uid` INT(16) NULL DEFAULT NULL ,
  `hs_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `hs_ip` VARCHAR(16) NULL DEFAULT NULL ,
  `hs_client` TINYTEXT NULL DEFAULT NULL ,
  `entry` INT(16) NOT NULL DEFAULT '0' ,
  `patient_id` INT(16) NULL DEFAULT NULL ,
  `center` VARCHAR(32) NULL DEFAULT NULL ,
  `type` VARCHAR(8) NULL DEFAULT NULL ,
  `start_date` DATE NULL DEFAULT NULL ,
  `stop_date` DATE NULL DEFAULT NULL ,
  `created` DATETIME NULL DEFAULT NULL ,
  `modified` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`hs_entry`) )
ENGINE = MyISAM
AUTO_INCREMENT = 510
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__hs_labs`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__hs_labs` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__hs_labs` (
  `hs_entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `hs_uid` INT(16) NULL DEFAULT NULL ,
  `hs_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `hs_ip` VARCHAR(16) NULL DEFAULT NULL ,
  `hs_client` TINYTEXT NOT NULL ,
  `entry` INT(16) NOT NULL DEFAULT '0' ,
  `case_id` INT(16) NULL DEFAULT NULL ,
  `type` VARCHAR(45) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `ordered` DATE NULL DEFAULT NULL ,
  `status` VARCHAR(45) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `comments` TEXT NULL DEFAULT NULL ,
  `pathogen_1` VARCHAR(255) NULL DEFAULT NULL ,
  `pathogen_2` VARCHAR(255) NULL DEFAULT NULL ,
  `pathogen_3` VARCHAR(255) NULL DEFAULT NULL ,
  `pathogen_4` VARCHAR(255) NULL DEFAULT NULL ,
  `result_pre` INT(1) NULL DEFAULT NULL ,
  `result_final` INT(1) NULL DEFAULT NULL ,
  `created` DATETIME NULL DEFAULT NULL ,
  `modified` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`hs_entry`) )
ENGINE = InnoDB
AUTO_INCREMENT = 402
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__hs_login`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__hs_login` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__hs_login` (
  `entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `hs_uid` INT(16) NULL DEFAULT NULL ,
  `hs_ip` CHAR(16) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `hs_client` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `hs_action` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (`entry`) )
ENGINE = MyISAM
AUTO_INCREMENT = 4046
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__hs_patients`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__hs_patients` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__hs_patients` (
  `hs_entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `hs_uid` INT(16) NULL DEFAULT NULL ,
  `hs_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `hs_ip` VARCHAR(16) NULL DEFAULT NULL ,
  `hs_client` TINYTEXT NOT NULL ,
  `entry` INT(16) NOT NULL DEFAULT '0' ,
  `name_first` VARCHAR(64) NULL DEFAULT NULL ,
  `name_last` VARCHAR(64) NULL DEFAULT NULL ,
  `phn` VARCHAR(16) NULL DEFAULT NULL ,
  `phone_home` VARCHAR(32) NULL DEFAULT NULL COMMENT '	' ,
  `phone_work` VARCHAR(32) NULL DEFAULT NULL ,
  `phone_mobile` VARCHAR(32) NULL DEFAULT NULL ,
  `email` VARCHAR(64) NULL DEFAULT NULL ,
  `email_reminder` INT(1) NULL DEFAULT NULL ,
  `date_of_birth` DATE NULL DEFAULT NULL ,
  `weight` DECIMAL(5,2) NULL DEFAULT NULL ,
  `gender` VARCHAR(16) NULL DEFAULT NULL ,
  `disease_diabetes` INT(1) NULL DEFAULT NULL ,
  `disease_cognitive` INT(1) NULL DEFAULT NULL ,
  `disease_psychosocial` INT(1) NULL DEFAULT NULL ,
  `allergies` TINYTEXT NULL DEFAULT NULL ,
  `pd_start_date` DATE NULL DEFAULT NULL ,
  `pd_stop_date` DATE NULL DEFAULT NULL ,
  `dialysis_center` VARCHAR(32) NULL DEFAULT NULL ,
  `dialysis_type` VARCHAR(8) NULL DEFAULT NULL ,
  `catheter_insertion_location` VARCHAR(32) NULL DEFAULT NULL ,
  `catheter_insertion_method` VARCHAR(32) NULL DEFAULT NULL ,
  `catheter_type` VARCHAR(64) NULL DEFAULT NULL ,
  `surgeon` INT(16) NULL DEFAULT NULL ,
  `primary_nurse` INT(16) NULL DEFAULT NULL ,
  `nephrologist` INT(16) NULL DEFAULT NULL ,
  `comments` TEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `cache_primary_nurse` VARCHAR(64) NULL DEFAULT NULL ,
  `cache_nephrologist` VARCHAR(64) NULL DEFAULT NULL ,
  `cache_on_pd` VARCHAR(16) NULL DEFAULT NULL ,
  `cache_cases` VARCHAR(16) NULL DEFAULT NULL ,
  `cache_case_status` VARCHAR(16) NULL DEFAULT NULL ,
  `created` DATETIME NULL DEFAULT NULL ,
  `modified` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`hs_entry`) )
ENGINE = InnoDB
AUTO_INCREMENT = 888
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__hs_users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__hs_users` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__hs_users` (
  `hs_entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `hs_uid` INT(16) NULL DEFAULT NULL ,
  `hs_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `hs_ip` VARCHAR(16) NULL DEFAULT NULL ,
  `hs_client` TINYTEXT NOT NULL ,
  `entry` INT(16) NOT NULL DEFAULT '0' ,
  `type` VARCHAR(32) NULL DEFAULT 'Administrator' ,
  `email` VARCHAR(64) NULL DEFAULT NULL ,
  `password` VARCHAR(128) NULL DEFAULT NULL ,
  `name_first` VARCHAR(64) NULL DEFAULT NULL ,
  `name_last` VARCHAR(64) NULL DEFAULT NULL ,
  `role` VARCHAR(32) NULL DEFAULT NULL ,
  `deactivated` INT(1) NULL DEFAULT '0' ,
  `opt_in` INT(1) NULL DEFAULT '0' ,
  `created` DATETIME NULL DEFAULT NULL ,
  `modified` DATETIME NULL DEFAULT NULL ,
  `accessed` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`hs_entry`) )
ENGINE = InnoDB
AUTO_INCREMENT = 105
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_cath_breakinmethod`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_cath_breakinmethod` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_cath_breakinmethod` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_cath_manufacturer`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_cath_manufacturer` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_cath_manufacturer` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_order` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_cath_surgeon`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_cath_surgeon` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_cath_surgeon` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_cath_type_show`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_cath_type_show` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_cath_type_show` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_comorbidconditions_show`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_comorbidconditions_show` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_comorbidconditions_show` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_databaseversion`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_databaseversion` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_databaseversion` (
  `col_versiondate` DATE NULL DEFAULT NULL ,
  `col_versionname` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_dialysiscenter`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_dialysiscenter` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_dialysiscenter` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_address` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_city` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_state` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_country` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_centerid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_dischargediagnosis`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_dischargediagnosis` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_dischargediagnosis` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_exitsite_normalcare`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_exitsite_normalcare` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_exitsite_normalcare` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_flags`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_flags` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_flags` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_hospital`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_hospital` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_hospital` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_infec_lab`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_infec_lab` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_infec_lab` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_infection_culture`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_infection_culture` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_infection_culture` (
  `col_infeccuture_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patinfec_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_date` DATE NULL DEFAULT NULL ,
  `col_organism` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_lab` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_samplingmethod` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_comments` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_infection_treatment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_infection_treatment` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_infection_treatment` (
  `col_infectreatment_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patinfec_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_startdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_antibiotic` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_route` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_loaddose` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_maintdose` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_dosesperday` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_durationdays` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_comments` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_infection_treatment_exporterrors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_infection_treatment_exporterrors` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_infection_treatment_exporterrors` (
  `col_error` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_field` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_row` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_infectreat_antibiotic_settings`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_infectreat_antibiotic_settings` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_infectreat_antibiotic_settings` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_show` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_route` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_loaddose` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_maintdose` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_dosesperday` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_durationdays` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_nephrologist`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_nephrologist` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_nephrologist` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_nurse`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_nurse` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_nurse` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_patient`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_patient` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_patient` (
  `col_employedlast12months` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_initdialysisdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_initialmodalityselection` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_levelofindependactivity` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_theroptioneducator` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_userspatientid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_lastname` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_firstname` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_gender` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_birthdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_race` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_racedetail` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_yearsofeducation` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_primarynephrologist` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_initexamdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_theroptrainingdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_primarycauseesrd` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_detailedcauseesrd` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_antibioticallergies` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_dialysiscenter` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_primarynurse` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_comments` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patientcamefrom` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_flag1` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_flag2` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_flag3` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_flag4` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_flag5` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_patient_catheter`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_patient_catheter` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_patient_catheter` (
  `col_patcatheter_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cathetertype` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_surgeon` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_implantationmethod` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_implantationdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_implantationenviron` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_break_inmethod` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_fullprescripstartdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_removaldate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_manufacturer` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_removalreason` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_omentperformed` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_patient_catheter_exporterrors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_patient_catheter_exporterrors` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_patient_catheter_exporterrors` (
  `col_error` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_field` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_row` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_patient_comorbidcond`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_patient_comorbidcond` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_patient_comorbidcond` (
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_comorbcond_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_patient_exitsitecond`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_patient_exitsitecond` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_patient_exitsitecond` (
  `col_patexitsite_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_conditiondate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_classification` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_normalexitsitecare` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_traumaoccurance` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_comments` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_patient_exporterrors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_patient_exporterrors` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_patient_exporterrors` (
  `col_error` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_field` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_row` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_patient_hospital`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_patient_hospital` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_patient_hospital` (
  `col_pathospital_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_hospital_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_entrydate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_dischargedate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_dischargediagnosis_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_outcome_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_patient_infection`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_patient_infection` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_patient_infection` (
  `col_patinfec_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_presentationdate` DATE NULL DEFAULT NULL ,
  `col_culturelab` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_inittreatmentprovider` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_infectiontype` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_hospitalized` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_dayshospitalized` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_relapsingepisode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_outcome` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_patient_nicathproblem`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_patient_nicathproblem` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_patient_nicathproblem` (
  `col_patnicathprob_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_inittreatmentprovider` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_problemtype` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_dateproblemidentified` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_treatment` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_hospitalized` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_dayshospitalized` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_alterntherapyrequired_` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_alterntherapy` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_treatmentsuccessful_` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_patient_system`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_patient_system` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_patient_system` (
  `col_patsystem_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_apdsystem` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_capdsystem` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ipdsystem` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_transferset` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_startdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_enddate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_reasonmain` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_reasondetail1` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_reasondetail2` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_exchangesperfby` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_primarynurse` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_patient_system_exporterrors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_patient_system_exporterrors` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_patient_system_exporterrors` (
  `col_error` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_field` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_row` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_race_detail`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_race_detail` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_race_detail` (
  `col_racedetailid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_race_show`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_race_show` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_race_show` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_system_show`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_system_show` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_system_show` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_system_trainer`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_system_trainer` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_system_trainer` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_system_training`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_system_training` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_system_training` (
  `col_systraining_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patsystem_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_startdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_daystrained` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_trainer` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_reason` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_system_tsetchangedate`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_system_tsetchangedate` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_system_tsetchangedate` (
  `col_patsystem_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_transsetchangedate` DATE NULL DEFAULT NULL ,
  `col_nurse_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_tblpatient_flags`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_tblpatient_flags` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_tblpatient_flags` (
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_flag_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_show` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_therapyoptioneducator`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_therapyoptioneducator` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_therapyoptioneducator` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_data_usersettings_center`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_data_usersettings_center` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_data_usersettings_center` (
  `col_previnfec_nummonths` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_previnfec_numinfecs` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_reason_months` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_agegroup`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_agegroup` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_agegroup` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_sort` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_cath_implantationenvironment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_cath_implantationenvironment` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_cath_implantationenvironment` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_cath_implantationmethod`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_cath_implantationmethod` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_cath_implantationmethod` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_order` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_cath_removalreason`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_cath_removalreason` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_cath_removalreason` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_order` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_cath_type`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_cath_type` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_cath_type` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_show` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_cathinfecsource`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_cathinfecsource` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_cathinfecsource` (
  `col_systemname` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cthmos` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_presentationdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_cathinfecsourcefinal`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_cathinfecsourcefinal` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_cathinfecsourcefinal` (
  `col_systemname` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_sumofcthmos` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_countofpresentationdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_causesofesrd`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_causesofesrd` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_causesofesrd` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_owner_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_comorbidconditions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_comorbidconditions` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_comorbidconditions` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_sort` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_select` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_custrpt_groups`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_custrpt_groups` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_custrpt_groups` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_selectionid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_custrptgroups`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_custrptgroups` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_custrptgroups` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_selectionid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_exchgsperfom`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_exchgsperfom` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_exchgsperfom` (
  `col_expirationdate` DATE NULL DEFAULT NULL ,
  `col_currentpassword` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_tocheckdateformat` DATE NULL DEFAULT NULL ,
  `col_programversion` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_releasedate` DATE NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_exchgsperformedby`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_exchgsperformedby` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_exchgsperformedby` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_exitsite_classification`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_exitsite_classification` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_exitsite_classification` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_gender`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_gender` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_gender` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_infec_organism`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_infec_organism` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_infec_organism` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_group` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_order` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_infec_outcome`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_infec_outcome` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_infec_outcome` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_infec_samplingmethod`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_infec_samplingmethod` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_infec_samplingmethod` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_order` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_infec_type`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_infec_type` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_infec_type` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_infectreat_antibiotic`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_infectreat_antibiotic` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_infectreat_antibiotic` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_show` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_infectreat_route`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_infectreat_route` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_infectreat_route` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_initial_treatment_provider`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_initial_treatment_provider` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_initial_treatment_provider` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_initialmodalityselection`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_initialmodalityselection` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_initialmodalityselection` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_sortorder` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_levelofindependentactivity`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_levelofindependentactivity` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_levelofindependentactivity` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_sortorder` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_menuchoices`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_menuchoices` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_menuchoices` (
  `col_menu_item_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_menu_list` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_sort` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_label` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_preparatory_function` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_object` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_object_type` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_nicath_alternatetherapy`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_nicath_alternatetherapy` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_nicath_alternatetherapy` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_nicath_problem`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_nicath_problem` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_nicath_problem` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_order` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_objecttypes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_objecttypes` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_objecttypes` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_onerec`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_onerec` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_onerec` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_dummy` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_outcome`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_outcome` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_outcome` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_paste_errors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_paste_errors` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_paste_errors` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_patientcamefrom`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_patientcamefrom` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_patientcamefrom` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_order` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_patinf_required_fields`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_patinf_required_fields` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_patinf_required_fields` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_taborder` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_controlname` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_tab` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_label_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_patinf_tabs`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_patinf_tabs` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_patinf_tabs` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_race`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_race` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_race` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_show` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_system`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_system` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_system` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_sort` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_systemtype` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_show` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_order` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_system_endreason`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_system_endreason` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_system_endreason` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_owner_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_system_trainingreason`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_system_trainingreason` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_system_trainingreason` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_order` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_system_type`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_system_type` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_system_type` (
  `col_system_type` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_temp13`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_temp13` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_temp13` (
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_primarynephrologist` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_dialysiscenter` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_primarynurse` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_surgeon` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_removaldate` DATE NULL DEFAULT NULL ,
  `col_removalreason` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_descriptionrpt` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_temptxt`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_temptxt` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_temptxt` (
  `col_descriptionrpt` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_totremovals` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_perc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_textelement`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_textelement` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_textelement` (
  `col_textid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_textvalue` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_textelement_dnmr`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_textelement_dnmr` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_textelement_dnmr` (
  `col_textid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_textvalue` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_textelement_engl`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_textelement_engl` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_textelement_engl` (
  `col_textid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_textvalue` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_textelement_fnln`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_textelement_fnln` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_textelement_fnln` (
  `col_textid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_textvalue` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_textelement_frnc`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_textelement_frnc` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_textelement_frnc` (
  `col_textid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_textvalue` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_textelement_grmn`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_textelement_grmn` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_textelement_grmn` (
  `col_textid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_textvalue` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_textelement_ital`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_textelement_ital` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_textelement_ital` (
  `col_textid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_textvalue` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_textelement_norw`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_textelement_norw` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_textelement_norw` (
  `col_textid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_textvalue` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_textelement_port`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_textelement_port` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_textelement_port` (
  `col_textid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_textvalue` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_textelement_spns`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_textelement_spns` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_textelement_spns` (
  `col_textid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_textvalue` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_textelement_swdn`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_textelement_swdn` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_textelement_swdn` (
  `col_textid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_textvalue` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_textelement_ukuk`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_textelement_ukuk` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_textelement_ukuk` (
  `col_textid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_textvalue` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_tmpcausative`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_tmpcausative` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_tmpcausative` (
  `col_presentationdate` DATE NULL DEFAULT NULL ,
  `col_dialysiscenter` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_diabet` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_organism` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_organismname` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_infectiontype` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_tmpcr_exitcareall`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_tmpcr_exitcareall` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_tmpcr_exitcareall` (
  `col_conditiondate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_pk` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patientid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_normalexitsitecare` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_tmpcr_groupbyorganism`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_tmpcr_groupbyorganism` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_tmpcr_groupbyorganism` (
  `col_diabet` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_infectiontype` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_presentationdate` DATE NULL DEFAULT NULL ,
  `col_patinfecid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patientid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_sysid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_dailyconnbyid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cathtypeid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_surgeonid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_breakinid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_organismid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_exitcareid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_systemtypeid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_infecdesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_diabetdesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_sysdesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_surgdesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_nasalflag` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_organdesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cathdesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_exitcaredesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_breakindesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_tmpcr_patientinfec`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_tmpcr_patientinfec` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_tmpcr_patientinfec` (
  `col_diabet` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patientid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_infectiontype` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_presentationdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patinfecid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_infecdesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_sysid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_dailyconnbyid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_systemtypeid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cathtypeid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_exitcareid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_surgeonid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_breakinid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_organismid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_diabetdesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_sysdesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_surgdesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_nasalflag` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_organdesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cathdesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_exitcaredesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_breakindesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_tmpdemrpt`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_tmpdemrpt` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_tmpdemrpt` (
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_startdate` DATE NULL DEFAULT NULL ,
  `col_enddate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cardio` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_diabet` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_center` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_age` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_tmpexitsitepat`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_tmpexitsitepat` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_tmpexitsitepat` (
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_diabet` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_center` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_conditiondate` DATE NULL DEFAULT NULL ,
  `col_classification` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_classid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_traumaoccurance` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_enddate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_daysoncond` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_tmphosp`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_tmphosp` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_tmphosp` (
  `col_pathospital_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_hospital_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_entrydate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_dischargedate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_dischargediagnosis_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_outcome_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_tmpinfecantibiotic`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_tmpinfecantibiotic` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_tmpinfecantibiotic` (
  `col_patinfec_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_antibiotic` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_presentationdate` DATE NULL DEFAULT NULL ,
  `col_infectiontype` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_startdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_durationdays` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_tmpinfecantibiotic_exporterrors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_tmpinfecantibiotic_exporterrors` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_tmpinfecantibiotic_exporterrors` (
  `col_error` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_field` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_row` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_tmplistofinfec`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_tmplistofinfec` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_tmplistofinfec` (
  `col_diabet` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_infectiontype` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_presentationdate` DATE NULL DEFAULT NULL ,
  `col_patinfecid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patientid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_diabetdesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_tmpnasal`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_tmpnasal` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_tmpnasal` (
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_userspatientid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_name` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_culture_date` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_organism` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_center` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_tmppatlist`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_tmppatlist` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_tmppatlist` (
  `col_lastname` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_firstname` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_userspatientid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_active` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_dialysiscenter` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_tmppda2`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_tmppda2` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_tmppda2` (
  `col_id_number` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_first_name` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_last_name` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_gender` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_birth_date` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_tmpqryrelapserpt`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_tmpqryrelapserpt` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_tmpqryrelapserpt` (
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_name` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_center` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_presentationdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_infectiontype` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_route` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_routdesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_antibiotic` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_type` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_enddate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_startdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_system` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_catheter` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_organism` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_tmprelapse`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_tmprelapse` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_tmprelapse` (
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_presentationdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_infectiontype` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_route` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_antibiotic` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_type` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_organism` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_name` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_center` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_tmpsysside`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_tmpsysside` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_tmpsysside` (
  `col_sysid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_sysdatefrom` DATE NULL DEFAULT NULL ,
  `col_sysdateto` DATE NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_usersettings_workstation`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_usersettings_workstation` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_usersettings_workstation` (
  `col_programdirectory` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_datadirectory` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_password` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_commentsshow` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_openfirsttime` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_usertablelist`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_usertablelist` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_usertablelist` (
  `col_tablename` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_level` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_deletecontents` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_yes_no`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_yes_no` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_yes_no` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_agegroup`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_agegroup` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_agegroup` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_cath_implantationenvironment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_cath_implantationenvironment` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_cath_implantationenvironment` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_cath_implantationmethod`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_cath_implantationmethod` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_cath_implantationmethod` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_cath_removalreason`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_cath_removalreason` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_cath_removalreason` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_cath_type`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_cath_type` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_cath_type` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_causesofesrd`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_causesofesrd` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_causesofesrd` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_comorbidconditions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_comorbidconditions` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_comorbidconditions` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_custrptgroups`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_custrptgroups` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_custrptgroups` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_dischargediagnosis`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_dischargediagnosis` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_dischargediagnosis` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_exchgsperformedby`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_exchgsperformedby` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_exchgsperformedby` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_exitsite_classification`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_exitsite_classification` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_exitsite_classification` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_flags`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_flags` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_flags` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_gender`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_gender` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_gender` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_infec_organism`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_infec_organism` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_infec_organism` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_infec_outcome`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_infec_outcome` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_infec_outcome` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_infec_samplingmethod`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_infec_samplingmethod` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_infec_samplingmethod` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_infec_type`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_infec_type` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_infec_type` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_infectreat_antibiotic`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_infectreat_antibiotic` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_infectreat_antibiotic` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_infectreat_route`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_infectreat_route` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_infectreat_route` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_initial_treatment_provider`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_initial_treatment_provider` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_initial_treatment_provider` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_initialmodalityselection`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_initialmodalityselection` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_initialmodalityselection` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_menuchoices`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_menuchoices` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_menuchoices` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_nicath_alternatetherapy`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_nicath_alternatetherapy` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_nicath_alternatetherapy` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_nicath_problem`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_nicath_problem` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_nicath_problem` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_outcome`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_outcome` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_outcome` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_patientcamefrom`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_patientcamefrom` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_patientcamefrom` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_patinf_required_fields`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_patinf_required_fields` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_patinf_required_fields` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_race`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_race` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_race` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_system`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_system` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_system` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_system_endreason`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_system_endreason` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_system_endreason` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_system_trainingreason`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_system_trainingreason` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_system_trainingreason` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_system_type`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_system_type` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_system_type` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_system_type` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsl_yes_no`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsl_yes_no` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsl_yes_no` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zsourcedischargediagnosis`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zsourcedischargediagnosis` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zsourcedischargediagnosis` (
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_ztbldemographicrpt`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_ztbldemographicrpt` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_ztbldemographicrpt` (
  `col_totnumberofpatients` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_aveage` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_percentdiabetic` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_percentcard` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_rptyear` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_ztblfilters4custrpt`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_ztblfilters4custrpt` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_ztblfilters4custrpt` (
  `col_paramsetid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_paramsetname` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxinfectype` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxdiabeticstatus` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxrace` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxracedetail` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxnurse` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxprimarynephrologist` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxdialysiscenter` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxflag1` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxflag2` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxflag3` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxflag4` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxflag5` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_txtagefrom` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_txtageto` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_txtuserfromdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_txtusertodate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxsystem` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxdaily` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxcathtype` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxsurgeon` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxbreak` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxorganism` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxgroup` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxdateinterval` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_cbxvalues` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_ztblpatdemogrpt`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_ztblpatdemogrpt` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_ztblpatdemogrpt` (
  `col_year1` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_year2` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_year3` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_year4` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_year5` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl11` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl12` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl13` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl14` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl15` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl16` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl21` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl22` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl23` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl24` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl25` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl26` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl31` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl32` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl33` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl34` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl35` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl36` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl41` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl42` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl43` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl44` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl45` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_ctrl46` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_ztblpateventlog`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_ztblpateventlog` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_ztblpateventlog` (
  `col_eventdtae` DATE NULL DEFAULT NULL ,
  `col_eventname` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_details` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_dayshosp` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_ztblreasonhappendrpt`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_ztblreasonhappendrpt` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_ztblreasonhappendrpt` (
  `col_reasonmain` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_everyreason` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_ztblreasonrpt`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_ztblreasonrpt` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_ztblreasonrpt` (
  `col_section` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_reason_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_reason` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_happend` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_ztblrelapse`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_ztblrelapse` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_ztblrelapse` (
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_presentationdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_infectiontype` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_firstofname` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_firstofcenter` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_firstofroute` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_firstofroutdesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_firstofantibiotic` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_firstoftype` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_firstofenddate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_firstofstartdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_firstofsystem` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_firstofcatheter` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_firstoforganism` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_ztblrelapsegrouped`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_ztblrelapsegrouped` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_ztblrelapsegrouped` (
  `col_patient_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_name` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_center` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_presentationdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_infectiontype` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_route` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_routdesc` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_antibiotic` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_type` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_enddate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_startdate` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_system` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_catheter` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_organism` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_ztbltablesemptyforrelease`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_ztbltablesemptyforrelease` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_ztbltablesemptyforrelease` (
  `col_tablename` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_releaseaction` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_releaseactiondescription` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_sourcetablename` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_specificparameter` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_ztmpnewdc`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_ztmpnewdc` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_ztmpnewdc` (
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_address` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_city` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_state` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_country` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_centerid` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zztmp`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zztmp` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zztmp` (
  `col_languagecode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_id` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_mult_zzztmp`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_mult_zzztmp` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_mult_zzztmp` (
  `col_name` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_txtlength` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_originallength` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_record_insertion_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_cath_breakinmethod`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_cath_breakinmethod` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_cath_breakinmethod` (
  `col_record_id` INT(16) NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_cath_manufacturer`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_cath_manufacturer` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_cath_manufacturer` (
  `col_record_id` INT(16) NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_order` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_cath_surgeon`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_cath_surgeon` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_cath_surgeon` (
  `col_record_id` INT(16) NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_cath_type_show`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_cath_type_show` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_cath_type_show` (
  `col_record_id` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_comorbidconditions_show`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_comorbidconditions_show` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_comorbidconditions_show` (
  `col_record_id` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_databaseversion`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_databaseversion` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_databaseversion` (
  `col_versiondate` DATE NULL DEFAULT NULL ,
  `col_versionname` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_dialysiscenter`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_dialysiscenter` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_dialysiscenter` (
  `col_record_id` INT(16) NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_address` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_city` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_state` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_country` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_centerid` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_dischargediagnosis`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_dischargediagnosis` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_dischargediagnosis` (
  `col_record_id` INT(16) NULL DEFAULT NULL ,
  `col_description` TEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_exitsite_normalcare`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_exitsite_normalcare` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_exitsite_normalcare` (
  `col_record_id` INT(16) NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_flags`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_flags` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_flags` (
  `col_record_id` INT(16) NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_hospital`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_hospital` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_hospital` (
  `col_record_id` INT(16) NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_infec_lab`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_infec_lab` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_infec_lab` (
  `col_record_id` INT(16) NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_infection_culture`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_infection_culture` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_infection_culture` (
  `col_infeccuture_id` INT(16) NULL DEFAULT NULL ,
  `col_patinfec_id` INT(16) NULL DEFAULT NULL ,
  `col_date` DATE NULL DEFAULT NULL ,
  `col_organism` INT(16) NULL DEFAULT NULL ,
  `col_lab` INT(16) NULL DEFAULT NULL ,
  `col_samplingmethod` INT(16) NULL DEFAULT NULL ,
  `col_comments` TEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_infection_treatment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_infection_treatment` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_infection_treatment` (
  `col_infectreatment` INT(16) NULL DEFAULT NULL ,
  `col_patinfec_id` INT(16) NULL DEFAULT NULL ,
  `col_startdate` DATE NULL DEFAULT NULL ,
  `col_antibiotic` INT(16) NULL DEFAULT NULL ,
  `col_route` INT(16) NULL DEFAULT NULL ,
  `col_loaddose` INT(16) NULL DEFAULT NULL ,
  `col_maintdose` INT(16) NULL DEFAULT NULL ,
  `col_dosesperday` INT(16) NULL DEFAULT NULL ,
  `col_durationdays` INT(16) NULL DEFAULT NULL ,
  `col_comments` TEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_infection_treatment_exporterrors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_infection_treatment_exporterrors` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_infection_treatment_exporterrors` (
  `col_error` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_field` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_row` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_infectreat_antibiotic_settings`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_infectreat_antibiotic_settings` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_infectreat_antibiotic_settings` (
  `col_record_id` INT(16) NULL DEFAULT NULL ,
  `col_show` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_route` INT(16) NULL DEFAULT NULL ,
  `col_loaddose` INT(16) NULL DEFAULT NULL ,
  `col_maintdose` INT(16) NULL DEFAULT NULL ,
  `col_dosesperday` INT(16) NULL DEFAULT NULL ,
  `col_durationdays` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_nephrologist`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_nephrologist` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_nephrologist` (
  `col_record_id` INT(16) NULL DEFAULT NULL ,
  `col_description` TEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_nurse`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_nurse` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_nurse` (
  `col_record_id` INT(16) NULL DEFAULT NULL ,
  `col_description` TEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_patient`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_patient` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_patient` (
  `col_employedlast12months` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_initdialysisdate` DATE NULL DEFAULT NULL ,
  `col_initialmodalityselection` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_levelofindependactivity` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patient_id` INT(16) NULL DEFAULT NULL ,
  `col_theroptioneducator` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_userspatientid` INT(16) NULL DEFAULT NULL ,
  `col_lastname` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_firstname` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_gender` INT(16) NULL DEFAULT NULL ,
  `col_birthdate` DATE NULL DEFAULT NULL ,
  `col_race` INT(16) NULL DEFAULT NULL ,
  `col_racedetail` INT(16) NULL DEFAULT NULL ,
  `col_yearsofeducation` INT(16) NULL DEFAULT NULL ,
  `col_primarynephrologist` INT(16) NULL DEFAULT NULL ,
  `col_initexamdate` DATE NULL DEFAULT NULL ,
  `col_theroptrainingdate` DATE NULL DEFAULT NULL ,
  `col_primarycauseesrd` INT(16) NULL DEFAULT NULL ,
  `col_detailedcauseesrd` INT(16) NULL DEFAULT NULL ,
  `col_antibioticallergies` INT(16) NULL DEFAULT NULL ,
  `col_dialysiscenter` INT(16) NULL DEFAULT NULL ,
  `col_primarynurse` INT(16) NULL DEFAULT NULL ,
  `col_comments` TEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_patientcamefrom` INT(16) NULL DEFAULT NULL ,
  `col_flag1` INT(16) NULL DEFAULT NULL ,
  `col_flag2` INT(16) NULL DEFAULT NULL ,
  `col_flag3` INT(16) NULL DEFAULT NULL ,
  `col_flag4` INT(16) NULL DEFAULT NULL ,
  `col_flag5` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_patient_catheter`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_patient_catheter` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_patient_catheter` (
  `col_patcatheter_id` INT(16) NULL DEFAULT NULL ,
  `col_patient_id` INT(16) NULL DEFAULT NULL ,
  `col_cathetertype` INT(16) NULL DEFAULT NULL ,
  `col_surgeon` INT(16) NULL DEFAULT NULL ,
  `col_implantationmethod` INT(16) NULL DEFAULT NULL ,
  `col_implantationdate` DATE NULL DEFAULT NULL ,
  `col_implantationenviron` INT(16) NULL DEFAULT NULL ,
  `col_break-inmethod` INT(16) NULL DEFAULT NULL ,
  `col_fullprescripstartdate` DATE NULL DEFAULT NULL ,
  `col_removaldate` DATE NULL DEFAULT NULL ,
  `col_manufacturer` INT(16) NULL DEFAULT NULL ,
  `col_removalreason` INT(16) NULL DEFAULT NULL ,
  `col_omentperformed` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_patient_cathether_exporterrors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_patient_cathether_exporterrors` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_patient_cathether_exporterrors` (
  `col_error` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_field` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_row` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_patient_comorbidcond`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_patient_comorbidcond` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_patient_comorbidcond` (
  `col_patient_id` INT(16) NULL DEFAULT NULL ,
  `col_comorbcond_id` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_patient_exitsitecond`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_patient_exitsitecond` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_patient_exitsitecond` (
  `col_patexitsite_id` INT(16) NULL DEFAULT NULL ,
  `col_patient_id` INT(16) NULL DEFAULT NULL ,
  `col_conditiondate` DATE NULL DEFAULT NULL ,
  `col_classification` INT(16) NULL DEFAULT NULL ,
  `col_normalexitsitecare` INT(16) NULL DEFAULT NULL ,
  `col_traumaoccurance` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_comments` TEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_patient_exporterrors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_patient_exporterrors` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_patient_exporterrors` (
  `col_error` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_field` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_row` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_patient_hospital`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_patient_hospital` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_patient_hospital` (
  `col_pathospital_id` INT(16) NULL DEFAULT NULL ,
  `col_patient_id` INT(16) NULL DEFAULT NULL ,
  `col_hospital_id` INT(16) NULL DEFAULT NULL ,
  `col_entrydate` DATE NULL DEFAULT NULL ,
  `col_dischargedate` DATE NULL DEFAULT NULL ,
  `col_dischargediagnosis_id` INT(16) NULL DEFAULT NULL ,
  `col_outcome_id` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_patient_infection`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_patient_infection` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_patient_infection` (
  `col_patinfec_id` INT(16) NULL DEFAULT NULL ,
  `col_patient_id` INT(16) NULL DEFAULT NULL ,
  `col_presentationdate` DATE NULL DEFAULT NULL ,
  `col_culturelab` INT(16) NULL DEFAULT NULL ,
  `col_inittreatmentprovider` INT(16) NULL DEFAULT NULL ,
  `col_infectiontype` INT(16) NULL DEFAULT NULL ,
  `col_hospitalized` INT(16) NULL DEFAULT NULL ,
  `col_dayshospitalized` INT(16) NULL DEFAULT NULL ,
  `col_relapsingepisode` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_outcome` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_patient_nicathproblem`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_patient_nicathproblem` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_patient_nicathproblem` (
  `col_patnicathprob_id` INT(16) NULL DEFAULT NULL ,
  `col_patient_id` INT(16) NULL DEFAULT NULL ,
  `col_inittreatmentprovider` INT(16) NULL DEFAULT NULL ,
  `col_problemtype` INT(16) NULL DEFAULT NULL ,
  `col_dateproblemidentified` DATE NULL DEFAULT NULL ,
  `col_treatment` TEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_hospitalized` INT(16) NULL DEFAULT NULL ,
  `col_dayshospitalized` INT(16) NULL DEFAULT NULL ,
  `col_alterntherapyrequired` INT(16) NULL DEFAULT NULL ,
  `col_alterntherapy` INT(16) NULL DEFAULT NULL ,
  `col_treatmentsuccessful` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_patient_system`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_patient_system` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_patient_system` (
  `col_patsystem_id` INT(16) NULL DEFAULT NULL ,
  `col_patient_id` INT(16) NULL DEFAULT NULL ,
  `col_apdsystem` INT(16) NULL DEFAULT NULL ,
  `col_capdsystem` INT(16) NULL DEFAULT NULL ,
  `col_ipdsystem` INT(16) NULL DEFAULT NULL ,
  `col_transferset` INT(16) NULL DEFAULT NULL ,
  `col_startdate` DATE NULL DEFAULT NULL ,
  `col_enddate` DATE NULL DEFAULT NULL ,
  `col_reasonmain` INT(16) NULL DEFAULT NULL ,
  `col_reasondetail1` INT(16) NULL DEFAULT NULL ,
  `col_reasondetail2` INT(16) NULL DEFAULT NULL ,
  `col_exchangesperfby` INT(16) NULL DEFAULT NULL ,
  `col_primarynurse` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_patient_system_exporterrors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_patient_system_exporterrors` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_patient_system_exporterrors` (
  `col_error` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_field` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `col_row` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_race_detail`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_race_detail` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_race_detail` (
  `col_racedetailid` INT(16) NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_race_show`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_race_show` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_race_show` (
  `col_record_id` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_system_show`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_system_show` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_system_show` (
  `col_record_id` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_system_trainer`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_system_trainer` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_system_trainer` (
  `col_record_id` INT(16) NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_system_training`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_system_training` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_system_training` (
  `col_systraining_id` INT(16) NULL DEFAULT NULL ,
  `col_patsystem_id` INT(16) NULL DEFAULT NULL ,
  `col_startdate` DATE NULL DEFAULT NULL ,
  `col_daystrained` INT(16) NULL DEFAULT NULL ,
  `col_trainer` INT(16) NULL DEFAULT NULL ,
  `col_reason` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_system_tsetchangedate`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_system_tsetchangedate` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_system_tsetchangedate` (
  `col_patsystem_id` INT(16) NULL DEFAULT NULL ,
  `col_transsetchangedate` DATE NULL DEFAULT NULL ,
  `col_nurse_id` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_tblpatient_flags`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_tblpatient_flags` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_tblpatient_flags` (
  `col_patient_id` INT(16) NULL DEFAULT NULL ,
  `col_flag_id` INT(16) NULL DEFAULT NULL ,
  `col_show` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_therapyoptioneducator`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_therapyoptioneducator` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_therapyoptioneducator` (
  `col_record_id` INT(16) NULL DEFAULT NULL ,
  `col_description` TINYTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms__poet_raw_usersettings_center`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms__poet_raw_usersettings_center` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms__poet_raw_usersettings_center` (
  `col_previnfec_nummonths` INT(16) NULL DEFAULT NULL ,
  `col_previnfec_numinfecs` INT(16) NULL DEFAULT NULL ,
  `col_reason_months` INT(16) NULL DEFAULT NULL )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms_alerts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms_alerts` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms_alerts` (
  `entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `alert_type` INT(3) NULL DEFAULT NULL ,
  `uid` INT(16) NULL DEFAULT NULL ,
  `pid` INT(16) NULL DEFAULT NULL ,
  `cid` INT(16) NULL DEFAULT NULL ,
  `lid` INT(16) NULL DEFAULT NULL ,
  `tid` INT(16) NULL DEFAULT NULL ,
  `show_after` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (`entry`) )
ENGINE = InnoDB
AUTO_INCREMENT = 972
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms_alerts_archive`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms_alerts_archive` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms_alerts_archive` (
  `entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `alert_entry` INT(16) NULL DEFAULT NULL ,
  `alert_type` INT(3) NULL DEFAULT NULL ,
  `uid` INT(16) NULL DEFAULT NULL ,
  `pid` INT(16) NULL DEFAULT NULL ,
  `cid` INT(16) NULL DEFAULT NULL ,
  `lid` INT(16) NULL DEFAULT NULL ,
  `tid` INT(16) NULL DEFAULT NULL ,
  `show_after` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ,
  `archive_uid` INT(16) NULL DEFAULT NULL ,
  `archive_comment` TEXT NULL DEFAULT NULL ,
  `archive_date` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`entry`) )
ENGINE = InnoDB
AUTO_INCREMENT = 618
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms_antibiotics`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms_antibiotics` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms_antibiotics` (
  `entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `case_id` INT(16) NULL DEFAULT NULL ,
  `antibiotic` VARCHAR(64) NULL DEFAULT NULL ,
  `basis_empiric` INT(1) NULL DEFAULT NULL ,
  `basis_final` INT(1) NULL DEFAULT NULL ,
  `route` VARCHAR(8) NULL DEFAULT NULL ,
  `dose_amount_loading` VARCHAR(8) NULL DEFAULT NULL ,
  `dose_amount` VARCHAR(8) NULL DEFAULT NULL ,
  `dose_amount_units` VARCHAR(8) NULL DEFAULT NULL ,
  `dose_frequency` VARCHAR(8) NULL DEFAULT NULL ,
  `regimen_duration` INT(3) NULL DEFAULT NULL ,
  `date_start` DATE NULL DEFAULT NULL ,
  `date_end` DATE NULL DEFAULT NULL ,
  `date_stopped` DATE NULL DEFAULT NULL ,
  `comments` TEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `created` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ,
  `modified` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`entry`) )
ENGINE = InnoDB
AUTO_INCREMENT = 2411
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms_cases`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms_cases` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms_cases` (
  `entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `patient` INT(16) NULL DEFAULT NULL ,
  `is_peritonitis` TINYINT(1) NULL DEFAULT NULL ,
  `is_exit_site` TINYINT(1) NULL DEFAULT NULL ,
  `is_tunnel` TINYINT(1) NULL DEFAULT NULL ,
  `initial_wbc` VARCHAR(16) NULL DEFAULT NULL ,
  `initial_pmn` VARCHAR(16) NULL DEFAULT NULL ,
  `case_type` VARCHAR(32) NULL DEFAULT NULL ,
  `hospitalization_required` VARCHAR(16) NULL DEFAULT 'No' ,
  `hospitalization_location` VARCHAR(64) NULL DEFAULT 'RCH' ,
  `hospitalization_onset` VARCHAR(16) NULL DEFAULT NULL ,
  `hospitalization_start_date` DATE NULL DEFAULT NULL ,
  `hospitalization_stop_date` DATE NULL DEFAULT NULL ,
  `outcome` VARCHAR(32) NULL DEFAULT 'Outstanding' ,
  `home_visit` VARCHAR(16) NULL DEFAULT 'Pending' ,
  `follow_up_culture` VARCHAR(16) NULL DEFAULT 'No' ,
  `next_step` INT(2) NULL DEFAULT NULL ,
  `closed` INT(1) NOT NULL DEFAULT '0' ,
  `comments` TEXT NULL DEFAULT NULL ,
  `created` DATE NULL DEFAULT NULL ,
  `modified` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`entry`) )
ENGINE = InnoDB
AUTO_INCREMENT = 775
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms_catheters`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms_catheters` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms_catheters` (
  `entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `patient_id` INT(16) NULL DEFAULT NULL ,
  `insertion_location` VARCHAR(32) NULL DEFAULT NULL ,
  `insertion_method` VARCHAR(32) NULL DEFAULT NULL ,
  `type` VARCHAR(64) NULL DEFAULT NULL ,
  `surgeon` INT(16) NULL DEFAULT NULL ,
  `insertion_date` DATE NULL DEFAULT NULL ,
  `removal_date` DATE NULL DEFAULT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  `modified` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`entry`) )
ENGINE = MyISAM
AUTO_INCREMENT = 803
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms_dialysis`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms_dialysis` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms_dialysis` (
  `entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `patient_id` INT(16) NULL DEFAULT NULL ,
  `center` VARCHAR(32) NULL DEFAULT NULL ,
  `type` VARCHAR(8) NULL DEFAULT NULL ,
  `start_date` DATE NULL DEFAULT NULL ,
  `stop_date` DATE NULL DEFAULT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  `modified` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`entry`) )
ENGINE = MyISAM
AUTO_INCREMENT = 818
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms_hide`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms_hide` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms_hide` (
  `entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `case_id` INT(16) NULL DEFAULT NULL ,
  `uid` INT(16) NULL DEFAULT NULL ,
  `hide_until` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`entry`) )
ENGINE = InnoDB
AUTO_INCREMENT = 236
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms_labs`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms_labs` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms_labs` (
  `entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `case_id` INT(16) NULL DEFAULT NULL ,
  `type` VARCHAR(45) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `ordered` DATE NULL DEFAULT NULL ,
  `status` VARCHAR(45) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `comments` TEXT NULL DEFAULT NULL ,
  `pathogen_1` VARCHAR(255) NULL DEFAULT NULL ,
  `pathogen_2` VARCHAR(255) NULL DEFAULT NULL ,
  `pathogen_3` VARCHAR(255) NULL DEFAULT NULL ,
  `pathogen_4` VARCHAR(255) NULL DEFAULT NULL ,
  `result_pre` INT(1) NULL DEFAULT NULL ,
  `result_final` INT(1) NULL DEFAULT NULL ,
  `created` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ,
  `modified` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`entry`) )
ENGINE = InnoDB
AUTO_INCREMENT = 898
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms_patients`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms_patients` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms_patients` (
  `entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `name_first` VARCHAR(64) NULL DEFAULT NULL ,
  `name_last` VARCHAR(64) NULL DEFAULT NULL ,
  `phn` VARCHAR(16) NULL DEFAULT NULL ,
  `phone_home` VARCHAR(32) NULL DEFAULT NULL COMMENT '	' ,
  `phone_work` VARCHAR(32) NULL DEFAULT NULL ,
  `phone_mobile` VARCHAR(32) NULL DEFAULT NULL ,
  `email` VARCHAR(64) NULL DEFAULT NULL ,
  `email_reminder` INT(1) NULL DEFAULT NULL ,
  `date_of_birth` DATE NULL DEFAULT NULL ,
  `weight` DECIMAL(5,2) NULL DEFAULT NULL ,
  `gender` VARCHAR(16) NULL DEFAULT NULL ,
  `disease_diabetes` INT(1) NULL DEFAULT NULL ,
  `disease_cognitive` INT(1) NULL DEFAULT NULL ,
  `disease_psychosocial` INT(1) NULL DEFAULT NULL ,
  `allergies` TINYTEXT NULL DEFAULT NULL ,
  `pd_start_date` DATE NULL DEFAULT NULL ,
  `pd_stop_date` DATE NULL DEFAULT NULL ,
  `dialysis_center` VARCHAR(32) NULL DEFAULT NULL ,
  `dialysis_type` VARCHAR(8) NULL DEFAULT NULL ,
  `catheter_insertion_location` VARCHAR(32) NULL DEFAULT NULL ,
  `catheter_insertion_method` VARCHAR(32) NULL DEFAULT NULL ,
  `catheter_type` VARCHAR(64) NULL DEFAULT NULL ,
  `surgeon` INT(16) NULL DEFAULT NULL ,
  `primary_nurse` INT(16) NULL DEFAULT NULL ,
  `nephrologist` INT(16) NULL DEFAULT NULL ,
  `comments` TEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `cache_primary_nurse` VARCHAR(64) NULL DEFAULT NULL ,
  `cache_nephrologist` VARCHAR(64) NULL DEFAULT NULL ,
  `cache_on_pd` VARCHAR(16) NULL DEFAULT NULL ,
  `cache_cases` VARCHAR(16) NULL DEFAULT NULL ,
  `cache_case_status` VARCHAR(16) NULL DEFAULT NULL ,
  `created` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ,
  `modified` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`entry`) )
ENGINE = InnoDB
AUTO_INCREMENT = 770
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms_reminders`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms_reminders` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms_reminders` (
  `entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `send_to` TINYTEXT NULL DEFAULT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (`entry`) )
ENGINE = InnoDB
AUTO_INCREMENT = 2
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `default_schema`.`ptms_users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`ptms_users` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`ptms_users` (
  `entry` INT(16) NOT NULL AUTO_INCREMENT ,
  `type` VARCHAR(32) NULL DEFAULT 'Administrator' ,
  `email` VARCHAR(64) NULL DEFAULT NULL ,
  `password` VARCHAR(128) NULL DEFAULT NULL ,
  `name_first` VARCHAR(64) NULL DEFAULT NULL ,
  `name_last` VARCHAR(64) NULL DEFAULT NULL ,
  `role` VARCHAR(32) NULL DEFAULT NULL ,
  `deactivated` INT(1) NULL DEFAULT '0' ,
  `opt_in` INT(1) NULL DEFAULT '0' ,
  `created` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ,
  `modified` DATETIME NULL DEFAULT NULL ,
  `accessed` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`entry`) )
ENGINE = InnoDB
AUTO_INCREMENT = 61
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `default_schema`.`sessions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `default_schema`.`sessions` ;

CREATE  TABLE IF NOT EXISTS `default_schema`.`sessions` (
  `id` CHAR(32) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NOT NULL ,
  `a_session` MEDIUMTEXT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `created` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

INSERT INTO ptms_user (email) VALUES ("administrator@renalconnect.com");