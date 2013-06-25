#!/usr/bin/perl

use lib "lib";
use rc::io;
use strict;

# THIS CRON SCRIPT IS DESIGNED TO BE RUN ON A DAILY BASIS AT 1:00 AM LOCAL TIME

# GET CURRENT DATE
my $current_date = &rc::io::fast(qq{SELECT CURDATE()});
my $six_months_ago = &rc::io::fast(qq{SELECT DATE_SUB(CURDATE(), INTERVAL 6 MONTH)});
my $twelve_months_ago = &rc::io::fast(qq{SELECT DATE_SUB(CURDATE(), INTERVAL 12 MONTH)});

# REACTIVATE STARTS ON THE DATE OF FOLLOW-UP
&rc::io::input(qq{UPDATE rc_lists SET completed="No" WHERE flag_for_follow_up_date="$current_date"});

# IF MODALITY AT 6 MONTHS REMAIN BLANK, REACTIVATE LIST 6 MONTHS FROM DATE OF FIRST DIALYSIS
&rc::io::input(qq{UPDATE rc_lists SET completed="No" WHERE ((modality_at_six_months IS NULL) OR (modality_at_six_months='')) AND first_hd_date="$six_months_ago"});
&rc::io::input(qq{UPDATE rc_lists SET completed="No" WHERE ((modality_at_twelve_months IS NULL) OR (modality_at_twelve_months='')) AND first_hd_date="$twelve_months_ago"});