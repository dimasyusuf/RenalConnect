#!/usr/bin/perl

use lib "lib";
use rc::io;
use strict;

my $q = &rc::io::get_q();
my @sid = &rc::io::get_sid();
my %local_settings = &rc::io::get_local_settings();

my ($output_main,
    $output_page,
    $output_popup,
    $output_alerts,
    $output_javascript,
    $output_specialrequest);

my %p = &rc::io::params();
%p = &rc::io::reset_expire(\%p);
&rc::io::store_state(\%p);

$p{'form_patients_phn'} = &rc::io::filter_integer_only($p{'form_patients_phn'});
my $close_button = &rc::io::close_button();
my $ok = &rc::io::auth();
my $token = $ok;





# ======================================
# PROCESS OVERRIDING OR SPECIAL REQUESTS
# ======================================

if ($p{'do'} eq "login") {
	$p{'message_error'} = &rc::io::login(\%p);
	$output_main = &rc::io::viewer(\%p);
} elsif ($p{'do'} eq "logout") {
	my $uid = &rc::io::logout(\%p);
	$output_main = &rc::io::viewer(\%p);
} elsif ($p{'do'} eq "create_administrator") {
	$p{"param_admin_email"} =~ s/ //g;
	my $fnam = $p{"param_admin_name_first"};
	my $lnam = $p{"param_admin_name_last"};
	my $mail = $p{"param_admin_email"};
	my $pass = $p{"param_admin_password"};
	my $repe = $p{"param_admin_password_repeat"};
	my $ekey = $p{"param_admin_key"};
	my $ckey = $local_settings{'encrypt_key'};
	my $is_administrator = &rc::io::fast(qq{SELECT type FROM rc_users WHERE entry="$sid[2]"});
	my $how_many_users = &rc::io::fast(qq{SELECT COUNT(*) FROM rc_users});
	if (($is_administrator ne "Administrator" and $how_many_users > 0) or
		($mail eq '') or
		($pass eq '') or
		($pass ne $repe) or
		($ekey ne $ckey)) {
			$p{'message_error'} = qq{<span class="b">The administrator user cannot be created</span> Please try again or contact technical support for assistance.};
	}
	if ($p{'message_error'} eq '') {
		$pass = &rc::io::encrypt($pass);
		my $id = &rc::io::input(qq{INSERT INTO rc_users (type, email, password, name_first, name_last, role, modified, accessed) VALUES ("Administrator", "$mail", "$pass", "$fnam", "$lnam", "Other", CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP())});
		&rc::io::track("users", $id);
	}
	$output_main = &rc::io::viewer(\%p);
} elsif ($p{'do'} eq "set_duration") {
	my $text = &rc::io::fast(qq{SELECT ADDDATE("$p{'start'}", "$p{'duration'}")});
	$output_specialrequest = qq{
		<div id="send_to_specialrequest">$text</div>
		<img alt='' 
			src="$local_settings{"path_htdocs"}/images/img_logo_fh_pddb.png" 
			onload="ajax_input('form_abx_date_stopped','send_to_specialrequest');"/>};
} elsif ($p{'do'} eq "add_select_patient" and $ok) {
	my $query = $p{"add_select_patient_query"};
	my $mode = $p{"add_select_patient_mode"};
	my $build;
	my $text;
	my @query = split(/ /, $query);
	foreach my $word (@query) {
		$build .= qq{name_first LIKE "\%$word\%" OR name_last LIKE "\%$word\%" OR phn LIKE "\%$word\%" OR };
	}
	$build =~ s/ OR $//g;
	my $sqlquery = qq{SELECT entry, name_last, name_first, phn, cache_cases, cache_case_status, cache_lists, cache_list_status FROM rc_patients WHERE $build ORDER BY name_last ASC, name_first ASC, phn ASC};
	my @patients = &rc::io::querymr($sqlquery);
	my $patients_count = 0;
	foreach my $p (@patients) {
		my $link;
		my $option;
		my $patients_entry = @$p[0];
		my $patients_name_last = @$p[1];
		my $patients_name_first = @$p[2];
		my $patients_phn = @$p[3];
		if ($mode eq "case") {
			my $patients_cache_cases = @$p[4];
			my $patients_cache_case_status = @$p[5];
			if ($patients_cache_cases > 0) {
				if ($patients_cache_case_status == 0) {
					my $patients_case_id = &rc::io::fast(qq{SELECT entry FROM rc_cases WHERE closed="0" AND patient="$patients_entry" LIMIT 1});
					$link = qq{<div class="sml"><a class="sml b" href="ajax.pl?token=$token&do=edit_case_form&case_id=$patients_case_id" target="hbin">View latest open case</a></div>};
					$option = qq{$patients_cache_cases case(s) &mdash; <span class="txt-gre b sml">active</span>};
				} else {
					$link = qq{<div class="sml"><a class="sml b" href="ajax.pl?token=$token&do=add_case_form&patient_id=$patients_entry" target="hbin">Create case</a></div>};
					$option = qq{$patients_cache_cases case(s) &mdash; <span class="txt-red b sml">closed</span>};
				}
			} else {
				$option = qq{No cases};
				$link = qq{<div class="sml"><a class="sml b" href="ajax.pl?token=$token&do=add_case_form&patient_id=$patients_entry" target="hbin">Create case</a></div>};
			}
		} else {
			my $patients_cache_lists = @$p[6];
			my $patients_cache_list_status = @$p[7];
			if ($patients_cache_lists > 0) {
				if ($patients_cache_list_status ne "Yes") {
					my $patients_list_id = &rc::io::fast(qq{SELECT entry FROM rc_lists WHERE (completed <> "Yes" OR completed IS NULL) AND patient="$patients_entry" LIMIT 1});
					$link = qq{<div class="sml"><a class="sml b" href="ajax.pl?token=$token&do=view_list&list_id=$patients_list_id" target="hbin">View latest open start</a></div>};
					$option = qq{$patients_cache_lists start(s) &mdash; <span class="txt-gre b sml">active</span>};
				} else {
					$link = qq{<div class="sml"><a class="sml b" href="ajax.pl?token=$token&do=view_list&patient_id=$patients_entry" target="hbin">Create start</a></div>};
					$option = qq{$patients_cache_lists start(s) &mdash; <span class="txt-red b sml">closed</span>};
				}
			} else {
				$option = qq{No starts};
				$link = qq{<div class="sml"><a class="sml b" href="ajax.pl?token=$token&do=view_list&patient_id=$patients_entry" target="hbin">Create start</a></div>};
			}
		}
		$text .= qq{
			<div class="float-l w25p">
				<div class="p5to p5ro">
					<div class="bg-vlg p5">
						<div class="b he18 oH" id="ncpn_$patients_count"> $patients_name_last, $patients_name_first </div>
						<div class="sml gt" id="ncpp_$patients_count">PHN $patients_phn </div>
						<div class="sml gt">$option</div>
						$link
					</div>
				</div>
			</div>};
		$patients_count++;
	}
	$output_specialrequest = qq{
		<div id="send_to_specialrequest">$text</div>
		<img alt='' 
			src="$local_settings{"path_htdocs"}/images/img_logo_fh_pddb.png" 
			onload="ajax('form_patient_selector','send_to_specialrequest');"/>};
}





# =========================================================
# PROCESS REQUESTS THAT WILL BE PLACED IN THE POP-UP WINDOW
# =========================================================

if ($p{'do'} eq "view_dismissed_alerts" and $ok) {
	$output_popup .= &rc::io::get_alerts_dismissed();
} elsif ($p{'do'} eq "make_administrator" and $ok) {
	if ($p{'uid'} ne '' and &rc::io::fast(qq{SELECT entry FROM rc_users WHERE entry="$sid[2]" AND type="Administrator"})) {
		my ($uid, $rl, $nf, $nl, $em) = &rc::io::query(qq{SELECT entry, role, name_first, name_last, email FROM rc_users WHERE entry="$p{'uid'}"});
		if ($uid) {
			&rc::io::input(qq{UPDATE rc_users SET type="Administrator" WHERE entry="$uid"});
			&rc::io::track("users", $uid);
			if ($rl eq "Nephrologist" or $rl eq "Surgeon") {
				$rl = "Dr. ";
			} else {
				$rl = '';
			}
			$p{'message_success'} = qq{<span class="b">$rl $nf $nl ($em) is now an administrator.</span>};
		}
	}
	$output_popup .= &rc::io::view_manage_users(\%p);
} elsif ($p{'do'} eq "deactivate" and $ok) {
	if ($p{'uid'} ne '' and &rc::io::fast(qq{SELECT entry FROM rc_users WHERE entry="$sid[2]" AND type="Administrator"})) {
		my ($uid, $rl, $nf, $nl, $em) = &rc::io::query(qq{SELECT entry, role, name_first, name_last, email FROM rc_users WHERE entry="$p{'uid'}"});
		if ($uid) {
			&rc::io::input(qq{UPDATE rc_users SET deactivated='1' WHERE entry="$uid"});
			&rc::io::track("users", $uid);
			if ($rl eq "Nephrologist" or $rl eq "Surgeon") {
				$rl = "Dr. ";
			} else {
				$rl = '';
			}
			$p{'message_success'} = qq{<span class="b">The account for $rl $nf $nl ($em) has been deactivated.</span>};
		}
	}
	$output_popup .= &rc::io::view_manage_users(\%p);
} elsif ($p{'do'} eq "reactivate" and $ok) {
	if ($p{'uid'} ne '' and &rc::io::fast(qq{SELECT entry FROM rc_users WHERE entry="$sid[2]" AND type="Administrator"})) {
		my ($uid, $rl, $nf, $nl, $em) = &rc::io::query(qq{SELECT entry, role, name_first, name_last, email FROM rc_users WHERE entry="$p{'uid'}"});
		if ($uid) {
			&rc::io::input(qq{UPDATE rc_users SET deactivated="0" WHERE entry="$uid"});
			&rc::io::track("users", $uid);
			if ($rl eq "Nephrologist" or $rl eq "Surgeon") {
				$rl = "Dr. ";
			} else {
				$rl = '';
			}
			$p{'message_success'} = qq{<span class="b">The account for $rl $nf $nl ($em) has been reactivated.</span>};
		}
	}
	$output_popup .= &rc::io::view_manage_users(\%p);
} elsif ($p{'do'} eq "add_user_form" and $ok) {
	$output_popup .= &rc::io::add_user_form(\%p);
} elsif ($p{'do'} eq "add_user_save" and $ok) {
	my $go = 1;
	my @columns = ("type","email","password","name_first","name_last","role");
	foreach my $column (@columns) {
		if ($p{"form_new_user_$column"} eq '') {
			$go = 0;
		}
	}
	if ($go == 0) {
		$p{'message_error'} = qq{<span class="b">This user cannot be added.</span> Please ensure that all required fields are completed correctly and try again.};
	} elsif (&rc::io::fast(qq{SELECT entry FROM rc_users WHERE email="$p{'form_new_user_email'}"})) {
		$p{'message_error'} = qq{<span class="b">A user with the email address $p{'form_new_user_email'} already exists in the database.</span> Please enter a differente email address, ensure that all required fields are completed correctly and try again.};
	} elsif (length($p{"form_new_user_password"}) < 8) {
		$p{'message_error'} = qq{<span class="b">The password you have selected is too short.</span> Please enter a password that is at least 8 characters in length, ensure that all required fields are completed correctly and try again.};
	} else {
		my $password_encrypted = &rc::io::encrypt($p{"form_new_user_password"});
		$p{'form_new_user_email'} =~ s/ //g;
		my $id = &rc::io::input(qq{INSERT INTO rc_users (type, email, password, name_first, name_last, role, opt_in) VALUES ("$p{'form_new_user_type'}", "$p{'form_new_user_email'}", "$password_encrypted", "$p{'form_new_user_name_first'}", "$p{'form_new_user_name_last'}", "$p{'form_new_user_role'}", "$p{'form_new_user_opt_in'}")});
		if ($id ne '') {
			&rc::io::track("users", $id);
			$output_popup .= qq{
					<div class="suc"><span class="b">New user added.</span> What would you like to do now?</div>
					<div>
						<a href="ajax.pl?token=$token&do=edit_manage_users_form" class="sab" target="hbin">Manage users</a> 
						<a class="sab" onclick="pop_up_hide(); clear_date_picker();">Close this box</a>
					</div>};
		} else {
			$p{'message_error'} = qq{<span class="b">This user cannot be added.</span> Please ensure that all required fields are completed correctly and try again.};
		}
	}
	if ($p{'message_error'} ne '') {
		$output_popup .= &rc::io::add_user_form(\%p);
	}
} elsif ($p{'do'} eq "hide" and $ok) {
	my $update_entry = &rc::io::fast(qq{SELECT entry FROM rc_hide WHERE record_id="$p{'record_id'}" AND record_type="$p{'record_type'}" AND uid="$sid[2]"});
	my $until_date = &rc::io::fast(qq{SELECT DATE_ADD(CURRENT_DATE(), INTERVAL 1 DAY)});
	my $until_time = qq{06:00:00};
	if ($update_entry ne '') {
		&rc::io::input(qq{UPDATE rc_hide SET hide_until="$until_date $until_time" WHERE record_id="$p{'record_id'}" AND record_type="$p{'record_type'}" AND uid="$sid[2]"});
	} else {
		if ($p{"record_id"} ne '') {
			&rc::io::input(qq{INSERT INTO rc_hide (record_id, uid, hide_until, record_type) VALUES ("$p{'record_id'}", "$sid[2]", "$until_date $until_time", "$p{'record_type'}")});
		}
	}
} elsif ($p{'do'} eq "unhide" and $ok) {
	&rc::io::input(qq{DELETE FROM rc_hide WHERE uid="$sid[2]" AND record_type="$p{'record_type'}"});
} elsif ($p{'do'} eq "dismiss" and $ok) {
	&rc::io::input(qq{UPDATE rc_alerts SET show_after=ADDDATE(CURDATE(), '1 0:0:0') WHERE entry="$p{'aid'}"});
	&rc::io::archive_alert($p{'aid'}, $sid[2], $p{'dismiss_reason'});
} elsif ($p{'do'} eq "add_patient_form" and $ok) {
	$output_popup .= &rc::io::view_patient(\%p);
} elsif ($p{'do'} eq "add_patient_save" and $ok) {
	&check_patient_input();
	if ($p{'message_error'} eq '') {
		my @columns = ("name_first", "name_last", "phn", "phone_home", "phone_work", "phone_mobile", "email", "email_reminder", "date_of_birth", "weight", "gender", "disease_diabetes", "disease_cognitive", "disease_psychosocial", "allergies", "pd_start_date", "pd_stop_date", "dialysis_center", "dialysis_type", "catheter_insertion_location", "catheter_insertion_method", "catheter_type", "primary_nurse", "nephrologist", "comments");
		foreach my $column (@columns) {
			$p{"form_patients_$column"} = &rc::io::or_null($p{"form_patients_$column"});
		}
		my $id = &rc::io::input(qq{INSERT INTO rc_patients (name_first, name_last, phn, phone_home, phone_work, phone_mobile, email, email_reminder, date_of_birth, weight, gender, disease_diabetes, disease_cognitive, disease_psychosocial, allergies, pd_start_date, pd_stop_date, dialysis_center, dialysis_type, catheter_insertion_location, catheter_insertion_method, catheter_type, primary_nurse, nephrologist, comments, modified) VALUES ($p{'form_patients_name_first'}, $p{'form_patients_name_last'}, $p{'form_patients_phn'}, $p{'form_patients_phone_home'}, $p{'form_patients_phone_work'}, $p{'form_patients_phone_mobile'}, $p{'form_patients_email'}, $p{'form_patients_email_reminder'}, $p{'form_patients_date_of_birth'}, $p{'form_patients_weight'}, $p{'form_patients_gender'}, $p{'form_patients_disease_diabetes'}, $p{'form_patients_disease_cognitive'}, $p{'form_patients_disease_psychosocial'}, $p{'form_patients_allergies'}, $p{'form_patients_pd_start_date'}, $p{'form_patients_pd_stop_date'}, $p{'form_patients_dialysis_center'}, $p{'form_patients_dialysis_type'}, $p{'form_patients_catheter_insertion_location'}, $p{'form_patients_catheter_insertion_method'}, $p{'form_patients_catheter_type'}, $p{'form_patients_primary_nurse'}, $p{'form_patients_nephrologist'}, $p{'form_patients_comments'}, CURRENT_TIMESTAMP())});
		if ($id ne '') {
			&rc::io::track("users", $id);
			&rc::io::cache_rebuild_patient($id);
			$output_popup .= qq{
				<div class="suc"><span class="b">Patient information added.</span> What would you like to do now?</div>
				<div>
					<a href="ajax.pl?token=$token&do=edit_patient_form&amp;patient_id=$id" class="sab" target="hbin">View patient information</a> 
					<a href="ajax.pl?token=$token&do=add_case_form&amp;patient_id=$id" class="sab" target="hbin">Add a new case for this patient</a>
					<a class="sab" onclick="pop_up_hide(); clear_date_picker();">Close this box</a>
				</div>};
		} else {
			$p{'message_error'} = qq{<span class="b">This patient's information cannot be added.</span> Please ensure that all required fields are completed correctly and try again.};
		}
	}
	if ($p{'message_error'} ne '') {
		$output_popup .= &rc::io::view_patient(\%p);
	}
} elsif (($p{'do'} eq "edit_patient_form") and ($p{"patient_id"} ne '') and $ok) {
	$output_popup .= &rc::io::view_patient(\%p);
} elsif ($p{'do'} eq "edit_patient_save" and $p{"patient_id"} ne '' and $ok) {
	&check_patient_input();
	if ($p{'message_error'} eq '') {
		my @columns = ("name_first", "name_last", "phn", "phone_home", "phone_work", "phone_mobile", "email", "email_reminder", "date_of_birth", "weight", "gender", "disease_diabetes", "disease_cognitive", "disease_psychosocial", "allergies", "pd_start_date", "pd_stop_date", "dialysis_center", "dialysis_type", "catheter_insertion_location", "catheter_insertion_method", "catheter_type", "primary_nurse", "nephrologist", "comments");
		foreach my $column (@columns) {
			$p{"form_patients_$column"} = &rc::io::or_null($p{"form_patients_$column"});
		}
		my $id = &rc::io::input(qq{UPDATE rc_patients SET name_first=$p{'form_patients_name_first'}, name_last=$p{'form_patients_name_last'}, phn=$p{'form_patients_phn'}, phone_home=$p{'form_patients_phone_home'}, phone_work=$p{'form_patients_phone_work'}, phone_mobile=$p{'form_patients_phone_mobile'}, email=$p{'form_patients_email'}, email_reminder=$p{'form_patients_email_reminder'}, date_of_birth=$p{'form_patients_date_of_birth'}, weight=$p{'form_patients_weight'}, gender=$p{'form_patients_gender'}, disease_diabetes=$p{'form_patients_disease_diabetes'}, disease_cognitive=$p{'form_patients_disease_cognitive'}, disease_psychosocial=$p{'form_patients_disease_psychosocial'}, allergies=$p{'form_patients_allergies'}, pd_start_date=$p{'form_patients_pd_start_date'}, pd_stop_date=$p{'form_patients_pd_stop_date'}, dialysis_center=$p{'form_patients_dialysis_center'}, dialysis_type=$p{'form_patients_dialysis_type'}, catheter_insertion_location=$p{'form_patients_catheter_insertion_location'}, catheter_insertion_method=$p{'form_patients_catheter_insertion_method'}, catheter_type=$p{'form_patients_catheter_type'}, primary_nurse=$p{'form_patients_primary_nurse'}, nephrologist=$p{'form_patients_nephrologist'}, comments=$p{'form_patients_comments'}, modified=CURRENT_TIMESTAMP() WHERE entry=$p{'patient_id'}});
		&rc::io::track("patients", $p{"patient_id"});
		&rc::io::cache_rebuild_patient($p{"patient_id"});
		$output_popup .= qq{
			<div class="suc">
				<span class="b">Patient information updated.</span> What would you like to do now?
			</div><div>
				<a href="ajax.pl?token=$token&do=edit_patient_form&amp;patient_id=$p{"patient_id"}" class="sab" target="hbin">View patient information</a> 
				<a href="ajax.pl?token=$token&do=add_case_form&amp;patient_id=$p{"patient_id"}" class="sab" target="hbin">Add a new case for this patient</a>
				<a class="sab" onclick="pop_up_hide();  clear_date_picker();">Close this box</a>
			</div>};
	}
	if ($p{'message_error'} ne '') {
		$output_popup .= &rc::io::view_patient(\%p);
	}
} elsif ($p{'do'} eq "view_list" and $ok) {
	$output_popup .= &rc::io::view_list(\%p);
} elsif ($p{'do'} eq "save_list" and $ok) {
	my $list_id;
	if ($p{"list_id"} eq '') {
		#SAVE NEW LIST
		my $columns;
		my $values;
		my $patient_id = &rc::io::fast(qq{SELECT entry FROM rc_patients WHERE entry="$p{'patient_id'}" LIMIT 1});
		if ($patient_id ne '' and $p{'form_list_home_centre'} ne '') {
			%p = &rc::io::check_if_list_complete_on_discharge(\%p);
			$p{"form_list_patient"} = $patient_id;
			foreach my $key (keys %p) {
				if ($key =~ /^form_list_/) {
					my $value = &rc::io::or_null($p{$key});
					$values .= $value . qq{, };
					$key =~ s/^form_list_//g;
					$columns .= qq{$key, };
				}
			}
			$columns .= qq{modified};
			$values .= qq{CURRENT_TIMESTAMP()};
			$list_id = &rc::io::input(qq{INSERT INTO rc_lists ($columns) VALUES ($values)});
			if ($p{'message_error'} eq '') {
				$p{'message_success'} = qq{<span class="b">List saved.</span>};
				my $mrp = &rc::io::fast(qq{SELECT nephrologist FROM rc_patients WHERE entry="$p{'form_list_patient'}" LIMIT 1});
				my ($dr_name_first, $dr_name_last, $dr_email) = &rc::io::query(qq{SELECT name_first, name_last, email FROM rc_users WHERE entry="$mrp"});
				if ($dr_name_last ne '' and $dr_email ne '') {
					my %mail = (
						"to" => $dr_email,
						"from" => $local_settings{"email_sender_from"},
						"cc" => '',
						"bcc" => '',
						"subject" => "You have a new patient on RenalConnect",
						"body" => qq{Dear Dr. $dr_name_last,\n\nYou have a new patient who has started hemodialysis at $p{'form_list_home_centre'} and is followed by a transition nurse.}	);
					&rc::io::mailer(\%mail);
				}
			}
			$p{"list_id"} = $list_id;
		} else {
			$p{'message_error'} = 1;
		}
	} else {
		# UPDATE EXISTING LIST
		$list_id = &rc::io::fast(qq{SELECT entry FROM rc_lists WHERE entry="$p{'list_id'}" LIMIT 1});
		if ($list_id ne '' and $p{'form_list_home_centre'} ne '') {
			my $query;
			my $patient_id = &rc::io::fast(qq{SELECT patient FROM rc_lists WHERE entry="$list_id" LIMIT 1});
			if ($patient_id ne '') {
				%p = &rc::io::check_if_list_complete_on_discharge(\%p);
				foreach my $key (keys %p) {
					if ($key =~ /^form_list_/) {
						my $value = &rc::io::or_null($p{$key});
						my $column = $key;
						$column =~ s/^form_list_//g;
						$query .= qq{$column=$value, };
					}
				}
				$query .= qq{modified=CURRENT_TIMESTAMP()};
				&rc::io::input(qq{UPDATE rc_lists SET $query WHERE entry="$list_id"});
				&rc::io::track("lists", $list_id);
				&rc::io::cache_rebuild_patient($p{"patient_id"});				
				if ($p{'message_error'} eq '') {
					$p{'message_success'} = qq{<span class="b">List saved.</span>};
				}
			} else {
				$p{'message_error'} = 1;
			}
		}
	}
	if ($list_id eq '') {
		$p{'message_error'} = 1;
	}
	if ($p{'message_error'} eq 1) {
		$p{'message_error'} = qq{
			<span class="b">This case cannot be saved.</span> 
			Please ensure that a home centre is provided and try again.};
	} elsif ($p{'message_error'} eq 2) {
		$p{'message_error'} = qq{
			<span class="b">This case cannot be signed off.</span> 
			Please ensure that all required fields, as marked by the red bullets,
			are completed and try again.};
	} else {
		$p{'message_error'} = '';
	}
	$output_popup .= &rc::io::view_list(\%p);
} elsif ($p{'do'} eq "delete_list" and $ok) {
	$p{"list_id"} = &rc::io::fast(qq{SELECT entry FROM rc_lists WHERE entry="$p{'list_id'}"});
	if ($p{"list_id"} ne '') {
		if ($p{"confirm_delete"} eq '1') {
			my $patient_id = &rc::io::fast(qq{SELECT patient FROM rc_lists WHERE entry="$p{'list_id'}"});
			&rc::io::input(qq{DELETE FROM rc_lists WHERE entry="$p{"list_id"}"});
			&rc::io::cache_rebuild_patient($patient_id);
			$output_popup .= qq{
				$close_button
				<div class="suc">
					<span class="b">This case has been deleted.</span>
					<div class="p10to">
						<a href="$local_settings{"path_htdocs"}/images/blank.gif" target="hbin" class="b" onclick="pop_up_hide();">Close this box</a>
					</div>
				</div>};
		} else {
			$output_popup .= qq{
				$close_button
				<div class="emp">
					<span class="b">Are you sure you want to delete this case?</span> 
					Cases should not be deleted unless they were created in error. 
					This action cannot be undone, however, a record of this case will 
					still be kept in the archive for auditing purposes. If you are 
					unsure, please contact your group leader before proceeding.
					<div class="p10to">
						<a href="ajax.pl?token=$token&do=delete_list&list_id=$p{"list_id"}&confirm_delete=1" target="hbin">Yes, delete</a> &nbsp; &nbsp; 
						<a href="ajax.pl?token=$token&do=view_list&list_id=$p{"list_id"}" target="hbin" class="b">No, do not delete this case</a>
					</div>
				</div>};
		}
	}
} elsif ($p{'do'} eq "add_case_form" and $ok) {
	$output_popup .= &rc::io::view_case(\%p);
} elsif ($p{'do'} eq "add_case_save" and $ok) {
	&check_case_input("add");
	if ($p{'message_error'} eq '') {
		my @columns = ("patient", "is_peritonitis", "is_exit_site", "is_tunnel", "initial_wbc", "initial_pmn", "case_type", "hospitalization_required", "hospitalization_location", "hospitalization_onset", "hospitalization_start_date", "hospitalization_stop_date", "outcome", "home_visit", "follow_up_culture", "comments", "modified", "created");
		foreach my $column (@columns) {
			$p{"form_case_$column"} = &rc::io::or_null($p{"form_case_$column"});
		}
		my $id = &rc::io::input(qq{INSERT INTO rc_cases (patient, is_peritonitis, is_exit_site, is_tunnel, initial_wbc, initial_pmn, case_type, hospitalization_required, hospitalization_location, hospitalization_onset, hospitalization_start_date, hospitalization_stop_date, outcome, home_visit, follow_up_culture, comments, modified, closed, created) VALUES ($p{'patient_id'}, $p{'form_case_is_peritonitis'}, $p{'form_case_is_exit_site'}, $p{'form_case_is_tunnel'}, $p{'form_case_initial_wbc'}, $p{'form_case_initial_pmn'}, $p{'form_case_case_type'}, $p{'form_case_hospitalization_required'}, $p{'form_case_hospitalization_location'}, $p{'form_case_hospitalization_onset'}, $p{'form_case_hospitalization_start_date'}, $p{'form_case_hospitalization_stop_date'}, $p{'form_case_outcome'}, $p{'form_case_home_visit'}, $p{'form_case_follow_up_culture'}, $p{'form_case_comments'}, CURRENT_TIMESTAMP(), "0", $p{'form_case_created'})});
		if ($id ne '') {
			if ($p{"form_special_weight"} ne '' and $p{"form_special_weight"} > 0 and $p{"patient_id"} ne '') {
				&rc::io::input(qq{UPDATE rc_patients SET weight="$p{"form_special_weight"}" WHERE entry="$p{"patient_id"}"});
			}
			&rc::io::get_next_step($id);
			&rc::io::track("cases", $id);
			&rc::io::cache_rebuild_patient($p{"patient_id"});
			$output_popup .= qq{
				<div class="suc"><span class="b">Case information added.</span> What would you like to do now?
				</div><div>
					<a href="ajax.pl?token=$token&do=edit_case_form&amp;case_id=$id" class="sab" target="hbin">Manage case</a> 
					<a href="ajax.pl?token=$token&do=add_lab_form&amp;case_id=$id" class="sab" target="hbin">Add culture result</a> 
					<a href="ajax.pl?token=$token&do=add_antibiotic_form&amp;case_id=$id" class="sab" target="hbin">Add antibiotic therapy</a>
					<a class="sab" onclick="pop_up_hide(); clear_date_picker();">Close this box</a>
				</div>};
		} else {
			$p{'message_error'} = qq{<span class="b">This case cannot be added.</span> Please ensure that all required fields are completed correctly and try again.};
		}
	}
	if ($p{'message_error'} ne ''){
		$output_popup .= &rc::io::view_case(\%p);
	}
} elsif (($p{'do'} eq "edit_case_form") and ($p{"case_id"} ne '') and $ok) {
	$output_popup .= &rc::io::view_case(\%p);
} elsif ($p{'do'} eq "edit_case_save" and $p{"case_id"} ne '' and $ok) {
	&check_case_input("edit");
	if ($p{'message_error'} eq '') {
		($p{"form_case_closed"}, $p{"form_special_patient_id"}) = &rc::io::query(qq{SELECT closed, patient FROM rc_cases WHERE entry="$p{"case_id"}"});
		my @columns = ("is_peritonitis", "is_exit_site", "is_tunnel", "initial_wbc", "initial_pmn", "case_type", "hospitalization_required", "hospitalization_location", "hospitalization_onset", "hospitalization_start_date", "hospitalization_stop_date", "outcome", "home_visit", "follow_up_culture", "comments", "created");
		foreach my $column (@columns) {
			$p{"form_case_$column"} = &rc::io::or_null($p{"form_case_$column"});
		}
		my $id = &rc::io::input(qq{UPDATE rc_cases SET is_peritonitis=$p{'form_case_is_peritonitis'}, is_exit_site=$p{'form_case_is_exit_site'}, is_tunnel=$p{'form_case_is_tunnel'}, initial_wbc=$p{'form_case_initial_wbc'}, initial_pmn=$p{'form_case_initial_pmn'}, case_type=$p{'form_case_case_type'}, hospitalization_required=$p{'form_case_hospitalization_required'}, hospitalization_location=$p{'form_case_hospitalization_location'}, hospitalization_onset=$p{'form_case_hospitalization_onset'}, hospitalization_start_date=$p{'form_case_hospitalization_start_date'}, hospitalization_stop_date=$p{'form_case_hospitalization_stop_date'}, outcome=$p{'form_case_outcome'}, home_visit=$p{'form_case_home_visit'}, follow_up_culture=$p{'form_case_follow_up_culture'}, comments=$p{'form_case_comments'}, created=$p{'form_case_created'}, modified=CURRENT_TIMESTAMP() WHERE entry="$p{'case_id'}"});
		if ($p{"form_special_weight"} ne '' and $p{"form_special_weight"} > 0 and $p{"form_special_patient_id"} ne '') {
			&rc::io::input(qq{UPDATE rc_patients SET weight="$p{"form_special_weight"}" WHERE entry="$p{"form_special_patient_id"}"});
		}
		&rc::io::get_next_step($p{"case_id"});
		&rc::io::track("cases", $p{"case_id"});
		&rc::io::cache_rebuild_patient($p{"patient_id"});
		$output_popup .= qq{
			<div class="suc">
				<span class="b">Case information updated.</span> What would you like to do now?
			</div><div>
				<a href="ajax.pl?token=$token&do=edit_case_form&amp;case_id=$p{"case_id"}" class="sab" target="hbin">Manage case</a> 
				<a href="ajax.pl?token=$token&do=add_lab_form&amp;case_id=$p{"case_id"}" class="sab" target="hbin">Add culture result</a> 
				<a href="ajax.pl?token=$token&do=add_antibiotic_form&amp;case_id=$p{"case_id"}" class="sab" target="hbin">Add antibiotic therapy</a>
				<a class="sab" onclick="pop_up_hide(); clear_date_picker();">Close this box</a>
			</div>};
	}
	if ($p{'message_error'} ne ''){
		$output_popup .= &rc::io::view_case(\%p);
	}
} elsif ($p{'do'} eq "add_catheter_form" and $ok) {
	$output_popup .= &rc::io::view_catheter(\%p);
} elsif ($p{'do'} eq "add_catheter_save" and $ok) {
	&check_catheter_input("add");
	if ($p{'message_error'} ne '') {
		$output_popup .= &rc::io::view_catheter(\%p);
	} else {
		my @columns = ("insertion_location", "insertion_method", "type", "surgeon", "insertion_date", "removal_date");
		my $columns;
		my $inserts;
		foreach my $column (@columns) {
			$p{"form_catheter_$column"} = &rc::io::or_null($p{"form_catheter_$column"});
			$columns .= qq{$column, };
			$inserts .= qq{$p{"form_catheter_$column"}, };
		}
		my $id = &rc::io::input(qq{INSERT INTO rc_catheters (patient_id, $columns modified) VALUES ("$p{'patient_id'}", $inserts CURRENT_TIMESTAMP())});
		if ($id ne '') {
			&rc::io::track("catheters", $id);
			$p{"patient_id"} = &rc::io::fast(qq{SELECT patient_id FROM rc_catheters WHERE entry="$id"});
			$p{'do'} = "edit_patient_form";
			$p{"do_reload"} = "add_catheter_save";
			$output_popup .= &rc::io::view_patient(\%p);
		}
	}
} elsif (($p{'do'} eq "edit_catheter_form") and $ok) {
	$output_popup .= &rc::io::view_catheter(\%p);
} elsif (($p{'do'} eq "edit_catheter_save") and ($p{"catheter_id"} ne '') and $ok) {
	&check_catheter_input("edit");
	if ($p{'message_error'} ne '') {
		$output_popup .= &rc::io::view_catheter(\%p);
	} else {
		my $rc_catheter_query;
		my @rc_catheter_columns = ("insertion_location", "insertion_method", "type", "surgeon", "insertion_date", "removal_date");
		foreach my $column (@rc_catheter_columns) {
			$p{"form_catheter_$column"} = &rc::io::or_null($p{"form_catheter_$column"});
			$rc_catheter_query .= qq{$column=$p{"form_catheter_$column"}, };
		}
		&rc::io::input(qq{UPDATE rc_catheters SET $rc_catheter_query modified=CURRENT_TIMESTAMP() WHERE entry="$p{"catheter_id"}"});
		&rc::io::track("catheters", $p{"catheter_id"});
		$p{'do'} = "edit_patient_form";
		$p{"do_reload"} = "edit_catheter_save";
		$output_popup .= &rc::io::view_patient(\%p);
	}
} elsif ($p{'do'} eq "add_dialysis_form" and $ok) {
	$output_popup .= &rc::io::view_dialysis(\%p);
} elsif ($p{'do'} eq "add_dialysis_save" and $ok) {
	&check_dialysis_input("add");
	if ($p{'message_error'} ne '') {
		$output_popup .= &rc::io::view_dialysis(\%p);
	} else {
		my @columns = ("center", "type", "start_date", "stop_date");
		my $columns;
		my $inserts;
		foreach my $column (@columns) {
			$p{"form_dialysis_$column"} = &rc::io::or_null($p{"form_dialysis_$column"});
			$columns .= qq{$column, };
			$inserts .= qq{$p{"form_dialysis_$column"}, };
		}
		my $id = &rc::io::input(qq{INSERT INTO rc_dialysis (patient_id, $columns modified) VALUES ("$p{'patient_id'}", $inserts CURRENT_TIMESTAMP())});
		if ($id ne '') {
			&rc::io::track("dialysis", $id);
			$p{"patient_id"} = &rc::io::fast(qq{SELECT patient_id FROM rc_dialysis WHERE entry="$id"});
			$p{'do'} = "edit_patient_form";
			$p{"do_reload"} = "add_dialysis_save";
			$output_popup .= &rc::io::view_patient(\%p);
		}
	}
} elsif (($p{'do'} eq "edit_dialysis_form") and $ok) {
	$output_popup .= &rc::io::view_dialysis(\%p);
} elsif (($p{'do'} eq "edit_dialysis_save") and ($p{"dialysis_id"} ne '') and $ok) {
	&check_dialysis_input("edit");
	if ($p{'message_error'} ne '') {
		$output_popup .= &rc::io::view_dialysis(\%p);
	} else {
		my $rc_dialysis_query;
		my @rc_dialysis_columns = ("center", "type", "start_date", "stop_date");
		foreach my $column (@rc_dialysis_columns) {
			$p{"form_dialysis_$column"} = &rc::io::or_null($p{"form_dialysis_$column"});
			$rc_dialysis_query .= qq{$column=$p{"form_dialysis_$column"}, };
		}
		&rc::io::input(qq{UPDATE rc_dialysis SET $rc_dialysis_query modified=CURRENT_TIMESTAMP() WHERE entry="$p{"dialysis_id"}"});
		&rc::io::track("dialysis", $p{"dialysis_id"});
		$p{'do'} = "edit_patient_form";
		$p{"do_reload"} = "edit_dialysis_save";
		$output_popup .= &rc::io::view_patient(\%p);
	}
} elsif ($p{'do'} eq "add_lab_form" and $ok) {
	$output_popup .= &rc::io::view_lab(\%p);
} elsif ($p{'do'} eq "add_lab_save" and $ok) {
	&check_lab_input("add");
	if ($p{'message_error'} ne '') {
		$output_popup .= &rc::io::view_lab(\%p);
	} else {
		my @rc_labs_columns = ("type", "status", "pathogen_1", "pathogen_2", "pathogen_3", "pathogen_4", "comments", "ordered");
		my $rc_labs_column_names = '';
		my $rc_labs_column_values = '';
		$p{"form_labs_result_pre"} = "0";
		$p{"form_labs_result_final"} = "0";
		my @pathogen_columns = (1..4);
		foreach my $col (@pathogen_columns) {
			if ($p{"form_labs_pathogen_$col"} eq "Final: Other") {
				$p{"form_labs_pathogen_$col"} = $p{"form_labs_pathogen_$col\_other"};
			}
		}
		foreach my $column (@rc_labs_columns) {
			$rc_labs_column_names .= qq{$column, };
			$rc_labs_column_values .= qq{"$p{"form_labs_$column"}", };
			if ($column =~ /pathogen_/) {
				if ($p{"form_labs_$column"} =~ /Preliminary/) {
					$p{"form_labs_result_pre"} = '1';
				} elsif ($p{"form_labs_$column"} =~ /Final/) {
					$p{"form_labs_result_final"} = '1';
				}
			}
		}
		my @columns = ("type", "status", "pathogen_1", "pathogen_2", "pathogen_3", "pathogen_4", "comments", "ordered", "result_pre", "result_final");
		foreach my $column (@columns) {
			$p{"form_labs_$column"} = &rc::io::or_null($p{"form_labs_$column"});
		}
		my $id = &rc::io::input(qq{INSERT INTO rc_labs (case_id, $rc_labs_column_names result_pre, result_final, modified) VALUES ("$p{'case_id'}", $rc_labs_column_values $p{'form_labs_result_pre'}, $p{'form_labs_result_final'}, CURRENT_TIMESTAMP())});
		if ($id ne '') {
			&rc::io::get_next_step($p{"case_id"});
			&rc::io::track("labs", $id);
			&rc::io::cache_rebuild_patient($p{"patient_id"});
			if ($p{"form_labs_result_final"} eq '1') {
				&rc::io::generate_alert_210_final_results_arrived($id);
			} elsif ($p{"form_labs_result_pre"} eq '1') {
				&rc::io::generate_alert_200_prelim_results_arrived($id);
			}
			$p{"case_id"} = &rc::io::fast(qq{SELECT case_id FROM rc_labs WHERE entry="$id"});
			$p{'do'} = "edit_case_form";
			$p{"do_reload"} = "add_lab_save";
			$output_popup .= &rc::io::view_case(\%p);
		}
	}
} elsif (($p{'do'} eq "edit_lab_form") and $ok) {
	$output_popup .= &rc::io::view_lab(\%p);
} elsif (($p{'do'} eq "edit_lab_save") and ($p{"lab_id"} ne '') and $ok) {
	&check_lab_input("edit");
	if ($p{'message_error'} ne '') {
		$output_popup .= &rc::io::view_lab(\%p);
	} else {
		my @rc_labs_columns = ("type", "status", "pathogen_1", "pathogen_2", "pathogen_3", "pathogen_4", "comments", "ordered");
		my $rc_labs_query = '';
		$p{"form_labs_result_pre"} = "0";
		$p{"form_labs_result_final"} = "0";
		my @pathogen_columns = (1..4);
		foreach my $col (@pathogen_columns) {
			if ($p{"form_labs_pathogen_$col"} eq "Final: Other") {
				$p{"form_labs_pathogen_$col"} = $p{"form_labs_pathogen_$col\_other"};
			}
		}
		foreach my $column (@rc_labs_columns) {
			$p{"form_labs_$column"} = &rc::io::or_null($p{"form_labs_$column"});
			$rc_labs_query .= qq{$column=$p{"form_labs_$column"}, };
			if ($column =~ /pathogen_/) {
				if ($p{"form_labs_$column"} =~ /Preliminary/) {
					$p{"form_labs_result_pre"} = '1';
				} elsif ($p{"form_labs_$column"} =~ /Final/) {
					$p{"form_labs_result_final"} = '1';
				}
			}
		}
		if ($p{"form_labs_result_final"} eq '1') {
			&rc::io::generate_alert_210_final_results_arrived($p{'lab_id'});
		} elsif ($p{"form_labs_result_pre"} eq '1') {
			&rc::io::generate_alert_200_prelim_results_arrived($p{'lab_id'});
		}
		&rc::io::input(qq{UPDATE rc_labs SET $rc_labs_query result_pre="$p{"form_labs_result_pre"}", result_final="$p{"form_labs_result_final"}", modified=CURRENT_TIMESTAMP() WHERE entry="$p{"lab_id"}"});
		&rc::io::get_next_step($p{"case_id"});
		&rc::io::track("labs", $p{"lab_id"});
		$p{'do'} = "edit_case_form";
		$p{"do_reload"} = "edit_lab_save";
		$output_popup .= &rc::io::view_case(\%p);
	}
} elsif ($p{'do'} eq "add_antibiotic_form" and $ok) {
	$output_popup .= &rc::io::view_antibiotic(\%p);
} elsif ($p{'do'} eq "add_antibiotic_save" and $ok) {
	&check_antibiotic_input("add");
	if ($p{'message_error'} eq '') {
		my @rc_abx_columns = ("antibiotic", "basis_empiric", "basis_final", "route", "dose_amount_loading", "dose_amount", "dose_amount_units", "dose_frequency", "regimen_duration", "date_start", "date_end", "date_stopped", "comments");
		my $rc_abx_column_names = '';
		my $rc_abx_column_values = '';
		$p{"form_abx_date_end"} = &rc::io::fast(qq{SELECT ADDDATE('$p{"form_abx_date_start"}', INTERVAL $p{"form_abx_regimen_duration"} DAY)});
		if ($p{"form_abx_date_stopped"} eq '') {
			$p{"form_abx_date_stopped"} = $p{"form_abx_date_end"};
		}
		if (($p{"form_abx_antibiotic"} eq "Other") and ($p{"form_abx_antibiotic_other"} ne '')) {
			$p{"form_abx_antibiotic"} = $p{"form_abx_antibiotic_other"};
		}
		foreach my $column (@rc_abx_columns) {
			$rc_abx_column_names .= qq{$column, };
			$p{"form_abx_$column"} = &rc::io::or_null($p{"form_abx_$column"});
			$rc_abx_column_values .= qq{$p{"form_abx_$column"}, };
		}
		my $id = &rc::io::input(qq{INSERT INTO rc_antibiotics (case_id, $rc_abx_column_names created, modified) VALUES ("$p{"case_id"}", $rc_abx_column_values CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP())});
		if ($id ne '') {
			&rc::io::get_next_step($p{"case_id"});
			&rc::io::track("antibiotics", $id);
			$p{'do'} = "edit_case_form";
			$p{"do_reload"} = "add_antibiotic_save";
			$output_popup .= &rc::io::view_case(\%p);
		} else {
			$p{'message_error'} = qq{<span class="b">This antibiotic treatment cannot be added.</span> Please ensure that all required fields are completed correctly and try again.};
		}
	}
	if ($p{'message_error'} ne '') {
		$output_popup .= &rc::io::view_antibiotic(\%p);
	}
} elsif (($p{'do'} eq "edit_antibiotic_form") and $ok) {
	$output_popup .= &rc::io::view_antibiotic(\%p);
} elsif ($p{'do'} eq "edit_antibiotic_save" and $ok) {
	&check_antibiotic_input("edit");
	if ($p{'message_error'} eq '') {
		$p{"form_abx_date_end"} = &rc::io::fast(qq{SELECT ADDDATE('$p{"form_abx_date_start"}', INTERVAL $p{"form_abx_regimen_duration"} DAY)});
		if ($p{"form_abx_date_stopped"} eq '') {
			$p{"form_abx_date_stopped"} = $p{"form_abx_date_end"};
		}
		my @columns = ("antibiotic", "basis_empiric", "basis_final", "route", "dose_amount_loading", "dose_amount", "dose_amount_units", "dose_frequency", "regimen_duration", "date_start", "date_end", "date_stopped", "comments");
		if (($p{"form_abx_antibiotic"} eq "Other") and ($p{"form_abx_antibiotic_other"} ne '')) {
			$p{"form_abx_antibiotic"} = $p{"form_abx_antibiotic_other"};
		}
		foreach my $column (@columns) {
			$p{"form_abx_$column"} = &rc::io::or_null($p{"form_abx_$column"});
		}
		my $id = &rc::io::input(qq{UPDATE rc_antibiotics SET antibiotic=$p{"form_abx_antibiotic"}, basis_empiric=$p{"form_abx_basis_empiric"}, basis_final=$p{"form_abx_basis_final"}, route=$p{"form_abx_route"}, dose_amount_loading=$p{"form_abx_dose_amount_loading"}, dose_amount=$p{"form_abx_dose_amount"}, dose_amount_units=$p{"form_abx_dose_amount_units"}, dose_frequency=$p{"form_abx_dose_frequency"}, regimen_duration=$p{"form_abx_regimen_duration"}, date_start=$p{"form_abx_date_start"}, date_end=$p{"form_abx_date_end"}, date_stopped=$p{"form_abx_date_stopped"}, comments=$p{"form_abx_comments"}, modified=CURRENT_TIMESTAMP() WHERE entry="$p{"abx_id"}"});
		$p{"case_id"} = &rc::io::fast(qq{SELECT case_id FROM rc_antibiotics WHERE entry="$p{"abx_id"}"});
		&rc::io::get_next_step($p{"case_id"});
		&rc::io::track("antibiotics", $p{"abx_id"});
		$p{'do'} = "edit_case_form";
		$p{"do_reload"} = "edit_antibiotic_save";
		$output_popup .= &rc::io::view_case(\%p);
	} else {
		$output_popup .= &rc::io::view_antibiotic(\%p);
	}
} elsif (($p{'do'} eq "edit_antibiotic_stop_save") and ($p{"abx_id"} ne '') and $ok) {
	$p{"abx_id"} = &rc::io::fast(qq{SELECT entry FROM rc_antibiotics WHERE entry="$p{"abx_id"}" LIMIT 1});
	if ($p{"abx_id"} ne '') {
		my $id = &rc::io::input(qq{UPDATE rc_antibiotics SET date_stopped=CURDATE() WHERE entry="$p{'abx_id'}"});
		$p{"case_id"} = &rc::io::fast(qq{SELECT case_id FROM rc_antibiotics WHERE entry="$p{"abx_id"}"});
		&rc::io::get_next_step($p{"case_id"});
		&rc::io::track("antibiotics", $p{"abx_id"});
		$p{'do'} = "edit_case_form";
		$p{"do_reload"} = "edit_antibiotic_stop_save";
		$output_popup .= &rc::io::view_case(\%p);
	}
} elsif ($p{'do'} eq "enter_lab_test_results" and $ok) {
		$output_popup .= &rc::io::enter_lab_test_results(\%p);
} elsif ($p{'do'} eq "edit_account_settings_form" and $ok) {
	$output_popup .= &rc::io::view_account_settings(\%p);
} elsif ($p{'do'} eq "edit_account_settings_save_user_info" and $ok) {
	my $executing_user = &rc::io::fast(qq{SELECT type FROM rc_users WHERE entry="$sid[2]"});
	if (
		($p{'uid'} eq '') or 
		($p{'uid'} =~ /\D/) or 
		($p{"form_users_name_first"} eq '') or 
		($p{"form_users_name_last"} eq '') or 
		($p{"form_users_email"} eq '') or 
		($p{"form_users_role"} eq '' and $executing_user eq "Administrator") or
		($executing_user ne "Administrator" and $sid[2] ne $p{'uid'})) {
		$p{'message_error'} = qq{<span class="b">User information cannot be saved.</span> Please complete all required fields and try again. uid is $p{'uid'}, form_users_name_first is $p{"form_users_name_first"}, form_users_name_last is $p{"form_users_name_last"}, form_users_email is $p{"form_users_email"}, form_users_role is $p{"form_users_role"}};
	}
	if ($p{'message_error'} eq '') {
		$p{'form_users_email'} =~ s/ //g;
		my $form_users_role_update = '';
		if ($p{'form_users_role'} ne '') {
			$form_users_role_update = qq{role="$p{'form_users_role'}",};
		}
		&rc::io::input(qq{UPDATE rc_users SET name_first="$p{"form_users_name_first"}", name_last="$p{"form_users_name_last"}", email="$p{"form_users_email"}", $form_users_role_update opt_in="$p{"form_users_opt_in"}", modified=CURRENT_TIMESTAMP() WHERE entry="$p{'uid'}"});
		&rc::io::track("users", $sid[2]);
		my @patient_ids = &rc::io::query(qq{SELECT entry FROM rc_patients WHERE primary_nurse="$sid[2]" OR nephrologist="$sid[2]"});
		foreach my $patient_id (@patient_ids) {
			&rc::io::cache_rebuild_patient($patient_id);
		}
		$p{'message_success'} = qq{<span class="b">User information saved.</span>};
	}
	$output_popup .= &rc::io::view_account_settings(\%p);
} elsif ($p{'do'} eq "edit_account_settings_save_password" and $ok) {
	my $chk_password = &rc::io::fast(qq{SELECT password FROM rc_users WHERE entry="$sid[2]"});
	my $old_password = &rc::io::encrypt($p{"form_users_password_old"});
	my $new_password = $p{"form_users_password"};
	my $rep_password = $p{"form_users_password_repeat"};
	if ($new_password eq '') {
		$p{'message_error'} = qq{<span class="b">Your password cannot be updated.</span> Please ensure that you have entered a new password and try again.};
	} elsif ($chk_password ne $old_password) {
		$p{'message_error'} = qq{<span class="b">Your password cannot be updated because your existing password does not match with the password we have on file.</span> Please ensure that you have entered the correct case sensitive existing password and try again.};
		&rc::io::record_login($sid[2],"password change failed");
	} elsif (length($new_password) < 8) {
		$p{'message_error'} = qq{<span class="b">Your password cannot be updated because your new password is too short.</span> Please ensure that your new password is at least 8 characters in length and try again.};
	}  elsif ($new_password ne $rep_password) {
		$p{'message_error'} = qq{<span class="b">Your password cannot be updated because your new passwords do not match.</span> Please ensure that you have re-entered the same new password twice and try again.};
	}
	if ($p{'message_error'} eq '') {
		$new_password = &rc::io::encrypt($new_password);
		&rc::io::input(qq{UPDATE rc_users SET password="$new_password" WHERE entry="$sid[2]"});
		&rc::io::track("users", $sid[2]);
		&rc::io::record_login($sid[2],"password change successful");
		$p{'message_success'} = qq{<span class="b">Your password has been updated.</span>};
	}
	$output_popup .= &rc::io::view_account_settings(\%p);
} elsif ($p{'do'} eq "edit_manage_users_form" and $ok) {
	$output_popup .= &rc::io::view_manage_users(\%p);
} elsif ($p{'do'} eq "delete_case_confirm" and $ok) {
	$p{"case_id"} = &rc::io::fast(qq{SELECT entry FROM rc_cases WHERE entry="$p{"case_id"}"});
	if ($p{"case_id"} ne '') {
		$output_popup .= qq{
			$close_button
			<div class="emp">
				<span class="b">Are you sure you want to delete this case?</span> 
				Cases should not be deleted unless they were created in error. All 
				culture results, alerts, and antibiotic treatment information 
				related to this case will also be deleted. This action cannot be 
				undone, however, a record of this case will still be kept in the 
				archive for auditing purposes. If you are unsure, please contact 
				your group leader before proceeding.
				<div class="p10to">
					<a href="ajax.pl?token=$token&do=delete_case_commit_save&case_id=$p{"case_id"}" target="hbin">Yes, delete</a> &nbsp; &nbsp; 
					<a href="ajax.pl?token=$token&do=edit_case_form&case_id=$p{"case_id"}" target="hbin" class="b">No, do not delete this case</a>
				</div>
			</div>};
	}
} elsif ($p{'do'} eq "delete_case_commit_save" and $ok) {
	$p{"case_id"} = &rc::io::fast(qq{SELECT entry FROM rc_cases WHERE entry="$p{'case_id'}"});
	if ($p{"case_id"} ne '') {
		my $patient_id = &rc::io::fast(qq{SELECT patient FROM rc_cases WHERE entry="$p{'case_id'}"});
		&rc::io::cache_rebuild_patient($patient_id);
		my @lab_ids = &rc::io::query(qq{SELECT entry FROM rc_labs WHERE case_id="$p{"case_id"}"});
		my @abx_ids = &rc::io::query(qq{SELECT entry FROM rc_antibiotics WHERE case_id="$p{"case_id"}"});
		foreach my $lab_id (@lab_ids) {
			&rc::io::track("labs", $lab_id);
		}
		foreach my $abx_id (@abx_ids) {
			&rc::io::track("antibiotics", $abx_id);
		}
		&rc::io::track("cases", $p{"case_id"});
		&rc::io::input(qq{DELETE FROM rc_hide WHERE record_id="$p{'case_id'}" AND record_type="case"});
		&rc::io::input(qq{DELETE FROM rc_labs WHERE case_id="$p{"case_id"}"});
		&rc::io::input(qq{DELETE FROM rc_alerts WHERE cid="$p{"case_id"}"});
		&rc::io::input(qq{DELETE FROM rc_alerts_archive WHERE cid="$p{"case_id"}"});
		&rc::io::input(qq{DELETE FROM rc_antibiotics WHERE case_id="$p{"case_id"}"});
		&rc::io::input(qq{DELETE FROM rc_cases WHERE entry="$p{"case_id"}"});
		$output_popup .= qq{
			$close_button
			<div class="suc">
				<span class="b">This case has been deleted.</span>
				<div class="p10to">
					<a href="$local_settings{"path_htdocs"}/images/blank.gif" target="hbin" class="b" onclick="pop_up_hide();">Close this box</a>
				</div>
			</div>};
	}
} elsif ($p{'do'} eq "delete_catheter_confirm" and $ok) {
	$p{"catheter_id"} = &rc::io::fast(qq{SELECT entry FROM rc_catheters WHERE entry="$p{"catheter_id"}"});
	if ($p{"catheter_id"} ne '') {
		$output_popup .= qq{
			$close_button
			<div class="emp">
				<span class="b">Are you sure you want to delete this catheter information?</span> 
				Catheter information must not be deleted unless they were created in error. This 
				action cannot be undone. However, a record of this catheter information will 
				still be kept in the archive for auditing purposes. If you are unsure, please 
				contact your group leader before proceeding.
				<div class="p10to">
					<a href="ajax.pl?token=$token&do=delete_catheter_commit_save&catheter_id=$p{"catheter_id"}" target="hbin">Yes, delete</a> &nbsp; &nbsp; 
					<a href="ajax.pl?token=$token&do=edit_catheter_form&catheter_id=$p{"catheter_id"}" target="hbin" class="b">No, do not delete this catheter</a>
				</div>
			</div>};
	}
} elsif ($p{'do'} eq "delete_catheter_commit_save" and $ok) {
	$p{"lab_id"} = &rc::io::fast(qq{SELECT entry FROM rc_catheters WHERE entry="$p{"catheter_id"}"});
	if ($p{"catheter_id"} ne '') {
		&rc::io::track("catheters", $p{"catheter_id"});
		&rc::io::input(qq{DELETE FROM rc_catheters WHERE entry="$p{"catheter_id"}"});
		$output_popup .= qq{
			$close_button
			<div class="suc">
				<span class="b">This catheter information has been deleted.</span>
				<div class="p10to"><a href="$local_settings{"path_htdocs"}/images/blank.gif" target="hbin" class="b" onclick="pop_up_hide();">Close this box</a></div>
			</div>};
	}
} elsif ($p{'do'} eq "delete_dialysis_confirm" and $ok) {
	$p{"dialysis_id"} = &rc::io::fast(qq{SELECT entry FROM rc_dialysis WHERE entry="$p{"dialysis_id"}"});
	if ($p{"dialysis_id"} ne '') {
		$output_popup .= qq{
			$close_button
			<div class="emp"><span class="b">Are you sure you want to delete this dialysis information?</span> Dialysis information must not be deleted unless they were created in error. This action cannot be undone. However, a record of this dialysis information will still be kept in the archive for auditing purposes. If you are unsure, please contact your group leader before proceeding.
				<div class="p10to"><a href="ajax.pl?token=$token&do=delete_dialysis_commit_save&dialysis_id=$p{"dialysis_id"}" target="hbin">Yes, delete</a> &nbsp; &nbsp; <a href="ajax.pl?token=$token&do=edit_dialysis_form&dialysis_id=$p{"dialysis_id"}" target="hbin" class="b">No, do not delete this dialysis</a></div>
			</div>};
	}
} elsif ($p{'do'} eq "delete_dialysis_commit_save" and $ok) {
	$p{"lab_id"} = &rc::io::fast(qq{SELECT entry FROM rc_dialysis WHERE entry="$p{"dialysis_id"}"});
	if ($p{"dialysis_id"} ne '') {
		&rc::io::track("dialysis", $p{"dialysis_id"});
		&rc::io::input(qq{DELETE FROM rc_dialysis WHERE entry="$p{"dialysis_id"}"});
		$output_popup .= qq{
			$close_button
			<div class="suc">
				<span class="b">This dialysis information has been deleted.</span>
				<div class="p10to"><a href="$local_settings{"path_htdocs"}/images/blank.gif" target="hbin" class="b" onclick="pop_up_hide();">Close this box</a></div>
			</div>};
	}
} elsif ($p{'do'} eq "delete_lab_confirm" and $ok) {
	$p{"lab_id"} = &rc::io::fast(qq{SELECT entry FROM rc_labs WHERE entry="$p{"lab_id"}"});
	if ($p{"lab_id"} ne '') {
		$output_popup .= qq{
			$close_button
			<div class="emp"><span class="b">Are you sure you want to delete this culture result?</span> Culture results must not be deleted unless they were created in error. This action cannot be undone. However, a record of this culture result will still be kept in the archive for auditing purposes. If you are unsure, please contact your group leader before proceeding.
				<div class="p10to"><a href="ajax.pl?token=$token&do=delete_lab_commit_save&lab_id=$p{"lab_id"}" target="hbin">Yes, delete</a> &nbsp; &nbsp; <a href="ajax.pl?token=$token&do=edit_lab_form&lab_id=$p{"lab_id"}" target="hbin" class="b">No, do not delete this culture result</a></div>
			</div>};
	}
} elsif ($p{'do'} eq "delete_lab_commit_save" and $ok) {
	$p{"lab_id"} = &rc::io::fast(qq{SELECT entry FROM rc_labs WHERE entry="$p{"lab_id"}"});
	if ($p{"lab_id"} ne '') {
		&rc::io::track("labs", $p{"lab_id"});
		&rc::io::input(qq{DELETE FROM rc_labs WHERE entry="$p{"lab_id"}"});
		&rc::io::input(qq{DELETE FROM rc_alerts WHERE lid="$p{"lab_id"}"});
		$output_popup .= qq{
			$close_button
			<div class="suc">
				<span class="b">This culture result has been deleted.</span>
				<div class="p10to"><a href="$local_settings{"path_htdocs"}/images/blank.gif" target="hbin" class="b" onclick="pop_up_hide();">Close this box</a></div>
			</div>};
	}
} elsif ($p{'do'} eq "delete_abx_confirm" and $ok) {
	$p{"abx_id"} = &rc::io::fast(qq{SELECT entry FROM rc_antibiotics WHERE entry="$p{"abx_id"}"});
	if ($p{"abx_id"} ne '') {
		$output_popup .= qq{
			$close_button
			<div class="emp"><span class="b">Are you sure you want to delete this antibiotic treatment?</span> Antibiotic treatments must not be deleted unless they were created in error. This action cannot be undone. However, a record of this antibiotic treatment will still be kept in the archive for auditing purposes. If you are unsure, please contact your group leader before proceeding.
				<div class="p10to"><a href="ajax.pl?token=$token&do=delete_abx_commit_save&abx_id=$p{"abx_id"}" target="hbin">Yes, delete</a> &nbsp; &nbsp; <a href="ajax.pl?token=$token&do=edit_antibiotic_form&abx_id=$p{"abx_id"}" target="hbin" class="b">No, do not delete this antibiotic treatment</a></div>
			</div>};
	}
} elsif ($p{'do'} eq "delete_abx_commit_save" and $ok) {
	$p{"abx_id"} = &rc::io::fast(qq{SELECT entry FROM rc_antibiotics WHERE entry="$p{"abx_id"}"});
	if ($p{"abx_id"} ne '') {
		&rc::io::track("antibiotics", $p{"abx_id"});
		&rc::io::input(qq{DELETE FROM rc_antibiotics WHERE entry="$p{"abx_id"}"});
		&rc::io::input(qq{DELETE FROM rc_alerts WHERE tid="$p{"abx_id"}"});
		$output_popup .= qq{
			$close_button
			<div class="suc">
				<span class="b">This antibiotic treatment has been deleted.</span>
				<div class="p10to"><a href="$local_settings{"path_htdocs"}/images/blank.gif" target="hbin" class="b" onclick="pop_up_hide();">Close this box</a></div>
			</div>};
	}
}


# ===============
# OTHER FUNCTIONS
# ===============

sub check_patient_input() {
	if (($p{"form_patients_name_first"} eq '') or ($p{"form_patients_name_last"} eq '') or ($p{"form_patients_phn"} eq '') or ($p{"form_patients_primary_nurse"} eq '') or ($p{"form_patients_nephrologist"} eq '')) {
		$p{'message_error'} = qq{<span class="b">This patient's information cannot be saved.</span> Please ensure that all required fields (name, PHN, primary nurse and nephrologist) are completed correctly and try again.};
	} elsif (&rc::io::fast(qq{SELECT entry FROM rc_patients WHERE phn="$p{"form_patients_phn"}" AND entry<>"$p{"patient_id"}" LIMIT 1}) > 0) {
		$p{'message_error'} = qq{<span class="b">This patient's information could not be saved because another patient with the same PHN number ($p{"form_patients_phn"}) already exists in the database.</span>};
	} elsif (&rc::io::is_date_valid($p{"form_patients_date_of_birth"}) eq '' and $p{"form_patients_date_of_birth"} ne '') {
		$p{'message_error'} = qq{<span class="b">This patient's information cannot be saved because the patient's date of birth appears to be invalid.</span> Please ensure that the date of birth is entered correctly in the format of YYYY-MM-DD and try again.};
	} elsif (&rc::io::is_date_valid($p{"form_patients_pd_start_date"}) eq '' and $p{"form_patients_pd_start_date"} ne '') {
		$p{'message_error'} = qq{<span class="b">This patient's information cannot be saved because the patient's PD start date appears to be invalid.</span> Please ensure that the date is entered correctly in the format of YYYY-MM-DD and try again.};
	} elsif (&rc::io::is_date_valid($p{"form_patients_pd_stop_date"}) eq '' and $p{"form_patients_pd_stop_date"} ne '') {
		$p{'message_error'} = qq{<span class="b">This patient's information cannot be saved because the patient's PD stop date appears to be invalid.</span> Please ensure that the date is entered correctly in the format of YYYY-MM-DD and try again.};
	} elsif ($p{"form_patients_pd_start_date"} ne '' and $p{"form_patients_pd_stop_date"} ne '' and &rc::io::fast(qq{SELECT DATEDIFF('$p{"form_patients_pd_stop_date"}', '$p{"form_patients_pd_start_date"}')}) < 0) {
		$p{'message_error'} = qq{<span class="b">This patient's information cannot be saved because the patient's PD start date occurs after the stop date.</span> Please ensure that the start date occurs before the stop date and try again.};
	}
}
sub check_case_input() {
	my $job_type = shift;
	if ($job_type eq "add") {
		$p{"patient_id"} = &rc::io::fast(qq{SELECT entry FROM rc_patients WHERE entry="$p{"patient_id"}" LIMIT 1});
		if ($p{"patient_id"} eq '') {
			$p{'message_error'} = qq{<span class="b">This case cannot be saved.</span> Please close this window and try again.};
		}
	} elsif ($job_type eq "edit") {
		$p{"case_id"} = &rc::io::fast(qq{SELECT entry FROM rc_cases WHERE entry="$p{"case_id"}"});
		$p{"patient_id"} = &rc::io::fast(qq{SELECT patient FROM rc_cases WHERE entry="$p{"case_id"}"});
		if ($p{"case_id"} eq '' or $p{"patient_id"} eq '') {
			$p{'message_error'} = qq{<span class="b">This case cannot be saved.</span> Please close this window and try again.};
		} elsif (&rc::io::is_date_valid($p{"form_case_created"}) eq '') {
			$p{'message_error'} = qq{<span class="b">This case cannot be saved because the presentation date appears to be invalid.</span> Please provide a valid presentation date in the format of YYYY-MM-DD and try again.};
		}
	}
	if ($p{"form_case_hospitalization_start_date"} ne '') {
		if (&rc::io::is_date_valid($p{"form_case_hospitalization_start_date"}) eq '') {
			$p{'message_error'} = qq{<span class="b">This case cannot be saved because the hospitalization start date appears to be invalid.</span> Please provide a valid start date in the format of YYYY-MM-DD and try again.};
		}
	} elsif ($p{"form_case_hospitalization_stop_date"} ne '') {
		if (&rc::io::is_date_valid($p{"form_case_hospitalization_stop_date"}) eq '') {
			$p{'message_error'} = qq{<span class="b">This case cannot be saved because the hospitalization end date appears to be invalid.</span> Please provide a valid end date in the format of YYYY-MM-DD and try again.};
		}
	} elsif ($p{"form_case_hospitalization_start_date"} ne '' and $p{"form_case_hospitalization_stop_date"} ne '') {
		if (&rc::io::fast(qq{SELECT DATEDIFF("$p{'form_case_hospitalization_stop_date'}","$p{'form_case_hospitalization_start_date'}");}) < 1) {
			$p{'message_error'} = qq{<span class="b">This case cannot be saved because the hospitalization end date is earlier than the start date.</span> Please provide a valid start and end date in the format of YYYY-MM-DD and try again.};
		}
	}
}
sub check_antibiotic_input() {
	my $antibiotic_job_type = shift;
	if ($antibiotic_job_type = "add") {
		$p{"case_id"} = &rc::io::fast(qq{SELECT entry FROM rc_cases WHERE entry="$p{"case_id"}" LIMIT 1});
		if ($p{"case_id"} eq '') {
			$p{'message_error'} = qq{<span class="b">This antibiotic treatment cannot be saved.</span> Please close this window and try again.};
		}
	} elsif ($antibiotic_job_type = "edit") {
		$p{"abx_id"} = &rc::io::fast(qq{SELECT entry FROM rc_antibiotics WHERE entry="$p{"abx_id"}" LIMIT 1});
		if ($p{"abx_id"} eq '') {
			$p{'message_error'} = qq{<span class="b">This antibiotic treatment cannot be saved.</span> Please close this window and try again.};
		}
	}
	if ($p{'message_error'} eq '') {
		if (&rc::io::is_date_valid($p{"form_abx_date_start"}) eq '') {
			$p{'message_error'} = qq{<span class="b">This antibiotic treatment cannot be saved because the start date appears to be invalid.</span> Please provide a valid start date in the format of YYYY-MM-DD and try again.};
		} elsif ($p{"form_abx_date_stopped"} ne '' and &rc::io::is_date_valid($p{"form_abx_date_stopped"}) eq '') {
			$p{'message_error'} = qq{<span class="b">This antibiotic treatment cannot be saved because the cancellation (premature stop) date appears to be invalid.</span> Please provide a valid premature stop date in the format of YYYY-MM-DD and try again.};
		} elsif ($p{"form_abx_date_stopped"} ne '' and &rc::io::fast(qq{SELECT DATEDIFF('$p{"form_abx_date_stopped"}', '$p{"form_abx_date_start"}')}) < 0) {
			$p{'message_error'} = qq{<span class="b">This antibiotic treatment cannot be saved because the cancellation (premature stop) date occurs before the start date.</span> Please provide a valid premature stop date and try again.};
		}
	}
}
sub check_catheter_input() {
	my $catheter_job_type = shift;
	if ($catheter_job_type eq "add") {
		$p{"patient_id"} = &rc::io::fast(qq{SELECT entry FROM rc_patients WHERE entry="$p{"patient_id"}" LIMIT 1});
		if ($p{"patient_id"} eq '') {
			$p{'message_error'} = qq{<span class="b">This catheter information cannot be saved.</span> Please close this window and try again.};
		}
	} elsif ($catheter_job_type eq "edit") {
		($p{"catheter_id"}, $p{"patient_id"}) = &rc::io::query(qq{SELECT entry, patient_id FROM rc_catheters WHERE entry="$p{"catheter_id"}" LIMIT 1});
		if ($p{"catheter_id"} eq '') {
			$p{'message_error'} = qq{<span class="b">This catheter information cannot be saved.</span> Please close this window and try again.};
		}
	}
    if ($p{'message_error'} eq '') {
    	if (&rc::io::is_date_valid($p{"form_catheter_insertion_date"}) eq '') {
			$p{'message_error'} = qq{<span class="b">This catheter information cannot be saved because the insertion date appears to be invalid.</span> Please provide a valid insertion date in the format of YYYY-MM-DD and try again.};
    	} elsif ($p{"form_catheter_removal_date"} ne '') {
			if (&rc::io::is_date_valid($p{"form_catheter_removal_date"}) eq '') {
				$p{'message_error'} = qq{<span class="b">This catheter information cannot be saved because the removal date appears to be invalid.</span> Please provide a valid removal date in the format of YYYY-MM-DD and try again.};
			} elsif (&rc::io::fast(qq{SELECT DATEDIFF("$p{'form_catheter_removal_date'}","$p{'form_catheter_insertion_date'}");}) < 1) {
				$p{'message_error'} = qq{<span class="b">This catheter information cannot be saved because the removal date is earlier than the insertion date.</span> Please provide a valid insertion and removal date in the format of YYYY-MM-DD and try again.};
			}
		}
	}
}
sub check_dialysis_input() {
	my $dialysis_job_type = shift;
	if ($dialysis_job_type eq "add") {
		$p{"patient_id"} = &rc::io::fast(qq{SELECT entry FROM rc_patients WHERE entry="$p{"patient_id"}" LIMIT 1});
		if ($p{"patient_id"} eq '') {
			$p{'message_error'} = qq{<span class="b">This dialysis information cannot be saved.</span> Please close this window and try again.};
		}
	} elsif ($dialysis_job_type eq "edit") {
		($p{"dialysis_id"}, $p{"patient_id"}) = &rc::io::query(qq{SELECT entry, patient_id FROM rc_dialysis WHERE entry="$p{"dialysis_id"}" LIMIT 1});
		if ($p{"dialysis_id"} eq '') {
			$p{'message_error'} = qq{<span class="b">This dialysis information cannot be saved.</span> Please close this window and try again.};
		}
	}
    if ($p{'message_error'} eq '') {
    	if (&rc::io::is_date_valid($p{"form_dialysis_start_date"}) eq '') {
			$p{'message_error'} = qq{<span class="b">This dialysis information cannot be saved because the start date appears to be invalid.</span> Please provide a valid start date in the format of YYYY-MM-DD and try again.};
    	} elsif ($p{"form_dialysis_stop_date"} ne '') {
			if (&rc::io::is_date_valid($p{"form_dialysis_stop_date"}) eq '') {
				$p{'message_error'} = qq{<span class="b">This dialysis information cannot be saved because the stop date appears to be invalid.</span> Please provide a valid stop date in the format of YYYY-MM-DD and try again.};
			} elsif (&rc::io::fast(qq{SELECT DATEDIFF("$p{'form_dialysis_stop_date'}","$p{'form_dialysis_start_date'}");}) < 1) {
				$p{'message_error'} = qq{<span class="b">This dialysis information cannot be saved because the stop date is earlier than the start date.</span> Please provide a valid start and stop date in the format of YYYY-MM-DD and try again.};
			}
		}
	}
}
sub check_lab_input() {
	my $lab_job_type = shift;
	if ($lab_job_type eq "add") {
		($p{"case_id"}, $p{"patient_id"}) = &rc::io::query(qq{SELECT entry, patient FROM rc_cases WHERE entry="$p{"case_id"}" LIMIT 1});
		if ($p{"case_id"} eq '') {
			$p{'message_error'} = qq{<span class="b">This culture cannot be saved.</span> Please close this window and try again.};
		}
	} elsif ($lab_job_type eq "edit") {
		($p{"lab_id"}, $p{"case_id"}) = &rc::io::query(qq{SELECT entry, case_id FROM rc_labs WHERE entry="$p{"lab_id"}" LIMIT 1});
		if ($p{"lab_id"} eq '') {
			$p{'message_error'} = qq{<span class="b">This culture result cannot be saved.</span> Please close this window and try again.};
		}
	}
    if ($p{'message_error'} eq '') {
    	if ($p{"form_labs_ordered"} eq '') {
			$p{'message_error'} = qq{<span class="b">This culture result cannot be saved because no order date information is provided.</span> Please provide a valid order date in the format of YYYY-MM-DD and try again.};
    	} elsif (&rc::io::is_date_valid($p{"form_labs_ordered"}) eq '') {
			$p{'message_error'} = qq{<span class="b">This culture result cannot be saved because the order date appears to be invalid.</span> Please provide a valid order date in the format of YYYY-MM-DD and try again.};
    	}
    }
}





# ============
# PRINT OUTPUT
# ============

if ($output_main ne '') {
	$output_javascript = qq{ajax('div_main','send_to_main');};
} else {
	if ($output_page eq '') {
		$p{"patient_id"} = '';
		$p{'do'} = '';
		my $state = &rc::io::fast(qq{SELECT value FROM rc_state WHERE uid="$sid[2]" AND param="tab" LIMIT 1});
		if ($state eq "view_active_cases") {
			$output_page = &rc::io::view_active_cases(\%p);
		} elsif ($state eq "view_cases") {
			$output_page = &rc::io::view_cases(\%p);
		} elsif ($state eq "view_patients") {
			$output_page = &rc::io::view_patients(\%p);
		} elsif ($state eq "view_labs") {
			$output_page = &rc::io::view_labs(\%p);
		} elsif ($state eq "view_reports") {
			$output_page = &rc::io::view_reports(\%p);
		} elsif ($state eq "view_active_lists") {
			$output_page = &rc::io::view_active_lists(\%p);
		} elsif ($state eq "view_lists") {
			$output_page = &rc::io::view_lists(\%p);
		} elsif ($state eq "view_list_reports") {
			$output_page = &rc::io::view_list_reports(\%p);
		} else {
			$output_page = &rc::io::view_active_cases(\%p);
			&rc::io::input(qq{INSERT INTO rc_state (uid, param, value) VALUES ("$sid[2]", "tab", "view_active_cases") ON DUPLICATE KEY UPDATE value="view_active_cases"});
		}
	}
	$output_alerts = &rc::io::get_alerts(\%p);
	if ($output_page ne '') {
		$output_javascript .= qq{ajax('div_page','send_to_page');};
	}
	if ($output_popup ne '') {
		$output_javascript .= qq{ajax_pop_up('div_pop_up','send_to_popup');};
	}
	$output_javascript .= qq{ajax('alerts','send_to_alerts');};
}

unless ($sid[2] ne '') {
	$output_page = qq{};
	$output_popup = qq{};
	$output_alerts = qq{};
	$output_specialrequest = qq{};
}

print $q->header("text/html; charset=utf-8") . 
	&rc::io::header() . qq{
		<body>
			<div id="send_to_main">$output_main</div>
			<div id="send_to_page">$output_page</div>
			<div id="send_to_popup">$output_popup</div>
			<div id="send_to_alerts">$output_alerts</div>
			<img alt='' 
				src="$local_settings{"path_htdocs"}/images/blank.gif" 
				onload="$output_javascript"/>
			$output_specialrequest
		</body>
	</html>};