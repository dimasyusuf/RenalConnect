# ************************************************************
# Sequel Pro SQL dump
# Version 4135
#
# http://www.sequelpro.com/
# http://code.google.com/p/sequel-pro/
#
# Host: localhost (MySQL 5.6.25)
# Database: renalconnect
# Generation Time: 2015-06-18 23:33:37 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table rc__hs_antibiotics
# ------------------------------------------------------------

CREATE TABLE `rc__hs_antibiotics` (
  `hs_entry` int(16) NOT NULL AUTO_INCREMENT,
  `hs_uid` int(16) DEFAULT NULL,
  `hs_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `hs_ip` varchar(16) DEFAULT NULL,
  `hs_client` tinytext NOT NULL,
  `entry` int(16) NOT NULL DEFAULT '0',
  `case_id` int(16) DEFAULT NULL,
  `antibiotic` varchar(64) DEFAULT NULL,
  `basis_empiric` int(1) DEFAULT NULL,
  `basis_final` int(1) DEFAULT NULL,
  `route` varchar(8) DEFAULT NULL,
  `dose_amount_loading` varchar(8) DEFAULT NULL,
  `dose_amount` varchar(8) DEFAULT NULL,
  `dose_amount_units` varchar(8) DEFAULT NULL,
  `dose_frequency` varchar(8) DEFAULT NULL,
  `regimen_duration` int(3) DEFAULT NULL,
  `date_start` date DEFAULT NULL,
  `date_end` date DEFAULT NULL,
  `date_stopped` date DEFAULT NULL,
  `comments` text CHARACTER SET utf8 COLLATE utf8_unicode_ci,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`hs_entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table rc__hs_cases
# ------------------------------------------------------------

CREATE TABLE `rc__hs_cases` (
  `hs_entry` int(16) NOT NULL AUTO_INCREMENT,
  `hs_uid` int(16) DEFAULT NULL,
  `hs_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `hs_ip` varchar(16) DEFAULT NULL,
  `hs_client` tinytext NOT NULL,
  `entry` int(16) NOT NULL DEFAULT '0',
  `patient` int(16) DEFAULT NULL,
  `is_peritonitis` tinyint(1) DEFAULT NULL,
  `is_exit_site` tinyint(1) DEFAULT NULL,
  `is_tunnel` tinyint(1) DEFAULT NULL,
  `initial_wbc` varchar(16) DEFAULT NULL,
  `initial_pmn` varchar(16) DEFAULT NULL,
  `case_type` varchar(32) DEFAULT NULL,
  `hospitalization_required` varchar(16) DEFAULT 'No',
  `hospitalization_location` varchar(64) DEFAULT 'RCH',
  `hospitalization_onset` varchar(16) DEFAULT NULL,
  `outcome` varchar(32) DEFAULT 'Outstanding',
  `home_visit` varchar(16) DEFAULT 'Pending',
  `follow_up_culture` varchar(16) DEFAULT 'No',
  `next_step` int(2) DEFAULT NULL,
  `closed` int(1) DEFAULT NULL,
  `comments` text,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`hs_entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table rc__hs_catheters
# ------------------------------------------------------------

CREATE TABLE `rc__hs_catheters` (
  `hs_entry` int(16) NOT NULL AUTO_INCREMENT,
  `hs_uid` int(16) DEFAULT NULL,
  `hs_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `hs_ip` varchar(16) DEFAULT NULL,
  `hs_client` tinytext,
  `entry` int(16) NOT NULL DEFAULT '0',
  `patient_id` int(16) DEFAULT NULL,
  `insertion_location` varchar(32) DEFAULT NULL,
  `insertion_method` varchar(32) DEFAULT NULL,
  `type` varchar(64) DEFAULT NULL,
  `surgeon` int(16) DEFAULT NULL,
  `insertion_date` date DEFAULT NULL,
  `removal_date` date DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`hs_entry`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;



# Dump of table rc__hs_dialysis
# ------------------------------------------------------------

CREATE TABLE `rc__hs_dialysis` (
  `hs_entry` int(16) NOT NULL AUTO_INCREMENT,
  `hs_uid` int(16) DEFAULT NULL,
  `hs_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `hs_ip` varchar(16) DEFAULT NULL,
  `hs_client` tinytext,
  `entry` int(16) NOT NULL DEFAULT '0',
  `patient_id` int(16) DEFAULT NULL,
  `center` varchar(32) DEFAULT NULL,
  `type` varchar(8) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `stop_date` date DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`hs_entry`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;



# Dump of table rc__hs_labs
# ------------------------------------------------------------

CREATE TABLE `rc__hs_labs` (
  `hs_entry` int(16) NOT NULL AUTO_INCREMENT,
  `hs_uid` int(16) DEFAULT NULL,
  `hs_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `hs_ip` varchar(16) DEFAULT NULL,
  `hs_client` tinytext NOT NULL,
  `entry` int(16) NOT NULL DEFAULT '0',
  `case_id` int(16) DEFAULT NULL,
  `type` varchar(45) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `ordered` date DEFAULT NULL,
  `status` varchar(45) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `comments` text,
  `pathogen_1` varchar(255) DEFAULT NULL,
  `pathogen_2` varchar(255) DEFAULT NULL,
  `pathogen_3` varchar(255) DEFAULT NULL,
  `pathogen_4` varchar(255) DEFAULT NULL,
  `result_pre` int(1) DEFAULT NULL,
  `result_final` int(1) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`hs_entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table rc__hs_lists
# ------------------------------------------------------------

CREATE TABLE `rc__hs_lists` (
  `hs_entry` int(16) unsigned NOT NULL AUTO_INCREMENT,
  `hs_uid` int(16) DEFAULT NULL,
  `hs_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `hs_ip` varchar(16) DEFAULT NULL,
  `hs_client` tinytext,
  `entry` int(16) DEFAULT NULL,
  `patient` int(16) DEFAULT NULL,
  `home_centre` varchar(64) DEFAULT NULL,
  `prior_status` varchar(64) DEFAULT NULL,
  `preemptive_transplant_referral` char(3) DEFAULT NULL,
  `kcc_modality_orientation_date` date DEFAULT NULL,
  `kcc_preferred_modality` varchar(32) DEFAULT NULL,
  `first_hd_date` date DEFAULT NULL,
  `tn_initial_assessment_date` date DEFAULT NULL,
  `vascular_access_at_hd_start` varchar(32) DEFAULT NULL,
  `cvc_va_referral_date` date DEFAULT NULL,
  `tn_avf_creation_date` date DEFAULT NULL,
  `tn_avf_use_date` date DEFAULT NULL,
  `candidate_for_home` char(3) DEFAULT NULL,
  `tn_chosen_modality` varchar(64) DEFAULT NULL,
  `tn_chosen_modality_other` tinytext,
  `interested_in_transplant` varchar(64) DEFAULT NULL,
  `incentre_reason` tinytext,
  `incentre_reason_other` tinytext,
  `homehd_hhd_referral_date` date DEFAULT NULL,
  `homehd_hhd_start_date` date DEFAULT NULL,
  `pd_referral_date` date DEFAULT NULL,
  `pd_cath_insertion_date` date DEFAULT NULL,
  `pd_start_date` date DEFAULT NULL,
  `transplant_referral_date` date DEFAULT NULL,
  `transplant_donor_identified` char(3) DEFAULT NULL,
  `transplant_date` date DEFAULT NULL,
  `acp_introduced` char(3) DEFAULT NULL,
  `most_completed_date` date DEFAULT NULL,
  `tn_discharge_date` date DEFAULT NULL,
  `flag_for_follow_up` char(3) DEFAULT NULL,
  `flag_for_follow_up_date` date DEFAULT NULL,
  `follow_up_comments` text,
  `modality_at_six_months` varchar(32) DEFAULT NULL,
  `modality_at_twelve_months` varchar(32) DEFAULT NULL,
  `completed` char(3) DEFAULT NULL,
  `comments` text,
  `created` timestamp NULL DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  `status_at_initial_meeting` varchar(32) DEFAULT NULL,
  `recovered_from_dialysis_dependance` char(3) DEFAULT NULL,
  PRIMARY KEY (`hs_entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table rc__hs_login
# ------------------------------------------------------------

CREATE TABLE `rc__hs_login` (
  `entry` int(16) NOT NULL AUTO_INCREMENT,
  `hs_uid` int(16) DEFAULT NULL,
  `hs_ip` char(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `hs_client` tinytext COLLATE utf8_unicode_ci,
  `hs_action` tinytext COLLATE utf8_unicode_ci,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`entry`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table rc__hs_patients
# ------------------------------------------------------------

CREATE TABLE `rc__hs_patients` (
  `hs_entry` int(16) NOT NULL AUTO_INCREMENT,
  `hs_uid` int(16) DEFAULT NULL,
  `hs_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `hs_ip` varchar(16) DEFAULT NULL,
  `hs_client` tinytext NOT NULL,
  `entry` int(16) NOT NULL DEFAULT '0',
  `name_first` varchar(64) DEFAULT NULL,
  `name_last` varchar(64) DEFAULT NULL,
  `phn` varchar(16) DEFAULT NULL,
  `phone_home` varchar(32) DEFAULT NULL COMMENT '	',
  `phone_work` varchar(32) DEFAULT NULL,
  `phone_mobile` varchar(32) DEFAULT NULL,
  `email` varchar(64) DEFAULT NULL,
  `email_reminder` int(1) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `weight` decimal(5,2) DEFAULT NULL,
  `gender` varchar(16) DEFAULT NULL,
  `disease_diabetes` int(1) DEFAULT NULL,
  `disease_cognitive` int(1) DEFAULT NULL,
  `disease_psychosocial` int(1) DEFAULT NULL,
  `allergies` tinytext,
  `pd_start_date` date DEFAULT NULL,
  `pd_stop_date` date DEFAULT NULL,
  `dialysis_center` varchar(32) DEFAULT NULL,
  `dialysis_type` varchar(8) DEFAULT NULL,
  `catheter_insertion_location` varchar(32) DEFAULT NULL,
  `catheter_insertion_method` varchar(32) DEFAULT NULL,
  `catheter_type` varchar(64) DEFAULT NULL,
  `surgeon` int(16) DEFAULT NULL,
  `primary_nurse` int(16) DEFAULT NULL,
  `nephrologist` int(16) DEFAULT NULL,
  `comments` text CHARACTER SET utf8 COLLATE utf8_unicode_ci,
  `cache_primary_nurse` varchar(64) DEFAULT NULL,
  `cache_nephrologist` varchar(64) DEFAULT NULL,
  `cache_on_pd` varchar(16) DEFAULT NULL,
  `cache_cases` varchar(16) DEFAULT NULL,
  `cache_case_status` varchar(16) DEFAULT NULL,
  `cache_lists` varchar(16) DEFAULT NULL,
  `cache_list_status` varchar(16) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`hs_entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table rc__hs_users
# ------------------------------------------------------------

CREATE TABLE `rc__hs_users` (
  `hs_entry` int(16) NOT NULL AUTO_INCREMENT,
  `hs_uid` int(16) DEFAULT NULL,
  `hs_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `hs_ip` varchar(16) DEFAULT NULL,
  `hs_client` tinytext NOT NULL,
  `entry` int(16) NOT NULL DEFAULT '0',
  `type` varchar(32) DEFAULT 'Administrator',
  `email` varchar(64) DEFAULT NULL,
  `password` varchar(128) DEFAULT NULL,
  `name_first` varchar(64) DEFAULT NULL,
  `name_last` varchar(64) DEFAULT NULL,
  `role` varchar(32) DEFAULT NULL,
  `deactivated` int(1) DEFAULT '0',
  `opt_in` int(1) DEFAULT '0',
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  `accessed` datetime DEFAULT NULL,
  `home_centre` tinytext,
  PRIMARY KEY (`hs_entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table rc_alerts
# ------------------------------------------------------------

CREATE TABLE `rc_alerts` (
  `entry` int(16) NOT NULL AUTO_INCREMENT,
  `alert_type` int(3) DEFAULT NULL,
  `uid` int(16) DEFAULT NULL,
  `pid` int(16) DEFAULT NULL,
  `cid` int(16) DEFAULT NULL,
  `lid` int(16) DEFAULT NULL,
  `tid` int(16) DEFAULT NULL,
  `show_after` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sid` int(16) DEFAULT NULL,
  PRIMARY KEY (`entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table rc_alerts_archive
# ------------------------------------------------------------

CREATE TABLE `rc_alerts_archive` (
  `entry` int(16) NOT NULL AUTO_INCREMENT,
  `alert_entry` int(16) DEFAULT NULL,
  `alert_type` int(3) DEFAULT NULL,
  `uid` int(16) DEFAULT NULL,
  `pid` int(16) DEFAULT NULL,
  `cid` int(16) DEFAULT NULL,
  `lid` int(16) DEFAULT NULL,
  `tid` int(16) DEFAULT NULL,
  `show_after` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `archive_uid` int(16) DEFAULT NULL,
  `archive_comment` text,
  `archive_date` datetime DEFAULT NULL,
  `sid` int(16) DEFAULT NULL,
  PRIMARY KEY (`entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table rc_antibiotics
# ------------------------------------------------------------

CREATE TABLE `rc_antibiotics` (
  `entry` int(16) NOT NULL AUTO_INCREMENT,
  `case_id` int(16) DEFAULT NULL,
  `antibiotic` varchar(64) DEFAULT NULL,
  `basis_empiric` int(1) DEFAULT NULL,
  `basis_final` int(1) DEFAULT NULL,
  `route` varchar(8) DEFAULT NULL,
  `dose_amount_loading` varchar(8) DEFAULT NULL,
  `dose_amount` varchar(8) DEFAULT NULL,
  `dose_amount_units` varchar(8) DEFAULT NULL,
  `dose_frequency` varchar(8) DEFAULT NULL,
  `regimen_duration` int(3) DEFAULT NULL,
  `date_start` date DEFAULT NULL,
  `date_end` date DEFAULT NULL,
  `date_stopped` date DEFAULT NULL,
  `comments` text CHARACTER SET utf8 COLLATE utf8_unicode_ci,
  `created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table rc_cases
# ------------------------------------------------------------

CREATE TABLE `rc_cases` (
  `entry` int(16) NOT NULL AUTO_INCREMENT,
  `patient` int(16) DEFAULT NULL,
  `is_peritonitis` tinyint(1) DEFAULT NULL,
  `is_exit_site` tinyint(1) DEFAULT NULL,
  `is_tunnel` tinyint(1) DEFAULT NULL,
  `initial_wbc` varchar(16) DEFAULT NULL,
  `initial_pmn` varchar(16) DEFAULT NULL,
  `case_type` varchar(32) DEFAULT NULL,
  `hospitalization_required` varchar(16) DEFAULT 'No',
  `hospitalization_location` varchar(64) DEFAULT 'RCH',
  `hospitalization_onset` varchar(16) DEFAULT NULL,
  `hospitalization_start_date` date DEFAULT NULL,
  `hospitalization_stop_date` date DEFAULT NULL,
  `outcome` varchar(32) DEFAULT 'Outstanding',
  `home_visit` varchar(16) DEFAULT 'Pending',
  `follow_up_culture` varchar(16) DEFAULT 'No',
  `next_step` int(2) DEFAULT NULL,
  `closed` int(1) NOT NULL DEFAULT '0',
  `comments` text,
  `created` date DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table rc_catheters
# ------------------------------------------------------------

CREATE TABLE `rc_catheters` (
  `entry` int(16) NOT NULL AUTO_INCREMENT,
  `patient_id` int(16) DEFAULT NULL,
  `insertion_location` varchar(32) DEFAULT NULL,
  `insertion_method` varchar(32) DEFAULT NULL,
  `type` varchar(64) DEFAULT NULL,
  `surgeon` int(16) DEFAULT NULL,
  `insertion_date` date DEFAULT NULL,
  `removal_date` date DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`entry`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;



# Dump of table rc_dialysis
# ------------------------------------------------------------

CREATE TABLE `rc_dialysis` (
  `entry` int(16) NOT NULL AUTO_INCREMENT,
  `patient_id` int(16) DEFAULT NULL,
  `center` varchar(32) DEFAULT NULL,
  `type` varchar(8) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `stop_date` date DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`entry`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;



# Dump of table rc_hide
# ------------------------------------------------------------

CREATE TABLE `rc_hide` (
  `entry` int(16) NOT NULL AUTO_INCREMENT,
  `record_id` int(16) DEFAULT NULL,
  `record_type` char(4) DEFAULT NULL,
  `uid` int(16) DEFAULT NULL,
  `hide_until` datetime DEFAULT NULL,
  PRIMARY KEY (`entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table rc_labs
# ------------------------------------------------------------

CREATE TABLE `rc_labs` (
  `entry` int(16) NOT NULL AUTO_INCREMENT,
  `case_id` int(16) DEFAULT NULL,
  `type` varchar(45) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `ordered` date DEFAULT NULL,
  `status` varchar(45) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `comments` text,
  `pathogen_1` varchar(255) DEFAULT NULL,
  `pathogen_2` varchar(255) DEFAULT NULL,
  `pathogen_3` varchar(255) DEFAULT NULL,
  `pathogen_4` varchar(255) DEFAULT NULL,
  `result_pre` int(1) DEFAULT NULL,
  `result_final` int(1) DEFAULT NULL,
  `created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table rc_lists
# ------------------------------------------------------------

CREATE TABLE `rc_lists` (
  `entry` int(16) unsigned NOT NULL AUTO_INCREMENT,
  `patient` int(16) DEFAULT NULL,
  `home_centre` varchar(64) DEFAULT NULL,
  `prior_status` varchar(64) DEFAULT NULL,
  `preemptive_transplant_referral` char(3) DEFAULT NULL,
  `kcc_modality_orientation_date` date DEFAULT NULL,
  `kcc_preferred_modality` varchar(32) DEFAULT NULL,
  `first_hd_date` date DEFAULT NULL,
  `tn_initial_assessment_date` date DEFAULT NULL,
  `vascular_access_at_hd_start` varchar(32) DEFAULT NULL,
  `cvc_va_referral_date` date DEFAULT NULL,
  `tn_avf_creation_date` date DEFAULT NULL,
  `tn_avf_use_date` date DEFAULT NULL,
  `candidate_for_home` char(3) DEFAULT NULL,
  `tn_chosen_modality` varchar(64) DEFAULT NULL,
  `tn_chosen_modality_other` tinytext,
  `interested_in_transplant` varchar(64) DEFAULT NULL,
  `incentre_reason` tinytext,
  `incentre_reason_other` tinytext,
  `homehd_hhd_referral_date` date DEFAULT NULL,
  `homehd_hhd_start_date` date DEFAULT NULL,
  `pd_referral_date` date DEFAULT NULL,
  `pd_cath_insertion_date` date DEFAULT NULL,
  `pd_start_date` date DEFAULT NULL,
  `transplant_referral_date` date DEFAULT NULL,
  `transplant_donor_identified` char(3) DEFAULT NULL,
  `transplant_date` date DEFAULT NULL,
  `acp_introduced` char(3) DEFAULT NULL,
  `most_completed_date` date DEFAULT NULL,
  `tn_discharge_date` date DEFAULT NULL,
  `flag_for_follow_up` tinytext,
  `flag_for_follow_up_date` date DEFAULT NULL,
  `follow_up_comments` text,
  `modality_at_six_months` varchar(32) DEFAULT NULL,
  `modality_at_twelve_months` varchar(32) DEFAULT NULL,
  `completed` char(3) DEFAULT NULL,
  `comments` text,
  `created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `modified` datetime DEFAULT NULL,
  `status_at_initial_meeting` varchar(32) DEFAULT NULL,
  `recovered_from_dialysis_dependance` char(3) DEFAULT NULL,
  PRIMARY KEY (`entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table rc_patients
# ------------------------------------------------------------

CREATE TABLE `rc_patients` (
  `entry` int(16) NOT NULL AUTO_INCREMENT,
  `name_first` varchar(64) DEFAULT NULL,
  `name_last` varchar(64) DEFAULT NULL,
  `phn` varchar(16) DEFAULT NULL,
  `phone_home` varchar(32) DEFAULT NULL COMMENT '	',
  `phone_work` varchar(32) DEFAULT NULL,
  `phone_mobile` varchar(32) DEFAULT NULL,
  `email` varchar(64) DEFAULT NULL,
  `email_reminder` int(1) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `weight` decimal(5,2) DEFAULT NULL,
  `gender` varchar(16) DEFAULT NULL,
  `disease_diabetes` int(1) DEFAULT NULL,
  `disease_cognitive` int(1) DEFAULT NULL,
  `disease_psychosocial` int(1) DEFAULT NULL,
  `allergies` tinytext,
  `pd_start_date` date DEFAULT NULL,
  `pd_stop_date` date DEFAULT NULL,
  `dialysis_center` varchar(32) DEFAULT NULL,
  `dialysis_type` varchar(8) DEFAULT NULL,
  `catheter_insertion_location` varchar(32) DEFAULT NULL,
  `catheter_insertion_method` varchar(32) DEFAULT NULL,
  `catheter_type` varchar(64) DEFAULT NULL,
  `surgeon` int(16) DEFAULT NULL,
  `primary_nurse` int(16) DEFAULT NULL,
  `nephrologist` int(16) DEFAULT NULL,
  `comments` text CHARACTER SET utf8 COLLATE utf8_unicode_ci,
  `cache_primary_nurse` varchar(64) DEFAULT NULL,
  `cache_nephrologist` varchar(64) DEFAULT NULL,
  `cache_on_pd` varchar(16) DEFAULT NULL,
  `cache_cases` varchar(16) DEFAULT NULL,
  `cache_case_status` varchar(16) DEFAULT NULL,
  `cache_lists` varchar(16) DEFAULT NULL,
  `cache_list_status` varchar(16) DEFAULT NULL,
  `created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table rc_reminders
# ------------------------------------------------------------

CREATE TABLE `rc_reminders` (
  `entry` int(16) NOT NULL AUTO_INCREMENT,
  `send_to` tinytext,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table rc_state
# ------------------------------------------------------------

CREATE TABLE `rc_state` (
  `uid` int(16) NOT NULL,
  `param` varchar(32) NOT NULL DEFAULT '',
  `value` tinytext,
  PRIMARY KEY (`uid`,`param`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table rc_users
# ------------------------------------------------------------

CREATE TABLE `rc_users` (
  `entry` int(16) NOT NULL AUTO_INCREMENT,
  `type` varchar(32) DEFAULT 'Administrator',
  `email` varchar(64) DEFAULT NULL,
  `password` varchar(128) DEFAULT NULL,
  `name_first` varchar(64) DEFAULT NULL,
  `name_last` varchar(64) DEFAULT NULL,
  `role` varchar(32) DEFAULT NULL,
  `deactivated` int(1) DEFAULT '0',
  `opt_in` int(1) DEFAULT '0',
  `created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `modified` datetime DEFAULT NULL,
  `accessed` datetime DEFAULT NULL,
  `home_centre` tinytext,
  PRIMARY KEY (`entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table sessions
# ------------------------------------------------------------

CREATE TABLE `sessions` (
  `id` char(32) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `a_session` mediumtext CHARACTER SET utf8 COLLATE utf8_unicode_ci,
  `created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
