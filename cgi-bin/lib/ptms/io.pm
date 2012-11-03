package ptms::io;
use strict;

# LOCAL INSTALLATION SETTINGS
# EDIT THE SETTINGS HERE TO MATCH YOUR LOCAL INSTALLATION

my %local_settings = (
	"path_htdocs" => "", #IF THE WEBSITE IS INSTALLED IN ROOT, SHOULD BE ""
	"path_cgibin" => "/cgi-bin/", #EXAMPLE "/cgi-bin/"
	"encrypt_key" => "", #A 16-TO-256 STRING RANDOM KEY, ALPHANUMERIC, CANNOT BE CHANGED, EXAMPLE 8cImkXgs6gzlEHYaShAl
	"dbinfo_host" => "", #DATABASE HOST NAME OR IP ADDRESS, EXAMPLE "localhost"
	"dbinfo_user" => "", #DATABASE USER NAME, EXAMPLE "root"
	"dbinfo_pass" => "", #DATABASE USER PASSWORD, EXAMPLE "password_for_database"
	"dbinfo_name" => "", #DATABASE NAME, EXAMPLE "test" or "renalconnect"
	"http_domain" => "", #THE DOMAIN OR IP ADDRESS WHERE IT'S INSTALLED, EXAMPLE "renalconnect.com"
	"liblocation" => "", #COULD BE LEFT BLANK
	"email_sender_key" => "",  #A 16-TO-256 STRING RANDOM KEY, ALPHANUMERIC, FOR YOUR send.php
	"email_sender_from" => "", #THE EMAIL ADDRESS OF YOUR RENALCONNECT, EXAMPLE "do.not.reply@renalconnect.com"
	"email_sender_script" => "/send.php", #ABSOLUTE URL PATH TO send.php, EXAMPLE "/send.php"
	"email_support_to" => "", #EMAIL ADDRESS OF TECHNICAL SUPPORT PERSON
	"email_support_bcc" => "", #EMAIL ADDRESS FOR BCC COPY OF TECHNICAL SUPPORT REQUESTS
	"end_of_settings" => "");

sub get_local_settings() {
	return %local_settings;
}

# FOR SIMPLE INSTALLATIONS WITHOUT ANY SOFTWARE MODIFICATION
# YOU SHOULD NOT NEED TO EDIT ANY CODE BELOW THIS POINT

my $path_htdocs = $local_settings{"path_htdocs"};
my $path_cgibin = $local_settings{"path_cgibin"};
my $encrypt_key = $local_settings{"encrypt_key"};
my $dbinfo_host = $local_settings{"dbinfo_host"};
my $dbinfo_user = $local_settings{"dbinfo_user"};
my $dbinfo_pass = $local_settings{"dbinfo_pass"};
my $dbinfo_name = $local_settings{"dbinfo_name"};
my $http_domain = $local_settings{"http_domain"};

my @sid;
my $token;

my $required_io = qq{<span class="txt-red">&bull;</span>};
my $comment_icon = qq{<img src="$path_htdocs/images/icon-comment-small-blue.gif" alt="" align="absmiddle"/>};

# END DEFINE ENVIRONMENT VARIABLES

sub get_path_htdocs() {return $path_htdocs;}
sub get_http_domain() {return $http_domain;}

sub encrypt_key() {
	return $encrypt_key;
}

use lib $local_settings{"liblocation"};

use Crypt::Blowfish;
use CGI::Session;
use CGI;
use DBI;

CGI::Session->name("ptms");
my $q = new CGI;
sub get_q() {return $q;}

my $cipher = new Crypt::Blowfish $encrypt_key;
sub encrypt() {
	my $a = shift;
	my $encrypted;
	while (length $a > 0) {
		while (length $a < 8) {$a .= "\t";}
		my $b = $cipher->encrypt(substr($a,0,8));
		$encrypted .= $b; 
		if (length $a > 8) {$a = substr($a,8);} else {$a = "";}
	}
	my $unpacked = unpack("H*",$encrypted);
	return ($unpacked);
}
sub decrypt() {
	my $a = pack("H*",shift);
	my $decrypted;
	while (length $a > 0) {
		my $b = substr($a,0,8);
		if (length $b == 8) {
			my $c = $cipher->decrypt($b);
			$decrypted .= $c;
		} 
		if (length $a > 8) {
			$a = substr($a,8);
		} else {
			$a = "";
		}
	}
	$decrypted =~ s/\t+$//g;
	return ($decrypted);
}
sub get_db() {
	my $dbh = DBI->connect("dbi:mysql:" . $dbinfo_name . ':' . $dbinfo_host, $dbinfo_user, $dbinfo_pass);
	return $dbh;
}
sub dblog() {
	my $query = shift;
	open(LOG, ">>db.txt");
	print LOG $query . "\n";
	close(LOG);
}
my $dbh = &get_db();
sub fast() {
	my $query = shift;
#	&dblog($query);
	my $input = $dbh->prepare($query);
	$input->execute;
	my @output = $input->fetchrow_array;
	$input->finish();
	return $output[0];
}
sub query() {
	my $query = shift;
#	&dblog($query);
	my $input = $dbh->prepare($query);
	$input->execute;
	my @output;
	while (my @tmp = $input->fetchrow_array) {
		foreach my $row (@tmp) {
			@output = (@output,$row);
		}
	}
	$input->finish();
	return @output;
}
sub queryh() {
	my $query = shift;
#	&dblog($query);
	my $input = $dbh->prepare($query);
	$input->execute;
	my $hash = $input->fetchrow_hashref;
	my %hash;
	if (defined(%$hash)) { 
		%hash = %$hash;
	}
	return %hash;
}
sub querymr() {
	my $query = shift;
#	&dblog($query);
	my $input = $dbh->prepare($query);
	$input->execute;
	my @row;
	my @fields;
	while(@row = $input->fetchrow_array()) {
 		my @record = @row;
		push(@fields, \@record);
	}
	$input->finish();
	return @fields;
}
sub input() {
	my $query = shift;
#	&dblog($query);
	my $input = $dbh->prepare(qq{SET NAMES 'utf8'});
	$input->execute;
	$input = $dbh->prepare($query);
	$input->execute;
	$input = $dbh->prepare(qq{SELECT LAST_INSERT_ID()});
	$input->execute;
	my @output = $input->fetchrow_array;
	$input->finish();
	return $output[0];
}
&input(qq{SET NAMES 'utf8'});

# SOFTWARE FUNCTIONS

sub get_sid() {
	if ($sid[0] and !$_[0]) {
		return @sid;
	} else {
		my $sid = $q->cookie("ptms") || undef;
		if ($sid eq undef) {
			my $s = new CGI::Session("driver:MySQL", undef, {Handle=>$dbh});
			$sid = $s->id();
		}
		my $s = new CGI::Session("driver:MySQL", $sid, {Handle=>$dbh});
		my $uid = $s->param("uid");
		my $coo = $s->header();
		my $ipa = $q->remote_addr();
		$coo =~ s/ISO-8859-1/utf-8\n\n/g;
		@sid = ($coo,$sid,$uid,$ipa);
		$token = $sid;
		return @sid;
	}
}
@sid = &get_sid();
sub record_login() {
	my ($uid, $comment) = @_;
	if ($uid ne "" and $comment ne "") {
		my $hs_ip = $q->remote_addr();
		my $hs_client = $q->user_agent();
		&input(qq{INSERT INTO ptms__hs_login (hs_uid, hs_ip, hs_client, hs_action) VALUES ("$uid", "$hs_ip", "$hs_client", "$comment")});
	}
}
sub login() {
	my %p = %{$_[0]};
	my $mail = $p{"param_login_email"};
	my $pass = $p{"param_login_password"};
	$pass = &encrypt($pass);
	my $uid = &fast(qq{SELECT entry FROM ptms_users WHERE email="$mail" AND password="$pass" AND deactivated="0"});
	if ($uid ne "") {
		my $s = new CGI::Session("driver:MySQL", $sid[1], {Handle=>$dbh});
		$s->param("uid", $uid);
		my $coo = $s->header();
		my $ipa = $q->remote_addr();
		$coo =~ s/ISO-8859-1/utf-8\n\n/g;
		@sid = ($coo,$sid[1],$uid,$ipa);
		&record_login($uid,"login");
		return "";
	} else {
		my $uid = &fast(qq{SELECT entry FROM ptms_users WHERE email="$mail"});
		&record_login($uid,"password mismatch");
		return qq{<span class="b">You have provided an incorrect email or password.</span> Please try again.};
	}
}
sub logout() {
	&record_login($sid[2],"logout");
	my $sid = $q->cookie("ptms") || undef;
	my $s = new CGI::Session("driver:MySQL", $sid, {Handle=>$dbh});
	$s->param("uid", "");
	my $coo = $s->header();
	my $ipa = $q->remote_addr();
	$coo =~ s/ISO-8859-1/utf-8\n\n/g;
	@sid = ($coo,$sid[1],"",$ipa);
	&input(qq{DELETE FROM sessions WHERE id="$sid"});
}
sub reset_expire() {
	my %p = %{$_[0]};
	@sid = &get_sid();
	my $expired = &fast(qq{SELECT id FROM sessions WHERE id="$sid[1]" AND created < SUBDATE(CURRENT_TIMESTAMP(), INTERVAL 10 MINUTE)});
	if ($expired eq $sid[1] and $sid[2] ne "") {
		$p{"do"} = "logout";
		$p{"message_error"} = qq{<span class="b">To help protect patient confidentiality, you have been automatically signed out after a ten minute period of inactivity.</span> We apologize for the inconvenience.};
	} else {
		&input(qq{UPDATE sessions SET created=CURRENT_TIMESTAMP() WHERE id="$sid[1]"});
	}
	return %p;
}
sub check_expire() {
	my %p = %{$_[0]};
	@sid = &get_sid();
	my $expired = &fast(qq{SELECT id FROM sessions WHERE id="$sid[1]" AND created < SUBDATE(CURRENT_TIMESTAMP(), INTERVAL 10 MINUTE)});
	if ($expired eq $sid[1] and $sid[2] ne "") {
		$p{"do"} = "logout";
		$p{"message_error"} = qq{<span class="b">To help protect patient confidentiality, you have been automatically signed out after a ten minute period of inactivity.</span> We apologize for the inconvenience.};
	}
	return %p;
}
sub auth() {
	@sid = &get_sid();
	if ($sid[2] ne "") {
		return $sid[1];
	} else {
		return "";
	}
}
sub params() {
	my %p;
	my @post = $q->param;
	foreach my $name (@post) {
		$p{"$name"} = $q->param("$name");
		$p{"$name"} =~ s/\"/&quot;/g;
	}
	if ($p{"token"} ne $sid[1]) {
		%p = ();
	}
	return %p;
}
sub display_checkboxes() {
	my $value = shift;
	if ($value eq "1") {
		return "checked";
	} else {
		return "";
	}
}
sub or_null() {
	my $input = shift;
	if ($input =~ /NULL/ or $input eq "" or $input eq "0000-00-00") {
		return "NULL";
	} else {
		return qq{"$input"};
	}
}
sub track() {
	my ($table, $entry) = @_;
	if ($table and $entry) {
		my $ip = $q->remote_addr;
		my $client = $q->user_agent();
		my %values = &queryh(qq{SELECT * FROM ptms_$table WHERE entry="$entry"});
		my $keys = qq{hs_uid, hs_ip, hs_client, };
		my $query;
		foreach my $key (keys %values) {
			$keys = $keys . $key . ", ";
			$query = $query . qq{"} . $values{$key} . qq{", };
		}
		$keys =~ s/, $//g;
		$query =~ s/, $//g;
		my $final = qq{INSERT INTO ptms__hs_$table ($keys) VALUES ("$sid[2]", "$ip", "$client", $query)};
		&input($final);
	}
}
sub header() {
	return qq{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" dir="ltr">
<head>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8" >
	<title>RenalConnect</title>
	<style type="text/css" media="all">\@import "$path_htdocs/main.css";</style>
	<script src="$path_htdocs/main.js" type="text/javascript"></script>
	<script src="$path_htdocs/date.js" type="text/javascript"></script>
</head>};
}
sub footer() {
	return qq{
		<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-18887445-1']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script></body></html>};
}
sub close_button() {
	return qq{<div class="float-r"><img src="$path_htdocs/images/close_off.png" alt="close" class="pointer" onclick="pop_up_hide(); clear_date_picker();" onmouseover="this.src='$path_htdocs/images/close_on.png';" onmouseout="this.src='$path_htdocs/images/close_off.png';"/></div>};
}
sub iframe() {
	return qq{
		<div class="hide">
			<iframe id="hbin" name="hbin" class="bin" src="$path_htdocs/images/blank.gif"></iframe>
			<iframe id="sbin" name="sbin" class="bin" src="alerts.pl"></iframe>
		</div>
		<div id="ap" class="hide">active_cases</div>};
}
my $close_button = &close_button();
sub remove_leading_zeros() {
	my $number = shift;
	$number =~ s/^0+//g;
	return $number;
}
sub build_select() {
	my @option = @_;
	my $active = shift(@option);
	my ($active_data, $active_text) = split(/;;/,$active);
	my $exists = 0;
	my $return;
	foreach my $e (@option) {
		my $value;
		my $label;
		if ($e =~ /;;/) {
			($value,$label) = split(/;;/,$e);
		} else {
			$value = $e;
			$label = $e;
		}
		if ($value ne $active_data) {
			$return .= qq{<option value="$value">$label</option>};
		} else {
			$return .= qq{<option value="$value" selected="selected">$label</option>};
			$exists = 1;
		}
	}
	if ($exists == 0) {
		if ($active_data ne "" and $active_text ne "") {
			$return .= qq{<option value="$active_data" selected="selected">$active_data $active_text</option>};
		} else {
			$return .= qq{<option value="$active_data" selected="selected">$active_data</option>};
		}
	}
	return $return;
}
sub nice_time_interval() {
	my $then = shift;
	my $now = &fast(qq{SELECT CURRENT_TIMESTAMP()});
	my $days = &fast(qq{SELECT DATEDIFF('$now','$then')});
	my $hour = &fast(qq{SELECT TIMEDIFF('$now','$then')});
	my $out;
	if ($days == 0) {
		my ($hr,$mn,$sc) = split(/:/,$hour);
		$hr = &remove_leading_zeros($hr);
		$mn = &remove_leading_zeros($mn);
		if ($hr > 1) {
			$out = "$hr hours ago";
		} elsif ($hr == 1) {
			$out = "1 hour ago";
		} elsif ($mn == 1) {
			$out = "1 minute ago";
		} elsif ($mn > 1) {
			$out = "$mn minutes ago";
		} else {
			$out = "moments ago";
		}
	} elsif ($days < 1) {
		my ($hr,$mn,$sc) = split(/:/,$hour);
		$hr = &remove_leading_zeros($hr);
		$mn = &remove_leading_zeros($mn);
		$out = "$hr hours ago";
	} elsif ($days == 1) {
		$out = "yesterday";
	} elsif ($days > 1) {
		if ($days >= 730) {
			my $years = int(0.5 + ($days / 365.25));
			$out = "$years years ago";
		} elsif ($days >= 70) {
			my $months = int(0.5 + ($days / 30.4375));
			$out = "$months months ago";
		} elsif ($days >= 14) {
			my $weeks = int(0.5 + ($days / 7));
			$out = "$weeks weeks ago";
		} else {
			$out = "$days days ago";
		}
	}
	return $out;
}
sub nice_time() {
	my $time = shift;
	$time = &fast(qq{SELECT DATE_FORMAT("$time",'%M %D, %Y  %h:%i %p');});
	$time =~ s/  /\&nbsp\; /g;
	$time =~ s/ 0//g;
	return $time;
}
sub nice_date() {
	my $time = shift;
	$time = &fast(qq{SELECT DATE_FORMAT("$time",'%M %D, %Y');});
	$time =~ s/  /\&nbsp\; /g;
	$time =~ s/ 0//g;
	return $time;
}
sub get_quick_links() {
	return qq{
		<div class="float-l p20ro">
			<img src="$path_htdocs/images/icon-update-small-blue.png" alt="" align="absmiddle"/> <a class="b" target="hbin" href="ajax.pl?token=$token&ref=view_active_cases&do=add_case_form">New case</a> &nbsp; &nbsp; 
			<img src="$path_htdocs/images/icon-user-small.png" alt="" align="absmiddle"/> <a class="b" target="hbin" href="ajax.pl?token=$token&ref=view_patients&do=add_patient_form">New patient</a>
		</div>
	};
}
sub view_active_cases() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	my @active_cases = &querymr(qq{SELECT entry, patient, case_type, initial_wbc, initial_pmn, hospitalization_required, hospitalization_location, hospitalization_start_date, hospitalization_stop_date, outcome, home_visit, next_step, comments, created, modified FROM ptms_cases WHERE closed="0" ORDER BY modified DESC, created DESC});
	my $output;
	my $rc = "bg-vlg";
	my $hidden = 0;
	foreach my $c (@active_cases) {
		my ($entry, $patient, $case_type, $initial_wbc, $initial_pmn, $hospitalization_required, $hospitalization_location, $hospitalization_start_date, $hospitalization_stop_date, $outcome, $home_visit, $next_step, $comments, $created, $modified) = @$c;
		if (&fast(qq{SELECT entry FROM ptms_hide WHERE case_id="$entry" AND uid="$sid[2]" AND hide_until >= NOW()})) {
			$hidden++;
		} else {
			my $infection_type = &get_infection_type($entry);
			my $hematology = qq{<span class="gt">Initial WBC:</span> };
			if ($initial_wbc ne "") {
				$hematology .= qq{<span class="b">$initial_wbc x 10<sup>6</sup>/L</span> &nbsp; };
			} else {
				$hematology .= qq{(not entered) &nbsp; };
			}
			$hematology .= qq{<span class="gt">Initial \%PMN:</span> };
			if ($initial_pmn ne "") {
				$hematology .= qq{<span class="b">$initial_pmn\%</span>};
			} else {
				$hematology .= qq{(not entered) &nbsp; };
			}
			my @p = &query(qq{SELECT primary_nurse, nephrologist, phn, phone_home, phone_work, phone_mobile, email, name_first, name_last, dialysis_center FROM ptms_patients WHERE entry="$patient"});
			my $pd_centre = &fast(qq{SELECT center FROM ptms_dialysis WHERE patient_id="$patient" ORDER BY modified DESC LIMIT 1});
			my $comments_patient = &comments_patient($patient);
			my $nurse_print = qq{(none)};
			my $nephrologist_print = qq{(none)};
			if ($p[0] ne "") {
				my ($nurse_fn, $nurse_ln) = &query(qq{SELECT name_first, name_last FROM ptms_users WHERE entry="$p[0]"});
				$nurse_print = "$nurse_fn $nurse_ln";
			}
			if ($p[1] ne "") {
				my ($nephr_fn, $nephr_ln) = &query(qq{SELECT name_first, name_last FROM ptms_users WHERE entry="$p[1]"});
				$nephrologist_print = "Dr. $nephr_fn $nephr_ln";
			}
			my $p_contact = qq{<span class="gt">PHN</span> <span class="b">$p[2]</span>};
			$p_contact .= qq{ &nbsp; &nbsp; <span class="gt">home</span> <span class="b">$p[3]</span>} if ($p[3] ne "");
			$p_contact .= qq{ &nbsp; &nbsp; <span class="gt">work</span> <span class="b">$p[4]</span>} if ($p[4] ne "");
			$p_contact .= qq{ &nbsp; &nbsp; <span class="gt">mobile</span> <span class="b">$p[5]</span>} if ($p[5] ne "");
			$p_contact .= qq{ &nbsp; &nbsp; <span class="gt">email</span> <span class="b">$p[6]</span>} if ($p[6] ne "");
			my $onset_date = &nice_date($created);
			$onset_date =~ s/ /&nbsp;/g;
			my $onset_when = &nice_time_interval($modified);
			my $hospital_l = "Outpatient";
			my $case_status = $outcome;
			if ($hospitalization_required eq "Yes") {
				if ($hospitalization_stop_date eq "" or &fast(qq{SELECT DATEDIFF(CURDATE(), "$hospitalization_stop_date")}) < 0) {
					$hospital_l = "Admit to $hospitalization_location";
				} else {
					$hospital_l = "Admit to $hospitalization_location (now discharged)";
				}
			}
			my ($culture_report, $abx_prescribed, $abx_prescribed_final, $abx_prescribed_empiric, $abx_label_text, $abx_completion);
			my @abxs = &query(qq{SELECT entry FROM ptms_antibiotics WHERE case_id="$entry" AND date_end > CURRENT_DATE() AND date_stopped > CURRENT_DATE() ORDER BY entry DESC});
			my $abxs_done = &fast(qq{SELECT COUNT(*) FROM ptms_antibiotics WHERE case_id="$entry"});
			foreach my $abx (@abxs) {
				my %a = &queryh(qq{SELECT * FROM ptms_antibiotics WHERE entry="$abx"});
				my $nice_date = &nice_date($a{"date_end"});
				my $temp_text = qq{<span class="b">$a{"antibiotic"}</span> $a{"dose_amount"} $a{"dose_amount_units"} $a{"dose_frequency"}, };
				if ($a{"basis_final"} == 1) {
					$abx_prescribed_final .= $temp_text;
				} else {
					$abx_prescribed_empiric .= $temp_text;
				}
			}
			if ($abx_prescribed_final ne "") {
				$abx_prescribed = $abx_prescribed_final;
				$abx_label_text = "Final antibiotics";
			} else {
				$abx_prescribed = $abx_prescribed_empiric;
				$abx_label_text = "Empiric antibiotics";
			}
			my ($abx_bar, $abx_percent) = &build_abx_bar(&fast(qq{SELECT entry FROM ptms_antibiotics WHERE case_id="$entry" ORDER BY date_stopped DESC,  date_start ASC LIMIT 1}));
			$abx_prescribed =~ s/, $//g;
			if ($abx_prescribed eq "") {
				$abx_bar = qq{};
				if ($abxs_done > 0) {
					$abx_label_text = "Antibiotics";
					$abx_prescribed = qq{<span class="b">course completed</span>};
					&get_next_step($entry);
				} else {
					$abx_prescribed = qq{<span class="b">none</span>};
				}
			}
			my @labs = &query(qq{SELECT entry FROM ptms_labs WHERE case_id="$entry" ORDER BY entry DESC});
			foreach my $l (@labs) {
				my %l = &queryh(qq{SELECT * FROM ptms_labs WHERE entry="$l"});
				my $last_updated = &nice_time_interval($l{"modified"});
				foreach my $slot (1..4) {
					$culture_report .= qq{$l{"pathogen_$slot"} ($last_updated); } if $l{"pathogen_$slot"};
				}
			}
			if ($culture_report eq "") {
				$culture_report = qq{<span class="b">no result</span>};
			}
			$culture_report =~ s/; $//g;
			$next_step = &fast(qq{SELECT next_step FROM ptms_cases WHERE entry="$entry" LIMIT 1});
			my $next_step_raw = $next_step;
			$next_step = &interpret_next_step($next_step);
			$infection_type = lcfirst $infection_type;
			$home_visit = lcfirst $home_visit;
			$case_type = lcfirst $case_type;
			$output .= qq{
				<div class="p5to">
					<div class="p20bo bg-dbp-$next_step_raw">
						<div class="">
							<div class="p5">
								<div class="float-r">$p_contact &nbsp; <a href="ajax.pl?token=$token&ref=view_active_cases&do=hide&case_id=$entry" target="hbin" class="b">Hide</a></div>
								<a href="ajax.pl?token=$token&ref=view_active_cases&do=edit_patient_form&amp;patient_id=$patient" target="hbin"><span class="wH">$p[8], $p[7]</span></a> $comments_patient &nbsp; $hospital_l
								<div><span class="gt">Primary nurse:</span> <span class="">$nurse_print</span> &nbsp; &nbsp; <span class="gt">Nephrologist:</span> <span class="">$nephrologist_print</span> &nbsp; &nbsp; <span class="gt">PD centre:</span> $pd_centre</div>
							</div>
							<div class=""><table class="w100p">
								<tbody>
									<tr>
										<td class="tl w30p"><div class="p5">
											<div><span class="gt">Presentation date:</span> <span class="b">$onset_date</span></div>
											<div><span class="gt">Last updated:</span> <span class="b">$onset_when</span></div>
											<div><span class="gt">Case type:</span> $case_type</div>
											<div><span class="gt">Infection type:</span> $infection_type</div>
											<div><span class="gt">Follow-up visit:</span> $home_visit</div>
										</div></td>
										<td class="tl"><div class="p5">
											<div><span class="gt">Culture report:</span> $culture_report</div>
											<div><span class="gt">$abx_label_text:</span> $abx_prescribed $abx_bar</div>
											<div class="p10to"><span class="ac-yellow">Next step: $next_step</span></div>
										</div></td>
										<td class="tl w130"><a href="ajax.pl?token=$token&ref=view_active_cases&do=edit_case_form&amp;case_id=$entry" target="hbin" class="manage_case" onclick="this.blur();"></a></td>
									</tr>
								</tbody>
							</table></div>
						</div>
					</div>
				</div>};
			if ($rc eq "") {
				$rc = "bg-vlg";
			} else {
				$rc = "";
			}
		}
	}
	if ($output eq "") {
		$output = qq{<div class="p10to gt">There are currently no active cases to display ($hidden hidden for today). <a href="ajax.pl?token=$token&ref=view_active_cases&do=unhide" target="hbin" class="b">Unhide all active cases</a> or <a href="ajax.pl?token=$token&ref=view_active_cases&do=add_case_form" target="hbin" class="b">create a case</a></div>};
	}
	return $output;
}
sub comments_patient() {
	my $entry = shift;
	if (&fast(qq{SELECT comments FROM ptms_patients WHERE entry="$entry"}) ne "") {
		return $comment_icon;
	} else {
		return "";
	}
}
sub comments_case() {
	my $entry = shift;
	my $comments_case = &fast(qq{SELECT comments FROM ptms_cases WHERE entry="$entry"});
	my $comments_abx;
	my $comments_lab;
	my @abxs = &query(qq{SELECT comments FROM ptms_antibiotics WHERE case_id="$entry"});
	my @labs = &query(qq{SELECT comments FROM ptms_labs WHERE case_id="$entry"});
	foreach my $abx (@abxs) {
		if ($abx ne "") {
			$comments_abx = 1;
		}
	}
	foreach my $lab (@labs) {
		if ($lab ne "") {
			$comments_lab = 1;
		}
	}
	if ($comments_case ne "" or $comments_abx ne "" or $comments_lab ne "") {
		return $comment_icon;
	} else {
		return "";
	}
}
sub comments_antibiotic() {
	my $entry = shift;
	if (&fast(qq{SELECT comments FROM ptms_antibiotics WHERE entry="$entry"}) ne "") {
		return $comment_icon;
	} else {
		return "";
	}
}
sub comments_lab() {
	my $entry = shift;
	if (&fast(qq{SELECT comments FROM ptms_labs WHERE entry="$entry"}) ne "") {
		return $comment_icon;
	} else {
		return "";
	}
}
sub view_cases() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	$p{"do"} = "view_cases";


	# BUILDS PATIENT ID AND NAME FILTERS
	# Filters the results based on a string of text provided
	# or a discreet patient database "entry" ID.

	my ($filter, $notice);
	if ($p{"filter"}) {
		$filter .= qq{AND (};
		my @split = split(/ /,$p{"filter"});
		foreach my $word (@split) {
			$filter .= qq{ptms_patients.name_first LIKE "\%$word\%" OR ptms_patients.name_last LIKE "\%$word\%" OR };
		}
		$filter =~ s/ OR $/\) /g;
	}
	if ($p{"patient_id"} ne "" and &fast(qq{SELECT entry FROM ptms_patients WHERE entry="$p{"patient_id"}" LIMIT 1}) ne "") {
		my ($name_first, $name_last, $phn) = &query(qq{SELECT name_first, name_last, phn FROM ptms_patients WHERE entry="$p{"patient_id"}" LIMIT 1});
		$filter .= qq{AND ptms_cases.patient="$p{"patient_id"}"};
		$notice .= qq{<div class="p10bo"><div class="warning"><span class="b">Displaying cases for $name_first $name_last</span> <span class="gt">(PHN $phn)</span> &nbsp; <a href="ajax.pl?token=$token&ref=view_cases&do=view_cases" target="hbin" onclick="tt('nav','1','4');">Click here</a> to see all cases.</div></div>};
	}



	# COUNTS HOW MANY RECORDS EXIST

	$p{"page_total_records"} = &fast(qq{SELECT COUNT(*) FROM ptms_cases $filter});



	# IF THE RESULTS ARE BEING FILTERED, DISPLAY ALL IN ONE PAGE
	# OTHERWISE, PAGINATE AT 20 RECORDS PER PAGE

	if ($p{"patient_id"} ne "" or $p{"filter"} ne "") {
		$p{"page"} = "1";
		$p{"page_q"} = 10000;
	} else {
		$p{"page"} = "1" if $p{"page"} eq "";
		$p{"page_q"} = 20;
	}



	# SORTING MECHANISM
	# The chunk of code below builds the clickable table headers.
	# Place this code high up as the sort_by_modify is required to
	# build the MySQL query.

	my %sort_by_labels = (
		"id" => "ID",
		"status" => "Status",
		"outcome" => "Outcome",
		"patient_name" => "Patient name",
		"next_step" => "Next step",
		"created" => "Created",
		"date_of_onset" => "Onset");
	my %sort_by_modify = (
		"id" => "ptms_cases.entry ASC",
		"status" => "ptms_cases.closed ASC",
		"outcome" => "ptms_cases.outcome ASC",
		"patient_name" => "ptms_patients.name_last ASC",
		"next_step" => "ptms_cases.next_step DESC",
		"created" => "ptms_cases.created DESC",
		"date_of_onset" => "ptms_cases.created DESC");
	my $query_sort_by = $sort_by_modify{$p{"sort"}};
	if ($query_sort_by eq "") {
		$query_sort_by = $sort_by_modify{"status"};
		$p{"sort"} = "status";
	}
	foreach my $key (keys %sort_by_labels) {
		if ($key ne $p{"sort"}) {
			$sort_by_labels{$key} = qq{<a target="hbin" href="ajax.pl?token=$token&do=$p{"do"}&patient_id=$p{"patient_id"}&filter=$p{"filter"}&sort=} . $key . qq{">} . $sort_by_labels{$key} . qq{</a>};
		} else {
			$sort_by_labels{$key} = qq{<span class="b">} . $sort_by_labels{$key} . qq{</span> <img src="$path_htdocs/images/ats_d.gif" alt="" align="absmiddle"/>};
		}
	}



	# PAGINATES THE DATA AND BUILDS THE SEARCH BOX

	$p{"page_limit_offset"} = $p{"page"} * $p{"page_q"} - $p{"page_q"};
	$p{"page_limit_offset_human"} = $p{"page_limit_offset"} + 1;
	$p{"page_limit_offset_human_tail"} = $p{"page"} * $p{"page_q"};
	$p{"page_limit_offset_human_tail"} = $p{"page_total_records"} if $p{"page_limit_offset_human_tail"} > $p{"page_total_records"};
	$p{"pages"} = int(1 + $p{"page_total_records"} / $p{"page_q"});
	my $pager = qq{
		<div class="p10to p10bo gt">
			<form name="form_page_jumper" action="ajax.pl" target="hbin" method="post" accept-charset="utf-8">
				<input type="hidden" name="do" value="$p{"do"}"/>
				<input type="hidden" name="token" value="$token"/>
				<input type="hidden" name="sort" value="$p{"sort"}"/>};
	if ($p{"pages"} > 1) {
		my $pages;
		my @pages = (1..$p{"pages"});
		foreach my $page (@pages) {
			if ($page eq $p{"page"}) {
				$pages .= qq{<option selected="selected">$page</option>};
			} else {
				$pages .= qq{<option>$page</option>};
			}
		}
		$pager .= qq{
			<div class="float-r">
				Record $p{"page_limit_offset_human"} to $p{"page_limit_offset_human_tail"} of $p{"page_total_records"} &nbsp; };
		if ($p{"page"} > 1) {
			my $prev_page = $p{"page"} - 1;
			$pager .= qq{<a href="ajax.pl?token=$token&ref=$ref&do=$p{"do"}&page=$prev_page&patient_id=$p{"patient_id"}&filter=$p{"filter"}&sort=$p{"sort"}" target="hbin" class="b">previous</a> &nbsp; };
		} else {
			$pager .= qq{<span class="gt b">previous</span> &nbsp; };
		}
		if ($p{"page"} + 1 <= $p{"pages"}) {
			my $next_page = $p{"page"} + 1;
			$pager .= qq{<a href="ajax.pl?token=$token&ref=$ref&do=$p{"do"}&page=$next_page&patient_id=$p{"patient_id"}&filter=$p{"filter"}&sort=$p{"sort"}" target="hbin" class="b">next</a>};
		} else {
			$pager .= qq{<span class="gt b">next</span>};
		}
		$pager .= qq{ &nbsp; go to page <select name="page">$pages</select> <input type="submit" value="Go"/></div>};
	}
	my $reset_button = qq{<a href="ajax.pl?token=$token&ref=$ref&do=$p{"do"}" target="hbin" class="b">reset</a>};
	$reset_button = qq{} if $p{"filter"} eq "";
	$pager .= qq{
				<div>
					<div class="float-l p1to p5ro">Search</div>
					<div class="float-l p5ro"><div class="itt w160"><input type="text" class="itt" name="filter" value="$p{"filter"}"/></div></div>
					<div class="float-l"><input type="submit" value="Search"/> &nbsp; $reset_button</div>
					<div class="clear-l"></div>
				</div>
			</form>
			<div class="clear-r"></div>
		</div>};



	my @cases = &querymr(qq{SELECT ptms_cases.entry, ptms_cases.patient, ptms_cases.case_type, ptms_cases.hospitalization_required, ptms_cases.hospitalization_location, ptms_cases.outcome, ptms_cases.home_visit, ptms_cases.next_step, ptms_cases.comments, ptms_cases.created, ptms_cases.modified, ptms_cases.closed, ptms_patients.name_last, ptms_patients.name_first, ptms_patients.phn FROM ptms_cases, ptms_patients WHERE ptms_patients.entry=ptms_cases.patient $filter ORDER BY $query_sort_by, ptms_patients.name_last ASC LIMIT $p{"page_limit_offset"}, $p{"page_q"}});
	my $cases;
	my $rc = "bg-vlg";
	foreach my $c (@cases) {
		my ($entry, $patient, $case_type, $hospitalization_required, $hospitalization_location, $outcome, $home_visit, $next_step, $comments, $created, $modified, $closed, $name_last, $name_first, $phn) = @$c;
		$created = &nice_time_interval($created);
		$modified = &nice_time_interval($modified);
		$next_step = &interpret_next_step($next_step);
		my $infection_type = &get_infection_type($entry);
		my $status = qq{<span class="b txt-gre">Active</span>};
		my $manage_case_button = qq{<a target="hbin" href="ajax.pl?token=$token&ref=view_cases&do=edit_case_form&case_id=$entry">manage case</a>};
		if ($closed eq "1") {
			$status = qq{<span class="b txt-red">Closed</span>};
			$manage_case_button = qq{<a target="hbin" href="ajax.pl?token=$token&ref=view_cases&do=edit_case_form&case_id=$entry">review case</a>};
		}
		my $comments_patient = &comments_patient($patient);
		my $comments_case = &comments_case($entry);
		$cases .= qq{
			<tr class="$rc">
				<td class="pfmb_l gt">$entry</td>
				<td class="pfmb_l">$status &nbsp; $manage_case_button $comments_case</td>
				<td class="pfmb_l">$outcome</td>
				<td class="pfmb_l"><a target="hbin" href="ajax.pl?token=$token&ref=view_cases&do=edit_patient_form&patient_id=$patient"><strong>$name_last</strong>, $name_first</a> $comments_patient</td>
				<td class="pfmb_l">$next_step</td>
				<td class="pfmb_l">$modified</td>
			</tr>
		};
		if ($rc eq "") {
			$rc = "bg-vlg";
		} else {
			$rc = "";
		}
	}
	if ($cases eq "") {
		$cases = qq{<tr><td class="pfmb_l gt" colspan="6">No cases found.</td></tr>};
	}
	return qq{
		$pager
		$notice
		<table class="pfmt w100p">
			<tbody>
				<tr>
					<td class="pfmb_l b bg-dbp w5p">$sort_by_labels{"id"}</td>
					<td class="pfmb_l b bg-dbp w20p">$sort_by_labels{"status"}</td>
					<td class="pfmb_l b bg-dbp w16p">$sort_by_labels{"outcome"}</td>
					<td class="pfmb_l b bg-dbp w24p">$sort_by_labels{"patient_name"}</td>
					<td class="pfmb_l b bg-dbp">$sort_by_labels{"next_step"}</td>
					<td class="pfmb_l b bg-dbp w13p">$sort_by_labels{"date_of_onset"}</td>
				</tr>
				$cases
			</tbody>
		</table>
	};
}
sub cache_rebuild_patient() {
	my $patient_id = shift;
	my ($cache_primary_nurse, 
		$cache_nephrologist, 
		$cache_on_pd, 
		$cache_cases, 
		$cache_case_status);
	my ($primary_nurse, $nephrologist) = &query(qq{SELECT primary_nurse, nephrologist FROM ptms_patients WHERE entry="$patient_id"});
	my $pd_stop_date = &fast(qq{SELECT stop_date FROM ptms_dialysis WHERE patient_id="$patient_id" ORDER BY entry DESC LIMIT 1});
	if ($primary_nurse ne "") {
		$cache_primary_nurse = join(", ",&query(qq{SELECT name_last, name_first FROM ptms_users WHERE entry="$primary_nurse"}));
	}
	if ($nephrologist ne "") {
		$cache_nephrologist = join(", ",&query(qq{SELECT name_last, name_first FROM ptms_users WHERE entry="$nephrologist"}));
	}
	$cache_on_pd = $pd_stop_date;
	$cache_cases = &fast(qq{SELECT COUNT(*) FROM ptms_cases WHERE patient="$patient_id"});
	$cache_case_status = &fast(qq{SELECT closed FROM ptms_cases WHERE patient="$patient_id" ORDER BY closed ASC LIMIT 1});
	&input(qq{UPDATE ptms_patients SET 
		cache_primary_nurse="$cache_primary_nurse",
		cache_nephrologist="$cache_nephrologist",
		cache_on_pd="$cache_on_pd",
		cache_cases="$cache_cases",
		cache_case_status="$cache_case_status"
		WHERE entry="$patient_id"});
}
sub view_patients() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	$p{"do"} = "view_patients";



	# BUILDS NAME FILTERS
	# Filters the results based on a string of text provided
	# or a discreet patient database "entry" ID.

	my ($filter, $notice);
	if ($p{"filter"}) {
		$filter .= qq{WHERE };
		my @split = split(/ /,$p{"filter"});
		foreach my $word (@split) {
			$filter .= qq{ptms_patients.name_first LIKE "\%$word\%" OR ptms_patients.name_last LIKE "\%$word\%" OR ptms_patients.phn LIKE "\%$word\%" OR ptms_patients.cache_primary_nurse LIKE "\%$word\%" OR ptms_patients.cache_nephrologist LIKE "\%$word\%" OR };
		}
		$filter =~ s/ OR $//g;
	}



	# COUNTS HOW MANY RECORDS EXIST

	$p{"page_total_records"} = &fast(qq{SELECT COUNT(*) FROM ptms_patients $filter});



	# IF THE RESULTS ARE BEING FILTERED, DISPLAY ALL IN ONE PAGE
	# OTHERWISE, PAGINATE AT 20 RECORDS PER PAGE

	if ($p{"filter"} ne "") {
		$p{"page"} = "1";
		$p{"page_q"} = 10000;
	} else {
		$p{"page"} = "1" if $p{"page"} eq "";
		$p{"page_q"} = 20;
	}



	# SORTING MECHANISM
	# The chunk of code below builds the clickable table headers.
	# Place this code high up as the sort_by_modify is required to
	# build the MySQL query.

	my %sort_by_labels = (
		"id" => "ID",
		"name" => "Name",
		"phn" => "PHN",
		"primary_nurse" => "Primary nurse",
		"nephrologist" => "Nephrologist",
		"on_pd" => "On PD",
		"cases" => "Cases",
		"status" => "Status");
	my %sort_by_modify = (
		"id" => "ptms_patients.entry ASC",
		"name" => "ptms_patients.name_last ASC",
		"phn" => "ptms_patients.phn ASC",
		"primary_nurse" => "ptms_patients.cache_primary_nurse ASC",
		"nephrologist" => "ptms_patients.cache_nephrologist ASC",
		"on_pd" => "ptms_patients.cache_on_pd ASC",
		"cases" => "ptms_patients.cache_cases DESC",
		"status" => "ptms_patients.cache_case_status ASC");
	my $query_sort_by = $sort_by_modify{$p{"sort"}};
	if ($query_sort_by eq "") {
		$query_sort_by = $sort_by_modify{"name"};
		$p{"sort"} = "name";
	}
	foreach my $key (keys %sort_by_labels) {
		if ($key ne $p{"sort"}) {
			$sort_by_labels{$key} = qq{<a target="hbin" href="ajax.pl?token=$token&do=$p{"do"}&filter=$p{"filter"}&sort=} . $key . qq{">} . $sort_by_labels{$key} . qq{</a>};
		} else {
			$sort_by_labels{$key} = qq{<span class="b">} . $sort_by_labels{$key} . qq{</span> <img src="$path_htdocs/images/ats_d.gif" alt="" align="absmiddle"/>};
		}
	}



	# PAGINATES THE DATA AND BUILDS THE SEARCH BOX

	$p{"page_limit_offset"} = $p{"page"} * $p{"page_q"} - $p{"page_q"};
	$p{"page_limit_offset_human"} = $p{"page_limit_offset"} + 1;
	$p{"page_limit_offset_human_tail"} = $p{"page"} * $p{"page_q"};
	$p{"page_limit_offset_human_tail"} = $p{"page_total_records"} if $p{"page_limit_offset_human_tail"} > $p{"page_total_records"};
	$p{"pages"} = int(1 + $p{"page_total_records"} / $p{"page_q"});
	my $pager = qq{
		<div class="p10to p10bo gt">
			<form name="form_page_jumper" action="ajax.pl" target="hbin" method="post" accept-charset="utf-8">
				<input type="hidden" name="do" value="$p{"do"}"/>
				<input type="hidden" name="token" value="$token"/>
				<input type="hidden" name="sort" value="$p{"sort"}"/>};
	if ($p{"pages"} > 1) {
		my $pages;
		my @pages = (1..$p{"pages"});
		foreach my $page (@pages) {
			if ($page eq $p{"page"}) {
				$pages .= qq{<option selected="selected">$page</option>};
			} else {
				$pages .= qq{<option>$page</option>};
			}
		}
		$pager .= qq{
			<div class="float-r">
				Record $p{"page_limit_offset_human"} to $p{"page_limit_offset_human_tail"} of $p{"page_total_records"} &nbsp; };
		if ($p{"page"} > 1) {
			my $prev_page = $p{"page"} - 1;
			$pager .= qq{<a href="ajax.pl?token=$token&ref=$ref&do=$p{"do"}&page=$prev_page&patient_id=$p{"patient_id"}&filter=$p{"filter"}&sort=$p{"sort"}" target="hbin" class="b">previous</a> &nbsp; };
		} else {
			$pager .= qq{<span class="gt b">previous</span> &nbsp; };
		}
		if ($p{"page"} + 1 <= $p{"pages"}) {
			my $next_page = $p{"page"} + 1;
			$pager .= qq{<a href="ajax.pl?token=$token&ref=$ref&do=$p{"do"}&page=$next_page&patient_id=$p{"patient_id"}&filter=$p{"filter"}&sort=$p{"sort"}" target="hbin" class="b">next</a>};
		} else {
			$pager .= qq{<span class="gt b">next</span>};
		}
		$pager .= qq{ &nbsp; go to page <select name="page">$pages</select> <input type="submit" value="Go"/></div>};
	}
	my $reset_button = qq{<a href="ajax.pl?token=$token&ref=$ref&do=$p{"do"}" target="hbin" class="b">reset</a>};
	$reset_button = qq{} if $p{"filter"} eq "";
	$pager .= qq{
				<div>
					<div class="float-l p1to p5ro">Search</div>
					<div class="float-l p5ro"><div class="itt w160"><input type="text" class="itt" name="filter" value="$p{"filter"}"/></div></div>
					<div class="float-l"><input type="submit" value="Search"/> &nbsp; $reset_button</div>
					<div class="clear-l"></div>
				</div>
			</form>
			<div class="clear-r"></div>
		</div>};



	my $rc = "bg-vlg";
	my $patients;
	my @patients = &querymr(qq{SELECT entry, name_last, name_first, phn, cache_primary_nurse, cache_nephrologist, cache_on_pd, cache_cases, cache_case_status, modified FROM ptms_patients $filter ORDER BY $query_sort_by, name_last ASC, name_first ASC, phn ASC LIMIT $p{"page_limit_offset"}, $p{"page_q"}});
	foreach my $p (@patients) {
		my ($entry, $name_last, $name_first, $phn, $cache_primary_nurse, $cache_nephrologist, $cache_on_pd, $cache_cases, $cache_case_status, $modified) = @$p;
		my $comments_patient = &comments_patient($entry);
		if ($cache_cases > 0) {
			$cache_cases = qq{<a href="ajax.pl?token=$token&ref=view_patients&do=view_cases&amp;patient_id=$entry" target="hbin" onclick="tt('nav','1','4');">$cache_cases found</a>};
			if ($cache_case_status eq "1") {
				$cache_case_status = qq{<span class="b txt-red">Closed</span>};
			} elsif ($cache_case_status eq "0") {
				$cache_case_status = qq{<span class="b txt-gre">Active</span>};
			}
		} else {
			$cache_cases = qq{<span class="gt">(none)</span>};
			$cache_case_status = qq{<span class="gt">(none)</span>};
		}
		if ($cache_on_pd eq "") {
			$cache_on_pd = qq{<span class="txt-gre b">Yes</span>};
		} else {
			$cache_on_pd = qq{<span class="txt-red b">No</span>};
		}
		$cache_primary_nurse = qq{<span class="gt">(not tracked)} if $cache_primary_nurse eq "";
		$cache_nephrologist = qq{<span class="gt">(not tracked)} if $cache_nephrologist eq "";
		$patients .= qq{
			<tr class="$rc">
				<td class="pfmb_l gt">$entry</td>
				<td class="pfmb_l"><a target="hbin" href="ajax.pl?token=$token&ref=view_patients&do=edit_patient_form&patient_id=$entry"><strong>$name_last</strong>, $name_first</a> $comments_patient</td>
				<td class="pfmb_l">$phn</td>
				<td class="pfmb_l">$cache_primary_nurse</td>
				<td class="pfmb_l">$cache_nephrologist</td>
				<td class="pfmb_l">$cache_on_pd</td>
				<td class="pfmb_l gt">$cache_cases</td>
				<td class="pfmb_l gt">$cache_case_status</td>
			</tr>};
		if ($rc eq "") {
			$rc = "bg-vlg";
		} else {
			$rc = "";
		}
	}
	if ($patients eq "") {
		$patients = qq{<tr><td class="pfmb_l gt" colspan="7">No patients found.</td></tr>};
	}
	return qq{
		$pager
		<table class="pfmt w100p">
			<tbody>
				<tr>
					<td class="pfmb_l b bg-dbp w6p">$sort_by_labels{"id"}</td>
					<td class="pfmb_l b bg-dbp">$sort_by_labels{"name"}</td>
					<td class="pfmb_l b bg-dbp w12p">$sort_by_labels{"phn"}</td>
					<td class="pfmb_l b bg-dbp w17p">$sort_by_labels{"primary_nurse"}</td>
					<td class="pfmb_l b bg-dbp w19p">$sort_by_labels{"nephrologist"}</td>
					<td class="pfmb_l b bg-dbp w9p">$sort_by_labels{"on_pd"}</td>
					<td class="pfmb_l b bg-dbp w9p">$sort_by_labels{"cases"}</td>
					<td class="pfmb_l b bg-dbp w9p">$sort_by_labels{"status"}</td>
				</tr>
				$patients
			</tbody>
		</table>};
}
sub enter_lab_test_results() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	my @labs = &querymr(qq{SELECT * FROM ptms_Labs ORDER BY status ASC});
	my $labs;
	my $rc = "bg-vlg";
	foreach my $l (@labs) {
		my $entry = @$l[0];
		my $status = @$l[5];
		my $case_id = @$l[1];
		my $result_pre = @$l[12];
		my $result_final = @$l[13];
		my $ordered = @$l[3];
		my $modified = @$l[15];
		$ordered = &nice_time_interval($ordered);
		$modified = &nice_time_interval($modified);
		my ($case_id, $case_type, $patient_id, $name_first, $name_last) = &query(qq{SELECT ptms_cases.entry, ptms_cases.case_type, ptms_cases.patient, ptms_patients.name_first, ptms_patients.name_last FROM ptms_cases, ptms_patients WHERE ptms_cases.entry="$case_id" AND ptms_cases.patient=ptms_patients.entry});
		my $infection_type = &get_infection_type($case_id);
		my $result_print = "none";
		if ($result_final > 0) {
			$result_print = "Final";
		} elsif ($result_pre > 0) {
			$result_print = "Preliminary";
		}
		$labs .= qq{
			<tr class="$rc">
				<td class="pfmb_l"><a target="hbin" href="ajax.pl?token=$token&ref=$ref&do=edit_patient_form&patient_id=$patient_id" class="b">$name_last, $name_first</a></td>
				<td class="pfmb_l">$infection_type</td>
				<td class="pfmb_l"><a target="hbin" href="ajax.pl?token=$token&ref=$ref&do=edit_lab_form&lab_id=$entry">$status</a></td>
				<td class="pfmb_l"><a target="hbin" href="ajax.pl?token=$token&ref=$ref&do=edit_lab_form&lab_id=$entry">$result_print</a></td>
				<td class="pfmb_l">$ordered</td>
				<td class="pfmb_l"><a target="hbin" href="ajax.pl?token=$token&ref=$ref&do=edit_lab_form&lab_id=$entry" class="b">update results</a></td>
			</tr>
		};
		if ($rc eq "") {
			$rc = "bg-vlg";
		} else {
			$rc = "";
		}
	}
	if ($labs eq "") {
		$labs = qq{<tr><td class="pfmb_l gt" colspan="6">No lab tests found.</td></tr>};
	}
	return qq{
		$close_button
		<h2><img src="$path_htdocs/images/img_culture.png" alt="" /> Culture results</h2>
		<div class="b p10bo">Please select a lab test record to update. If the appropriate lab test requisition is not listed below, <a href="ajax.pl?token=$token&ref=$ref&do=add_lab_form" target="hbin">please create one</a>.</div>
		<table class="pfmt w100p">
			<tbody>
				<tr>
					<td class="pfmb_l b bg-dbp">Patient name</td>
					<td class="pfmb_l b bg-dbp">Infection type</td>
					<td class="pfmb_l b bg-dbp">Status</td>
					<td class="pfmb_l b bg-dbp">Results</td>
					<td class="pfmb_l b bg-dbp">Ordered</td>
					<td class="pfmb_l b bg-dbp">&nbsp;</td>
				</tr>
				$labs
			</tbody>
		</table>
	};
}
sub view_labs() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	$p{"do"} = "view_labs";


	# BUILDS NAME FILTER
	# Filters the results based on a string of text provided

	my ($filter, $notice);
	if ($p{"filter"}) {
		$filter .= qq{AND (};
		my @split = split(/ /,$p{"filter"});
		foreach my $word (@split) {
			$filter .= qq{ptms_patients.name_first LIKE "\%$word\%" OR ptms_patients.name_last LIKE "\%$word\%" OR ptms_labs.pathogen_1 LIKE "\%$word\%" OR ptms_labs.pathogen_2 LIKE "\%$word\%" OR ptms_labs.pathogen_3 LIKE "\%$word\%" OR ptms_labs.pathogen_4 LIKE "\%$word\%" OR };
		}
		$filter =~ s/ OR $/\) /g;
	}



	# COUNTS HOW MANY RECORDS EXIST

	$p{"page_total_records"} = &fast(qq{SELECT COUNT(*) FROM ptms_labs, ptms_cases, ptms_patients WHERE ptms_cases.entry=ptms_labs.case_id AND ptms_patients.entry=ptms_cases.patient $filter});



	# IF THE RESULTS ARE BEING FILTERED, DISPLAY ALL IN ONE PAGE
	# OTHERWISE, PAGINATE AT 20 RECORDS PER PAGE

	if ($p{"patient_id"} ne "" or $p{"filter"} ne "") {
		$p{"page"} = "1";
		$p{"page_q"} = 10000;
	} else {
		$p{"page"} = "1" if $p{"page"} eq "";
		$p{"page_q"} = 20;
	}



	# SORTING MECHANISM
	# The chunk of code below builds the clickable table headers.
	# Place this code high up as the sort_by_modify is required to
	# build the MySQL query.

	my %sort_by_labels = (
		"id" => "ID",
		"patient_name" => "Patient name",
		"case_type" => "Case type",
		"results" => "Results",
		"last_updated" => "Last updated");
	my %sort_by_modify = (
		"id" => "ptms_labs.entry ASC",
		"patient_name" => "ptms_patients.name_last ASC",
		"case_type" => "ptms_cases.is_peritonitis DESC, ptms_cases.is_exit_site DESC, ptms_cases.is_tunnel DESC",
		"results" => "ptms_labs.pathogen_1 ASC, ptms_labs.pathogen_2 ASC, ptms_labs.pathogen_3 ASC, ptms_labs.pathogen_4 ASC",
		"last_updated" => "ptms_labs.modified DESC");
	my $query_sort_by = $sort_by_modify{$p{"sort"}};
	if ($query_sort_by eq "") {
		$query_sort_by = $sort_by_modify{"last_updated"};
		$p{"sort"} = "last_updated";
	}
	foreach my $key (keys %sort_by_labels) {
		if ($key ne $p{"sort"}) {
			$sort_by_labels{$key} = qq{<a target="hbin" href="ajax.pl?token=$token&do=$p{"do"}&patient_id=$p{"patient_id"}&filter=$p{"filter"}&sort=} . $key . qq{">} . $sort_by_labels{$key} . qq{</a>};
		} else {
			$sort_by_labels{$key} = qq{<span class="b">} . $sort_by_labels{$key} . qq{</span> <img src="$path_htdocs/images/ats_d.gif" alt="" align="absmiddle"/>};
		}
	}



	# PAGINATES THE DATA AND BUILDS THE SEARCH BOX

	$p{"page_limit_offset"} = $p{"page"} * $p{"page_q"} - $p{"page_q"};
	$p{"page_limit_offset_human"} = $p{"page_limit_offset"} + 1;
	$p{"page_limit_offset_human_tail"} = $p{"page"} * $p{"page_q"};
	$p{"page_limit_offset_human_tail"} = $p{"page_total_records"} if $p{"page_limit_offset_human_tail"} > $p{"page_total_records"};
	$p{"pages"} = int(1 + $p{"page_total_records"} / $p{"page_q"});
	my $pager = qq{
		<div class="p10to p10bo gt">
			<form name="form_page_jumper" action="ajax.pl" target="hbin" method="post" accept-charset="utf-8">
				<input type="hidden" name="do" value="$p{"do"}"/>
				<input type="hidden" name="token" value="$token"/>
				<input type="hidden" name="sort" value="$p{"sort"}"/>};
	if ($p{"pages"} > 1) {
		my $pages;
		my @pages = (1..$p{"pages"});
		foreach my $page (@pages) {
			if ($page eq $p{"page"}) {
				$pages .= qq{<option selected="selected">$page</option>};
			} else {
				$pages .= qq{<option>$page</option>};
			}
		}
		$pager .= qq{
			<div class="float-r">
				Record $p{"page_limit_offset_human"} to $p{"page_limit_offset_human_tail"} of $p{"page_total_records"} &nbsp; };
		if ($p{"page"} > 1) {
			my $prev_page = $p{"page"} - 1;
			$pager .= qq{<a href="ajax.pl?token=$token&ref=$ref&do=$p{"do"}&page=$prev_page&patient_id=$p{"patient_id"}&filter=$p{"filter"}&sort=$p{"sort"}" target="hbin" class="b">previous</a> &nbsp; };
		} else {
			$pager .= qq{<span class="gt b">previous</span> &nbsp; };
		}
		if ($p{"page"} + 1 <= $p{"pages"}) {
			my $next_page = $p{"page"} + 1;
			$pager .= qq{<a href="ajax.pl?token=$token&ref=$ref&do=$p{"do"}&page=$next_page&patient_id=$p{"patient_id"}&filter=$p{"filter"}&sort=$p{"sort"}" target="hbin" class="b">next</a>};
		} else {
			$pager .= qq{<span class="gt b">next</span>};
		}
		$pager .= qq{ &nbsp; go to page <select name="page">$pages</select> <input type="submit" value="Go"/></div>};
	}
	my $reset_button = qq{<a href="ajax.pl?token=$token&ref=$ref&do=$p{"do"}" target="hbin" class="b">reset</a>};
	$reset_button = qq{} if $p{"filter"} eq "";
	$pager .= qq{
				<div>
					<div class="float-l p1to p5ro">Search</div>
					<div class="float-l p5ro"><div class="itt w160"><input type="text" class="itt" name="filter" value="$p{"filter"}"/></div></div>
					<div class="float-l"><input type="submit" value="Search"/> &nbsp; $reset_button</div>
					<div class="clear-l"></div>
				</div>
			</form>
			<div class="clear-r"></div>
		</div>};



	my $labs_query = qq{SELECT ptms_labs.entry, ptms_labs.case_id, ptms_labs.pathogen_1, ptms_labs.pathogen_2, ptms_labs.pathogen_3, ptms_labs.pathogen_4, ptms_labs.ordered, ptms_labs.modified, ptms_cases.entry, ptms_cases.case_type, ptms_cases.patient, ptms_patients.name_first, ptms_patients.name_last FROM ptms_labs, ptms_cases, ptms_patients WHERE ptms_cases.entry=ptms_labs.case_id AND ptms_patients.entry=ptms_cases.patient $filter ORDER BY $query_sort_by, ptms_patients.name_last ASC, ptms_labs.modified DESC LIMIT $p{"page_limit_offset"}, $p{"page_q"}};
	my @labs = &querymr($labs_query);
	my $labs;
	my $rc = "bg-vlg";
	foreach my $l (@labs) {
		my ($entry, $case_id, $pathogen_1, $pathogen_2, $pathogen_3, $pathogen_4, $ordered, $modified, $case_id, $case_type, $patient_id, $name_first, $name_last) = @$l;
		$ordered = &nice_time_interval($ordered);
		$modified = &nice_time_interval($modified);
		my $infection_type = &get_infection_type($case_id);
		my $pathogens;
		foreach my $pathogen ($pathogen_1, $pathogen_2, $pathogen_3, $pathogen_4) {
			if ($pathogen ne "") {
				$pathogens .= qq{$pathogen; };
			}
		}
		$pathogens =~ s/; $//g;
		my $comments_lab = &comments_lab($entry);
		my $comments_patient = &comments_patient($patient_id);
		$labs .= qq{
			<tr class="$rc">
				<td class="pfmb_l gt">$entry</td>
				<td class="pfmb_l"><a target="hbin" href="ajax.pl?token=$token&ref=view_labs&do=edit_patient_form&patient_id=$patient_id"><strong>$name_last</strong>, $name_first</a> $comments_patient</td>
				<td class="pfmb_l">$infection_type</td>
				<td class="pfmb_l"><div class="ofh-18"><a target="hbin" href="ajax.pl?token=$token&ref=view_labs&do=edit_lab_form&lab_id=$entry">$pathogens</a> $comments_lab</div></td>
				<td class="pfmb_l">$modified</td>
			</tr>
		};
		if ($rc eq "") {
			$rc = "bg-vlg";
		} else {
			$rc = "";
		}
	}
	if ($labs eq "") {
		$labs = qq{<tr><td class="pfmb_l gt" colspan="4">No culture results found.</td></tr>};
	}
	return qq{
		$pager
		<table class="pfmt w100p">
			<tbody>
				<tr>
					<td class="pfmb_l b bg-dbp w6p">$sort_by_labels{"id"}</td>
					<td class="pfmb_l b bg-dbp w24p">$sort_by_labels{"patient_name"}</td>
					<td class="pfmb_l b bg-dbp w11p">$sort_by_labels{"case_type"}</td>
					<td class="pfmb_l b bg-dbp ">$sort_by_labels{"results"}</td>
					<td class="pfmb_l b bg-dbp w13p">$sort_by_labels{"last_updated"}</td>
				</tr>
				$labs
			</tbody>
		</table>
	};
}
sub viewer() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	@sid = &get_sid();
	my $check_db_status = &fast(qq{SELECT type FROM ptms_users WHERE type="Administrator" LIMIT 1});
	my $msgs;
	if ($p{"message_error"} ne "") {
		$msgs .= qq{<div class="emp">$p{"message_error"}</div>};
	}
	if (!$check_db_status) {
		return qq{
		<div class="w800 p30to align-middle">
			<div class="bg-cloud">
				<div class="align-middle w360 p100to">
					<img src="$path_htdocs/images/img_logo_rc_new.png" alt="RenalConnect"/>
					$msgs
					<div class="p10bo"><span class="b">This installation does not have an administrator.</span> Please take this opportunity to create an administrator account. For assistance, please click on the <span class="b">get technical support</span> link.</div>
					<form name="form_create_administrator" action="ajax.pl" target="hbin" method="post" accept-charset="utf-8">
					<input type="hidden" name="token" value="$token"/>
						<table>
							<tbody>
								<tr>
									<td class="tl gt p10ro">First name</td>
									<td class="tl"><div class="itt w240"><input type="text" class="itt" name="param_admin_name_first" value=""/></div></td>
								</tr><tr>
									<td class="tl gt p10ro">Last name</td>
									<td class="tl"><div class="itt w240"><input type="text" class="itt" name="param_admin_name_last" value=""/></div></td>
								</tr><tr>
									<td class="tl gt p10ro">Email</td>
									<td class="tl"><div class="itt w240"><input type="text" class="itt" name="param_admin_email" value=""/></div></td>
								</tr><tr>
									<td class="tl gt p10ro">Password</td>
									<td class="tl"><div class="itt w240"><input type="password" class="itt" name="param_admin_password"/></div></td>
								</tr><tr>
									<td class="tl gt p10ro">Repeat password</td>
									<td class="tl"><div class="itt w240"><input type="password" class="itt" name="param_admin_password_repeat"/></div></td>
								</tr><tr>
									<td class="tl gt p10ro">Database encryption key</td>
									<td class="tl p10bo"><div class="itt w240"><input type="text" class="itt" name="param_admin_key"/></div></td>
								</tr><tr>
									<td class="tl gt p10ro">&nbsp;<input type="hidden" name="do" value="create_administrator"/></td>
									<td class="tl p10to p10bo"><input type="submit" value="Submit"/></td>
								</tr>
							</tbody>
						</table>
						<div><a href="support.pl" class="b">Get technical support</a></div>
					</form>
				</div>
			</div>
		</div>};
	} elsif (&auth()) {
		my $ubox = &get_user_box(\%p);
		my $quick_links = &get_quick_links(\%p);
		my $view_active_cases = &view_active_cases(\%p);
		my $view_alerts = &get_alerts(\%p);
		return qq{
			<!--[if lt IE 7 ]>
  				<div class="p10 bg-yel"><img src="$path_htdocs/images/img_ni_warn.gif" alt="" align="absmiddle"/>&nbsp;<span class="b">You are using an outdated browser that is ten years old.</span> For best results, please upgrade to the latest release of <a href="http://www.google.com/chrome" target="_blank">Google Chrome</a>, <a href="http://www.firefox.com/" target="_blank">Mozilla Firefox</a>, or <a href="http://www.apple.com/safari" target="_blank">Apple Safari</a>.</div>
			<![endif]-->
			<div class="hdrbg"></div>
			$ubox
			<div class="p10lo p10ro wbg"><img src="$path_htdocs/images/img_logo_rc_new_small.png" alt="RenalConnect"/></div>
			<div class="p10lo p10ro wbg mh500">
				<div>
					<table class="w100p">
						<tbody>
							<tr>
								<td class="p10ro">
									<div class="bg-hx">
										$quick_links
										<a class="tab tabAct b" id="nav0" onclick="tt('nav','0','4'); apc('view_active_cases');" target="hbin" href="ajax.pl?token=$token&ref=view_active_cases&do=view_active_cases">Active cases</a>
										<a class="tab tabOff b" id="nav1" onclick="tt('nav','1','4'); apc('view_cases');" target="hbin" href="ajax.pl?token=$token&ref=view_cases&do=view_cases">All cases</a>
										<a class="tab tabOff b" id="nav2" onclick="tt('nav','2','4'); apc('view_patients');" target="hbin" href="ajax.pl?token=$token&ref=view_patients&do=view_patients">Patients</a>
										<a class="tab tabOff b" id="nav3" onclick="tt('nav','3','4'); apc('view_labs');" target="hbin" href="ajax.pl?token=$token&ref=view_labs&do=view_labs">Culture results</a>
										<a class="tab tabOff b" id="nav4" onclick="tt('nav','4','4'); apc('view_reports')" target="hbin" href="ajax.pl?token=$token&ref=view_reports&do=view_reports">Reports</a>
									</div>
									<div id="div_page" class="wbg">$view_active_cases</div>
								</td><td class="w240">
									<div class="bg-hx">
										<a class="tab tabAct b">Alerts</a> &nbsp; <a href="ajax.pl?token=$token&ref=$ref&do=view_dismissed_alerts" target="hbin">View dismissed alerts</a></div>
									</div>
									<div class="p5to" id="alerts">
										$view_alerts
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<div class="m20to br-t p10to p10bo p20lo p20ro tl gt bg-vlg">
				<div class="float-r"><a href="http://www.pdiconnect.com/cgi/reprint/30/4/393.pdf" target="_blank" class="b">View the ISPD Peritonitis Guidelines (PDF)</a></div>
				<span class="b">Remember patient confidentiality</span> &nbsp; &bull; &nbsp; Proudly hosted in British Columbia by the BC Provincial Renal Agency
			</div>};
	} else {
		return qq{
		<div class="w800 p30to align-middle">
			<div class="bg-cloud">
				<div class="align-middle w360 p100to">
					<div class="p20bo"><img src="$path_htdocs/images/img_logo_rc_new.png" 
					alt="RenalConnect" onload="pop_up_hide(); clear_date_picker();"/></div>
					<form name="form_login" action="ajax.pl" target="hbin" method="post" accept-charset="utf-8">
						<input type="hidden" name="token" value="$token"/>
						$msgs
						<table>
							<tbody>
								<tr>
									<td class="tr gt w100">Email</td>
									<td class="tl p10lo"><div class="itt w200"><input type="text" class="itt" name="param_login_email"/></div></td>
								</tr><tr>
									<td class="tr gt">Password</td>
									<td class="tl p10lo p10bo"><div class="itt w200"><input type="password" class="itt" name="param_login_password"/></div>
									<a href="password.pl">I forgot my password</a></td>
								</tr><tr>
									<td class="tl gt">&nbsp;<input type="hidden" name="do" value="login"></td>
									<td class="tl p10lo p20bo">
										<input type="submit" value="Sign in"/>
										<div class="p10to"><a href="support.pl" class="b">Get technical support</a></div>
									</td>
								</tr>
							</tbody>
						</table>
					</form>
					<div class="gt sml">RenalConnect is a clinical management tool developed in British Columbia to improve quality of care and patient outcome in peritoneal dialysis. It is hosted by the British Columbia Provincial Renal Agency (BCPRA).</div>
				</div>
			</div>
		</div>};
	}
}
sub get_user_box() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	@sid = &get_sid();
	if ($sid[2] ne "") {
		my ($type,$fnam,$lnam,$role) = &query(qq{SELECT type, name_first, name_last, role FROM ptms_users WHERE entry="$sid[2]"});
		my $name = $lnam . ", " . $fnam;
		my $tlbl = "(HCP)";
		if ($type eq "Administrator") {
			$type = qq{ &nbsp; <a href="ajax.pl?token=$token&ref=$ref&do=edit_manage_users_form" target="hbin">Manage users</a>};
			$tlbl = "(administrator)";
		} else {
			$type = "";
		}
		if ($role eq "Nephrologist" or $role eq "Surgeon") {
			$name = "Dr. " . $name;
		}
		return qq{
				<div class="w360 float-r">
					<div class="p10to p20ro tr">
						<div class="tr">
							<span class="b">$name</span> 
							<span class="gt">$tlbl</span> &nbsp; 
							<a href="ajax.pl?token=$token&ref=$ref&do=logout" target="hbin" class="b">Sign out</a>
						</div>
						<div class="tr"><a href="ajax.pl?token=$token&ref=$ref&do=edit_account_settings_form" target="hbin">Account settings</a>$type</div>
					</div>
				</div>};
	} else {
		return "not signed in";
	}
}
sub get_infection_type() {
	my $entry = shift;
	my ($is_peritonitis, $is_exit_site, $is_tunnel) = &query(qq{SELECT is_peritonitis, is_exit_site, is_tunnel FROM ptms_cases WHERE entry="$entry"});
	my $infection_type;
	$infection_type .= qq{peritonitis, } if $is_peritonitis == 1;
	$infection_type .= qq{exit site, } if $is_exit_site == 1;
	$infection_type .= qq{tunnel} if $is_tunnel == 1;
	while ($infection_type =~ /, $/) {
		$infection_type =~ s/, $//g;
	}
	$infection_type = ucfirst $infection_type;
	return $infection_type;
}
sub is_date_valid() {
	my $input = shift;
	return &fast(qq{SELECT SUBDATE('$input', INTERVAL 0 DAY)});
}
sub build_abx_bar() {
	my $abx_id = shift;
	if ($abx_id) {
		my ($date_start, $date_end, $date_stopped) = &query(qq{SELECT date_start, date_end, date_stopped FROM ptms_antibiotics WHERE entry="$abx_id"});
		my $date_current = &fast(qq{SELECT CURDATE()});
		my $final_end_date;
		my $final_bar_color;
		if (&fast(qq{SELECT DATEDIFF('$date_end', '$date_stopped')}) > 0) {
			$final_end_date = $date_stopped;
			$final_bar_color = "e5ecf3";
		} else {
			$final_end_date = $date_end;
			$final_bar_color = "99ee00";
		}
		my $total_duration = &fast(qq{SELECT DATEDIFF('$final_end_date', '$date_start')});
		my $total_passed = &fast(qq{SELECT DATEDIFF('$date_current', '$date_start')});
		my $total_to_go = &fast(qq{SELECT DATEDIFF('$final_end_date', '$date_current')});
		my $progress;
		if ($total_to_go < 0 or $total_duration < 1) {
			$progress = 100;
		} else {
			$progress = int(0.5 + (($total_passed / $total_duration)*100));
			if ($progress > 100) {
				$progress = 100;
			}
		}
		my $abx_bar = qq{<div style="border:1px solid #ccd2d9; height:5px; display:block; background-color:#ffffff;"><div style="width:$progress} . qq{\%; height:5px; display:block; background-color:#$final_bar_color} . qq{;"></div></div>};
		return ($abx_bar, $progress);
	}
}
sub view_case() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	my ($msgs, $cultures, $antibiotics, $triggers, $name_first, $name_last, $phn, $weight, $title, $patient_info, $next_step, $delete_button);
	$msgs .= qq{<div class="emp">$p{"message_error"}</div>} if $p{"message_error"} ne "";
	$msgs .= qq{<div class="suc">$p{"message_success"}</div>} if $p{"message_success"} ne "";
	my $ok_case = &fast(qq{SELECT entry FROM ptms_cases WHERE entry="$p{"case_id"}"});
	my $ok_patient = &fast(qq{SELECT entry FROM ptms_patients WHERE entry="$p{"patient_id"}"});
	my $render_page = 0;
	if ($ok_case eq "") {
		if ($ok_patient eq "") {
			return qq{
				$close_button
				<h2><img src="$path_htdocs/images/icon-update-small-blue.png" alt=""/> New case</h2>
				$msgs
				<div class="b p10bo">Please enter a patient's name or PHN or <a href="ajax.pl?token=$token&ref=$ref&do=add_patient_form" target="hbin">add a new patient</a>.</div>
				<div class="">
					<div class="float-r w730">
						<div class="itt"><input type="text" class="itt" id="ncpi" name="ncpi" value="" onkeyup="refresh_new_case_ajax(this.value);"/></div>
						<div class="hide" id="form_case_patient_selector_token">$token</div>
						<div class="hide" id="form_case_patient_selector_prev"></div>
						<div class="hide" id="form_case_patient_selector_ref">$ref</div>
					</div>
					<img src="$path_htdocs/images/img_ni_search.gif" alt="Search"/>
					<div class="clear-r"></div>
				</div>
				<div id="form_case_patient_selector" class="max300"></div>
				<div class="hide" id="form_case_patient_selector_searching"><div class="loading">Searching...</div></div>
				<div class="clear-l"></div>
				<img src="/images/blank.gif" width="1" height="1" alt="" onload="document.getElementById('ncpi').focus()"/>};
		} elsif ($ok_patient and &fast(qq{SELECT entry FROM ptms_cases WHERE patient="$ok_patient" AND outcome="Outstanding"})) {
			my ($cid, $cty, $ccr, $cmo) = &query(qq{SELECT entry, case_type, created, modified FROM ptms_cases WHERE patient="$ok_patient" AND outcome="Outstanding" ORDER BY entry DESC LIMIT 1});
			my $cit = &get_infection_type($cid);
			$ccr = &nice_time_interval($ccr);
			$cmo = &nice_time_interval($cmo);
			my ($pnf,$pnl,$phn) = &query(qq{SELECT name_first, name_last, phn FROM ptms_patients WHERE entry="$ok_patient"});
			return qq{
				$close_button
				<h2><img src="$path_htdocs/images/icon-update-small-blue.png" alt=""/> New case</h2>
				$msgs
				<div class="emp"><span class="b">The patient $pnf $pnl ($phn) already has an outstanding case that was last updated $cmo.</span> Patients can have only one outstanding case at a time.
				<div class="p10to"><a href="ajax.pl?token=$token&ref=$ref&do=edit_case_form&case_id=$cid" target="hbin" class="b">Manage case</a> | <a href="ajax.pl?token=$token&ref=$ref&do=add_case_form" target="hbin" class="b">choose another patient</a></div></div>
			};
		} elsif ($ok_patient) {
			$render_page = 1;
			$triggers = qq{
				<input type="hidden" name="patient_id" value="$ok_patient"/>
				<input type="hidden" name="do" value="add_case_save"/>
			};
			$title = "New case";
			$p{"form_case_created"} = &fast(qq{SELECT CURDATE()});
			$p{"form_case_infection_type"} = "Peritonitis";
			$p{"form_case_case_type"} = "De novo";
			$p{"form_case_closed_print"} = "Active";
			$p{"form_case_hospitalization_required"} = "No";
			$p{"form_case_hospitalization_location"} = "Royal Columbian Hospital";
			$p{"form_case_hospitalization_onset"} = "No";
			$p{"form_case_outcome"} = "Outstanding";
			$p{"form_case_home_visit"} = "Pending";
			$p{"form_case_follow_up_culture"} = "Pending";
			$p{"form_case_modified"} = "Right now";
			$p{"form_case_is_peritonitis"} = 1;
			$p{"form_case_is_exit_site"} = 0;
			$p{"form_case_is_tunnel"} = 0;
			$title = "New case";
			$cultures = qq{};
			$antibiotics = qq{};
			$p{"page_case_past_cases"} = qq{};
			$p{"page_case_past_cases_count"} = qq{0};
			my @cases = &query(qq{SELECT entry FROM ptms_cases WHERE patient="$ok_patient" ORDER BY created DESC});
			foreach my $case_id (@cases) {
				my %case_info = &queryh(qq{SELECT * FROM ptms_cases WHERE entry="$case_id"});
				my $case_type;
				if ($case_info{"is_peritonitis"} eq 1) {
					$case_type .= qq{peritonitis, };
				}
				if ($case_info{"is_exit_site"} eq 1) {
					$case_type .= qq{exit site, };
				}
				if ($case_info{"is_tunnel"} eq 1) {
					$case_type .= qq{tunnel, };
				}
				$case_type =~ s/, $//g;
				$case_type = ucfirst $case_type;
				my $case_onset_date = &nice_date($case_info{"created"});
				my $case_onset_interval = &nice_time_interval($case_info{"created"});
				my $case_cultures;
				my $case_antibiotics;
				my @case_cultures = &querymr(qq{SELECT pathogen_1, pathogen_2, pathogen_3, pathogen_4 FROM ptms_labs WHERE case_id="$case_id"});
				my @case_antibiotics = &query(qq{SELECT antibiotic FROM ptms_antibiotics WHERE case_id="$case_id"});
				foreach my $culture (@case_cultures) {
					my @culture = @$culture;
					foreach my $pathogen (@culture) {
						if ($pathogen ne "") {
							$case_cultures .= qq{$pathogen; };
						}
					}
				}
				$case_cultures =~ s/; $//g;
				foreach my $antibiotic (@case_antibiotics) {
					if ($antibiotic ne "") {
						$case_antibiotics .= qq{$antibiotic; };
					}
				}
				$case_antibiotics =~ s/; $//g;
				$case_info{"outcome"} = lc $case_info{"outcome"};
				$p{"page_case_past_cases_count"} = $p{"page_case_past_cases_count"} + 1;
				$p{"page_case_past_cases"} .= qq{
					<div class="p5bo">
						<div class="p5bo br-b">
							<div class="float-r"><a href="ajax.pl?token=$token&ref=$ref&do=edit_case_form&amp;case_id=$case_id" class="b" target="hbin">manage case</a></div>
							<div class="b">$case_type</div>
							<div class="sml">
								<div>
									<span class="gt">Presented</span> 
									<span class="b">$case_onset_interval</span> ($case_onset_date)
								</div>
								<div>
									<span class="gt">Culture</span> 
									<span class="">$case_cultures</span>
								</div>
								<div>
									<span class="gt">Antibiotics</span> 
									<span class="">$case_antibiotics</span>
								</div>
								<div>
									<span class="gt">Outcome</span>
									<span class="">$case_info{"outcome"}</span>
								</div>
							</div>
						</div>
					</div>
				};
			}
		}
	} elsif ($ok_case ne "") {
		&get_next_step($ok_case);
		$render_page = 1;
		$triggers = qq{
			<input type="hidden" name="case_id" value="$ok_case"/>
			<input type="hidden" name="do" value="edit_case_save"/>
		};
		$title = "Manage case";
		$delete_button = qq{<div class="float-r p2to"><a href="ajax.pl?token=$token&ref=$ref&do=delete_case_confirm&case_id=$ok_case" target="hbin" class="rcb"><span>Delete case</span></a></div>};
		my %h = &queryh(qq{SELECT entry, patient, is_peritonitis, is_exit_site, is_tunnel, initial_wbc, initial_pmn, case_type, hospitalization_required, hospitalization_location, hospitalization_onset, hospitalization_start_date, hospitalization_stop_date, outcome, home_visit, follow_up_culture, next_step, closed, comments, created, modified FROM ptms_cases WHERE entry="$ok_case"});
		foreach my $key (keys %h) {
			$p{"form_case_$key"} = $h{"$key"};
		}
		$p{"patient_id"} = $p{"form_case_patient"};
		$ok_patient = $p{"form_case_patient"};
		$p{"form_case_modified"} = &nice_time($p{"form_case_modified"});
		if ($p{"form_case_closed"} == 1) {
			$p{"form_case_closed_print"} = "Closed";
		} else {
			$p{"form_case_closed_print"} = "Active";
		}
		my @lab = &querymr(qq{SELECT entry, type, status, created, modified, pathogen_1, pathogen_2, pathogen_3, pathogen_4 FROM ptms_labs WHERE case_id="$ok_case"});
		foreach my $l (@lab) {
			my ($lid, $type, $stat, $crea, $upda, $p1, $p2, $p3, $p4) = @$l;
			$type = ucfirst $type;
			$stat =~ s/\d //g;
			$crea = &nice_time_interval($crea);
			$upda = &nice_time_interval($upda);
			$upda =~ s/ /&nbsp;/g;
			my $germ;			
			my @t = ($p1, $p2, $p3, $p4);
			foreach my $t (@t) {
				if ($t ne "") {
					$germ .= qq{<span class="b">$t</span>, };
				}
			}
			$germ =~ s/, $//g;
			$germ = qq{<span class="b">Results not available</span>} unless $germ;
			my $comments_lab = &comments_lab($lid);
			$cultures .= qq{
				<div>
					<div class="p5 bg-vlg">
						<div class="float-r"><a href="ajax.pl?token=$token&ref=$ref&do=edit_lab_form&lab_id=$lid" target="hbin" class="b">change</a></div>
						<div>$germ <span class="gt">($upda)</span> $comments_lab</div>
					</div>
				</div>};
		}
		my @abx = &querymr(qq{SELECT * FROM ptms_antibiotics WHERE case_id="$ok_case" ORDER BY date_stopped DESC});
		foreach my $a (@abx) {
			my ($abx_entry, $abx_case_id, $abx_antibiotic, $abx_basis_empiric, $abx_basis_final, $abx_route, $dose_amount_loading, $abx_dose_amount, $abx_dose_amount_units, $abx_dose_frequency, $abx_regimen_duration, $abx_date_start, $abx_date_end, $abx_date_stopped, $abx_comments, $abx_created, $abx_modified) = @$a;
			$abx_antibiotic = ucfirst $abx_antibiotic;
			$abx_date_start = &nice_date($abx_date_start);
			$abx_created = &nice_time_interval($abx_created);
			$abx_modified = &nice_time_interval($abx_modified);
			my $parse_abx_date_stopped = $abx_date_stopped; $parse_abx_date_stopped =~ s/\-//g;
			my $parse_abx_date_end = $abx_date_end; $parse_abx_date_end =~ s/\-//g;
			my $stop_notice;
			if ($parse_abx_date_stopped < $parse_abx_date_end) {
				$stop_notice = "&mdash;stopped";
			}
			my $abx_regimen_duration_print = qq{For $abx_regimen_duration days starting on $abx_date_start $stop_notice};
			$abx_regimen_duration_print = qq{Loading dose given on $abx_date_start $stop_notice} if $abx_regimen_duration == 1;
			my $abx_basis;
			if ($abx_basis_final == 1) {
				$abx_basis = "final";
			} elsif ($abx_basis_empiric == 1) {
				$abx_basis = "empiric";
			}
			my ($abx_bar, $abx_percent) = &build_abx_bar($abx_entry);
			my $stop_button = qq{ &nbsp; <a href="ajax.pl?token=$token&ref=$ref&do=edit_antibiotic_stop_save&case_id=$ok_case&abx_id=$abx_entry" target="hbin" class="b">stop</a>};
			if ($abx_percent eq "100") {
				$stop_button = "";
			}
			my $comments_abx = &comments_antibiotic($abx_entry);
			$antibiotics .= qq{
				<div class="">
					<div class="p5 bg-vlg">
						<div class="float-r"><a href="ajax.pl?token=$token&ref=$ref&do=edit_antibiotic_form&abx_id=$abx_entry" target="hbin" class="b">change</a>$stop_button</div>
						<div><span class="b">$abx_antibiotic, $abx_dose_amount $abx_dose_amount_units $abx_dose_frequency $abx_route</span> ($abx_basis) $comments_abx</div>
						<div class="sml">$abx_regimen_duration_print</div>
						<div>$abx_bar</div>
					</div>
				</div>};
		}
		$next_step = qq{<span class="ac-yellow">Next step: } . 
		&interpret_next_step($h{"next_step"}) . qq{</span>};
		$cultures = qq{
			<h4>Culture results</h4>
			<div class="mh120">
				$cultures
			</div>
			<div class="p5to p20bo"><img src="$path_htdocs/images/add.gif" alt=""/><a target="hbin" href="ajax.pl?token=$token&ref=$ref&do=add_lab_form&case_id=$ok_case">Add culture result</a></div>};
		$antibiotics = qq{
			<h4>Antibiotics given</h4>
			<div class="xh200">
				$antibiotics
			</div>
			<div class="p5to p20bo"><img src="$path_htdocs/images/add.gif" alt=""/><a href="ajax.pl?token=$token&ref=$ref&do=add_antibiotic_form&case_id=$ok_case" target="hbin">Add treatment</a></div>};
	}
	if ($ok_patient ne "") {	
		($name_first, $name_last, $phn, $weight) = &query(qq{SELECT name_first, name_last, phn, weight FROM ptms_patients WHERE entry="$ok_patient"});
		$p{"form_special_weight"} = $weight;
		$patient_info = qq{
			<tr>
				<td class="tl gt">Patient name</td>
				<td class="tl"><a href="ajax.pl?token=$token&ref=$ref&do=edit_patient_form&patient_id=$ok_patient" target="hbin"><span class="b">$name_last, $name_first</span></a> <span class="gt">PHN $phn</span></td>
			</tr>};
	}
	if ($render_page == 1) {
		my $form_case_hospitalization_onset_options = &build_select(
			$p{"form_case_hospitalization_onset"},
			"No",
			"Yes");
		my $form_case_case_type_options = &build_select(
			$p{"form_case_case_type"},
			"De novo",
			"Recurrent",
			"Relapsing",
			"Repeat",
			"Refractory",
			"Catheter-related");
		my $form_case_hospitalization_required_options = &build_select(
			$p{"form_case_hospitalization_required"},
			"No",
			"Yes");
		my $form_case_hospitalization_location_options = &build_select(
			$p{"form_case_hospitalization_location"},
			"Abbotsford Regional Hospital",
			"Burnaby General Hospital",
			"Chilliwack General Hospital",
			"Eagle Ridge Hospital",
			"Mission Memorial Hospital",
			"Peach Arch Hospital",
			"Ridge Meadows Hospital",
			"Royal Columbian Hospital",
			"Surrey Memorial Hospital",
			"Other");
		my $form_case_outcome_options = &build_select(
			$p{"form_case_outcome"},
			"Outstanding",
			"Resolution",
			"Relapsing infection",
			"Catheter removal",
			"Catheter removal and death",
			"Death");
		my $form_case_home_visit_options = &build_select(
			$p{"form_case_home_visit"},
			"Pending",
			"Completed",
			"Declined",
			"Not applicable");
		
		my $form_case_follow_up_culture_options = &build_select(
			$p{"form_case_follow_up_culture"},
			"Pending",
			"Received",
			"Declined",
			"Not applicable");
		$p{"form_case_is_peritonitis_checked"} = qq{checked="checked"} if $p{"form_case_is_peritonitis"} == 1;
		$p{"form_case_is_exit_site_checked"} = qq{checked="checked"} if $p{"form_case_is_exit_site"} == 1;
		$p{"form_case_is_tunnel_checked"} = qq{checked="checked"} if $p{"form_case_is_tunnel"} == 1;
		if ($p{"page_case_past_cases"} ne "") {
			$p{"page_case_past_cases"} = qq{<div class="p10 bg-vlg"><h4>Past cases</h4><div style="max-height:360px; overflow:auto; padding-right:10px;">} . $p{"page_case_past_cases"} . qq{</div><span class="gt">Total of } . $p{"page_case_past_cases_count"} . qq{ past cases found in the database.</span></div>};
		}
		my $form_case_hospitalization_info_div_def = "hide";
		if ($p{"form_case_hospitalization_required"} eq "Yes") {
			$form_case_hospitalization_info_div_def = "show";
		}
		my $form_case_hospitalization_start_date_default = &fast(qq{SELECT CURDATE()});
		my $active_update_info;
		if ($p{"form_case_modified"} ne "") {
			if ($p{"form_case_closed"} == 1) {
				$p{"form_case_closed_print"} = qq{<span class="ac-red">Closed case</span>};
			} else {
				$p{"form_case_closed_print"} = qq{<span class="ac-green">Active case</span>};
			}
			$active_update_info = qq{
				<div class="float-l p15to p5ro">$p{"form_case_closed_print"}</div>
				<div class="float-l p15to"><span class="ac-lg">updated $p{"form_case_modified"}</span></div>
			};
		}
		return qq{
			$close_button
			<div class="float-l p20ro"><h2><img src="$path_htdocs/images/icon-update-small-blue.png" alt=""/> $title</h2></div>
			$active_update_info
			<div class="clear-l"></div>
			$msgs
			<div class="float-l w50p">
				<div class="p10ro">
					<div>
						<form name="form_case" action="ajax.pl" target="hbin" method="post" accept-charset="utf-8">
							<input type="hidden" name="token" value="$token"/>
							<input type="hidden" name="ref" value="$ref"/>
							$triggers
							<table class="w100p">
								<tbody>
									$patient_info
									<tr>
										<td class="tl w120 gt">Presentation date</td>
										<td class="tl"><div class="itt w80"><input type="text" class="itt" name="form_case_created" value="$p{"form_case_created"}" onclick="displayDatePicker('form_case_created');"/></div></td>
									</tr><tr>
										<td class="tl gt">Case type</td>
										<td class="tl"><select name="form_case_case_type" onfocus="show_def()" onblur="hide_def()" id="form_case_case_type">
											$form_case_case_type_options
										</select></td>
									</tr><tr>
										<td class="tl gt">Infection type</td>
										<td class="tl">
											<div><input type="checkbox" name="form_case_is_peritonitis" id="form_case_is_peritonitis" value="1" $p{"form_case_is_peritonitis_checked"} /> 
											<label for="form_case_is_peritonitis">Peritonitis</label></div>
											<div><input type="checkbox" name="form_case_is_exit_site" id="form_case_is_exit_site" value="1" $p{"form_case_is_exit_site_checked"} /> 
											<label for="form_case_is_exit_site">Exit site</label></div>
											<div><input type="checkbox" name="form_case_is_tunnel" id="form_case_is_tunnel" value="1" $p{"form_case_is_tunnel_checked"} /> 
											<label for="form_case_is_tunnel">Tunnel</label></div>
										</td>
									</tr><tr>
										<td class="tl gt">Initial WBC count</td>
										<td class="tl"><div class="float-l"><div class="itt w50"><input type="text" class="itt" name="form_case_initial_wbc" value="$p{"form_case_initial_wbc"}"/></div></div><div class="float-l p2to p5lo">x 10<sup>6</sup>/L</div><div class="clear-l"></div></td>
									</tr><tr>
										<td class="tl gt">Initial \%PMN on diff</td>
										<td class="tl"><div class="float-l"><div class="itt w50"><input type="text" class="itt" name="form_case_initial_pmn" value="$p{"form_case_initial_pmn"}"/></div></div><div class="float-l p2to p5lo">\%</div><div class="clear-l"></div></td>
									</tr><tr>
										<td class="tl gt">Patient weight</td>
										<td class="tl"><div class="float-l"><div class="itt w50"><input type="text" class="itt" name="form_special_weight" value="$p{"form_special_weight"}"/></div></div><div class="float-l p2to p5lo">kilograms</div><div class="clear-l"></div></td>
									</tr><tr>
										<td class="tl gt">Onset in hospital</td>
										<td class="bl"><select name="form_case_hospitalization_onset">
											$form_case_hospitalization_onset_options
										</select></td>
									</tr><tr>
										<td class="tl gt">Hospitalized</td>
										<td class="tl">
											<select name="form_case_hospitalization_required" id="form_case_hospitalization_required" onchange="set_hospitalization();">
												$form_case_hospitalization_required_options
											</select>
											<div id="form_case_hospitalization_info_div" class="$form_case_hospitalization_info_div_def">
												<div class="p4bo">
													<div class="float-l gt w60 p3to">Location</div> 
													<select name="form_case_hospitalization_location" class="w180">
														$form_case_hospitalization_location_options
													</select>
												</div>
												<div class="p3bo">
													<div class="float-l gt w100">Admit date</div>
													<div class="itt w80"><input type="text" class="itt" id="form_case_hospitalization_start_date" name="form_case_hospitalization_start_date" value="$p{"form_case_hospitalization_start_date"}" onclick="displayDatePicker('form_case_hospitalization_start_date');"/></div>
													<div id="form_case_hospitalization_start_date_default" class="hide">$form_case_hospitalization_start_date_default</div>
												</div>
												<div>
													<div class="float-l gt w100">Discharge date</div>
													<div class="itt w80"><input type="text" class="itt" name="form_case_hospitalization_stop_date" value="$p{"form_case_hospitalization_stop_date"}" onclick="displayDatePicker('form_case_hospitalization_stop_date');"/></div>
												</div>
											</div>
										</td>
									</tr><tr>
										<td class="tl gt">Home visit</td>
										<td class="tl"><select name="form_case_home_visit">
											$form_case_home_visit_options
										</select></td>
									</tr><tr>
										<td class="tl gt">Follow-up culture</td>
										<td class="tl"><select name="form_case_follow_up_culture">
											$form_case_follow_up_culture_options
										</select></td>
									</tr><tr>
										<td class="tl gt">Outcome</td>
										<td class="tl"><select name="form_case_outcome">
											$form_case_outcome_options
										</select></td>
									</tr><tr>
										<td class="tl gt">Comments $comment_icon</td>
										<td class="tl"><div class="itt w100p"><textarea class="itt" name="form_case_comments" rows="3">$p{"form_case_comments"}</textarea></div></td>
									</tr>
								</tbody>
							</table>
							$delete_button<input type="submit" value="Save changes" onclick="clear_date_picker();"/><div class="clear-r"></div>
						</form>
					</div>
				</div>
			</div>
			<div class="float-l w50p">
				<div class="p10lo">
					<div>
						$p{"page_case_past_cases"}
						$cultures
						$antibiotics
						<div class="txt-red">$next_step</div>
					</div>
				</div>
			</div>
			<div class="clear-l"></div>
		};
	}
}
sub view_catheter() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	my ($msgs,$title);
	if ($p{"message_error"} ne "") {
		$msgs .= qq{<div class="emp">$p{"message_error"}</div>};
	}
	if ($p{"message_success"} ne "") {
		$msgs .= qq{<div class="suc">$p{"message_success"}</div>};
	}
	my $ok_patient = &fast(qq{SELECT entry FROM ptms_patients WHERE entry="$p{"patient_id"}"});
	my $ok_catheter = &fast(qq{SELECT entry FROM ptms_catheters WHERE entry="$p{"catheter_id"}"});
	my ($triggers, $delete_button);
	if ($ok_catheter ne "") {
		my %h = &queryh(qq{SELECT * FROM ptms_catheters WHERE entry="$p{"catheter_id"}"});
		foreach my $key (keys %h) {
			$p{"form_catheter_$key"} = $h{"$key"};
		}
		$ok_patient = $p{"form_catheter_patient_id"};
		$title = "Catheter information";
		$triggers = qq{
			<input type="hidden" name="do" value="edit_catheter_save"/>
			<input type="hidden" name="catheter_id" value="$ok_catheter"/>
		};
		$delete_button = qq{<div class="">&nbsp;</div><div class="tr"><a href="ajax.pl?token=$token&ref=$ref&do=delete_catheter_confirm&catheter_id=$p{"catheter_id"}" target="hbin" class="rcb"><span>Delete catheter information</span></a><div class="clear-l"></div></div>};
	} else {
		$title = "Add catheter information";
		$triggers = qq{
			<input type="hidden" name="do" value="add_catheter_save"/>
			<input type="hidden" name="patient_id" value="$ok_patient"/>
		};
		$p{"form_catheter_insertion_location"} = "Bedside" if $p{"form_catheter_insertion_location"} eq "";
		$p{"form_catheter_insertion_method"} = "Surgery" if $p{"form_catheter_insertion_method"} eq "";
		$p{"form_catheter_type"} = "Curled" if $p{"form_catheter_type"} eq "";
	}
	my ($name_first, $name_last, $phn) = &query(qq{SELECT name_first, name_last, phn FROM ptms_patients WHERE entry="$ok_patient"});
	my $form_catheter_insertion_location_options = &build_select(
		$p{"form_catheter_insertion_location"},
		"Bedside",
		"Operating room");
	my $form_catheter_insertion_method_options = &build_select(
		$p{"form_catheter_insertion_method"},
		"Blind insertion",
		"Peritoneoscope",
		"Surgery",
		"Other");
	my $form_catheter_type_options = &build_select(
		$p{"form_catheter_type"},
		"Curled",
		"Presternal",
		"Straight");
	my @usrs = &querymr(qq{SELECT entry, name_first, name_last, role FROM ptms_users WHERE role="Nephrologist" OR role="Surgeon" ORDER BY name_last ASC, name_first ASC});
	my $select_options_surgeons = qq{<option value="">(none)</option>};
	my $selected_surgeon;
	foreach my $d (@usrs) {
		my ($users_entry, $users_name_first, $users_name_last, $users_role) = @$d;
		if ($p{"form_catheter_surgeon"} eq $users_entry) {
			$selected_surgeon = qq{selected="selected"};
		} else {
			$selected_surgeon = "";
		}
		$select_options_surgeons .= qq{<option value="$users_entry" $selected_surgeon>Dr. $users_name_first $users_name_last</option>};
	}
	return qq{
		$close_button
		<h2><img src="$path_htdocs/images/icon-user-small.png" alt="" /> $title</h2>
		$msgs
		<form name="form_catheter" action="ajax.pl" target="hbin" method="post" accept-charset="utf-8">
			<input type="hidden" name="token" value="$token"/>
			<input type="hidden" name="ref" value="$ref"/>
			$triggers
			<div class="float-l w50p">
				<div class="pl0ro">
					<div>
						<div class="b p5bo">Patient information</div>
						<table class="w100p">
							<tbody>
								<tr>
									<td class="tl w100 gt">Patient name</td>
									<td class="tl">$name_last, $name_first</td>
								</tr><tr>
									<td class="tl w100 gt">PHN</td>
									<td class="tl">$phn</td>
								</tr>
							</tbody>
						</table>
						<div class="p50to">
							<img src="$path_htdocs/images/img_back_off.png" onclick="document.form_catheter.submit(); clear_date_picker();" onmouseover="this.src='$path_htdocs/images/img_back_on.png';" onmouseout="this.src='$path_htdocs/images/img_back_off.png';" onmousedown="this.src='$path_htdocs/images/img_back_press.png';" alt="save changes and return">
							<div class="p30lo p10to gt"> or <a href="ajax.pl?token=$token&ref=$ref&do=edit_patient_form&amp;patient_id=$ok_patient" target="hbin" onclick="clear_date_picker();">discard changes and return</a></div>
						</div>
					</div>
				</div>
			</div>
			<div class="float-l w50p">
				<div class="p10lo">
					<div>
						<div class="b p5bo">Catheter details</div>
						<table class="w100p">
							<tbody>
								<tr>
									<td class="tl w110 gt">Insertion location</td>
									<td class="tl">
										<select name="form_catheter_insertion_location" class="w100p">
											$form_catheter_insertion_location_options
										</select>
									</td>
								</tr><tr>
									<td class="tl w110 gt">Insertion method</td>
									<td class="tl">
										<select name="form_catheter_insertion_method" class="w100p">
											$form_catheter_insertion_method_options
										</select>
									</td>
								</tr><tr>
									<td class="tl w110 gt">Catheter type</td>
									<td class="tl">
										<select name="form_catheter_type" class="w100p">
											$form_catheter_type_options
										</td>
								</tr><tr>
									<td class="tl w110 gt">Surgeon</td>
									<td class="tl p5bo">
										<select name="form_catheter_surgeon" class="w100p">
											$select_options_surgeons
										</select>
									</td>
								</tr><tr>
									<td class="tl w110 gt">Insertion date</td>
									<td class="tl">
										<div class="float-l p5ro"><div class="itt w80"><input type="text" class="itt" name="form_catheter_insertion_date" value="$p{"form_catheter_insertion_date"}" onclick="displayDatePicker('form_catheter_insertion_date');"/></div></div><span class="gt">YYYY-MM-DD</span>
									</td>
								</tr><tr>
									<td class="tl w110 gt">Removal date</td>
									<td class="tl">
										<div class="float-l p5ro"><div class="itt w80"><input type="text" class="itt" name="form_catheter_removal_date" value="$p{"form_catheter_removal_date"}" onclick="displayDatePicker('form_catheter_removal_date');"/></div></div><span class="gt">YYYY-MM-DD</span>
									</td>
								</tr>
							</tbody>
						</table>
						$delete_button
					</div>
				</div>
			</div>
			<div class="clear-l"></div>
		</form>};
}
sub view_dialysis() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	my ($msgs,$title);
	if ($p{"message_error"} ne "") {
		$msgs .= qq{<div class="emp">$p{"message_error"}</div>};
	}
	if ($p{"message_success"} ne "") {
		$msgs .= qq{<div class="suc">$p{"message_success"}</div>};
	}
	my $ok_patient = &fast(qq{SELECT entry FROM ptms_patients WHERE entry="$p{"patient_id"}"});
	my $ok_dialysis = &fast(qq{SELECT entry FROM ptms_dialysis WHERE entry="$p{"dialysis_id"}"});
	my ($triggers, $delete_button);
	if ($ok_dialysis ne "") {
		my %h = &queryh(qq{SELECT * FROM ptms_dialysis WHERE entry="$p{"dialysis_id"}"});
		foreach my $key (keys %h) {
			$p{"form_dialysis_$key"} = $h{"$key"};
		}
		$ok_patient = $p{"form_dialysis_patient_id"};
		$title = "Dialysis information";
		$triggers = qq{
			<input type="hidden" name="do" value="edit_dialysis_save"/>
			<input type="hidden" name="dialysis_id" value="$ok_dialysis"/>
		};
		$delete_button = qq{<div class="">&nbsp;</div><div class="tr"><a href="ajax.pl?token=$token&ref=$ref&do=delete_dialysis_confirm&dialysis_id=$p{"dialysis_id"}" target="hbin" class="rcb"><span>Delete dialysis information</span></a><div class="clear-l"></div></div>};
	} else {
		$title = "Add dialysis information";
		$triggers = qq{
			<input type="hidden" name="do" value="add_dialysis_save"/>
			<input type="hidden" name="patient_id" value="$ok_patient"/>
		};
		$p{"form_dialysis_center"} = "RCH" if $p{"form_dialysis_center"} eq "";
		$p{"form_dialysis_type"} = "CCPD" if $p{"form_dialysis_type"} eq "";
	}
	my ($name_first, $name_last, $phn) = &query(qq{SELECT name_first, name_last, phn FROM ptms_patients WHERE entry="$ok_patient"});
	my $form_dialysis_center_options = &build_select(
		$p{"form_dialysis_center"},
		"ARH",
		"RCH");
	my $form_dialysis_type_options = &build_select(
		$p{"form_dialysis_type"},
		"CAPD",
		"CCPD");
	return qq{
		$close_button
		<h2><img src="$path_htdocs/images/icon-user-small.png" alt="" /> $title</h2>
		$msgs
		<form name="form_dialysis" action="ajax.pl" target="hbin" method="post" accept-charset="utf-8">
			<input type="hidden" name="token" value="$token"/>
			<input type="hidden" name="ref" value="$ref"/>
			$triggers
			<div class="float-l w50p">
				<div class="pl0ro">
					<div>
						<div class="b p5bo">Patient information</div>
						<table class="w100p">
							<tbody>
								<tr>
									<td class="tl w100 gt">Patient name</td>
									<td class="tl">$name_last, $name_first</td>
								</tr><tr>
									<td class="tl w100 gt">PHN</td>
									<td class="tl">$phn</td>
								</tr>
							</tbody>
						</table>
						<div class="p50to">
							<img src="$path_htdocs/images/img_back_off.png" onclick="document.form_dialysis.submit(); clear_date_picker();" onmouseover="this.src='$path_htdocs/images/img_back_on.png';" onmouseout="this.src='$path_htdocs/images/img_back_off.png';" onmousedown="this.src='$path_htdocs/images/img_back_press.png';" alt="save changes and return">
							<div class="p30lo p10to gt"> or <a href="ajax.pl?token=$token&ref=$ref&do=edit_patient_form&amp;patient_id=$ok_patient" target="hbin" onclick="clear_date_picker();">discard changes and return</a></div>
						</div>
					</div>
				</div>
			</div>
			<div class="float-l w50p">
				<div class="p10lo">
					<div>
						<div class="b p5bo">Dialysis details</div>
						<table class="w100p">
							<tbody>
								<tr>
									<td class="tl w90 gt">Dialysis centre</td>
									<td class="tl">
										<select name="form_dialysis_center" class="w100p">
											$form_dialysis_center_options
										</select>
									</td>
								</tr><tr>
									<td class="tl gt">Dialysis type</td>
									<td class="tl">
										<select name="form_dialysis_type" class="w100p">
											$form_dialysis_type_options
										</select>
									</td>
								</tr><tr>
									<td class="tl gt">Start date</td>
									<td class="tl">
										<div class="float-l p5ro"><div class="itt w80"><input type="text" class="itt" name="form_dialysis_start_date" value="$p{"form_dialysis_start_date"}" onclick="displayDatePicker('form_dialysis_start_date');"/></div></div><span class="gt">YYYY-MM-DD</span>
									</td>
								</tr><tr>
									<td class="tl gt">Stop date</td>
									<td class="tl">
										<div class="float-l p5ro"><div class="itt w80"><input type="text" class="itt" name="form_dialysis_stop_date" value="$p{"form_dialysis_stop_date"}" onclick="displayDatePicker('form_dialysis_stop_date');"/></div></div><span class="gt">YYYY-MM-DD</span>
									</td>
								</tr>
							</tbody>
						</table>
						$delete_button
					</div>
				</div>
			</div>
			<div class="clear-l"></div>
		</form>};
}
sub view_lab() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	my ($msgs,$title);
	if ($p{"message_error"} ne "") {
		$msgs .= qq{<div class="emp">$p{"message_error"}</div>};
	}
	if ($p{"message_success"} ne "") {
		$msgs .= qq{<div class="suc">$p{"message_success"}</div>};
	}
	my $ok_case = &fast(qq{SELECT entry FROM ptms_cases WHERE entry="$p{"case_id"}"});
	my $confirm_lab = &fast(qq{SELECT entry FROM ptms_labs WHERE entry="$p{"lab_id"}"});
	if ($ok_case eq "" and $confirm_lab eq "") {
		$title = "Add culture result";
		my @cases = &querymr(qq{SELECT ptms_cases.entry, ptms_cases.patient, ptms_cases.case_type, ptms_cases.outcome, ptms_cases.created, ptms_cases.modified, ptms_patients.name_first, ptms_patients.name_last, ptms_patients.phn FROM ptms_cases, ptms_patients WHERE ptms_cases.patient=ptms_patients.entry ORDER BY ptms_patients.name_last ASC, ptms_patients.name_first ASC, ptms_cases.outcome ASC, ptms_cases.modified DESC});
		my $cases = "";
		foreach my $c (@cases) {
			my $last_updated = &nice_time_interval(@$c[5]);
			my $case_status = ucfirst @$c[3];
			my $case_type = ucfirst @$c[2];
			my $infection_type = &get_infection_type(@$c[0]);
			$cases .= qq{
				<tr>
					<td class="pfmb_l">$case_status</td>
					<td class="pfmb_l"><a href="ajax.pl?token=$token&ref=$ref&do=edit_patient_form&amp;patient_id=@$c[1]" target="hbin">@$c[6] @$c[7]</a></td>
					<td class="pfmb_l">@$c[8]</td>
					<td class="pfmb_l">$case_type</td>
					<td class="pfmb_l">$infection_type</td>
					<td class="pfmb_l">$last_updated</td>
					<td class="pfmb_l"><a href="ajax.pl?token=$token&ref=$ref&do=add_lab_form&amp;case_id=@$c[0]" target="hbin" class="b">Add lab test</a></td>
				</tr>
			};
		}
		if ($cases eq "") {
			$cases = qq{<tr><td class="pfmb_l gt" colspan="7">No cases found.</td></tr>};
		}
		return qq{
			$close_button
			<h2>$title</h2>
			$msgs
			<div class="b">
				Please select a case from the list below or <a href="ajax.pl?token=$token&ref=$ref&do=add_case_form" target="hbin">enter a new case</a>. If the patient is not in this system, please <a href="ajax.pl?token=$token&ref=$ref&do=add_patient_form" target="hbin">enter the patient</a> first before proceeding to enter a new case or adding a lab test requisition to that case.
			</div>
			<div class="p10to">
				<div class="max400">
					<div>
						<table class="pfmt w100p">
							<tbody>
								<tr>
									<td class="pfmb_l b bg-dbp">Case status</td>
									<td class="pfmb_l b bg-dbp">Patient name</td>
									<td class="pfmb_l b bg-dbp">PHN</td>
									<td class="pfmb_l b bg-dbp">Case type</td>
									<td class="pfmb_l b bg-dbp">Infection type</td>
									<td class="pfmb_l b bg-dbp">Case updated</td>
									<td class="pfmb_l b bg-dbp">&nbsp;</td>
								</tr>
								$cases
							</tbody>
						</table>
					</div>
				</div>
			</div>
		};
	} else {
		my ($triggers, $name_first, $name_last, $phn, $case_type, $case_infection_type, $case_outcome, $case_created, $case_id, $delete_button);
		if ($confirm_lab ne "") {
			$title = "Culture result";
			my %h = &queryh(qq{SELECT * FROM ptms_labs WHERE entry="$p{"lab_id"}"});
			foreach my $key (keys %h) {
				$p{"form_labs_$key"} = $h{"$key"};
			}
			$triggers = qq{
				<input type="hidden" name="do" value="edit_lab_save"/>
				<input type="hidden" name="lab_id" value="$confirm_lab"/>
			};
			($name_first, $name_last, $phn, $case_id, $case_type, $case_outcome, $case_created) = &query(qq{SELECT ptms_patients.name_first, ptms_patients.name_last, ptms_patients.phn, ptms_cases.entry, ptms_cases.case_type, ptms_cases.outcome, ptms_cases.created FROM ptms_cases, ptms_patients WHERE ptms_cases.entry="$p{"form_labs_case_id"}" AND ptms_cases.patient=ptms_patients.entry});
			$case_infection_type = &get_infection_type($case_id);
			$ok_case = $p{"form_labs_case_id"};
			$delete_button = qq{<div class="">&nbsp;</div><div class="tr"><a href="ajax.pl?token=$token&ref=$ref&do=delete_lab_confirm&lab_id=$p{"lab_id"}" target="hbin" class="rcb"><span>Delete culture result</span></a><div class="clear-l"></div></div>};
		} elsif ($ok_case ne "") {
			$title = "Add culture result";
			$triggers = qq{
				<input type="hidden" name="do" value="add_lab_save"/>
				<input type="hidden" name="case_id" value="$ok_case"/>
			};
			($name_first, $name_last, $phn, $case_id, $case_type, $case_outcome, $case_created) = &query(qq{SELECT ptms_patients.name_first, ptms_patients.name_last, ptms_patients.phn, ptms_cases.entry, ptms_cases.case_type, ptms_cases.outcome, ptms_cases.created FROM ptms_cases, ptms_patients WHERE ptms_cases.entry="$ok_case" AND ptms_cases.patient=ptms_patients.entry});
			$p{"form_labs_type"} = "Peritoneal dialysis fluid" if $p{"form_labs_type"} eq "";
			$case_infection_type = &get_infection_type($case_id);
		}
		if ($p{"form_labs_ordered"} eq "") {
			$p{"form_labs_ordered"} = &fast(qq{SELECT CURDATE()});
		}
		my $time_modified = $p{"form_labs_modified"};
		if ($time_modified ne "") {
			$time_modified = &nice_time($time_modified);
		} else {
			$time_modified = "Right now";
		}
		my $form_labs_pathogen_matrix;
		my $form_labs_pathogen_matrix_count = 1;
		while ($form_labs_pathogen_matrix_count < 5) {
			my $number = $form_labs_pathogen_matrix_count;
			my $form_labs_results_type_options = &build_select(
				$p{"form_labs_result_$number\_type"},
				";;(select stage)",
				"Preliminary",
				"Final");
			my $form_labs_pathogen_options = &build_select(
				$p{"form_labs_pathogen_$number"},
				";;(select pathogen)",
				"(no culture taken)",
				"Preliminary: Gram +ve coccus",
				"Preliminary: Gram +ve bacillus",
				"Preliminary: Gram -ve coccus",
				"Preliminary: Acid fast bacillus",
				"Preliminary: Yeast",
				"Preliminary: Multiple",
				"Preliminary: Other",
				"Preliminary: Culture negative",
				"Final: (Gram +ve) Corynebacteria species",
				"Final: (Gram +ve) Clostridium species",
				"Final: (Gram +ve) Diptheroids",
				"Final: (Gram +ve) Enterococcus species",
				"Final: (Gram +ve) Propionibacterium",
				"Final: (Gram +ve) Lactobacillus",
				"Final: (Gram +ve) Staphylococcus aureus (sensitivity unknown)",
				"Final: (Gram +ve) Staphylococcus aureus (MSSA)",
				"Final: (Gram +ve) Staphylococcus aureus (MRSA)",
				"Final: (Gram +ve) Staphylococcus epidermidis",
				"Final: (Gram +ve) Staphylococcus species",
				"Final: (Gram +ve) Staphylococcus species, coagulase negative",
				"Final: (Gram +ve) Streptococcus species",
				"Final: (Gram +ve) Gram positive organisms, other",
				"Final: (Gram -ve) Acinetobacter species",
				"Final: (Gram -ve) Citrobacter species",
				"Final: (Gram -ve) Enterobacter species",
				"Final: (Gram -ve) Escherichia coli",
				"Final: (Gram -ve) Klebsiella species",
				"Final: (Gram -ve) Neisseria species",
				"Final: (Gram -ve) Proteus mirabilis",
				"Final: (Gram -ve) Pseudomonas species",
				"Final: (Gram -ve) Serratia marcescens",
				"Final: (Gram -ve) Gram negative organisms, other",
				"Final: Mycobacterium tuberculosis",
				"Final: (Yeast) Candida species",
				"Final: (Yeast) Other species",
				"Final: Anaerobes",
				"Final: Multiple",
				"Final: Other",
				"Final: Culture negative");
			$form_labs_pathogen_matrix .= qq{
				<tr>
					<td class="tl" colspan="2">
						<select name="form_labs_pathogen_$number" id="form_labs_pathogen_$number" class="w100p" onchange="set_pathogens('$number');">
							$form_labs_pathogen_options
						</select>
						<div id="form_labs_pathogen_$number\_other_div" class="hide">
							<div class="p5to p10bo">
								<div class="float-l b p5ro">Specify</div>
								<div class="float-l">
									<div class="itt w300"><input type="text" name="form_labs_pathogen_$number\_other" id="form_labs_pathogen_$number\_other" class="itt"></div>
								</div>
								<div class="clear-l"></div>
							</div>
						</div>
					</td>
				</tr>};
			$form_labs_pathogen_matrix_count++;
		}
		$case_created = &nice_time($case_created);
		my $form_labs_type_options = &build_select(
			$p{"form_labs_type"},
			"Peritoneal dialysis fluid",
			"Swab of exit site",
			"Blood culture");
		return qq{
			$close_button
			<h2><img src="$path_htdocs/images/img_culture.png" alt="" /> $title</h2>
			$msgs
			<form name="form_labs" action="ajax.pl" target="hbin" method="post" accept-charset="utf-8">
				<input type="hidden" name="token" value="$token"/>
				<input type="hidden" name="ref" value="$ref"/>
				$triggers
				<div class="float-l w50p">
					<div class="pl0ro">
						<div>
							<div class="b p5bo">Case information</div>
							<table class="w100p">
								<tbody>
									<tr>
										<td class="tl w100 gt">Patient name</td>
										<td class="tl">$name_last, $name_first</td>
									</tr><tr>
										<td class="tl w100 gt">PHN</td>
										<td class="tl">$phn</td>
									</tr><tr>
										<td class="tl w100 gt">Case&nbsp;details</td>
										<td class="tl">
											Opened: <span class="b">$case_created</span>
											<br/>Case type: <span class="b">$case_type</span>
											<br/>Infection: <span class="b">$case_infection_type</span>
											<br/>Current status: <span class="b">$case_outcome</span>
										</td>
									</tr>
								</tbody>
							</table>
							<div class="p50to">
								<img src="$path_htdocs/images/img_back_off.png" onclick="document.form_labs.submit(); clear_date_picker();" onmouseover="this.src='$path_htdocs/images/img_back_on.png';" onmouseout="this.src='$path_htdocs/images/img_back_off.png';" onmousedown="this.src='$path_htdocs/images/img_back_press.png';" alt="save changes and return">
								<div class="p30lo p10to gt"> or <a href="ajax.pl?token=$token&ref=$ref&do=edit_case_form&amp;case_id=$ok_case" target="hbin" onclick="clear_date_picker();">discard changes and return</a></div>
							</div>
						</div>
					</div>
				</div>
				<div class="float-l w50p">
					<div class="p10lo">
						<div>
							<div class="b p5bo">Culture details</div>
							<table class="w100p">
								<tbody>
									<tr>
										<td class="tl w100 gt">Date ordered</td>
										<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_labs_ordered" value="$p{"form_labs_ordered"}"  onclick="displayDatePicker('form_labs_ordered');" /></div></td>
									</tr><tr>
										<td class="tl gt">Sample type</td>
										<td class="tl p5bo"><select name="form_labs_type" class="w100p">
											$form_labs_type_options
										</select></td>
									</tr><tr>
										<td class="tl gt">Comments $comment_icon</td>
										<td class="tl"><div class="itt w100p"><textarea class="itt" name="form_labs_comments" rows="5">$p{"form_labs_comments"}</textarea></div></td>
									</tr><tr>
										<td class="tl gt">Last updated</td>
										<td class="tl">$time_modified</td>
									</tr><tr>
										<td class="tl" colspan="2"><div class="b p10to p5bo">Culture results</div></td>
									</tr>
										$form_labs_pathogen_matrix
								</tbody>
							</table>
							$delete_button
						</div>
					</div>
				</div>
				<div class="clear-l"></div>
			</form>};
	}
}
sub view_antibiotic() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	my ($msgs, $title, $print_page, $triggers, $name_first, $name_last, $phn, $weight, $case_type, $case_infection_type, $case_outcome, $case_created, $patient_id, $delete_button);
	$msgs .= qq{<div class="emp">$p{"message_error"}</div>} if ($p{"message_error"} ne "");
	$msgs .= qq{<div class="suc">$p{"message_success"}</div>} if ($p{"message_success"} ne "");
	my $ok_abx = &fast(qq{SELECT entry FROM ptms_antibiotics WHERE entry="$p{"abx_id"}"});
	my $ok_case;
	if ($ok_abx eq "") {
		$ok_case = &fast(qq{SELECT entry FROM ptms_cases WHERE entry="$p{"case_id"}"});
		if ($ok_case eq "") {
			my $cases;
			my @cases = &querymr(qq{SELECT ptms_cases.entry, ptms_cases.patient, ptms_cases.case_type, ptms_cases.outcome, ptms_cases.created, ptms_cases.modified, ptms_patients.name_first, ptms_patients.name_last, ptms_patients.phn FROM ptms_cases, ptms_patients WHERE ptms_cases.patient=ptms_patients.entry ORDER BY ptms_patients.name_last ASC, ptms_patients.name_first ASC, ptms_cases.outcome ASC, ptms_cases.modified DESC});
			foreach my $c (@cases) {
				my $infection_type = &get_infection_type(@$c[0]);
				my $last_updated = &nice_time_interval(@$c[5]);
				my $case_status = ucfirst @$c[3];
				my $case_type = ucfirst @$c[2];
				$cases .= qq{
					<tr>
						<td class="pfmb_l">$case_status</td>
						<td class="pfmb_l"><a href="ajax.pl?token=$token&ref=$ref&do=edit_patient_form&amp;patient_id=@$c[1]" target="hbin">@$c[6] @$c[7]</a></td>
						<td class="pfmb_l">@$c[8]</td>
						<td class="pfmb_l">$case_type</td>
						<td class="pfmb_l">$infection_type</td>
						<td class="pfmb_l">$last_updated</td>
						<td class="pfmb_l"><a href="ajax.pl?token=$token&ref=$ref&do=add_antibiotic_form&amp;case_id=@$c[0]" target="hbin" class="b">Add antibiotic treatment</a></td>
					</tr>
				};
			}
			$cases = qq{<tr><td class="pfmb_l gt" colspan="7">No cases found.</td></tr>} if ($cases eq "");
			return qq{
				$close_button
				<h2>Add antibiotic treatment</h2>
				$msgs
				<div class="b">Please select a case from the list below or <a href="ajax.pl?token=$token&ref=$ref&do=add_case_form" target="hbin">enter a new case</a>. If the patient is not in this system, please <a href="ajax.pl?token=$token&ref=$ref&do=add_patient_form" target="hbin">enter the patient</a> first before proceeding to enter a new case or adding a lab test requisition or antibiotic treatment to that case.</div>
				<div class="p10to">
					<div class="max400">
						<table class="pfmt w100p">
							<tbody>
								<tr>
									<td class="pfmb_l b bg-dbp">Case status</td>
									<td class="pfmb_l b bg-dbp">Patient name</td>
									<td class="pfmb_l b bg-dbp">PHN</td>
									<td class="pfmb_l b bg-dbp">Case type</td>
									<td class="pfmb_l b bg-dbp">Infection type</td>
									<td class="pfmb_l b bg-dbp">Case updated</td>
									<td class="pfmb_l b bg-dbp">&nbsp;</td>
								</tr>
								$cases
							</tbody>
						</table>
					</div>
				</div>
			};
		} else {
			$title = "Add antibiotic treatment";
			$triggers = qq{
				<input type="hidden" name="do" value="add_antibiotic_save"/>
				<input type="hidden" name="case_id" value="$ok_case"/>
			};
			$print_page = 1;
		}
	} else {
		$title = "Antibiotic treatment";
		$triggers = qq{
			<input type="hidden" name="do" value="edit_antibiotic_save"/>
			<input type="hidden" name="abx_id" value="$ok_abx"/>
		};
		$print_page = 1;
		my %h = &queryh(qq{SELECT * FROM ptms_antibiotics WHERE entry="$ok_abx"});
		foreach my $key (keys %h) {
			$p{"form_abx_$key"} = $h{"$key"};
		}
		$ok_case = &fast(qq{SELECT case_id FROM ptms_antibiotics WHERE entry="$ok_abx"});
		$delete_button = qq{<div class="tr"><a href="ajax.pl?token=$token&ref=$ref&do=delete_abx_confirm&abx_id=$ok_abx" target="hbin" class="">Delete antibiotic treatment</a></div>};
	}
	if ($print_page == 1) {
		$print_page = 1;
		($patient_id, $name_first, $name_last, $phn, $weight, $case_type, $case_outcome, $case_created) = &query(qq{SELECT ptms_patients.entry, ptms_patients.name_first, ptms_patients.name_last, ptms_patients.phn, ptms_patients.weight, ptms_cases.case_type, ptms_cases.outcome, ptms_cases.created FROM ptms_cases, ptms_patients WHERE ptms_cases.entry="$ok_case" AND ptms_cases.patient=ptms_patients.entry});
		my $weight_label = qq{not tracked};
		if ($weight > 0) {
			$weight_label = qq{&nbsp;kg};
		}
		$case_infection_type = &get_infection_type($ok_case);
		$case_created = &nice_time($case_created);
		my @labs = &querymr(qq{SELECT pathogen_1, pathogen_2, pathogen_3, pathogen_4 FROM ptms_labs WHERE case_id="$ok_case"});
		my $rp;
		foreach my $germs (@labs) {
			foreach my $germ (@$germs) {
				if ($germ) {
					$rp .= qq{$germ<br/>};
				}
			}
		}
		$rp = qq{<span class="gt">(none reported)</span>} if $rp eq "";
		my $time_ordered = $p{"form_abx_ordered"};
		my $time_modified = $p{"form_abx_modified"};
		if ($time_ordered ne "") {
			$time_ordered = &nice_time($time_ordered);
		} else {
			$time_ordered = "Right now";
		}
		if ($time_modified ne "") {
			$time_modified = &nice_time($time_modified);
		} else {
			$time_modified = "Right now";
		}
		$p{"form_abx_date_start"} = &fast(qq{SELECT CURDATE()}) if $p{"form_abx_date_start"} eq "";
		my $form_abx_basis_display;
		if ($p{"form_abx_basis_empiric"} == 1) {
			$p{"form_abx_basis_empiric"} = qq{checked};
		} else {
			$p{"form_abx_basis_empiric"} = qq{};
		}
		if ($p{"form_abx_basis_final"} == 1) {
			$p{"form_abx_basis_final"} = qq{checked};
		} else {
			$p{"form_abx_basis_final"} = qq{};
		}
		if ($p{"form_abx_basis_empiric"} ne "checked" and $p{"form_abx_basis_final"} ne "checked") {
			$p{"form_abx_basis_empiric"} = qq{checked};
			$p{"form_abx_basis_final"} = qq{};
		}
		if ($p{"form_abx_dose_amount_units"} eq "") {
			$p{"form_abx_dose_amount_units"} = "g";
		}
		$form_abx_basis_display = qq{<input type="checkbox" name="form_abx_basis_empiric" id="form_abx_basis_empiric" value="1" $p{"form_abx_basis_empiric"}/><label for="form_abx_basis_empiric"> empiric &nbsp;</label> <input type="checkbox" name="form_abx_basis_final" id="form_abx_basis_final" value="1" $p{"form_abx_basis_final"}/><label for="form_abx_basis_final"> final &nbsp;</label>};
		my @abx_selection = (
			"Ampicillin",
			"Cefazolin",
			"Ceftazidime",
			"Ceftriaxone",
			"Ciprofloxacin",
			"Fluconazole",
			"Gentamicin",
			"Meropenem",
			"Mycafungin",
			"Rifampin",
			"Tobramycin",
			"Trimethoprim Sulfamethoxazole",
			"Vancomycin",
			"Other");
		my $abx_loading;
		foreach my $abx (@abx_selection) {
			my $l = 0;
			if (&fast(qq{SELECT entry FROM ptms_antibiotics WHERE case_id="$ok_case" AND antibiotic="$abx" AND regimen_duration="1" LIMIT 1}) ne "") {
				$abx_loading .= qq{<div class="hide" id="loading_dose_$abx">1</div>};
			} else {
				$abx_loading .= qq{<div class="hide" id="loading_dose_$abx">0</div>};
			}
		}
		my $form_abx_antibiotic_options = &build_select(
			$p{"form_abx_antibiotic"},
			";;(select an antibiotic)",
			@abx_selection);
		my $form_abx_dose_amount_units_options = &build_select(
			$p{"form_abx_dose_amount_units"},
			"g",
			"mg");
		my $form_abx_dose_frequency_options = &build_select(
			$p{"form_abx_dose_frequency"},
			"Q6H",
			"Q8H",
			"Q12H",
			"QD",
			"Q2D",
			"Q3D",
			"Q4D",
			"Q5D");
		my $form_abx_route_options = &build_select(
			$p{"form_abx_route"},
			"IP",
			"PO",
			"IV",
			"IM",
			"Topical",
			"Intranasal",
			"Intratunnel");
		my $form_abx_regimen_duration_options = &build_select(
			qq{$p{"form_abx_regimen_duration"};;days},
			"1;;1 day",
			"2;;2 days",
			"3;;3 days",
			"4;;4 days",
			"5;;5 days",
			"6;;6 days",
			"7;;7 days",
			"8;;8 days",
			"9;;9 days",
			"10;;10 days",
			"11;;11 days",
			"12;;12 days",
			"13;;13 days",
			"14;;14 days",
			"15;;15 days",
			"21;;21 days",
			"28;;28 days");
		my $capd = &fast(qq{SELECT dialysis_type FROM ptms_patients WHERE entry="$patient_id"});
		if ($capd eq "CAPD") {
			$capd = "1";
		} else {
			$capd = "0";
		}
		return qq{
			$close_button
			<h2><img src="$path_htdocs/images/img_antibiotics.png" alt="" /> $title</h2>
			$msgs
			<form name="form_abx" action="ajax.pl" target="hbin" method="post" accept-charset="utf-8">
				<input type="hidden" name="token" value="$token"/>
				<input type="hidden" name="ref" value="$ref"/>
				<input type="hidden" name="case_id" value="$ok_case"/>
				<div class="hide" id="is_capd">$capd</div>
				$triggers
				<div class="float-l w50p">
					<div class="p10ro">
						<div>
							<div class="b p5bo">Case information</div>
							<table>
								<tbody>
									<tr>
										<td class="tl gt p20ro">Patient&nbsp;name</td>
										<td class="tl">$name_first $name_last</td>
									</tr><tr>
										<td class="tl gt p20ro">PHN</td>
										<td class="tl">$phn</td>
									</tr><tr>
										<td class="tl gt p20ro">Weight</td>
										<td class="tl"><div class="float-l" id="form_abx_weight">$weight</div>$weight_label</td>
									</tr><tr>
										<td class="tl gt p20ro">Case&nbsp;details</td>
										<td class="tl">
											<div><span class="gt">Onset:</span> <span class="b">$case_created</span></div>
											<div><span class="gt">Case type:</span> <span class="b">$case_type</span></div>
											<div><span class="gt">Infection:</span> <span class="b">$case_infection_type</span></div>
											<div><span class="gt">Current status:</span> <span class="b">$case_outcome</span></div>
										</td>
									</tr><tr>
										<td class="tl gt p20ro">Pathogens</td>
										<td class="tl">$rp</td>
									</tr>
								</tbody>
							</table>
							<div class="p50to">
								<img src="$path_htdocs/images/img_back_off.png" onclick="document.form_abx.submit(); clear_date_picker();" onmouseover="this.src='$path_htdocs/images/img_back_on.png';" onmouseout="this.src='$path_htdocs/images/img_back_off.png';" onmousedown="this.src='$path_htdocs/images/img_back_press.png';" alt="save changes and return">
								<div class="p30lo p10to gt"> or <a href="ajax.pl?token=$token&ref=$ref&do=edit_case_form&amp;case_id=$ok_case" target="hbin" onclick="clear_date_picker();">discard changes and return</a></div>
							</div>
						</div>
					</div>
				</div>
				<div class="float-l w50p">
					<div class="p10lo">
						<div>
							<div class="b p5bo">Treatment</div>
							<table class="w100p">
								<tbody>
									<tr>
										<td class="tl w100 gt">Antibiotic</td>
										<td class="tl">
											<select name="form_abx_antibiotic" class="w100p" id="form_abx_antibiotic" onchange="set_antibiotics();">
												$form_abx_antibiotic_options
											</select>
											<div id="form_abx_antibiotic_other_div" class="hide">
												<div class="p5to">
													<div class="float-l b p5ro">Specify</div>
													<div class="float-l">
														<div class="itt w200"><input type="text" name="form_abx_antibiotic_other" id="form_abx_antibiotic_other" class="itt"></div>
													</div>
													<div class="clear-l"></div>
												</div>
											</div>
										</td>
									</tr><tr>
										<td class="tl gt">Basis</td>
										<td class="tl">$form_abx_basis_display</td>
									</tr><tr>
										<td class="tl gt">Loading dose</td>
										<td class="tl"><div class="float-l"><div class="itt w40"><input type="text" class="itt" name="form_abx_dose_amount_loading" id="form_abx_dose_amount_loading" value="$p{"form_abx_dose_amount_loading"}"/></div></div> &nbsp;
											<select name="form_abx_dose_amount_units" id="form_abx_dose_amount_units" onchange="set_dose_units();">
												$form_abx_dose_amount_units_options
											</select> </td>
									</tr><tr>
										<td class="tl gt">Dose and route</td>
										<td class="tl">
											<div class="float-l"><div class="itt w40"><input type="text" class="itt" name="form_abx_dose_amount" id="form_abx_dose_amount" value="$p{"form_abx_dose_amount"}"/></div></div> &nbsp; <span class="" id="form_abx_dose_label">$p{"form_abx_dose_amount_units"}</span>
											<select name="form_abx_dose_frequency" id="form_abx_dose_frequency">
												$form_abx_dose_frequency_options
											</select> 
											<select name="form_abx_route" id="form_abx_route" class="w60">
												$form_abx_route_options
											</select>
											<div class="clear-l"></div>
										</td>
									</tr><tr>
										<td class="tl gt">Start date</td>
										<td class="tl">
											<div class="float-l">
												<div class="itt w80"><input type="text" class="itt" name="form_abx_date_start" id="form_abx_date_start" value="$p{"form_abx_date_start"}" onclick="displayDatePicker('form_abx_date_start');"/></div>
											</div>
											<div class="float-l p5lo p5ro gt">duration set to</div>
											<div class="float-l">
												<select name="form_abx_regimen_duration" id="form_abx_regimen_duration" onchange="set_duration()" class="w80">
												$form_abx_regimen_duration_options
												</select>
												$abx_loading
												<div class="hide" id="form_abx_regimen_token">$token</div>
												<div class="hide" id="form_abx_regimen_ref">$ref</div>
											</div>
										</td>
									</tr><tr>
										<td class="tl gt">Stop date</td>
										<td class="tl"><div class="itt w80"><input type="text" class="itt" name="form_abx_date_stopped" id="form_abx_date_stopped" value="$p{"form_abx_date_stopped"}" onclick="displayDatePicker('form_abx_date_stopped');"/></div><div id="url_test"></div></td>
									</tr><tr>
										<td class="tl gt">Comments $comment_icon</td>
										<td class="tl"><div class="itt w100p"><textarea class="itt" name="form_abx_comments" rows="5">$p{"form_abx_comments"}</textarea></div><span style="color: #ffffff;">Hello World</span></td>
									</tr>
								</tbody>
							</table>
							$delete_button
						</div>
					</div>
				</div>
				<div class="clear-l"></div>
			</form>};
	}
}
sub view_patient() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	my @data;
	my $triggers = qq{<input type="hidden" name="do" value="add_patient_save"/>};
	my $pnam = qq{New patient};
	my $msgs;
	if ($p{"message_error"} ne "") {
		$msgs .= qq{<div class="emp">$p{"message_error"}</div>};
	}
	if ($p{"message_success"} ne "") {
		$msgs .= qq{<div class="suc">$p{"message_success"}</div>};
	}
	my $add_catheter_link;
	my $add_dialysis_link;
	my $catheter_information;
	my $dialysis_information;
	$p{"patient_id"} = &fast(qq{SELECT entry FROM ptms_patients WHERE entry="$p{'patient_id'}"});
	if (($p{"patient_id"} ne "") and (($p{"do"} eq "edit_patient_form") or ($p{"do"} eq "edit_patient_save"))) {
		my %h = &queryh(qq{SELECT * FROM ptms_patients WHERE entry="$p{"patient_id"}"});
		$triggers = qq{
			<input type="hidden" name="patient_id" value="$p{"patient_id"}"/>
			<input type="hidden" name="do" value="edit_patient_save"/>
		};
		$pnam = qq{$h{'name_last'}, $h{'name_first'}};
		foreach my $key (keys %h) {
			$p{"form_patients_$key"} = $h{"$key"};
		}
		$catheter_information = qq{<h4>Catheter information</h4>};
		$dialysis_information = qq{<h4>Dialysis information</h4>};
		$add_catheter_link = qq{<div class="p5to p20bo"><img src="$path_htdocs/images/add.gif" alt=""/><a target="hbin" href="ajax.pl?token=$token&ref=$ref&do=add_catheter_form&patient_id=$p{"patient_id"}">Add catheter information</a></div>};
		$add_dialysis_link = qq{<div class="p5to p20bo"><img src="$path_htdocs/images/add.gif" alt=""/><a target="hbin" href="ajax.pl?token=$token&ref=$ref&do=add_dialysis_form&patient_id=$p{"patient_id"}">Add peritoneal dialysis information</a></div>};
		my @catheter_information = &querymr(qq{SELECT entry, type, insertion_date, removal_date FROM ptms_catheters WHERE patient_id="$p{'patient_id'}"});
		foreach my $catheter (@catheter_information) {
			my $catheter_id = @$catheter[0];
			my $catheter_type = @$catheter[1];
			my $catheter_insertion_date = @$catheter[2];
			my $catheter_removal_date = @$catheter[3];
			my $insertion_removal_information;
			if ($catheter_insertion_date ne "") {
				$catheter_insertion_date = &nice_date($catheter_insertion_date);
				$insertion_removal_information .= qq{inserted on $catheter_insertion_date};
			}
			if ($catheter_removal_date ne "") {
				$catheter_removal_date = &nice_date($catheter_removal_date);
				if ($insertion_removal_information ne "") {
					$insertion_removal_information .= qq{, removed on $catheter_removal_date};
				} else {
					$insertion_removal_information .= qq{removed on $catheter_removal_date};
				}
			}
			$catheter_information .= qq{
				<div>
					<div class="p5 bg-vlg">
						<div class="float-r"><a href="ajax.pl?token=$token&ref=$ref&do=edit_catheter_form&catheter_id=$catheter_id" target="hbin" class="b">change</a></div>
						<div><span class="b">$catheter_type catheter</span> <span class="gt">$insertion_removal_information</span></div>
					</div>
				</div>};
		}
		my @dialysis_information = &querymr(qq{SELECT entry, center, type, start_date, stop_date FROM ptms_dialysis WHERE patient_id="$p{'patient_id'}"});
		foreach my $dialysis (@dialysis_information) {
			my $dialysis_id = @$dialysis[0];
			my $dialysis_center = @$dialysis[1];
			my $dialysis_type = @$dialysis[2];
			my $dialysis_start_date = @$dialysis[3];
			my $dialysis_stop_date = @$dialysis[4];
			my $start_stop_information;
			if ($dialysis_start_date ne "") {
				$dialysis_start_date = &nice_date($dialysis_start_date);
				$start_stop_information .= qq{started on $dialysis_start_date};
			}
			if ($dialysis_stop_date ne "") {
				$dialysis_stop_date = &nice_date($dialysis_stop_date);
				if ($start_stop_information ne "") {
					$start_stop_information .= qq{, stopped on $dialysis_stop_date};
				} else {
					$start_stop_information .= qq{stopped on $dialysis_stop_date};
				}
			}
			$dialysis_information .= qq{
				<div>
					<div class="p5 bg-vlg">
						<div class="float-r"><a href="ajax.pl?token=$token&ref=$ref&do=edit_dialysis_form&dialysis_id=$dialysis_id" target="hbin" class="b">change</a></div>
						<div><span class="b">$dialysis_type at $dialysis_center</span> <span class="gt">$start_stop_information</span></div>
					</div>
				</div>};
		}
	} else {
		$p{"form_patients_email_reminder"} = &display_checkboxes($p{"form_patients_email_reminder"});
		$p{"form_patients_gender"} = "Male";
		$p{"form_patients_dialysis_center"} = "RCH";
		$p{"form_patients_dialysis_type"} = "CCPD";
		$p{"form_patients_catheter_insertion_location"} = "Bedside";
		$p{"form_patients_catheter_insertion_method"} = "Surgery";
		$p{"form_patients_catheter_type"} = "Curled";
	}
	my $select_options_nephrologists = qq{<option value="">(none)</option>};
	my $select_options_pd_nurses = qq{<option value="">(none)</option>};
	my $select_options_surgeons = qq{<option value="">(none)</option>};
	my @usrs = &querymr(qq{SELECT entry, name_first, name_last, role FROM ptms_users ORDER BY name_last ASC, name_first ASC});
	foreach my $d (@usrs) {
		my ($users_entry, $users_name_first, $users_name_last, $users_role) = @$d;
		my ($selected_surgeon, $selected_nephrologist, $selected_pd_nurse);
		my $name = "$users_name_first $users_name_last";
		if ($users_role eq "Nephrologist" or $users_role eq "Surgeon") {
			$name = "Dr. $name";
			if ($p{"form_patients_nephrologist"} eq $users_entry) {
				$selected_nephrologist = qq{selected="selected"};
			}
			if ($p{"form_patients_surgeon"} eq $users_entry) {
				$selected_surgeon = qq{selected="selected"};
			}
			$select_options_nephrologists .= qq{<option value="$users_entry" $selected_nephrologist>$name</option>};
			$select_options_surgeons .= qq{<option value="$users_entry" $selected_surgeon>$name</option>};
		} elsif ($users_role eq "PD Nurse") {
			if ($p{"form_patients_primary_nurse"} eq $users_entry) {
				$selected_pd_nurse = qq{selected="selected"};
			}
			$select_options_pd_nurses .= qq{<option value="$users_entry" $selected_pd_nurse>$name</option>};
		}
	}
	my $form_patients_gender_options = &build_select(
		$p{"form_patients_gender"},
		"Female",
		"Male");
	my $form_patients_dialysis_center_options = &build_select(
		$p{"form_patients_dialysis_center"},
		"ARH",
		"RCH");
	my $form_patients_dialysis_type_options = &build_select(
		$p{"form_patients_dialysis_type"},
		"CAPD",
		"CCPD");
	my $form_patients_catheter_insertion_location_options = &build_select(
		$p{"form_patients_catheter_insertion_location"},
		"Bedside",
		"Operating room");
	my $form_patients_catheter_insertion_method_options = &build_select(
		$p{"form_patients_catheter_insertion_method"},
		"Blind insertion",
		"Peritoneoscope",
		"Surgery",
		"Other");
	my $form_patients_catheter_type_options = &build_select(
		$p{"form_patients_catheter_type"},
		"Curled",
		"Presternal",
		"Straight");
	if ($p{"form_patients_pd_start_date"} eq "") {
		$p{"form_patients_pd_start_date"} = &fast(qq{SELECT CURDATE()});
	}
	$p{"form_patients_disease_diabetes"} = &display_checkboxes($p{"form_patients_disease_diabetes"});
	$p{"form_patients_disease_cognitive"} = &display_checkboxes($p{"form_patients_disease_cognitive"});
	$p{"form_patients_disease_psychosocial"} = &display_checkboxes($p{"form_patients_disease_psychosocial"});
	return qq{
		$close_button
		<h2><img src="$path_htdocs/images/icon-user-small.png" alt=""/> $pnam</h2>
		$msgs
		<form name="form_patients" action="ajax.pl" target="hbin" method="post" accept-charset="utf-8">
			<input type="hidden" name="token" value="$token"/>
			<input type="hidden" name="ref" value="$ref"/>
		<div class="float-l w50p">
			<div class="p10ro">
				<div>
					<h4>Personal information</h4>
					<table class="w100p">
						<tbody>
							<tr>
								<td class="tl w110 gt">First name $required_io</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_name_first" value="$p{"form_patients_name_first"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">Last name $required_io</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_name_last" value="$p{"form_patients_name_last"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">PHN $required_io</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_phn" value="$p{"form_patients_phn"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">Phone (home)</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_phone_home" value="$p{"form_patients_phone_home"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">Phone (work)</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_phone_work" value="$p{"form_patients_phone_work"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">Phone (mobile)</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_phone_mobile" value="$p{"form_patients_phone_mobile"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">Email</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_email" value="$p{"form_patients_email"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">&nbsp;</td>
								<td class="tl"><div class="p5bo"><input type="checkbox" name="form_patients_email_reminder" id="form_patients_email_reminder" value="1" $p{"form_patients_email_reminder"}/><label for="form_patients_email_reminder"> send reminders to this address</label></div></td>
							</tr><tr>
								<td class="tl w110 gt">Weight (kg)</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_weight" value="$p{"form_patients_weight"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">Date of birth</td>
								<td class="tl">
									<div class="itt w100p"><input type="text" class="itt" name="form_patients_date_of_birth" value="$p{"form_patients_date_of_birth"}" onclick="displayDatePicker('form_patients_date_of_birth');"/></div>
								</td>
							</tr><tr>
								<td class="tl w110 gt">Gender</td>
								<td class="tl">
									<select name="form_patients_gender" class="w100p">
										$form_patients_gender_options
									</select>
								</td>
							</tr>
						</tbody>
					</table>
					<div class="p15to"><h4>Medical history</h4></div>
					<table class="w100p">
						<tbody>
							<tr>
								<td class="tl w110 gt">Allergies</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_allergies" value="$p{"form_patients_allergies"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">Co-morbidities</td>
								<td class="tl">
									<div class=""><input type="checkbox" name="form_patients_disease_diabetes" id="form_patients_disease_diabetes" value="1" $p{"form_patients_disease_diabetes"}/><label for="form_patients_disease_diabetes"> diabetes</label></div>
									<div class=""><input type="checkbox" name="form_patients_disease_cognitive" id="form_patients_disease_cognitive" value="1" $p{"form_patients_disease_cognitive"}/><label for="form_patients_disease_cognitive"> cognitive impairment</label></div>
									<div class=""><input type="checkbox" name="form_patients_disease_psychosocial" id="form_patients_disease_psychosocial" value="1" $p{"form_patients_disease_psychosocial"}/><label for="form_patients_disease_psychosocial"> psychosocial issues</label></div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>
		<div class="float-l w50p">
			<div class="p10lo">
				<div>
					$catheter_information
					$add_catheter_link
					$dialysis_information
					$add_dialysis_link
					<table class="w100p">
						<tbody>
							<tr>
								<td class="tl w110 gt">Primary nurse $required_io</td>
								<td class="tl">
									<select name="form_patients_primary_nurse" class="w100p">
										$select_options_pd_nurses
									</select>
								</td>
							</tr><tr>
								<td class="tl w110 gt">Nephrologist $required_io</td>
								<td class="tl p5bo">
									<select name="form_patients_nephrologist" class="w100p">
										$select_options_nephrologists
									</select>
								</td>
							</tr><tr>
								<td class="tl w110 gt">Comments $comment_icon</td>
								<td class="tl"><div class="itt w100p"><textarea class="itt" name="form_patients_comments" rows="5">$p{"form_patients_comments"}</textarea></div></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>
		<div class="clear-l"></div>
		<div class="p20to">
			<div class="float-r">
				$triggers
				<input type="submit" value="Save changes" onclick="clear_date_picker();"/> 
			</div>
			<div class="gt">$required_io indicates required fields</div>
			<div class="clear-l"></div>
		</div>
		</form>
	};
}
sub view_account_settings() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	my $is_administrator = &fast(qq{SELECT type FROM ptms_users WHERE entry="$sid[2]"});
	my $target_is_administrator = &fast(qq{SELECT type FROM ptms_users WHERE entry="$p{"uid"}"});
	my $triggers = qq{<input type="hidden" name="do" value="edit_account_settings"/>};
	my $title = qq{Your account};
	my $return;
	my @data;
	my $msgs;
	if (
			($p{"uid"} eq "") or 
			($p{"uid"} =~ /\D/) or 
			($sid[2] ne $p{"uid"} and $is_administrator ne "Administrator") or 
			($sid[2] ne $p{"uid"} and $target_is_administrator eq "Administrator")) {
				$p{"uid"} = $sid[2];
	}
	if ($p{"uid"} ne $sid[2]) {
		$title = qq{Modify account};
		$return = qq{<div class="p2to"><a href="ajax.pl?token=$token&ref=$ref&do=edit_manage_users_form" target="hbin" class="b">&laquo; return to manage users</a></div>};
	}
	if ($p{"message_error"} ne "") {
		$msgs .= qq{<div class="emp">$p{"message_error"}</div>};
	}
	if ($p{"message_success"} ne "") {
		$msgs .= qq{<div class="suc">$p{"message_success"}</div>};
	}
	my %h = &queryh(qq{SELECT * FROM ptms_users WHERE entry="$p{"uid"}"});
	foreach my $key (keys %h) {
		$p{"form_users_$key"} = $h{"$key"};
	}
	$p{"form_users_created"} = &nice_time($p{"form_users_created"});
	$p{"form_users_modified"} = &nice_time($p{"form_users_modified"});
	$p{"form_users_opt_in"} = &display_checkboxes($p{"form_users_opt_in"});
	my $form_users_role_print = $p{"form_users_role"};
	if ($is_administrator eq "Administrator") {
		my $form_users_role_options = &build_select(
			$p{"form_users_role"},
			"Nephrologist",
			"PD Nurse",
			"Surgeon",
			"Other");
		$form_users_role_print = qq{
			<select name="form_users_role">
				$form_users_role_options
			</select>};
	}
	my $change_password;
	if ($sid[2] eq $p{"uid"}) {
		$change_password = qq{<div class="float-l w40p">
			<div class="p10to p10lo">
				<div>
					<form name="form_account_settings_password" action="ajax.pl" target="hbin" method="post" accept-charset="utf-8">
						<input type="hidden" name="token" value="$token"/>
						<input type="hidden" name="do" value="edit_account_settings_save_password"/>
						<input type="hidden" name="ref" value="$ref"/>
						<div class="b p5bo">Update password</div>
						<div class="gt sml p10bo">Please note that passwords are case sensitive.</div>
						<table class="w100p">
							<tbody>
								<tr>
									<td class="tl gt w120">Existing password</td>
									<td class="tl"><div class="itt w100p"><input type="password" class="itt" name="form_users_password_old" value=""/></div></td>
								</tr><tr>
									<td class="tl gt">New password</td>
									<td class="tl"><div class="itt w100p"><input type="password" class="itt" name="form_users_password" value=""/></div></td>
								</tr><tr>
									<td class="tl gt">Repeat password</td>
									<td class="tl p5bo"><div class="itt w100p"><input type="password" class="itt" name="form_users_password_repeat" value=""/></div></td>
								</tr><tr>
									<td class="tl gt">&nbsp;</td>
									<td class="tr">
										<input type="submit" value="Save changes" onclick="clear_date_picker();"/>
									</td>
							</tbody>
						</table>
					</form>
				</div>
			</div>
		</div>};
	}
	return qq{
		$close_button
		<h2><img src="$path_htdocs/images/img_ni_my_profile.gif" alt="" /> $title</h2>
		$msgs
		<div class="float-l w60p">
			<div class="p10ro">
				<div class="p10 bg-vlg">
					<div>
						<form name="form_account_settings_user_info" action="ajax.pl" target="hbin" method="post" accept-charset="utf-8">
							<input type="hidden" name="token" value="$token"/>
							<input type="hidden" name="ref" value="$ref"/>
							<input type="hidden" name="uid" value="$p{"uid"}"/>
							<input type="hidden" name="do" value="edit_account_settings_save_user_info"/>
							<div class="b p5bo">User information</div>
							<table class="w100p">
								<tbody>
									<tr>
										<td class="tl gt w100">First name $required_io</td>
										<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_users_name_first" value="$p{"form_users_name_first"}"/></div></td>
									</tr><tr>
										<td class="tl gt">Last name $required_io</td>
										<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_users_name_last" value="$p{"form_users_name_last"}"/></div></td>
									</tr><tr>
										<td class="tl gt">Email (login) $required_io</td>
										<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_users_email" value="$p{"form_users_email"}"/></div></td>
									</tr><tr>
										<td class="tl gt">Notifications</td>
										<td class="tl b"><input type="checkbox" name="form_users_opt_in" id="form_users_opt_in" value="1" $p{"form_users_opt_in"} /> 
											<label for="form_users_opt_in">cc this email when reminders are sent to patients</label></td>
									</tr><tr>
										<td class="tl gt">Role</td>
										<td class="tl">$form_users_role_print</td>
									</tr><tr>
										<td class="tl gt">Account type</td>
										<td class="tl b">$p{"form_users_type"}</td>
									</tr><tr>
										<td class="tl gt">Created</td>
										<td class="tl">$p{"form_users_created"}</td>
									</tr><tr>
										<td class="tl gt">Modified</td>
										<td class="tl">$p{"form_users_modified"}</td>
									</tr><tr>
										<td class="tl" colspan="2">
											<div class="float-r"><input type="submit" value="Save changes" onclick="clear_date_picker();"/></div>
										$return
										<div class="clear-r"></div>
										</td>
									</tr>
								</tbody>
							</table>
						</form>
					</div>
				</div>
			</div>
		</div>
		$change_password
		<div class="clear-l"></div>
	};
}
sub view_manage_users() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	my $msgs;
	if ($p{"message_error"} ne "") {
		$msgs .= qq{<div class="emp">$p{"message_error"}</div>};
	}
	if ($p{"message_success"} ne "") {
		$msgs .= qq{<div class="suc">$p{"message_success"}</div>};
	}
	my $check_administrator = &fast(qq{SELECT entry FROM ptms_users WHERE entry="$sid[2]" AND type="Administrator"});
	if ($check_administrator ne "") {
		my @users = &querymr(qq{SELECT * FROM ptms_users ORDER BY name_last ASC, name_first ASC, entry ASC});
		my $table;
		my $rc = "bg-vlg";
		foreach my $u (@users) {
			my ($user_entry, $user_type, $user_email, $user_password, $user_name_first, $user_name_last, $user_role, $user_deactivated, $user_opt_in, $user_created, $user_modified, $user_accessed) = @$u;
			my ($you, $tasks, $name_print);
			if ($user_entry eq $sid[2]) {
				$you = qq{&mdash;<span class="b">you</span>};
				$tasks .= qq{<a href="ajax.pl?token=$token&ref=$ref&do=edit_account_settings_form" target="hbin" class="b">account settings</a> };
			}
			if ($user_deactivated == 0) {
				$user_deactivated = qq{<span class="txt-gre b">active</span>};
				unless ($user_type eq "Administrator" or $user_entry eq $sid[2]) {
					$tasks .= qq{<a href="ajax.pl?token=$token&ref=$ref&do=deactivate&uid=$user_entry" target="hbin">deactivate</a> &nbsp; };
				}
			} else {
				$user_deactivated = qq{<span class="txt-red b">deactivated</span>};
				$tasks .= qq{<a href="ajax.pl?token=$token&ref=$ref&do=reactivate&uid=$user_entry" target="hbin">reactivate</a> &nbsp; };
			}
			if ($user_type eq "Administrator") {
				$name_print = qq{<span class="b">$user_name_last</span>, $user_name_first};
				$user_type = qq{<span class="b">(admin)</span>};
			} else {
				$name_print = qq{<a href="ajax.pl?token=$token&ref=$ref&do=edit_account_settings_form&uid=$user_entry" target="hbin"><span class="b">$user_name_last</span>, $user_name_first</a>};
				$tasks .= qq{<a href="ajax.pl?token=$token&ref=$ref&do=make_administrator&uid=$user_entry" target="hbin">make admin</a>};
				$user_type = "";
				
			}
			if ($tasks eq "") {
				$tasks = qq{<span class="gt">(none)</span>};
			}
			$table .= qq{
				<tr class="$rc">
					<td class="pfmb_l w160">$name_print  $you $user_type</td>
					<td class="pfmb_l w220">$user_email</td>
					<td class="pfmb_l w80">$user_role</td>
					<td class="pfmb_l w80">$user_deactivated</td>
					<td class="pfmb_l">$tasks</td>
				</tr>
			};			
			if ($rc eq "") {
				$rc = "bg-vlg";
			} else {
				$rc = "";
			}
		}
		return qq{
			$close_button
			<h2><img src="$path_htdocs/images/img_ni_my_profile.gif" alt="" /> Manage users</h2>
			$msgs
			<table class="pfmt w100p">
				<tbody>
					<tr>
						<td class="pfmb_l b bg-dbp w160">Name</td>
						<td class="pfmb_l b bg-dbp w220">Email</td>
						<td class="pfmb_l b bg-dbp w80">Role</td>
						<td class="pfmb_l b bg-dbp w80">Status</td>
						<td class="pfmb_l b bg-dbp">Tasks</td>
					</tr>
				</tbody>
			</table><div style="max-height:400px; overflow:auto;"><table class="pfmt w100p">
				<tbody>
					$table
				</tbody>
			</table></div>
			<div class="tr p5"><img src="$path_htdocs/images/add.gif" alt=""/><a class="b" target="hbin" href="ajax.pl?token=$token&ref=$ref&do=add_user_form">Add new user</a></div>
		};
	}
}
sub add_user_form() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	my $msgs;
	if ($p{"message_error"} ne "") {
		$msgs .= qq{<div class="emp">$p{"message_error"}</div>};
	}
	if ($p{"message_success"} ne "") {
		$msgs .= qq{<div class="suc">$p{"message_success"}</div>};
	}
	$p{"form_new_user_type"} = "Regular" if $p{"form_new_user_type"} eq "";
	$p{"form_new_user_role"} = "PD Nurse" if $p{"form_new_user_role"} eq "";
	$p{"form_new_user_password"} = lc substr(&encrypt(rand()),0,6) if $p{"form_new_user_password"} eq "";
	my $form_new_user_type_options = &build_select(
		$p{"form_new_user_type"},
		"Regular",
		"Administrator");
	my $form_new_user_role_options = &build_select(
		$p{"form_new_user_role"},
		"Nephrologist",
		"PD Nurse",
		"Surgeon",
		"Other");
	return qq{
		$close_button
		<h2><img src="$path_htdocs/images/img_ni_my_profile.gif" alt="" /> Add new user</h2>
		$msgs
		<form name="form_add_user" action="ajax.pl" target="hbin" method="post" accept-charset="utf-8">
			<input type="hidden" name="token" value="$token"/>
			<input type="hidden" name="ref" value="$ref"/>
			<input type="hidden" name="do" value="add_user_save"/>
			<div class="float-l w60p">
				<div class="p10ro">
					<div>
						<table class="w100p">
							<tbody>
								<tr>
									<td class="tl gt w100">First name $required_io</td>
									<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_new_user_name_first" value="$p{"form_new_user_name_first"}"/></div></td>
								</tr><tr>
									<td class="tl gt">Last name $required_io</td>
									<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_new_user_name_last" value="$p{"form_new_user_name_last"}"/></div></td>
								</tr><tr>
									<td class="tl gt">Email address $required_io</td>
									<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_new_user_email" value="$p{"form_new_user_email"}"/></div></td>
								</tr><tr>
										<td class="tl gt">Notifications</td>
										<td class="tl b"><input type="checkbox" name="form_new_user_opt_in" id="form_new_user_opt_in" value="1" checked /> 
											<label for="form_new_user_opt_in">cc this email when reminders are sent to patients</label></td>
									</tr><tr>
									<td class="tl gt">Password $required_io</td>
									<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_new_user_password" value="$p{"form_new_user_password"}"/></div>
									<div class="sml gt">Please provide a temporary password for this user.</div></td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
			<div class="float-l w40p">
				<div class="p10lo">
					<div>
						<table class="w100p">
							<tbody>
								<tr>
									<td class="tl gt w100">User type $required_io</td>
									<td class="tl">
										<select name="form_new_user_type" class="w100p">
											$form_new_user_type_options
										</select>
									</td>
								</tr><tr>
									<td class="tl gt">Role $required_io</td>
									<td class="tl">
										<select name="form_new_user_role" class="w100p">
											$form_new_user_role_options
										</select>
									</td>
								</tr><tr>
									<td class="tl gt">&nbsp;</td>
									<td class="tr p10to"><input type="submit" value="Save changes" onclick="clear_date_picker();"/> </td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
			<div class="clear-l"></div>
		</form>
	};
}
sub get_time() {
	my $time = &fast(qq{SELECT DATE_FORMAT(CURRENT_TIMESTAMP(),'%M %D, %Y  %h:%i %p');});
	$time =~ s/  /\&nbsp\; /g;
	$time =~ s/ 0//g;
	return $time;
}
sub get_alerts_dismissed() {
	my $uid = $sid[2];
	my @alerts = &querymr(qq{SELECT entry, alert_entry, alert_type, uid, pid, cid, lid, tid, show_after, archive_uid, archive_comment, archive_date FROM ptms_alerts_archive WHERE uid IS NULL OR uid="$uid" ORDER BY archive_date DESC});
	my %alert_codes = (
		"5" => "Please reconsider the Tobramycin or Gentamicin dose for this patient, as it may be too high.",
		"10" => "Please reconsider the Vancomycin dose for this patient, it is below the recommended minimum of 20 mg/kg.",
		"15" => "This patient is on fluconazole. Please consider drug interactions including statins.",
		"20" => "This patient has MRSA. Please review this patient's antibiotics to ensure that it is appropriate for this organism.",
		"30" => "This patient has a fungal infection. Peritoneal dialysis catheter should ideally removed within 24 hours. <a href=\"http://www.pdiconnect.com/cgi/content/abstract/31/1/60?etoc\" target=\"blank\">view reference</a>",
		"90" => "Please consider fluconazole prophylaxis for this patient.",
		"110" => "Preliminary culture results not arrived.",
		"120" => "Final culture results not arrived.",
		"200" => "Preliminary culture results updated",
		"210" => "Final culture results updated"
	);
	my $output = $close_button . qq{<h2>Dismissed alerts</h2><div style="max-height:400px; overflow:auto;">};
	foreach my $a (@alerts) {
		my ($entry, $alert_entry, $alert_type, $uid, $pid, $cid, $lid, $tid, $show_after, $archive_uid, $archive_comment, $archive_date) = @$a;
		my $alert_text = $alert_codes{$alert_type};
		my $nice_time_interval = &nice_time_interval($archive_date);
		my $dismiss_by_text;
		my ($patient_name_first, $patient_name_last) = &query(qq{SELECT name_first, name_last FROM ptms_patients WHERE entry="$pid" LIMIT 1});
		my $patient_information = qq{<a href="ajax.pl?token=$token&do=edit_patient_form&patient_id=$pid" target="hbin" class="b">$patient_name_last, $patient_name_first</a>};
		if ($archive_uid ne "") {
			my ($name_first, $name_last) = &query(qq{SELECT name_first, name_last FROM ptms_users WHERE entry="$archive_uid"});
			if ($archive_comment eq "") {
				$archive_comment = qq{(none given)};
			}
			$dismiss_by_text = qq{<div class="sml gt">Dismissed $nice_time_interval by <span class="b">$name_first $name_last</span>. Reason: &quot;$archive_comment&quot;</div>};
		} else {
			$dismiss_by_text = qq{<div class="sml gt">Dismissed $nice_time_interval by the system</div>};
		}
		$output .= qq{
			<div class="emp">
				$patient_information &nbsp; $alert_text
				$dismiss_by_text
			</div>};
	}
	$output .= qq{</div>};
	return $output;
}
sub get_alerts() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	my $uid = $sid[2];
	&generate_alerts();
	my @alerts = &querymr(qq{SELECT * FROM ptms_alerts WHERE (uid="$uid" OR uid IS NULL) AND show_after < CURRENT_TIMESTAMP() ORDER BY alert_type ASC});
	my $output;
	foreach my $alert (@alerts) {
		my ($aid, $type, $uid, $pid, $cid, $lid, $tid, $show_after) = @$alert;
		my ($name_first,$name_last) = &query(qq{SELECT name_first, name_last FROM ptms_patients WHERE entry="$pid"});
		my $community = qq{<img src="$path_htdocs/images/img_community.gif" alt="Community alert" class="float-r"/>};
		my $button = qq{
			<div class="show" id="alert_dismiss_box_$aid">
				<a href="ajax.pl?token=$token&ref=$ref&do=edit_case_form&case_id=$cid" target="hbin" class="">attend</a> &nbsp; 
				<a href="$path_htdocs/images/blank.gif" target="hbin" class="" onclick="dismiss_provide_reason('$aid');">dismiss</a>
			</div>
			<div class="hide" id="alert_dismiss_reason_box_$aid">
				<div class="p10to bt">Reason</div>
				<form name="dismiss_form_for_$aid" id="dismiss_form_for_$aid" action="ajax.pl" target="hbin" method="post" accept-charset="utf-8">
					<input type="hidden" name="token" value="$token"/>
					<input type="hidden" name="ref" value="$ref"/>
					<input type="hidden" name="do" value="dismiss"/>
					<input type="hidden" name="aid" value="$aid"/>
					<div class="itt w100p"><textarea name="dismiss_reason" class="itt" rows="3"></textarea></div>
					<div class="p5to tr"><input type="submit" value="Dismiss"/> &nbsp; 
					<a href="$path_htdocs/images/blank.gif" target="hbin" class="" onclick="cancel_dismiss('$aid');">cancel</a></div>
				</form>
			</div>
			};
		if ($uid ne "") {
			$community = "";
			$button = qq{
			<div>
				<a href="ajax.pl?token=$token&ref=$ref&do=edit_case_form&case_id=$cid" target="hbin" class="">attend</a> &nbsp; 
				<a href="ajax.pl?token=$token&ref=$ref&do=dismiss&aid=$aid" target="hbin" class="">dismiss</a>
			</div>};
		}
		if ($type eq "5") {
			$output .= qq{
				<div class="emp">
					$community
					<div class="b">$name_first $name_last</div>
					<div>Please reconsider the Tobramycin or Gentamicin dose for this patient, as it may be too high.</div>
					$button
				</div>};
		} elsif ($type eq "10") {
			$output .= qq{
				<div class="emp">
					$community
					<div class="b">$name_first $name_last</div>
					<div>Please reconsider the Vancomycin dose for this patient, it is below the recommended minimum of 20 mg/kg.</div>
					$button
				</div>};
		} elsif ($type eq "15") {
			$output .= qq{
				<div class="emp">
					$community
					<div class="b">$name_first $name_last</div>
					<div>This patient is on fluconazole. Please consider drug interactions including statins.</div>
					$button
				</div>};
		} elsif ($type eq "20") {
			$output .= qq{
				<div class="emp">
					$community
					<div class="b">$name_first $name_last</div>
					<div>This patient has MRSA. Please review this patient's antibiotics to ensure that it is appropriate for this organism.</div>
					$button
				</div>};
		} elsif ($type eq "30") {
			$output .= qq{
				<div class="emp">
					$community
					<div class="b">$name_first $name_last</div>
					<div>This patient has a fungal infection. Peritoneal dialysis catheter should ideally removed within 24 hours. <a href=\"http://www.pdiconnect.com/cgi/content/abstract/31/1/60?etoc\" target=\"blank\">view reference</a></div>
					$button
				</div>};
		} elsif ($type eq "90") {
			$output .= qq{
				<div class="emp">
					$community
					<div class="b">$name_first $name_last</div>
					<div>Please consider fluconazole prophylaxis for this patient.</div>
					$button
				</div>};
		} elsif ($type eq "110") {
			my $lab_created = &fast(qq{SELECT ordered FROM ptms_labs WHERE entry="$lid"});
			my $lab_created_nice = &nice_time($lab_created);
			my $lab_created_interval = &nice_time_interval($lab_created);
			$output .= qq{
				<div class="emp">
					$community
					<div class="b">$name_first $name_last</div>
					<div>Preliminary culture results not arrived (requisition sent $lab_created_interval on $lab_created_nice)</div>
					$button
				</div>};
		} elsif ($type eq "120") {
			my $lab_updated = &fast(qq{SELECT ordered FROM ptms_labs WHERE entry="$lid"});
			my $lab_updated_nice = &nice_time($lab_updated);
			my $lab_updated_interval = &nice_time_interval($lab_updated);
			$output .= qq{
				<div class="emp">
					$community
					<div class="b">$name_first $name_last</div>
					<div>Final culture results not arrived (requisition sent $lab_updated_interval on $lab_updated_nice)</div>
					$button
				</div>};
		} elsif ($type eq "200") {
			my $lab_updated = &fast(qq{SELECT modified FROM ptms_labs WHERE entry="$lid"});
			my $lab_updated_nice = &nice_time($lab_updated);
			my $lab_updated_interval = &nice_time_interval($lab_updated);
			$output .= qq{
				<div class="suc">
					$community
					<div class="b">$name_first $name_last</div>
					<div>Preliminary culture results updated $lab_updated_interval ($lab_updated_nice)</div>
					$button
				</div>};
		} elsif ($type eq "210") {
			my $lab_updated = &fast(qq{SELECT modified FROM ptms_labs WHERE entry="$lid"});
			my $lab_updated_nice = &nice_time($lab_updated);
			my $lab_updated_interval = &nice_time_interval($lab_updated);
			$output .= qq{
				<div class="suc">
					$community
					<div class="b">$name_first $name_last</div>
					<div>Final culture results updated $lab_updated_interval ($lab_updated_nice)</div>
					$button
				</div>};
		} else {
			$output .= qq{
				<div class="fph">
					$community
					<div class="b">$name_first $name_last</div>
					<div>Telephone follow-up recommended this patient.</div>
					$button
				</div>};
		}
	}
	if ($output eq "") {
		$output = qq{<div class="fph">You have no alerts at this time.</div>};
	}
	return $output;
}
sub archive_and_delete_alerts() {
	my $query = shift;	
	my @entries = &query($query);
	foreach my $entry (@entries) {
		&archive_alert($entry);
		&input(qq{DELETE FROM ptms_alerts WHERE entry="$entry"});
	}
}
sub archive_alert() {
	my ($alert_id, $archive_uid, $archive_comment) = @_;
	my $archive_alert_id = &input(qq{INSERT INTO ptms_alerts_archive (alert_entry, alert_type, uid, pid, cid, lid, tid, show_after) SELECT entry, alert_type, uid, pid, cid, lid, tid, show_after FROM ptms_alerts WHERE entry="$alert_id"});
	if ($archive_alert_id ne "") {
		&input(qq{UPDATE ptms_alerts_archive SET archive_date = CURRENT_TIMESTAMP() WHERE entry="$archive_alert_id"});
		if ($archive_uid ne "") {
			&input(qq{UPDATE ptms_alerts_archive SET archive_uid="$archive_uid" WHERE entry="$archive_alert_id"});
		}
		if ($archive_comment ne "") {
			&input(qq{UPDATE ptms_alerts_archive SET archive_comment="$archive_comment" WHERE entry="$archive_alert_id"});
		}
	}
}
sub generate_alerts() {
	&archive_and_delete_alerts(qq{SELECT ptms_alerts.entry FROM ptms_alerts, ptms_cases WHERE ptms_alerts.cid=ptms_cases.entry AND ptms_cases.closed="1"});
	&generate_alerts_5_tobramycin_gentamicin_overdose();
	&generate_alerts_10_vancomycin_underdose();
	&generate_alerts_15_on_fluconazole_hold_statins();
	&generate_alerts_20_mrsa_wrong_antibiotic();
	&generate_alerts_30_yeast_remove_pd_catheter_asap();
	&generate_alerts_90_no_flu_prophylaxis();
	&generate_alerts_110_no_prelim_results();
	&generate_alerts_120_no_final_results();
}
sub generate_alerts_5_tobramycin_gentamicin_overdose() {
	my $uid = $sid[2];
	my @cases = &querymr(qq{SELECT entry, patient FROM ptms_cases WHERE closed="0"});
	foreach my $case (@cases) {
		my ($cid, $pid) = @$case;
		my @abx = &querymr(qq{SELECT dose_amount, dose_amount_units FROM ptms_antibiotics WHERE case_id="$cid" AND (antibiotic="Tobramycin" OR antibiotic="Gentamicin") AND date_end >= curdate() AND date_stopped >= curdate()});
		my $trigger = 0;
		my ($weight, $ccpd) = &query(qq{SELECT weight, dialysis_type FROM ptms_patients WHERE entry="$pid"});
		my $target = 0.6;
		if ($ccpd eq "CCPD") {
			$target = 0.5;
		}
		foreach my $a (@abx) {
			my ($dose, $unit) = @$a;
			if ($dose ne "") {
				if ($unit ne "mg") {
					$dose = $dose * 1000;
				}
				if ($weight ne "") {
					my $total = $weight * $target + 10;
					if ($total < $dose) {
						$trigger = 1;
					}
				}
			}
		}
		if ($trigger == 1) {
			if (&fast(qq{SELECT entry FROM ptms_alerts WHERE alert_type="5" AND cid="$cid"}) eq "") {
				&input(qq{INSERT INTO ptms_alerts (alert_type, pid, cid) VALUES ("5", "$pid", "$cid")});
			}
		} else {
			&archive_and_delete_alerts(qq{SELECT entry FROM ptms_alerts WHERE alert_type="5" AND cid="$cid"});
		}
	}
}
sub generate_alerts_10_vancomycin_underdose() {
	my $uid = $sid[2];
	my @cases = &querymr(qq{SELECT entry, patient FROM ptms_cases WHERE closed="0"});
	foreach my $case (@cases) {
		my ($cid, $pid) = @$case;
		my @abx = &querymr(qq{SELECT dose_amount, dose_amount_units FROM ptms_antibiotics WHERE case_id="$cid" AND antibiotic="Vancomycin" AND route <> "IV" AND date_end >= curdate() AND date_stopped >= curdate()});
		my $trigger = 0;
		if ($abx[0] ne "") {
			my $ton = &fast(qq{SELECT weight FROM ptms_patients WHERE entry="$pid"});
			if ($ton ne "") {
				my $target = ($ton * 20) * 0.9;
				foreach my $a (@abx) {
					my ($dose, $unit) = @$a;
					if ($unit ne "mg") {
						$dose = $dose * 1000;
					}
					if ($target > $dose) {
						$trigger = 1;
					}
				}
			}
		}
		if ($trigger == 1) {
			if (&fast(qq{SELECT entry FROM ptms_alerts WHERE alert_type="10" AND cid="$cid"}) eq "") {
				&input(qq{INSERT INTO ptms_alerts (alert_type, pid, cid) VALUES ("10","$pid","$cid")});
			}
		} else {
			&archive_and_delete_alerts(qq{SELECT entry FROM ptms_alerts WHERE alert_type="10" AND cid="$cid"});
		}
	}
}
sub generate_alerts_15_on_fluconazole_hold_statins() {
	my $uid = $sid[2];
	my @cases = &querymr(qq{SELECT entry, patient FROM ptms_cases WHERE closed="0"});
	foreach my $case (@cases) {
		my ($cid, $pid) = @$case;
		my $aid = &fast(qq{SELECT entry FROM ptms_antibiotics WHERE case_id="$cid" AND antibiotic="Fluconazole" AND date_end >= curdate() AND date_stopped >= curdate() LIMIT 1});
		if ($aid ne "") {
			if (&fast(qq{SELECT entry FROM ptms_alerts WHERE alert_type="15" AND cid="$cid"}) eq "") {
				&input(qq{INSERT INTO ptms_alerts (alert_type, pid, cid) VALUES ("15","$pid","$cid")});
			}
		} else {
			&archive_and_delete_alerts(qq{SELECT entry FROM ptms_alerts WHERE alert_type="15" AND cid="$cid"});
		}
	}
}
sub generate_alerts_20_mrsa_wrong_antibiotic() {
	my $uid = $sid[2];
	my @cases = &query(qq{SELECT entry FROM ptms_cases WHERE closed="0"});
	foreach my $case (@cases) {
		my ($cid, $pid) = &query(qq{SELECT DISTINCTROW ptms_cases.entry, ptms_cases.patient FROM ptms_labs, ptms_cases WHERE ptms_cases.entry="$case" AND ptms_cases.entry=ptms_labs.case_id AND (ptms_labs.pathogen_1="Final: (Gram +ve) Staphylococcus aureus (MRSA)" OR ptms_labs.pathogen_2="Final: (Gram +ve) Staphylococcus aureus (MRSA)" OR ptms_labs.pathogen_3="Final: (Gram +ve) Staphylococcus aureus (MRSA)" OR ptms_labs.pathogen_4="Final: (Gram +ve) Staphylococcus aureus (MRSA)") LIMIT 1});
		if ($cid ne "") {
			if (&fast(qq{SELECT entry FROM ptms_antibiotics WHERE case_id="$cid" AND (antibiotic="Vancomycin" OR antibiotic="Linezolid") LIMIT 1}) eq "") {
				if (&fast(qq{SELECT entry FROM ptms_alerts WHERE alert_type="20" AND cid="$cid"}) eq "") {
					&input(qq{INSERT INTO ptms_alerts (alert_type, pid, cid) VALUES ("20", "$pid", "$cid")});
				}
			} else {
				&archive_and_delete_alerts(qq{SELECT entry FROM ptms_alerts WHERE alert_type="20" AND cid="$cid"});
			}
		} else {
			&archive_and_delete_alerts(qq{SELECT entry FROM ptms_alerts WHERE alert_type="20" AND cid="$cid"});
		}
	}
}
sub generate_alerts_30_yeast_remove_pd_catheter_asap() {
	my $uid = $sid[2];
	my @cases = &query(qq{SELECT entry FROM ptms_cases WHERE closed="0"});
	foreach my $case (@cases) {
		my ($cid, $pid) = &query(qq{SELECT DISTINCTROW ptms_cases.entry, ptms_cases.patient FROM ptms_labs, ptms_cases WHERE ptms_cases.entry="$case" AND ptms_cases.entry=ptms_labs.case_id AND (ptms_labs.pathogen_1 LIKE "%Yeast%" OR ptms_labs.pathogen_2 LIKE "%Yeast%" OR ptms_labs.pathogen_3 LIKE "%Yeast%" OR ptms_labs.pathogen_4 LIKE "%Yeast%") LIMIT 1});
		if ($cid ne "") {
			if (&fast(qq{SELECT entry FROM ptms_alerts WHERE alert_type="30" AND cid="$cid"}) eq "") {
				&input(qq{INSERT INTO ptms_alerts (alert_type, pid, cid) VALUES ("30", "$pid", "$cid")});
			}
		} else {
			&archive_and_delete_alerts(qq{SELECT entry FROM ptms_alerts WHERE alert_type="30" AND cid="$cid"});
		}
	}
}
sub generate_alerts_90_no_flu_prophylaxis() {
	my $uid = $sid[2];
	my @cases = &querymr(qq{SELECT entry, patient FROM ptms_cases WHERE closed="0"});
	foreach my $case (@cases) {
		my ($case_id, $patient_id) = @$case;
		if (&fast(qq{SELECT antibiotic FROM ptms_antibiotics WHERE case_id="$case_id" AND antibiotic="Fluconazole"}) eq "") {
			if (&fast(qq{SELECT entry FROM ptms_alerts WHERE alert_type="90" AND cid="$case_id"}) eq "") {
				&input(qq{INSERT INTO ptms_alerts (alert_type, pid, cid) VALUES ("90", "$patient_id", "$case_id")});
			}
		} else {
			&archive_and_delete_alerts(qq{SELECT entry FROM ptms_alerts WHERE alert_type="90" AND cid="$case_id"});
		}
	}
}
sub generate_alerts_110_no_prelim_results() {
	my $uid = $sid[2];
	my @lab_not_arrived = &querymr(qq{SELECT ptms_labs.case_id, ptms_labs.entry FROM ptms_cases, ptms_labs WHERE ptms_cases.closed="0" AND ptms_cases.entry=ptms_labs.case_id AND ptms_labs.result_pre="0" AND ptms_labs.result_final="0" AND ptms_labs.ordered < SUBTIME(CURRENT_TIMESTAMP(), '1 0:0:0') ORDER BY ptms_labs.created DESC});
	foreach my $d (@lab_not_arrived) {
		my ($cid, $lid) = @$d;
		my $pid = &fast(qq{SELECT patient FROM ptms_cases WHERE entry="$cid"});
		if (&fast(qq{SELECT entry FROM ptms_alerts WHERE alert_type="110" AND cid="$cid"}) eq "") {
			&input(qq{INSERT INTO ptms_alerts (alert_type, pid, cid, lid) VALUES ("110", "$pid", "$cid", "$lid")});
		}
	}
}
sub generate_alerts_120_no_final_results() {
	my $uid = $sid[2];
	my @lab_not_arrived = &querymr(qq{SELECT ptms_labs.case_id, ptms_labs.entry FROM ptms_cases, ptms_labs WHERE ptms_cases.closed="0" AND ptms_cases.entry=ptms_labs.case_id AND ptms_labs.result_pre="1" AND ptms_labs.result_final="0" AND ptms_labs.ordered < SUBTIME(CURRENT_TIMESTAMP(), '3 0:0:0') ORDER BY ptms_labs.created DESC});
	foreach my $d (@lab_not_arrived) {
		my ($cid, $lid) = @$d;
		my $pid = &fast(qq{SELECT patient FROM ptms_cases WHERE entry="$cid"});
		my $good = &fast(qq{SELECT COUNT(*) FROM ptms_labs WHERE case_id="$cid" AND result_final="1"});
		if ($good < 1) {
			if (&fast(qq{SELECT entry FROM ptms_alerts WHERE alert_type="120" AND cid="$cid"}) eq "") {
				&input(qq{INSERT INTO ptms_alerts (alert_type, pid, cid, lid) VALUES ("120","$pid","$cid","$lid")});
			}
		} else {
			&archive_and_delete_alerts(qq{SELECT entry FROM ptms_alerts WHERE alert_type="120" AND cid="$cid"});
		}
	}
}
sub generate_alert_200_prelim_results_arrived() {
	my $lid = shift;
	my $cid = &fast(qq{SELECT case_id FROM ptms_labs WHERE entry="$lid"});
	my $pid = &fast(qq{SELECT patient FROM ptms_cases WHERE entry="$cid"});
	&input(qq{DELETE FROM ptms_alerts WHERE (alert_type="110" OR alert_type="200") AND cid="$cid"});
	my @uids = &query(qq{SELECT primary_nurse, nephrologist FROM ptms_patients WHERE entry="$pid"});
	foreach my $uid (@uids) {
		&input(qq{INSERT INTO ptms_alerts (alert_type,uid,pid,cid,lid) VALUES ("200","$uid","$pid","$cid","$lid")});
	}
}
sub generate_alert_210_final_results_arrived() {
	my $lid = shift;
	my $cid = &fast(qq{SELECT case_id FROM ptms_labs WHERE entry="$lid"});
	my $pid = &fast(qq{SELECT patient FROM ptms_cases WHERE entry="$cid"});
	&input(qq{DELETE FROM ptms_alerts WHERE (alert_type="110" OR alert_type="120" OR alert_type="200" OR alert_type="210") AND cid="$cid"});
	my @uids = &query(qq{SELECT primary_nurse, nephrologist FROM ptms_patients WHERE entry="$pid"});
	foreach my $uid (@uids) {
		&input(qq{INSERT INTO ptms_alerts (alert_type,uid,pid,cid,lid) VALUES ("210","$uid","$pid","$cid","$lid")});
	}
}
sub write_to_error_log() {
	my $message = shift;
	open (LOG, ">>error_log.txt") or die $!;
	print LOG $message . "\n";
	close(LOG);
}
sub interpret_next_step() {
	my $text = shift;
	my %next = (
		"1" => qq{Specify empiric treatment},
		"2" => qq{Get culture result},
		"3" => qq{Get final culture result},
		"4" => qq{Specify final antibiotic},
		"5" => qq{Complete antibiotic course},
		"6" => qq{Collect follow-up culture},
		"7" => qq{Arrange home visit},
		"8" => qq{Specify case outcome},
		"9" => qq{(closed)},
	);
	$text = $next{$text};
	$text = $next{9} if $text eq "";
	return $text;
}
sub get_next_step() {
	my $cid = shift;
	my $next = 1;
	my $outcome = &fast(qq{SELECT outcome FROM ptms_cases WHERE entry="$cid"});
	my $pid = &fast(qq{SELECT patient FROM ptms_cases WHERE entry="$cid"});
	if ($outcome ne "Outstanding") {
		$next = 9;
	} else {
		if (&fast(qq{SELECT entry FROM ptms_antibiotics WHERE case_id="$cid"}) eq "") {
			$next = 1;
		} else {
			if (&fast(qq{SELECT entry FROM ptms_labs WHERE case_id="$cid" AND (result_pre="1" OR result_final="1") ORDER BY entry DESC LIMIT 1}) eq "") {
				$next = 2;
			} else {
				if (&fast(qq{SELECT entry FROM ptms_labs WHERE case_id="$cid" AND result_final="1" ORDER BY entry DESC LIMIT 1}) eq "") {
					$next = 3;
				} else {							
					if (&fast(qq{SELECT entry FROM ptms_antibiotics WHERE case_id="$cid" AND basis_final="1"}) eq "") {
						$next = 4;
					} else {							
						if (&fast(qq{SELECT entry FROM ptms_antibiotics WHERE case_id="$cid" AND (date_end >= CURDATE() AND date_stopped >= CURDATE())}) ne "") {
							$next = 5;
						} else {
							if (&fast(qq{SELECT follow_up_culture FROM ptms_cases WHERE entry="$cid" AND follow_up_culture="Pending" AND is_peritonitis="1"}) eq "Pending") {
								# SEND EMAIL REMINDER
								my $email = &fast(qq{SELECT email FROM ptms_patients WHERE email_reminder="1" AND entry="$pid"});
								if ($email ne "") {
									my $already_sent = &fast(qq{SELECT entry FROM ptms_reminders WHERE send_to="$email" AND created > SUBDATE(CURDATE(), INTERVAL 7 DAY)});
									if ($already_sent eq "") {
										# SEND EMAIL
										my @list_to_bcc = &query(qq{SELECT email FROM ptms_users WHERE opt_in="1"});
										my %patient_info = &queryh(qq{SELECT * FROM ptms_patients WHERE entry="$pid"});
										my $greeting = $patient_info{"name_first"} . " " . $patient_info{"name_last"};
										if ($patient_info{"gender"} eq "Male") {
											$greeting = "Mr. " . $greeting;
										} elsif ($patient_info{"gender"} eq "Female") {
											$greeting = "Ms. " . $greeting;
										}
										my $list_to_bcc = join(", ", @list_to_bcc);
										my %mail = (
											"to" => $email,
											"from" => $local_settings{"email_sender_from"},
											"cc" => "",
											"bcc" => $list_to_bcc,
											"subject" => "Reminder to bring PD bag for follow-up culture",
											"body" => qq{Dear $greeting,\n\nOur records indicate that your antibiotic regimen is complete. Please remember to bring your PD bag for follow-up culture as soon as possible.\n\nBest regards,\nThe RenalConnect Team\n}	);
										&mailer(\%mail);
										&input(qq{DELETE FROM ptms_reminders WHERE send_to="$email"});
										&input(qq{INSERT INTO ptms_reminders (send_to) VALUES ("$email")});
									}
								}
							}
							if (&fast(qq{SELECT is_peritonitis FROM ptms_cases WHERE entry="$cid"}) ne "1") {
								$next = 8;
							} else {
								if (&fast(qq{SELECT follow_up_culture FROM ptms_cases WHERE entry="$cid" AND (follow_up_culture="Not tracked" OR follow_up_culture="Received" OR follow_up_culture="Collected" OR follow_up_culture="Declined")}) eq "" and $outcome ne "Catheter removal" and $outcome ne "Catheter removal and death") {
									$next = 6;
								} else {
									my $hv = &fast(qq{SELECT home_visit FROM ptms_cases WHERE entry="$cid"});
									if (($hv eq "Pending")) {
										$next = 7;
									} else {
										$next = 8;
									}
								}
							}
						}
					}
				}
			}
		}
	}
	&input(qq{UPDATE ptms_cases SET next_step="$next" WHERE entry="$cid"});
	if ($next eq "9") {
		&input(qq{UPDATE ptms_cases SET closed="1" WHERE entry="$cid"});
		&cache_rebuild_patient($pid);
	}
}
sub view_reports() {
	my %p = %{$_[0]};
	my $ref = $p{"ref"};
	my ($start, $end);
	$p{"form_report_interval"} = &fast(qq{SELECT DATEDIFF('$p{"form_report_end"}', '$p{"form_report_start"}')});
	if ($p{"form_report_interval"} < 1 or $p{"form_report_interval"} eq "") {
		($start, $end) = (&fast(qq{SELECT SUBDATE(CURDATE(), INTERVAL 6 MONTH)}), &fast(qq{SELECT ADDDATE(CURDATE(), INTERVAL 1 DAY)}));
	} else {
		($start, $end) = ($p{"form_report_start"}, $p{"form_report_end"});
	}
	my $now = &fast(qq{SELECT ADDDATE(CURDATE(), INTERVAL 1 DAY)});
	my $ago_month = &fast(qq{SELECT SUBDATE(CURDATE(), INTERVAL 1 MONTH)});
	my $ago_quarter = &fast(qq{SELECT SUBDATE(CURDATE(), INTERVAL 3 MONTH)});
	my $ago_half_year = &fast(qq{SELECT SUBDATE(CURDATE(), INTERVAL 6 MONTH)});
	my $ago_year = &fast(qq{SELECT SUBDATE(CURDATE(), INTERVAL 12 MONTH)});
	my $ago_two_year = &fast(qq{SELECT SUBDATE(CURDATE(), INTERVAL 24 MONTH)});
	my $ago_five_year = &fast(qq{SELECT SUBDATE(CURDATE(), INTERVAL 48 MONTH)});
	my $year = &fast(qq{SELECT YEAR("$now")});
	my @year_range = (1..3);
	my $common_presets = qq{
		<a href="ajax.pl?token=$token&do=view_reports&form_report_start=$ago_month&form_report_end=$now" target="hbin">month</a> &nbsp; 
		<a href="ajax.pl?token=$token&do=view_reports&form_report_start=$ago_quarter&form_report_end=$now" target="hbin">quarter</a> &nbsp; 
		<a href="ajax.pl?token=$token&do=view_reports&form_report_start=$ago_half_year&form_report_end=$now" target="hbin">six months</a> &nbsp; 
		<a href="ajax.pl?token=$token&do=view_reports&form_report_start=$ago_year&form_report_end=$now" target="hbin">year</a> &nbsp; 
		<a href="ajax.pl?token=$token&do=view_reports&form_report_start=$ago_two_year&form_report_end=$now" target="hbin">two years</a> &nbsp; 
	};
	my $common_years;
	foreach my $sub (@year_range) {
		my $y = $year - $sub;
		$common_years .= qq{<a href="ajax.pl?token=$token&do=view_reports&form_report_start=$y-01-01&form_report_end=$y-12-31" target="hbin">$y</a> &nbsp; };
	}
	my $peritonitis_rate = &report_peritonitis($start, $end);
	my $hospitalization_rate = &report_percent_cases_hospitalized($start, $end);
	my $culture_negative_rate = &report_percent_cases_culture_negative($start, $end);
	my $pathogens_hospitalized = &report_pathogens($start, $end, qq{SELECT ptms_labs.pathogen_1, ptms_labs.pathogen_2, ptms_labs.pathogen_3, ptms_labs.pathogen_4 FROM ptms_cases, ptms_labs WHERE ptms_cases.created >= "$start" AND ptms_cases.created <= "$end" AND ptms_cases.hospitalization_required="Yes" AND ptms_cases.entry=ptms_labs.case_id}, "Pathogens, hospitalized patients", "#3399ff");
	my $pathogens_all = &report_pathogens($start, $end, qq{SELECT ptms_labs.pathogen_1, ptms_labs.pathogen_2, ptms_labs.pathogen_3, ptms_labs.pathogen_4 FROM ptms_cases, ptms_labs WHERE ptms_cases.created >= "$start" AND ptms_cases.created <= "$end" AND ptms_cases.entry=ptms_labs.case_id}, "Pathogens, all infections", "#ffcc00");
	my $pathogens_peritonitis = &report_pathogens($start, $end, qq{SELECT ptms_labs.pathogen_1, ptms_labs.pathogen_2, ptms_labs.pathogen_3, ptms_labs.pathogen_4 FROM ptms_cases, ptms_labs WHERE ptms_cases.created >= "$start" AND ptms_cases.created <= "$end" AND ptms_cases.is_peritonitis="1" AND ptms_cases.entry=ptms_labs.case_id}, "Pathogens, in peritonitis", "#ff3300");
	my $pathogens_exit_site = &report_pathogens($start, $end, qq{SELECT ptms_labs.pathogen_1, ptms_labs.pathogen_2, ptms_labs.pathogen_3, ptms_labs.pathogen_4 FROM ptms_cases, ptms_labs WHERE ptms_cases.created >= "$start" AND ptms_cases.created <= "$end" AND ptms_cases.is_exit_site="1" AND ptms_cases.entry=ptms_labs.case_id}, "Pathogens, in exit site infections", "#B3FF00");
	my $pathogens_tunnel = &report_pathogens($start, $end, qq{SELECT ptms_labs.pathogen_1, ptms_labs.pathogen_2, ptms_labs.pathogen_3, ptms_labs.pathogen_4 FROM ptms_cases, ptms_labs WHERE ptms_cases.created >= "$start" AND ptms_cases.created <= "$end" AND ptms_cases.is_tunnel="1" AND ptms_cases.entry=ptms_labs.case_id}, "Pathogens, in tunnel infections", "#ffee00");
	my $antibiotics_empiric = &report_antibiotics($start, $end, qq{SELECT ptms_antibiotics.antibiotic FROM ptms_cases, ptms_antibiotics WHERE ptms_cases.created >= "$start" AND ptms_cases.created <= "$end" AND ptms_cases.is_peritonitis="1" AND ptms_cases.entry=ptms_antibiotics.case_id AND ptms_antibiotics.basis_empiric="1"}, "Antibiotics, as empiric treatment (peritonitis only)", "#FF00B3");
	my $antibiotics_final = &report_antibiotics($start, $end, qq{SELECT ptms_antibiotics.antibiotic FROM ptms_cases, ptms_antibiotics WHERE ptms_cases.created >= "$start" AND ptms_cases.created <= "$end" AND ptms_cases.is_peritonitis="1" AND ptms_cases.entry=ptms_antibiotics.case_id AND ptms_antibiotics.basis_final="1"}, "Antibiotics, as final treatment (peritonitis only)", "#CC00FF");
	my $nice_start = &nice_date($start);
	my $nice_end = &nice_date($end);
	return qq{
		<div class="">
			<div class="p20bo">
				<div class="float-l p10to"><h4>For <strong>$nice_start</strong> to <strong>$nice_end</strong></h4></div>
				<div class="tr">
					<div class="float-r p9to">
						<form name="report" action="ajax.pl" target="hbin" method="post" accept-charset="utf-8">
							<input type="hidden" name="do" value="view_reports"/>
							<input type="hidden" name="token" value="$token"/>
							<div class="float-l b p1to">Switch to &nbsp;</div>
							<div class="float-l"><div class="itt w80"><input type="text" class="itt" name="form_report_start" value="$start" onclick="displayDatePicker('form_report_start');"/></div></div>
							<div class="float-l">&nbsp; to &nbsp;</div>
							<div class="float-l"><div class="itt w80"><input type="text" class="itt" name="form_report_end" value="$end" onclick="displayDatePicker('form_report_end');"/></div></div>
							<div class="float-l">&nbsp; <input type="submit" value="Go"/></div>
							<div class="clear-l"></div>
						</form>
					</div>
					<div class="clear-r"></div>
					<div class="tr gt">past &nbsp; $common_presets</div>
					<div class="tr gt">year &nbsp; $common_years</div>
				</div>
			</div>
			$peritonitis_rate
			$hospitalization_rate
			$culture_negative_rate
			$antibiotics_empiric
			$antibiotics_final
			$pathogens_all
			$pathogens_hospitalized
			$pathogens_peritonitis
			$pathogens_exit_site
			$pathogens_tunnel
			<div class="clear-l"></div>
			<div class="p10 bg-vlg">
				<h2>Export data</h2>
				<span class="b">You will have the option to download all patient data in Excel format</span>. Please note that requests to download the database are recorded in the RenalConnect access logs, and that each Excel file downloaded contains a unique tracking number that connects the file to your account. This feature is under development.
			</div>
		</div>
	};
}
sub report_percent_cases_culture_negative() {
	my ($start, $end) = @_;
	my @cultures = &querymr(qq{SELECT ptms_labs.pathogen_1, ptms_labs.pathogen_2, ptms_labs.pathogen_3, ptms_labs.pathogen_4 FROM ptms_labs, ptms_cases WHERE ptms_labs.ordered >= "$start" AND ptms_labs.ordered <= "$end" AND ptms_labs.case_id=ptms_cases.entry AND ptms_cases.is_peritonitis = 1});
	my $cultures_negative_percent = 0;
	my $cultures_negative = 0;
	my $cultures_all = 0;
	foreach my $c (@cultures) {
		my @results = @$c;
		my $marker = 0;
		foreach my $r (@results) {
			if ($r =~ /Culture negative/ or $r =~ /Nothing identified/) {
				$marker = 1;
			}
		}
		if ($marker == 1) {
			$cultures_negative++;
		}
		$cultures_all++;
	}
	if ($cultures_all > 0) {
		$cultures_negative_percent = int(0.5 + (($cultures_negative / $cultures_all) * 100));
	}
	if ($cultures_negative_percent > 10) {
		$cultures_negative_percent = qq{<span class="txt-red">$cultures_negative_percent\%</span>};
	} else {
		$cultures_negative_percent = qq{<span class="txt-gre">$cultures_negative_percent\%</span>};
	}
	return qq{
		<div class="rbox w50p">
			<div class="rbox-in">
				<div class="rbox-hd">Negative cultures</div>
				<div class="rbox-xl">$cultures_negative_percent</div>
				<div class="rbox-st"> of cultures yield negative<br/>results during this time period</div>
				<div class="rbox-fp">
					<div>only cultures from peritonitis cases are counted</div>
					<div>$cultures_negative cultures negative</div>
					<div>$cultures_all total cultures ordered</div>
				</div>
			</div>
		</div>};
}
sub report_percent_cases_hospitalized() {
	my ($start, $end) = @_;
	my $cases_all = &fast(qq{SELECT COUNT(*) FROM ptms_cases WHERE created >= "$start" AND created <= "$end"});
	my $cases_hospitalized = &fast(qq{SELECT COUNT(*) FROM ptms_cases WHERE hospitalization_required="Yes" AND created >= "$start" AND created <= "$end"});
	my $cases_hospitalized_percent = 0;
	if ($cases_all > 0) {
		$cases_hospitalized_percent = int(0.5 + (($cases_hospitalized / $cases_all) * 100));
	}
	return qq{
		<div class="rbox w50p">
			<div class="rbox-in">
				<div class="rbox-hd">Hospitalization</div>
				<div class="rbox-xl">$cases_hospitalized_percent\%</div>
				<div class="rbox-st"> of cases require hospitalization<br/>during this time period</div>
				<div class="rbox-fp">
					<div>$cases_hospitalized cases requiring hospitalization</div>
					<div>$cases_all cases in total</div>
				</div>
			</div>
		</div>};
}
sub report_peritonitis() {
	my ($start, $end) = @_;
	my @pds = &querymr(qq{SELECT start_date, stop_date, patient_id FROM ptms_dialysis WHERE (stop_date IS NULL OR stop_date >= "$start") AND start_date IS NOT NULL});
	my $days_at_risk = 0;
	my $months_at_risk = 0;
	my $patients_at_risk = 0;
	my %patients_at_risk_hash = ();
	my @peritonitis_rate_patient;
	foreach my $pd (@pds) {
		my ($pd_start, $pd_end, $patient_id) = @$pd;
		my ($true_start, $true_end);
		if (&fast(qq{SELECT DATEDIFF('$start','$pd_start')}) >= 0) {
			$true_start = $start;
		} else {
			$true_start = $pd_start;
		}
		if ($pd_end ne "") {
			if (&fast(qq{SELECT DATEDIFF('$end','$pd_end')}) >= 0) {
				$true_end = $pd_end;
			} else {
				$true_end = $end;
			}
		} else {
			$true_end = $end;
		}
		my $days_at_risk_patient = &fast(qq{SELECT DATEDIFF('$true_end','$true_start')});
		if ($days_at_risk_patient > 0) {
			$days_at_risk = $days_at_risk + $days_at_risk_patient;
			$patients_at_risk_hash{$patient_id} = 1;
			$patients_at_risk++;
		}
		my $peritonitis_occurence_patient = &fast(qq{SELECT COUNT(*) FROM ptms_cases WHERE is_peritonitis="1" AND created >= "$start" AND created <= "$end" AND patient="$patient_id"});
		my $months_at_risk_patient = $days_at_risk_patient / 30.4368499;
		if ($peritonitis_occurence_patient > 0) {
		    my $peritonitis_rate_patient = ($months_at_risk_patient / $peritonitis_occurence_patient);
		    @peritonitis_rate_patient = (@peritonitis_rate_patient, $peritonitis_rate_patient);
		}
	}
	my $patients_at_risk_new = 0;
	foreach my $key (keys %patients_at_risk_hash) {
	    $patients_at_risk_new = $patients_at_risk_new + $patients_at_risk_hash{$key};
    }
    #&fast(qq{SELECT COUNT(DISTINCTROW patient_id) FROM ptms_dialysis WHERE (start_date >= "$start" AND start_date <= "$end") OR (stop_date <= "$end" AND stop_date >= "$start")});
    my $patients_peritonitis = &fast(qq{SELECT COUNT(DISTINCTROW patient) FROM ptms_cases WHERE is_peritonitis="1" AND created >= "$start" AND created <= "$end"});
    my $patients_peritonitis_free = $patients_at_risk_new - $patients_peritonitis;
	$months_at_risk = $days_at_risk / 30.4368499;
	my $months_at_risk_rounded = int(0.5 + $months_at_risk);
	my $peritonitis_occurence = &fast(qq{SELECT COUNT(*) FROM ptms_cases WHERE is_peritonitis="1" AND created >= "$start" AND created <= "$end"});
	my $peritonitis_rate;
	my $peritonitis_rate_sd_rounded;
	my $peritonitis_rate_not_rounded;
	if ($peritonitis_occurence > 0) {
		$peritonitis_rate = int(0.5 + (($months_at_risk / $peritonitis_occurence) * 10)) / 10;
		$peritonitis_rate_not_rounded = $months_at_risk / $peritonitis_occurence;
		my $peritonitis_rate_sum_of_subtract_of_mean_squared;
		my $subtract_of_mean_squared_counter = 0;
		foreach my $individual_peritonitis_rate (@peritonitis_rate_patient) {
		    my $subtract_of_mean = ($peritonitis_rate_not_rounded - $individual_peritonitis_rate) * ($peritonitis_rate_not_rounded - $individual_peritonitis_rate);
		    $peritonitis_rate_sum_of_subtract_of_mean_squared = $peritonitis_rate_sum_of_subtract_of_mean_squared + $subtract_of_mean;
		    $subtract_of_mean_squared_counter++;
		}
		$subtract_of_mean_squared_counter = $subtract_of_mean_squared_counter - 1;
		$peritonitis_rate_sum_of_subtract_of_mean_squared = $peritonitis_rate_sum_of_subtract_of_mean_squared / $subtract_of_mean_squared_counter;
		my $peritonitis_rate_sd = sqrt($peritonitis_rate_sum_of_subtract_of_mean_squared);
		$peritonitis_rate_sd_rounded = int(0.5 + ($peritonitis_rate_sd * 100)) / 100;
	} else {
		$peritonitis_rate = qq{&infin;};
		$peritonitis_rate_sd_rounded = qq{zero};
	}
	#					<div>standard deviation of $peritonitis_rate_sd_rounded months between episodes</div>
	return qq{
		<div class="rbox w50p">
			<div class="rbox-in">
				<div class="rbox-hd">Peritonitis rate</div>
				<div class="rbox-xl">$peritonitis_rate</div>
				<div class="rbox-st">months between episodes</div>
				<div class="rbox-fp">
					<div>$months_at_risk_rounded patient-months of peritoneal dialysis at risk</div>
					<div>$peritonitis_occurence new cases of peritonitis in $patients_peritonitis patients</div>
					<div>$patients_at_risk_new patients at risk</div>
					<div>$patients_peritonitis_free patients peritonitis-free</div>
				</div>
			</div>
		</div>};
}
sub report_pathogens() {
	my ($start, $end, $query, $header, $color) = @_;
	my @pathogens = &querymr($query);
	my %pathogens;
	my $total = 0;
	my $biggest = 0;
	foreach my $p (@pathogens) {
		my @ps = @$p;
		foreach my $ps (@ps) {
			if ($ps ne "") {
				if ($pathogens{$ps} eq "") {
					$pathogens{$ps} = 1;
				} else {
					$pathogens{$ps} = $pathogens{$ps} + 1;
				}
				$total++;
				if ($pathogens{$ps} > $biggest) {
					$biggest = $pathogens{$ps};
				}
			}
		}
	}
	my $elements = keys(%pathogens);
	my $break = int(0.5+$elements/2);
	my $rows = 1;
	my $print = qq{<div class="float-l w50p">};
	foreach my $key (sort {$pathogens{$b} <=> $pathogens{$a}} keys %pathogens) {
		my $quantity = $pathogens{$key};
		my $max_width = 50;
		my $width = int(0.5 + (($quantity/$biggest) * 15));
		my $percent = int(0.5 + (($quantity/$total) * 100));
		my $name = $key;
		$name =~ s/species/<em>spp<\/em>/g;
		$name =~ s/negative/-ve/g;
		$name =~ s/\(Gram //g;
		$name =~ s/ve\)/ve/g;
		$print .= qq{
			<div class="sml">
				<div style="float:left; display:block; height:11px; width:} . $width . qq{\%; background-color:$color;"></div>
				<div class="">&nbsp;<span class="b txt-blk">$percent\%</span> <span class="txt-blk">$name</span> &nbsp; <span class="gt">$quantity</span></div>
			</div>
		};
		if ($rows == $break) {
			$print .= qq{</div><div class="float-l w50p">};
		}
		$rows++;
	}
	$print .= qq{</div>};
	return qq{
		<div class="rbox-long w100p">
			<div class="rbox-in">
				<div class="rbox-hd">$header</div>
				<div class="p10to">
					$print
					<div class="clear-l"></div>
				</div>
			</div>
		</div>};
}
sub report_antibiotics() {
	my ($start, $end, $query, $header, $color) = @_;
	my @antibiotics = &query($query);
	my %antibiotics;
	my $total = 0;
	my $biggest = 0;
	foreach my $a (@antibiotics) {
		if ($a ne "") {
			if ($antibiotics{$a} eq "") {
				$antibiotics{$a} = 1;
			} else {
				$antibiotics{$a} = $antibiotics{$a} + 1;
			}
			$total++;
			if ($antibiotics{$a} > $biggest) {
				$biggest = $antibiotics{$a};
			}
		}
	}
	my $elements = keys(%antibiotics);
	my $break = int(0.5+$elements/2);
	my $rows = 1;
	my $print = qq{<div class="float-l w50p">};
	foreach my $key (sort {$antibiotics{$b} <=> $antibiotics{$a}} keys %antibiotics) {
		my $quantity = $antibiotics{$key};
		my $max_width = 50;
		my $width = int(0.5 + (($quantity/$biggest) * 50));
		my $percent = int(0.5 + (($quantity/$total) * 100));
		my $name = $key;
		$print .= qq{
			<div class="sml">
				<div style="float:left; display:block; height:11px; width:} . $width . qq{\%; background-color:$color;"></div>
				<div class="">&nbsp;<span class="b txt-blk">$percent\%</span> <span class="txt-blk">$name</span> &nbsp; <span class="gt">$quantity</span></div>
			</div>
		};
		if ($rows == $break) {
			$print .= qq{</div><div class="float-l w50p">};
		}
		$rows++;
	}
	$print .= qq{</div>};
	return qq{
		<div class="rbox-long w100p">
			<div class="rbox-in">
				<div class="rbox-hd">$header</div>
				<div class="p10to">
					$print
					<div class="clear-l"></div>
				</div>
			</div>
		</div>};
}
sub filter_integer_only() {
	my $string = shift;
	$string =~ s/\D//g;
	return $string;
}
sub mailer() {
 	my (%mail) = %{$_[0]};
	my $to = $mail{"to"};
	my $from = $mail{"from"};
	my $subject = $mail{"subject"};
	my $cc = $mail{"cc"};
	my $bcc = $mail{"bcc"};
	my $body = $mail{"body"};
	my $key = $local_settings{"email_sender_key"};
 	my $params = qq{to=$to&from=$from&subject=$subject&cc=$cc&bcc=$bcc&body=$body&key=$key};
	my $result = `curl --data "$params" $local_settings{"email_sender_script"}`;
	my $final = $params . " " . $result;
	return $final;
}
return 1;