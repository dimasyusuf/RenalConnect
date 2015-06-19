package rc::io;
use strict;

# =============================================
# LOCAL INSTALLATION SETTINGS ARE FOUND BELOW
# EDIT THESE SETTINGS TO MATCH YOUR ENVIRONMENT
# =============================================

my %local_settings = (
	"path_htdocs" => "", #IF THE WEBSITE IS INSTALLED IN ROOT, SHOULD BE ''
	"path_cgibin" => "/cgi-bin/", #THE WEBSITE'S CGI-BIN MUST BE INSTALLED IN ROOT, I.E. /cgi-bin/index.pl MUST BE ACCESSIBLE
	"encrypt_key" => "", #A 16-TO-256 STRING RANDOM KEY, ALPHANUMERIC, CANNOT BE CHANGED
	"dbinfo_host" => "", #DATABASE HOST NAME OR IP ADDRESS, EXAMPLE "localhost"
	"dbinfo_user" => "", #DATABASE USER NAME, EXAMPLE "root"
	"dbinfo_pass" => "", #DATABASE USER PASSWORD, EXAMPLE "password_for_database"
	"dbinfo_name" => "", #DATABASE NAME, EXAMPLE "test" or "renalconnect"
	"http_domain" => "", #THE DOMAIN OR IP ADDRESS WHERE IT'S INSTALLED, EXAMPLE "renalconnect.com"
	"email_sender_key" => "",  #A 16-TO-256 STRING RANDOM KEY, ALPHANUMERIC, FOR YOUR send.php
	"email_sender_from" => "", #THE EMAIL ADDRESS OF YOUR RENALCONNECT, EXAMPLE "do.not.reply@renalconnect.com"
	"email_sender_script" => "/send.php", #ABSOLUTE URL PATH TO send.php, EXAMPLE "http://www.renalconnectmail.com/send.php"
	"email_support_to" => "", #EMAIL ADDRESS OF TECHNICAL SUPPORT PERSON
	"default_hospital" => "", #THE DEFAULT HOSPITAL IN YOUR GROUP, I.E. "St. Michael's Hospital"
	"ajax_debug" => "off", #DEVELOPMENT DEBUG TOOL, BY DEFAULT SHOULD BE off
	"end_of_settings" => "");

#THE HOSPITALS IN YOUR GROUP, I.E. "St. Michael's Hospital"

my @local_settings_hospitals = (
	"Abbotsford Regional Hospital",
	"Burnaby General Hospital",
	"Chilliwack General Hospital",
	"Eagle Ridge Hospital",
	"Mission Memorial Hospital",
	"Peach Arch Hospital",
	"Ridge Meadows Hospital",
	"Royal Columbian Hospital",
	"Surrey Memorial Hospital");

#THE HOSPITALS IN YOUR GROUP ACCEPTING NEW DIALYSIS PATIENTS, I.E. "St. Michael's Hospital"

my @local_settings_hospitals_for_new_starts = (
	"Abbotsford Regional Hospital",
	"Royal Columbian Hospital",
	"Surrey Memorial Hospital");

#THE DIALYSIS CENTRE(S) IN YOUR GROUP, I.E. "St. Michael's Hospital"

my @dialysis_centres = ("ARH", "RCH"); 
@{$local_settings{"dialysis_centres"}} = @dialysis_centres;

# ==========================================================
# FOR SIMPLE INSTALLATIONS WITHOUT ANY SOFTWARE MODIFICATION
# YOU SHOULD NOT NEED TO EDIT ANY CODE BELOW THIS POINT
# ==========================================================

use Crypt::Blowfish;
use CGI::Session;
use CGI;
use DBI;

sub get_local_settings() {
	return %local_settings;
}

CGI::Session->name("rc");

my $q = new CGI;
my @sid;
my $token;
my $cipher = new Crypt::Blowfish $local_settings{"encrypt_key"};

sub get_q() {return $q;}
sub encrypt() {
	my $a = shift;
	my $encrypted;
	while (length $a > 0) {
		while (length $a < 8) {$a .= "\t";}
		my $b = $cipher->encrypt(substr($a,0,8));
		$encrypted .= $b; 
		if (length $a > 8) {$a = substr($a,8);} else {$a = '';}
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
			$a = '';
		}
	}
	$decrypted =~ s/\t+$//g;
	return ($decrypted);
}
sub get_db() {
	my $dbh = DBI->connect("dbi:mysql:" . $local_settings{"dbinfo_name"} . ':' . $local_settings{"dbinfo_host"}, $local_settings{"dbinfo_user"}, $local_settings{"dbinfo_pass"});
	return $dbh;
}
sub dblog() {
#	my $query = shift;
#	open(LOG, ">>db.txt");
#	print LOG $query . "\n";
#	close(LOG);
}
my $dbh = &get_db();
sub fast() {
	my $query = shift;
	&dblog($query);
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
	if (ref($hash) eq "HASH") { 
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
	&dblog($query);
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

# SET GLOBAL LANGUAGE
my $lang = 'English';
my $set_lang = '';
my %pl = &params();
my %w;

my %lang_en = (
	qq{Recovered from dialysis dependance?} => qq{Recovered from dialysis dependance?},
	qq{Status at initial meeting} => qq{Status at initial meeting},
	qq{Pre-dialysis} => qq{Pre-dialysis},
	qq{Hemodialysis} => qq{Hemodialysis},
	qq{Recovered} => qq{Recovered},
	qq{From PD referral to PD catheter insertion} => qq{From PD referral to PD catheter insertion},
	qq{From PD referral to PD start} => qq{From PD referral to PD start},
	qq{Data point} => qq{Data point},
	qq{Duration} => qq{Duration},
	qq{Date 1} => qq{Date 1},
	qq{Date 2} => qq{Date 2},
	qq{Unlock} => qq{Unlock},
	'Yes, but not referred at this time' => 'Yes, but not referred at this time',
	'median' => 'median',
	'(closed)' => '(closed)',
	'(mean)' => '(mean)',
	'(no culture taken)' => '(no culture taken)',
	'account settings' => 'account settings',
	'Account type' => 'Account type',
	'ACP introduced' => 'ACP introduced',
	'Active case' => 'Active case',
	'active cases' => 'active cases',
	'Active list' => 'Active list',
	'active starts' => 'active starts',
	'Active_uc' => 'Active',
	'active' => 'active',
	'Add a new case for this patient' => 'Add a new case for this patient',
	'Add a new patient' => 'Add a new patient',
	'Add antibiotic treatment' => 'Add antibiotic treatment',
	'add case' => 'add case',
	'Add catheter information' => 'Add catheter information',
	'Add culture result' => 'Add culture result',
	'Add dialysis information' => 'Add dialysis information',
	'Add lab test' => 'Add lab test',
	'Add new user' => 'Add new user',
	'add patient' => 'add patient',
	'Add peritoneal dialysis information' => 'Add peritoneal dialysis information',
	'add start' => 'add start',
	'Add treatment' => 'Add treatment',
	'admin' => 'admin',
	'administrator' => 'administrator',
	'Admit date' => 'Admit date',
	'Admitted' => 'Admitted',
	'Advance care planning' => 'Advance care planning',
	'after TN intervention' => 'after TN intervention',
	'alerts' => 'alerts',
	'all cases' => 'all cases',
	'All centres_uc' => 'All centres',
	'all centres' => 'all centres',
	'all patients' => 'all patients',
	'all starts' => 'all starts',
	'Allergies' => 'Allergies',
	'already has an outstanding case that was last updated' => 'already has an outstanding case that was last updated',
	'and is followed by a transition nurse' => 'and is followed by a transition nurse',
	'Antibiotic treatment' => 'Antibiotic treatment',
	'Antibiotic' => 'Antibiotic',
	'Antibiotics given' => 'Antibiotics given',
	'Antibiotics, as empiric treatment (peritonitis only)' => 'Antibiotics, as empiric treatment (peritonitis only)',
	'Antibiotics, as final treatment (peritonitis only)' => 'Antibiotics, as final treatment (peritonitis only)',
	'Antibiotics' => 'Antibiotics',
	'April' => 'April',
	'Arrange follow-up in' => 'Arrange follow-up in',
	'Arrange home visit' => 'Arrange home visit',
	'at' => 'at',
	'attend' => 'attend',
	'August' => 'August',
	'AV fistula (AVF)' => 'AV fistula (AVF)',
	'AV graft (AVG)' => 'AV graft (AVG)',
	'Basis' => 'Basis',
	'Bedside' => 'Bedside',
	'Blind insertion' => 'Blind insertion',
	'Blood culture' => 'Blood culture',
	'by the system' => 'by the system',
	'by' => 'by',
	'cancel' => 'cancel',
	'Candidate for home dialysis' => 'Candidate for home dialysis',
	'Case information' => 'Case information',
	'Case statistics' => 'Case statistics',
	'Case type' => 'Case type',
	'case(s)' => 'case(s)',
	'Case&nbsp;details' => 'Case&nbsp;details',
	'cases in total' => 'cases in total',
	'cases requiring hospitalization' => 'cases requiring hospitalization',
	'Cases' => 'Cases',
	'Catheter details' => 'Catheter details',
	'Catheter information' => 'Catheter information',
	'Catheter removal and death' => 'Catheter removal and death',
	'Catheter removal' => 'Catheter removal',
	'Catheter type' => 'Catheter type',
	'Catheter-related' => 'Catheter-related',
	'cc this email when reminders are sent to patients' => 'cc this email when reminders are sent to patients',
	'Central venous catheter (CVC)' => 'Central venous catheter (CVC)',
	'change' => 'change',
	'Checklist' => 'Checklist',
	'choose another patient' => 'choose another patient',
	'Chosen modality' => 'Chosen modality',
	'Click here' => 'Click here',
	'Clinical Pharmacist' => 'Clinical Pharmacist',
	'Close this box' => 'Close this box',
	'Closed case' => 'Closed case',
	'Closed list' => 'Closed list',
	'Closed_uc' => 'Closed',
	'closed' => 'closed',
	'Co-morbidities' => 'Co-morbidities',
	'cognitive impairment' => 'cognitive impairment',
	'Collect follow-up culture' => 'Collect follow-up culture',
	'Comments' => 'Comments',
	'Community alert' => 'Community alert',
	'Community hemodialysis' => 'Community hemodialysis',
	'Complete antibiotic course' => 'Complete antibiotic course',
	'Completed' => 'Completed',
	'Conservative (no dialysis)' => 'Conservative (no dialysis)',
	'Convenience' => 'Convenience',
	'course completed' => 'course completed',
	'create a case' => 'create a case',
	'create a new start' => 'create a new start',
	'Create case' => 'Create case',
	'Create start' => 'Create start',
	'Created' => 'Created',
	'Culture details' => 'Culture details',
	'Culture report' => 'Culture report',
	'Culture result' => 'Culture result',
	'Culture results' => 'Culture results',
	'Culture' => 'Culture',
	'cultures negative' => 'cultures negative',
	'cultures' => 'cultures',
	'Curled' => 'Curled',
	'Current status' => 'Current status',
	'CVC with AVF or AVG' => 'CVC with AVF or AVG',
	'Database encryption key' => 'Database encryption key',
	'Date of AV access creation' => 'Date of AV access creation',
	'Date of birth' => 'Date of birth',
	'Date of first AV access use' => 'Date of first AV access use',
	'Date of first hemodialysis (HD)' => 'Date of first hemodialysis (HD)',
	'Date of HHD referral' => 'Date of HHD referral',
	'Date of HHD start' => 'Date of HHD start',
	'Date of initial TN assessment' => 'Date of initial TN assessment',
	'Date of ACP completion' => 'Date of ACP completion',
	'Date of PD cath insertion' => 'Date of PD cath insertion',
	'Date of PD referral' => 'Date of PD referral',
	'Date of PD start' => 'Date of PD start',
	'Date of TN sign off' => 'Date of TN sign off',
	'Date of transplant referral' => 'Date of transplant referral',
	'Date of transplantation' => 'Date of transplantation',
	'Date of VA referral' => 'Date of VA referral',
	'Date ordered' => 'Date ordered',
	'day' => 'day',
	'days ago' => 'days ago',
	'days starting on' => 'days starting on',
	'days' => 'days',
	'De novo' => 'De novo',
	'deactivate' => 'deactivate',
	'deactivated' => 'deactivated',
	'Dear' => 'Dear',
	'Death' => 'Death',
	'Deceased' => 'Deceased',
	'December' => 'December',
	'Declined' => 'Declined',
	'Delete antibiotic treatment' => 'Delete antibiotic treatment',
	'Delete case' => 'Delete case',
	'Delete catheter information' => 'Delete catheter information',
	'Delete culture result' => 'Delete culture result',
	'Delete dialysis information' => 'Delete dialysis information',
	'delete' => 'delete',
	'diabetes' => 'diabetes',
	'Dialysis centre' => 'Dialysis centre',
	'Dialysis details' => 'Dialysis details',
	'Dialysis information' => 'Dialysis information',
	'Dialysis type' => 'Dialysis type',
	'discard changes and return' => 'discard changes and return',
	'Discharge date' => 'Discharge date',
	'dismiss' => 'dismiss',
	'Dismissed alerts' => 'Dismissed alerts',
	'Dismissed' => 'Dismissed',
	'Displaying cases for' => 'Displaying cases for',
	'Displaying lists for' => 'Displaying lists for',
	'Dose and route' => 'Dose and route',
	'duration set to' => 'duration set to',
	'Email_uc' => 'Email',
	'email' => 'email',
	'Empiric antibiotics' => 'Empiric antibiotics',
	'empiric' => 'empiric',
	'enter a new case' => 'enter a new case',
	'enter the patient' => 'enter the patient',
	'Existing password' => 'Existing password',
	'exit site' => 'exit site',
	'Exit site' => 'Exit site',
	'Failed home dialysis in the past' => 'Failed home dialysis in the past',
	'Failed peritoneal dialysis in the past' => 'Failed peritoneal dialysis in the past',
	'February' => 'February',
	'Female' => 'Female',
	'Filter by patient name' => 'Filter by patient name',
	'Final antibiotics' => 'Final antibiotics',
	'Final_uc' => 'Final',
	'Final: (Gram -ve) Acinetobacter species' => 'Final: (Gram -ve) Acinetobacter species',
	'Final: (Gram -ve) Citrobacter species' => 'Final: (Gram -ve) Citrobacter species',
	'Final: (Gram -ve) Enterobacter species' => 'Final: (Gram -ve) Enterobacter species',
	'Final: (Gram -ve) Escherichia coli' => 'Final: (Gram -ve) Escherichia coli',
	'Final: (Gram -ve) Gram negative organisms, other' => 'Final: (Gram -ve) Gram negative organisms, other',
	'Final: (Gram -ve) Klebsiella species' => 'Final: (Gram -ve) Klebsiella species',
	'Final: (Gram -ve) Neisseria species' => 'Final: (Gram -ve) Neisseria species',
	'Final: (Gram -ve) Proteus mirabilis' => 'Final: (Gram -ve) Proteus mirabilis',
	'Final: (Gram -ve) Pseudomonas species' => 'Final: (Gram -ve) Pseudomonas species',
	'Final: (Gram -ve) Serratia marcescens' => 'Final: (Gram -ve) Serratia marcescens',
	'Final: (Gram +ve) Clostridium species' => 'Final: (Gram +ve) Clostridium species',
	'Final: (Gram +ve) Corynebacteria species' => 'Final: (Gram +ve) Corynebacteria species',
	'Final: (Gram +ve) Diptheroids' => 'Final: (Gram +ve) Diptheroids',
	'Final: (Gram +ve) Enterococcus species' => 'Final: (Gram +ve) Enterococcus species',
	'Final: (Gram +ve) Gram positive organisms, other' => 'Final: (Gram +ve) Gram positive organisms, other',
	'Final: (Gram +ve) Lactobacillus' => 'Final: (Gram +ve) Lactobacillus',
	'Final: (Gram +ve) Propionibacterium' => 'Final: (Gram +ve) Propionibacterium',
	'Final: (Gram +ve) Staphylococcus aureus (MRSA)' => 'Final: (Gram +ve) Staphylococcus aureus (MRSA)',
	'Final: (Gram +ve) Staphylococcus aureus (MSSA)' => 'Final: (Gram +ve) Staphylococcus aureus (MSSA)',
	'Final: (Gram +ve) Staphylococcus aureus (sensitivity unknown)' => 'Final: (Gram +ve) Staphylococcus aureus (sensitivity unknown)',
	'Final: (Gram +ve) Staphylococcus epidermidis' => 'Final: (Gram +ve) Staphylococcus epidermidis',
	'Final: (Gram +ve) Staphylococcus species, coagulase negative' => 'Final: (Gram +ve) Staphylococcus species, coagulase negative',
	'Final: (Gram +ve) Staphylococcus species' => 'Final: (Gram +ve) Staphylococcus species',
	'Final: (Gram +ve) Streptococcus species' => 'Final: (Gram +ve) Streptococcus species',
	'Final: (Yeast) Candida species' => 'Final: (Yeast) Candida species',
	'Final: (Yeast) Other species' => 'Final: (Yeast) Other species',
	'Final: Anaerobes' => 'Final: Anaerobes',
	'Final: Culture negative' => 'Final: Culture negative',
	'Final: Multiple' => 'Final: Multiple',
	'Final: Mycobacterium tuberculosis' => 'Final: Mycobacterium tuberculosis',
	'Final: Other' => 'Final: Other',
	'final' => 'final',
	'First assessment' => 'First assessment',
	'first before proceeding to enter a new case or adding a lab test requisition or antibiotic treatment to that case' => 'first before proceeding to enter a new case or adding a lab test requisition or antibiotic treatment to that case',
	'first before proceeding to enter a new case or adding a lab test requisition to that case' => 'first before proceeding to enter a new case or adding a lab test requisition to that case',
	'First name' => 'First name',
	'Follow-up and outcome' => 'Follow-up and outcome',
	'Follow-up comments' => 'Follow-up comments',
	'Follow-up culture' => 'Follow-up culture',
	'Follow-up date' => 'Follow-up date',
	'Follow-up visit' => 'Follow-up visit',
	'For best results, please upgrade to the latest release of' => 'For best results, please upgrade to the latest release of',
	'For patients with CVC' => 'For patients with CVC',
	'for' => 'for',
	'For' => 'For',
	'found' => 'found',
	'From HD start to first TN assessment' => 'From HD start to first TN assessment',
	'From HD start to HHD referral' => 'From HD start to HHD referral',
	'From HD start to HHD start' => 'From HD start to HHD start',
	'From HD start to ACP completion' => 'From HD start to ACP completion',
	'From HD start to PD catheter insertion' => 'From HD start to PD catheter insertion',
	'From HD start to PD referral' => 'From HD start to PD referral',
	'From HD start to PD start' => 'From HD start to PD start',
	'From HD start to transplant operation' => 'From HD start to transplant operation',
	'From HD start to transplant referral' => 'From HD start to transplant referral',
	'From HD start to VA referral for patients who chose HD' => 'From HD start to VA referral for patients who chose HD',
	'From HD start to VA creation for patients who chose HD' => 'From HD start to VA creation for patients who chose HD',
	'From HD start to VA use for patients who chose HD' => 'From HD start to VA use for patients who chose HD',
	'from' => 'from',
	'Gender' => 'Gender',
	'General comments' => 'General comments',
	'Get culture result' => 'Get culture result',
	'Get final culture result' => 'Get final culture result',
	'Get technical support' => 'Get technical support',
	'go to page' => 'go to page',
	'Go' => 'Go',
	'has been deactivated' => 'has been deactivated',
	'hidden for today' => 'hidden for today',
	'Hide' => 'Hide',
	'Home centre' => 'Home centre',
	'Home hemodialysis (HHD)' => 'Home hemodialysis (HHD)',
	'Home hemodialysis' => 'Home hemodialysis',
	'Home visit' => 'Home visit',
	'home' => 'home',
	'Hospitalization' => 'Hospitalization',
	'Hospitalized' => 'Hospitalized',
	'hour ago' => 'hour ago',
	'hours ago' => 'hours ago',
	'I forgot my password' => 'I forgot my password',
	'If the patient is not in this system, please' => 'If the patient is not in this system, please',
	'IM' => 'IM',
	'In-centre hemodialysis' => 'In-centre hemodialysis',
	'In-centre or community hemodialysis' => 'In-centre or community hemodialysis',
	'Inadequate access to assistance' => 'Inadequate access to assistance',
	'Inadequate social support' => 'Inadequate social support',
	'Include' => 'Include',
	'inclusive' => 'inclusive',
	'indicates required fields' => 'indicates required fields',
	'Infection type' => 'Infection type',
	'Infection' => 'Infection',
	'Initial %PMN on diff' => 'Initial %PMN on diff',
	'Initial %PMN:' => 'Initial %PMN:',
	'Initial meeting' => 'Initial meeting',
	'Initial WBC count' => 'Initial WBC count',
	'Initial WBC' => 'Initial WBC',
	'inserted on' => 'inserted on',
	'Insertion date' => 'Insertion date',
	'Insertion location' => 'Insertion location',
	'Insertion method' => 'Insertion method',
	'Insufficient dexterity' => 'Insufficient dexterity',
	'Intranasal' => 'Intranasal',
	'Intratunnel' => 'Intratunnel',
	'IP' => 'IP',
	'IP' => 'IP',
	'is now an administrator' => 'is now an administrator',
	'IV' => 'IV',
	'January' => 'January',
	'July' => 'July',
	'June' => 'June',
	'Kidney Care Centre' => 'Kidney Care Centre',
	'kilograms' => 'kilograms',
	'lang' => 'en',
	'Language' => 'Language',
	'Last name' => 'Last name',
	'Last updated' => 'Last updated',
	'List saved' => 'List saved',
	'List statistics' => 'List statistics',
	'Living donor identified' => 'Living donor identified',
	'Loading dose given on' => 'Loading dose given on',
	'Loading dose' => 'Loading dose',
	'Location' => 'Location',
	'make admin' => 'make admin',
	'Male' => 'Male',
	'Manage case_uc' => 'Manage case',
	'Manage start_uc' => 'Manage start',
	'manage case' => 'manage case',
	'manage start' => 'manage start',
	'Manage users_uc' => 'Manage users',
	'manage users' => 'manage users',
	'March' => 'March',
	'May' => 'May',
	'Medical contraindication' => 'Medical contraindication',
	'Medical history' => 'Medical history',
	'Message' => 'Message',
	'minute ago' => 'minute ago',
	'minutes ago' => 'minutes ago',
	'mobile' => 'mobile',
	'Modality at 12 months' => 'Modality at 12 months',
	'Modality at 6 months' => 'Modality at 6 months',
	'Modality orientation date' => 'Modality orientation date',
	'Modified' => 'Modified',
	'Modify account' => 'Modify account',
	'moments ago' => 'moments ago',
	'month' => 'month',
	'months ago' => 'months ago',
	'months between episodes' => 'months between episodes',
	'months' => 'months',
	'ACP completion date' => 'ACP completion date',
	'Mr.' => 'Mr.',
	'Ms.' => 'Ms.',
	'Name' => 'Name',
	'Negative cultures' => 'Negative cultures',
	'Nephrologist' => 'Nephrologist',
	'New case' => 'New case',
	'new cases of peritonitis in' => 'new cases of peritonitis in',
	'New password' => 'New password',
	'New patient' => 'New patient',
	'New start' => 'New start',
	'new starts' => 'new starts',
	'Next step' => 'Next step',
	'next' => 'next',
	'No cases found' => 'No cases found',
	'No cases' => 'No cases',
	'No choice made' => 'No choice made',
	'No culture results found' => 'No culture results found',
	'No lab tests found' => 'No lab tests found',
	'No patients found' => 'No patients found',
	'no result' => 'no result',
	'No starts found' => 'No starts found',
	'No, do not delete' => 'No, do not delete',
	'No' => 'No',
	'Nocturnal in-centre hemodialysis' => 'Nocturnal in-centre hemodialysis',
	'none given' => 'none given',
	'none reported' => 'none reported',
	'none' => 'none',
	'Not applicable' => 'Not applicable',
	'not arranged' => 'not arranged',
	'not entered' => 'not entered',
	'not signed in' => 'not signed in',
	'not specified' => 'not specified',
	'not tracked' => 'not tracked',
	'Not tracked' => 'Not tracked',
	'Not yet known' => 'Not yet known',
	'Notifications' => 'Notifications',
	'November' => 'November',
	'now discharged' => 'now discharged',
	'October' => 'October',
	'of cases require hospitalization<br/>during this time period' => 'of cases require hospitalization<br/>during this time period',
	'of cultures yield negative<br/>results during this time period' => 'of cultures yield negative<br/>results during this time period',
	'of' => 'of',
	'On PD' => 'On PD',
	'on' => 'on',
	'only cultures from peritonitis cases are counted' => 'only cultures from peritonitis cases are counted',
	'Onset in hospital' => 'Onset in hospital',
	'Onset' => 'Onset',
	'Open outstanding case' => 'Open outstanding case',
	'Opened' => 'Opened',
	'Operating room' => 'Operating room',
	'or' => 'or',
	'Ordered' => 'Ordered',
	'Other' => 'Other',
	'Outcome' => 'Outcome',
	'Outpatient' => 'Outpatient',
	'Outstanding' => 'Outstanding',
	'Password Recovery' => 'Password Recovery',
	'Password' => 'Password',
	'past cases found in the database' => 'past cases found in the database',
	'Past cases' => 'Past cases',
	'past' => 'past',
	'Pathogens, all infections' => 'Pathogens, all infections',
	'Pathogens, hospitalized patients' => 'Pathogens, hospitalized patients',
	'Pathogens, in exit site infections' => 'Pathogens, in exit site infections',
	'Pathogens, in peritonitis' => 'Pathogens, in peritonitis',
	'Pathogens, in tunnel infections' => 'Pathogens, in tunnel infections',
	'Patient believes home dialysis is inferior care' => 'Patient believes home dialysis is inferior care',
	'Patient interested in transplant' => 'Patient interested in transplant',
	'Patient name' => 'Patient name',
	'Patient weight' => 'Patient weight',
	'patient-months of peritoneal dialysis at risk' => 'patient-months of peritoneal dialysis at risk',
	'Patient&nbsp;name' => 'Patient&nbsp;name',
	'patients at risk' => 'patients at risk',
	'Patients can have only one outstanding case at a time' => 'Patients can have only one outstanding case at a time',
	'patients of' => 'patients of',
	'patients peritonitis-free' => 'patients peritonitis-free',
	'patients with CVC and no AVF' => 'patients with CVC and no AVF',
	'patients without ACP completion date' => 'patients without ACP completion date',
	'patients' => 'patients',
	'PD centre' => 'PD centre',
	'PD Nurse' => 'PD Nurse',
	'Pending' => 'Pending',
	'Peritoneal dialysis (PD)' => 'Peritoneal dialysis (PD)',
	'Peritoneal dialysis fluid' => 'Peritoneal dialysis fluid',
	'Peritoneal dialysis' => 'Peritoneal dialysis',
	'Peritoneoscope' => 'Peritoneoscope',
	'Peritonitis rate' => 'Peritonitis rate',
	'peritonitis' => 'peritonitis',
	'Peritonitis' => 'Peritonitis',
	'Personal information' => 'Personal information',
	'PHN' => 'PHN',
	'Phone (home)' => 'Phone (home)',
	'Phone (mobile)' => 'Phone (mobile)',
	'Phone (work)' => 'Phone (work)',
	'Physician office' => 'Physician office',
	'please create one' => 'please create one',
	'Please enter a patient&quot;s name or PHN or' => 'Please enter a patient&quot;s name or PHN or',
	'Please note that passwords are case sensitive' => 'Please note that passwords are case sensitive',
	'Please provide a temporary password for this user' => 'Please provide a temporary password for this user',
	'Please provide the ACP completion date' => 'Please provide the ACP completion date',
	'Please record the modality at 12 months' => 'Please record the modality at 12 months',
	'Please record the modality at 6 months' => 'Please record the modality at 6 months',
	'Please select a case from the list below or' => 'Please select a case from the list below or',
	'Please select a lab test record to update. If the appropriate lab test requisition is not listed below' => 'Please select a lab test record to update. If the appropriate lab test requisition is not listed below',
	'Please try again or contact technical support for assistance.' => 'Please try again or contact technical support for assistance.',
	'PO' => 'PO',
	'Pre-emptive transplant' => 'Pre-emptive transplant',
	'Preferred dialysis modality' => 'Preferred dialysis modality',
	'Preferred modality' => 'Preferred modality',
	'Preliminary: Acid fast bacillus' => 'Preliminary: Acid fast bacillus',
	'Preliminary: Culture negative' => 'Preliminary: Culture negative',
	'Preliminary: Gram -ve coccus' => 'Preliminary: Gram -ve coccus',
	'Preliminary: Gram +ve bacillus' => 'Preliminary: Gram +ve bacillus',
	'Preliminary: Gram +ve coccus' => 'Preliminary: Gram +ve coccus',
	'Preliminary: Multiple' => 'Preliminary: Multiple',
	'Preliminary: Other' => 'Preliminary: Other',
	'Preliminary: Yeast' => 'Preliminary: Yeast',
	'Preliminary' => 'Preliminary',
	'Presentation date' => 'Presentation date',
	'Presented' => 'Presented',
	'Presternal' => 'Presternal',
	'previous' => 'previous',
	'Primary nurse' => 'Primary nurse',
	'Prior status' => 'Prior status',
	'Proportion of all patients referred for transplant' => 'Proportion of all patients referred for transplant',
	'Proportion of patients introduced to ACP' => 'Proportion of patients introduced to ACP',
	'Proportion of patients who are on HD with VA (AVF or AVG) 12 months after TN intervention' => 'Proportion of patients who are on HD with VA (AVF or AVG) 12 months after TN intervention',
	'Proportion of patients who are on HD with VA (AVF or AVG) 6 months after TN intervention' => 'Proportion of patients who are on HD with VA (AVF or AVG) 6 months after TN intervention',
	'Proportion of patients who are on HHD 12 months after TN intervention' => 'Proportion of patients who are on HHD 12 months after TN intervention',
	'Proportion of patients who are on HHD 6 months after TN intervention' => 'Proportion of patients who are on HHD 6 months after TN intervention',
	'Proportion of patients who are on PD 12 months after TN intervention' => 'Proportion of patients who are on PD 12 months after TN intervention',
	'Proportion of patients who are on PD 6 months after TN intervention' => 'Proportion of patients who are on PD 6 months after TN intervention',
	'Proportion of patients who chose HHD after TN intervention' => 'Proportion of patients who chose HHD after TN intervention',
	'Proportion of patients who chose PD after TN intervention' => 'Proportion of patients who chose PD after TN intervention',
	'Proportion of patients with an identified living donor' => 'Proportion of patients with an identified living donor',
	'psychosocial issues' => 'psychosocial issues',
	'quarter' => 'quarter',
	'quarter' => 'quarter',
	'Range of' => 'Range of',
	'reactivate' => 'reactivate',
	'Reason_uc' => 'Reason',
	'reason' => 'reason',
	'Received' => 'Received',
	'Recurrent' => 'Recurrent',
	'Referred for transplant prior to hemodialysis' => 'Referred for transplant prior to hemodialysis',
	'Refractory' => 'Refractory',
	'Regular' => 'Regular',
	'Relapsing infection' => 'Relapsing infection',
	'Relapsing' => 'Relapsing',
	'Remember patient confidentiality' => 'Remember patient confidentiality',
	'Removal date' => 'Removal date',
	'removed on' => 'removed on',
	'RenalConnect: cloud-based management of dialysis care' => 'RenalConnect: cloud-based management of dialysis care',
	'Repeat password' => 'Repeat password',
	'Repeat' => 'Repeat',
	'reports' => 'reports',
	'Request for Technical Assistance' => 'Request for Technical Assistance',
	'requisition sent' => 'requisition sent',
	'reset' => 'reset',
	'Resolution' => 'Resolution',
	'Results not available' => 'Results not available',
	'Results' => 'Results',
	'return to manage users' => 'return to manage users',
	'return to sign in screen' => 'return to sign in screen',
	'review case' => 'review case',
	'Right now' => 'Right now',
	'Role' => 'Role',
	'Sample type' => 'Sample type',
	'save changes and return' => '&crarr; save changes and return',
	'Save changes' => 'Save changes',
	'Search' => 'Search',
	'Searching...' => 'Searching...',
	'select an antibiotic' => 'select an antibiotic',
	'select pathogen' => 'select pathogen',
	'select stage' => 'select stage',
	'send reminders to this address' => 'send reminders to this address',
	'September' => 'September',
	'Show all alerts' => 'Show all alerts',
	'Sign in' => 'Sign in',
	'Sign off' => 'Sign off',
	'sign out' => 'sign out',
	'six months' => 'six months',
	'Specify &quot;other&quot; modality' => 'Specify &quot;other&quot; modality',
	'Specify &quot;other&quot; reason' => 'Specify &quot;other&quot; reason',
	'Specify case outcome' => 'Specify case outcome',
	'Specify empiric treatment' => 'Specify empiric treatment',
	'Specify final antibiotic' => 'Specify final antibiotic',
	'Specify' => 'Specify',
	'Start date' => 'Start date',
	'starts &gt; 180 days from HD start to TN 1st visit' => 'starts &gt; 180 days from HD start to TN 1st visit',
	'starts &le; 180 days from HD start to TN 1st visit' => 'starts &le; 180 days from HD start to TN 1st visit',
	'starts matching the criteria' => 'starts matching the criteria',
	'starts matching this time frame' => 'starts matching this time frame',
	'starts with data for this calculation' => 'starts with data for this calculation',
	'Status' => 'Status',
	'Stop date' => 'Stop date',
	'stop' => 'stop',
	'stopped' => 'stopped',
	'Straight' => 'Straight',
	'Submit' => 'Submit',
	'Surgeon' => 'Surgeon',
	'Surgery' => 'Surgery',
	'Swab of exit site' => 'Swab of exit site',
	'Switch to' => 'Switch to',
	'Tasks' => 'Tasks',
	'The account for' => 'The account for',
	'The administrator user cannot be created' => 'The administrator user cannot be created',
	'The patient' => 'The patient',
	'There are currently no active cases to display' => 'There are currently no active cases to display',
	'There are currently no active starts to display' => 'There are currently no active starts to display',
	'There are no applicable alerts for this view' => 'There are no applicable alerts for this view',
	'This case has been deleted' => 'This case has been deleted',
	'This information has been deleted' => 'This information has been deleted',
	'TN assessment' => 'TN assessment',
	'to be determined' => 'to be determined',
	'to see all cases' => 'to see all cases',
	'to see all lists' => 'to see all lists',
	'to' => 'to',
	'Topical' => 'Topical',
	'total cultures ordered' => 'total cultures ordered',
	'Total of' => 'Total of',
	'Transition Nurse' => 'Transition Nurse',
	'Transplant imminent' => 'Transplant imminent',
	'Transplant' => 'Transplant',
	'Treatment' => 'Treatment',
	'tunnel' => 'tunnel',
	'Tunnel' => 'Tunnel',
	'two years' => 'two years',
	'Unhide all active cases' => 'Unhide all active cases',
	'Unhide all active starts' => 'Unhide all active starts',
	'Unknown acute' => 'Unknown acute',
	'Unknown chronic' => 'Unknown chronic',
	'Unknown' => 'Unknown',
	'Update password' => 'Update password',
	'update results' => 'update results',
	'updated' => 'updated',
	'Use the MATCH-D tool' => 'Use the MATCH-D tool',
	'User information saved' => 'User information saved',
	'User information' => 'User information',
	'User type' => 'User type',
	'Vascular access at HD start' => 'Vascular access at HD start',
	'Vascular access' => 'Vascular access',
	'view dismissed alerts' => 'view dismissed alerts',
	'View latest open case' => 'View latest open case',
	'View latest open start' => 'View latest open start',
	'View patient information' => 'View patient information',
	'View' => 'View',
	'w_about_renalconnect' => 'RenalConnect is a clinical management tool developed in British Columbia to improve quality of care and patient outcome in dialysis.',
	'w_alert_cannot_add_patient' => qq{<span class="b">This patient's information cannot be added.</span> Please ensure that all required fields are completed correctly and try again.},
	qq{w_alert_code_230} => qq{Please follow-up on this new patient.},
	qq{w_alert_code_240} => qq{Please follow-up on this new patient to document treatment modality at 6 months.},
	qq{w_alert_code_250} => qq{Please follow-up on this new patient to document treatment modality at 12 months.},
	'w_alert_code_10' => "Please reconsider the Vancomycin dose for this patient, it is below the recommended minimum of 20 mg/kg.",
	'w_alert_code_110' => "Preliminary culture results not arrived.",
	'w_alert_code_120' => "Final culture results not arrived.",
	'w_alert_code_15' => "This patient is on fluconazole. Please consider drug interactions including statins.",
	'w_alert_code_20' => "This patient has MRSA. Please review this patient's antibiotics to ensure that it is appropriate for this organism.",
	'w_alert_code_200' => "Preliminary culture results updated",
	'w_alert_code_210' => "Final culture results updated",
	'w_alert_code_220' => 'Telephone follow-up recommended this patient.',
	'w_alert_code_30' => qq{This patient has a fungal infection. Peritoneal dialysis catheter should ideally removed within 24 hours. <a href="http://www.pdiconnect.com/cgi/content/abstract/31/1/60?etoc" target="blank">view reference</a>},
	'w_alert_code_5' => "Please reconsider the Tobramycin or Gentamicin dose for this patient, as it may be too high.",
	'w_alert_code_90' => "Please consider fluconazole prophylaxis for this patient.",
	'w_auto_sign_out_notice' => '<span class="b">To help protect patient confidentiality, the screen has been locked.</span> Please re-enter your password to continue working.',
	'w_confirm_delete_case' => qq{<span class="b">Are you sure you want to delete this case?</span> Cases should not be deleted unless they were created in error. This action cannot be undone, however, a record of this case will still be kept in the archive for auditing purposes. If you are unsure, please contact your group leader before proceeding.},
	'w_confirm_delete_information' => qq{<span class="b">Are you sure you want to delete this information?</span> This information must not be deleted unless it was created in error. This action cannot be undone. However, a record of it will still be kept in the archive for auditing purposes. If you are unsure, please contact your group leader before proceeding.},
	'w_email_bring_pd_reminder_body' => 'Our records indicate that your antibiotic regimen is complete. Please remember to bring your PD bag for follow-up culture as soon as possible.',
	'w_email_bring_pd_reminder_subject' => 'Reminder to bring PD bag for follow-up culture',
	'w_error_cannot_add_antibiotic' => qq{<span class="b">This antibiotic treatment cannot be added.</span> Please ensure that all required fields are completed correctly and try again.},
	'w_error_cannot_add_case' => qq{<span class="b">This case cannot be added.</span> Please ensure that all required fields are completed correctly and try again.},
	'w_error_cannot_add_user' => qq{<span class="b">This user cannot be added.</span> Please ensure that all required fields are completed correctly and try again.},
	'w_error_cannot_save_user' => qq{<span class="b">User information cannot be saved.</span> Please complete all required fields and try again.},
	'w_error_cant_sign_off' => qq{<span class="b">This case cannot be signed off.</span> Please ensure that all required fields, as marked by the red bullets, are completed and try again.},
	'w_error_case_antibiotic_start_invalid' => 'This antibiotic treatment cannot be saved because the start date appears to be invalid.',
	'w_error_case_antibiotic_start_stop_invalid' => 'This antibiotic treatment cannot be saved because the cancellation (premature stop) date occurs before the start date.',
	'w_error_case_antibiotic_stop_invalid' => qq{This antibiotic treatment cannot be saved because the cancellation (premature stop) date appears to be invalid.},
	'w_error_case_catheter_start_invalid' => 'This catheter information cannot be saved because the insertion date appears to be invalid.',
	'w_error_case_catheter_start_stop_invalid' => 'This catheter information cannot be saved because the removal date is earlier than the insertion date.',
	'w_error_case_catheter_stop_invalid' => 'This catheter information cannot be saved because the removal date appears to be invalid.',
	'w_error_case_dialysis_start_invalid' => 'This dialysis information cannot be saved because the start date appears to be invalid.',
	'w_error_case_dialysis_start_stop_invalid' => 'This dialysis information cannot be saved because the stop date is earlier than the start date.',
	'w_error_case_dialysis_stop_invalid' => 'This dialysis information cannot be saved because the stop date appears to be invalid.',
	'w_error_case_hospitalization_date_invalid' => qq{This case cannot be saved because the hospitalization start date appears to be invalid.},
	'w_error_case_hospitalization_end_date_invalid' => qq{This case cannot be saved because the hospitalization end date appears to be invalid.},
	'w_error_case_hospitalization_start_end_date_invalid' => qq{This case cannot be saved because the hospitalization end date is earlier than the start date.},
	'w_error_case_presentation_invalid' => qq{This case cannot be saved because the presentation date appears to be invalid.},
	'w_error_date_format' => qq{Please ensure that the date is entered correctly in the format of YYYY-MM-DD and try again.},
	'w_error_email_doesnt_exist' => qq{<div class="emp"><span class="b">The user with the email address provided is currently not a registered and active user in the system.</span> Please contact your peritoneal dialysis team leader for further assistance.</div>},
	'w_error_information_cant_be_saved' => qq{<span class="b">This information cannot be processed.</span> Please ensure that all required fields are completed correctly and try again.},
	'w_error_no_home_center' => qq{<span class="b">This case cannot be saved.</span> Please ensure that a home centre is provided and try again.},
	'w_error_password_cannot_update' => qq{<span class="b">Your password cannot be updated.</span> Please ensure that you have entered a new password and try again.},
	'w_error_password_repeat_dont_match' => qq{<span class="b">Your password cannot be updated because your new passwords do not match.</span> Please ensure that you have re-entered the same new password twice and try again.},
	'w_error_password_too_short' => qq{<span class="b">The new password is too short.</span> Please enter a password that is at least 8 characters in length. Ensure that all required fields are completed correctly and try again.},
	'w_error_passwords_dont_match' => qq{<span class="b">Your password cannot be updated because your existing password does not match with the password we have on file.</span> Please ensure that you have entered the correct case sensitive existing password and try again.},
	'w_error_patient_dob_invalid' => qq{This patient's information cannot be saved because the patient's date of birth appears to be invalid.},
	'w_error_patient_pd_invalid' => qq{This patient's information cannot be saved because the patient's PD start date appears to be invalid.},
	'w_error_patient_pd_start_stop_invalid' => qq{<span class="b">This patient's information cannot be saved because the patient's PD start date occurs after the stop date.</span> Please ensure that the start date occurs before the stop date and try again.},
	'w_error_patient_pd_stop_invalid' => qq{This patient's information cannot be saved because the patient's PD stop date appears to be invalid.},
	'w_error_patient_phn_already_exists' => qq{This patient's information could not be saved because another patient with the same PHN number already exists in the database.},
	'w_error_same_email' => qq{<span class="b">A user with this email address already exists in the database.</span> Please enter a different email address, ensure that all required fields are completed correctly and try again.},
	'w_error_user_complete_all' => qq{<span class="b">This user cannot be added.</span> Please ensure that all required fields are completed correctly and try again.},
	'w_incorrect_email_or_password' => '<span class="b">You have provided an incorrect email or password.</span> Please try again.',
	'w_no_administrator' => '<span class="b">This installation does not have an administrator.</span> Please take this opportunity to create an administrator account. For assistance, please click on the <span class="b">Get technical support</span> link.',
	'w_password_blurb' => qq{Have you lost your password? You may use this form to reset your password by email. Please enter your RenalConnect email address and then submit the form, to have a temporary password sent to your email address. If you can't remember the email address you use to access this system, or if you are unsure whether you have an account, please ask your peritoneal dialysis team leader.},
	'w_password_email_1' => qq{Hello,\n\nSomeone, hopefully you, have requested to reset your password for your RenalConnect application. Your password has been reset to:},
	'w_password_email_2' => qq{Please use the following updated account information to access RenalConnect.},
	'w_password_email_3' => qq{We strongly recommend that you delete this email and create a new, personalized password immediately.},
	'w_request_blurb' => 'If you are experiencing technical difficulties using the system, or if you believe you have come across a software malfunction, please fill out and submit the form below to notify your RenalConnect team, who will be able to assist you promptly. Please provide a call-back telephone number in the message if possible.',
	'w_request_confirmed' => qq{<div class="suc"><span class="b">Your request for assistance has been sent.</span> Please check your email account in the next few minutes for a confirmation. If you do not receive the email in the next hour, please check your junk mail folder, or contact your peritoneal dialysis team leader for further assistance.</div><div><a href="index.pl" class="b">&laquo; return to sign in screen</a> | <a href="support.pl">submit another support request</a></div>},
	'w_request_letter_part_1' => qq{Hello,\n\nA request for technical assistance was sent from your RenalConnect application on behalf of},
	'w_request_letter_part_2' => qq{(start of message)},
	'w_request_letter_part_3' => qq{(end of message)},
	'w_success_case_info_added' => qq{<span class="b">Case information updated.</span> What would you like to do now?},
	'w_success_new_password_sent' => qq{<div class="suc"><span class="b">A temporary password has been sent to your email.</span> Please check your email account in the next few minutes. If you do not receive the email in the next hour, please check your junk mail folder, or contact your peritoneal dialysis team leader for further assistance.</div>},
	'w_success_password_updated' => qq{<span class="b">Your password has been updated.</span>},
	'w_success_patient_info_added' => qq{<span class="b">Patient information added.</span> What would you like to do now?},
	'w_success_patient_info_updated' => qq{<span class="b">Patient information updated.</span> What would you like to do now?},
	'w_success_user_added' => qq{<span class="b">New user added.</span> What would you like to do now?},
	'weeks ago' => 'weeks ago',
	'Weight' => 'Weight',
	'work' => 'work',
	'year' => 'year',
	'years ago' => 'years ago',
	'Yes' => 'Yes',
	'yesterday' => 'yesterday',
	'You are using an outdated browser that is ten years old.' => 'You are using an outdated browser that is ten years old.',
	'You have a new patient in RenalConnect' => 'You have a new patient in RenalConnect',
	'You have a new patient who has started hemodialysis at' => 'You have a new patient who has started hemodialysis at',
	'You have no alerts at this time.' => 'You have no alerts at this time.',
	'you' => 'you',
	'Your account' => 'Your account'
);
my %lang_fr = (
	qq{Recovered from dialysis dependance?} => qq{Remis de dialyse dépendance?},
	qq{Status at initial meeting} => qq{Statut lors de la première réunion},
	qq{Pre-dialysis} => qq{Avant de dialyse},
	qq{Hemodialysis} => qq{Hémodialyse},
	qq{Recovered} => qq{Rétabli},
	qq{From PD referral to PD catheter insertion} => qq{Depuis le renvoi de l'PD à l'insertion d'un cathéter de DP},
	qq{From PD referral to PD start} => qq{Depuis le renvoi de l'PD au début de la DP},
	qq{Data point} => qq{Point de données},
	qq{Duration} => qq{Durée},
	qq{Date 1} => qq{Datte 1},
	qq{Date 2} => qq{Datte 2},
	qq{Unlock} => qq{Ouvrir},
	qq{Yes, but not referred at this time} => qq{Oui, mais pas visé},
	qq{median} => qq{médiane},
	qq{(closed)} => qq{(fermé)},
	qq{(mean)} => qq{(moyenne)},
	qq{(no culture taken)} => qq{(pas de culture prise)},
	qq{account settings} => qq{Paramètres du compte},
	qq{Account type} => qq{Type de compte},
	qq{ACP introduced} => qq{PPS offerte},
	qq{Active case} => qq{Cas actif},
	qq{active cases} => qq{Cas actifs},
	qq{Active list} => qq{Liste active},
	qq{active starts} => qq{En cours},
	qq{Active_uc} => qq{Actif},
	qq{active} => qq{actif},
	qq{Add a new case for this patient} => qq{Ajouter un nouveau cas pour ce patient},
	qq{Add a new patient} => qq{Ajouter un nouveau patient},
	qq{Add antibiotic treatment} => qq{Ajouter traitement antibiotique},
	qq{add case} => qq{Ajouter cas},
	qq{Add catheter information} => qq{Ajouter des informations sur le cathéter},
	qq{Add culture result} => qq{Ajouter résultat de la culture},
	qq{Add dialysis information} => qq{Ajouter des informations sur la dialyse},
	qq{Add lab test} => qq{Ajouter test de laboratoire},
	qq{Add new user} => qq{Ajouter un nouvel utilisateur},
	qq{add patient} => qq{Ajouter patient},
	qq{Add peritoneal dialysis information} => qq{Ajouter des informations sur la dialyse péritonéale},
	qq{add start} => qq{Ajouter nouveau traitement},
	qq{Add treatment} => qq{Ajouter traitement},
	qq{admin} => qq{admin},
	qq{administrator} => qq{administrateur},
	qq{Admit date} => qq{Date d'admission},
	qq{Admitted} => qq{Admis},
	qq{Advance care planning} => qq{Planification préalable des soins de santé},
	qq{after TN intervention} => qq{après intervention infirmière de transition},
	qq{alerts} => qq{Alertes},
	qq{all cases} => qq{Tous les cas},
	qq{All centres_uc} => qq{Tous les centres},
	qq{all centres} => qq{tous les centres},
	qq{all patients} => qq{tous les patients},
	qq{all starts} => qq{Tous},
	qq{Allergies} => qq{Allergies},
	qq{already has an outstanding case that was last updated} => qq{a déjà un cas en suspens qui a été mis à jour},
	qq{and is followed by a transition nurse} => qq{et est suivi par une infirmière de transition},
	qq{Antibiotic treatment} => qq{Traitement antibiotique},
	qq{Antibiotic} => qq{Antibiotique},
	qq{Antibiotics given} => qq{Antibiotiques administrés},
	qq{Antibiotics, as empiric treatment (peritonitis only)} => qq{Antibiotiques, comme traitement empirique (péritonite seulement)},
	qq{Antibiotics, as final treatment (peritonitis only)} => qq{Antibiotiques, comme traitement final (péritonite seulement)},
	qq{Antibiotics} => qq{Antibiotiques},
	qq{April} => qq{Avril},
	qq{Arrange follow-up in} => qq{Prévoir un suivi en},
	qq{Arrange home visit} => qq{Organiser une visite à domicile},
	qq{at} => qq{à},
	qq{attend} => qq{assister},
	qq{August} => qq{Août},
	qq{AV fistula (AVF)} => qq{Fistule AV (FAV)},
	qq{AV graft (AVG)} => qq{Greffe AV (GAV)},
	qq{Basis} => qq{Base},
	qq{Bedside} => qq{Chevet},
	qq{Blind insertion} => qq{Insertion à l'aveugle},
	qq{Blood culture} => qq{Hémoculture},
	qq{by the system} => qq{par le système},
	qq{by} => qq{par},
	qq{cancel} => qq{annuler},
	qq{Candidate for home dialysis} => qq{Candidat pour la dialyse à domicile},
	qq{Case information} => qq{Informations sur le cas},
	qq{Case statistics} => qq{Statistiques sur le cas},
	qq{Case type} => qq{Type de cas},
	qq{case(s)} => qq{cas},
	qq{Case&nbsp;details} => qq{Détails du cas},
	qq{cases in total} => qq{cas au total},
	qq{cases requiring hospitalization} => qq{cas nécessitant une hospitalisation},
	qq{Cases} => qq{Cas},
	qq{Catheter details} => qq{Détails sur le cathéter},
	qq{Catheter information} => qq{Informations sur le cathéter},
	qq{Catheter removal and death} => qq{Retrait du cathéter et décès},
	qq{Catheter removal} => qq{Retrait du cathéter},
	qq{Catheter type} => qq{Type de cathéter},
	qq{Catheter-related} => qq{Lié au cathéter},
	qq{cc this email when reminders are sent to patients} => qq{Mettre cette adresse courriel en cc quand les rappels sont envoyés aux patients},
	qq{Central venous catheter (CVC)} => qq{Cathéter veineux central (CVC)},
	qq{change} => qq{changement},
	qq{Checklist} => qq{Liste de vérification},
	qq{choose another patient} => qq{choisir un autre patient},
	qq{Chosen modality} => qq{Modalité choisie},
	qq{Click here} => qq{Cliquez ici},
	qq{Clinical Pharmacist} => qq{Pharmacien clinique},
	qq{Close this box} => qq{Fermer cette fenêtre},
	qq{Closed case} => qq{Cas fermé},
	qq{Closed list} => qq{Liste fermée},
	qq{Closed_uc} => qq{Fermé},
	qq{closed} => qq{fermé},
	qq{Co-morbidities} => qq{Comorbidités},
	qq{cognitive impairment} => qq{déficience cognitive},
	qq{Collect follow-up culture} => qq{Recueillir la culture de suivi},
	qq{Comments} => qq{Commentaires},
	qq{Community alert} => qq{Alerte communautaire},
	qq{Community hemodialysis} => qq{Hémodialyse communautaire},
	qq{Complete antibiotic course} => qq{Cours d'antibiothérapie terminé},
	qq{Completed} => qq{Terminé},
	qq{Conservative (no dialysis)} => qq{Conservateur (pas de dialyse)},
	qq{Convenience} => qq{Commodité},
	qq{course completed} => qq{Cours terminé},
	qq{create a case} => qq{créer un cas},
	qq{create a new start} => qq{créer un nouveau traitement},
	qq{Create case} => qq{Créer un cas },
	qq{Create start} => qq{Créer un nouveau traitement},
	qq{Created} => qq{Créé},
	qq{Culture details} => qq{Détails de la culture},
	qq{Culture report} => qq{Rapport de la culture},
	qq{Culture result} => qq{Résultat de la culture},
	qq{Culture results} => qq{Résultats de la culture},
	qq{Culture} => qq{Culture},
	qq{cultures negative} => qq{cultures négatives},
	qq{cultures} => qq{Cultures},
	qq{Curled} => qq{Enroulé},
	qq{Current status} => qq{État actuel},
	qq{CVC with AVF or AVG} => qq{CVC avec FAV ou GAV},
	qq{Database encryption key} => qq{Clé de chiffrement de la base de données},
	qq{Date of AV access creation} => qq{Date de création de l'accès AV},
	qq{Date of birth} => qq{Date de naissance},
	qq{Date of first AV access use} => qq{Date de la première utilisation de l'accès AV},
	qq{Date of first hemodialysis (HD)} => qq{Date de première hémodialyse (HD)},
	qq{Date of HHD referral} => qq{Date d'orientation en HDD},
	qq{Date of HHD start} => qq{Date de début HDD},
	qq{Date of initial TN assessment} => qq{Date de l'évaluation initiale},
	qq{Date of ACP completion} => qq{Date d'achèvement d'OMPT},
	qq{Date of PD cath insertion} => qq{Date d'insertion du cathéter de DP},
	qq{Date of PD referral} => qq{Date d'orientation en DP},
	qq{Date of PD start} => qq{Date de début de la DP},
	qq{Date of TN sign off} => qq{Date de déconnexion de l'infirmière de transition},
	qq{Date of transplant referral} => qq{Date de recommandation de la greffe},
	qq{Date of transplantation} => qq{Date de la greffe},
	qq{Date of VA referral} => qq{Date d'orientation pour un AV},
	qq{Date ordered} => qq{Date de commande},
	qq{day} => qq{jour},
	qq{days ago} => qq{jours passés},
	qq{days starting on} => qq{jours à partir du},
	qq{days} => qq{jours},
	qq{De novo} => qq{De novo},
	qq{deactivate} => qq{désactiver},
	qq{deactivated} => qq{désactivé},
	qq{Dear} => qq{Cher},
	qq{Death} => qq{Décès},
	qq{Deceased} => qq{Décédé},
	qq{December} => qq{Décembre},
	qq{Declined} => qq{Refusé},
	qq{Delete antibiotic treatment} => qq{Supprimer un traitement antibiotique},
	qq{Delete case} => qq{Supprimer cas},
	qq{Delete catheter information} => qq{Supprimer les informations sur le cathéter},
	qq{Delete culture result} => qq{Supprimer résultat culture},
	qq{Delete dialysis information} => qq{Supprimer les informations sur la dialyse},
	qq{delete} => qq{effacer},
	qq{diabetes} => qq{diabète},
	qq{Dialysis centre} => qq{Centre de dialyse},
	qq{Dialysis details} => qq{Détails de dialyse},
	qq{Dialysis information} => qq{Informations de dialyse},
	qq{Dialysis type} => qq{Type de dialyse},
	qq{discard changes and return} => qq{annuler les modifications et retour},
	qq{Discharge date} => qq{Date de sortie},
	qq{dismiss} => qq{rejeter},
	qq{Dismissed alerts} => qq{Alertes rejetées},
	qq{Dismissed} => qq{Rejeté},
	qq{Displaying cases for} => qq{Afficher cas pour},
	qq{Displaying lists for} => qq{Afficher listes pour},
	qq{Dose and route} => qq{Dose et voie d'administration},
	qq{duration set to} => qq{durée fixée à},
	qq{Email_uc} => qq{Courriel},
	qq{email} => qq{Courriel},
	qq{Empiric antibiotics} => qq{Antibiotiques empiriques},
	qq{empiric} => qq{empirique},
	qq{enter a new case} => qq{entrer un nouveau dossier},
	qq{enter the patient} => qq{entrer le patient},
	qq{Existing password} => qq{Mot de passe existant},
	qq{exit site} => qq{point de sortie},
	qq{Exit site} => qq{Site de sortie},
	qq{Failed home dialysis in the past} => qq{Échec dialyse à domicile par le passé},
	qq{Failed peritoneal dialysis in the past} => qq{Échec dialyse péritonéale par le passé},
	qq{February} => qq{Février},
	qq{Female} => qq{Femme},
	qq{Filter by patient name} => qq{Filtrer selon le nom du patient},
	qq{Final antibiotics} => qq{Derniers antibiotiques},
	qq{Final_uc} => qq{Finale},
	qq{Final: (Gram -ve) Acinetobacter species} => qq{Final: (Gram -ve) espèce Acinetobacter},
	qq{Final: (Gram -ve) Citrobacter species} => qq{Final: (Gram -ve) espèce Citrobacter},
	qq{Final: (Gram -ve) Enterobacter species} => qq{Final: (Gram -ve) espèce Enterobacter},
	qq{Final: (Gram -ve) Escherichia coli} => qq{Final: (Gram -ve) Escherichia coli},
	qq{Final: (Gram -ve) Gram negative organisms, other} => qq{Final: (Gram -ve) organismes Gram négatifs, autre},
	qq{Final: (Gram -ve) Klebsiella species} => qq{Final: (Gram -ve) espèce Klebsiella},
	qq{Final: (Gram -ve) Neisseria species} => qq{Final: (Gram -ve) espèce Neisseria},
	qq{Final: (Gram -ve) Proteus mirabilis} => qq{Final: (Gram -ve) Proteus mirabilis},
	qq{Final: (Gram -ve) Pseudomonas species} => qq{Final: (Gram -ve) espèces Pseudomonas},
	qq{Final: (Gram -ve) Serratia marcescens} => qq{Final: (Gram -ve) Serratia marcescens},
	qq{Final: (Gram +ve) Clostridium species} => qq{Final: (Gram +ve) espèce de Clostridium},
	qq{Final: (Gram +ve) Corynebacteria species} => qq{Final: (Gram +ve) espèce de corynebactéries},
	qq{Final: (Gram +ve) Diptheroids} => qq{Final: (Gram +ve) Dipthéroïdes},
	qq{Final: (Gram +ve) Enterococcus species} => qq{Final: (Gram +ve) espèce d'entérocoque},
	qq{Final: (Gram +ve) Gram positive organisms, other} => qq{Final: (Gram +ve) organismes Gram positifs, d'autres},
	qq{Final: (Gram +ve) Lactobacillus} => qq{Final: (Gram +ve) Lactobacille},
	qq{Final: (Gram +ve) Propionibacterium} => qq{Final: (Gram +ve) Propionibacterium},
	qq{Final: (Gram +ve) Staphylococcus aureus (MRSA)} => qq{Final: (Gram +ve) Staphylococcus aureus (SARM)},
	qq{Final: (Gram +ve) Staphylococcus aureus (MSSA)} => qq{Final: (Gram +ve) Staphylococcus aureus (SASM)},
	qq{Final: (Gram +ve) Staphylococcus aureus (sensitivity unknown)} => qq{Final: (Gram +ve) Staphylococcus aureus (sensibilité inconnue)},
	qq{Final: (Gram +ve) Staphylococcus epidermidis} => qq{Final: (Gram +ve) Staphylococcus epidermidis},
	qq{Final: (Gram +ve) Staphylococcus species, coagulase negative} => qq{Final: (Gram +ve) espèce Staphylococcus coagulase négative},
	qq{Final: (Gram +ve) Staphylococcus species} => qq{Final: (Gram +ve) espèce de staphylocoque},
	qq{Final: (Gram +ve) Streptococcus species} => qq{Final: (Gram +ve) espèce de streptocoque},
	qq{Final: (Yeast) Candida species} => qq{Final: (levures) espèce de Candida},
	qq{Final: (Yeast) Other species} => qq{Final: (levures) Autre espèce},
	qq{Final: Anaerobes} => qq{Final: Anaérobies},
	qq{Final: Culture negative} => qq{Final: Culture négative},
	qq{Final: Multiple} => qq{Final: Multiple},
	qq{Final: Mycobacterium tuberculosis} => qq{Final: Mycobacterium tuberculosis},
	qq{Final: Other} => qq{Final: Autres},
	qq{final} => qq{final},
	qq{First assessment} => qq{Première évaluation},
	qq{first before proceeding to enter a new case or adding a lab test requisition or antibiotic treatment to that case} => qq{avant de procéder pour entrer un nouveau cas ou d'ajouter une demande de test de laboratoire ou un traitement antibiotique pour ce cas},
	qq{first before proceeding to enter a new case or adding a lab test requisition to that case} => qq{avant de procéder pour entrer un nouveau cas ou d'ajouter une demande de test de laboratoire pour ce cas},
	qq{First name} => qq{Prénom},
	qq{Follow-up and outcome} => qq{Suivi et résultat},
	qq{Follow-up comments} => qq{Commentaires de suivi},
	qq{Follow-up culture} => qq{Culture de suivi},
	qq{Follow-up date} => qq{Date de suivi},
	qq{Follow-up visit} => qq{Visite de suivi},
	qq{For best results, please upgrade to the latest release of} => qq{Pour de meilleurs résultats, veuillez installer la dernière version de},
	qq{For patients with CVC} => qq{Pour les patients avec CVC},
	qq{for} => qq{pour},
	qq{For} => qq{Pour},
	qq{found} => qq{trouvé},
	qq{From HD start to first TN assessment} => qq{Depuis le début de l'HD à la première évaluation de l'infirmière de transition},
	qq{From HD start to HHD referral} => qq{Depuis le début de l'HD à l'orientation vers l'HDD},
	qq{From HD start to HHD start} => qq{Depuis le début de l'HD à l'HDD},
	qq{From HD start to ACP completion} => qq{Depuis le début de l'HD à l'achèvement de l'OMPT},
	qq{From HD start to PD catheter insertion} => qq{Depuis le début de l'HD à l'insertion d'un cathéter de DP},
	qq{From HD start to PD referral} => qq{Depuis le début de l'HD à l'orientation en DP},
	qq{From HD start to PD start} => qq{Depuis le début de l'HD au début de la DP},
	qq{From HD start to transplant operation} => qq{Depuis le début de l'HD à l'intervention chirurgicale de la greffe},
	qq{From HD start to transplant referral} => qq{Depuis le début de l'HD à la recommandation d'une greffe},
	qq{From HD start to VA referral for patients who chose HD} => qq{Depuis le début de l'HD à le renvoi d'un AV pour les patients qui ont choisi l'HD},
	qq{From HD start to VA creation for patients who chose HD} => qq{Depuis le début de l'HD à la création d'un AV pour les patients qui ont choisi l'HD},
	qq{From HD start to VA use for patients who chose HD} => qq{Depuis le début de l'HD à l'utilisation d'un AV pour les patients qui ont choisi l'HD},
	qq{from} => qq{de},
	qq{Gender} => qq{Sexe},
	qq{General comments} => qq{Observations générales},
	qq{Get culture result} => qq{Obtenir le résultat de la culture},
	qq{Get final culture result} => qq{Obtenir le résultat final de la culture},
	qq{Get technical support} => qq{Obtenir du soutien technique},
	qq{go to page} => qq{Aller à la page},
	qq{Go} => qq{Aller},
	qq{has been deactivated} => qq{a été désactivé},
	qq{hidden for today} => qq{caché pour aujourd'hui},
	qq{Hide} => qq{Cacher},
	qq{Home centre} => qq{Centre},
	qq{Home hemodialysis (HHD)} => qq{Hémodialyse à domicile (HDD)},
	qq{Home hemodialysis} => qq{Hémodialyse à domicile},
	qq{Home visit} => qq{Visite à domicile},
	qq{home} => qq{maison},
	qq{Hospitalization} => qq{Hospitalisation},
	qq{Hospitalized} => qq{Hospitalisé},
	qq{hour ago} => qq{heure passée},
	qq{hours ago} => qq{heures passées},
	qq{I forgot my password} => qq{J'ai oublié mon mot de passe},
	qq{If the patient is not in this system, please} => qq{Si le patient n'est pas dans ce système, veuillez},
	qq{IM} => qq{IM},
	qq{In-centre hemodialysis} => qq{Hémodialyse en centre},
	qq{In-centre or community hemodialysis} => qq{Hémodialyse en centre ou centre communautaire},
	qq{Inadequate access to assistance} => qq{Accès inadéquat à l'assistance},
	qq{Inadequate social support} => qq{Appui social inadéquat},
	qq{Include} => qq{Inclure},
	qq{inclusive} => qq{inclusivement},
	qq{indicates required fields} => qq{Indique les champs obligatoires},
	qq{Infection type} => qq{Type d'infection},
	qq{Infection} => qq{Infection},
	qq{Initial %PMN on diff} => qq{\% granulocyte initiale sur l'analyse},
	qq{Initial %PMN:} => qq{% granulocyte initiale:},
	qq{Initial meeting} => qq{Première réunion},
	qq{Initial WBC count} => qq{Numération leucocytaire initiale},
	qq{Initial WBC} => qq{Numération leucocytaire initiale},
	qq{inserted on} => qq{inséré le},
	qq{Insertion date} => qq{Date d'insertion},
	qq{Insertion location} => qq{Emplacement d'insertion},
	qq{Insertion method} => qq{Procédé d'insertion},
	qq{Insufficient dexterity} => qq{Dextérité insuffisante},
	qq{Intranasal} => qq{Intranasale},
	qq{Intratunnel} => qq{Intratunnel},
	qq{IP} => qq{IP},
	qq{is now an administrator} => qq{est maintenant un administrateur},
	qq{IV} => qq{i.v.},
	qq{January} => qq{Janvier},
	qq{July} => qq{Juillet},
	qq{June} => qq{Juin},
	qq{Kidney Care Centre} => qq{Centre de soins néphrologiques},
	qq{kilograms} => qq{kilogrammes},
	qq{lang} => qq{fr},
	qq{Language} => qq{Langue},
	qq{Last name} => qq{Nom},
	qq{Last updated} => qq{Dernière mise à jour},
	qq{List saved} => qq{Liste sauvegardée},
	qq{List statistics} => qq{Statistiques de la liste},
	qq{Living donor identified} => qq{Donneur vivant identifié},
	qq{Loading dose given on} => qq{Dose de charge donnée le},
	qq{Loading dose} => qq{Dose de charge},
	qq{Location} => qq{Emplacement},
	qq{make admin} => qq{Donner droits admin},
	qq{Male} => qq{Masculin},
	qq{Manage case_uc} => qq{Gérer cas},
	qq{Manage start_uc} => qq{Gérer nouveau traitement},
	qq{manage case} => qq{Gérer cas},
	qq{manage start} => qq{Gérer nouveau traitement},
	qq{Manage users_uc} => qq{Gérer les utilisateurs},
	qq{manage users} => qq{Gérer les utilisateurs},
	qq{March} => qq{Mars},
	qq{May} => qq{Mai},
	qq{Medical contraindication} => qq{Contre-indication médicale},
	qq{Medical history} => qq{Antécédents médicaux},
	qq{Message} => qq{Message},
	qq{minute ago} => qq{minute passée},
	qq{minutes ago} => qq{minutes passées},
	qq{mobile} => qq{mobile},
	qq{Modality at 12 months} => qq{Modalité à 12 mois},
	qq{Modality at 6 months} => qq{Modalité à 6 mois},
	qq{Modality orientation date} => qq{Date d'orientation sur les modalités},
	qq{Modified} => qq{Modifié},
	qq{Modify account} => qq{Modifier un compte},
	qq{moments ago} => qq{moments passés},
	qq{month} => qq{mois},
	qq{months ago} => qq{mois passés},
	qq{months between episodes} => qq{mois entre les épisodes},
	qq{months} => qq{mois},
	qq{ACP completion date} => qq{Date d'achèvement de OMPT},
	qq{Mr.} => qq{M.},
	qq{Ms.} => qq{Mme},
	qq{Name} => qq{Nom},
	qq{Negative cultures} => qq{Cultures négatives},
	qq{Nephrologist} => qq{Néphrologue},
	qq{New case} => qq{Nouveau cas},
	qq{new cases of peritonitis in} => qq{nouveaux cas de péritonite chez},
	qq{New password} => qq{Nouveau mot de passe},
	qq{New patient} => qq{Nouveau patient},
	qq{New start} => qq{Nouveau traitement},
	qq{new starts} => qq{Nouveaux traitements},
	qq{Next step} => qq{Prochaine étape},
	qq{next} => qq{Suivant},
	qq{No cases found} => qq{Pas de cas identifiés},
	qq{No cases} => qq{Aucun cas},
	qq{No choice made} => qq{Pas de choix fait},
	qq{No culture results found} => qq{Aucun résultat de culture},
	qq{No lab tests found} => qq{Pas de tests de laboratoire trouvés},
	qq{No patients found} => qq{Aucun patient trouvé},
	qq{no result} => qq{aucun résultat},
	qq{No starts found} => qq{Pas de mises en chantier trouvés},
	qq{No, do not delete} => qq{Non, ne pas supprimer},
	qq{No} => qq{Aucun},
	qq{Nocturnal in-centre hemodialysis} => qq{Hémodialyse de nuit en centre},
	qq{none given} => qq{aucun donné},
	qq{none reported} => qq{aucun signalé},
	qq{none} => qq{aucun},
	qq{Not applicable} => qq{Sans objet},
	qq{not arranged} => qq{non organisé},
	qq{not entered} => qq{pas entré},
	qq{not signed in} => qq{non inscrit},
	qq{not specified} => qq{non spécifié},
	qq{Not tracked} => qq{Pas enregistré},
	qq{not tracked} => qq{pas suivi},
	qq{Not yet known} => qq{Pas encore connu},
	qq{Notifications} => qq{Notifications},
	qq{November} => qq{Novembre},
	qq{now discharged} => qq{a reçu son congé depuis},
	qq{October} => qq{Octobre},
	qq{of cases require hospitalization<br/>during this time period} => qq{des cas nécessitent une hospitalisation<br/>au cours de cette période},
	qq{of cultures yield negative<br/>results during this time period} => qq{des cultures donnent des résultats négatifs<br/>au cours de cette période},
	qq{of} => qq{de},
	qq{On PD} => qq{Sous DP},
	qq{on} => qq{sur},
	qq{only cultures from peritonitis cases are counted} => qq{Seules les cultures de cas de péritonite sont comptées},
	qq{Onset in hospital} => qq{Apparition à l'hôpital},
	qq{Onset} => qq{Début},
	qq{Open outstanding case} => qq{Cas ouvert en suspens},
	qq{Opened} => qq{Ouvert},
	qq{Operating room} => qq{Salle d'opération},
	qq{or} => qq{ou},
	qq{Ordered} => qq{Ordonné},
	qq{Other} => qq{Autre},
	qq{Outcome} => qq{Résultat},
	qq{Outpatient} => qq{Ambulatoire},
	qq{Outstanding} => qq{En suspens},
	qq{Password Recovery} => qq{Récupération de mot de passe},
	qq{Password} => qq{Mot de passe},
	qq{past cases found in the database} => qq{cas antérieurs trouvés dans la base de données},
	qq{Past cases} => qq{Cas antérieurs},
	qq{past} => qq{passé},
	qq{Pathogens, all infections} => qq{Pathogènes, toutes les infections},
	qq{Pathogens, hospitalized patients} => qq{Pathogènes, patients hospitalisés},
	qq{Pathogens, in exit site infections} => qq{Pathogènes, infections des points de sortie},
	qq{Pathogens, in peritonitis} => qq{Pathogènes, cas de péritonite},
	qq{Pathogens, in tunnel infections} => qq{Pathogènes, infections des tunnels},
	qq{Patient believes home dialysis is inferior care} => qq{Le patient croit que la dialyse à domicile est un traitement inférieur},
	qq{Patient interested in transplant} => qq{Patient qui souhaite une greffe},
	qq{Patient name} => qq{Nom du patient},
	qq{Patient weight} => qq{Poids du patient},
	qq{patient-months of peritoneal dialysis at risk} => qq{patients-mois de dialyse péritonéale à risque},
	qq{Patient&nbsp;name} => qq{Nom du patient},
	qq{patients at risk} => qq{patient(s) à risque},
	qq{Patients can have only one outstanding case at a time} => qq{Les patients peuvent n'avoir qu'un seul cas en suspens à la fois},
	qq{patients of} => qq{patients de},
	qq{patients peritonitis-free} => qq{patients sans péritonite},
	qq{patients with CVC and no AVF} => qq{patients avec CVC et sans FAV},
	qq{patients without ACP completion date} => qq{patients sans date d'achèvement d'OMPT},
	qq{patients} => qq{Patients},
	qq{PD centre} => qq{Centre de DP},
	qq{PD Nurse} => qq{Infirmière de DP},
	qq{Pending} => qq{En attente},
	qq{Peritoneal dialysis (PD)} => qq{Dialyse péritonéale (DP)},
	qq{Peritoneal dialysis fluid} => qq{Solution de dialyse péritonéale},
	qq{Peritoneal dialysis} => qq{Dialyse péritonéale},
	qq{Peritoneoscope} => qq{Péritonéoscope},
	qq{Peritonitis rate} => qq{Taux de péritonite},
	qq{peritonitis} => qq{Péritonite},
	qq{Peritonitis} => qq{Péritonite},
	qq{Personal information} => qq{Renseignements personnels},
	qq{PHN} => qq{Numéro de carte d'assurance-maladie du patient},
	qq{Phone (home)} => qq{Téléphone (domicile)},
	qq{Phone (mobile)} => qq{Téléphone (mobile)},
	qq{Phone (work)} => qq{Téléphone (travail)},
	qq{Physician office} => qq{Cabinet médical},
	qq{please create one} => qq{veuillez créer un},
	qq{Please enter a patient&quot;s name or PHN or} => qq{Veuillez entrer le nom d'un patient ou le numéro de carte d'assurance-maladie du patient ou},
	qq{Please note that passwords are case sensitive} => qq{Veuillez noter que les mots de passe sont sensibles à la casse},
	qq{Please provide a temporary password for this user} => qq{Veuillez fournir un mot de passe temporaire pour cet utilisateur}, 
	qq{Please provide the ACP completion date} => qq{Veuillez fournir la date d'achèvement d'OMPT},
	qq{Please record the modality at 12 months} => qq{Veuillez noter la modalité à 12 mois},
	qq{Please record the modality at 6 months} => qq{Veuillez noter la modalité à 6 mois},
	qq{Please select a case from the list below or} => qq{Veuillez sélectionner un cas dans la liste ci-dessous ou},
	qq{Please select a lab test record to update. If the appropriate lab test requisition is not listed below} => qq{Veuillez sélectionner un dossier de test de laboratoire à mettre à jour. Si la demande de test de laboratoire approprié n'est pas répertoriée ci-dessous},
	qq{Please try again or contact technical support for assistance.} => qq{Veuillez essayer de nouveau ou communiquer avec le soutien technique pour assistance.},
	qq{PO} => qq{P.O.},
	qq{Pre-emptive transplant} => qq{Greffe préemptive},
	qq{Preferred dialysis modality} => qq{Modalité de dialyse préférée},
	qq{Preferred modality} => qq{Modalité préférée},
	qq{Preliminary: Acid fast bacillus} => qq{Préliminaire: acide bacille rapide},
	qq{Preliminary: Culture negative} => qq{Préliminaire: culture négative},
	qq{Preliminary: Gram -ve coccus} => qq{Préliminaire: Gram -ve coccus},
	qq{Preliminary: Gram +ve bacillus} => qq{Préliminaire: Gram +ve bacille},
	qq{Preliminary: Gram +ve coccus} => qq{Préliminaire: Gram +ve coccus},
	qq{Preliminary: Multiple} => qq{Préliminaire: multiple},
	qq{Preliminary: Other} => qq{Préliminaire: autre},
	qq{Preliminary: Yeast} => qq{Préliminaire: levure},
	qq{Preliminary} => qq{Préliminaire},
	qq{Presentation date} => qq{Date de la présentation},
	qq{Presented} => qq{Présenté},
	qq{Presternal} => qq{Présternal},
	qq{previous} => qq{Précédent},
	qq{Primary nurse} => qq{Infirmière primaire},
	qq{Prior status} => qq{Statut précédent},
	qq{Proportion of all patients referred for transplant} => qq{Proportion de tous les patients pour lesquels une greffe a été recommandée},
	qq{Proportion of patients introduced to ACP} => qq{Proportion de patients ayant bénéficié d'une planification préalable des soins},
	qq{Proportion of patients who are on HD with VA (AVF or AVG) 12 months after TN intervention} => qq{Proportion de patients qui sont sous HD avec AV (FAV ou GAV) 12 mois après l'intervention de l'infirmière de transition},
	qq{Proportion of patients who are on HD with VA (AVF or AVG) 6 months after TN intervention} => qq{Proportion de patients qui sont sous HD avec AV (FAV ou GAV) 6 mois après l'intervention de l'infirmière de transition},
	qq{Proportion of patients who are on HHD 12 months after TN intervention} => qq{Proportion de patients qui sont sous HDD 12 mois après l'intervention de l'infirmière de transition},
	qq{Proportion of patients who are on HHD 6 months after TN intervention} => qq{Proportion de patients qui sont sous HDD 6 mois après l'intervention de l'infirmière de transition},
	qq{Proportion of patients who are on PD 12 months after TN intervention} => qq{Proportion de patients qui sont sous DP 12 mois après l'intervention de l'infirmière de transition},
	qq{Proportion of patients who are on PD 6 months after TN intervention} => qq{Proportion de patients qui sont sous DP 6 mois après l'intervention de l'infirmière de transition},
	qq{Proportion of patients who chose HHD after TN intervention} => qq{Proportion de patients qui ont choisi l'HDD après l'intervention de l'infirmière de transition},
	qq{Proportion of patients who chose PD after TN intervention} => qq{Proportion de patients qui ont choisi la DP après l'intervention de l'infirmière de transition},
	qq{Proportion of patients with an identified living donor} => qq{Proportion de patients avec un donneur vivant identifié},
	qq{psychosocial issues} => qq{problèmes psychosociaux},
	qq{quarter} => qq{trimestre},
	qq{Range of} => qq{Échelle de},
	qq{reactivate} => qq{réactiver},
	qq{Reason_uc} => qq{Raison},
	qq{reason} => qq{raison},
	qq{Received} => qq{Reçu},
	qq{Recurrent} => qq{Récurrent},
	qq{Referred for transplant prior to hemodialysis} => qq{Greffe recommandée avant hémodialyse},
	qq{Refractory} => qq{Réfractaire},
	qq{Regular} => qq{Ordinaire},
	qq{Relapsing infection} => qq{Infection récurrente},
	qq{Relapsing} => qq{Récurrente},
	qq{Remember patient confidentiality} => qq{N'oubliez pas la confidentialité des renseignements du patient},
	qq{Removal date} => qq{Date de retrait},
	qq{removed on} => qq{retiré le},
	qq{RenalConnect: cloud-based management of dialysis care} => qq{RenalConnect: gestion en nuage des soins de dialyse},
	qq{Repeat password} => qq{Répéter mot de passe},
	qq{Repeat} => qq{Répéter},
	qq{reports} => qq{Rapports},
	qq{Request for Technical Assistance} => qq{Demande d'assistance technique},
	qq{requisition sent} => qq{réquisition envoyée},
	qq{reset} => qq{Réinitialiser},
	qq{Resolution} => qq{Résolution},
	qq{Results not available} => qq{Résultats non disponibles},
	qq{Results} => qq{Résultats},
	qq{return to manage users} => qq{retourner à gérer les utilisateurs},
	qq{return to sign in screen} => qq{retourner à l'écran d'entrée en session},
	qq{review case} => qq{Examiner le cas},
	qq{Right now} => qq{Pour le moment},
	qq{Role} => qq{Rôle},
	qq{Sample type} => qq{Type d'échantillon},
	qq{save changes and return} => qq{enregistrer les modifications et retour},
	qq{Save changes} => qq{Enregistrer les modifications},
	qq{Search} => qq{Recherche},
	qq{Searching...} => qq{Recherche en cours...},
	qq{select an antibiotic} => qq{sélectionner un antibiotique},
	qq{select pathogen} => qq{sélectionner un pathogène},
	qq{select stage} => qq{sélectionner un stade},
	qq{send reminders to this address} => qq{Envoyer des rappels à cette adresse},
	qq{September} => qq{Septembre},
	qq{Show all alerts} => qq{Voir toutes les alertes},
	qq{Sign in} => qq{Entrer en session},
	qq{Sign off} => qq{Terminer la session},
	qq{sign out} => qq{Se déconnecter},
	qq{six months} => qq{six mois},
	qq{Specify &quot;other&quot; modality} => qq{Spécifier « autre » modalité},
	qq{Specify &quot;other&quot; reason} => qq{Spécifier « autre » raison},
	qq{Specify case outcome} => qq{Spécifier résultat du cas},
	qq{Specify empiric treatment} => qq{Spécifier un traitement empirique},
	qq{Specify final antibiotic} => qq{Spécifier un dernier antibiotique },
	qq{Specify} => qq{Spécifier},
	qq{Start date} => qq{Date du nouveau traitement},
	qq{starts &gt; 180 days from HD start to TN 1st visit} => qq{Nouveau départ &gt; 180 jours du début de l'HD à la première visite de l'infirmière de transition},
	qq{starts &le; 180 days from HD start to TN 1st visit} => qq{Nouveau départ &le; 180 jours du début de l'HD à la première visite de l'infirmière de transition},
	qq{starts matching the criteria} => qq{nouveaux départs correspondant aux critères},
	qq{starts matching this time frame} => qq{nouveaux départs correspondant à cette période},
	qq{starts with data for this calculation} => qq{nouveaux départs avec des données pour ce calcul},
	qq{Status} => qq{État},
	qq{Stop date} => qq{Date d'arrêt},
	qq{stop} => qq{arrêter},
	qq{stopped} => qq{arrêté},
	qq{Straight} => qq{Droit},
	qq{Submit} => qq{Soumettre},
	qq{Surgeon} => qq{Chirurgien},
	qq{Surgery} => qq{Chirurgie},
	qq{Swab of exit site} => qq{Prélèvement au point de sortie},
	qq{Switch to} => qq{Passer à},
	qq{Tasks} => qq{Tâches},
	qq{The account for} => qq{Le compte pour},
	qq{The administrator user cannot be created} => qq{L'utilisateur de l'administrateur ne peut pas être créé},
	qq{The patient} => qq{Le patient},
	qq{There are currently no active cases to display} => qq{Il n'y a pas de cas actifs à afficher},
	qq{There are currently no active starts to display} => qq{Il n'y a pas de nouveaux départs en cours à afficher},
	qq{There are no applicable alerts for this view} => qq{Il n'y a aucune alerte pour cet écran},
	qq{This case has been deleted} => qq{Ce cas a été supprimé},
	qq{This information has been deleted} => qq{Cette information a été supprimée},
	qq{TN assessment} => qq{Évaluation de l'infirmière de transition},
	qq{to be determined} => qq{à déterminer},
	qq{to see all cases} => qq{voir tous les cas},
	qq{to see all lists} => qq{voir toutes les listes},
	qq{to} => qq{à},
	qq{Topical} => qq{Topique},
	qq{total cultures ordered} => qq{cultures demandées au total},
	qq{Total of} => qq{Total de},
	qq{Transition Nurse} => qq{Infirmière de transition},
	qq{Transplant imminent} => qq{Greffe imminente},
	qq{Transplant} => qq{Greffe},
	qq{Treatment} => qq{Traitement},
	qq{tunnel} => qq{tunnel},
	qq{Tunnel} => qq{Tunnel},
	qq{two years} => qq{deux années},
	qq{Unhide all active cases} => qq{Afficher tous les cas actifs},
	qq{Unhide all active starts} => qq{Afficher tous les nouveaux départs actifs},
	qq{Unknown acute} => qq{Aigu inconnu},
	qq{Unknown chronic} => qq{Chronique inconnu},
	qq{Unknown} => qq{Inconnu},
	qq{Update password} => qq{Mettre à jour le mot de passe},
	qq{update results} => qq{Mettre à jour les résultats},
	qq{updated} => qq{mis à jour},
	qq{Use the MATCH-D tool} => qq{Utiliser l'outil MATCH-D},
	qq{User information saved} => qq{Informations sur l'utilisateur enregistrées},
	qq{User information} => qq{Informations sur l'utilisateur},
	qq{User type} => qq{Type d'utilisateur},
	qq{Vascular access at HD start} => qq{Accès vasculaire au début de l'HD},
	qq{Vascular access} => qq{Accès vasculaire},
	qq{view dismissed alerts} => qq{Voir alertes rejetées},
	qq{View latest open case} => qq{Voir le dernier cas ouvert},
	qq{View latest open start} => qq{Voir le dernier départ ouvert},
	qq{View patient information} => qq{Voir l'information sur le patient},
	qq{View} => qq{Voir},
	qq{w_about_renalconnect} => qq{RenalConnect est un outil de gestion clinique développé en Colombie-Britannique afin d'améliorer la qualité des soins et les résultats des patients en dialyse.},
	qq{w_alert_cannot_add_patient} => qq{<span class="b">L'information de ce patient ne peut être ajouté.</span> S'il vous plaît assurez-vous que tous les champs obligatoires sont remplis correctement et essayez à nouveau.},
	qq{w_alert_code_10} => qq{S'il vous plaît reconsidérer la dose de vancomycine pour ce patient, il est inférieur au minimum recommandé de 20 mg/kg.},
	qq{w_alert_code_110} => qq{Résultats de la culture préliminaires pas arrivés.},
	qq{w_alert_code_120} => qq{Résultats de la culture finales pas arrivés.},
	qq{w_alert_code_15} => qq{Ce patient est sur le fluconazole. S'il vous plaît envisager les interactions médicamenteuses, y compris les statines.},
	qq{w_alert_code_20} => qq{Ce patient a MRSA. S'il vous plaît examiner les antibiotiques de ce patient pour s'assurer qu'il est approprié pour cet organisme.},
	qq{w_alert_code_200} => qq{Résultats de la culture préliminaires à jour},
	qq{w_alert_code_210} => qq{Résultats de culture final mis à jour},
	qq{w_alert_code_220} => qq{Un suivi téléphonique a recommandé ce patient.},
	qq{w_alert_code_30} => qq{Ce patient a une infection fongique. Cathéter de dialyse péritonéale devrait idéalement retiré dans les 24 heures. <a href="http://www.pdiconnect.com/cgi/content/abstract/31/1/60?etoc" target="blank">référence de vue</a>},
	qq{w_alert_code_5} => qq{S'il vous plaît reconsidérer la dose de tobramycine ou la gentamicine pour ce patient, car il peut être trop élevé.},
	qq{w_alert_code_90} => qq{S'il vous plaît envisager une prophylaxie au fluconazole pour ce patient.},
	qq{w_alert_code_230} => qq{S'il vous plaît suivi sur ce nouveau patient.},
	qq{w_alert_code_240} => qq{S'il vous plaît le suivi de ce nouveau patient pour discuter des modalités de traitement à six mois.},
	qq{w_alert_code_250} => qq{S'il vous plaît le suivi de ce nouveau patient pour discuter des modalités de traitement à 12 mois.},
	qq{w_auto_sign_out_notice} => qq{<span class="b">Pour aider à protéger la confidentialité du patient, l'écran a été verrouillé.</span> S'il vous plaît entrer de nouveau votre mot de passe pour continuer à travailler.},
	qq{w_confirm_delete_case} => qq{<span class="b">Etes-vous sûr de vouloir supprimer ce cas? Cas ne doivent pas être supprimés, sauf si elles ont été créées dans l'erreur.</span> Cette action ne peut pas être annulée, cependant, un dossier de cette affaire sera toujours conservé dans les archives à des fins de vérification. Si vous n'êtes pas sûr, s'il vous plaît communiquer avec votre chef de groupe avant de poursuivre.},
	qq{w_confirm_delete_information} => qq{<span class="b">Etes-vous sûr de vouloir supprimer ces informations? Cette information ne doit pas être supprimé, sauf si elle a été créée dans l'erreur.</span> Cette action ne peut être annulée. Cependant, un dossier de celui-ci sera toujours conservé dans les archives à des fins de vérification. Si vous n'êtes pas sûr, s'il vous plaît communiquer avec votre chef de groupe avant de poursuivre.},
	qq{w_email_bring_pd_reminder_body} => qq{Nos dossiers indiquent que votre traitement antibiotique est terminé. S'il vous plaît n'oubliez pas d'apporter votre sac de PD pour la culture de suivi dès que possible.},
	qq{w_email_bring_pd_reminder_subject} => qq{Rappel d'apporter sac de PD pour la culture de suivi},
	qq{w_error_cannot_add_antibiotic} => qq{<span class="b">Ce traitement antibiotique ne peut pas être ajouté.</span> S'il vous plaît assurez-vous que tous les champs obligatoires sont remplis correctement et essayez à nouveau.},
	qq{w_error_cannot_add_case} => qq{<span class="b">Cette affaire ne peut pas être ajouté.</span> S'il vous plaît assurez-vous que tous les champs obligatoires sont remplis correctement et essayez à nouveau.},
	qq{w_error_cannot_add_user} => qq{<span class="b">Cet utilisateur ne peut pas être ajouté.</span> S'il vous plaît assurez-vous que tous les champs obligatoires sont remplis correctement et essayez à nouveau.},
	qq{w_error_cannot_save_user} => qq{<span class="b">Informations de l'utilisateur ne peut être sauvé.</span> S'il vous plaît remplir tous les champs nécessaires et essayez à nouveau.},
	qq{w_error_cant_sign_off} => qq{<span class="b">Cette affaire ne peut pas être signé.</span> S'il vous plaît assurez-vous que tous les champs obligatoires, comme marqué par les balles rouges, sont terminées et essayez à nouveau.},
	qq{w_error_case_antibiotic_start_invalid} => qq{Ce traitement antibiotique ne peut être sauvé, car la date de lancement semble être invalide.},
	qq{w_error_case_antibiotic_start_stop_invalid} => qq{Ce traitement antibiotique ne peut être sauvé, car la date d'annulation (arrêt prématuré) survient avant la date de lancement.},
	qq{w_error_case_antibiotic_stop_invalid} => qq{Ce traitement antibiotique ne peut être sauvé, car la date d'annulation (arrêt prématuré) semble être invalide.},
	qq{w_error_case_catheter_start_invalid} => qq{Cette information de cathéter ne peut être sauvé, car la date d'insertion semble être invalide.},
	qq{w_error_case_catheter_start_stop_invalid} => qq{Cette information de cathéter ne peut être sauvé, car la date de sortie est antérieure à la date d'insertion.},
	qq{w_error_case_catheter_stop_invalid} => qq{Cette information de cathéter ne peut être sauvé, car la date de l'enlèvement semble être invalide.},
	qq{w_error_case_dialysis_start_invalid} => qq{Cette information de dialyse ne peut être sauvé, car la date de lancement semble être invalide.},
	qq{w_error_case_dialysis_start_stop_invalid} => qq{Cette information de dialyse ne peut être sauvée parce que la date d'arrêt est antérieure à la date de début.},
	qq{w_error_case_dialysis_stop_invalid} => qq{Cette information de dialyse ne peut être sauvée parce que la date d'arrêt semble être invalide.},
	qq{w_error_case_hospitalization_date_invalid} => qq{Ce cas ne peut être sauvé, car la date de début de l'hospitalisation semble être invalide.},
	qq{w_error_case_hospitalization_end_date_invalid} => qq{Ce cas ne peut être sauvé, car la date de fin d'hospitalisation semble être invalide.},
	qq{w_error_case_hospitalization_start_end_date_invalid} => qq{Ce cas ne peut être sauvé, car la date de fin d'hospitalisation est antérieure à la date de début.},
	qq{w_error_case_presentation_invalid} => qq{Ce cas ne peut être sauvé, car la date de présentation semble être invalide.},
	qq{w_error_date_format} => qq{S'il vous plaît assurez-vous que la date est entré correctement dans le format AAAA-MM-JJ et essayez à nouveau.},
	qq{w_error_email_doesnt_exist} => qq{<div class="emp"><span class="b">L'utilisateur avec l'adresse e-mail fournie n'est actuellement pas un utilisateur enregistré et actif dans le système.</span> S'il vous plaît contacter votre chef d'équipe de dialyse péritonéale pour obtenir de l'aide.</div>},
	qq{w_error_information_cant_be_saved} => qq{<span class="b">Cette information ne peut pas être traitée.</span> S'il vous plaît s'assurer que tous les champs obligatoires sont remplis correctement et essayez à nouveau.},
	qq{w_error_no_home_center} => qq{<span class="b">Cette affaire ne peut pas être sauvé.</span> S'il vous plaît assurez-vous que d'un centre d'accueil est disponible et essayez à nouveau.},
	qq{w_error_password_cannot_update} => qq{<span class="b">Votre mot de passe ne peut pas être mis à jour.</span> S'il vous plaît vous assurer que vous avez entré un nouveau mot de passe et essayez de nouveau.},
	qq{w_error_password_repeat_dont_match} => qq{<span class="b">Votre mot de passe ne peut pas être mis à jour car vos nouveaux mots de passe ne correspondent pas.</span> S'il vous plaît vous assurer que vous avez réintégré le même nouveau mot de passe deux fois et essayer à nouveau.},
	qq{w_error_password_too_short} => qq{<span class="b">Le nouveau mot de passe est trop court.</span> S'il vous plaît entrer un mot de passe d'au moins 8 caractères. Assurez-vous que tous les champs obligatoires sont remplis correctement et essayez à nouveau.},
	qq{w_error_passwords_dont_match} => qq{<span class="b">Votre mot de passe ne peut pas être mise à jour parce que votre mot de passe existant ne correspond pas avec le mot de passe que nous avons sur le dossier.</span> S'il vous plaît vous assurer que vous avez entré le mot de passe existant sensible correcte des cas et essayer à nouveau.},
	qq{w_error_patient_dob_invalid} => qq{L'information de ce patient ne peut pas être enregistré car la date de naissance du patient semble être invalide.},
	qq{w_error_patient_pd_invalid} => qq{L'information de ce patient ne peut pas être enregistré car péritonéale date de début de dialyse du patient semble être invalide.},
	qq{w_error_patient_pd_start_stop_invalid} => qq{<span class="b">L'information de ce patient ne peut pas être enregistré car péritonéale date de début de dialyse du patient se produit après la date d'arrêt.</span> S'il vous plaît assurez-vous que la date de début survient avant la date d'arrêt et essayez à nouveau.},
	qq{w_error_patient_pd_stop_invalid} => qq{L'information de ce patient ne peut pas être enregistré car dialyse péritonéale date d' arrêt du patient semble être invalide.},
	qq{w_error_patient_phn_already_exists} => qq{L'information de ce malade n'a pas pu être enregistré car un autre patient avec le même nombre de santé existe déjà dans la base de données.},
	qq{w_error_same_email} => qq{<span class="b">Un utilisateur avec cette adresse e-mail existe déjà dans la base de données.</span> S'il vous plaît entrer une adresse e-mail différente, veiller à ce que tous les champs obligatoires sont remplis correctement et essayez à nouveau.},
	qq{w_error_user_complete_all} => qq{<span class="b">Cet utilisateur ne peut pas être ajouté.</span> S'il vous plaît s'assurer que tous les champs obligatoires sont remplis correctement et essayez à nouveau.},
	qq{w_incorrect_email_or_password} => qq{<span class="b">Vous avez fourni un e-mail ou mot de passe incorrect.</span> S'il vous plaît essayez de nouveau.},
	qq{w_no_administrator} => qq{<span class="b">Cette installation ne dispose pas d'un administrateur.</span> S'il vous plaît profiter de cette occasion pour créer un compte d'administrateur. Pour de l'aide, s'il vous plaît cliquer sur le lien de support technique obtenir.},
	qq{w_password_blurb} => qq{Avez-vous perdu votre mot de passe? Vous pouvez utiliser ce formulaire pour réinitialiser votre mot de passe par email. S'il vous plaît, entrez votre adresse e-mail RenalConnect puis soumettre le formulaire, d'avoir un mot de passe temporaire envoyé à votre adresse e-mail. Si vous ne vous souvenez pas de l'adresse e-mail que vous utilisez pour accéder à ce système, ou si vous ne savez pas si vous avez un compte, s'il vous plaît demander à votre chef d'équipe de dialyse péritonéale.},
	qq{w_password_email_1} => qq{Bonjour,\n\nQuelqu'un, j'espère que vous, ont demandé pour réinitialiser votre mot de passe pour votre application RenalConnect. Votre mot de passe a été réinitialisé à:},
	qq{w_password_email_2} => qq{S'il vous plaît utiliser les informations de compte à jour ci-dessous pour accéder à RenalConnect.},
	qq{w_password_email_3} => qq{Nous vous recommandons fortement de supprimer ce message et de créer immédiatement un nouveau mot de passe personnalisé.},
	qq{w_request_blurb} => qq{Si vous éprouvez des difficultés techniques en utilisant le système, ou si vous croyez que vous avez rencontré un dysfonctionnement du logiciel, s'il vous plaît remplir et soumettre le formulaire ci-dessous pour informer votre équipe de RenalConnect, qui sera en mesure de vous aider rapidement. S'il vous plaît fournir un numéro de téléphone de rappel dans le message si possible.},
	qq{w_request_confirmed} => qq{<div class="suc"><span class="b">Votre demande d'assistance a été envoyé.</span> S'il vous plaît vérifier votre compte e-mail dans les prochaines minutes pour une confirmation. Si vous ne recevez pas le mail dans les prochaines heures, s'il vous plaît vérifier votre dossier de courrier indésirable, ou communiquez avec votre chef d'équipe de dialyse péritonéale pour obtenir de l'aide.</div><div><a href="index.pl" class="b">&laquo; retourner à signer dans l'écran</a> | <a href="support.pl">présenter une autre demande de soutien</a></div>},
	qq{w_request_letter_part_1} => qq{Bonjour,\n\nUne demande d'assistance technique a été envoyé à partir de votre application RenalConnect au nom de},
	qq{w_request_letter_part_2} => qq{(début du message)},
	qq{w_request_letter_part_3} => qq{(fin du message)},
	qq{w_success_case_info_added} => qq{<span class="b">Les informations sur les cas de mise à jour.</span> Que souhaitez-vous faire maintenant?},
	qq{w_success_new_password_sent} => qq{<div class="suc"><span class="b">Un mot de passe temporaire a été envoyé à votre adresse email.</span> S'il vous plaît vérifier votre compte e-mail dans les prochaines minutes. Si vous ne recevez pas le mail dans les prochaines heures, s'il vous plaît vérifier votre dossier de courrier indésirable, ou communiquez avec votre chef d'équipe de dialyse péritonéale pour obtenir de l'aide.</div>},
	qq{w_success_password_updated} => qq{<span class="b">Votre mot de passe a été mis à jour.</span>},
	qq{w_success_patient_info_added} => qq{<span class="b">L'information des patients ajouté.</span> Que souhaitez-vous faire maintenant?},
	qq{w_success_patient_info_updated} => qq{<span class="b">L'information des patients mis à jour.</span> Que souhaitez-vous faire maintenant?},
	qq{w_success_user_added} => qq{<span class="b">Nouvel utilisateur ajouté.</span> Que souhaitez-vous faire maintenant?},
	qq{weeks ago} => qq{semaines passées},
	qq{Weight} => qq{Poids},
	qq{work} => qq{travail},
	qq{year} => qq{année},
	qq{years ago} => qq{années passées},
	qq{Yes} => qq{Oui},
	qq{yesterday} => qq{hier},
	qq{You are using an outdated browser that is ten years old.} => qq{Vous utilisez un navigateur obsolète qui a dix ans.},
	qq{You have a new patient in RenalConnect} => qq{Vous avez un nouveau patient dans RenalConnect},
	qq{You have a new patient who has started hemodialysis at} => qq{Vous avez un nouveau patient qui a commencé l'hémodialyse à},
	qq{You have no alerts at this time.} => qq{Vous n'avez pas d'alertes pour le moment.},
	qq{you} => qq{vous},
	qq{Your account} => qq{Votre compte}
);
my %lang_es = (
	qq{Recovered from dialysis dependance?} => qq{Recuperado de la dependencia de diálisis?},
	qq{Status at initial meeting} => qq{Estado en la reunión inicial},
	qq{Pre-dialysis} => qq{Antes de la diálisis},
	qq{Hemodialysis} => qq{Hemodiálisis},
	qq{Recovered} => qq{Recuperado},
	qq{From PD referral to PD catheter insertion} => qq{De remisión de la DP a la inserción del catéter de DP},
	qq{From PD referral to PD start} => qq{De remisión de la DP a la inicio de la DP},
	qq{Data point} => qq{Punto de datos},
	qq{Duration} => qq{Duración},
	qq{Date 1} => qq{Fecha 1},
	qq{Date 2} => qq{Fecha 2},
	qq{Unlock} => qq{Descubrir},
	qq{Yes, but not referred at this time} => qq{Sí, pero no se hace referencia},
	qq{median} => qq{mediana},
	qq{(closed)} => qq{(cerrado)},
	qq{(mean)} => qq{(promedio)},
	qq{(no culture taken)} => qq{(sin cultivo tomado)},
	qq{account settings} => qq{cuenta},
	qq{Account type} => qq{Tipo de cuenta},
	qq{ACP introduced} => qq{APC introducido},
	qq{Active case} => qq{Activa de casos},
	qq{active cases} => qq{casos activos},
	qq{Active list} => qq{Escala activa},
	qq{active starts} => qq{inicio activas},
	qq{Active_uc} => qq{Activo},
	qq{active} => qq{activo},
	qq{Add a new case for this patient} => qq{Añadir un nuevo caso de este paciente},
	qq{Add a new patient} => qq{Agregar un nuevo paciente},
	qq{Add antibiotic treatment} => qq{Añadir tratamiento antibiótico},
	qq{add case} => qq{agregar caso},
	qq{Add catheter information} => qq{Añadir información catéter},
	qq{Add culture result} => qq{Añade resultado del cultivo},
	qq{Add dialysis information} => qq{Agregar información de la diálisis},
	qq{Add lab test} => qq{Añadir la prueba de laboratorio},
	qq{Add new user} => qq{Añadir nuevo usuario},
	qq{add patient} => qq{añadir paciente},
	qq{Add peritoneal dialysis information} => qq{Agregar información de la diálisis peritoneal},
	qq{add start} => qq{añadir comienzo},
	qq{Add treatment} => qq{Añadir tratamiento},
	qq{admin} => qq{administración},
	qq{administrator} => qq{administrador},
	qq{Admit date} => qq{Fecha admita},
	qq{Admitted} => qq{Admitidos},
	qq{Advance care planning} => qq{Avanzar en la planificación del cuidado},
	qq{after TN intervention} => qq{después de la intervención enfermera},
	qq{alerts} => qq{alertas},
	qq{all cases} => qq{todos los casos},
	qq{All centres_uc} => qq{Todos los centros},
	qq{all centres} => qq{todos los centros},
	qq{all patients} => qq{todos los pacientes},
	qq{all starts} => qq{todo inicio},
	qq{Allergies} => qq{Alergias},
	qq{already has an outstanding case that was last updated} => qq{ya tiene un caso pendiente que se actualizó por última vez},
	qq{and is followed by a transition nurse} => qq{y es seguido por una enfermera de transición},
	qq{Antibiotic treatment} => qq{El tratamiento con antibióticos},
	qq{Antibiotic} => qq{Antibiótico},
	qq{Antibiotics given} => qq{Los antibióticos administrados},
	qq{Antibiotics, as empiric treatment (peritonitis only)} => qq{Los antibióticos, como tratamiento empírico (peritonitis solamente)},
	qq{Antibiotics, as final treatment (peritonitis only)} => qq{Los antibióticos, como tratamiento final (sólo la peritonitis)},
	qq{Antibiotics} => qq{Antibióticos},
	qq{April} => qq{Abril},
	qq{Arrange follow-up in} => qq{Organizar el seguimiento en},
	qq{Arrange home visit} => qq{Organizar visita domiciliaria},
	qq{at} => qq{en},
	qq{attend} => qq{asistir},
	qq{August} => qq{Agosto},
	qq{AV fistula (AVF)} => qq{Fístula AV (FAV)},
	qq{AV graft (AVG)} => qq{Injerto AV (IAV)},
	qq{Basis} => qq{Base},
	qq{Bedside} => qq{Cabecera},
	qq{Blind insertion} => qq{La inserción a ciegas},
	qq{Blood culture} => qq{Un cultivo de sangre},
	qq{by the system} => qq{por el sistema de},
	qq{by} => qq{por},
	qq{cancel} => qq{cancelar},
	qq{Candidate for home dialysis} => qq{Candidato a la diálisis en el hogar},
	qq{Case information} => qq{Información del caso},
	qq{Case statistics} => qq{Estadísticas de casos},
	qq{Case type} => qq{Tipo de caso},
	qq{case(s)} => qq{casos},
	qq{Case&nbsp;details} => qq{Detalles del caso},
	qq{cases in total} => qq{casos en total},
	qq{cases requiring hospitalization} => qq{casos que requirieron hospitalización},
	qq{Cases} => qq{Casos},
	qq{Catheter details} => qq{Detalles catéter},
	qq{Catheter information} => qq{Información catéter},
	qq{Catheter removal and death} => qq{Remoción del catéter y la muerte},
	qq{Catheter removal} => qq{Remoción del catéter},
	qq{Catheter type} => qq{Tipo de catéter},
	qq{Catheter-related} => qq{Asociada a catéter},
	qq{cc this email when reminders are sent to patients} => qq{enviar copia de este correo electrónico cuando se envían recordatorios a los pacientes},
	qq{Central venous catheter (CVC)} => qq{Catéter venoso central (CVC)},
	qq{change} => qq{cambio},
	qq{Checklist} => qq{Lista de verificación},
	qq{choose another patient} => qq{elegir otro paciente},
	qq{Chosen modality} => qq{Modalidad elegida},
	qq{Click here} => qq{Haga clic aquí},
	qq{Clinical Pharmacist} => qq{Farmacéutico clínico},
	qq{Close this box} => qq{Cierra este cuadro},
	qq{Closed case} => qq{Caso cerrado},
	qq{Closed list} => qq{Lista cerrada},
	qq{Closed_uc} => qq{Cerrado},
	qq{closed} => qq{cerrado},
	qq{Co-morbidities} => qq{Comorbilidades},
	qq{cognitive impairment} => qq{deterioro cognitivo},
	qq{Collect follow-up culture} => qq{Recoger cultura seguimiento},
	qq{Comments} => qq{Comentarios},
	qq{Community alert} => qq{Comunitario de alerta},
	qq{Community hemodialysis} => qq{Hemodiálisis comunidad},
	qq{Complete antibiotic course} => qq{Curso completo de antibióticos},
	qq{Completed} => qq{Completado},
	qq{Conservative (no dialysis)} => qq{Conservador (sin diálisis)},
	qq{Convenience} => qq{Conveniencia},
	qq{course completed} => qq{curso completo},
	qq{create a case} => qq{crear un caso},
	qq{create a new start} => qq{crear un nuevo punto de partida},
	qq{Create case} => qq{Crea caso},
	qq{Create start} => qq{Cree inicio},
	qq{Created} => qq{Creado},
	qq{Culture details} => qq{Detalles Cultura},
	qq{Culture report} => qq{Informe de cultura},
	qq{Culture result} => qq{Resultado cultura},
	qq{Culture results} => qq{Los resultados del cultivo},
	qq{Culture} => qq{Cultura},
	qq{cultures negative} => qq{culturas negativo},
	qq{cultures} => qq{culturas},
	qq{Curled} => qq{Acurrucado},
	qq{Current status} => qq{Situación actual},
	qq{CVC with AVF or AVG} => qq{CVC con FAV o IAV},
	qq{Database encryption key} => qq{Clave de cifrado de base de datos},
	qq{Date of AV access creation} => qq{Fecha de creación de acceso AV},
	qq{Date of birth} => qq{Fecha de nacimiento},
	qq{Date of first AV access use} => qq{Primera utilización acceso AV},
	qq{Date of first hemodialysis (HD)} => qq{Fecha de la primera HD},
	qq{Date of HHD referral} => qq{Fecha de la consulta HDC},
	qq{Date of HHD start} => qq{Fecha de inicio HDC},
	qq{Date of initial TN assessment} => qq{Fecha de la evaluación inicial},
	qq{Date of ACP completion} => qq{Fecha de finalización de OMPT},
	qq{Date of PD cath insertion} => qq{Inserción del catéter de DP},
	qq{Date of PD referral} => qq{Fecha de la consulta de DP},
	qq{Date of PD start} => qq{Fecha de inicio de DP},
	qq{Date of TN sign off} => qq{Fecha de la enfermera firmar apagado},
	qq{Date of transplant referral} => qq{Consulta para el trasplante},
	qq{Date of transplantation} => qq{Fecha de trasplante},
	qq{Date of VA referral} => qq{Fecha de la consulta para el AV},
	qq{Date ordered} => qq{Fecha ordenado},
	qq{day} => qq{día},
	qq{days ago} => qq{días atrás},
	qq{days starting on} => qq{días comenzando el},
	qq{days} => qq{día},
	qq{De novo} => qq{De novo},
	qq{deactivate} => qq{desactivar},
	qq{deactivated} => qq{desactivado},
	qq{Dear} => qq{Hola},
	qq{Death} => qq{Muerte},
	qq{Deceased} => qq{Fallecido},
	qq{December} => qq{Diciembre},
	qq{Declined} => qq{Rehusó},
	qq{Delete antibiotic treatment} => qq{Eliminar el tratamiento antibiótico},
	qq{Delete case} => qq{Eliminar caso},
	qq{Delete catheter information} => qq{Eliminar información catéter},
	qq{Delete culture result} => qq{Eliminar resultado del cultivo},
	qq{Delete dialysis information} => qq{Elimine la información de diálisis},
	qq{delete} => qq{borrar},
	qq{diabetes} => qq{diabetes},
	qq{Dialysis centre} => qq{Centro de diálisis},
	qq{Dialysis details} => qq{Detalles de diálisis},
	qq{Dialysis information} => qq{Información de la diálisis},
	qq{Dialysis type} => qq{Tipo de diálisis},
	qq{discard changes and return} => qq{descartar los cambios y volver},
	qq{Discharge date} => qq{Fecha de salida},
	qq{dismiss} => qq{despedir},
	qq{Dismissed alerts} => qq{Alertas cesados},
	qq{Dismissed} => qq{Despedido},
	qq{Displaying cases for} => qq{Viendo casos para},
	qq{Displaying lists for} => qq{Visualización de listas de},
	qq{Dose and route} => qq{Dosis y vía},
	qq{duration set to} => qq{duración},
	qq{Email_uc} => qq{Courriel},
	qq{email} => qq{courriel},
	qq{Empiric antibiotics} => qq{Antibióticos empíricos},
	qq{empiric} => qq{empírico},
	qq{enter a new case} => qq{introducir un nuevo caso},
	qq{enter the patient} => qq{ingresar al paciente},
	qq{Existing password} => qq{Contraseña existente},
	qq{exit site} => qq{sitio de salida},
	qq{Exit site} => qq{Sitio de salida},
	qq{Failed home dialysis in the past} => qq{Diálisis en el hogar fracasado en el pasado},
	qq{Failed peritoneal dialysis in the past} => qq{Diálisis peritoneal fracasado en el pasado},
	qq{February} => qq{Febrero},
	qq{Female} => qq{Femenino},
	qq{Filter by patient name} => qq{Filtrar por nombre del paciente},
	qq{Final antibiotics} => qq{Antibióticos finales},
	qq{Final_uc} => qq{Final},
	qq{Final: (Gram -ve) Acinetobacter species} => qq{Final: (Gram -ve) especies de Acinetobacter},
	qq{Final: (Gram -ve) Citrobacter species} => qq{Final: (Gram -ve) especies Citrobacter},
	qq{Final: (Gram -ve) Enterobacter species} => qq{Final: (Gram -ve) especies de Enterobacter},
	qq{Final: (Gram -ve) Escherichia coli} => qq{Final: (Gram -ve) Escherichia coli},
	qq{Final: (Gram -ve) Gram negative organisms, other} => qq{Final: (Gram -ve) organismos Gram negativos, otros},
	qq{Final: (Gram -ve) Klebsiella species} => qq{Final: (Gram -ve) especies de Klebsiella},
	qq{Final: (Gram -ve) Neisseria species} => qq{Final: (Gram -ve) especies de Neisseria},
	qq{Final: (Gram -ve) Proteus mirabilis} => qq{Final: (Gram -ve) Proteus mirabilis},
	qq{Final: (Gram -ve) Pseudomonas species} => qq{Final: (Gram -ve) especies de Pseudomonas},
	qq{Final: (Gram -ve) Serratia marcescens} => qq{Final: (Gram -ve) Serratia marcescens},
	qq{Final: (Gram +ve) Clostridium species} => qq{Final: (Gram +ve) especies de Clostridium},
	qq{Final: (Gram +ve) Corynebacteria species} => qq{Final: (Gram +ve) especies corinebacterias},
	qq{Final: (Gram +ve) Diptheroids} => qq{Final: (Gram + ve ) Diptheroids},
	qq{Final: (Gram +ve) Enterococcus species} => qq{Final: (Gram +ve) especies de Enterococcus},
	qq{Final: (Gram +ve) Gram positive organisms, other} => qq{Final: (Gram +ve) organismos Gram positivos, otros},
	qq{Final: (Gram +ve) Lactobacillus} => qq{Final: (Gram +ve) Lactobacillus},
	qq{Final: (Gram +ve) Propionibacterium} => qq{Final: (Gram +ve) Propionibacterium},
	qq{Final: (Gram +ve) Staphylococcus aureus (MRSA)} => qq{Final: (Gram +ve) Staphylococcus aureus (MRSA)},
	qq{Final: (Gram +ve) Staphylococcus aureus (MSSA)} => qq{Final: (Gram +ve) Staphylococcus aureus (MSSA)},
	qq{Final: (Gram +ve) Staphylococcus aureus (sensitivity unknown)} => qq{Final: (Gram +ve) Staphylococcus aureus (sensibilidad desconocida)},
	qq{Final: (Gram +ve) Staphylococcus epidermidis} => qq{Final: (Gram +ve) Staphylococcus epidermidis},
	qq{Final: (Gram +ve) Staphylococcus species, coagulase negative} => qq{Final: (Gram +ve) las especies de Staphylococcus coagulasa negativo},
	qq{Final: (Gram +ve) Staphylococcus species} => qq{Final: (Gram +ve) especies de Staphylococcus},
	qq{Final: (Gram +ve) Streptococcus species} => qq{Final: (Gram +ve) especies de Streptococcus},
	qq{Final: (Yeast) Candida species} => qq{Final: (levadura) especies de Candida},
	qq{Final: (Yeast) Other species} => qq{Final: (levadura) Otras especies},
	qq{Final: Anaerobes} => qq{Final: Los anaerobios},
	qq{Final: Culture negative} => qq{Final: Cultura negativo},
	qq{Final: Multiple} => qq{Final: Múltiple},
	qq{Final: Mycobacterium tuberculosis} => qq{Final: Mycobacterium tuberculosis},
	qq{Final: Other} => qq{Final: Otros},
	qq{final} => qq{final},
	qq{First assessment} => qq{Primera evaluación},
	qq{first before proceeding to enter a new case or adding a lab test requisition or antibiotic treatment to that case} => qq{primero antes de proceder a introducir un nuevo caso o la adición de una solicitud de pruebas de laboratorio o tratamiento con antibióticos para este caso},
	qq{first before proceeding to enter a new case or adding a lab test requisition to that case} => qq{primero antes de proceder a introducir un nuevo caso o la adición de una solicitud de prueba de laboratorio para este caso},
	qq{First name} => qq{Nombre de pila},
	qq{Follow-up and outcome} => qq{Seguimiento y resultados},
	qq{Follow-up comments} => qq{Comentarios},
	qq{Follow-up culture} => qq{Seguimiento de la cultura},
	qq{Follow-up date} => qq{Fecha de seguimiento},
	qq{Follow-up visit} => qq{Visita de reiteración},
	qq{For best results, please upgrade to the latest release of} => qq{Para obtener los mejores resultados, por favor, actualice a la última versión de},
	qq{For patients with CVC} => qq{Para los pacientes con CVC},
	qq{for} => qq{para},
	qq{For} => qq{Para},
	qq{found} => qq{fundar},
	qq{From HD start to first TN assessment} => qq{De principio de la HD a la primera evaluación de la enfermera},
	qq{From HD start to HHD referral} => qq{De principio de la HD a la remisión para la HDC},
	qq{From HD start to HHD start} => qq{De principio de la HD a la HD},
	qq{From HD start to ACP completion} => qq{De principio de la HD a la finalización de OMPT},
	qq{From HD start to PD catheter insertion} => qq{De principio de la HD a la inserción del catéter de DP},
	qq{From HD start to PD referral} => qq{De principio de la HD a la remisión para la DP},
	qq{From HD start to PD start} => qq{De principio de la HD a la inicio de la DP},
	qq{From HD start to transplant operation} => qq{De principio de la HD a la operación de trasplante},
	qq{From HD start to transplant referral} => qq{De principio de la HD a la remisión para el trasplante},
	qq{From HD start to VA referral for patients who chose HD} => qq{De principio de la HD a la la referencia de un AV para los pacientes que optaron por HD},
	qq{From HD start to VA creation for patients who chose HD} => qq{De principio de la HD a la creación de un AV para los pacientes que optaron por HD},
	qq{From HD start to VA use for patients who chose HD} => qq{De principio de la HD a la uso de un AV para los pacientes que optaron por HD},
	qq{from} => qq{de},
	qq{Gender} => qq{Género},
	qq{General comments} => qq{Comentarios generales},
	qq{Get culture result} => qq{Obtenga resultado del cultivo},
	qq{Get final culture result} => qq{Obtenga resultado final de cultivo},
	qq{Get technical support} => qq{Obtenga asistencia técnica},
	qq{go to page} => qq{ir a la página},
	qq{Go} => qq{Ir},
	qq{has been deactivated} => qq{ha sido desactivado},
	qq{hidden for today} => qq{oculto para hoy},
	qq{Hide} => qq{Ocultar},
	qq{Home centre} => qq{Centro de origen},
	qq{Home hemodialysis (HHD)} => qq{Hemodiálisis en el hogar (HDH)},
	qq{Home hemodialysis} => qq{Hemodiálisis en el hogar},
	qq{Home visit} => qq{Visita domiciliaria},
	qq{home} => qq{casa},
	qq{Hospitalization} => qq{Hospitalización},
	qq{Hospitalized} => qq{Hospitalizado},
	qq{hour ago} => qq{horas atrás},
	qq{hours ago} => qq{horas atrás},
	qq{I forgot my password} => qq{Olvidé mi contraseña},
	qq{If the patient is not in this system, please} => qq{Si el paciente no está en este sistema, por favor},
	qq{IM} => qq{IM},
	qq{In-centre hemodialysis} => qq{Hemodiálisis en el Hospital},
	qq{In-centre or community hemodialysis} => qq{En el centro o la hemodiálisis comunidad},
	qq{Inadequate access to assistance} => qq{El acceso inadecuado a la asistencia},
	qq{Inadequate social support} => qq{Apoyo social inadecuado},
	qq{Include} => qq{Incluir},
	qq{inclusive} => qq{inclusivo},
	qq{indicates required fields} => qq{indica los campos obligatorios},
	qq{Infection type} => qq{Tipo de infección},
	qq{Infection} => qq{Infección},
	qq{Initial %PMN on diff} => qq{% de granulocito inicial en el análisis},
	qq{Initial %PMN:} => qq{Initial % granulocito:},
	qq{Initial meeting} => qq{Reunión inicial},
	qq{Initial WBC count} => qq{Recuento inicial de glóbulos blancos},
	qq{Initial WBC} => qq{inicial del glóbulos blancos},
	qq{inserted on} => qq{insertada en},
	qq{Insertion date} => qq{Fecha de inserción},
	qq{Insertion location} => qq{Ubicación de inserción},
	qq{Insertion method} => qq{Método de inserción},
	qq{Insufficient dexterity} => qq{Destreza insuficiente},
	qq{Intranasal} => qq{Intranasal},
	qq{Intratunnel} => qq{Intratunnel},
	qq{IP} => qq{IP},
	qq{is now an administrator} => qq{ahora es un administrador},
	qq{IV} => qq{IV},
	qq{January} => qq{Enero},
	qq{July} => qq{Julio},
	qq{June} => qq{Junio},
	qq{Kidney Care Centre} => qq{Renal Care Centre},
	qq{kilograms} => qq{kilogramos},
	qq{lang} => qq{es},
	qq{Language} => qq{Idioma},
	qq{Last name} => qq{Apellido},
	qq{Last updated} => qq{Actualización},
	qq{List saved} => qq{Lista ahorrado},
	qq{List statistics} => qq{Estadísticas lista},
	qq{Living donor identified} => qq{Donante vivo identificado},
	qq{Loading dose given on} => qq{La dosis de carga indicada en},
	qq{Loading dose} => qq{La dosis de carga},
	qq{Location} => qq{Ubicación},
	qq{make admin} => qq{hacer de admin},
	qq{Male} => qq{Masculino},
	qq{Manage case_uc} => qq{Administrar caso},
	qq{manage case} => qq{administrar caso},
	qq{manage start} => qq{administrar inicio},
	qq{Manage start_uc} => qq{Administrar inicio},
	qq{Manage users_uc} => qq{Administrar de usuarios},
	qq{manage users} => qq{administrar usuarios},
	qq{March} => qq{Marzo},
	qq{May} => qq{Mayo},
	qq{Medical contraindication} => qq{Contraindicación médica},
	qq{Medical history} => qq{Historial médico},
	qq{Message} => qq{Mensaje},
	qq{minute ago} => qq{minutos atrás},
	qq{minutes ago} => qq{minutos atrás},
	qq{mobile} => qq{móvil},
	qq{Modality at 12 months} => qq{Modalidad a los 12 meses},
	qq{Modality at 6 months} => qq{Modalidad a los 6 meses},
	qq{Modality orientation date} => qq{Orientación Modalidad},
	qq{Modified} => qq{Modificado},
	qq{Modify account} => qq{Modificar cuenta},
	qq{moments ago} => qq{hace unos momentos},
	qq{month} => qq{mes},
	qq{months ago} => qq{meses atrás},
	qq{months between episodes} => qq{meses entre los episodios},
	qq{months} => qq{mes},
	qq{ACP completion date} => qq{fecha de finalización de OMPT},
	qq{Mr.} => qq{Sr.},
	qq{Ms.} => qq{Sra.},
	qq{Name} => qq{Nombre},
	qq{Negative cultures} => qq{Los cultivos negativos},
	qq{Nephrologist} => qq{Nefrólogo},
	qq{New case} => qq{Nuevo caso},
	qq{new cases of peritonitis in} => qq{nuevos casos de peritonitis en},
	qq{New password} => qq{Nueva contraseña},
	qq{New patient} => qq{Nueva paciente},
	qq{New start} => qq{Nuevo comienzo},
	qq{new starts} => qq{nuevas aperturas},
	qq{Next step} => qq{Siguiente paso},
	qq{next} => qq{próximo},
	qq{No cases found} => qq{No se han encontrado casos},
	qq{No cases} => qq{No hay casos},
	qq{No choice made} => qq{Sin opción elegida},
	qq{No culture results found} => qq{No hay resultados de los cultivos que se encuentran},
	qq{No lab tests found} => qq{No hay pruebas de laboratorio que se encuentran},
	qq{No patients found} => qq{No se han encontrado pacientes},
	qq{no result} => qq{sin resultado},
	qq{No starts found} => qq{No se han encontrado aperturas},
	qq{No, do not delete} => qq{No, no lo elimine},
	qq{No} => qq{No},
	qq{Nocturnal in-centre hemodialysis} => qq{Nocturnal hemodiálisis en el hospital},
	qq{none given} => qq{ninguno determinado},
	qq{none reported} => qq{ninguno reportado},
	qq{none} => qq{ninguno},
	qq{Not applicable} => qq{No aplicable},
	qq{not arranged} => qq{que no se presentan},
	qq{not entered} => qq{no se indica},
	qq{not signed in} => qq{no firmado en},
	qq{not specified} => qq{no especificado},
	qq{Not tracked} => qq{No se ha grabado},
	qq{not tracked} => qq{no utilice control},
	qq{Not yet known} => qq{Todavía no se sabe},
	qq{Notifications} => qq{Notificaciones},
	qq{November} => qq{Noviembre},
	qq{now discharged} => qq{ahora descargada},
	qq{October} => qq{Octubre},
	qq{of cases require hospitalization<br/>during this time period} => qq{de los casos requieren hospitalización<br/>durante este período de tiempo},
	qq{of cultures yield negative<br/>results during this time period} => qq{de las culturas dan resultados negativos<br/>durante este período de tiempo},
	qq{of} => qq{de},
	qq{On PD} => qq{En la DP},
	qq{on} => qq{en},
	qq{only cultures from peritonitis cases are counted} => qq{sólo las culturas de los casos de peritonitis se cuentan},
	qq{Onset in hospital} => qq{Onset en el hospital},
	qq{Onset} => qq{Comienzo},
	qq{Open outstanding case} => qq{Caso pendiente Abierto},
	qq{Opened} => qq{Abierto},
	qq{Operating room} => qq{Sala de operaciones},
	qq{or} => qq{o},
	qq{Ordered} => qq{Ordenado},
	qq{Other} => qq{Otro},
	qq{Outcome} => qq{Resultado},
	qq{Outpatient} => qq{Paciente externo},
	qq{Outstanding} => qq{Pendiente},
	qq{Password Recovery} => qq{Recuperación de la contraseña},
	qq{Password} => qq{Contraseña},
	qq{past cases found in the database} => qq{los casos del pasado que se encuentran en la base de datos},
	qq{Past cases} => qq{Casos anteriores},
	qq{past} => qq{pasado},
	qq{Pathogens, all infections} => qq{Patógenos, todas las infecciones},
	qq{Pathogens, hospitalized patients} => qq{Patógenos, pacientes hospitalizados},
	qq{Pathogens, in exit site infections} => qq{Patógenos, en las infecciones del sitio de salida},
	qq{Pathogens, in peritonitis} => qq{Patógenos, en peritonitis},
	qq{Pathogens, in tunnel infections} => qq{Patógenos, en las infecciones del túnel},
	qq{Patient believes home dialysis is inferior care} => qq{Paciente cree diálisis en el hogar es el cuidado inferior},
	qq{Patient interested in transplant} => qq{Interesado en trasplante},
	qq{Patient name} => qq{Nombre},
	qq{Patient weight} => qq{Peso},
	qq{patient-months of peritoneal dialysis at risk} => qq{pacientes-meses de diálisis peritoneal en riesgo},
	qq{Patient&nbsp;name} => qq{Nombre},
	qq{patients at risk} => qq{pacientes con riesgo},
	qq{Patients can have only one outstanding case at a time} => qq{Los pacientes pueden tener sólo un caso pendiente en un momento},
	qq{patients of} => qq{pacientes de},
	qq{patients peritonitis-free} => qq{pacientes sin peritonitis},
	qq{patients with CVC and no AVF} => qq{pacientes con CVC y sin FAV},
	qq{patients without ACP completion date} => qq{pacientes sin fecha de finalización de OMPT},
	qq{patients} => qq{pacientes},
	qq{PD centre} => qq{Centro de DP},
	qq{PD Nurse} => qq{Enfermera de DP},
	qq{Pending} => qq{Pendiente},
	qq{Peritoneal dialysis (PD)} => qq{La diálisis peritoneal (DP)},
	qq{Peritoneal dialysis fluid} => qq{Líquido de diálisis peritoneal},
	qq{Peritoneal dialysis} => qq{La diálisis peritoneal},
	qq{Peritoneoscope} => qq{Peritoneoscopio},
	qq{Peritonitis rate} => qq{Tasa de peritonitis},
	qq{peritonitis} => qq{peritonitis},
	qq{Peritonitis} => qq{Peritonitis},
	qq{Personal information} => qq{Datos personales},
	qq{PHN} => qq{Número},
	qq{Phone (home)} => qq{Teléfono (casa)},
	qq{Phone (mobile)} => qq{Teléfono (móvil)},
	qq{Phone (work)} => qq{Teléfono (trabajo)},
	qq{Physician office} => qq{Oficina del médico},
	qq{please create one} => qq{por favor, cree una},
	qq{Please enter a patient&quot;s name or PHN or} => qq{Por favor ingrese el nombre del paciente o el número de la salud o la},
	qq{Please note that passwords are case sensitive} => qq{Tenga en cuenta que las contraseñas distinguen entre mayúsculas y minúsculas},
	qq{Please provide a temporary password for this user} => qq{Por favor proporcione una contraseña temporal para este usuario},
	qq{Please provide the ACP completion date} => qq{Por favor, proporcione la fecha de finalización de OMPT},
	qq{Please record the modality at 12 months} => qq{Por favor registre la modalidad a los 12 meses},
	qq{Please record the modality at 6 months} => qq{Por favor registre la modalidad a los 6 meses},
	qq{Please select a case from the list below or} => qq{Por favor seleccione un caso de la lista a continuación o},
	qq{Please select a lab test record to update. If the appropriate lab test requisition is not listed below} => qq{Por favor, seleccione un registro de la prueba de laboratorio para actualizar. Si la solicitud de prueba de laboratorio adecuada no está en la lista a continuación},
	qq{Please try again or contact technical support for assistance.} => qq{Por favor, inténtelo de nuevo o contacte con el soporte técnico para obtener asistencia.},
	qq{PO} => qq{PO},
	qq{Pre-emptive transplant} => qq{Trasplante preventivo},
	qq{Preferred dialysis modality} => qq{Modalidad de diálisis preferida},
	qq{Preferred modality} => qq{modalidad preferida},
	qq{Preliminary: Acid fast bacillus} => qq{Preliminar: Acid bacilo rápido},
	qq{Preliminary: Culture negative} => qq{Preliminar: Cultura negativo},
	qq{Preliminary: Gram -ve coccus} => qq{Preliminar: Gram -ve coccus},
	qq{Preliminary: Gram +ve bacillus} => qq{Preliminar: Gram +ve bacilo},
	qq{Preliminary: Gram +ve coccus} => qq{Preliminar: Gram +ve coccus},
	qq{Preliminary: Multiple} => qq{Preliminar: Multiple},
	qq{Preliminary: Other} => qq{Preliminar: Otros},
	qq{Preliminary: Yeast} => qq{Preliminar: Levadura},
	qq{Preliminary} => qq{Preliminar},
	qq{Presentation date} => qq{Fecha de presentación},
	qq{Presented} => qq{Presentado},
	qq{Presternal} => qq{Preesternal},
	qq{previous} => qq{anterior},
	qq{Primary nurse} => qq{Enfermera primaria},
	qq{Prior status} => qq{Condición anterior},
	qq{Proportion of all patients referred for transplant} => qq{Proporción de todos los pacientes remitidos para trasplante},
	qq{Proportion of patients introduced to ACP} => qq{Proporción de pacientes que presentó para avanzar en la planificación de cuidados},
	qq{Proportion of patients who are on HD with VA (AVF or AVG) 12 months after TN intervention} => qq{Proporción de pacientes que están en HD mediante un AV (FAV o IAV) 12 meses después de la intervención enfermera},
	qq{Proportion of patients who are on HD with VA (AVF or AVG) 6 months after TN intervention} => qq{Proporción de pacientes que están en HD mediante un AV (FAV o IAV) 6 meses después de la intervención enfermera},
	qq{Proportion of patients who are on HHD 12 months after TN intervention} => qq{Proporción de pacientes que están en HDH 12 meses después de la intervención enfermera},
	qq{Proportion of patients who are on HHD 6 months after TN intervention} => qq{Proporción de pacientes que están en HDH 6 meses después de la intervención enfermera},
	qq{Proportion of patients who are on PD 12 months after TN intervention} => qq{Proporción de pacientes que están en DP 12 meses después de la intervención enfermera},
	qq{Proportion of patients who are on PD 6 months after TN intervention} => qq{Proporción de pacientes que están en DP 6 meses después de la intervención enfermera},
	qq{Proportion of patients who chose HHD after TN intervention} => qq{Proporción de pacientes que eligieron HDH tras la intervención enfermera},
	qq{Proportion of patients who chose PD after TN intervention} => qq{Proporción de pacientes que eligieron DP después de la intervención enfermera},
	qq{Proportion of patients with an identified living donor} => qq{Proporción de pacientes con un donante vivo identificado},
	qq{psychosocial issues} => qq{problemas psicosociales},
	qq{quarter} => qq{tres meses},
	qq{Range of} => qq{Rango de},
	qq{reactivate} => qq{reactivar},
	qq{Reason_uc} => qq{Razón},
	qq{reason} => qq{razón},
	qq{Received} => qq{Recibido},
	qq{Recurrent} => qq{Recurrente},
	qq{Referred for transplant prior to hemodialysis} => qq{Referido para el trasplante antes de la hemodiálisis},
	qq{Refractory} => qq{Refractario},
	qq{Regular} => qq{Regular},
	qq{Relapsing infection} => qq{Recurrente infección},
	qq{Relapsing} => qq{Reincidente},
	qq{Remember patient confidentiality} => qq{Recuerde que la confidencialidad del paciente},
	qq{Removal date} => qq{Fecha de Remoción},
	qq{removed on} => qq{eliminado en},
	qq{RenalConnect: cloud-based management of dialysis care} => qq{RenalConnect: gestión basada en la nube de la atención de la diálisis},
	qq{Repeat password} => qq{Repita la contraseña},
	qq{Repeat} => qq{Repetición},
	qq{reports} => qq{informes},
	qq{Request for Technical Assistance} => qq{Solicitud de Asistencia Técnica},
	qq{requisition sent} => qq{requisición enviada},
	qq{reset} => qq{reajustar},
	qq{Resolution} => qq{Resolución},
	qq{Results not available} => qq{Resultados no disponibles},
	qq{Results} => qq{Resultados},
	qq{return to manage users} => qq{volver a administrar usuarios},
	qq{return to sign in screen} => qq{volver a la pantalla Inicio de sesión},
	qq{review case} => qq{caso reseña},
	qq{Right now} => qq{Ahora mismo},
	qq{Role} => qq{Papel},
	qq{Sample type} => qq{Tipo de muestra},
	qq{save changes and return} => qq{&crarr; guardar los cambios y volver},
	qq{Save changes} => qq{Guardar cambios},
	qq{Search} => qq{Búsqueda},
	qq{Searching...} => qq{Buscando ...},
	qq{select an antibiotic} => qq{seleccionar un antibiótico},
	qq{select pathogen} => qq{seleccione patógeno},
	qq{select stage} => qq{seleccione el escenario},
	qq{send reminders to this address} => qq{enviar recordatorios a esta dirección},
	qq{September} => qq{Septiembre},
	qq{Show all alerts} => qq{Mostrar todas las alertas},
	qq{Sign in} => qq{Entrar},
	qq{Sign off} => qq{Firmar},
	qq{sign out} => qq{desconectarte},
	qq{six months} => qq{seis meses},
	qq{Specify &quot;other&quot; modality} => qq{Especifique la modalidad "otros"},
	qq{Specify &quot;other&quot; reason} => qq{Especifique la razón "otra"},
	qq{Specify case outcome} => qq{Especifique resultado del caso},
	qq{Specify empiric treatment} => qq{Especificar el tratamiento empírico},
	qq{Specify final antibiotic} => qq{Especifique antibiótico definitiva},
	qq{Specify} => qq{Especificar},
	qq{Start date} => qq{Fecha de inicio},
	qq{starts &gt; 180 days from HD start to TN 1st visit} => qq{inicio &gt; 180 días desde el inicio de la hemodiálisis a la primera visita de una enfermera},
	qq{starts &le; 180 days from HD start to TN 1st visit} => qq{inicio &le; 180 días desde el inicio de la hemodiálisis a la primera visita de una enfermera},
	qq{starts matching the criteria} => qq{inicio coincide con los criterios},
	qq{starts matching this time frame} => qq{inicio a juego este marco de tiempo},
	qq{starts with data for this calculation} => qq{inicio con los datos para este cálculo},
	qq{Status} => qq{Estado},
	qq{Stop date} => qq{Fecha detener},
	qq{stop} => qq{detener},
	qq{stopped} => qq{detenido},
	qq{Straight} => qq{Recto},
	qq{Submit} => qq{Presentar},
	qq{Surgeon} => qq{Cirujano},
	qq{Surgery} => qq{Cirugía},
	qq{Swab of exit site} => qq{Swab del sitio de salida},
	qq{Switch to} => qq{Cambie a},
	qq{Tasks} => qq{Tareas},
	qq{The account for} => qq{La cuenta para el},
	qq{The administrator user cannot be created} => qq{El usuario administrador no se puede crear},
	qq{The patient} => qq{El paciente},
	qq{There are currently no active cases to display} => qq{Actualmente no hay casos activos para mostrar},
	qq{There are currently no active starts to display} => qq{Actualmente no hay aperturas activas para mostrar},
	qq{There are no applicable alerts for this view} => qq{No hay alertas aplicables para este punto de vista},
	qq{This case has been deleted} => qq{Se ha suprimido este caso},
	qq{This information has been deleted} => qq{Esta información ha sido borrado},
	qq{TN assessment} => qq{Evaluación de la enfermera de transición},
	qq{to be determined} => qq{por determinar},
	qq{to see all cases} => qq{para ver todos los casos},
	qq{to see all lists} => qq{para ver todas las listas},
	qq{to} => qq{a},
	qq{Topical} => qq{Actual},
	qq{total cultures ordered} => qq{culturas totales ordenaron},
	qq{Total of} => qq{Total de},
	qq{Transition Nurse} => qq{Enfermera Transición},
	qq{Transplant imminent} => qq{Trasplante inminente},
	qq{Transplant} => qq{Trasplante},
	qq{Treatment} => qq{Tratamiento},
	qq{tunnel} => qq{túnel},
	qq{Tunnel} => qq{Túnel},
	qq{two years} => qq{dos años},
	qq{Unhide all active cases} => qq{Hacer visible todos los casos activos},
	qq{Unhide all active starts} => qq{Hacer visible todo inicio activos},
	qq{Unknown acute} => qq{Desconocido aguda},
	qq{Unknown chronic} => qq{Desconocido crónica},
	qq{Unknown} => qq{Ignoto},
	qq{Update password} => qq{Actualización de la contraseña},
	qq{update results} => qq{actualizar los resultados},
	qq{updated} => qq{actualizado},
	qq{Use the MATCH-D tool} => qq{Utilice MATCH-D},
	qq{User information saved} => qq{Información del usuario guardada},
	qq{User information} => qq{información del usuario},
	qq{User type} => qq{Tipo de usuario},
	qq{Vascular access at HD start} => qq{El AV al inicio de la HD},
	qq{Vascular access} => qq{El acceso vascular},
	qq{view dismissed alerts} => qq{vista desestimó alertas},
	qq{View latest open case} => qq{Ver el último caso abierto},
	qq{View latest open start} => qq{Ver el último inicio abierta},
	qq{View patient information} => qq{Ver la información del paciente},
	qq{View} => qq{Ver},
	qq{w_about_renalconnect} => qq{RenalConnect es una herramienta de gestión clínica desarrollada en la Columbia Británica para mejorar la calidad de la atención y los resultados del paciente en diálisis.},
	qq{w_alert_cannot_add_patient} => qq{<span class="b">Información de este paciente no se puede añadir.</span> Por favor, asegúrese de que todos los campos se han completado correctamente y vuelve a intentarlo.},
	qq{w_alert_code_10} => qq{Por favor, reconsiderar la dosis de vancomicina para este paciente, que está por debajo del mínimo recomendado de 20 mg/kg.},
	qq{w_alert_code_110} => qq{Resultados de los cultivos preliminares no llegaron.},
	qq{w_alert_code_120} => qq{Resultados de los cultivos finales no llegaron.},
	qq{w_alert_code_15} => qq{Este paciente es el fluconazol. Por favor considere las interacciones de medicamentos, incluyendo las estatinas.},
	qq{w_alert_code_20} => qq{Este paciente tiene MRSA. Por favor revise los antibióticos de este paciente para asegurarse de que es apropiado para este organismo.},
	qq{w_alert_code_200} => qq{Resultados de los cultivos preliminares actualizado},
	qq{w_alert_code_210} => qq{Resultados de los cultivos finales actualizados},
	qq{w_alert_code_220} => qq{Seguimiento telefónico recomienda este paciente.},
	qq{w_alert_code_230} => qq{Por favor, el seguimiento de este nuevo paciente.},
	qq{w_alert_code_240} => qq{Por favor, el seguimiento de este nuevo paciente al tratamiento Chat en modalidad a los 6 meses.},
	qq{w_alert_code_250} => qq{Por favor, el seguimiento de este nuevo paciente al tratamiento Chat en modalidad a los 12 meses.},
	qq{w_alert_code_30} => qq{Este paciente tiene una infección por hongos. Catéter de diálisis peritoneal debe eliminado idealmente dentro de las 24 horas. <a href="http://www.pdiconnect.com/cgi/content/abstract/31/1/60?etoc" target="blank">vista de referencia</a>},
	qq{w_alert_code_5} => qq{Por favor, reconsiderar la dosis de tobramicina o gentamicina para este paciente, ya que puede ser demasiado alto.},
	qq{w_alert_code_90} => qq{Por favor considerar la profilaxis con fluconazol para este paciente.},
	qq{w_auto_sign_out_notice} => qq{<span class="b">Para ayudar a proteger la confidencialidad del paciente, la pantalla se ha bloqueado.</span> Por favor, vuelva a introducir la contraseña para continuar trabajand.},
	qq{w_confirm_delete_case} => qq{<span class="b">¿Está seguro que desea eliminar este caso? Los casos no deben eliminarse a menos que se crearon en el error.</span> Esta acción no se puede deshacer, sin embargo, todavía se mantiene un registro de este caso en el archivo para fines de auditoría. Si no está seguro, póngase en contacto con el líder de su grupo antes de proceder.},
	qq{w_confirm_delete_information} => qq{<span class="b">¿Está seguro de que desea eliminar esta información? Esta información no debe ser eliminado, a menos que se creó en el error.</span> Esta acción no se puede deshacer. Sin embargo, todavía se mantendrá un registro de ello en el archivo para fines de auditoría. Si no está seguro, póngase en contacto con el líder de su grupo antes de proceder.},
	qq{w_email_bring_pd_reminder_body} => qq{Nuestros registros indican que su régimen de antibióticos se ha completado. Por favor, recuerde llevar su bolsa de PD para la cultura de seguimiento tan pronto como sea posible.},
	qq{w_email_bring_pd_reminder_subject} => qq{Recordatorio para llevar bolsa PD para la cultura de seguimiento},
	qq{w_error_cannot_add_antibiotic} => qq{<span class="b">No puede añadirse este tratamiento antibiótico.</span> Por favor, asegúrese de que todos los campos se han completado correctamente y vuelve a intentarlo.},
	qq{w_error_cannot_add_case} => qq{<span class="b">No se puede añadir este caso.</span> Por favor, asegúrese de que todos los campos se han completado correctamente y vuelve a intentarlo.},
	qq{w_error_cannot_add_user} => qq{<span class="b">Este usuario no se puede añadir.</span> Por favor, asegúrese de que todos los campos se han completado correctamente y vuelve a intentarlo.},
	qq{w_error_cannot_save_user} => qq{<span class="b">Información de usuario no se puede guardar.</span> Por favor, complete todos los campos obligatorios y vuelva a intentarlo.},
	qq{w_error_cant_sign_off} => qq{<span class="b">Este caso no puede ser firmado.</span> Por favor, asegúrese de que todos los campos requeridos, según lo marcado por las balas rojas, se completan y vuelva a intentarlo.},
	qq{w_error_case_antibiotic_start_invalid} => qq{Este tratamiento antibiótico no se puede guardar porque la fecha de inicio no parece ser válida.},
	qq{w_error_case_antibiotic_start_stop_invalid} => qq{Este tratamiento antibiótico no se puede guardar porque la fecha de la cancelación (de parada prematuro) ocurre antes de la fecha de inicio.},
	qq{w_error_case_antibiotic_stop_invalid} => qq{Este tratamiento antibiótico no se puede guardar porque la fecha de la cancelación (de parada prematuro) no parece ser válida.},
	qq{w_error_case_catheter_start_invalid} => qq{Esta información catéter no se puede guardar porque la fecha de inserción aparece como no válida.},
	qq{w_error_case_catheter_start_stop_invalid} => qq{Esta información catéter no se puede guardar porque la fecha de la retirada es anterior a la fecha de inserción.},
	qq{w_error_case_catheter_stop_invalid} => qq{Esta información catéter no se puede guardar porque la fecha de la retirada no parece ser válida.},
	qq{w_error_case_dialysis_start_invalid} => qq{Esta información de diálisis no se puede guardar porque la fecha de inicio no parece ser válida.},
	qq{w_error_case_dialysis_start_stop_invalid} => qq{Esta información de diálisis no se puede guardar porque la fecha tope es anterior a la fecha de inicio.},
	qq{w_error_case_dialysis_stop_invalid} => qq{Esta información de diálisis no se puede guardar porque la fecha tope no parece ser válida.},
	qq{w_error_case_hospitalization_date_invalid} => qq{Este caso no se puede guardar debido a que la fecha de inicio de la hospitalización no parece ser válida.},
	qq{w_error_case_hospitalization_end_date_invalid} => qq{Este caso no se puede guardar debido a que la fecha de finalización de la hospitalización no parece ser válida.},
	qq{w_error_case_hospitalization_start_end_date_invalid} => qq{Este caso no se puede guardar debido a que la fecha de finalización de la hospitalización es anterior a la fecha de inicio.},
	qq{w_error_case_presentation_invalid} => qq{Este caso no se puede guardar porque la fecha de presentación no parece ser válida.},
	qq{w_error_date_format} => qq{Por favor, asegúrese de que la fecha en que se ha introducido correctamente en el formato AAAA-MM-DD y vuelva a intentarlo.},
	qq{w_error_email_doesnt_exist} => qq{<div class="emp"><span class="b">El usuario con la dirección de correo electrónico proporcionada en la actualidad no es un usuario registrado y activo en el sistema.</span> Por favor, póngase en contacto con su jefe de equipo de diálisis peritoneal para obtener más ayuda.</div>},
	qq{w_error_information_cant_be_saved} => qq{<span class="b">Esta información no puede ser procesada.</span> Asegúrese de que todos los campos requeridos se completen correctamente y vuelva a intentarlo.},
	qq{w_error_no_home_center} => qq{<span class="b">Este caso no se puede guardar.</span> Por favor, asegúrese de que se ha previsto un centro de origen y vuelve a intentarlo.},
	qq{w_error_password_cannot_update} => qq{<span class="b">La contraseña no se puede actualizar.</span> Por favor, asegúrese de que ha entrado en una nueva contraseña y vuelva a intentarlo.},
	qq{w_error_password_repeat_dont_match} => qq{<span class="b">La contraseña no se puede actualizar porque sus nuevas contraseñas no coinciden.</span> Por favor, asegúrese de que ha vuelto a entrar en la misma nueva contraseña dos veces y vuelva a intentarlo.},
	qq{w_error_password_too_short} => qq{<span class="b">La nueva contraseña es demasiado corta.</span> Por favor, introduzca una contraseña de por lo menos 8 caracteres de longitud. Asegúrese de que todos los campos requeridos se completen correctamente y vuelva a intentarlo.},
	qq{w_error_passwords_dont_match} => qq{<span class="b">La contraseña no se puede actualizar porque la contraseña existente no coincide con la contraseña que tenemos en archivo.</span> Por favor, asegúrese de que ha entrado en el sensible contraseña existente caracteres correctos y vuelva a intentarlo.},
	qq{w_error_patient_dob_invalid} => qq{La información de este paciente no se puede guardar porque la fecha de nacimiento del paciente no parece ser válida.},
	qq{w_error_patient_pd_invalid} => qq{La información de este paciente no se puede guardar porque la diálisis peritoneal fecha de inicio del paciente no parece ser válida.},
	qq{w_error_patient_pd_start_stop_invalid} => qq{<span class="b">La información de este paciente no se puede guardar porque la diálisis peritoneal fecha de inicio del paciente se produce después de la fecha tope.</span> Por favor, asegúrese de que la fecha de inicio se produce antes de la fecha tope y vuelva a intentarlo.},
	qq{w_error_patient_pd_stop_invalid} => qq{La información de este paciente no se puede guardar porque la diálisis peritoneal la fecha tope del paciente no parece ser válida.},
	qq{w_error_patient_phn_already_exists} => qq{La información de este paciente no se pudo guardar porque otro paciente con el mismo número de la salud ya existe en la base de datos.},
	qq{w_error_same_email} => qq{<span class="b">Un usuario con esta dirección de correo electrónico ya existe en la base de datos.</span> Por favor, introduce una dirección de correo electrónico diferente, asegúrese de que todos los campos se han completado correctamente y vuelve a intentarlo.},
	qq{w_error_user_complete_all} => qq{<span class="b">Este usuario no se puede añadir.</span> Asegúrese de que todos los campos requeridos se completen correctamente y vuelva a intentarlo.},
	qq{w_incorrect_email_or_password} => qq{<span class="b">Usted ha proporcionado un correo electrónico o contraseña incorrectos.</span> Por favor, inténtelo de nuevo.},
	qq{w_no_administrator} => qq{<span class="b">Esta instalación no tiene un administrador.</span> Por favor tome esta oportunidad para crear una cuenta de administrador. Si necesita ayuda, por favor haga clic en el enlace de obtener asistencia técnica.},
	qq{w_password_blurb} => qq{¿Ha perdido su contraseña? Usted puede usar este formulario para restablecer su contraseña por correo electrónico. Introduzca su dirección de correo electrónico RenalConnect y luego enviar el formulario, tener una contraseña temporal enviada a su dirección de correo electrónico. Si no puede recordar la dirección de correo electrónico que utiliza para acceder a este sistema, o si no está seguro de si tiene una cuenta, por favor pregunte a su jefe de equipo de diálisis peritoneal.},
	qq{w_password_email_1} => qq{Hola,\n\nAlguien, esperamos que pueda, han solicitado restablecer la contraseña para su aplicación RenalConnect. Su contraseña se ha restablecido a:},
	qq{w_password_email_2} => qq{Por favor utilice la siguiente información de cuenta actualizado para acceder RenalConnect.},
	qq{w_password_email_3} => qq{Le recomendamos que borre este mensaje y crear luego una contraseña personalizada inmediatamente.},
	qq{w_request_blurb} => qq{Si usted está experimentando problemas técnicos con el sistema, o si usted cree que ha llegado a través de un mal funcionamiento de software, por favor llene y envíe el siguiente formulario para notificar a su equipo RenalConnect, que será capaz de ayudar a usted a la brevedad. Por favor, proporcione un número de teléfono de devolución de llamada en el mensaje si es posible.},
	qq{w_request_confirmed} => qq{<div class="suc"><span class="b">Su solicitud de asistencia ha sido enviado.</span> Por favor, revise su cuenta de correo electrónico en los próximos minutos para una confirmación. Si usted no recibe el correo electrónico en la siguiente hora, por favor revise su carpeta de correo basura, o comuníquese con el líder del equipo de diálisis peritoneal para obtener más ayuda.</div><div><a href="index.pl" class="b">&laquo; volver a la pantalla Inicio de sesión</a> | <a href="support.pl">presentar una nueva solicitud de soporte</a></div>},
	qq{w_request_letter_part_1} => qq{Hola,\n\nA solicitud de asistencia técnica fue enviado desde la aplicación RenalConnect en nombre de},
	qq{w_request_letter_part_2} => qq{(inicio del mensaje)},
	qq{w_request_letter_part_3} => qq{(final del mensaje)},
	qq{w_success_case_info_added} => qq{<span class="b">Información actualizada del caso.</span> ¿Qué le gustaría hacer ahora?},
	qq{w_success_new_password_sent} => qq{<div class="suc"><span class="b">Una contraseña temporal ha sido enviada a su correo electrónico.</span> Por favor verifique su cuenta de correo electrónico en los próximos minutos. Si usted no recibe el correo electrónico en la siguiente hora, por favor revise su carpeta de correo basura, o comuníquese con el líder del equipo de diálisis peritoneal para obtener más ayuda.</div>},
	qq{w_success_password_updated} => qq{<span class="b">Su contraseña ha sido actualizado.</span>},
	qq{w_success_patient_info_added} => qq{<span class="b">La información del paciente agregó.</span> ¿Qué le gustaría hacer ahora?},
	qq{w_success_patient_info_updated} => qq{<span class="b">La información del paciente actualiza.</span> ¿Qué le gustaría hacer ahora?},
	qq{w_success_user_added} => qq{<span class="b">Nuevo usuario añadió.</span> ¿Qué le gustaría hacer ahora?},
	qq{weeks ago} => qq{semanas atrás},
	qq{Weight} => qq{Peso},
	qq{work} => qq{trabajo},
	qq{year} => qq{año},
	qq{years ago} => qq{años atrás},
	qq{Yes} => qq{Sí},
	qq{yesterday} => qq{ayer},
	qq{You are using an outdated browser that is ten years old.} => qq{Usted está utilizando un navegador obsoleto que tiene diez años.},
	qq{You have a new patient in RenalConnect} => qq{Usted tiene un nuevo paciente en RenalConnect},
	qq{You have a new patient who has started hemodialysis at} => qq{Usted tiene un nuevo paciente que comenzó la hemodiálisis en},
	qq{You have no alerts at this time.} => qq{No tiene alertas en este momento.},
	qq{you} => qq{usted},
	qq{Your account} => qq{Tu cuenta}
);
if ($pl{'lang'} eq 'English' or $pl{'lang'} eq 'Français' or $pl{'lang'} eq 'Español') {
	$set_lang = $pl{'lang'};
	$lang = $pl{'lang'};
} else {
	@sid = &get_sid();
}
if ($lang eq 'Français') {
	%w = %lang_fr;
} elsif ($lang eq 'Español') {
	%w = %lang_es;
} else {
	$lang = 'English';
	%w = %lang_en;
}
sub get_w() {
	return %w;
}

# SOFTWARE FUNCTIONS

sub get_sid() {
	if ($sid[0] and !$_[0]) {
		return @sid;
	} else {
		my $sid = $q->cookie("rc") || undef;
		if ($sid eq undef) {
			my $s = new CGI::Session("driver:MySQL", undef, {Handle=>$dbh});
			$sid = $s->id();
			$s->param('lang', $set_lang);
		}
		my $s = new CGI::Session("driver:MySQL", $sid, {Handle=>$dbh});
		if ($set_lang ne '') {
			$s->param('lang', $set_lang);
		}
		my $uid = $s->param("uid");
		$lang = $s->param('lang');
		my $coo = $s->header();
		my $ipa = $q->remote_addr();
		$coo =~ s/ISO-8859-1/utf-8\n\n/g;
		@sid = ($coo, $sid, $uid, $ipa);
		$token = $sid;
		return @sid;
	}
}
@sid = &get_sid();
my $hbin_target = "hbin";
my $sbin_target = "sbin";
my $required_io = qq{<span class="txt-red">&bull;</span>};
my $comment_icon = qq{<img src="$local_settings{"path_htdocs"}/images/icon-comment-small-blue.gif" alt='' align="absmiddle"/>};
my $button_add_patient = qq{<img src="$local_settings{"path_htdocs"}/images/icon-user-small.png" alt='' align="absmiddle"/> <a class="b nou p10ro" target="$hbin_target" href="ajax.pl?token=$token&do=add_patient_form">$w{'add patient'}</a>};
my $button_add_case = qq{<img src="$local_settings{"path_htdocs"}/images/icon-update-small-blue.png" alt='' align="absmiddle"/> <a class="b nou p10ro" target="$hbin_target" href="ajax.pl?token=$token&do=add_case_form">$w{'add case'}</a>};
my $button_add_list = qq{<img src="$local_settings{"path_htdocs"}/images/icon-update-small-blue.png" alt='' align="absmiddle"/> <a class="b nou p10ro" target="$hbin_target" href="ajax.pl?token=$token&do=view_list">$w{'add start'}</a>};
if ($local_settings{'ajax_debug'} eq "on") {
	$hbin_target = "_blank";
	$sbin_target = "_blank";
}

sub record_login() {
	my ($uid, $comment) = @_;
	if ($uid ne '' and $comment ne '') {
		my $hs_ip = $q->remote_addr();
		my $hs_client = $q->user_agent();
		&input(qq{INSERT INTO rc__hs_login (hs_uid, hs_ip, hs_client, hs_action) VALUES ("$uid", "$hs_ip", "$hs_client", "$comment")});
	}
}
sub login() {
	my %p = %{$_[0]};
	my $mail = $p{"param_login_email"};
	my $pass = $p{"param_login_password"};
	$pass = &encrypt($pass);
	my $uid = &fast(qq{SELECT entry FROM rc_users WHERE email="$mail" AND password="$pass" AND deactivated="0"});
	if ($uid ne '') {
		my $s = new CGI::Session("driver:MySQL", $sid[1], {Handle=>$dbh});
		$s->param("uid", $uid);
		my $coo = $s->header();
		my $ipa = $q->remote_addr();
		$coo =~ s/ISO-8859-1/utf-8\n\n/g;
		@sid = ($coo,$sid[1],$uid,$ipa);
		&record_login($uid,"login");
		&input(qq{INSERT INTO rc_state (uid, param, value) VALUES ("$uid", "lock", "0") ON DUPLICATE KEY UPDATE value="0"});
		return '';
	} else {
		my $uid = &fast(qq{SELECT entry FROM rc_users WHERE email="$mail"});
		&record_login($uid,"password mismatch");
		return $w{'w_incorrect_email_or_password'};
	}
}
sub logout() {
	&record_login($sid[2],"logout");
	my $sid = $q->cookie("rc") || undef;
	my $s = new CGI::Session("driver:MySQL", $sid, {Handle=>$dbh});
	$s->param("uid", '');
	my $coo = $s->header();
	my $ipa = $q->remote_addr();
	$coo =~ s/ISO-8859-1/utf-8\n\n/g;
	@sid = ($coo,$sid[1],'',$ipa);
	#&input(qq{DELETE FROM sessions WHERE id="$sid"});
}
sub reset_expire() {
	my %p = %{$_[0]};
	@sid = &get_sid();
	my $expired = &fast(qq{SELECT id FROM sessions WHERE id="$sid[1]" AND created < SUBDATE(CURRENT_TIMESTAMP(), INTERVAL 60 MINUTE)});
	if ($expired eq $sid[1] and $sid[2] ne '') {
		$p{'do'} = "logout";
		$p{'message_error'} = $w{'w_auto_sign_out_notice'};
	} else {
		&input(qq{UPDATE sessions SET created=CURRENT_TIMESTAMP() WHERE id="$sid[1]"});
	}
	return %p;
}
sub get_lock_screen() {
	my %p = %{$_[0]};
	@sid = &get_sid();
	my $email = &fast(qq{SELECT email FROM rc_users WHERE entry="$sid[2]"});
	return qq{
		<div class="w800 p30to align-middle">
			<div class="bg-cloud">
				<div class="lang_bar">
					&nbsp;
				</div>
				<div class="align-middle w360 p100to">
					<div class="p20bo"><img src="$local_settings{"path_htdocs"}/images/img_logo_rc_new.png" 
					alt="RenalConnect"/></div>
					<form name="form_login" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
						<input type="hidden" name="token" value="$token"/>
						<input type="hidden" name="param_login_email" value="$email"/>
						<input type="hidden" name="do" value="unlock">
						<div class="p20bo"><div class="emp">$w{'w_auto_sign_out_notice'}</div></div>
						<table>
							<tbody>
								<tr>
									<td class="tr gt w100">$w{'Email_uc'}</td>
									<td class="tl p10lo p10bo">
										$email
									</td>
								</tr><tr>
									<td class="tr gt">$w{'Password'}</td>
									<td class="tl p10lo p10bo">
										<div class="itt"><input type="password" class="itt" name="param_login_password"/></div>
										<div class="p10to"><a href="password.pl">$w{'I forgot my password'}</a></div>
									</td>
								</tr><tr>
									<td class="tl gt">&nbsp;</td>
									<td class="tl p10lo p20bo">
										<input type="submit" value="$w{'Unlock'}"/>
										<div class="p10to"><a href="support.pl" class="b">$w{'Get technical support'}</a></div>
									</td>
								</tr>
							</tbody>
						</table>
					</form>
					<div class="gt sml">$w{'w_about_renalconnect'}</div>
				</div>
			</div>
		</div>
	};
}
sub auth() {
	@sid = &get_sid();
	if ($sid[2] ne '') {
		return $sid[1];
	} else {
		return '';
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
		if ($p{"do"} ne "lock") {
			%p = ();
		}
	}
	return %p;
}
sub display_checkboxes() {
	my $value = shift;
	if ($value eq '1') {
		return "checked";
	} else {
		return '';
	}
}
sub or_null() {
	my $input = shift;
	if ($input =~ /NULL/ or $input eq '' or $input eq "0000-00-00") {
		return qq{NULL};
	} else {
		return qq{"$input"};
	}
}
sub track() {
	my ($table, $entry) = @_;
	if ($table and $entry) {
		my $ip = $q->remote_addr;
		my $client = $q->user_agent();
		my %values = &queryh(qq{SELECT * FROM rc_$table WHERE entry="$entry"});
		my $keys = qq{hs_uid, hs_ip, hs_client, };
		my $query;
		foreach my $key (keys %values) {
			$keys = $keys . $key . ", ";
			$query = $query . qq{"} . $values{$key} . qq{", };
		}
		$keys =~ s/, $//g;
		$query =~ s/, $//g;
		my $final = qq{INSERT INTO rc__hs_$table ($keys) VALUES ("$sid[2]", "$ip", "$client", $query)};
		&input($final);
	}
}
sub header() {
	return qq{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" dir="ltr">
<head>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8" >
	<title>RenalConnect</title>
	<style type="text/css" media="all">\@import "$local_settings{"path_htdocs"}/main.css";</style>
	<script src="$local_settings{"path_htdocs"}/jquery.js"></script>
	<script src="$local_settings{"path_htdocs"}/main.js" type="text/javascript"></script>
	<script src="$local_settings{"path_htdocs"}/date.js" type="text/javascript"></script>
</head>};
}
sub footer_no_analytics() {
	return qq{</body></html>};
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
	return qq{<div class="float-r"><img src="$local_settings{"path_htdocs"}/images/close_off.png" alt="close" class="pointer" onclick="pop_up_hide(); clear_date_picker();" onmouseover="this.src='$local_settings{"path_htdocs"}/images/close_on.png';" onmouseout="this.src='$local_settings{"path_htdocs"}/images/close_off.png';"/></div>};
}
sub iframe() {
	return qq{
		<div class="hide">
			<iframe id="hbin" name="hbin" class="bin" src="$local_settings{"path_htdocs"}/images/blank.gif"></iframe>
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
sub store_state() {
	my %p = %{$_[0]};
	my $do = $p{'do'};
	if ($sid[2] ne '') {
		if (
			($do eq "view_active_cases") or 
			($do eq "view_cases") or 
			($do eq "view_patients") or 
			($do eq "view_labs") or 
			($do eq "view_reports") or 
			($do eq "view_active_lists") or 
			($do eq "view_lists") or 
			($do eq "view_list_reports")
		) {
			&input(qq{INSERT INTO rc_state (uid, param, value) VALUES ("$sid[2]", "tab", "$do") ON DUPLICATE KEY UPDATE value="$do"});
			&input(qq{INSERT INTO rc_state (uid, param, value) VALUES ("$sid[2]", "tab_filter", "$p{'filter'}") ON DUPLICATE KEY UPDATE value="$p{'filter'}"});
			&input(qq{INSERT INTO rc_state (uid, param, value) VALUES ("$sid[2]", "tab_page", "$p{'page'}") ON DUPLICATE KEY UPDATE value="$p{'page'}"});
			&input(qq{INSERT INTO rc_state (uid, param, value) VALUES ("$sid[2]", "tab_sort", "$p{'sort'}") ON DUPLICATE KEY UPDATE value="$p{'sort'}"});
		}
		if ($p{"form_active_lists_home_centres_filter"} ne '') {
			&input(qq{INSERT INTO rc_state (uid, param, value) VALUES ("$sid[2]", "active_lists_home_centres_filter", "$p{"form_active_lists_home_centres_filter"}") ON DUPLICATE KEY UPDATE value="$p{"form_active_lists_home_centres_filter"}"});
		}
		if ($p{"form_active_lists_patient_filter"} ne '') {
			&input(qq{INSERT INTO rc_state (uid, param, value) VALUES ("$sid[2]", "active_lists_patient_filter", "$p{"form_active_lists_patient_filter"}") ON DUPLICATE KEY UPDATE value="$p{"form_active_lists_patient_filter"}"});
		}
	}
}
sub build_select() {

	# BUILDS A DROP-DOWN MENU
	# THE FIRST ELEMENT IN THE INHERITED ARRAY IS THE SELECTED OPTION
	# IF THERE IS NO VALUE, A BLANK OPTION WILL BE APPENDED AND SELECTED AT THE END

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
		if ($active_data ne '' and $active_text ne '') {
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
	my $ago = ' ago';
	if ($w{'lang'} eq 'fr') {
		$ago = '';
	}
	if ($days == 0) {
		my ($hr,$mn,$sc) = split(/:/,$hour);
		$hr = &remove_leading_zeros($hr);
		$mn = &remove_leading_zeros($mn);
		if ($hr > 1) {
			$out = "$hr $w{'hours' . $ago}";
		} elsif ($hr == 1) {
			$out = "1 $w{'hour' . $ago}";
		} elsif ($mn == 1) {
			$out = "1 $w{'minute' . $ago}";
		} elsif ($mn > 1) {
			$out = "$mn $w{'minutes' . $ago}";
		} else {
			$out = $w{'moments' . $ago};
		}
	} elsif ($days < 1) {
		my ($hr,$mn,$sc) = split(/:/,$hour);
		$hr = &remove_leading_zeros($hr);
		$mn = &remove_leading_zeros($mn);
		$out = "$hr $w{'hours' . $ago}";
	} elsif ($days == 1) {
		$out = $w{'yesterday'};
	} elsif ($days > 1) {
		if ($days >= 730) {
			my $years = int(0.5 + ($days / 365.25));
			$out = "$years $w{'years' . $ago}";
		} elsif ($days >= 70) {
			my $months = int(0.5 + ($days / 30.4375));
			$out = "$months $w{'months' . $ago}";
		} elsif ($days >= 14) {
			my $weeks = int(0.5 + ($days / 7));
			$out = "$weeks $w{'weeks' . $ago}";
		} else {
			$out = "$days $w{'days' . $ago}";
		}
	}
	
	if ($w{'lang'} eq 'fr') {
		$out = 'il y a ' . $out;
	}
	return $out;
}
sub clean_up_time() {
    my $time = shift;
    $time =~ s/January/$w{'January'}/g;
    $time =~ s/February/$w{'February'}/g;
    $time =~ s/March/$w{'March'}/g;
    $time =~ s/April/$w{'April'}/g;
    $time =~ s/May/$w{'May'}/g;
    $time =~ s/June/$w{'June'}/g;
    $time =~ s/July/$w{'July'}/g;
    $time =~ s/August/$w{'August'}/g;
    $time =~ s/September/$w{'September'}/g;
    $time =~ s/October/$w{'October'}/g;
    $time =~ s/November/$w{'November'}/g;
    $time =~ s/December/$w{'December'}/g;
	$time =~ s/  /\&nbsp\; /g;
	$time =~ s/ 0/ /g;
    return $time;
}
sub nice_time() {
	my $time = shift;
	if ($w{'lang'} eq 'fr') {
		$time = &fast(qq{SELECT DATE_FORMAT("$time",'%d %M %Y  %H h %i');});
	} else {
		$time = &fast(qq{SELECT DATE_FORMAT("$time",'%M %d, %Y  %h:%i %p');});
	}
    $time = &clean_up_time($time);
	return $time;
}
sub nice_date() {
	my $time = shift;
	if ($w{'lang'} eq 'fr') {
		$time = &fast(qq{SELECT DATE_FORMAT("$time",'%d %M %Y');});
	} else {
		$time = &fast(qq{SELECT DATE_FORMAT("$time",'%M %d, %Y');});
	}
    $time = &clean_up_time($time);
	return $time;
}
sub get_age() {
	my $birthdate = shift;
	my $age = &fast(qq{SELECT DATEDIFF(CURDATE(), '$birthdate')});
	$age = int($age/365.242);
	return $age;
}
sub view_active_lists() {
	my %p = %{$_[0]};

	# BUILD HOME CENTER FILTER
	my @home_centres = &query(qq{SELECT DISTINCTROW home_centre FROM rc_lists WHERE (completed != "Yes" OR completed IS NULL)});
	my $saved_active_lists_patient_filter = &fast(qq{SELECT value FROM rc_state WHERE param="active_lists_patient_filter" AND uid="$sid[2]" LIMIT 1});
	my $saved_active_lists_home_centres_filter = &fast(qq{SELECT value FROM rc_state WHERE param="active_lists_home_centres_filter" AND uid="$sid[2]" LIMIT 1});
	my $active_lists_patient_filter_mysql;
	my $active_lists_home_centres_filter_mysql;
	if ($saved_active_lists_home_centres_filter eq '') {
		$saved_active_lists_home_centres_filter = "all centres";
		&input(qq{INSERT INTO rc_state (uid, param, value) VALUES ("$sid[2]", "active_lists_home_centres_filter", "$saved_active_lists_home_centres_filter")});
	}
	if ($saved_active_lists_patient_filter eq '') {
		$saved_active_lists_patient_filter = "all patients";
		&input(qq{INSERT INTO rc_state (uid, param, value) VALUES ("$sid[2]", "active_lists_patient_filter", "$saved_active_lists_patient_filter")});
	}
	if ($saved_active_lists_home_centres_filter ne "all centres") {
		$active_lists_home_centres_filter_mysql = qq{AND rc_lists.home_centre="$saved_active_lists_home_centres_filter"};
	}
	if ($saved_active_lists_patient_filter eq "patients with CVC and no AVF") {
		$active_lists_patient_filter_mysql = qq{AND (rc_lists.vascular_access_at_hd_start LIKE "\%CVC\%") AND (rc_lists.tn_avf_use_date IS NULL OR rc_lists.tn_avf_use_date = '0000-00-00')};
	} elsif ($saved_active_lists_patient_filter eq "patients without ACP completion date") {
		$active_lists_patient_filter_mysql = qq{AND rc_lists.most_completed_date IS NULL};
	} elsif ($saved_active_lists_patient_filter =~ /\d/) {
		$active_lists_patient_filter_mysql = qq{AND rc_patients.nephrologist="$saved_active_lists_patient_filter"};
	}
	my @nephrologists = &querymr(qq{SELECT entry, name_first, name_last FROM rc_users WHERE role="Nephrologist" AND deactivated="0" ORDER BY name_last ASC, name_first ASC});
	my @patient_filter_by_nephrologists;
	foreach my $n (@nephrologists) {
		my $nid = @$n[0];
		my $first = @$n[1];
		my $last = @$n[2];
		@patient_filter_by_nephrologists = (@patient_filter_by_nephrologists, "$nid;;$w{'patients of'} Dr. $first $last");
	}
	my $form_active_lists_patient_filter_options = &build_select(
		"$saved_active_lists_patient_filter;;$w{$saved_active_lists_patient_filter}",
		"all patients;;$w{'all patients'}",
		"patients with CVC and no AVF;;$w{'patients with CVC and no AVF'}",
		"patients without ACP completion date;;$w{'patients without ACP completion date'}",
		@patient_filter_by_nephrologists);
	my $form_active_lists_home_centres_filter_options = &build_select(
		"$saved_active_lists_home_centres_filter;;$w{'$saved_active_lists_home_centres_filter'}",
		@home_centres,
		"all centres;;$w{'all centres'}");
	my $home_centres_menu = qq{
		<form name="form_home_centre" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
			<input type="hidden" name="token" value="$token"/>
			$w{'View'} <select name="form_active_lists_patient_filter">
				$form_active_lists_patient_filter_options
			</select> 
			$w{'from'} <select name="form_active_lists_home_centres_filter">
				$form_active_lists_home_centres_filter_options
			</select>
			<input type="submit" value="$w{'Go'}"/>
		</form>
	};
	foreach my $centre (@home_centres) {
	}

	my @active_lists = &querymr(qq{SELECT 
			rc_lists.entry, 
			rc_lists.patient, 
			rc_lists.home_centre, 
			rc_lists.tn_initial_assessment_date, 
			rc_lists.tn_chosen_modality, 
			rc_lists.tn_chosen_modality_other, 
			rc_lists.comments, 
			rc_lists.created, 
			rc_lists.modified,
			rc_lists.flag_for_follow_up_date,
			rc_lists.follow_up_comments,
			rc_lists.modality_at_six_months,
			rc_lists.modality_at_twelve_months,
			rc_lists.most_completed_date
		FROM 
			rc_lists, rc_patients 
		WHERE (rc_lists.completed != "Yes" OR rc_lists.completed IS NULL) 
			AND rc_lists.patient = rc_patients.entry 
			$active_lists_home_centres_filter_mysql
			$active_lists_patient_filter_mysql
		ORDER BY rc_lists.modified DESC, rc_lists.created DESC;});
	my $output;
	my $rc = "bg-vlg";
	my $hidden = 0;
	foreach my $c (@active_lists) {
		my (
			$entry, 
			$patient, 
			$home_centre,
			$tn_initial_assessment_date,
			$tn_chosen_modality,
			$tn_chosen_modality_other,
			$comments, 
			$created, 
			$modified,
			$flag_for_follow_up_date,
			$follow_up_comments,
			$modality_at_six_months,
			$modality_at_twelve_months,
			$most_completed_date) = @$c;
		if (&fast(qq{SELECT 
				entry 
			FROM rc_hide 
			WHERE record_id="$entry" 
				AND record_type="list" 
				AND uid="$sid[2]" 
				AND hide_until >= NOW()})) {
			$hidden++;
		} else {
			my @p = &query(qq{SELECT 
					primary_nurse, 
					nephrologist, 
					phn, 
					phone_home, 
					phone_work, 
					phone_mobile, 
					email, 
					name_first, 
					name_last, 
					dialysis_center,
					date_of_birth,
					gender
				FROM 
					rc_patients 
				WHERE 
					entry="$patient"});
			my $comments_patient = &comments_patient($patient);

			# PRINT THE PATIENT'S PRIMARY NURSE
			my $nurse_print = qq{(none)};
			if ($p[0] ne '') {
				my ($nurse_fn, $nurse_ln) = &query(qq{SELECT name_first, name_last FROM rc_users WHERE entry="$p[0]"});
				$nurse_print = "$nurse_fn $nurse_ln";
			}

			# PRINT THE PATIENT'S PRIMARY NEPHROLOGIST
			my $nephrologist_print = qq{(none)};
			if ($p[1] ne '') {
				my ($nephr_fn, $nephr_ln) = &query(qq{SELECT name_first, name_last FROM rc_users WHERE entry="$p[1]"});
				$nephrologist_print = "Dr. $nephr_fn $nephr_ln";
			}

			# PRINT THE PATIENT'S PHN AND CONTACT INFORMATION
			my $p_contact = qq{<span class="gt">$w{'PHN'}</span> <span class="b">$p[2]</span>};
			$p_contact .= qq{ &nbsp; &nbsp; <span class="gt">$w{'home'}</span> <span class="b">$p[3]</span>} if ($p[3] ne '');
			$p_contact .= qq{ &nbsp; &nbsp; <span class="gt">$w{'work'}</span> <span class="b">$p[4]</span>} if ($p[4] ne '');
			$p_contact .= qq{ &nbsp; &nbsp; <span class="gt">$w{'mobile'}</span> <span class="b">$p[5]</span>} if ($p[5] ne '');
			$p_contact .= qq{ &nbsp; &nbsp; <span class="gt">$w{'email'}</span> <span class="b">$p[6]</span>} if ($p[6] ne '');
			$tn_chosen_modality = $w{$tn_chosen_modality};
			if ($tn_chosen_modality eq "Other") {
				$tn_chosen_modality = qq{$w{'Other'} (&quot;$w{"$tn_chosen_modality_other"}&quot;)};
			}
			my $list_created_print = &nice_date($created);
			my $list_created_interval_print = &nice_time_interval($created);
			my $list_updated_print = &nice_date($modified);
			my $list_updated_interval_print = &nice_time_interval($modified);

			my $initial_meeting_print = qq{(none)};
			if ($tn_initial_assessment_date ne '') {
				my $tn_assessment_date_print = &nice_date($tn_initial_assessment_date);
				my $tn_assessment_date_interval_print = &nice_time_interval($tn_initial_assessment_date);
				$initial_meeting_print = qq{<span class="b">$tn_assessment_date_interval_print ($tn_assessment_date_print)</span>};
			}
			
			my $age = &get_age($p[10]);
			if ($age > 1) {
				my $gender = substr($p[11], 0, 1);
				$age = qq{<span class="p10lo b">$age} . qq{$gender</span>};
			} else {
				$age = '';
			}
			
			my $follow_up_date = qq{($w{'not arranged'})};
			if ($follow_up_comments ne '') {
				$follow_up_comments = qq{($w{'reason'}: &quot;$follow_up_comments&quot;)};
			}
			if ($flag_for_follow_up_date ne '') {
				$follow_up_date = &nice_date($flag_for_follow_up_date);
			}
			my $stalefactor = "0";
			if ($tn_initial_assessment_date ne '') {
				$stalefactor = &fast(qq{SELECT DATEDIFF (CURDATE(), '$tn_initial_assessment_date')});
				$stalefactor = int($stalefactor / 10);
				if ($stalefactor > 9) {
					$stalefactor = 9;
				}
				$stalefactor = 9 - $stalefactor;
			}
			if ($comments ne '') {
				if (length($comments) > 500) {
					my @words = split(/ /, $comments);
					$comments = '';
					my $character_count = 0;
					foreach my $word (@words) {
						if ($character_count < 500) {
							$comments .= $word . ' ';
							$character_count = $character_count + length($word . ' ');
						}
					}
					$comments =~ s/ $/\.\.\./g;
				}
				$comments = qq{&quot;$comments&quot;};
			} else {
				$comments = qq{($w{'none'})};
			}
			my $date_diff;
			if ($tn_initial_assessment_date ne '') {
				$date_diff = &fast(qq{SELECT DATEDIFF(CURDATE(), '$tn_initial_assessment_date')});
			}
			if ($modality_at_six_months eq '') {
				if ($date_diff > (365/2)) {
					$modality_at_six_months = qq{<span class="ac-yellow">$w{'Please record the modality at 6 months'}</span>};
				} else {
					$modality_at_six_months = qq{($w{'to be determined'})};
				}
			} else {
				$modality_at_six_months = $w{$modality_at_six_months};
			}
			if ($modality_at_twelve_months eq '') {
				if ($date_diff > 365) {
					$modality_at_twelve_months = qq{<span class="ac-yellow">$w{'Please record the modality at 12 months'}</span>};
				} else {
					$modality_at_twelve_months = qq{($w{'to be determined'})};
				}
			} else {
				$modality_at_twelve_months = $w{$modality_at_twelve_months};
			}
			if ($most_completed_date eq '') {
				$most_completed_date = qq{<span class="ac-yellow">$w{'Please provide the ACP completion date'}</span>};
			} else {
				$most_completed_date = &nice_date($most_completed_date);
			}
			$output .= qq{
				<div class="p5to">
					<div class="p20bo bg-dbp-$stalefactor">
						<div class=''>
							<div class="p5">
                                <div class="float-r">$p_contact &nbsp; <a href="ajax.pl?token=$token&do=hide&record_id=$entry&record_type=list" target="$hbin_target" class="b">$w{'Hide'}</a></div>
								<a href="ajax.pl?token=$token&do=edit_patient_form&amp;patient_id=$patient" target="$hbin_target" onclick="blurry();"><span class="wH">$p[8], $p[7]</span></a> $comments_patient $age
							</div>
							<div class=''>
								<table class="w100p">
									<tbody>
										<tr>
											<td class="tl w30p">
												<div class="p5">
                                                    <div><span class="gt">$w{'Home centre'}:</span> <span class=''>$home_centre</span></div>
                                                    <div><span class="gt">$w{'Nephrologist'}:</span> <span class=''>$nephrologist_print</span></div>
                                                    <div><span class="gt">$w{'Created'}:</span> <span class=''>$list_created_interval_print ($list_created_print)</span></div>
                                                    <div><span class="gt">$w{'Last updated'}:</span> <span class=''>$list_updated_interval_print ($list_updated_print)</span></div>
												</div>
											</td>
											<td class="tl">
												<div class="p5">
                                                    <div><span class="gt">$w{'Initial meeting'}:</span> $initial_meeting_print</div>
                                                    <div><span class="gt">$w{'Chosen modality'}:</span> <span class="b">$tn_chosen_modality</span></div>
                                                    <div><span class="gt">$w{'ACP completion date'}:</span> $most_completed_date</div>
                                                    <div><span class="gt">$w{'Follow-up date'}:</span> <span class="b">$follow_up_date</span> <span class="gt">$follow_up_comments</span></div>
                                                    <div><span class="gt">$w{'Modality at 6 months'}:</span> $modality_at_six_months</div>
                                                    <div><span class="gt">$w{'Modality at 12 months'}:</span> $modality_at_twelve_months</div>
												</div>
											</td>
											<td class="tr w150 p10to p10ro">
												<a href="ajax.pl?token=$token&do=view_list&amp;list_id=$entry" target="$hbin_target" class="tron" onclick="blurry();">$w{'manage start'}</a>
											</td>
										</tr>
									</tbody>
								</table>
                                <div class="p5lo p5ro sml"><span class="gt b">$w{'Comments'}:</span> <span class="gt">$comments</span></div>
							</div>
						</div>
					</div>
				</div>};
			if ($rc eq '') {
				$rc = "bg-vlg";
			} else {
				$rc = '';
			}
		}
	}
	if ($output eq '') {
		$output = qq{<div class="p10to gt">$w{'There are currently no active starts to display'} ($hidden $w{'hidden for today'}). <a href="ajax.pl?token=$token&do=unhide&record_type=list" target="$hbin_target" class="b">$w{'Unhide all active starts'}</a> $w{'or'} <a href="ajax.pl?token=$token&do=view_list" target="$hbin_target" class="b">$w{'create a new start'}</a></div>};
	}
	return qq{
		<div class="p10to p5bo">
			<div class="float-r gt">$home_centres_menu</div>
			$button_add_patient
			$button_add_list
			
		</div>} . $output;
}
sub view_active_cases() {
	my %p = %{$_[0]};
	my @active_cases = &querymr(qq{SELECT entry, patient, case_type, initial_wbc, initial_pmn, hospitalization_required, hospitalization_location, hospitalization_start_date, hospitalization_stop_date, outcome, home_visit, next_step, comments, created, modified FROM rc_cases WHERE closed="0" ORDER BY modified DESC, created DESC});
	my $output;
	my $rc = "bg-vlg";
	my $hidden = 0;
	foreach my $c (@active_cases) {
		my ($entry, $patient, $case_type, $initial_wbc, $initial_pmn, $hospitalization_required, $hospitalization_location, $hospitalization_start_date, $hospitalization_stop_date, $outcome, $home_visit, $next_step, $comments, $created, $modified) = @$c;
		if (&fast(qq{SELECT entry FROM rc_hide WHERE record_id="$entry" AND record_type="case" AND uid="$sid[2]" AND hide_until >= NOW()})) {
			$hidden++;
		} else {
			my $infection_type = &get_infection_type($entry);
			my $hematology = qq{<span class="gt">$w{'Initial WBC'}:</span> };
			if ($initial_wbc ne '') {
				$hematology .= qq{<span class="b">$initial_wbc x 10<sup>6</sup>/L</span> &nbsp; };
			} else {
				$hematology .= qq{(not entered) &nbsp; };
			}
			$hematology .= qq{<span class="gt">$w{'Initial %PMN:'}</span> };
			if ($initial_pmn ne '') {
				$hematology .= qq{<span class="b">$initial_pmn\%</span>};
			} else {
				$hematology .= qq{($w{'not entered'}) &nbsp; };
			}
			my @p = &query(qq{SELECT primary_nurse, nephrologist, phn, phone_home, phone_work, phone_mobile, email, name_first, name_last, dialysis_center, date_of_birth, gender FROM rc_patients WHERE entry="$patient"});
			my $age = &get_age($p[10]);
			if ($age > 1) {
				my $gender = substr($p[11], 0, 1);
				$age = qq{<span class="p10lo b">$age} . qq{$gender</span>};
			} else {
				$age = '';
			}
			my $pd_centre = &fast(qq{SELECT center FROM rc_dialysis WHERE patient_id="$patient" ORDER BY modified DESC LIMIT 1});
			my $comments_patient = &comments_patient($patient);
			if ($comments_patient) {
				$comments_patient = qq{<span class="p10lo">$comments_patient</span>};
			}
			my $nurse_print = qq{(none)};
			my $nephrologist_print = qq{(none)};
			if ($p[0] ne '') {
				my ($nurse_fn, $nurse_ln) = &query(qq{SELECT name_first, name_last FROM rc_users WHERE entry="$p[0]"});
				$nurse_print = "$nurse_fn $nurse_ln";
			}
			if ($p[1] ne '') {
				my ($nephr_fn, $nephr_ln) = &query(qq{SELECT name_first, name_last FROM rc_users WHERE entry="$p[1]"});
				$nephrologist_print = "Dr. $nephr_fn $nephr_ln";
			}
			my $p_contact = qq{<span class="gt">$w{'PHN'}</span> <span class="b">$p[2]</span>};
			$p_contact .= qq{ &nbsp; &nbsp; <span class="gt">$w{'home'}</span> <span class="b">$p[3]</span>} if ($p[3] ne '');
			$p_contact .= qq{ &nbsp; &nbsp; <span class="gt">$w{'work'}</span> <span class="b">$p[4]</span>} if ($p[4] ne '');
			$p_contact .= qq{ &nbsp; &nbsp; <span class="gt">$w{'mobile'}</span> <span class="b">$p[5]</span>} if ($p[5] ne '');
			$p_contact .= qq{ &nbsp; &nbsp; <span class="gt">$w{'email'}</span> <span class="b">$p[6]</span>} if ($p[6] ne '');
			my $onset_date = &nice_date($created);
			$onset_date =~ s/ /&nbsp;/g;
			my $onset_when = &nice_time_interval($modified);
			my $hospital_l = qq{<span class="p10lo b">$w{'Outpatient'}</span>};
			my $case_status = $outcome;
			if ($hospitalization_required eq "Yes") {
				if ($hospitalization_stop_date eq '' or &fast(qq{SELECT DATEDIFF(CURDATE(), "$hospitalization_stop_date")}) < 0) {
					$hospital_l = qq{<span class="p10lo"><strong>$w{'Admitted'}</strong> to $hospitalization_location</span>};
				} else {
					$hospital_l = qq{<span class="p10lo"><strong>$w{'Admitted'}</strong> $w{'to'} $hospitalization_location ($w{'now discharged'})</span>};
				}
			}
			my ($culture_report, $abx_prescribed, $abx_prescribed_final, $abx_prescribed_empiric, $abx_label_text, $abx_completion);
			my @abxs = &query(qq{SELECT entry FROM rc_antibiotics WHERE case_id="$entry" AND date_end > CURRENT_DATE() AND date_stopped > CURRENT_DATE() ORDER BY entry DESC});
			my $abxs_done = &fast(qq{SELECT COUNT(*) FROM rc_antibiotics WHERE case_id="$entry"});
			foreach my $abx (@abxs) {
				my %a = &queryh(qq{SELECT * FROM rc_antibiotics WHERE entry="$abx"});
				my $nice_date = &nice_date($a{"date_end"});
				my $temp_text = qq{<span class="b">$a{"antibiotic"}</span> $a{"dose_amount"} $a{"dose_amount_units"} $a{"dose_frequency"}, };
				if ($a{"basis_final"} == 1) {
					$abx_prescribed_final .= $temp_text;
				} else {
					$abx_prescribed_empiric .= $temp_text;
				}
			}
			if ($abx_prescribed_final ne '') {
				$abx_prescribed = $abx_prescribed_final;
				$abx_label_text = $w{'Final antibiotics'};
			} else {
				$abx_prescribed = $abx_prescribed_empiric;
				$abx_label_text = $w{'Empiric antibiotics'};
			}
			my ($abx_bar, $abx_percent) = &build_abx_bar(&fast(qq{SELECT entry FROM rc_antibiotics WHERE case_id="$entry" ORDER BY date_stopped DESC,  date_start ASC LIMIT 1}));
			$abx_prescribed =~ s/, $//g;
			if ($abx_prescribed eq '') {
				$abx_bar = qq{};
				if ($abxs_done > 0) {
					$abx_label_text = $w{'Antibiotics'};
					$abx_prescribed = qq{<span class="b">$w{'course completed'}</span>};
					&get_next_step($entry);
				} else {
					$abx_prescribed = qq{<span class="b">$w{'none'}</span>};
				}
			}
			my @labs = &query(qq{SELECT entry FROM rc_labs WHERE case_id="$entry" ORDER BY entry DESC});
			foreach my $l (@labs) {
				my %l = &queryh(qq{SELECT * FROM rc_labs WHERE entry="$l"});
				my $last_updated = &nice_time_interval($l{"modified"});
				foreach my $slot (1..4) {
					my $bacteria = $l{"pathogen_$slot"};
					$bacteria = $w{$bacteria} if $w{$bacteria} ne '';
					$culture_report .= qq{$bacteria ($last_updated); } if $bacteria;
				}
			}
			if ($culture_report eq '') {
				$culture_report = qq{<span class="b">$w{'no result'}</span>};
			}
			$culture_report =~ s/; $//g;
			$next_step = &fast(qq{SELECT next_step FROM rc_cases WHERE entry="$entry" LIMIT 1});
			my $next_step_raw = $next_step;
			$next_step = &interpret_next_step($next_step);
			$infection_type = lcfirst $w{$infection_type};
			$home_visit = lcfirst $w{$home_visit};
			$case_type = lcfirst $w{$case_type};
			$output .= qq{
				<div class="p5to">
					<div class="p20bo bg-dbp-$next_step_raw">
						<div class=''>
							<div class="p5">
                                <div class="float-r">$p_contact &nbsp; <a href="ajax.pl?token=$token&do=hide&record_id=$entry&record_type=case" target="$hbin_target" class="b" onclick="blurry();">$w{'Hide'}</a></div>
								<a href="ajax.pl?token=$token&do=edit_patient_form&amp;patient_id=$patient" target="$hbin_target"><span class="wH">$p[8], $p[7]</span></a> $comments_patient $age $hospital_l
                                <div><span class="gt">$w{'Primary nurse'}:</span> <span class=''>$nurse_print</span> &nbsp; &nbsp; <span class="gt">$w{'Nephrologist'}:</span> <span class=''>$nephrologist_print</span> &nbsp; &nbsp; <span class="gt">$w{'PD centre'}:</span> $pd_centre</div>
							</div>
							<div class=''><table class="w100p">
								<tbody>
									<tr>
										<td class="tl w30p"><div class="p5">
											<div><span class="gt">$w{'Presentation date'}:</span> <span class="b">$onset_date</span></div>
											<div><span class="gt">$w{'Last updated'}:</span> <span class="b">$onset_when</span></div>
											<div><span class="gt">$w{'Case type'}:</span> $case_type</div>
											<div><span class="gt">$w{'Infection type'}:</span> $infection_type</div>
											<div><span class="gt">$w{'Follow-up visit'}:</span> $home_visit</div>
										</div></td>
										<td class="tl"><div class="p5">
											<div><span class="gt">$w{'Culture report'}:</span> $culture_report</div>
											<div><span class="gt">$abx_label_text:</span> $abx_prescribed $abx_bar</div>
											<div class="p10to"><span class="ac-yellow">$w{'Next step'}: $next_step</span></div>
										</div></td>
										<td class="tr w150 p10ro">
											<a href="ajax.pl?token=$token&do=edit_case_form&amp;case_id=$entry" target="$hbin_target" class="tron" onclick="blurry();">$w{'manage case'}</a>
										</td>
									</tr>
								</tbody>
							</table></div>
						</div>
					</div>
				</div>};
			if ($rc eq '') {
				$rc = "bg-vlg";
			} else {
				$rc = '';
			}
		}
	}
	if ($output eq '') {
		$output = qq{<div class="p10to gt">$w{'There are currently no active cases to display'} ($hidden $w{'hidden for today'}). <a href="ajax.pl?token=$token&do=unhide&record_type=case" target="$hbin_target" class="b">$w{'Unhide all active cases'}</a> $w{'or'} <a href="ajax.pl?token=$token&do=add_case_form" target="$hbin_target" class="b">$w{'create a case'}</a></div>};
	}
	$output = qq{
 		<div class="p10to p5bo">
 			$button_add_patient
 			$button_add_case
 		</div>} . $output;
	return $output;
}
sub comments_patient() {
	my $entry = shift;
	if (&fast(qq{SELECT comments FROM rc_patients WHERE entry="$entry"}) ne '') {
		return $comment_icon;
	} else {
		return '';
	}
}
sub comments_case() {
	my $entry = shift;
	my $comments_case = &fast(qq{SELECT comments FROM rc_cases WHERE entry="$entry"});
	my $comments_abx;
	my $comments_lab;
	my @abxs = &query(qq{SELECT comments FROM rc_antibiotics WHERE case_id="$entry"});
	my @labs = &query(qq{SELECT comments FROM rc_labs WHERE case_id="$entry"});
	foreach my $abx (@abxs) {
		if ($abx ne '') {
			$comments_abx = 1;
		}
	}
	foreach my $lab (@labs) {
		if ($lab ne '') {
			$comments_lab = 1;
		}
	}
	if ($comments_case ne '' or $comments_abx ne '' or $comments_lab ne '') {
		return $comment_icon;
	} else {
		return '';
	}
}
sub comments_antibiotic() {
	my $entry = shift;
	if (&fast(qq{SELECT comments FROM rc_antibiotics WHERE entry="$entry"}) ne '') {
		return $comment_icon;
	} else {
		return '';
	}
}
sub comments_lab() {
	my $entry = shift;
	if (&fast(qq{SELECT comments FROM rc_labs WHERE entry="$entry"}) ne '') {
		return $comment_icon;
	} else {
		return '';
	}
}
sub view_lists() {
	my %p = %{$_[0]};
	$p{'do'} = "view_lists";


	# BUILDS PATIENT ID AND NAME FILTERS
	# Filters the results based on a string of text provided
	# or a discreet patient database "entry" ID.

	my ($filter, $notice);
	if ($p{"filter"}) {
		$filter .= qq{AND (};
		my @split = split(/ /,$p{"filter"});
		foreach my $word (@split) {
			$filter .= qq{rc_patients.name_first LIKE "\%$word\%" OR rc_patients.name_last LIKE "\%$word\%" OR };
		}
		$filter =~ s/ OR $/\) /g;
	}
	if ($p{'patient_id'} ne '' and &fast(qq{SELECT entry FROM rc_patients WHERE entry="$p{'patient_id'}" LIMIT 1}) ne '') {
		my ($name_first, $name_last, $phn) = &query(qq{SELECT name_first, name_last, phn FROM rc_patients WHERE entry="$p{'patient_id'}" LIMIT 1});
		$filter .= qq{AND rc_lists.patient="$p{'patient_id'}"};
		$notice .= qq{<div class="p10bo"><div class="warning"><span class="b">$w{'Displaying lists for'} $name_first $name_last</span> <span class="gt">($w{'PHN'} $phn)</span> &nbsp; <a href="ajax.pl?token=$token&do=view_lists" target="$hbin_target" onclick="tt('nav','6','7');">$w{'Click here'}</a> $w{'to see all lists'}.</div></div>};
	}



	# COUNTS HOW MANY RECORDS EXIST

	$p{"page_total_records"} = &fast(qq{SELECT COUNT(*) FROM rc_lists $filter});



	# IF THE RESULTS ARE BEING FILTERED, DISPLAY ALL IN ONE PAGE
	# OTHERWISE, PAGINATE AT 20 RECORDS PER PAGE

	if ($p{'patient_id'} ne '' or $p{"filter"} ne '') {
		$p{"page"} = '1';
		$p{"page_q"} = 10000;
	} else {
		$p{"page"} = '1' if $p{"page"} eq '';
		$p{"page_q"} = 20;
	}



	# SORTING MECHANISM
	# The chunk of code below builds the clickable table headers.
	# Place this code high up as the sort_by_modify is required to
	# build the MySQL query.

	my %sort_by_labels = (
		"id" => "ID",
		"status" => $w{'Status'},
		"modality" => $w{'Chosen modality'},
		"patient_name" => $w{'Patient name'},
		"initial_assessment" => $w{'First assessment'},
		"modified" => $w{'Last updated'});

	my %sort_by_modify = (
		"id" => "rc_lists.entry ASC",
		"status" => "rc_lists.completed ASC",
		"modality" => "rc_lists.tn_chosen_modality ASC",
		"patient_name" => "rc_patients.name_last ASC",
		"initial_assessment" => "rc_lists.tn_initial_assessment_date DESC",
		"modified" => "rc_lists.modified DESC");

	my $query_sort_by = $sort_by_modify{$p{"sort"}};
	if ($query_sort_by eq '') {
		$query_sort_by = $sort_by_modify{"status"};
		$p{"sort"} = "status";
	}
	foreach my $key (keys %sort_by_labels) {
		if ($key ne $p{"sort"}) {
			$sort_by_labels{$key} = qq{<a target="$hbin_target" href="ajax.pl?token=$token&do=$p{'do'}&patient_id=$p{'patient_id'}&filter=$p{"filter"}&sort=} . $key . qq{">} . $sort_by_labels{$key} . qq{</a>};
		} else {
			$sort_by_labels{$key} = qq{<span class="b">} . $sort_by_labels{$key} . qq{</span> <img src="$local_settings{"path_htdocs"}/images/ats_d.gif" alt='' align="absmiddle"/>};
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
			<form name="form_page_jumper" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
				<input type="hidden" name="do" value="$p{'do'}"/>
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
            $p{"page_limit_offset_human"} $w{'to'} $p{"page_limit_offset_human_tail"} $w{'of'} $p{"page_total_records"} &nbsp; };
		if ($p{"page"} > 1) {
			my $prev_page = $p{"page"} - 1;
			$pager .= qq{<a href="ajax.pl?token=$token&do=$p{'do'}&page=$prev_page&patient_id=$p{'patient_id'}&filter=$p{"filter"}&sort=$p{"sort"}" target="$hbin_target" class="b">$w{'previous'}</a> &nbsp; };
		} else {
			$pager .= qq{<span class="gt b">$w{'previous'}</span> &nbsp; };
		}
		if ($p{"page"} + 1 <= $p{"pages"}) {
			my $next_page = $p{"page"} + 1;
			$pager .= qq{<a href="ajax.pl?token=$token&do=$p{'do'}&page=$next_page&patient_id=$p{'patient_id'}&filter=$p{"filter"}&sort=$p{"sort"}" target="$hbin_target" class="b">$w{'next'}</a>};
		} else {
			$pager .= qq{<span class="gt b">$w{'next'}</span>};
		}
		$pager .= qq{ &nbsp; $w{'go to page'} <select name="page">$pages</select> <input type="submit" value="$w{'Go'}"/></div>};
	}
	my $reset_button = qq{<a href="ajax.pl?token=$token&do=$p{'do'}" target="$hbin_target" class="b">$w{'reset'}</a>};
	$reset_button = qq{} if $p{"filter"} eq '';
	$pager .= qq{
				<div>
					<div class="float-l p10ro">
						$button_add_patient
						$button_add_list
					</div>
					<div class="float-l p1to p5ro">$w{'Filter by patient name'}</div>
					<div class="float-l p5ro"><div class="itt w120"><input type="text" class="itt" name="filter" value="$p{"filter"}"/></div></div>
					<div class="float-l"><input type="submit" value="$w{'Search'}"/> &nbsp; $reset_button</div>
					<div class="clear-l"></div>
				</div>
			</form>
			<div class="clear-r"></div>
		</div>};

	my @lists = &querymr(qq{SELECT 
		rc_lists.entry, 
		rc_lists.patient, 
		rc_lists.completed, 
		rc_lists.tn_chosen_modality, 
		rc_lists.tn_initial_assessment_date, 
		rc_lists.created, 
		rc_lists.modified, 
		rc_patients.name_last, 
		rc_patients.name_first, 
		rc_patients.phn 
			FROM 
		rc_lists, rc_patients 
			WHERE 
		rc_patients.entry=rc_lists.patient $filter 
		ORDER BY $query_sort_by, rc_patients.name_last ASC 
		LIMIT $p{"page_limit_offset"}, $p{"page_q"}});
	my $lists;
	my $rc = "bg-vlg";
	foreach my $c (@lists) {
		my (
			$entry, 
			$patient, 
			$completed, 
			$tn_chosen_modality, 
			$tn_initial_assessment_date, 
			$created, 
			$modified, 
			$name_last, 
			$name_first, 
			$phn) = @$c;
		$created = &nice_time_interval($created);
		$modified = &nice_time_interval($modified);
		my $status = qq{<span class="b txt-gre">$w{'Active_uc'}</span>};
		my $manage_list_button = qq{<a target="$hbin_target" href="ajax.pl?token=$token&do=view_list&list_id=$entry">$w{'manage start'}</a>};
		if ($completed eq "Yes") {
			$status = qq{<span class="b txt-red">$w{'Closed_uc'}</span>};
			$manage_list_button = qq{<a target="$hbin_target" href="ajax.pl?token=$token&do=view_list&list_id=$entry">$w{'manage start'}</a>};
		}
		my $comments_patient = &comments_patient($patient);
		if ($tn_initial_assessment_date eq '') {
			$tn_initial_assessment_date = qq{($w{'none'})};
		} else {
			$tn_initial_assessment_date = &nice_time_interval($tn_initial_assessment_date);
		}
		if ($tn_chosen_modality eq '') {
			$tn_chosen_modality = qq{<span class="gt">($w{'not specified'})</span>};
		} else {
			$tn_chosen_modality = $w{$tn_chosen_modality};
		}
		$lists .= qq{
			<tr class="$rc">
				<td class="pfmb_l gt">$entry</td>
				<td class="pfmb_l">$status &nbsp; $manage_list_button</td>
				<td class="pfmb_l">$tn_chosen_modality</td>
				<td class="pfmb_l"><a target="$hbin_target" href="ajax.pl?token=$token&do=edit_patient_form&patient_id=$patient"><strong>$name_last</strong>, $name_first</a> $comments_patient</td>
				<td class="pfmb_l">$tn_initial_assessment_date</td>
				<td class="pfmb_l">$modified</td>
			</tr>
		};
		if ($rc eq '') {
			$rc = "bg-vlg";
		} else {
			$rc = '';
		}
	}
	if ($lists eq '') {
		$lists = qq{<tr><td class="pfmb_l gt" colspan="6">$w{'No starts found'}.</td></tr>};
	}
	return qq{
		$pager
		$notice
		<table class="pfmt w100p">
			<tbody>
				<tr>
					<td class="pfmb_l b bg-dbp w5p">$sort_by_labels{"id"}</td>
					<td class="pfmb_l b bg-dbp w18p">$sort_by_labels{"status"}</td>
					<td class="pfmb_l b bg-dbp w24p">$sort_by_labels{"modality"}</td>
					<td class="pfmb_l b bg-dbp">$sort_by_labels{"patient_name"}</td>
					<td class="pfmb_l b bg-dbp w13p">$sort_by_labels{"initial_assessment"}</td>
					<td class="pfmb_l b bg-dbp w13p">$sort_by_labels{"modified"}</td>
				</tr>
				$lists
			</tbody>
		</table>
	};
}
sub view_cases() {
	my %p = %{$_[0]};
	$p{'do'} = "view_cases";


	# BUILDS PATIENT ID AND NAME FILTERS
	# Filters the results based on a string of text provided
	# or a discreet patient database "entry" ID.

	my ($filter, $notice);
	$p{"filter"} = &fast(qq{SELECT value FROM rc_state WHERE uid="$sid[2]" AND param="tab_filter" LIMIT 1});
	$p{"page"} = &fast(qq{SELECT value FROM rc_state WHERE uid="$sid[2]" AND param="tab_page" LIMIT 1});
	$p{"sort"} = &fast(qq{SELECT value FROM rc_state WHERE uid="$sid[2]" AND param="tab_sort" LIMIT 1});
	if ($p{"filter"}) {
		$filter .= qq{AND (};
		my @split = split(/ /,$p{"filter"});
		foreach my $word (@split) {
			$filter .= qq{rc_patients.name_first LIKE "\%$word\%" OR rc_patients.name_last LIKE "\%$word\%" OR };
		}
		$filter =~ s/ OR $/\) /g;
	}
	if ($p{'patient_id'} ne '' and &fast(qq{SELECT entry FROM rc_patients WHERE entry="$p{'patient_id'}" LIMIT 1}) ne '') {
		my ($name_first, $name_last, $phn) = &query(qq{SELECT name_first, name_last, phn FROM rc_patients WHERE entry="$p{'patient_id'}" LIMIT 1});
		$filter .= qq{AND rc_cases.patient="$p{'patient_id'}"};
		$notice .= qq{<div class="p10bo"><div class="warning"><span class="b">$w{'Displaying cases for'} $name_first $name_last</span> <span class="gt">($w{'PHN'} $phn)</span> &nbsp; <a href="ajax.pl?token=$token&do=view_cases" target="$hbin_target" onclick="tt('nav','1','7');">$w{'Click here'}</a> $w{'to see all cases'}.</div></div>};
	}



	# COUNTS HOW MANY RECORDS EXIST

	$p{"page_total_records"} = &fast(qq{SELECT COUNT(*) FROM rc_cases $filter});



	# IF THE RESULTS ARE BEING FILTERED, DISPLAY ALL IN ONE PAGE
	# OTHERWISE, PAGINATE AT 20 RECORDS PER PAGE

	if ($p{'patient_id'} ne '' or $p{"filter"} ne '') {
		$p{"page"} = '1';
		$p{"page_q"} = 10000;
	} else {
		$p{"page"} = '1' if $p{"page"} eq '';
		$p{"page_q"} = 20;
	}



	# SORTING MECHANISM
	# The chunk of code below builds the clickable table headers.
	# Place this code high up as the sort_by_modify is required to
	# build the MySQL query.

	my %sort_by_labels = (
		"id" => "ID",
    "status" => $w{'Status'},
    "outcome" => $w{'Outcome'},
    "patient_name" => $w{'Patient name'},
    "next_step" => $w{'Next step'},
    "created" => $w{'Created'},
    "date_of_onset" => $w{'Onset'});
	my %sort_by_modify = (
		"id" => "rc_cases.entry ASC",
		"status" => "rc_cases.closed ASC",
		"outcome" => "rc_cases.outcome ASC",
		"patient_name" => "rc_patients.name_last ASC",
		"next_step" => "rc_cases.next_step DESC",
		"created" => "rc_cases.created DESC",
		"date_of_onset" => "rc_cases.created DESC");
	my $query_sort_by = $sort_by_modify{$p{"sort"}};
	if ($query_sort_by eq '') {
		$query_sort_by = $sort_by_modify{"status"};
		$p{"sort"} = "status";
	}
	foreach my $key (keys %sort_by_labels) {
		if ($key ne $p{"sort"}) {
			$sort_by_labels{$key} = qq{<a target="$hbin_target" href="ajax.pl?token=$token&do=$p{'do'}&patient_id=$p{'patient_id'}&filter=$p{"filter"}&sort=} . $key . qq{">} . $sort_by_labels{$key} . qq{</a>};
		} else {
			$sort_by_labels{$key} = qq{<span class="b">} . $sort_by_labels{$key} . qq{</span> <img src="$local_settings{"path_htdocs"}/images/ats_d.gif" alt='' align="absmiddle"/>};
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
			<form name="form_page_jumper" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
				<input type="hidden" name="do" value="$p{'do'}"/>
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
            $p{"page_limit_offset_human"} $w{'to'} $p{"page_limit_offset_human_tail"} $w{'of'} $p{"page_total_records"} &nbsp; };
		if ($p{"page"} > 1) {
			my $prev_page = $p{"page"} - 1;
			$pager .= qq{<a href="ajax.pl?token=$token&do=$p{'do'}&page=$prev_page&patient_id=$p{'patient_id'}&filter=$p{"filter"}&sort=$p{"sort"}" target="$hbin_target" class="b">$w{'previous'}</a> &nbsp; };
		} else {
			$pager .= qq{<span class="gt b">$w{'previous'}</span> &nbsp; };
		}
		if ($p{"page"} + 1 <= $p{"pages"}) {
			my $next_page = $p{"page"} + 1;
			$pager .= qq{<a href="ajax.pl?token=$token&do=$p{'do'}&page=$next_page&patient_id=$p{'patient_id'}&filter=$p{"filter"}&sort=$p{"sort"}" target="$hbin_target" class="b">$w{'next'}</a>};
		} else {
			$pager .= qq{<span class="gt b">$w{'next'}</span>};
		}
		$pager .= qq{ &nbsp; $w{'go to page'} <select name="page">$pages</select> <input type="submit" value="$w{'Go'}"/></div>};
	}
	my $reset_button = qq{<a href="ajax.pl?token=$token&do=$p{'do'}" target="$hbin_target" class="b">$w{'reset'}</a>};
	$reset_button = qq{} if $p{"filter"} eq '';
 	$pager .= qq{
 				<div>
 					<div class="float-l p10ro">
 						$button_add_patient
 						$button_add_case
 					</div>
        <div class="float-l p1to p5ro">$w{'Search'}</div>
 					<div class="float-l p5ro"><div class="itt w120"><input type="text" class="itt" name="filter" value="$p{"filter"}"/></div></div>
 					<div class="float-l"><input type="submit" value="$w{'Search'}"/> &nbsp; $reset_button</div>
 					<div class="clear-l"></div>
 				</div>
 			</form>
 			<div class="clear-r"></div>
 		</div>};


	my @cases = &querymr(qq{SELECT rc_cases.entry, rc_cases.patient, rc_cases.case_type, rc_cases.hospitalization_required, rc_cases.hospitalization_location, rc_cases.outcome, rc_cases.home_visit, rc_cases.next_step, rc_cases.comments, rc_cases.created, rc_cases.modified, rc_cases.closed, rc_patients.name_last, rc_patients.name_first, rc_patients.phn FROM rc_cases, rc_patients WHERE rc_patients.entry=rc_cases.patient $filter ORDER BY $query_sort_by, rc_patients.name_last ASC LIMIT $p{"page_limit_offset"}, $p{"page_q"}});
	my $cases;
	my $rc = "bg-vlg";
	foreach my $c (@cases) {
		my ($entry, $patient, $case_type, $hospitalization_required, $hospitalization_location, $outcome, $home_visit, $next_step, $comments, $created, $modified, $closed, $name_last, $name_first, $phn) = @$c;
		$created = &nice_time_interval($created);
		$modified = &nice_time_interval($modified);
		$next_step = &interpret_next_step($next_step);
		my $infection_type = &get_infection_type($entry);
		my $status = qq{<span class="b txt-gre">$w{'Active_uc'}</span>};
		my $manage_case_button = qq{<a target="$hbin_target" href="ajax.pl?token=$token&do=edit_case_form&case_id=$entry">$w{'manage case'}</a>};
		if ($closed eq '1') {
			$status = qq{<span class="b txt-red">$w{'Closed_uc'}</span>};
			$manage_case_button = qq{<a target="$hbin_target" href="ajax.pl?token=$token&do=edit_case_form&case_id=$entry">$w{'review case'}</a>};
		}
		my $comments_patient = &comments_patient($patient);
		my $comments_case = &comments_case($entry);
		$outcome = $w{$outcome};
		$cases .= qq{
			<tr class="$rc">
				<td class="pfmb_l gt">$entry</td>
				<td class="pfmb_l">$status &nbsp; $manage_case_button $comments_case</td>
				<td class="pfmb_l">$outcome</td>
				<td class="pfmb_l"><a target="$hbin_target" href="ajax.pl?token=$token&do=edit_patient_form&patient_id=$patient"><strong>$name_last</strong>, $name_first</a> $comments_patient</td>
				<td class="pfmb_l">$next_step</td>
				<td class="pfmb_l">$modified</td>
			</tr>
		};
		if ($rc eq '') {
			$rc = "bg-vlg";
		} else {
			$rc = '';
		}
	}
	if ($cases eq '') {
		$cases = qq{<tr><td class="pfmb_l gt" colspan="6">$w{'No cases found'}.</td></tr>};
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
		$cache_case_status,
		$cache_lists,
		$cache_list_status);
	my ($primary_nurse, $nephrologist) = &query(qq{SELECT primary_nurse, nephrologist FROM rc_patients WHERE entry="$patient_id"});
	my $pd_stop_date = &fast(qq{SELECT stop_date FROM rc_dialysis WHERE patient_id="$patient_id" ORDER BY entry DESC LIMIT 1});
	if ($primary_nurse ne '') {
		$cache_primary_nurse = join(", ",&query(qq{SELECT name_last, name_first FROM rc_users WHERE entry="$primary_nurse"}));
	}
	if ($nephrologist ne '') {
		$cache_nephrologist = join(", ",&query(qq{SELECT name_last, name_first FROM rc_users WHERE entry="$nephrologist"}));
	}
	$cache_on_pd = $pd_stop_date;
	$cache_cases = &fast(qq{SELECT COUNT(*) FROM rc_cases WHERE patient="$patient_id"});
	$cache_case_status = &fast(qq{SELECT closed FROM rc_cases WHERE patient="$patient_id" ORDER BY closed ASC LIMIT 1});
	$cache_lists = &fast(qq{SELECT COUNT(*) FROM rc_lists WHERE patient="$patient_id"});
	$cache_list_status = &fast(qq{SELECT completed FROM rc_lists WHERE patient="$patient_id" ORDER BY completed DESC LIMIT 1});
	&input(qq{UPDATE rc_patients SET 
		cache_primary_nurse="$cache_primary_nurse",
		cache_nephrologist="$cache_nephrologist",
		cache_on_pd="$cache_on_pd",
		cache_cases="$cache_cases",
		cache_case_status="$cache_case_status",
		cache_lists="$cache_lists",
		cache_list_status="$cache_list_status"
		WHERE entry="$patient_id"});
}
sub view_patients() {
	my %p = %{$_[0]};
	$p{'do'} = "view_patients";



	# BUILDS NAME FILTERS
	# Filters the results based on a string of text provided
	# or a discreet patient database "entry" ID.

	$p{"filter"} = &fast(qq{SELECT value FROM rc_state WHERE uid="$sid[2]" AND param="tab_filter" LIMIT 1});
	$p{"page"} = &fast(qq{SELECT value FROM rc_state WHERE uid="$sid[2]" AND param="tab_page" LIMIT 1});
	$p{"sort"} = &fast(qq{SELECT value FROM rc_state WHERE uid="$sid[2]" AND param="tab_sort" LIMIT 1});
	my ($filter, $notice);
	if ($p{"filter"}) {
		$filter .= qq{WHERE };
		my @split = split(/ /,$p{"filter"});
		foreach my $word (@split) {
			$filter .= qq{rc_patients.name_first LIKE "\%$word\%" OR rc_patients.name_last LIKE "\%$word\%" OR rc_patients.phn LIKE "\%$word\%" OR rc_patients.cache_primary_nurse LIKE "\%$word\%" OR rc_patients.cache_nephrologist LIKE "\%$word\%" OR };
		}
		$filter =~ s/ OR $//g;
	}



	# COUNTS HOW MANY RECORDS EXIST

	$p{"page_total_records"} = &fast(qq{SELECT COUNT(*) FROM rc_patients $filter});



	# IF THE RESULTS ARE BEING FILTERED, DISPLAY ALL IN ONE PAGE
	# OTHERWISE, PAGINATE AT 20 RECORDS PER PAGE

	if ($p{"filter"} ne '') {
		$p{"page"} = '1';
		$p{"page_q"} = 10000;
	} else {
		$p{"page"} = '1' if $p{"page"} eq '';
		$p{"page_q"} = 20;
	}



	# SORTING MECHANISM
	# The chunk of code below builds the clickable table headers.
	# Place this code high up as the sort_by_modify is required to
	# build the MySQL query.

	my %sort_by_labels = (
		"id" => "ID",
    "name" => $w{'Name'},
    "phn" => $w{'PHN'},
    "primary_nurse" => $w{'Primary nurse'},
    "nephrologist" => $w{'Nephrologist'},
    "on_pd" => $w{'On PD'},
    "cases" => $w{'Cases'},
    "status" => $w{'Status'});
	my %sort_by_modify = (
		"id" => "rc_patients.entry ASC",
		"name" => "rc_patients.name_last ASC",
		"phn" => "rc_patients.phn ASC",
		"primary_nurse" => "rc_patients.cache_primary_nurse ASC",
		"nephrologist" => "rc_patients.cache_nephrologist ASC",
		"on_pd" => "rc_patients.cache_on_pd ASC",
		"cases" => "rc_patients.cache_cases DESC",
		"status" => "rc_patients.cache_case_status ASC");
	my $query_sort_by = $sort_by_modify{$p{"sort"}};
	if ($query_sort_by eq '') {
		$query_sort_by = $sort_by_modify{"name"};
		$p{"sort"} = "name";
	}
	foreach my $key (keys %sort_by_labels) {
		if ($key ne $p{"sort"}) {
			$sort_by_labels{$key} = qq{<a target="$hbin_target" href="ajax.pl?token=$token&do=$p{'do'}&filter=$p{"filter"}&sort=} . $key . qq{">} . $sort_by_labels{$key} . qq{</a>};
		} else {
			$sort_by_labels{$key} = qq{<span class="b">} . $sort_by_labels{$key} . qq{</span> <img src="$local_settings{"path_htdocs"}/images/ats_d.gif" alt='' align="absmiddle"/>};
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
			<form name="form_page_jumper" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
				<input type="hidden" name="do" value="$p{'do'}"/>
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
				$p{"page_limit_offset_human"} $w{'to'} $p{"page_limit_offset_human_tail"} $w{'of'} $p{"page_total_records"} &nbsp; };
		if ($p{"page"} > 1) {
			my $prev_page = $p{"page"} - 1;
			$pager .= qq{<a href="ajax.pl?token=$token&do=$p{'do'}&page=$prev_page&patient_id=$p{'patient_id'}&filter=$p{"filter"}&sort=$p{"sort"}" target="$hbin_target" class="b">$w{'previous'}</a> &nbsp; };
		} else {
			$pager .= qq{<span class="gt b">$w{'previous'}</span> &nbsp; };
		}
		if ($p{"page"} + 1 <= $p{"pages"}) {
			my $next_page = $p{"page"} + 1;
			$pager .= qq{<a href="ajax.pl?token=$token&do=$p{'do'}&page=$next_page&patient_id=$p{'patient_id'}&filter=$p{"filter"}&sort=$p{"sort"}" target="$hbin_target" class="b">$w{'next'}</a>};
		} else {
			$pager .= qq{<span class="gt b">$w{'next'}</span>};
		}
		$pager .= qq{ &nbsp; $w{'go to page'} <select name="page">$pages</select> <input type="submit" value="$w{'Go'}"/></div>};
	}
	my $reset_button = qq{<a href="ajax.pl?token=$token&do=$p{'do'}" target="$hbin_target" class="b">$w{'reset'}</a>};
	$reset_button = qq{} if $p{"filter"} eq '';
 	$pager .= qq{
 				<div>
 					<div class="float-l p10ro">
 						$button_add_patient
 						$button_add_case
 					</div>
 					<div class="float-l p1to p5ro">$w{'Search'}</div>
 					<div class="float-l p5ro"><div class="itt w120"><input type="text" class="itt" name="filter" value="$p{"filter"}"/></div></div>
 					<div class="float-l"><input type="submit" value="$w{'Search'}"/> &nbsp; $reset_button</div>
 					<div class="clear-l"></div>
 				</div>
 			</form>
 			<div class="clear-r"></div>
 		</div>};


	my $rc = "bg-vlg";
	my $patients;
	my @patients = &querymr(qq{SELECT entry, name_last, name_first, phn, cache_primary_nurse, cache_nephrologist, cache_on_pd, cache_cases, cache_case_status, modified FROM rc_patients $filter ORDER BY $query_sort_by, name_last ASC, name_first ASC, phn ASC LIMIT $p{"page_limit_offset"}, $p{"page_q"}});
	foreach my $p (@patients) {
		my ($entry, $name_last, $name_first, $phn, $cache_primary_nurse, $cache_nephrologist, $cache_on_pd, $cache_cases, $cache_case_status, $modified) = @$p;
		my $comments_patient = &comments_patient($entry);
		if ($cache_cases > 0) {
			$cache_cases = qq{<a href="ajax.pl?token=$token&do=view_cases&amp;patient_id=$entry" target="$hbin_target" onclick="tt('nav','1','7');">$cache_cases $w{'found'}</a>};
			if ($cache_case_status eq '1') {
				$cache_case_status = qq{<span class="b txt-red">$w{'Closed_uc'}</span>};
			} elsif ($cache_case_status eq "0") {
				$cache_case_status = qq{<span class="b txt-gre">$w{'Active_uc'}</span>};
			}
		} else {
			$cache_cases = qq{<span class="gt">($w{'none'})</span>};
			$cache_case_status = qq{<span class="gt">($w{'none'})</span>};
		}
		if ($cache_on_pd eq '') {
			$cache_on_pd = qq{<span class="txt-gre b">$w{'Yes'}</span>};
		} else {
			$cache_on_pd = qq{<span class="txt-red b">$w{'No'}</span>};
		}
		$cache_primary_nurse = qq{<span class="gt">($w{'not tracked'})} if $cache_primary_nurse eq '';
		$cache_nephrologist = qq{<span class="gt">($w{'not tracked'})} if $cache_nephrologist eq '';
		$patients .= qq{
			<tr class="$rc">
				<td class="pfmb_l gt">$entry</td>
				<td class="pfmb_l"><a target="$hbin_target" href="ajax.pl?token=$token&do=edit_patient_form&patient_id=$entry"><strong>$name_last</strong>, $name_first</a> $comments_patient</td>
				<td class="pfmb_l">$phn</td>
				<td class="pfmb_l">$cache_primary_nurse</td>
				<td class="pfmb_l">$cache_nephrologist</td>
				<td class="pfmb_l">$cache_on_pd</td>
				<td class="pfmb_l gt">$cache_cases</td>
				<td class="pfmb_l gt">$cache_case_status</td>
			</tr>};
		if ($rc eq '') {
			$rc = "bg-vlg";
		} else {
			$rc = '';
		}
	}
	if ($patients eq '') {
		$patients = qq{<tr><td class="pfmb_l gt" colspan="7">$w{'No patients found'}.</td></tr>};
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
	my @labs = &querymr(qq{SELECT * FROM rc_Labs ORDER BY status ASC});
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
		my ($case_id, $case_type, $patient_id, $name_first, $name_last) = &query(qq{SELECT rc_cases.entry, rc_cases.case_type, rc_cases.patient, rc_patients.name_first, rc_patients.name_last FROM rc_cases, rc_patients WHERE rc_cases.entry="$case_id" AND rc_cases.patient=rc_patients.entry});
		my $infection_type = &get_infection_type($case_id);
		my $result_print = $w{'none'};
		if ($result_final > 0) {
			$result_print = $w{'Final_uc'};
		} elsif ($result_pre > 0) {
			$result_print = $w{'Preliminary'};
		}
		$labs .= qq{
			<tr class="$rc">
				<td class="pfmb_l"><a target="$hbin_target" href="ajax.pl?token=$token&do=edit_patient_form&patient_id=$patient_id" class="b">$name_last, $name_first</a></td>
				<td class="pfmb_l">$infection_type</td>
				<td class="pfmb_l"><a target="$hbin_target" href="ajax.pl?token=$token&do=edit_lab_form&lab_id=$entry">$status</a></td>
				<td class="pfmb_l"><a target="$hbin_target" href="ajax.pl?token=$token&do=edit_lab_form&lab_id=$entry">$result_print</a></td>
				<td class="pfmb_l">$ordered</td>
            <td class="pfmb_l"><a target="$hbin_target" href="ajax.pl?token=$token&do=edit_lab_form&lab_id=$entry" class="b">$w{'update results'}</a></td>
			</tr>
		};
		if ($rc eq '') {
			$rc = "bg-vlg";
		} else {
			$rc = '';
		}
	}
	if ($labs eq '') {
		$labs = qq{<tr><td class="pfmb_l gt" colspan="6">$w{'No lab tests found'}.</td></tr>};
	}
	return qq{
		$close_button
		<h2><img src="$local_settings{"path_htdocs"}/images/img_culture.png" alt='' /> $w{'Culture results'}</h2>
		<div class="b p10bo">$w{'Please select a lab test record to update. If the appropriate lab test requisition is not listed below'}, <a href="ajax.pl?token=$token&do=add_lab_form" target="$hbin_target">$w{'please create one'}</a>.</div>
		<table class="pfmt w100p">
			<tbody>
				<tr>
					<td class="pfmb_l b bg-dbp">$w{'Patient name'}</td>
					<td class="pfmb_l b bg-dbp">$w{'Infection type'}</td>
					<td class="pfmb_l b bg-dbp">$w{'Status'}</td>
					<td class="pfmb_l b bg-dbp">$w{'Results'}</td>
					<td class="pfmb_l b bg-dbp">$w{'Ordered'}</td>
					<td class="pfmb_l b bg-dbp">&nbsp;</td>
				</tr>
				$labs
			</tbody>
		</table>
	};
}
sub view_labs() {
	my %p = %{$_[0]};
	$p{'do'} = "view_labs";


	# BUILDS NAME FILTER
	# Filters the results based on a string of text provided

	$p{"filter"} = &fast(qq{SELECT value FROM rc_state WHERE uid="$sid[2]" AND param="tab_filter" LIMIT 1});
	$p{"page"} = &fast(qq{SELECT value FROM rc_state WHERE uid="$sid[2]" AND param="tab_page" LIMIT 1});
	$p{"sort"} = &fast(qq{SELECT value FROM rc_state WHERE uid="$sid[2]" AND param="tab_sort" LIMIT 1});

	my ($filter, $notice);
	if ($p{"filter"}) {
		$filter .= qq{AND (};
		my @split = split(/ /,$p{"filter"});
		foreach my $word (@split) {
			$filter .= qq{rc_patients.name_first LIKE "\%$word\%" OR rc_patients.name_last LIKE "\%$word\%" OR rc_labs.pathogen_1 LIKE "\%$word\%" OR rc_labs.pathogen_2 LIKE "\%$word\%" OR rc_labs.pathogen_3 LIKE "\%$word\%" OR rc_labs.pathogen_4 LIKE "\%$word\%" OR };
		}
		$filter =~ s/ OR $/\) /g;
	}



	# COUNTS HOW MANY RECORDS EXIST

	$p{"page_total_records"} = &fast(qq{SELECT COUNT(*) FROM rc_labs, rc_cases, rc_patients WHERE rc_cases.entry=rc_labs.case_id AND rc_patients.entry=rc_cases.patient $filter});



	# IF THE RESULTS ARE BEING FILTERED, DISPLAY ALL IN ONE PAGE
	# OTHERWISE, PAGINATE AT 20 RECORDS PER PAGE

	if ($p{'patient_id'} ne '' or $p{"filter"} ne '') {
		$p{"page"} = '1';
		$p{"page_q"} = 10000;
	} else {
		$p{"page"} = '1' if $p{"page"} eq '';
		$p{"page_q"} = 20;
	}



	# SORTING MECHANISM
	# The chunk of code below builds the clickable table headers.
	# Place this code high up as the sort_by_modify is required to
	# build the MySQL query.

	my %sort_by_labels = (
		"id" => "ID",
		"patient_name" => $w{'Patient name'},
		"case_type" => $w{'Case type'},
		"results" => $w{'Results'},
		"last_updated" => $w{'Last updated'});
	my %sort_by_modify = (
		"id" => "rc_labs.entry ASC",
		"patient_name" => "rc_patients.name_last ASC",
		"case_type" => "rc_cases.is_peritonitis DESC, rc_cases.is_exit_site DESC, rc_cases.is_tunnel DESC",
		"results" => "rc_labs.pathogen_1 ASC, rc_labs.pathogen_2 ASC, rc_labs.pathogen_3 ASC, rc_labs.pathogen_4 ASC",
		"last_updated" => "rc_labs.modified DESC");
	my $query_sort_by = $sort_by_modify{$p{"sort"}};
	if ($query_sort_by eq '') {
		$query_sort_by = $sort_by_modify{"last_updated"};
		$p{"sort"} = "last_updated";
	}
	foreach my $key (keys %sort_by_labels) {
		if ($key ne $p{"sort"}) {
			$sort_by_labels{$key} = qq{<a target="$hbin_target" href="ajax.pl?token=$token&do=$p{'do'}&patient_id=$p{'patient_id'}&filter=$p{"filter"}&sort=} . $key . qq{">} . $sort_by_labels{$key} . qq{</a>};
		} else {
			$sort_by_labels{$key} = qq{<span class="b">} . $sort_by_labels{$key} . qq{</span> <img src="$local_settings{"path_htdocs"}/images/ats_d.gif" alt='' align="absmiddle"/>};
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
			<form name="form_page_jumper" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
				<input type="hidden" name="do" value="$p{'do'}"/>
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
            $p{"page_limit_offset_human"} $w{'to'} $p{"page_limit_offset_human_tail"} $w{'of'} $p{"page_total_records"} &nbsp; };
		if ($p{"page"} > 1) {
			my $prev_page = $p{"page"} - 1;
			$pager .= qq{<a href="ajax.pl?token=$token&do=$p{'do'}&page=$prev_page&patient_id=$p{'patient_id'}&filter=$p{"filter"}&sort=$p{"sort"}" target="$hbin_target" class="b">$w{'previous'}</a> &nbsp; };
		} else {
			$pager .= qq{<span class="gt b">$w{'previous'}</span> &nbsp; };
		}
		if ($p{"page"} + 1 <= $p{"pages"}) {
			my $next_page = $p{"page"} + 1;
			$pager .= qq{<a href="ajax.pl?token=$token&do=$p{'do'}&page=$next_page&patient_id=$p{'patient_id'}&filter=$p{"filter"}&sort=$p{"sort"}" target="$hbin_target" class="b">$w{'next'}</a>};
		} else {
			$pager .= qq{<span class="gt b">$w{'next'}</span>};
		}
		$pager .= qq{ &nbsp; $w{'go to page'} <select name="page">$pages</select> <input type="submit" value="$w{'Go'}"/></div>};
	}
	my $reset_button = qq{<a href="ajax.pl?token=$token&do=$p{'do'}" target="$hbin_target" class="b">$w{'reset'}</a>};
	$reset_button = qq{} if $p{"filter"} eq '';
 	$pager .= qq{
 				<div>
 					<div class="float-l p10ro">
 						$button_add_patient
 						$button_add_case
 					</div>
 					<div class="float-l p1to p5ro">$w{'Search'}</div>
 					<div class="float-l p5ro"><div class="itt w120"><input type="text" class="itt" name="filter" value="$p{"filter"}"/></div></div>
 					<div class="float-l"><input type="submit" value="$w{'Search'}"/> &nbsp; $reset_button</div>
 					<div class="clear-l"></div>
 				</div>
 			</form>
 			<div class="clear-r"></div>
 		</div>};


	my $labs_query = qq{SELECT rc_labs.entry, rc_labs.case_id, rc_labs.pathogen_1, rc_labs.pathogen_2, rc_labs.pathogen_3, rc_labs.pathogen_4, rc_labs.ordered, rc_labs.modified, rc_cases.entry, rc_cases.case_type, rc_cases.patient, rc_patients.name_first, rc_patients.name_last FROM rc_labs, rc_cases, rc_patients WHERE rc_cases.entry=rc_labs.case_id AND rc_patients.entry=rc_cases.patient $filter ORDER BY $query_sort_by, rc_patients.name_last ASC, rc_labs.modified DESC LIMIT $p{"page_limit_offset"}, $p{"page_q"}};
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
			if ($pathogen ne '') {
				my $translated_pathogen = $w{$pathogen};
				if ($translated_pathogen ne '') {
					$pathogens .= qq{$translated_pathogen; };
				} else {
					$pathogens .= qq{$pathogen; };
				}
			}
		}
		$pathogens =~ s/; $//g;
		my $comments_lab = &comments_lab($entry);
		my $comments_patient = &comments_patient($patient_id);
		$labs .= qq{
			<tr class="$rc">
				<td class="pfmb_l gt">$entry</td>
				<td class="pfmb_l"><a target="$hbin_target" href="ajax.pl?token=$token&do=edit_patient_form&patient_id=$patient_id"><strong>$name_last</strong>, $name_first</a> $comments_patient</td>
				<td class="pfmb_l">$infection_type</td>
				<td class="pfmb_l"><div class="ofh-18"><a target="$hbin_target" href="ajax.pl?token=$token&do=edit_lab_form&lab_id=$entry">$pathogens</a> $comments_lab</div></td>
				<td class="pfmb_l">$modified</td>
			</tr>
		};
		if ($rc eq '') {
			$rc = "bg-vlg";
		} else {
			$rc = '';
		}
	}
	if ($labs eq '') {
		$labs = qq{<tr><td class="pfmb_l gt" colspan="4">$w{'No culture results found'}.</td></tr>};
	}
	return qq{
		$pager
		<table class="pfmt w100p">
			<tbody>
				<tr>
					<td class="pfmb_l b bg-dbp w6p">$sort_by_labels{"id"}</td>
					<td class="pfmb_l b bg-dbp w20p">$sort_by_labels{"patient_name"}</td>
					<td class="pfmb_l b bg-dbp w15p">$sort_by_labels{"case_type"}</td>
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
	@sid = &get_sid();
	my $check_db_status = &fast(qq{SELECT type FROM rc_users WHERE type="Administrator" LIMIT 1});
	my $msgs;
	if ($p{'message_error'} ne '') {
		$msgs .= qq{<div class="emp">$p{'message_error'}</div>};
	}
	if (!$check_db_status) {
		
		my $param_admin_lang_options = &build_select(
			$lang,
			"English",
			"Français",
			"Español");
		
		return qq{
		<div class="w800 p30to align-middle">
			<div class="bg-cloud">
				<div class="align-middle w360 p100to">
					<img src="$local_settings{"path_htdocs"}/images/img_logo_rc_new.png" alt="RenalConnect" alt="$w{'RenalConnect: cloud-based management of dialysis care'}"/>
					$msgs
            		<div class="p10bo">$w{'w_no_administrator'}</div>
					<form name="form_create_administrator" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
					<input type="hidden" name="token" value="$token"/>
						<table>
							<tbody>
								<tr>
            						<td class="tl gt p10ro">$w{'First name'}</td>
									<td class="tl"><div class="itt w240"><input type="text" class="itt" name="param_admin_name_first" value=''/></div></td>
								</tr><tr>
            						<td class="tl gt p10ro">$w{'Last name'}</td>
									<td class="tl"><div class="itt w240"><input type="text" class="itt" name="param_admin_name_last" value=''/></div></td>
								</tr><tr>
									<td class="tl gt p10ro">$w{'Email_uc'}</td>
									<td class="tl"><div class="itt w240"><input type="text" class="itt" name="param_admin_email" value=''/></div></td>
								</tr><tr>
									<td class="tl gt p10ro">$w{'Password'}</td>
									<td class="tl"><div class="itt w240"><input type="password" class="itt" name="param_admin_password"/></div></td>
								</tr><tr>
									<td class="tl gt p10ro">$w{'Repeat password'}</td>
									<td class="tl"><div class="itt w240"><input type="password" class="itt" name="param_admin_password_repeat"/></div></td>
								</tr><tr>
            						<td class="tl gt p10ro">$w{'Database encryption key'}</td>
									<td class="tl p10bo"><div class="itt w240"><input type="text" class="itt" name="param_admin_key"/></div></td>
								</tr><tr>
									<td class="tl gt p10ro">&nbsp;<input type="hidden" name="do" value="create_administrator"/></td>
									<td class="tl p10to p10bo"><input type="submit" value="$w{'Submit'}"/></td>
								</tr>
							</tbody>
						</table>
						<div><a href="support.pl" class="b">$w{'Get technical support'}</a></div>
					</form>
				</div>
			</div>
		</div>};
	} elsif (&auth()) {
		my $tab_cases = "tabOff";
		my $tab_lists = "tabOff";
		my $user_type = &fast(qq{SELECT role FROM rc_users WHERE entry="$sid[2]" LIMIT 1});
		my $view_page;
		my %alerts = (
			"alerts" => "show",
			"alerts_hidden" => "hide");
        &rc::io::input(qq{INSERT INTO rc_state (uid, param, value) VALUES ("$sid[2]", "tab", "view_active_lists") ON DUPLICATE KEY UPDATE value="view_active_lists"});
        $view_page = &view_active_lists(\%p);
        $tab_lists = "tabAct";
        $alerts{"alerts"} = "show";
        $alerts{"alerts_hidden"} = "hide";
		my $view_alerts = &get_alerts(\%p);
		my $ubox = &get_user_box(\%p);
		my $enable_legacy = 'float-l';

		return qq{
			<!--[if lt IE 7 ]>
				<div class="p10 bg-yel"><img src="$local_settings{"path_htdocs"}/images/img_ni_warn.gif" alt='' align="absmiddle"/>&nbsp;<span class="b">$w{'You are using an outdated browser that is ten years old.'}</span> $w{'For best results, please upgrade to the latest release of'} <a href="http://www.google.com/chrome" target="_blank">Google Chrome</a>, <a href="http://www.firefox.com/" target="_blank">Mozilla Firefox</a>, $w{'or'} <a href="http://www.apple.com/safari" target="_blank">Apple Safari</a>.</div>
			<![endif]-->
			<div class="hdrbg"></div>
			$ubox
			<div class="p10lo p10ro p10to p10bo wbg"><img src="$local_settings{"path_htdocs"}/images/img_logo_rc_new_small.png" alt="RenalConnect"/></div>
			<div class="p10lo p10ro wbg mh500">
				<div>
					<table class="w100p">
						<tbody>
							<tr>
								<td class="p10ro">
									<div class="bg-hx">
										<div class="float-l p20ro">
											<a class="tab tabOff b" id="nav2" onclick="tt('nav','2','7'); apc('view_patients');" target="$hbin_target" href="ajax.pl?token=$token&do=view_patients">$w{'patients'}</a>
										</div>
										<div class="float-l p20ro">
											<span class="gt">$w{'new starts'}</span> <span class="lgt">&raquo;</span>
											<a class="tab $tab_lists b" id="nav5" onclick="tt('nav','5','7'); apc('view_active_lists');" target="$hbin_target" href="ajax.pl?token=$token&do=view_active_lists">$w{'active starts'}</a>
											<a class="tab tabOff b" id="nav6" onclick="tt('nav','6','7'); apc('view_lists');" target="$hbin_target" href="ajax.pl?token=$token&do=view_lists">$w{'all starts'}</a>
											<a class="tab tabOff b" id="nav7" onclick="tt('nav','7','7'); apc('view_list_reports');" target="$hbin_target" href="ajax.pl?token=$token&do=view_list_reports">$w{'reports'}</a>
										</div>
										<div class="$enable_legacy">										
											<span class="gt p20lo">$w{'peritonitis'}</span> <span class="lgt">&raquo;</span>
											<a class="tab $tab_cases b" id="nav0" onclick="tt('nav','0','7'); apc('view_active_cases');" target="$hbin_target" href="ajax.pl?token=$token&do=view_active_cases">$w{'active cases'}</a>
											<a class="tab tabOff b" id="nav1" onclick="tt('nav','1','7'); apc('view_cases');" target="$hbin_target" href="ajax.pl?token=$token&do=view_cases">$w{'all cases'}</a>
            								<a class="tab tabOff b" id="nav3" onclick="tt('nav','3','7'); apc('view_labs');" target="$hbin_target" href="ajax.pl?token=$token&do=view_labs">$w{'cultures'}</a>
											<a class="tab tabOff b" id="nav4" onclick="tt('nav','4','7'); apc('view_reports');" target="$hbin_target" href="ajax.pl?token=$token&do=view_reports">$w{'reports'}</a>
										</div>
										<div class="clear-l"></div>
									</div>
									<div id="div_page" class="wbg">$view_page</div>
								</td><td class="w240">
									<div class="bg-hx">
										<a class="tab tabAct b">$w{'alerts'}</a> &nbsp; <a class="nou" href="ajax.pl?token=$token&do=view_dismissed_alerts" target="$hbin_target">$w{'view dismissed alerts'}</a></div>
									</div>
									<div class="p5to">
										<div id="alerts" class="$alerts{'alerts'}">
											$view_alerts
										</div>
										<div id="alerts_hidden" class="$alerts{'alerts_hidden'}">
            								<div class="fph">$w{'There are no applicable alerts for this view'}. <a href="/images/blank.gif" target="hbin" onclick="show_alerts();">$w{'Show all alerts'}</a></div>
										</div>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<div class="m20to br-t p10to p10bo p20lo p20ro tl gt bg-vlg">
				<div class="float-r">
					<a href="index.pl?lang=English">English</a> &bull; 
					<a href="index.pl?lang=Français">Français</a> &bull; 
					<a href="index.pl?lang=Español">Español</a>
				</div>
            	<span class="b">$w{'Remember patient confidentiality'}</span>
            </div>};
	} else {
		return qq{
		<div class="w800 p30to align-middle">
			<div class="bg-cloud">
				<div class="lang_bar">
					<a href="index.pl?lang=English">English</a> &bull; 
					<a href="index.pl?lang=Français">Français</a> &bull; 
					<a href="index.pl?lang=Español">Español</a>
				</div>
				<div class="align-middle w360 p100to">
					<div class="p20bo"><img src="$local_settings{"path_htdocs"}/images/img_logo_rc_new.png" 
					alt="RenalConnect"/></div>
					<form name="form_login" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
						<input type="hidden" name="token" value="$token"/>
						$msgs
						<table>
							<tbody>
								<tr>
									<td class="tr gt w100">$w{'Email_uc'}</td>
									<td class="tl p10lo p10bo">
										<div class="itt w240"><input type="text" class="itt" name="param_login_email" value="$p{'param_login_email'}"/></div>
									</td>
								</tr><tr>
									<td class="tr gt">$w{'Password'}</td>
									<td class="tl p10lo p10bo">
										<div class="itt"><input type="password" class="itt" name="param_login_password"/></div>
            							<div class="p10to"><a href="password.pl">$w{'I forgot my password'}</a></div>
            						</td>
								</tr><tr>
									<td class="tl gt">&nbsp;<input type="hidden" name="do" value="login"></td>
									<td class="tl p10lo p20bo">
										<input type="submit" value="$w{'Sign in'}"/>
										<div class="p10to"><a href="support.pl" class="b">$w{'Get technical support'}</a></div>
									</td>
								</tr>
							</tbody>
						</table>
					</form>
            		<div class="gt sml">$w{'w_about_renalconnect'}</div>
					<div><img src="$local_settings{"path_htdocs"}/images/blank.gif" alt='' onload="pop_up_hide(); clear_date_picker();"/></div>
				</div>
			</div>
		</div>};
	}
}
sub get_user_box() {
	my %p = %{$_[0]};
	@sid = &get_sid();
	if ($sid[2] ne '') {
		my ($type,$fnam,$lnam,$role) = &query(qq{SELECT type, name_first, name_last, role FROM rc_users WHERE entry="$sid[2]"});
		my $name = $lnam . ", " . $fnam;
		my $tlbl = "(HCP)";
		if ($type eq "Administrator") {
			$type = qq{ &nbsp; <a href="ajax.pl?token=$token&do=edit_manage_users_form" target="$hbin_target">$w{'manage users'}</a>};
			$tlbl = "&ndash; $w{'administrator'}";
		} else {
			$type = '';
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
            <a href="ajax.pl?token=$token&do=logout" target="$hbin_target" class="b">$w{'sign out'}</a>
						</div>
            <div class="tr"><a href="ajax.pl?token=$token&do=edit_account_settings_form" target="$hbin_target">$w{'account settings'}</a>$type</div>
					</div>
				</div>};
	} else {
		return "$w{'not signed in'}";
	}
}
sub get_infection_type() {
	my $entry = shift;
	my ($is_peritonitis, $is_exit_site, $is_tunnel) = &query(qq{SELECT is_peritonitis, is_exit_site, is_tunnel FROM rc_cases WHERE entry="$entry"});
	my $infection_type;
	$infection_type .= qq{$w{'peritonitis'}, } if $is_peritonitis == 1;
	$infection_type .= qq{$w{'exit site'}, } if $is_exit_site == 1;
	$infection_type .= qq{$w{'tunnel'}} if $is_tunnel == 1;
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
		my ($date_start, $date_end, $date_stopped) = &query(qq{SELECT date_start, date_end, date_stopped FROM rc_antibiotics WHERE entry="$abx_id"});
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
sub check_if_list_complete_on_discharge() {
	my %p = %{$_[0]};
	my @mandatory_fields = (
		"home_centre",
		"tn_initial_assessment_date",
		"prior_status",
		"tn_chosen_modality",
		"candidate_for_home",
		"interested_in_transplant",
		"acp_introduced",
		"tn_discharge_date");
	my $error = 0;
	if ($p{"form_list_completed"} eq "Yes") {
		foreach my $field (@mandatory_fields) {
			if ($p{"form_list_$field"} eq '') {
				$error = 1;
			}
		}
		if ($p{"form_list_tn_chosen_modality"} eq "Other") {
			if ($p{"form_list_tn_chosen_modality_other"} eq '') {
				$error = 2;
			}
		}
		if ($p{"form_list_interested_in_transplant"} eq "Yes") {
			if (($p{"form_list_transplant_referral_date"} eq '') or 
				($p{"form_list_transplant_donor_identified"} eq '')) {
				$error = 3;
			}
		}
		if ($error > 0) {
			$p{'message_error'} = 2;
			$p{"form_list_completed"} = "No";
		}
	}
	return %p;
}
sub view_list() {
	my %p = %{$_[0]};
	my (
		$msgs,
		$triggers, 
		$name_first, 
		$name_last, 
		$phn, 
		$dialysis_center, 
		$nephrologist,
		$title, 
		$patient_info, 
		$delete_button);
	$msgs .= qq{<div class="emp">$p{'message_error'}</div>} if $p{'message_error'} ne '';
	$msgs .= qq{<div class="suc">$p{'message_success'}</div>} if $p{'message_success'} ne '';
	my $ok_list = &fast(qq{SELECT entry FROM rc_lists WHERE entry="$p{"list_id"}"});
	my $ok_patient = &fast(qq{SELECT entry FROM rc_patients WHERE entry="$p{'patient_id'}"});
	my $render_page = 0;
	if ($ok_list eq '') {
		if ($ok_patient eq '') {
			return qq{
				$close_button
				<h2><img src="$local_settings{"path_htdocs"}/images/icon-update-small-blue.png" alt=''/> $w{'New start'}</h2>
				$msgs
				<div class="b p10bo">$w{"Please enter a patient's name or PHN or"} <a href="ajax.pl?token=$token&do=add_patient_form" target="$hbin_target">$w{'Add a new patient'}</a>.</div>
				<div class=''>
					<div class="float-r w730">
						<div class="itt"><input type="text" class="itt" id="ncpi" name="ncpi" value='' onkeyup="refresh_patient_selector_ajax(this.value);"/></div>
						<div class="hide" id="form_patient_selector_token">$token</div>
						<div class="hide" id="form_patient_selector_mode">list</div>
						<div class="hide" id="form_patient_selector_prev"></div>
					</div>
					<img src="$local_settings{"path_htdocs"}/images/img_ni_search.gif" alt="$w{'Search'}"/>
					<div class="clear-r"></div>
				</div>
				<div id="form_patient_selector" class="max300"></div>
				<div class="hide" id="form_patient_selector_searching"><div class="loading">$w{'Searching...'}</div></div>
				<div class="clear-l"></div>
				<img src="/images/blank.gif" width='1' height='1' alt='' onload="document.getElementById('ncpi').focus()"/>};
		} elsif ($ok_patient) {
			$render_page = 1;
			$triggers = qq{<input type="hidden" name="patient_id" value="$ok_patient"/>};
			$title = $w{'New start'};
			$p{"form_list_created"} = &fast(qq{SELECT CURDATE()});
			$p{"form_list_modified"} = $w{'Right now'};
			$title = $w{'New start'};
		}
	} elsif ($ok_list ne '') {
		$render_page = 1;
		$triggers = qq{<input type="hidden" name="list_id" value="$ok_list"/>};
		$title = $w{'Manage start_uc'};
		$delete_button = qq{<a href="ajax.pl?token=$token&do=delete_list&list_id=$ok_list" target="$hbin_target">$w{'Delete case'}</a>};
		my %h = &queryh(qq{SELECT * FROM rc_lists WHERE entry="$ok_list"});
		foreach my $key (keys %h) {
			$p{"form_list_$key"} = $h{"$key"};
		}
		$p{'patient_id'} = $p{"form_list_patient"} if $p{'form_list_patient'} ne '';
		$ok_patient = $p{"form_list_patient"};
		$p{"form_list_modified"} = &nice_time($p{"form_list_modified"});
	}
	if ($ok_patient ne '') {	
		($name_first, $name_last, $phn, $dialysis_center, $nephrologist) = &query(qq{SELECT 
				name_first, 
				name_last, 
				phn, 
				dialysis_center, 
				cache_nephrologist 
			FROM 
				rc_patients 
			WHERE entry="$ok_patient"});
		if ($nephrologist) {
			$nephrologist = "Dr. " . $nephrologist;
		}
		$patient_info = qq{
			<div class="p20bo">
				<div class="float-l w49p"><span class="gt">$w{'Name'}</span> <a href="ajax.pl?token=$token&do=edit_patient_form&patient_id=$ok_patient" target="$hbin_target" class="b">$name_last, $name_first</a></div>
				<div class="float-l w49p"><span class="gt">$w{'PHN'}</span> $phn</div>
				<div class="float-l w49p"><span class="gt">$w{'Nephrologist'}</span> $nephrologist</div>
				<div class="clear-l"></div>
			</div>};
	}
	my $active_update_info;
	if ($p{"form_list_modified"} ne '') {
		if ($p{"form_list_completed"} eq "Yes") {
			$p{"form_list_closed_print"} = qq{<span class="ac-red">$w{'Closed list'}</span>};
		} else {
			$p{"form_list_closed_print"} = qq{<span class="ac-green">$w{'Active list'}</span>};
		}
		$active_update_info = qq{
			<div class="float-l p15to p5ro">$p{"form_list_closed_print"}</div>
			<div class="float-l p15to"><span class="ac-lg">$w{'updated'} $p{"form_list_modified"}</span></div>
		};
	}
	if ($p{"form_list_status_at_initial_meeting"} eq '') {
		$p{"form_list_status_at_initial_meeting"} = "Hemodialysis";
	}
	if ($p{"form_list_recovered_from_dialysis_dependance"} eq '') {
		$p{"form_list_recovered_from_dialysis_dependance"} = "No";
	}

	my @boolean_options = (
        "Yes;;$w{'Yes'}",
        "No;;$w{'No'}");
    my @transplant_question = (
    	"Yes, but not referred at this time;;$w{'Yes, but not referred at this time'}",
        "Yes;;$w{'Yes'}",
        "No;;$w{'No'}");
	my @dialysis_modalities = (
		"Peritoneal dialysis;;$w{'Peritoneal dialysis'}",
		"Home hemodialysis;;$w{'Home hemodialysis'}",
		"Community hemodialysis;;$w{'Community hemodialysis'}",
		"In-centre hemodialysis;;$w{'In-centre hemodialysis'}",
		"Nocturnal in-centre hemodialysis;;$w{'Nocturnal in-centre hemodialysis'}",
		"Conservative (no dialysis);;$w{'Conservative (no dialysis)'}",
		"No choice made;;$w{'No choice made'}",
		"Other;;$w{'Other'}");
	my @treatment_modalities_six_months = (
        "Peritoneal dialysis;;$w{'Peritoneal dialysis'}",
        "Home hemodialysis;;$w{'Home hemodialysis'}",
        "Community hemodialysis;;$w{'Community hemodialysis'}",
        "In-centre hemodialysis;;$w{'In-centre hemodialysis'}",
        "Nocturnal in-centre hemodialysis;;$w{'Nocturnal in-centre hemodialysis'}",
        "Conservative (no dialysis);;$w{'Conservative (no dialysis)'}",
        "Transplant;;$w{'Transplant'}",
        "No choice made;;$w{'No choice made'}",
		"Not yet known;;$w{'Not yet known'}",
		"Deceased;;$w{'Deceased'}",
		"Other;;$w{'Other'}");
	my @prior_status_options = (
        "Kidney Care Centre;;$w{'Kidney Care Centre'}",
    	"Peritoneal dialysis;;$w{'Peritoneal dialysis'}",
    	"Transplant;;$w{'Transplant'}",
		"Physician office;;$w{'Physician office'}",
		"Unknown acute;;$w{'Unknown acute'}",
		"Unknown chronic;;$w{'Unknown chronic'}");
	my @status_at_initial_meeting_options = (
        "Pre-dialysis;;$w{'Pre-dialysis'}",
    	"Hemodialysis;;$w{'Hemodialysis'}",
    	"Peritoneal dialysis;;$w{'Peritoneal dialysis'}",
		"Recovered;;$w{'Recovered'}");

	my $form_list_home_centre_options = &build_select(
		$p{"form_list_home_centre"},
		@local_settings_hospitals_for_new_starts);
	my $form_list_status_at_initial_meeting_options = &build_select(
		$p{"form_list_status_at_initial_meeting"},
		@status_at_initial_meeting_options);
	my $form_list_prior_status_options = &build_select(
		$p{"form_list_prior_status"},
		@prior_status_options);
	my $form_list_vascular_access_at_hd_start_options = &build_select(
		$p{"form_list_vascular_access_at_hd_start"},
		"AV fistula (AVF);;$w{'AV fistula (AVF)'}",
		"AV graft (AVG);;$w{'AV graft (AVG)'}",
		"Central venous catheter (CVC);;$w{'Central venous catheter (CVC)'}",
		"CVC with AVF or AVG;;$w{'CVC with AVF or AVG'}");
	my $form_list_candidate_for_home_options = &build_select(
		$p{"form_list_candidate_for_home"},
		@boolean_options);
	my $form_list_acp_introduced_options = &build_select(
		$p{"form_list_acp_introduced"},
		@boolean_options);
	my $form_list_flag_for_follow_up_options = &build_select(
		$p{"form_list_flag_for_follow_up"},
		"1 month;;1 $w{'month'}",
		"2 months;;2 $w{'months'}",
		"3 months;;3 $w{'months'}",
		"4 months;;4 $w{'months'}",
		"5 months;;5 $w{'months'}",
		"6 months;;6 $w{'months'}",
		"9 months;;9 $w{'months'}",
		"12 months;;12 $w{'months'}");
	my $form_list_flag_for_follow_up_date_1 = &fast(qq{SELECT DATE_ADD(CURDATE(), INTERVAL 1 MONTH)});
	my $form_list_flag_for_follow_up_date_2 = &fast(qq{SELECT DATE_ADD(CURDATE(), INTERVAL 2 MONTH)});
	my $form_list_flag_for_follow_up_date_3 = &fast(qq{SELECT DATE_ADD(CURDATE(), INTERVAL 3 MONTH)});
	my $form_list_flag_for_follow_up_date_4 = &fast(qq{SELECT DATE_ADD(CURDATE(), INTERVAL 4 MONTH)});
	my $form_list_flag_for_follow_up_date_5 = &fast(qq{SELECT DATE_ADD(CURDATE(), INTERVAL 5 MONTH)});
	my $form_list_flag_for_follow_up_date_6 = &fast(qq{SELECT DATE_ADD(CURDATE(), INTERVAL 6 MONTH)});
	my $form_list_flag_for_follow_up_date_9 = &fast(qq{SELECT DATE_ADD(CURDATE(), INTERVAL 9 MONTH)});
	my $form_list_flag_for_follow_up_date_12 = &fast(qq{SELECT DATE_ADD(CURDATE(), INTERVAL 12 MONTH)});
	my $form_list_preemptive_transplant_referral_options = &build_select(
		$p{"form_list_preemptive_transplant_referral"},
		@boolean_options);
	my $form_list_modality_at_six_months_options = &build_select(
		$p{"form_list_modality_at_six_months"},
		@treatment_modalities_six_months);
	my $form_list_modality_at_twelve_months_options = &build_select(
		$p{"form_list_modality_at_twelve_months"},
		@treatment_modalities_six_months);
	my $form_list_recovered_from_dialysis_dependance_options = &build_select(
		$p{"form_list_recovered_from_dialysis_dependance"},
		@boolean_options);
	my $form_list_completed_options = &build_select(
		$p{"form_list_completed"},
		@boolean_options);
	my $form_list_tn_chosen_modality_options = &build_select(
		$p{"form_list_tn_chosen_modality"},
		@dialysis_modalities);
	my $form_list_kcc_preferred_modality_options = &build_select(
		$p{"form_list_kcc_preferred_modality"},
		@treatment_modalities_six_months);
	my $form_list_incentre_reason_options = &build_select(
		$p{"form_list_incentre_reason"},
		"Convenience;;$w{'Convenience'}",
		"Failed home dialysis in the past;;$w{'Failed home dialysis in the past'}",
		"Failed peritoneal dialysis in the past;;$w{'Failed peritoneal dialysis in the past'}",
		"Inadequate access to assistance;;$w{'Inadequate access to assistance'}",
		"Inadequate social support;;$w{'Inadequate social support'}",
		"Insufficient dexterity;;$w{'Insufficient dexterity'}",
		"Medical contraindication;;$w{'Medical contraindication'}",
		"Patient believes home dialysis is inferior care;;$w{'Patient believes home dialysis is inferior care'}",
		"Transplant imminent;;$w{'Transplant imminent'}",
		"Other;;$w{'Other'}");
	my $form_list_transplant_donor_identified_options = &build_select(
		$p{"form_list_transplant_donor_identified"},
		@boolean_options);
	my $form_list_interested_in_transplant_options = &build_select(
		$p{"form_list_interested_in_transplant"},
		@transplant_question);
	my $form_list_tn_discharge_date_default = &fast(qq{SELECT CURDATE()});
	if ($p{"form_list_tn_initial_assessment_date"} eq '') {
		$p{"form_list_tn_initial_assessment_date"} = $form_list_tn_discharge_date_default;
	}
	my $first_dialysis = $p{"form_list_first_hd_date"};
	my $enable_modality_at_6_months = qq{<div id="form_list_modality_at_six_months_enable" class="hide">0</div>};
	my $enable_modality_at_12_months = qq{<div id="form_list_modality_at_twelve_months_enable" class="hide">0</div>};
	if ($first_dialysis ne '') {
		my $six = &fast(qq{SELECT DATEDIFF(CURDATE(), DATE_ADD('$first_dialysis', INTERVAL 6 MONTH));});
		my $twelve = &fast(qq{SELECT DATEDIFF(CURDATE(), DATE_ADD('$first_dialysis', INTERVAL 12 MONTH));});
		if ($six > -1) {
			$six = '1';
		}
		if ($twelve > -1) {
			$twelve = '1';
		}
		$enable_modality_at_6_months = qq{<div id="form_list_modality_at_six_months_enable" class="hide">$six</div>};
		$enable_modality_at_12_months = qq{<div id="form_list_modality_at_twelve_months_enable" class="hide">$twelve</div>};
	}
	if ($render_page == 1) {
		return qq{
			$close_button
			<div class="float-l p20ro">
				<h2><img src="$local_settings{"path_htdocs"}/images/icon-update-small-blue.png" alt=''/> $title</h2>
			</div>
			$active_update_info
			<div class="clear-l"></div>
			$msgs
			<form name="form_list" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
				<input type="hidden" name="do" value="save_list"/>
				<input type="hidden" name="token" value="$token"/>
				$triggers
				<div class="float-l w50p">
					<div class="p10ro">
						<div>
							<div class="p10bo b">$w{'Patient information'}</div>
							$patient_info
							<div class="p10bo b">$w{'Checklist'}</div>
							<div class="p10bo clear-l">
								<div class="float-l gt w49p">$w{'Home centre'} $required_io</div>
								<select name="form_list_home_centre" id="form_list_home_centre" class="w49p">
									$form_list_home_centre_options
								</select>
							</div>
							<div class="p10bo clear-l">
								<div class="float-l gt w49p">$w{'Date of initial TN assessment'} $required_io</div>
								<div class="itt w49p"><input type="text" class="itt" name="form_list_tn_initial_assessment_date" value="$p{"form_list_tn_initial_assessment_date"}" onclick="displayDatePicker('form_list_tn_initial_assessment_date');"/></div>
							</div>
							<div class="p10bo clear-l">
								<div class="float-l gt w49p">$w{'Status at initial meeting'}</div>
								<select class="w49p" name="form_list_status_at_initial_meeting" id="form_list_status_at_initial_meeting" onchange="manage_list();">
									$form_list_status_at_initial_meeting_options
								</select>
							</div>
							<div class="p10bo clear-l">
								<div class="float-l gt w49p">$w{'Prior status'} $required_io</div>
								<select class="w49p" name="form_list_prior_status" id="form_list_prior_status" onchange="manage_list();">
									$form_list_prior_status_options
								</select>
							</div>
							<div class="p10bo clear-l">
								<div class="float-l gt w49p">$w{'Date of first hemodialysis (HD)'}</div>
								<div class="itt w49p"><input type="text" class="itt" name="form_list_first_hd_date" value="$p{"form_list_first_hd_date"}" onclick="displayDatePicker('form_list_first_hd_date');"/></div>
							</div>
							<div class="p10bo clear-l">
								<div class="float-l gt w49p">$w{'Vascular access at HD start'}</div>
								<select name="form_list_vascular_access_at_hd_start" id="form_list_vascular_access_at_hd_start" class="w49p" onchange="manage_list();">
									$form_list_vascular_access_at_hd_start_options
								</select>
							</div>
							<div class="p10bo clear-l">
								<div class="float-l gt w49p">$w{'Date of AV access creation'}</div>
								<div class="itt w49p"><input type="text" class="itt" name="form_list_tn_avf_creation_date" value="$p{"form_list_tn_avf_creation_date"}" onclick="displayDatePicker('form_list_tn_avf_creation_date');"/></div>
							</div>
							<div class="p10bo clear-l">
								<div class="float-l gt w49p">$w{'Date of first AV access use'}</div>
								<div class="itt w49p"><input type="text" class="itt" name="form_list_tn_avf_use_date" value="$p{"form_list_tn_avf_use_date"}" onclick="displayDatePicker('form_list_tn_avf_use_date');"/></div>
							</div>
							<div class="p10bo clear-l">
								<div class="float-l gt w49p">$w{'Preferred dialysis modality'}<br/>$w{'after TN intervention'} $required_io</div>
								<select name="form_list_tn_chosen_modality" id="form_list_tn_chosen_modality" class="w49p" onchange="manage_list();">
									$form_list_tn_chosen_modality_options
								</select>
								<div class="clear-l"></div>
							</div>
							<div id="form_list_tn_chosen_modality_other_box">
								<div class="p10bo clear-l">
									<div class="float-l gt w49p">$w{'Specify &quot;other&quot; modality'} $required_io</div>
									<div class="itt w49p"><input type="text" class="itt" name="form_list_tn_chosen_modality_other" value="$p{"form_list_tn_chosen_modality_other"}"/></div>
								</div>
							</div>
							<div class="p10bo clear-l">
								<div class="float-l gt w49p">$w{'Candidate for home dialysis'} $required_io</div>
								<select name="form_list_candidate_for_home">
									$form_list_candidate_for_home_options
								</select> <a href="$local_settings{"path_htdocs"}/images/matchd2009.pdf" class="sml" target="_blank">$w{'Use the MATCH-D tool'}</a>
								<div class="clear-l"></div>
							</div>
							<div class="p10bo clear-l">
								<div class="float-l gt w49p">$w{'Patient interested in transplant'} $required_io</div>
								<select name="form_list_interested_in_transplant" id="form_list_interested_in_transplant" class="w49p" onchange="manage_list();">
									$form_list_interested_in_transplant_options
								</select>
							</div>
							<div class="p10bo clear-l">
								<div class="float-l gt w49p">$w{'ACP introduced'} $required_io</div>
								<select name="form_list_acp_introduced" class="w49p">
									$form_list_acp_introduced_options
								</select>
							</div>
							<div class="p10bo clear-l">
								<div class="float-l gt w49p">$w{'Date of ACP completion'}</div>
								<div class="itt w49p"><input type="text" class="itt" name="form_list_most_completed_date" value="$p{"form_list_most_completed_date"}" onclick="displayDatePicker('form_list_most_completed_date');"/></div>
							</div>
							<div class="p20bo clear-l">
								<div class="float-l gt w49p">$w{'Recovered from dialysis dependance?'}</div>
								<select name="form_list_recovered_from_dialysis_dependance" class="w49p">
									$form_list_recovered_from_dialysis_dependance_options
								</select>
								<div class="clear-l"></div>
							</div>
							
							<div class="p10bo b">$w{'Sign off'}</div>
							<div class="p10bo">
								<div class="float-l gt w49p">$w{'Sign off'}</div>
								<select name="form_list_completed" id="form_list_completed" class="w49p" onchange="manage_list();">
									$form_list_completed_options
								</select>
							</div>
							<div class="p10bo clear-l">
								<div class="float-l gt w49p">$w{'Date of TN sign off'} $required_io</div>
								<div class="itt w49p"><input type="text" class="itt" name="form_list_tn_discharge_date" id="form_list_tn_discharge_date" value="$p{"form_list_tn_discharge_date"}" onclick="displayDatePicker('form_list_tn_discharge_date');"/></div>
								<div id="form_list_tn_discharge_date_default" class="hide">$form_list_tn_discharge_date_default</div>
							</div>
						</div>
					</div>
				</div>
				<div class="float-l w50p">
					<div class="p10lo">
						<div>
							<div id="form_list_kcc">
								<div class="p10bo">
									<div class="p10bo b">$w{'Kidney Care Centre'}</div>
									<div class="p10bo clear-l">
										<div class="float-l gt w49p">$w{'Modality orientation date'}</div>
										<div class="itt w49p"><input type="text" class="itt" name="form_list_kcc_modality_orientation_date" value="$p{"form_list_kcc_modality_orientation_date"}" onclick="displayDatePicker('form_list_kcc_modality_orientation_date');"/></div>
									</div>
									<div class="p10bo clear-l">
										<div class="float-l gt w49p">$w{'Preferred modality'}</div>
										<select class="w49p" name="form_list_kcc_preferred_modality">
											$form_list_kcc_preferred_modality_options
										</select>
									</div>
								</div>
							</div>
							
							<div id="form_list_cvc">
								<div class="p10bo">
									<div class="p10bo b">$w{'For patients with CVC'}</div>
									<div class="p10bo clear-l">
										<div class="float-l gt w49p">$w{'Date of VA referral'}</div>
										<div class="itt w49p"><input type="text" class="itt" name="form_list_cvc_va_referral_date" value="$p{"form_list_cvc_va_referral_date"}" onclick="displayDatePicker('form_list_cvc_va_referral_date');"/></div>
									</div>
								</div>
							</div>
							
							<div id="form_list_incentrehd">
								<div class="p10bo">
									<div class="p10bo b">$w{'In-centre or community hemodialysis'}</div>
									<div class="p10bo clear-l">
										<div class="float-l gt w49p">$w{'Reason_uc'} $required_io</div>
										<select class="w49p" name="form_list_incentre_reason" id="form_list_incentre_reason" onchange="manage_list();">
											$form_list_incentre_reason_options
										</select>
									</div>
									<div id="form_list_incentre_reason_other_box">
										<div class="class="p2bo">
											<div class="float-l gt w49p">$w{'Specify &quot;other&quot; reason'} $required_io</div>
											<div class="itt w49p"><input type="text" class="itt" name="form_list_incentre_reason_other" value="$p{"form_list_incentre_reason_other"}"/></div>
										</div>
									</div>
								</div>
							</div>
							
							<div id="form_list_hhd">
								<div class="p10bo">
									<div class="p10bo b">$w{'Home hemodialysis (HHD)'}</div>
									<div class="p10bo clear-l">
										<div class="float-l gt w49p">$w{'Date of HHD referral'}</div>
										<div class="itt w49p"><input type="text" class="itt" name="form_list_homehd_hhd_referral_date" value="$p{"form_list_homehd_hhd_referral_date"}" onclick="displayDatePicker('form_list_homehd_hhd_referral_date');"/></div>
									</div>
									<div class="p10bo clear-l">
										<div class="float-l gt w49p">$w{'Date of HHD start'}</div>
										<div class="itt w49p"><input type="text" class="itt" name="form_list_homehd_hhd_start_date" value="$p{"form_list_homehd_hhd_start_date"}" onclick="displayDatePicker('form_list_homehd_hhd_start_date');"/></div>
									</div>
								</div>
							</div>
							
							<div id="form_list_pd">
								<div class="p10bo">
            						<div class="p10bo b">$w{'Peritoneal dialysis (PD)'}</div>
									<div class="p10bo clear-l">
            							<div class="float-l gt w49p">$w{'Date of PD referral'}</div>
										<div class="itt w49p"><input type="text" class="itt" name="form_list_pd_referral_date" value="$p{"form_list_pd_referral_date"}" onclick="displayDatePicker('form_list_pd_referral_date');"/></div>
									</div>
									<div class="p10bo clear-l">
            							<div class="float-l gt w49p">$w{'Date of PD cath insertion'}</div>
										<div class="itt w49p"><input type="text" class="itt" name="form_list_pd_cath_insertion_date" value="$p{"form_list_pd_cath_insertion_date"}" onclick="displayDatePicker('form_list_pd_cath_insertion_date');"/></div>
									</div>
									<div class="p10bo clear-l">
            							<div class="float-l gt w49p">$w{'Date of PD start'}</div>
										<div class="itt w49p"><input type="text" class="itt" name="form_list_pd_start_date" value="$p{"form_list_pd_start_date"}" onclick="displayDatePicker('form_list_pd_start_date');"/></div>
									</div>
								</div>
							</div>
							
							<div id="form_list_transplant">
								<div class="p10bo">
									<div class="p10bo b">$w{'Transplant'}</div>
									<div class="p10bo clear-l">
            							<div class="float-l gt w49p">$w{'Date of transplant referral'}</div>
										<div class="itt w49p"><input type="text" class="itt" name="form_list_transplant_referral_date" value="$p{"form_list_transplant_referral_date"}" onclick="displayDatePicker('form_list_transplant_referral_date');"/></div>
									</div>
									<div class="p10bo clear-l">
            							<div class="float-l gt w49p">$w{'Living donor identified'}</div>
										<select name="form_list_transplant_donor_identified" class="">
											$form_list_transplant_donor_identified_options
										</select>
									</div>
									<div class="p10bo clear-l">
            							<div class="float-l gt w49p">$w{'Date of transplantation'}</div>
										<div class="itt w49p"><input type="text" class="itt" name="form_list_transplant_date" value="$p{"form_list_transplant_date"}" onclick="displayDatePicker('form_list_transplant_date');"/></div>
									</div>
								</div>
							</div>
							
							<div id="form_list_preemptive_transplant">
								<div class="p10bo">
            							<div class="p10bo b">$w{'Pre-emptive transplant'}</div>
									<div class="p10bo clear-l">
            							<div class="float-l gt w49p">$w{'Referred for transplant prior to hemodialysis'}</div>
										<select class="w49p" name="form_list_preemptive_transplant_referral">
											$form_list_preemptive_transplant_referral_options
										</select>
										<div class="clear-l"></div>
									</div>
								</div>
							</div>
							
							<div>
								<div class="p10bo">
            						<div class="p10bo b">$w{'Follow-up and outcome'}</div>
									<div class="p10bo clear-l">
            							<div class="float-l gt w49p">$w{'Arrange follow-up in'}</div>
										<div class="float-l"><select class="w100" name="form_list_flag_for_follow_up" id="form_list_flag_for_follow_up" onchange="manage_list_followup();">
											$form_list_flag_for_follow_up_options
										</select></div>
            							<div class="float-l tm w30 gt">$w{'at'}</div>
										<div class="float-l">
											<div class="itt w80"><input type="text" class="itt" name="form_list_flag_for_follow_up_date" id="form_list_flag_for_follow_up_date" value="$p{"form_list_flag_for_follow_up_date"}" onclick="displayDatePicker('form_list_flag_for_follow_up_date');"/></div>
										</div>
										<div id="form_list_flag_for_follow_up_date_1" class="hide">$form_list_flag_for_follow_up_date_1</div>
										<div id="form_list_flag_for_follow_up_date_2" class="hide">$form_list_flag_for_follow_up_date_2</div>
										<div id="form_list_flag_for_follow_up_date_3" class="hide">$form_list_flag_for_follow_up_date_3</div>
										<div id="form_list_flag_for_follow_up_date_4" class="hide">$form_list_flag_for_follow_up_date_4</div>
										<div id="form_list_flag_for_follow_up_date_5" class="hide">$form_list_flag_for_follow_up_date_5</div>
										<div id="form_list_flag_for_follow_up_date_6" class="hide">$form_list_flag_for_follow_up_date_6</div>
										<div id="form_list_flag_for_follow_up_date_9" class="hide">$form_list_flag_for_follow_up_date_9</div>
										<div id="form_list_flag_for_follow_up_date_12" class="hide">$form_list_flag_for_follow_up_date_12</div>
										<div class="clear-l"></div>
									</div>
									<div class="p10bo clear-l">
            							<div class="float-l gt w49p">$w{'Follow-up comments'}</div>
										<div class="itt w49p"><input type="text" class="itt" name="form_list_follow_up_comments" value="$p{"form_list_follow_up_comments"}"/></div>
									</div>
									<div class="p10bo clear-l">
										<div class="float-l gt w49p">$w{'Modality at 6 months'}</div>
										<select name="form_list_modality_at_six_months" id="form_list_modality_at_six_months" class="w49p">
											$form_list_modality_at_six_months_options
										</select>
										$enable_modality_at_6_months
									</div>
									<div class="p10bo clear-l">
            							<div class="float-l gt w49p">$w{'Modality at 12 months'}</div>
										<select name="form_list_modality_at_twelve_months" id="form_list_modality_at_twelve_months" class="w49p">
											$form_list_modality_at_twelve_months_options
										</select>
										$enable_modality_at_12_months
									</div>
								</div>
							</div>
							
            				<div class="p10bo b">$w{'General comments'}</div>
							<div class=''>
								<div class="itt w100p"><textarea class="itt" name="form_list_comments" rows="12">$p{"form_list_comments"}</textarea></div>
							</div>
							
							<div class="p5 bg-vlg tr">
								<input type="submit" value="$w{'Save changes'}" onclick="clear_date_picker();"/>
							</div>
							<div>$delete_button</div>
						</div>
					</div>
				</div>
			</form>
			<div class="clear-l"></div>
			<img src="/images/blank.gif" width='1' height='1' alt='' onload="manage_list();"/>
		};
	}
}
sub view_case() {
	my %p = %{$_[0]};
	my ($msgs, $cultures, $antibiotics, $triggers, $name_first, $name_last, $phn, $weight, $title, $patient_info, $next_step, $delete_button);
	$msgs .= qq{<div class="emp">$p{'message_error'}</div>} if $p{'message_error'} ne '';
	$msgs .= qq{<div class="suc">$p{'message_success'}</div>} if $p{'message_success'} ne '';
	my $ok_case = &fast(qq{SELECT entry FROM rc_cases WHERE entry="$p{"case_id"}"});
	my $ok_patient = &fast(qq{SELECT entry FROM rc_patients WHERE entry="$p{'patient_id'}"});
	my $render_page = 0;
	if ($ok_case eq '') {
		if ($ok_patient eq '') {
			return qq{
				$close_button
				<h2><img src="$local_settings{"path_htdocs"}/images/icon-update-small-blue.png" alt=''/> $w{'New case'}</h2>
				$msgs
				<div class="b p10bo">$w{"Please enter a patient's name or PHN or"} <a href="ajax.pl?token=$token&do=add_patient_form" target="$hbin_target">$w{'Add a new patient'}</a>.</div>
				<div class=''>
					<div class="float-r w730">
						<div class="itt"><input type="text" class="itt" id="ncpi" name="ncpi" value='' onkeyup="refresh_patient_selector_ajax(this.value);"/></div>
						<div class="hide" id="form_patient_selector_token">$token</div>
						<div class="hide" id="form_patient_selector_mode">case</div>
						<div class="hide" id="form_patient_selector_prev"></div>
					</div>
					<img src="$local_settings{"path_htdocs"}/images/img_ni_search.gif" alt="$w{'Search'}"/>
					<div class="clear-r"></div>
				</div>
				<div id="form_patient_selector" class="max300"></div>
				<div class="hide" id="form_patient_selector_searching"><div class="loading">$w{'Searching'}...</div></div>
				<div class="clear-l"></div>
				<img src="/images/blank.gif" width='1' height='1' alt='' onload="document.getElementById('ncpi').focus()"/>};
		} elsif ($ok_patient and &fast(qq{SELECT entry FROM rc_cases WHERE patient="$ok_patient" AND outcome="Outstanding"})) {
			my ($cid, $cty, $ccr, $cmo) = &query(qq{SELECT entry, case_type, created, modified FROM rc_cases WHERE patient="$ok_patient" AND outcome="Outstanding" ORDER BY entry DESC LIMIT 1});
			my $cit = &get_infection_type($cid);
			$ccr = &nice_time_interval($ccr);
			$cmo = &nice_time_interval($cmo);
			my ($pnf,$pnl,$phn) = &query(qq{SELECT name_first, name_last, phn FROM rc_patients WHERE entry="$ok_patient"});
			return qq{
				$close_button
				<h2><img src="$local_settings{"path_htdocs"}/images/icon-update-small-blue.png" alt=''/> $w{'New case'}</h2>
				$msgs
				<div class="emp"><span class="b">$w{'The patient'} $pnf $pnl ($phn) $w{'already has an outstanding case that was last updated'} $cmo.</span> $w{'Patients can have only one outstanding case at a time'}.
				<div class="p10to"><a href="ajax.pl?token=$token&do=edit_case_form&case_id=$cid" target="$hbin_target" class="b">$w{'Open outstanding case'}</a> &bull; <a href="ajax.pl?token=$token&do=add_case_form" target="$hbin_target" class="b">$w{'choose another patient'}</a></div></div>
			};
		} elsif ($ok_patient) {
			$render_page = 1;
			$triggers = qq{
				<input type="hidden" name="patient_id" value="$ok_patient"/>
				<input type="hidden" name="do" value="add_case_save"/>
			};
			$title = $w{'New case'};
			$p{"form_case_created"} = &fast(qq{SELECT CURDATE()});
			$p{"form_case_infection_type"} = "Peritonitis";
			$p{"form_case_case_type"} = "De novo";
			$p{"form_case_closed_print"} = $w{'Active_uc'};
			$p{"form_case_hospitalization_required"} = "No";
			$p{"form_case_hospitalization_location"} = $local_settings{"default_hospital"};
			$p{"form_case_hospitalization_onset"} = "No";
			$p{"form_case_outcome"} = "Outstanding";
			$p{"form_case_home_visit"} = "Pending";
			$p{"form_case_follow_up_culture"} = "Pending";
			$p{"form_case_modified"} = $w{'Right now'};
			$p{"form_case_is_peritonitis"} = 1;
			$p{"form_case_is_exit_site"} = 0;
			$p{"form_case_is_tunnel"} = 0;
			$cultures = qq{};
			$antibiotics = qq{};
			$p{"page_case_past_cases"} = qq{};
			$p{"page_case_past_cases_count"} = qq{0};
			my @cases = &query(qq{SELECT entry FROM rc_cases WHERE patient="$ok_patient" ORDER BY created DESC});
			foreach my $case_id (@cases) {
				my %case_info = &queryh(qq{SELECT * FROM rc_cases WHERE entry="$case_id"});
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
				my @case_cultures = &querymr(qq{SELECT pathogen_1, pathogen_2, pathogen_3, pathogen_4 FROM rc_labs WHERE case_id="$case_id"});
				my @case_antibiotics = &query(qq{SELECT antibiotic FROM rc_antibiotics WHERE case_id="$case_id"});
				foreach my $culture (@case_cultures) {
					my @culture = @$culture;
					foreach my $pathogen (@culture) {
						if ($pathogen ne '') {
							$case_cultures .= qq{$pathogen; };
						}
					}
				}
				$case_cultures =~ s/; $//g;
				foreach my $antibiotic (@case_antibiotics) {
					if ($antibiotic ne '') {
						$case_antibiotics .= qq{$antibiotic; };
					}
				}
				$case_antibiotics =~ s/; $//g;
				$case_info{"outcome"} = lc $case_info{"outcome"};
				$p{"page_case_past_cases_count"} = $p{"page_case_past_cases_count"} + 1;
				$p{"page_case_past_cases"} .= qq{
					<div class="p5bo">
						<div class="p5bo br-b">
                    <div class="float-r"><a href="ajax.pl?token=$token&do=edit_case_form&amp;case_id=$case_id" class="b" target="$hbin_target">$w{'manage case'}</a></div>
							<div class="b">$case_type</div>
							<div class="sml">
								<div>
                    <span class="gt">$w{'Presented'}</span>
									<span class="b">$case_onset_interval</span> ($case_onset_date)
								</div>
								<div>
                    <span class="gt">$w{'Culture'}</span>
									<span class=''>$case_cultures</span>
								</div>
								<div>
                    <span class="gt">$w{'Antibiotics'}</span>
									<span class=''>$case_antibiotics</span>
								</div>
								<div>
                    <span class="gt">$w{'Outcome'}</span>
									<span class=''>$case_info{"outcome"}</span>
								</div>
							</div>
						</div>
					</div>
				};
			}
		}
	} elsif ($ok_case ne '') {
		&get_next_step($ok_case);
		$render_page = 1;
		$triggers = qq{
			<input type="hidden" name="case_id" value="$ok_case"/>
			<input type="hidden" name="do" value="edit_case_save"/>
		};
		$title = $w{'Manage case_uc'};
		$delete_button = qq{<div class="float-r p2to"><a href="ajax.pl?token=$token&do=delete_case_confirm&case_id=$ok_case" target="$hbin_target" class="rcb"><span>$w{'Delete case'}</span></a></div>};
		my %h = &queryh(qq{SELECT entry, patient, is_peritonitis, is_exit_site, is_tunnel, initial_wbc, initial_pmn, case_type, hospitalization_required, hospitalization_location, hospitalization_onset, hospitalization_start_date, hospitalization_stop_date, outcome, home_visit, follow_up_culture, next_step, closed, comments, created, modified FROM rc_cases WHERE entry="$ok_case"});
		foreach my $key (keys %h) {
			$p{"form_case_$key"} = $h{"$key"};
		}
		$p{'patient_id'} = $p{"form_case_patient"} if $p{'form_case_patient'} ne '';
		$ok_patient = $p{"form_case_patient"};
		$p{"form_case_modified"} = &nice_time($p{"form_case_modified"});
		if ($p{"form_case_closed"} == 1) {
			$p{"form_case_closed_print"} = $w{'Closed_uc'};
		} else {
			$p{"form_case_closed_print"} = $w{'Active_uc'};
		}
		my @lab = &querymr(qq{SELECT entry, type, status, created, modified, pathogen_1, pathogen_2, pathogen_3, pathogen_4 FROM rc_labs WHERE case_id="$ok_case"});
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
				if ($t ne '') {
					$t = $w{$t};
					$germ .= qq{<span class="b">$t</span>, };
				}
			}
			$germ =~ s/, $//g;
			$germ = qq{<span class="b">$w{'Results not available'}</span>} unless $germ;
			my $comments_lab = &comments_lab($lid);
			$cultures .= qq{
				<div>
					<div class="p5 bg-vlg">
						<div class="float-r"><a href="ajax.pl?token=$token&do=edit_lab_form&lab_id=$lid" target="$hbin_target" class="b">$w{'change'}</a></div>
						<div>$germ <span class="gt">($upda)</span> $comments_lab</div>
					</div>
				</div>};
		}
		my @abx = &querymr(qq{SELECT * FROM rc_antibiotics WHERE case_id="$ok_case" ORDER BY date_stopped DESC});
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
				$stop_notice = "&mdash;$w{'stopped'}";
			}
			my $abx_regimen_duration_print = qq{$w{'For'} $abx_regimen_duration $w{'days starting on'} $abx_date_start $stop_notice};
			$abx_regimen_duration_print = qq{$w{'Loading dose given on'} $abx_date_start $stop_notice} if $abx_regimen_duration == 1;
			my $abx_basis;
			if ($abx_basis_final == 1) {
				$abx_basis = $w{'final'};
			} elsif ($abx_basis_empiric == 1) {
				$abx_basis = $w{'empiric'};
			}
			my ($abx_bar, $abx_percent) = &build_abx_bar($abx_entry);
			my $stop_button = qq{ &nbsp; <a href="ajax.pl?token=$token&do=edit_antibiotic_stop_save&case_id=$ok_case&abx_id=$abx_entry" target="$hbin_target" class="b">$w{'stop'}</a>};
			if ($abx_percent eq "100") {
				$stop_button = '';
			}
			my $comments_abx = &comments_antibiotic($abx_entry);
			$antibiotics .= qq{
				<div class=''>
					<div class="p5 bg-vlg">
						<div class="float-r"><a href="ajax.pl?token=$token&do=edit_antibiotic_form&abx_id=$abx_entry" target="$hbin_target" class="b">$w{'change'}</a>$stop_button</div>
						<div><span class="b">$abx_antibiotic, $abx_dose_amount $abx_dose_amount_units $abx_dose_frequency $abx_route</span> ($abx_basis) $comments_abx</div>
						<div class="sml">$abx_regimen_duration_print</div>
						<div>$abx_bar</div>
					</div>
				</div>};
		}
		$next_step = qq{<span class="ac-yellow">$w{'Next step'}: } .
		&interpret_next_step($h{"next_step"}) . qq{</span>};
		$cultures = qq{
			<h4>$w{'Culture results'}</h4>
			<div class="mh120">
				$cultures
			</div>
			<div class="p5to p20bo"><img src="$local_settings{"path_htdocs"}/images/add.gif" alt=''/><a target="$hbin_target" href="ajax.pl?token=$token&do=add_lab_form&case_id=$ok_case">$w{'Add culture result'}</a></div>};
		$antibiotics = qq{
			<h4>$w{'Antibiotics given'}</h4>
			<div class="xh200">
				$antibiotics
			</div>
			<div class="p5to p20bo"><img src="$local_settings{"path_htdocs"}/images/add.gif" alt=''/><a href="ajax.pl?token=$token&do=add_antibiotic_form&case_id=$ok_case" target="$hbin_target">$w{'Add treatment'}</a></div>};
	}
	if ($ok_patient ne '') {	
		($name_first, $name_last, $phn, $weight) = &query(qq{SELECT name_first, name_last, phn, weight FROM rc_patients WHERE entry="$ok_patient"});
		$p{"form_special_weight"} = $weight;
		$patient_info = qq{
			<tr>
				<td class="tl gt">$w{'Patient name'}</td>
            <td class="tl"><a href="ajax.pl?token=$token&do=edit_patient_form&patient_id=$ok_patient" target="$hbin_target"><span class="b">$name_last, $name_first</span></a> <span class="gt">$w{'PHN'} $phn</span></td>
			</tr>};
	}
	if ($render_page == 1) {
		my $form_case_hospitalization_onset_options = &build_select(
        qq{$p{'form_case_hospitalization_onset'};;$w{$p{'form_case_hospitalization_onset'}}},
			"No;;$w{'No'}",
			"Yes;;$w{'Yes'}");
		my $form_case_case_type_options = &build_select(
        qq{$p{'form_case_case_type'};;$w{$p{'form_case_case_type'}}},
			"De novo;;$w{'De novo'}",
			"Recurrent;;$w{'Recurrent'}",
			"Relapsing;;$w{'Relapsing'}",
			"Repeat;;$w{'Repeat'}",
			"Refractory;;$w{'Refractory'}",
			"Catheter-related;;$w{'Catheter-related'}");
		my $form_case_hospitalization_required_options = &build_select(
        qq{$p{'form_case_hospitalization_required'};;$w{$p{'form_case_hospitalization_required'}}},
            "No;;$w{'No'}",
            "Yes;;$w{'Yes'}");
		my $form_case_hospitalization_location_options = &build_select(
			$p{"form_case_hospitalization_location"},
			@local_settings_hospitals,
			"Other;;$w{'Other'}");
		my $form_case_outcome_options = &build_select(
            qq{$p{'form_case_outcome'};;$w{$p{'form_case_outcome'}}},
			"Outstanding;;$w{'Outstanding'}",
			"Resolution;;$w{'Resolution'}",
			"Relapsing infection;;$w{'Relapsing infection'}",
			"Catheter removal;;$w{'Catheter removal'}",
			"Catheter removal and death;;$w{'Catheter removal and death'}",
			"Death;;$w{'Death'}");
		my $form_case_home_visit_options = &build_select(
        qq{$p{'form_case_home_visit'};;$w{$p{'form_case_home_visit'}}},
			"Pending;;$w{'Pending'}",
			"Completed;;$w{'Completed'}",
			"Declined;;$w{'Declined'}",
			"Not applicable;;$w{'Not applicable'}");
		
		my $form_case_follow_up_culture_options = &build_select(
        qq{$p{'form_case_follow_up_culture'};;$w{$p{'form_case_follow_up_culture'}}},
        "Pending;;$w{'Pending'}",
        "Received;;$w{'Received'}",
        "Declined;;$w{'Declined'}",
        "Not applicable;;$w{'Not applicable'}");
		$p{"form_case_is_peritonitis_checked"} = qq{checked="checked"} if $p{"form_case_is_peritonitis"} == 1;
		$p{"form_case_is_exit_site_checked"} = qq{checked="checked"} if $p{"form_case_is_exit_site"} == 1;
		$p{"form_case_is_tunnel_checked"} = qq{checked="checked"} if $p{"form_case_is_tunnel"} == 1;
		if ($p{"page_case_past_cases"} ne '') {
			$p{"page_case_past_cases"} = qq{<div class="p10 bg-vlg"><h4>$w{'Past cases'}</h4><div style="max-height:360px; overflow:auto; padding-right:10px;">} . $p{"page_case_past_cases"} . qq{</div><span class="gt">$w{'Total of'} } . $p{"page_case_past_cases_count"} . qq{ $w{'past cases found in the database'}.</span></div>};
		}
		my $form_case_hospitalization_info_div_def = "hide";
		if ($p{"form_case_hospitalization_required"} eq "Yes") {
			$form_case_hospitalization_info_div_def = "show";
		}
		my $form_case_hospitalization_start_date_default = &fast(qq{SELECT CURDATE()});
		my $active_update_info;
		if ($p{"form_case_modified"} ne '') {
			if ($p{"form_case_closed"} == 1) {
				$p{"form_case_closed_print"} = qq{<span class="ac-red">$w{'Closed case'}</span>};
			} else {
				$p{"form_case_closed_print"} = qq{<span class="ac-green">$w{'Active case'}</span>};
			}
			$active_update_info = qq{
				<div class="float-l p15to p5ro">$p{"form_case_closed_print"}</div>
				<div class="float-l p15to"><span class="ac-lg">$w{'updated'} $p{"form_case_modified"}</span></div>
			};
		}
		return qq{
			$close_button
			<div class="float-l p20ro"><h2><img src="$local_settings{"path_htdocs"}/images/icon-update-small-blue.png" alt=''/> $title</h2></div>
			$active_update_info
			<div class="clear-l"></div>
			$msgs
			<div class="float-l w50p">
				<div class="p10ro">
					<div>
						<form name="form_case" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
							<input type="hidden" name="token" value="$token"/>
							$triggers
							<table class="w100p">
								<tbody>
									$patient_info
									<tr>
										<td class="tl w120 gt">$w{'Presentation date'}</td>
										<td class="tl"><div class="itt w80"><input type="text" class="itt" name="form_case_created" value="$p{"form_case_created"}" onclick="displayDatePicker('form_case_created');"/></div></td>
									</tr><tr>
										<td class="tl gt">$w{'Case type'}</td>
										<td class="tl"><select name="form_case_case_type" onfocus="show_def()" onblur="hide_def()" id="form_case_case_type">
											$form_case_case_type_options
										</select></td>
									</tr><tr>
										<td class="tl gt">$w{'Infection type'}</td>
										<td class="tl">
											<div>
												<input type="checkbox" name="form_case_is_peritonitis" id="form_case_is_peritonitis" value='1' $p{"form_case_is_peritonitis_checked"} /> 
            									<label for="form_case_is_peritonitis">$w{'Peritonitis'}</label>
            								</div>
											<div>
												<input type="checkbox" name="form_case_is_exit_site" id="form_case_is_exit_site" value='1' $p{"form_case_is_exit_site_checked"} /> 
            									<label for="form_case_is_exit_site">$w{'Exit site'}</label>
            								</div>
											<div>
												<input type="checkbox" name="form_case_is_tunnel" id="form_case_is_tunnel" value='1' $p{"form_case_is_tunnel_checked"} /> 
            									<label for="form_case_is_tunnel">$w{'Tunnel'}</label>
            								</div>
										</td>
									</tr><tr>
                                                <td class="tl gt">$w{'Initial WBC count'}</td>
										<td class="tl"><div class="float-l"><div class="itt w50"><input type="text" class="itt" name="form_case_initial_wbc" value="$p{"form_case_initial_wbc"}"/></div></div><div class="float-l p2to p5lo">x 10<sup>6</sup>/L</div><div class="clear-l"></div></td>
									</tr><tr>
            <td class="tl gt">$w{'Initial %PMN on diff'}</td>
										<td class="tl"><div class="float-l"><div class="itt w50"><input type="text" class="itt" name="form_case_initial_pmn" value="$p{"form_case_initial_pmn"}"/></div></div><div class="float-l p2to p5lo">\%</div><div class="clear-l"></div></td>
									</tr><tr>
            <td class="tl gt">$w{'Patient weight'}</td>
            <td class="tl"><div class="float-l"><div class="itt w50"><input type="text" class="itt" name="form_special_weight" value="$p{"form_special_weight"}"/></div></div><div class="float-l p2to p5lo">$w{'kilograms'}</div><div class="clear-l"></div></td>
									</tr><tr>
            <td class="tl gt">$w{'Onset in hospital'}</td>
										<td class="bl"><select name="form_case_hospitalization_onset">
											$form_case_hospitalization_onset_options
										</select></td>
									</tr><tr>
            <td class="tl gt">$w{'Hospitalized'}</td>
										<td class="tl">
											<select name="form_case_hospitalization_required" id="form_case_hospitalization_required" onchange="set_hospitalization();">
												$form_case_hospitalization_required_options
											</select>
											<div id="form_case_hospitalization_info_div" class="$form_case_hospitalization_info_div_def">
												<div class="p4bo">
            <div class="float-l gt w60 p3to">$w{'Location'}</div>
													<select name="form_case_hospitalization_location" class="w200">
														$form_case_hospitalization_location_options
													</select>
												</div>
												<div class="p3bo">
            <div class="float-l gt w100">$w{'Admit date'}</div>
													<div class="itt w80"><input type="text" class="itt" id="form_case_hospitalization_start_date" name="form_case_hospitalization_start_date" value="$p{"form_case_hospitalization_start_date"}" onclick="displayDatePicker('form_case_hospitalization_start_date');"/></div>
													<div id="form_case_hospitalization_start_date_default" class="hide">$form_case_hospitalization_start_date_default</div>
												</div>
												<div>
            <div class="float-l gt w100">$w{'Discharge date'}</div>
													<div class="itt w80"><input type="text" class="itt" name="form_case_hospitalization_stop_date" value="$p{"form_case_hospitalization_stop_date"}" onclick="displayDatePicker('form_case_hospitalization_stop_date');"/></div>
												</div>
											</div>
										</td>
									</tr><tr>
            <td class="tl gt">$w{'Home visit'}</td>
										<td class="tl"><select name="form_case_home_visit">
											$form_case_home_visit_options
										</select></td>
									</tr><tr>
            <td class="tl gt">$w{'Follow-up culture'}</td>
										<td class="tl"><select name="form_case_follow_up_culture">
											$form_case_follow_up_culture_options
										</select></td>
									</tr><tr>
            <td class="tl gt">$w{'Outcome'}</td>
										<td class="tl"><select name="form_case_outcome">
											$form_case_outcome_options
										</select></td>
									</tr><tr>
            <td class="tl gt">$w{'Comments'} $comment_icon</td>
										<td class="tl"><div class="itt w100p"><textarea class="itt" name="form_case_comments" rows="3">$p{"form_case_comments"}</textarea></div></td>
									</tr>
								</tbody>
							</table>
							$delete_button<input type="submit" value="$w{'Save changes'}" onclick="clear_date_picker();"/><div class="clear-r"></div>
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
			<div class="clear-l"></div>};
	}
}
sub view_catheter() {
	my %p = %{$_[0]};
	my ($msgs,$title);
	if ($p{'message_error'} ne '') {
		$msgs .= qq{<div class="emp">$p{'message_error'}</div>};
	}
	if ($p{'message_success'} ne '') {
		$msgs .= qq{<div class="suc">$p{'message_success'}</div>};
	}
	my $ok_patient = &fast(qq{SELECT entry FROM rc_patients WHERE entry="$p{'patient_id'}"});
	my $ok_catheter = &fast(qq{SELECT entry FROM rc_catheters WHERE entry="$p{"catheter_id"}"});
	my ($triggers, $delete_button);
	if ($ok_catheter ne '') {
		my %h = &queryh(qq{SELECT * FROM rc_catheters WHERE entry="$p{"catheter_id"}"});
		foreach my $key (keys %h) {
			$p{"form_catheter_$key"} = $h{"$key"};
		}
		$ok_patient = $p{"form_catheter_patient_id"};
		$title = $w{'Catheter information'};
		$triggers = qq{
			<input type="hidden" name="do" value="edit_catheter_save"/>
			<input type="hidden" name="catheter_id" value="$ok_catheter"/>
		};
		$delete_button = qq{<div class=''>&nbsp;</div><div class="tr"><a href="ajax.pl?token=$token&do=delete_catheter_confirm&catheter_id=$p{"catheter_id"}" target="$hbin_target" class="rcb"><span>$w{'Delete catheter information'}</span></a><div class="clear-l"></div></div>};
	} else {
		$title = $w{'Add catheter information'};
		$triggers = qq{
			<input type="hidden" name="do" value="add_catheter_save"/>
			<input type="hidden" name="patient_id" value="$ok_patient"/>
		};
		$p{"form_catheter_insertion_location"} = "Bedside" if $p{"form_catheter_insertion_location"} eq '';
		$p{"form_catheter_insertion_method"} = "Surgery" if $p{"form_catheter_insertion_method"} eq '';
		$p{"form_catheter_type"} = "Curled" if $p{"form_catheter_type"} eq '';
	}
	my ($name_first, $name_last, $phn) = &query(qq{SELECT name_first, name_last, phn FROM rc_patients WHERE entry="$ok_patient"});
	my $form_catheter_insertion_location_options = &build_select(
    qq{$p{'form_catheter_insertion_location'};;$w{$p{'form_catheter_insertion_location'}}},
		"Bedside;;$w{'Bedside'}",
		"Operating room;;$w{'Operating room'}");
	my $form_catheter_insertion_method_options = &build_select(
    qq{$p{'form_catheter_insertion_method'};;$w{$p{'form_catheter_insertion_method'}}},
		"Blind insertion;;$w{'Blind insertion'}",
		"Peritoneoscope;;$w{'Peritoneoscope'}",
		"Surgery;;$w{'Surgery'}",
		"Other");
	my $form_catheter_type_options = &build_select(
    qq{$p{'form_catheter_type'};;$w{$p{'form_catheter_type'}}},
		"Curled;;$w{'Curled'}",
		"Presternal;;$w{'Presternal'}",
		"Straight;;$w{'Straight'}");
	my @usrs = &querymr(qq{SELECT entry, name_first, name_last, role FROM rc_users WHERE role="Nephrologist" OR role="Surgeon" ORDER BY name_last ASC, name_first ASC});
	my $select_options_surgeons = qq{<option value=''>($w{'none'})</option>};
	my $selected_surgeon;
	foreach my $d (@usrs) {
		my ($users_entry, $users_name_first, $users_name_last, $users_role) = @$d;
		if ($p{"form_catheter_surgeon"} eq $users_entry) {
			$selected_surgeon = qq{selected="selected"};
		} else {
			$selected_surgeon = '';
		}
		$select_options_surgeons .= qq{<option value="$users_entry" $selected_surgeon>Dr. $users_name_first $users_name_last</option>};
	}
	return qq{
		$close_button
		<h2><img src="$local_settings{"path_htdocs"}/images/icon-user-small.png" alt='' /> $title</h2>
		$msgs
		<form name="form_catheter" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
			<input type="hidden" name="token" value="$token"/>
			$triggers
			<div class="float-l w40p">
				<div class="pl0ro">
					<div>
						<div class="b p5bo">$w{'Patient information'}</div>
						<table class="w100p">
							<tbody>
								<tr>
									<td class="tl w100 gt">$w{'Patient name'}</td>
									<td class="tl">$name_last, $name_first</td>
								</tr><tr>
									<td class="tl w100 gt">$w{'PHN'}</td>
									<td class="tl">$phn</td>
								</tr>
							</tbody>
						</table>
						<div class="p50to">
							<div class="tron" onclick="document.form_catheter.submit(); clear_date_picker();">$w{'save changes and return'}</div>
        					<div class="p30lo p10to gt"> $w{'or'} <a href="ajax.pl?token=$token&do=edit_patient_form&amp;patient_id=$ok_patient" target="$hbin_target" onclick="clear_date_picker();">$w{'discard changes and return'}</a></div>
						</div>
					</div>
				</div>
			</div>
			<div class="float-l w60p">
				<div class="p10lo">
					<div>
        <div class="b p5bo">$w{'Catheter details'}</div>
						<table class="w100p">
							<tbody>
								<tr>
        <td class="tl w110 gt">$w{'Insertion location'}</td>
									<td class="tl">
										<select name="form_catheter_insertion_location" class="w100p">
											$form_catheter_insertion_location_options
										</select>
									</td>
								</tr><tr>
        <td class="tl w110 gt">$w{'Insertion method'}</td>
									<td class="tl">
										<select name="form_catheter_insertion_method" class="w100p">
											$form_catheter_insertion_method_options
										</select>
									</td>
								</tr><tr>
        <td class="tl w110 gt">$w{'Catheter type'}</td>
									<td class="tl">
										<select name="form_catheter_type" class="w100p">
											$form_catheter_type_options
										</td>
								</tr><tr>
        <td class="tl w110 gt">$w{'Surgeon'}</td>
									<td class="tl p5bo">
										<select name="form_catheter_surgeon" class="w100p">
											$select_options_surgeons
										</select>
									</td>
								</tr><tr>
        <td class="tl w110 gt">$w{'Insertion date'}</td>
									<td class="tl">
										<div class="float-l p5ro"><div class="itt w80"><input type="text" class="itt" name="form_catheter_insertion_date" value="$p{"form_catheter_insertion_date"}" onclick="displayDatePicker('form_catheter_insertion_date');"/></div></div><span class="gt">YYYY-MM-DD</span>
									</td>
								</tr><tr>
        <td class="tl w110 gt">$w{'Removal date'}</td>
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
	my ($msgs,$title);
	if ($p{'message_error'} ne '') {
		$msgs .= qq{<div class="emp">$p{'message_error'}</div>};
	}
	if ($p{'message_success'} ne '') {
		$msgs .= qq{<div class="suc">$p{'message_success'}</div>};
	}
	my $ok_patient = &fast(qq{SELECT entry FROM rc_patients WHERE entry="$p{'patient_id'}"});
	my $ok_dialysis = &fast(qq{SELECT entry FROM rc_dialysis WHERE entry="$p{"dialysis_id"}"});
	my ($triggers, $delete_button);
	if ($ok_dialysis ne '') {
		my %h = &queryh(qq{SELECT * FROM rc_dialysis WHERE entry="$p{"dialysis_id"}"});
		foreach my $key (keys %h) {
			$p{"form_dialysis_$key"} = $h{"$key"};
		}
		$ok_patient = $p{"form_dialysis_patient_id"};
		$title = $w{'Dialysis information'};
		$triggers = qq{
			<input type="hidden" name="do" value="edit_dialysis_save"/>
			<input type="hidden" name="dialysis_id" value="$ok_dialysis"/>
		};
		$delete_button = qq{<div class=''>&nbsp;</div><div class="tr"><a href="ajax.pl?token=$token&do=delete_dialysis_confirm&dialysis_id=$p{"dialysis_id"}" target="$hbin_target" class="rcb"><span>$w{'Delete dialysis information'}</span></a><div class="clear-l"></div></div>};
	} else {
		$title = $w{'Add dialysis information'};
		$triggers = qq{
			<input type="hidden" name="do" value="add_dialysis_save"/>
			<input type="hidden" name="patient_id" value="$ok_patient"/>
		};
		$p{"form_dialysis_center"} = "RCH" if $p{"form_dialysis_center"} eq '';
		$p{"form_dialysis_type"} = "CCPD" if $p{"form_dialysis_type"} eq '';
	}
	my ($name_first, $name_last, $phn) = &query(qq{SELECT name_first, name_last, phn FROM rc_patients WHERE entry="$ok_patient"});
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
		<h2><img src="$local_settings{"path_htdocs"}/images/icon-user-small.png" alt='' /> $title</h2>
		$msgs
		<form name="form_dialysis" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
			<input type="hidden" name="token" value="$token"/>
			$triggers
			<div class="float-l w50p">
				<div class="pl0ro">
					<div>
						<div class="b p5bo">$w{'Patient information'}</div>
						<table class="w100p">
							<tbody>
								<tr>
									<td class="tl w100 gt">$w{'Patient name'}</td>
									<td class="tl">$name_last, $name_first</td>
								</tr><tr>
									<td class="tl w100 gt">$w{'PHN'}</td>
									<td class="tl">$phn</td>
								</tr>
							</tbody>
						</table>
						<div class="p50to">
							<div class="tron" onclick="document.form_dialysis.submit(); clear_date_picker();">$w{'save changes and return'}</div>
        					<div class="p30lo p10to gt"> $w{'or'} <a href="ajax.pl?token=$token&do=edit_patient_form&amp;patient_id=$ok_patient" target="$hbin_target" onclick="clear_date_picker();">$w{'discard changes and return'}</a></div>
						</div>
					</div>
				</div>
			</div>
			<div class="float-l w50p">
				<div class="p10lo">
					<div>
        <div class="b p5bo">$w{'Dialysis details'}</div>
						<table class="w100p">
							<tbody>
								<tr>
        <td class="tl w90 gt">$w{'Dialysis centre'}</td>
									<td class="tl">
										<select name="form_dialysis_center" class="w100p">
											$form_dialysis_center_options
										</select>
									</td>
								</tr><tr>
        <td class="tl gt">$w{'Dialysis type'}</td>
									<td class="tl">
										<select name="form_dialysis_type" class="w100p">
											$form_dialysis_type_options
										</select>
									</td>
								</tr><tr>
        <td class="tl gt">$w{'Start date'}</td>
									<td class="tl">
										<div class="float-l p5ro"><div class="itt w80"><input type="text" class="itt" name="form_dialysis_start_date" value="$p{"form_dialysis_start_date"}" onclick="displayDatePicker('form_dialysis_start_date');"/></div></div><span class="gt">YYYY-MM-DD</span>
									</td>
								</tr><tr>
        <td class="tl gt">$w{'Stop date'}</td>
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
	my ($msgs,$title);
	if ($p{'message_error'} ne '') {
		$msgs .= qq{<div class="emp">$p{'message_error'}</div>};
	}
	if ($p{'message_success'} ne '') {
		$msgs .= qq{<div class="suc">$p{'message_success'}</div>};
	}
	my $ok_case = &fast(qq{SELECT entry FROM rc_cases WHERE entry="$p{"case_id"}"});
	my $confirm_lab = &fast(qq{SELECT entry FROM rc_labs WHERE entry="$p{"lab_id"}"});
	if ($ok_case eq '' and $confirm_lab eq '') {
		$title = $w{'Add culture result'};
		my @cases = &querymr(qq{SELECT rc_cases.entry, rc_cases.patient, rc_cases.case_type, rc_cases.outcome, rc_cases.created, rc_cases.modified, rc_patients.name_first, rc_patients.name_last, rc_patients.phn FROM rc_cases, rc_patients WHERE rc_cases.patient=rc_patients.entry ORDER BY rc_patients.name_last ASC, rc_patients.name_first ASC, rc_cases.outcome ASC, rc_cases.modified DESC});
		my $cases = '';
		foreach my $c (@cases) {
			my $last_updated = &nice_time_interval(@$c[5]);
			my $case_status = ucfirst @$c[3];
			my $case_type = ucfirst @$c[2];
			my $infection_type = &get_infection_type(@$c[0]);
			$cases .= qq{
				<tr>
					<td class="pfmb_l">$case_status</td>
					<td class="pfmb_l"><a href="ajax.pl?token=$token&do=edit_patient_form&amp;patient_id=@$c[1]" target="$hbin_target">@$c[6] @$c[7]</a></td>
					<td class="pfmb_l">@$c[8]</td>
					<td class="pfmb_l">$case_type</td>
					<td class="pfmb_l">$infection_type</td>
					<td class="pfmb_l">$last_updated</td>
                <td class="pfmb_l"><a href="ajax.pl?token=$token&do=add_lab_form&amp;case_id=@$c[0]" target="$hbin_target" class="b">$w{'Add lab test'}</a></td>
				</tr>
			};
		}
		if ($cases eq '') {
			$cases = qq{<tr><td class="pfmb_l gt" colspan="7">$w{'No cases found'}.</td></tr>};
		}
		return qq{
			$close_button
			<h2>$title</h2>
			$msgs
			<div class="b">
            $w{'Please select a case from the list below or'} <a href="ajax.pl?token=$token&do=add_case_form" target="$hbin_target">$w{'enter a new case'}</a>. $w{'If the patient is not in this system, please'} <a href="ajax.pl?token=$token&do=add_patient_form" target="$hbin_target">$w{'enter the patient'}</a> $w{'first before proceeding to enter a new case or adding a lab test requisition to that case'}.
			</div>
			<div class="p10to">
				<div class="max400">
					<div>
						<table class="pfmt w100p">
							<tbody>
								<tr>
									<td class="pfmb_l b bg-dbp">$w{'Case status'}</td>
									<td class="pfmb_l b bg-dbp">$w{'Patient name'}</td>
									<td class="pfmb_l b bg-dbp">$w{'PHN'}</td>
									<td class="pfmb_l b bg-dbp">$w{'Case type'}</td>
									<td class="pfmb_l b bg-dbp">$w{'Infection type'}</td>
									<td class="pfmb_l b bg-dbp">$w{'Case updated'}</td>
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
		if ($confirm_lab ne '') {
			$title = $w{'Culture result'};
			my %h = &queryh(qq{SELECT * FROM rc_labs WHERE entry="$p{"lab_id"}"});
			foreach my $key (keys %h) {
				$p{"form_labs_$key"} = $h{"$key"};
			}
			$triggers = qq{
				<input type="hidden" name="do" value="edit_lab_save"/>
				<input type="hidden" name="lab_id" value="$confirm_lab"/>
			};
			($name_first, $name_last, $phn, $case_id, $case_type, $case_outcome, $case_created) = &query(qq{SELECT rc_patients.name_first, rc_patients.name_last, rc_patients.phn, rc_cases.entry, rc_cases.case_type, rc_cases.outcome, rc_cases.created FROM rc_cases, rc_patients WHERE rc_cases.entry="$p{"form_labs_case_id"}" AND rc_cases.patient=rc_patients.entry});
			$case_infection_type = &get_infection_type($case_id);
			$ok_case = $p{"form_labs_case_id"};
			$delete_button = qq{<div class=''>&nbsp;</div><div class="tr"><a href="ajax.pl?token=$token&do=delete_lab_confirm&lab_id=$p{"lab_id"}" target="$hbin_target" class="rcb"><span>$w{'Delete culture result'}</span></a><div class="clear-l"></div></div>};
		} elsif ($ok_case ne '') {
			$title = "Add culture result";
			$triggers = qq{
				<input type="hidden" name="do" value="add_lab_save"/>
				<input type="hidden" name="case_id" value="$ok_case"/>
			};
			($name_first, $name_last, $phn, $case_id, $case_type, $case_outcome, $case_created) = &query(qq{SELECT rc_patients.name_first, rc_patients.name_last, rc_patients.phn, rc_cases.entry, rc_cases.case_type, rc_cases.outcome, rc_cases.created FROM rc_cases, rc_patients WHERE rc_cases.entry="$ok_case" AND rc_cases.patient=rc_patients.entry});
			$p{"form_labs_type"} = "Peritoneal dialysis fluid" if $p{"form_labs_type"} eq '';
			$case_infection_type = &get_infection_type($case_id);
		}
		if ($p{"form_labs_ordered"} eq '') {
			$p{"form_labs_ordered"} = &fast(qq{SELECT CURDATE()});
		}
		my $time_modified = $p{"form_labs_modified"};
		if ($time_modified ne '') {
			$time_modified = &nice_time($time_modified);
		} else {
			$time_modified = $w{'Right now'};
		}
		my $form_labs_pathogen_matrix;
		my $form_labs_pathogen_matrix_count = 1;
		while ($form_labs_pathogen_matrix_count < 5) {
			my $number = $form_labs_pathogen_matrix_count;
			my $form_labs_results_type_options = &build_select(
				$p{"form_labs_result_$number\_type"},
				";;($w{'select stage'})",
				"Preliminary;;$w{'Preliminary'}",
				"Final;;$w{'Final_uc'}");
			my $form_labs_pathogen_options = &build_select(
				$p{"form_labs_pathogen_$number"},
				";;($w{'select pathogen'})",
				"(no culture taken);;$w{'(no culture taken)'}",
				"Preliminary: Gram +ve coccus;;$w{'Preliminary: Gram +ve coccus'}",
				"Preliminary: Gram +ve bacillus;;$w{'Preliminary: Gram +ve bacillus'}",
				"Preliminary: Gram -ve coccus;;$w{'Preliminary: Gram -ve coccus'}",
				"Preliminary: Acid fast bacillus;;$w{'Preliminary: Acid fast bacillus'}",
				"Preliminary: Yeast;;$w{'Preliminary: Yeast'}",
				"Preliminary: Multiple;;$w{'Preliminary: Multiple'}",
				"Preliminary: Other;;$w{'Preliminary: Other'}",
				"Preliminary: Culture negative;;$w{'Preliminary: Culture negative'}",
				"Final: (Gram +ve) Corynebacteria species;;$w{'Final: (Gram +ve) Corynebacteria species'}",
				"Final: (Gram +ve) Clostridium species;;$w{'Final: (Gram +ve) Clostridium species'}",
				"Final: (Gram +ve) Diptheroids;;$w{'Final: (Gram +ve) Diptheroids'}",
				"Final: (Gram +ve) Enterococcus species;;$w{'Final: (Gram +ve) Enterococcus species'}",
				"Final: (Gram +ve) Propionibacterium;;$w{'Final: (Gram +ve) Propionibacterium'}",
				"Final: (Gram +ve) Lactobacillus;;$w{'Final: (Gram +ve) Lactobacillus'}",
				"Final: (Gram +ve) Staphylococcus aureus (sensitivity unknown);;$w{'Final: (Gram +ve) Staphylococcus aureus (sensitivity unknown)'}",
				"Final: (Gram +ve) Staphylococcus aureus (MSSA);;$w{'Final: (Gram +ve) Staphylococcus aureus (MSSA)'}",
				"Final: (Gram +ve) Staphylococcus aureus (MRSA);;$w{'Final: (Gram +ve) Staphylococcus aureus (MRSA)'}",
				"Final: (Gram +ve) Staphylococcus epidermidis;;$w{'Final: (Gram +ve) Staphylococcus epidermidis'}",
				"Final: (Gram +ve) Staphylococcus species;;$w{'Final: (Gram +ve) Staphylococcus species'}",
				"Final: (Gram +ve) Staphylococcus species, coagulase negative;;$w{'Final: (Gram +ve) Staphylococcus species, coagulase negative'}",
				"Final: (Gram +ve) Streptococcus species;;$w{'Final: (Gram +ve) Streptococcus species'}",
				"Final: (Gram +ve) Gram positive organisms, other;;$w{'Final: (Gram +ve) Gram positive organisms, other'}",
				"Final: (Gram -ve) Acinetobacter species;;$w{'Final: (Gram -ve) Acinetobacter species'}",
				"Final: (Gram -ve) Citrobacter species;;$w{'Final: (Gram -ve) Citrobacter species'}",
				"Final: (Gram -ve) Enterobacter species;;$w{'Final: (Gram -ve) Enterobacter species'}",
				"Final: (Gram -ve) Escherichia coli;;$w{'Final: (Gram -ve) Escherichia coli'}",
				"Final: (Gram -ve) Klebsiella species;;$w{'Final: (Gram -ve) Klebsiella species'}",
				"Final: (Gram -ve) Neisseria species;;$w{'Final: (Gram -ve) Neisseria species'}",
				"Final: (Gram -ve) Proteus mirabilis;;$w{'Final: (Gram -ve) Proteus mirabilis'}",
				"Final: (Gram -ve) Pseudomonas species;;$w{'Final: (Gram -ve) Pseudomonas species'}",
				"Final: (Gram -ve) Serratia marcescens;;$w{'Final: (Gram -ve) Serratia marcescens'}",
				"Final: (Gram -ve) Gram negative organisms, other;;$w{'Final: (Gram -ve) Gram negative organisms, other'}",
				"Final: Mycobacterium tuberculosis;;$w{'Final: Mycobacterium tuberculosis'}",
				"Final: (Yeast) Candida species;;$w{'Final: (Yeast) Candida species'}",
				"Final: (Yeast) Other species;;$w{'Final: (Yeast) Other species'}",
				"Final: Anaerobes;;$w{'Final: Anaerobes'}",
				"Final: Multiple;;$w{'Final: Multiple'}",
				"Final: Other;;$w{'Final: Other'}",
				"Final: Culture negative;;$w{'Final: Culture negative'}");
			$form_labs_pathogen_matrix .= qq{
				<tr>
					<td class="tl" colspan="2">
						<select name="form_labs_pathogen_$number" id="form_labs_pathogen_$number" class="w100p" onchange="set_pathogens('$number');">
							$form_labs_pathogen_options
						</select>
						<div id="form_labs_pathogen_$number\_other_div" class="hide">
							<div class="p5to p10bo">
                <div class="float-l b p5ro">$w{'Specify'}</div>
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
        	qq{$p{'form_labs_type'};;$w{$p{'form_labs_type'}}},
			"Peritoneal dialysis fluid;;$w{'Peritoneal dialysis fluid'}",
			"Swab of exit site;;$w{'Swab of exit site'}",
			"Blood culture;;$w{'Blood culture'}");
		$case_type = $w{$case_type};
		$case_infection_type = $w{$case_infection_type};
		$case_outcome = $w{$case_outcome};
		return qq{
			$close_button
			<h2><img src="$local_settings{"path_htdocs"}/images/img_culture.png" alt='' /> $title</h2>
			$msgs
			<form name="form_labs" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
				<input type="hidden" name="token" value="$token"/>
				$triggers
				<div class="float-l w50p">
					<div class="pl0ro">
						<div>
							<div class="b p5bo">$w{'Case information'}</div>
							<table class="w100p">
								<tbody>
									<tr>
										<td class="tl w100 gt">$w{'Patient name'}</td>
										<td class="tl">$name_last, $name_first</td>
									</tr><tr>
										<td class="tl w100 gt">$w{'PHN'}</td>
										<td class="tl">$phn</td>
									</tr><tr>
										<td class="tl w100 gt">$w{'Case&nbsp;details'}</td>
										<td class="tl">
											$w{'Opened'}: <span class="b">$case_created</span>
											<br/>$w{'Case type'}: <span class="b">$case_type</span>
											<br/>$w{'Infection'}: <span class="b">$case_infection_type</span>
											<br/>$w{'Current status'}: <span class="b">$case_outcome</span>
										</td>
									</tr>
								</tbody>
							</table>
							<div class="p50to">
								<div class="tron" onclick="document.form_labs.submit(); clear_date_picker();">$w{'save changes and return'}</div>
            					<div class="p30lo p10to gt"> $w{'or'} <a href="ajax.pl?token=$token&do=edit_case_form&amp;case_id=$ok_case" target="$hbin_target" onclick="clear_date_picker();">$w{'discard changes and return'}</a></div>
							</div>
						</div>
					</div>
				</div>
				<div class="float-l w50p">
					<div class="p10lo">
						<div>
							<div class="b p5bo">$w{'Culture details'}</div>
							<table class="w100p">
								<tbody>
									<tr>
										<td class="tl w100 gt">$w{'Date ordered'}</td>
										<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_labs_ordered" value="$p{"form_labs_ordered"}"  onclick="displayDatePicker('form_labs_ordered');" /></div></td>
									</tr><tr>
										<td class="tl gt">$w{'Sample type'}</td>
										<td class="tl p5bo"><select name="form_labs_type" class="w100p">
											$form_labs_type_options
										</select></td>
									</tr><tr>
										<td class="tl gt">$w{'Comments'} $comment_icon</td>
										<td class="tl"><div class="itt w100p"><textarea class="itt" name="form_labs_comments" rows="5">$p{"form_labs_comments"}</textarea></div></td>
									</tr><tr>
										<td class="tl gt">$w{'Last updated'}</td>
										<td class="tl">$time_modified</td>
									</tr><tr>
										<td class="tl" colspan="2"><div class="b p10to p5bo">$w{'Culture results'}</div></td>
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
	my ($msgs, $title, $print_page, $triggers, $name_first, $name_last, $phn, $weight, $case_type, $case_infection_type, $case_outcome, $case_created, $patient_id, $delete_button);
	$msgs .= qq{<div class="emp">$p{'message_error'}</div>} if ($p{'message_error'} ne '');
	$msgs .= qq{<div class="suc">$p{'message_success'}</div>} if ($p{'message_success'} ne '');
	my $ok_abx = &fast(qq{SELECT entry FROM rc_antibiotics WHERE entry="$p{"abx_id"}"});
	my $ok_case;
	if ($ok_abx eq '') {
		$ok_case = &fast(qq{SELECT entry FROM rc_cases WHERE entry="$p{"case_id"}"});
		if ($ok_case eq '') {
			my $cases;
			my @cases = &querymr(qq{SELECT rc_cases.entry, rc_cases.patient, rc_cases.case_type, rc_cases.outcome, rc_cases.created, rc_cases.modified, rc_patients.name_first, rc_patients.name_last, rc_patients.phn FROM rc_cases, rc_patients WHERE rc_cases.patient=rc_patients.entry ORDER BY rc_patients.name_last ASC, rc_patients.name_first ASC, rc_cases.outcome ASC, rc_cases.modified DESC});
			foreach my $c (@cases) {
				my $infection_type = &get_infection_type(@$c[0]);
				my $last_updated = &nice_time_interval(@$c[5]);
				my $case_status = ucfirst @$c[3];
				my $case_type = ucfirst @$c[2];
				$cases .= qq{
					<tr>
						<td class="pfmb_l">$case_status</td>
						<td class="pfmb_l"><a href="ajax.pl?token=$token&do=edit_patient_form&amp;patient_id=@$c[1]" target="$hbin_target">@$c[6] @$c[7]</a></td>
						<td class="pfmb_l">@$c[8]</td>
						<td class="pfmb_l">$case_type</td>
						<td class="pfmb_l">$infection_type</td>
						<td class="pfmb_l">$last_updated</td>
                    <td class="pfmb_l"><a href="ajax.pl?token=$token&do=add_antibiotic_form&amp;case_id=@$c[0]" target="$hbin_target" class="b">$w{'Add antibiotic treatment'}</a></td>
					</tr>
				};
			}
			$cases = qq{<tr><td class="pfmb_l gt" colspan="7">$w{'No cases found'}.</td></tr>} if ($cases eq '');
			return qq{
				$close_button
				<h2>Add antibiotic treatment</h2>
				$msgs
				<div class="b">$w{'Please select a case from the list below or'} <a href="ajax.pl?token=$token&do=add_case_form" target="$hbin_target">$w{'enter a new case'}</a>. $w{'If the patient is not in this system, please'} <a href="ajax.pl?token=$token&do=add_patient_form" target="$hbin_target">$w{'enter the patient'}</a> $w{'first before proceeding to enter a new case or adding a lab test requisition or antibiotic treatment to that case'}.</div>
				<div class="p10to">
					<div class="max400">
						<table class="pfmt w100p">
							<tbody>
								<tr>
									<td class="pfmb_l b bg-dbp">$w{'Case status'}</td>
									<td class="pfmb_l b bg-dbp">$w{'Patient name'}</td>
									<td class="pfmb_l b bg-dbp">$w{'PHN'}</td>
									<td class="pfmb_l b bg-dbp">$w{'Case type'}</td>
									<td class="pfmb_l b bg-dbp">$w{'Infection type'}</td>
									<td class="pfmb_l b bg-dbp">$w{'Case updated'}</td>
									<td class="pfmb_l b bg-dbp">&nbsp;</td>
								</tr>
								$cases
							</tbody>
						</table>
					</div>
				</div>
			};
		} else {
			$title = $w{'Add antibiotic treatment'};
			$triggers = qq{
				<input type="hidden" name="do" value="add_antibiotic_save"/>
				<input type="hidden" name="case_id" value="$ok_case"/>
			};
			$print_page = 1;
		}
	} else {
		$title = $w{'Antibiotic treatment'};
		$triggers = qq{
			<input type="hidden" name="do" value="edit_antibiotic_save"/>
			<input type="hidden" name="abx_id" value="$ok_abx"/>
		};
		$print_page = 1;
		my %h = &queryh(qq{SELECT * FROM rc_antibiotics WHERE entry="$ok_abx"});
		foreach my $key (keys %h) {
			$p{"form_abx_$key"} = $h{"$key"};
		}
		$ok_case = &fast(qq{SELECT case_id FROM rc_antibiotics WHERE entry="$ok_abx"});
		$delete_button = qq{<div class="tr"><a href="ajax.pl?token=$token&do=delete_abx_confirm&abx_id=$ok_abx" target="$hbin_target" class=''>$w{'Delete antibiotic treatment'}</a></div>};
	}
	if ($print_page == 1) {
		$print_page = 1;
		($patient_id, $name_first, $name_last, $phn, $weight, $case_type, $case_outcome, $case_created) = &query(qq{SELECT rc_patients.entry, rc_patients.name_first, rc_patients.name_last, rc_patients.phn, rc_patients.weight, rc_cases.case_type, rc_cases.outcome, rc_cases.created FROM rc_cases, rc_patients WHERE rc_cases.entry="$ok_case" AND rc_cases.patient=rc_patients.entry});
		my $weight_label = $w{'not tracked'};
		if ($weight > 0) {
			$weight_label = qq{&nbsp;kg};
		}
		$case_infection_type = &get_infection_type($ok_case);
		$case_created = &nice_time($case_created);
		my @labs = &querymr(qq{SELECT pathogen_1, pathogen_2, pathogen_3, pathogen_4 FROM rc_labs WHERE case_id="$ok_case"});
		my $rp;
		foreach my $germs (@labs) {
			foreach my $germ (@$germs) {
				if ($germ) {
                    $germ = $w{$germ} if $w{$germ};
					$rp .= qq{$germ<br/>};
				}
			}
		}
    $rp = qq{<span class="gt">($w{'none reported'})</span>} if $rp eq '';
		my $time_ordered = $p{"form_abx_ordered"};
		my $time_modified = $p{"form_abx_modified"};
		if ($time_ordered ne '') {
			$time_ordered = &nice_time($time_ordered);
		} else {
			$time_ordered = $w{'Right now'};
		}
		if ($time_modified ne '') {
			$time_modified = &nice_time($time_modified);
		} else {
			$time_modified = $w{'Right now'};
		}
		$p{"form_abx_date_start"} = &fast(qq{SELECT CURDATE()}) if $p{"form_abx_date_start"} eq '';
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
		if ($p{"form_abx_dose_amount_units"} eq '') {
			$p{"form_abx_dose_amount_units"} = "g";
		}
    $form_abx_basis_display = qq{<input type="checkbox" name="form_abx_basis_empiric" id="form_abx_basis_empiric" value='1' $p{"form_abx_basis_empiric"}/><label for="form_abx_basis_empiric"> $w{'empiric'} &nbsp;</label> <input type="checkbox" name="form_abx_basis_final" id="form_abx_basis_final" value='1' $p{"form_abx_basis_final"}/><label for="form_abx_basis_final"> $w{'final'} &nbsp;</label>};
		my @abx_selection = (
			"Ampicillin",
			"Cefazolin",
			"Ceftazidime",
			"Ceftriaxone",
			"Cephalexin",
			"Ciprofloxacin",
			"Fluconazole",
			"Gentamicin",
			"Meropenem",
			"Mycafungin",
			"Rifampin",
			"Tobramycin",
			"Trimethoprim Sulfamethoxazole",
			"Vancomycin",
			"Other;;$w{'Other'}");
		my $abx_loading;
		foreach my $abx (@abx_selection) {
			my $l = 0;
			if (&fast(qq{SELECT entry FROM rc_antibiotics WHERE case_id="$ok_case" AND antibiotic="$abx" AND regimen_duration='1' LIMIT 1}) ne '') {
				$abx_loading .= qq{<div class="hide" id="loading_dose_$abx">1</div>};
			} else {
				$abx_loading .= qq{<div class="hide" id="loading_dose_$abx">0</div>};
			}
		}
		my $form_abx_antibiotic_options = &build_select(
			$p{"form_abx_antibiotic"},
			";;($w{'select an antibiotic'})",
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
    		qq{$p{"form_abx_route"};;$w{$p{"form_abx_route"}}},
			"IP;;$w{'IP'}",
			"PO;;$w{'PO'}",
			"IV;;$w{'IV'}",
			"IM;;$w{'IM'}",
			"Topical;;$w{'Topical'}",
			"Intranasal;;$w{'Intranasal'}",
			"Intratunnel;;$w{'Intratunnel'}");
		my $form_abx_regimen_duration_options = &build_select(
    		qq{$p{'form_abx_regimen_duration'};;$p{'form_abx_regimen_duration'} $w{'days'}},
			"1;;1 $w{'day'}",
			"2;;2 $w{'days'}",
			"3;;3 $w{'days'}",
			"4;;4 $w{'days'}",
			"5;;5 $w{'days'}",
			"6;;6 $w{'days'}",
			"7;;7 $w{'days'}",
			"8;;8 $w{'days'}",
			"9;;9 $w{'days'}",
			"10;;10 $w{'days'}",
			"11;;11 $w{'days'}",
			"12;;12 $w{'days'}",
			"13;;13 $w{'days'}",
			"14;;14 $w{'days'}",
			"15;;15 $w{'days'}",
			"21;;21 $w{'days'}",
			"28;;28 $w{'days'}");
		my $capd = &fast(qq{SELECT dialysis_type FROM rc_patients WHERE entry="$patient_id"});
		if ($capd eq "CAPD") {
			$capd = '1';
		} else {
			$capd = "0";
		}
		$case_type = $w{$case_type} if $w{$case_type};
		$case_infection_type = $w{$case_infection_type} if $w{$case_infection_type};
		$case_outcome = $w{$case_outcome} if $w{$case_outcome};
		return qq{
			$close_button
			<h2><img src="$local_settings{"path_htdocs"}/images/img_antibiotics.png" alt='' /> $title</h2>
			$msgs
			<form name="form_abx" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
				<input type="hidden" name="token" value="$token"/>
				<input type="hidden" name="case_id" value="$ok_case"/>
				<div class="hide" id="is_capd">$capd</div>
				$triggers
				<div class="float-l w50p">
					<div class="p10ro">
						<div>
							<div class="b p5bo">$w{'Case information'}</div>
							<table>
								<tbody>
									<tr>
										<td class="tl gt p20ro">$w{'Patient&nbsp;name'}</td>
										<td class="tl">$name_first $name_last</td>
									</tr><tr>
										<td class="tl gt p20ro">$w{'PHN'}</td>
										<td class="tl">$phn</td>
									</tr><tr>
										<td class="tl gt p20ro">$w{'Weight'}</td>
										<td class="tl"><div class="float-l" id="form_abx_weight">$weight</div>$weight_label</td>
									</tr><tr>
										<td class="tl gt p20ro">$w{'Case&nbsp;details'}</td>
										<td class="tl">
											<div><span class="gt">$w{'Onset'}:</span> <span class="b">$case_created</span></div>
											<div><span class="gt">$w{'Case type'}:</span> <span class="b">$case_type</span></div>
											<div><span class="gt">$w{'Infection'}:</span> <span class="b">$case_infection_type</span></div>
											<div><span class="gt">$w{'Current status'}:</span> <span class="b">$case_outcome</span></div>
										</td>
									</tr><tr>
										<td class="tl gt p20ro">$w{'Pathogens'}</td>
										<td class="tl">$rp</td>
									</tr>
								</tbody>
							</table>
							<div class="p50to">
								<div class="tron" onclick="document.form_abx.submit(); clear_date_picker();">$w{'save changes and return'}</div>
            					<div class="p30lo p10to gt"> $w{'or'} <a href="ajax.pl?token=$token&do=edit_case_form&amp;case_id=$ok_case" target="$hbin_target" onclick="clear_date_picker();">$w{'discard changes and return'}</a></div>
							</div>
						</div>
					</div>
				</div>
				<div class="float-l w50p">
					<div class="p10lo">
						<div>
            <div class="b p5bo">$w{'Treatment'}</div>
							<table class="w100p">
								<tbody>
									<tr>
            <td class="tl w100 gt">$w{'Antibiotic'}</td>
										<td class="tl">
											<select name="form_abx_antibiotic" class="w100p" id="form_abx_antibiotic" onchange="set_antibiotics();">
												$form_abx_antibiotic_options
											</select>
											<div id="form_abx_antibiotic_other_div" class="hide">
												<div class="p5to">
            <div class="float-l b p5ro">$w{'Specify'}</div>
													<div class="float-l">
														<div class="itt w200"><input type="text" name="form_abx_antibiotic_other" id="form_abx_antibiotic_other" class="itt"></div>
													</div>
													<div class="clear-l"></div>
												</div>
											</div>
										</td>
									</tr><tr>
            <td class="tl gt">$w{'Basis'}</td>
										<td class="tl">$form_abx_basis_display</td>
									</tr><tr>
            <td class="tl gt">$w{'Loading dose'}</td>
										<td class="tl"><div class="float-l"><div class="itt w40"><input type="text" class="itt" name="form_abx_dose_amount_loading" id="form_abx_dose_amount_loading" value="$p{"form_abx_dose_amount_loading"}"/></div></div> &nbsp;
											<select name="form_abx_dose_amount_units" id="form_abx_dose_amount_units" onchange="set_dose_units();">
												$form_abx_dose_amount_units_options
											</select> </td>
									</tr><tr>
            <td class="tl gt">$w{'Dose and route'}</td>
										<td class="tl">
											<div class="float-l"><div class="itt w40"><input type="text" class="itt" name="form_abx_dose_amount" id="form_abx_dose_amount" value="$p{"form_abx_dose_amount"}"/></div></div> &nbsp; <span class='' id="form_abx_dose_label">$p{"form_abx_dose_amount_units"}</span>
											<select name="form_abx_dose_frequency" id="form_abx_dose_frequency">
												$form_abx_dose_frequency_options
											</select> 
											<select name="form_abx_route" id="form_abx_route" class="w60">
												$form_abx_route_options
											</select>
											<div class="clear-l"></div>
										</td>
									</tr><tr>
            <td class="tl gt">$w{'Start date'}</td>
										<td class="tl">
											<div class="float-l">
												<div class="itt w80"><input type="text" class="itt" name="form_abx_date_start" id="form_abx_date_start" value="$p{"form_abx_date_start"}" onclick="displayDatePicker('form_abx_date_start');"/></div>
											</div>
            <div class="float-l p5lo p5ro gt">$w{'duration set to'}</div>
											<div class="float-l">
												<select name="form_abx_regimen_duration" id="form_abx_regimen_duration" onchange="set_duration()" class="w80">
												$form_abx_regimen_duration_options
												</select>
												$abx_loading
												<div class="hide" id="form_abx_regimen_token">$token</div>
											</div>
										</td>
									</tr><tr>
            <td class="tl gt">$w{'Stop date'}</td>
										<td class="tl"><div class="itt w80"><input type="text" class="itt" name="form_abx_date_stopped" id="form_abx_date_stopped" value="$p{"form_abx_date_stopped"}" onclick="displayDatePicker('form_abx_date_stopped');"/></div><div id="url_test"></div></td>
									</tr><tr>
            <td class="tl gt">$w{'Comments'} $comment_icon</td>
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
	my @data;
	my $triggers = qq{<input type="hidden" name="do" value="add_patient_save"/>};
	my $pnam = $w{'New patient'};
	my $msgs;
	if ($p{'message_error'} ne '') {
		$msgs .= qq{<div class="emp">$p{'message_error'}</div>};
	}
	if ($p{'message_success'} ne '') {
		$msgs .= qq{<div class="suc">$p{'message_success'}</div>};
	}
	my $add_catheter_link;
	my $add_dialysis_link;
	my $catheter_information;
	my $dialysis_information;
	$p{'patient_id'} = &fast(qq{SELECT entry FROM rc_patients WHERE entry="$p{'patient_id'}"});
	if (($p{'patient_id'} ne '') and (($p{'do'} eq "edit_patient_form") or ($p{'do'} eq "edit_patient_save"))) {
		my %h = &queryh(qq{SELECT * FROM rc_patients WHERE entry="$p{'patient_id'}"});
		$triggers = qq{
			<input type="hidden" name="patient_id" value="$p{'patient_id'}"/>
			<input type="hidden" name="do" value="edit_patient_save"/>
		};
		$pnam = qq{$h{'name_last'}, $h{'name_first'}};
		foreach my $key (keys %h) {
			$p{"form_patients_$key"} = $h{"$key"};
		}
		$catheter_information = qq{<h4>$w{'Catheter information'}</h4>};
		$dialysis_information = qq{<h4>$w{'Dialysis information'}</h4>};
		$add_catheter_link = qq{<div class="p5to p20bo"><img src="$local_settings{"path_htdocs"}/images/add.gif" alt=''/><a target="$hbin_target" href="ajax.pl?token=$token&do=add_catheter_form&patient_id=$p{'patient_id'}">$w{'Add catheter information'}</a></div>};
		$add_dialysis_link = qq{<div class="p5to p20bo"><img src="$local_settings{"path_htdocs"}/images/add.gif" alt=''/><a target="$hbin_target" href="ajax.pl?token=$token&do=add_dialysis_form&patient_id=$p{'patient_id'}">$w{'Add peritoneal dialysis information'}</a></div>};
		my @catheter_information = &querymr(qq{SELECT entry, type, insertion_date, removal_date FROM rc_catheters WHERE patient_id="$p{'patient_id'}"});
		foreach my $catheter (@catheter_information) {
			my $catheter_id = @$catheter[0];
			my $catheter_type = @$catheter[1];
			my $catheter_insertion_date = @$catheter[2];
			my $catheter_removal_date = @$catheter[3];
			my $insertion_removal_information;
			if ($catheter_insertion_date ne '') {
				$catheter_insertion_date = &nice_date($catheter_insertion_date);
				$insertion_removal_information .= qq{$w{'inserted on'} $catheter_insertion_date};
			}
			if ($catheter_removal_date ne '') {
				$catheter_removal_date = &nice_date($catheter_removal_date);
				if ($insertion_removal_information ne '') {
					$insertion_removal_information .= qq{, $w{'removed on'} $catheter_removal_date};
				} else {
					$insertion_removal_information .= qq{$w{'removed on'} $catheter_removal_date};
				}
			}
			$catheter_information .= qq{
				<div>
					<div class="p5 bg-vlg">
						<div class="float-r"><a href="ajax.pl?token=$token&do=edit_catheter_form&catheter_id=$catheter_id" target="$hbin_target" class="b">$w{'change'}</a></div>
						<div><span class="b">$catheter_type catheter</span> <span class="gt">$insertion_removal_information</span></div>
					</div>
				</div>};
		}
		my @dialysis_information = &querymr(qq{SELECT entry, center, type, start_date, stop_date FROM rc_dialysis WHERE patient_id="$p{'patient_id'}"});
		foreach my $dialysis (@dialysis_information) {
			my $dialysis_id = @$dialysis[0];
			my $dialysis_center = @$dialysis[1];
			my $dialysis_type = @$dialysis[2];
			my $dialysis_start_date = @$dialysis[3];
			my $dialysis_stop_date = @$dialysis[4];
			my $start_stop_information;
			if ($dialysis_start_date ne '') {
				$dialysis_start_date = &nice_date($dialysis_start_date);
				$start_stop_information .= qq{started on $dialysis_start_date};
			}
			if ($dialysis_stop_date ne '') {
				$dialysis_stop_date = &nice_date($dialysis_stop_date);
				if ($start_stop_information ne '') {
					$start_stop_information .= qq{, stopped on $dialysis_stop_date};
				} else {
					$start_stop_information .= qq{stopped on $dialysis_stop_date};
				}
			}
			$dialysis_information .= qq{
				<div>
					<div class="p5 bg-vlg">
						<div class="float-r"><a href="ajax.pl?token=$token&do=edit_dialysis_form&dialysis_id=$dialysis_id" target="$hbin_target" class="b">$w{'change'}</a></div>
                <div><span class="b">$dialysis_type $w{'at'} $dialysis_center</span> <span class="gt">$start_stop_information</span></div>
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
	my $select_options_nephrologists = qq{<option value=''>($w{'none'})</option>};
	my $select_options_pd_nurses = qq{<option value=''>($w{'none'})</option>};
	my $select_options_surgeons = qq{<option value=''>($w{'none'})</option>};
	my @usrs = &querymr(qq{SELECT entry, name_first, name_last, role FROM rc_users ORDER BY name_last ASC, name_first ASC});
	foreach my $d (@usrs) {
		my ($users_entry, $users_name_first, $users_name_last, $users_role) = @$d;
		my ($selected_surgeon, $selected_nephrologist, $selected_pd_nurse);
		my $name = "$users_name_first $users_name_last";
		if ($users_role eq "Nephrologist") {
			$name = "Dr. $name";
			if ($p{"form_patients_nephrologist"} eq $users_entry) {
				$selected_nephrologist = qq{selected="selected"};
			}
			if ($p{"form_patients_surgeon"} eq $users_entry) {
				$selected_surgeon = qq{selected="selected"};
			}
			$select_options_nephrologists .= qq{<option value="$users_entry" $selected_nephrologist>$name</option>};
			$select_options_surgeons .= qq{<option value="$users_entry" $selected_surgeon>$name</option>};
		} elsif ($users_role =~ /Nurse/) {
			if ($p{"form_patients_primary_nurse"} eq $users_entry) {
				$selected_pd_nurse = qq{selected="selected"};
			}
			$select_options_pd_nurses .= qq{<option value="$users_entry" $selected_pd_nurse>$name</option>};
		}
	}
	my $form_patients_gender_options = &build_select(
    qq{$p{"form_patients_gender"};;$w{$p{"form_patients_gender"}}},
		"Female;;$w{'Female'}",
		"Male;;$w{'Male'}");
	my $form_patients_dialysis_center_options = &build_select(
		$p{"form_patients_dialysis_center"},
		"ARH",
		"RCH");
	my $form_patients_dialysis_type_options = &build_select(
		$p{"form_patients_dialysis_type"},
		"CAPD",
		"CCPD");
	my $form_patients_catheter_insertion_location_options = &build_select(
    qq{$p{"form_patients_catheter_insertion_location"};;$w{$p{"form_patients_catheter_insertion_location"}}},
		"Bedside;;$w{'Bedside'}",
		"Operating room;;$w{'Operating room'}");
	my $form_patients_catheter_insertion_method_options = &build_select(
    qq{$p{"form_patients_catheter_insertion_method"};;$w{$p{"form_patients_catheter_insertion_method"}}},
		"Blind insertion;;$w{'Blind insertion'}",
		"Peritoneoscope;;$w{'Peritoneoscope'}",
		"Surgery;;$w{'Surgery'}",
		"Other;;$w{'Other'}");
	my $form_patients_catheter_type_options = &build_select(
    qq{$p{"form_patients_catheter_type"};;$w{$p{"form_patients_catheter_type"}}},
		"Curled;;$w{'Curled'}",
		"Presternal;;$w{'Presternal'}",
		"Straight;;$w{'Straight'}");
	if ($p{"form_patients_pd_start_date"} eq '') {
		$p{"form_patients_pd_start_date"} = &fast(qq{SELECT CURDATE()});
	}
	$p{"form_patients_disease_diabetes"} = &display_checkboxes($p{"form_patients_disease_diabetes"});
	$p{"form_patients_disease_cognitive"} = &display_checkboxes($p{"form_patients_disease_cognitive"});
	$p{"form_patients_disease_psychosocial"} = &display_checkboxes($p{"form_patients_disease_psychosocial"});
	return qq{
		$close_button
		<h2><img src="$local_settings{"path_htdocs"}/images/icon-user-small.png" alt=''/> $pnam</h2>
		$msgs
		<form name="form_patients" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
			<input type="hidden" name="token" value="$token"/>
		<div class="float-l w40p">
			<div class="p10ro">
				<div>
					<h4>$w{'Personal information'}</h4>
					<table class="w100p">
						<tbody>
							<tr>
								<td class="tl w110 gt">$w{'First name'} $required_io</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_name_first" value="$p{"form_patients_name_first"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">$w{'Last name'} $required_io</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_name_last" value="$p{"form_patients_name_last"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">$w{'PHN'} $required_io</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_phn" value="$p{"form_patients_phn"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">$w{'Phone (home)'}</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_phone_home" value="$p{"form_patients_phone_home"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">$w{'Phone (work)'}</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_phone_work" value="$p{"form_patients_phone_work"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">$w{'Phone (mobile)'}</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_phone_mobile" value="$p{"form_patients_phone_mobile"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">$w{'Email_uc'}</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_email" value="$p{"form_patients_email"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">&nbsp;</td>
								<td class="tl"><div class="p5bo"><input type="checkbox" name="form_patients_email_reminder" id="form_patients_email_reminder" value='1' $p{"form_patients_email_reminder"}/><label for="form_patients_email_reminder"> $w{'send reminders to this address'}</label></div></td>
							</tr><tr>
								<td class="tl w110 gt">$w{'Weight'} (kg)</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_weight" value="$p{"form_patients_weight"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">$w{'Date of birth'}</td>
								<td class="tl">
									<div class="itt w100p"><input type="text" class="itt" name="form_patients_date_of_birth" value="$p{"form_patients_date_of_birth"}" onclick="displayDatePicker('form_patients_date_of_birth');" placeholder="YYYY-MM-DD" /></div>
								</td>
							</tr><tr>
								<td class="tl w110 gt">$w{'Gender'}</td>
								<td class="tl">
									<select name="form_patients_gender" class="w100p">
										$form_patients_gender_options
									</select>
								</td>
							</tr>
						</tbody>
					</table>
					<div class="p15to"><h4>$w{'Medical history'}</h4></div>
					<table class="w100p">
						<tbody>
							<tr>
								<td class="tl w110 gt">$w{'Allergies'}</td>
								<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_patients_allergies" value="$p{"form_patients_allergies"}"/></div></td>
							</tr><tr>
								<td class="tl w110 gt">$w{'Co-morbidities'}</td>
								<td class="tl">
									<div class=''><input type="checkbox" name="form_patients_disease_diabetes" id="form_patients_disease_diabetes" value='1' $p{"form_patients_disease_diabetes"}/><label for="form_patients_disease_diabetes"> $w{'diabetes'}</label></div>
									<div class=''><input type="checkbox" name="form_patients_disease_cognitive" id="form_patients_disease_cognitive" value='1' $p{"form_patients_disease_cognitive"}/><label for="form_patients_disease_cognitive"> $w{'cognitive impairment'}</label></div>
									<div class=''><input type="checkbox" name="form_patients_disease_psychosocial" id="form_patients_disease_psychosocial" value='1' $p{"form_patients_disease_psychosocial"}/><label for="form_patients_disease_psychosocial"> $w{'psychosocial issues'}</label></div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>
		<div class="float-l w60p">
			<div class="p10lo">
				<div>
					$catheter_information
					$add_catheter_link
					$dialysis_information
					$add_dialysis_link
					<table class="w100p">
						<tbody>
							<tr>
								<td class="tl w130 gt">$w{'Primary nurse'} $required_io</td>
								<td class="tl">
									<select name="form_patients_primary_nurse" class="w100p">
										$select_options_pd_nurses
									</select>
								</td>
							</tr><tr>
								<td class="tl w110 gt">$w{'Nephrologist'} $required_io</td>
								<td class="tl p5bo">
									<select name="form_patients_nephrologist" class="w100p">
										$select_options_nephrologists
									</select>
								</td>
							</tr><tr>
								<td class="tl w110 gt">$w{'Comments'} $comment_icon</td>
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
				<input type="submit" value="$w{'Save changes'}" onclick="clear_date_picker();"/> 
			</div>
        <div class="gt">$required_io $w{'indicates required fields'}</div>
			<div class="clear-l"></div>
		</div>
		</form>
	};
}
sub view_account_settings() {
	my %p = %{$_[0]};
	my $is_administrator = &fast(qq{SELECT type FROM rc_users WHERE entry="$sid[2]"});
	my $target_is_administrator = &fast(qq{SELECT type FROM rc_users WHERE entry="$p{'uid'}"});
	my $triggers = qq{<input type="hidden" name="do" value="edit_account_settings"/>};
	my $title = $w{'Your account'};
	my $return;
	my @data;
	my $msgs;
	if (
			($p{'uid'} eq '') or 
			($p{'uid'} =~ /\D/) or 
			($sid[2] ne $p{'uid'} and $is_administrator ne "Administrator") or 
			($sid[2] ne $p{'uid'} and $target_is_administrator eq "Administrator")) {
				$p{'uid'} = $sid[2];
	}
	if ($p{'uid'} ne $sid[2]) {
		$title = $w{'Modify account'};
		$return = qq{<div class="p2to"><a href="ajax.pl?token=$token&do=edit_manage_users_form" target="$hbin_target" class="b">&laquo; $w{'return to manage users'}</a></div>};
	}
	if ($p{'message_error'} ne '') {
		$msgs .= qq{<div class="emp">$p{'message_error'}</div>};
	}
	if ($p{'message_success'} ne '') {
		$msgs .= qq{<div class="suc">$p{'message_success'}</div>};
	}
	my %h = &queryh(qq{SELECT * FROM rc_users WHERE entry="$p{'uid'}"});
	foreach my $key (keys %h) {
		$p{"form_users_$key"} = $h{"$key"};
	}
	$p{"form_users_created"} = &nice_time($p{"form_users_created"});
	$p{"form_users_modified"} = &nice_time($p{"form_users_modified"});
	$p{"form_users_opt_in"} = &display_checkboxes($p{"form_users_opt_in"});
	my $form_users_role_print = $p{"form_users_role"};
	my $form_users_lang_options = &build_select(
		$p{"form_users_lang"},
		"English",
		"Français",
		"Español");

	#if ($is_administrator eq "Administrator") {
		my $form_users_role_options = &build_select(
    		qq{$p{"form_users_role"};;$w{$p{"form_users_role"}}},
			"Clinical Pharmacist;;$w{'Clinical Pharmacist'}",
			"Nephrologist;;$w{'Nephrologist'}",
			"PD Nurse;;$w{'PD Nurse'}",
			"Surgeon;;$w{'Surgeon'}",
			"Transition Nurse;;$w{'Transition Nurse'}",
			"Other;;$w{'Other'}");
		$form_users_role_print = qq{
			<div><select name="form_users_role" class="w100p">
				$form_users_role_options
			</select></div>};
	#}

	my $form_users_home_centre_options = &build_select(
		qq{$p{"form_users_home_centre"};;$w{$p{"form_users_home_centre"}}},
		@local_settings_hospitals_for_new_starts);
	my $form_users_home_centre_print = qq{
		<div><select name="form_users_home_centre" class="w100p">
			$form_users_home_centre_options
		</select></div>};

	my $change_password;
	if ($sid[2] eq $p{'uid'}) {
		$change_password = qq{
			<div class="float-l w50p">
				<div class="p10to p10lo">
					<div>
						<form name="form_account_settings_password" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
							<input type="hidden" name="token" value="$token"/>
							<input type="hidden" name="do" value="edit_account_settings_save_password"/>
							<div class="b p5bo">$w{'Update password'}</div>
							<div class="gt sml p10bo">$w{'Please note that passwords are case sensitive'}.</div>
							<table class="w100p">
								<tbody>
									<tr>
										<td class="tl gt w120">$w{'Existing password'}</td>
										<td class="tl"><div class="itt w100p"><input type="password" class="itt" name="form_users_password_old" value=''/></div></td>
									</tr><tr>
										<td class="tl gt">$w{'New password'}</td>
										<td class="tl"><div class="itt w100p"><input type="password" class="itt" name="form_users_password" value=''/></div></td>
									</tr><tr>
										<td class="tl gt">$w{'Repeat password'}</td>
										<td class="tl p5bo"><div class="itt w100p"><input type="password" class="itt" name="form_users_password_repeat" value=''/></div></td>
									</tr><tr>
										<td class="tl gt">&nbsp;</td>
										<td class="tr">
											<input type="submit" value="$w{'Save changes'}" onclick="clear_date_picker();"/>
										</td>
								</tbody>
							</table>
						</form>
					</div>
				</div>
			</div>};
	}
	my $user_type_translated = $w{$p{"form_users_type"}};
	if ($user_type_translated eq '') {
		$user_type_translated = $p{"form_users_type"};
	}
	return qq{
		$close_button
		<h2><img src="$local_settings{"path_htdocs"}/images/img_ni_my_profile.gif" alt='' /> $title</h2>
		$msgs
		<div class="float-l w50p">
			<div class="p10ro">
				<div class="p10 bg-vlg">
					<div>
						<form name="form_account_settings_user_info" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
							<input type="hidden" name="token" value="$token"/>
							<input type="hidden" name="uid" value="$p{'uid'}"/>
							<input type="hidden" name="do" value="edit_account_settings_save_user_info"/>
							<div class="b p5bo">$w{'User information'}</div>
							<table class="w100p">
								<tbody>
									<tr>
										<td class="tl gt w100">$w{'First name'} $required_io</td>
										<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_users_name_first" value="$p{"form_users_name_first"}"/></div></td>
									</tr><tr>
										<td class="tl gt">$w{'Last name'} $required_io</td>
										<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_users_name_last" value="$p{"form_users_name_last"}"/></div></td>
									</tr><tr>
										<td class="tl gt">$w{'Email_uc'} $required_io</td>
										<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_users_email" value="$p{"form_users_email"}"/></div></td>
									</tr><tr>
										<td class="tl gt">$w{'Notifications'}</td>
										<td class="tl b">
											<input type="checkbox" name="form_users_opt_in" id="form_users_opt_in" value='1' $p{"form_users_opt_in"} /> 
											<label for="form_users_opt_in">$w{'cc this email when reminders are sent to patients'}</label>
										</td>
									</tr><tr>
										<td class="tl gt">$w{'Role'}</td>
										<td class="tl">$form_users_role_print</td>
									</tr><tr>
										<td class="tl gt">$w{'Home centre'}</td>
										<td class="tl">$form_users_home_centre_print</td>
									</tr><tr>
										<td class="tl gt">$w{'Account type'}</td>
										<td class="tl b">$p{"form_users_type"}</td>
									</tr><tr>
										<td class="tl gt">$w{'Created'}</td>
										<td class="tl">$p{"form_users_created"}</td>
									</tr><tr>
										<td class="tl gt">$w{'Modified'}</td>
										<td class="tl">$p{"form_users_modified"}</td>
									</tr><tr>
										<td class="tl" colspan="2">
											<div class="float-r"><input type="submit" value="$w{'Save changes'}" onclick="clear_date_picker();"/></div>
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
	my $msgs;
	if ($p{'message_error'} ne '') {
		$msgs .= qq{<div class="emp">$p{'message_error'}</div>};
	}
	if ($p{'message_success'} ne '') {
		$msgs .= qq{<div class="suc">$p{'message_success'}</div>};
	}
	my $check_administrator = &fast(qq{SELECT entry FROM rc_users WHERE entry="$sid[2]" AND type="Administrator"});
	if ($check_administrator ne '') {
		my @users = &querymr(qq{SELECT * FROM rc_users ORDER BY name_last ASC, name_first ASC, entry ASC});
		my $table;
		my $rc = "bg-vlg";
		foreach my $u (@users) {
			my ($user_entry, $user_type, $user_email, $user_password, $user_name_first, $user_name_last, $user_role, $user_deactivated, $user_opt_in, $user_created, $user_modified, $user_accessed, $user_home_centre) = @$u;
			my ($you, $tasks, $name_print);
			if ($user_entry eq $sid[2]) {
				$you = qq{&mdash;<span class="b">$w{'you'}</span>};
				$tasks .= qq{<a href="ajax.pl?token=$token&do=edit_account_settings_form" target="$hbin_target" class="b">$w{'account settings'}</a> &nbsp; };
			}
			if ($user_type eq "Administrator") {
				$name_print = qq{<span class="b">$user_name_last</span>, $user_name_first};
				$user_type = qq{<span class="b">($w{'admin'})</span>};
			} else {
				$name_print = qq{<a href="ajax.pl?token=$token&do=edit_account_settings_form&uid=$user_entry" target="$hbin_target"><span class="b">$user_name_last</span>, $user_name_first</a>};
				$tasks .= qq{<a href="ajax.pl?token=$token&do=make_administrator&uid=$user_entry" target="$hbin_target">$w{'make admin'}</a> &nbsp; };
				$user_type = '';
				
			}
			if ($user_deactivated == 0) {
				$user_deactivated = qq{<span class="txt-gre b">$w{'Active_uc'}</span>};
				unless ($user_type eq "Administrator" or $user_entry eq $sid[2]) {
					$tasks .= qq{<a href="ajax.pl?token=$token&do=deactivate&uid=$user_entry" target="$hbin_target">$w{'deactivate'}</a>};
				}
			} else {
				$user_deactivated = qq{<span class="txt-red b">$w{'deactivated'}</span>};
				$tasks .= qq{<a href="ajax.pl?token=$token&do=reactivate&uid=$user_entry" target="$hbin_target">$w{'reactivate'}</a>};
			}
			if ($tasks eq '') {
				$tasks = qq{<span class="gt">($w{'none'})</span>};
			}
			$user_role = $w{$user_role} if $w{$user_role} ne '';
			$table .= qq{
				<tr class="$rc">
					<td class="pfmb_l w180">$name_print  $you $user_type</td>
					<td class="pfmb_l w240">$user_email</td>
					<td class="pfmb_l w160">$user_role</td>
					<td class="pfmb_l w100">$user_deactivated</td>
					<td class="pfmb_l">$tasks</td>
				</tr>
			};			
			if ($rc eq '') {
				$rc = "bg-vlg";
			} else {
				$rc = '';
			}
		}
		return qq{
			$close_button
			<h2><img src="$local_settings{"path_htdocs"}/images/img_ni_my_profile.gif" alt='' /> $w{'manage users'}</h2>
			$msgs
			<table class="pfmt w100p">
				<tbody>
					<tr>
						<td class="pfmb_l b bg-dbp w180">$w{'Name'}</td>
						<td class="pfmb_l b bg-dbp w240">$w{'Email_uc'}</td>
						<td class="pfmb_l b bg-dbp w160">$w{'Role'}</td>
						<td class="pfmb_l b bg-dbp w100">$w{'Status'}</td>
						<td class="pfmb_l b bg-dbp">$w{'Tasks'}</td>
					</tr>
				</tbody>
			</table>
			<div style="max-height:400px; overflow:auto;">
				<table class="pfmt w100p">
					<tbody>
						$table
					</tbody>
				</table>
			</div>
			<div class="tr p5"><img src="$local_settings{"path_htdocs"}/images/add.gif" alt=''/><a class="b" target="$hbin_target" href="ajax.pl?token=$token&do=add_user_form">$w{'Add new user'}</a></div>
		};
	}
}
sub add_user_form() {
	my %p = %{$_[0]};
	my $msgs;
	if ($p{'message_error'} ne '') {
		$msgs .= qq{<div class="emp">$p{'message_error'}</div>};
	}
	if ($p{'message_success'} ne '') {
		$msgs .= qq{<div class="suc">$p{'message_success'}</div>};
	}
	$p{"form_new_user_type"} = "Regular" if $p{"form_new_user_type"} eq '';
	$p{"form_new_user_role"} = "PD Nurse" if $p{"form_new_user_role"} eq '';
	$p{"form_new_user_home_centre"} = "Royal Columbian Hospital" if $p{"form_new_user_home_centre"} eq '';
	$p{"form_new_user_password"} = lc substr(&encrypt(rand()),0,8) if $p{"form_new_user_password"} eq '';
	my $form_new_user_lang_options = &build_select(
		$lang,
		"English",
		"Français",
		"Español");
	my $form_new_user_type_options = &build_select(
    qq{$p{"form_new_user_type"};;$w{$p{"form_new_user_type"}}},
		"Regular;;$w{'Regular'}",
		"Administrator;;$w{'Administrator'}");
	my $form_new_user_role_options = &build_select(
    qq{$p{"form_new_user_role"};;$w{$p{"form_new_user_role"}}},
		"Nephrologist;;$w{'Nephrologist'}",
		"Transition Nurse;;$w{'Transition Nurse'}",
		"PD Nurse;;$w{'PD Nurse'}",
		"Surgeon;;$w{'Surgeon'}",
		"Other;;$w{'Other'}");
	my $form_new_user_home_centre_options = &build_select(
		qq{$p{"form_new_user_home_centre"};;$w{$p{"form_new_user_home_centre"}}},
		@local_settings_hospitals_for_new_starts);
	my $form_new_user_home_centre_print = qq{
		<div><select name="form_new_user_home_centre" class="w100p">
			$form_new_user_home_centre_options
		</select></div>};
	return qq{
		$close_button
		<h2><img src="$local_settings{"path_htdocs"}/images/img_ni_my_profile.gif" alt='' /> $w{'Add new user'}</h2>
		$msgs
		<form name="form_add_user" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
			<input type="hidden" name="token" value="$token"/>
			<input type="hidden" name="do" value="add_user_save"/>
			<div class="float-l w60p">
				<div class="p10ro">
					<div>
						<table class="w100p">
							<tbody>
								<tr>
									<td class="tl gt w100">$w{'First name'} $required_io</td>
									<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_new_user_name_first" value="$p{"form_new_user_name_first"}"/></div></td>
								</tr><tr>
									<td class="tl gt">$w{'Last name'} $required_io</td>
									<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_new_user_name_last" value="$p{"form_new_user_name_last"}"/></div></td>
								</tr><tr>
    								<td class="tl gt">$w{'Email_uc'} $required_io</td>
									<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_new_user_email" value="$p{"form_new_user_email"}"/></div></td>
								</tr><tr>
    								<td class="tl gt">$w{'Notifications'}</td>
									<td class="tl b"><input type="checkbox" name="form_new_user_opt_in" id="form_new_user_opt_in" value='1' checked /> 
    									<label for="form_new_user_opt_in">$w{'cc this email when reminders are sent to patients'}</label>
									</td>
								</tr><tr>
									<td class="tl gt">$w{'Password'} $required_io</td>
									<td class="tl"><div class="itt w100p"><input type="text" class="itt" name="form_new_user_password" value="$p{"form_new_user_password"}"/></div>
    									<div class="sml gt">$w{'Please provide a temporary password for this user'}.</div>
    								</td>
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
    								<td class="tl gt w100">$w{'User type'} $required_io</td>
									<td class="tl">
										<select name="form_new_user_type" class="w100p">
											$form_new_user_type_options
										</select>
									</td>
								</tr><tr>
    								<td class="tl gt">$w{'Role'} $required_io</td>
									<td class="tl">
										<select name="form_new_user_role" class="w100p">
											$form_new_user_role_options
										</select>
									</td>
								</tr><tr>
										<td class="tl gt">$w{'Home centre'}</td>
										<td class="tl">$form_new_user_home_centre_print</td>
								</tr><tr>
									<td class="tl gt">&nbsp;</td>
									<td class="tr p10to"><input type="submit" value="$w{'Save changes'}" onclick="clear_date_picker();"/> </td>
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
	$time = &clean_up_time($time);
	return $time;
}
sub get_alerts_dismissed() {
	my $uid = $sid[2];
	my @alerts = &querymr(qq{SELECT entry, alert_entry, alert_type, uid, pid, cid, lid, tid, show_after, archive_uid, archive_comment, archive_date FROM rc_alerts_archive WHERE uid IS NULL OR uid="$uid" ORDER BY archive_date DESC});
	my %alert_codes = (
        "5" => $w{'w_alert_code_5'},
		"10" => $w{'w_alert_code_10'},
		"15" => $w{'w_alert_code_15'},
		"20" => $w{'w_alert_code_20'},
		"30" => $w{'w_alert_code_30'},
		"90" => $w{'w_alert_code_90'},
		"110" => $w{'w_alert_code_110'},
		"120" => $w{'w_alert_code_120'},
		"200" => $w{'w_alert_code_200'},
		"210" => $w{'w_alert_code_210'},
        '220' => $w{'w_alert_code_else'}
	);
	my $output = $close_button . qq{<h2>$w{'Dismissed alerts'}</h2><div style="max-height:400px; overflow:auto;">};
	foreach my $a (@alerts) {
		my ($entry, $alert_entry, $alert_type, $uid, $pid, $cid, $lid, $tid, $show_after, $archive_uid, $archive_comment, $archive_date) = @$a;
		my $alert_text = $alert_codes{$alert_type};
		my $nice_time_interval = &nice_time_interval($archive_date);
		my $dismiss_by_text;
		my ($patient_name_first, $patient_name_last) = &query(qq{SELECT name_first, name_last FROM rc_patients WHERE entry="$pid" LIMIT 1});
		my $patient_information = qq{<a href="ajax.pl?token=$token&do=edit_patient_form&patient_id=$pid" target="$hbin_target" class="b">$patient_name_last, $patient_name_first</a>};
		if ($archive_uid ne '') {
			my ($name_first, $name_last) = &query(qq{SELECT name_first, name_last FROM rc_users WHERE entry="$archive_uid"});
			if ($archive_comment eq '') {
				$archive_comment = qq{($w{'none given'})};
			}
			if ($w{'lang'} eq 'fr') {
				$dismiss_by_text = qq{<div class="sml gt">Rejetée par <span class="b">$name_first $name_last</span> il y a $nice_time_interval. $w{'Reason_uc'}: &quot;$archive_comment&quot;</div>};
			} else {
				$dismiss_by_text = qq{<div class="sml gt">$w{'Dismissed'} $nice_time_interval $w{'by'} <span class="b">$name_first $name_last</span>. $w{'Reason_uc'}: &quot;$archive_comment&quot;</div>};
			}
		} else {
			if ($w{'lang'} eq 'fr') {
				$dismiss_by_text = qq{<div class="sml gt">Rejetée par le système $nice_time_interval</div>};
			} else {
				$dismiss_by_text = qq{<div class="sml gt">$w{'Dismissed'} $nice_time_interval $w{'by the system'}</div>};
			}
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
	my $uid = $sid[2];
	&generate_alerts();
	my @alerts = &querymr(qq{SELECT * FROM rc_alerts WHERE (uid="$uid" OR uid IS NULL) AND show_after < CURRENT_TIMESTAMP() ORDER BY alert_type ASC});
	my $output;
	foreach my $alert (@alerts) {
		my ($aid, $type, $uid, $pid, $cid, $lid, $tid, $show_after, $start_id) = @$alert;
		my ($name_first,$name_last) = &query(qq{SELECT name_first, name_last FROM rc_patients WHERE entry="$pid"});
		my $community = qq{<img src="$local_settings{"path_htdocs"}/images/img_community.gif" alt="$w{'Community alert'}" class="float-r"/>};
		my $do_thing = "do=edit_case_form&case_id=$cid";
		if ($start_id ne '') {
			$do_thing = "do=view_list&list_id=$start_id";
		}
		my $button = qq{
			<div class="show" id="alert_dismiss_box_$aid">
            	<a href="ajax.pl?token=$token&$do_thing" target="$hbin_target" class=''>$w{'attend'}</a> &nbsp;
            	<a href="$local_settings{"path_htdocs"}/images/blank.gif" target="$hbin_target" class='' onclick="dismiss_provide_reason('$aid');">$w{'dismiss'}</a>
			</div>
			<div class="hide" id="alert_dismiss_reason_box_$aid">
            <div class="p10to bt">$w{'Reason_uc'}</div>
				<form name="dismiss_form_for_$aid" id="dismiss_form_for_$aid" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
					<input type="hidden" name="token" value="$token"/>
					<input type="hidden" name="do" value="dismiss"/>
					<input type="hidden" name="aid" value="$aid"/>
					<div class="itt w100p"><textarea name="dismiss_reason" class="itt" rows="3"></textarea></div>
					<div class="p5to tr"><input type="submit" value="Dismiss"/> &nbsp; 
            		<a href="$local_settings{"path_htdocs"}/images/blank.gif" target="$hbin_target" class='' onclick="cancel_dismiss('$aid');">$w{'cancel'}</a></div>
				</form>
			</div>
			};
		if ($uid ne '') {
			$community = '';
			$button = qq{
			<div>
				<a href="ajax.pl?token=$token&$do_thing" target="$hbin_target" class=''>$w{'attend'}</a> &nbsp;
				<a href="ajax.pl?token=$token&do=dismiss&aid=$aid" target="$hbin_target" class=''>$w{'dismiss'}</a>
			</div>};
		}
		if ($type eq "5") {
			$output .= qq{
				<div class="emp">
					$community
					<div class="b">$name_first $name_last</div>
                	<div>$w{'w_alert_code_5'}</div>
					$button
				</div>};
		} elsif ($type eq "10") {
			$output .= qq{
				<div class="emp">
					$community
					<div class="b">$name_first $name_last</div>
                	<div>$w{'w_alert_code_10'}</div>
					$button
				</div>};
		} elsif ($type eq "15") {
			$output .= qq{
				<div class="emp">
					$community
					<div class="b">$name_first $name_last</div>
                	<div>$w{'w_alert_code_15'}</div>
					$button
				</div>};
		} elsif ($type eq "20") {
			$output .= qq{
				<div class="emp">
					$community
					<div class="b">$name_first $name_last</div>
                	<div>$w{'w_alert_code_20'}</div>
					$button
				</div>};
		} elsif ($type eq "30") {
			$output .= qq{
				<div class="emp">
					$community
					<div class="b">$name_first $name_last</div>
                	<div>$w{'w_alert_code_30'}</div>
					$button
				</div>};
		} elsif ($type eq "90") {
			$output .= qq{
				<div class="emp">
					$community
					<div class="b">$name_first $name_last</div>
                	<div>$w{'w_alert_code_90'}</div>
					$button
				</div>};
		} elsif ($type eq "110") {
			my $lab_created = &fast(qq{SELECT ordered FROM rc_labs WHERE entry="$lid"});
			my $lab_created_nice = &nice_time($lab_created);
			my $lab_created_interval = &nice_time_interval($lab_created);
			$output .= qq{
				<div class="emp">
					$community
					<div class="b">$name_first $name_last</div>
                <div>$w{'w_alert_code_110'} ($w{'requisition sent'} $lab_created_interval $w{'on'} $lab_created_nice)</div>
					$button
				</div>};
		} elsif ($type eq "120") {
			my $lab_updated = &fast(qq{SELECT ordered FROM rc_labs WHERE entry="$lid"});
			my $lab_updated_nice = &nice_time($lab_updated);
			my $lab_updated_interval = &nice_time_interval($lab_updated);
			$output .= qq{
				<div class="emp">
					$community
					<div class="b">$name_first $name_last</div>
                <div>$w{'w_alert_code_120'} ($w{'requisition sent'} $lab_updated_interval $w{'on'} $lab_updated_nice)</div>
					$button
				</div>};
		} elsif ($type eq "200") {
			my $lab_updated = &fast(qq{SELECT modified FROM rc_labs WHERE entry="$lid"});
			my $lab_updated_nice = &nice_time($lab_updated);
			my $lab_updated_interval = &nice_time_interval($lab_updated);
			$output .= qq{
				<div class="suc">
					$community
					<div class="b">$name_first $name_last</div>
                <div>$w{'w_alert_code_200'} $lab_updated_interval ($lab_updated_nice)</div>
					$button
				</div>};
		} elsif ($type eq "210") {
			my $lab_updated = &fast(qq{SELECT modified FROM rc_labs WHERE entry="$lid"});
			my $lab_updated_nice = &nice_time($lab_updated);
			my $lab_updated_interval = &nice_time_interval($lab_updated);
			$output .= qq{
				<div class="suc">
					$community
					<div class="b">$name_first $name_last</div>
                <div>$w{'w_alert_code_210'} $lab_updated_interval ($lab_updated_nice)</div>
					$button
				</div>};
		} elsif ($type eq "230" or $type eq "240" or $type eq "250") {
			my $alert_code = "w_alert_code_" . $type;
			$output .= qq{
				<div class="emp">
					$community
					<div class="b">$name_first $name_last</div>
                	<div>$w{$alert_code}</div>
					$button
				</div>};
		} else {
			$output .= qq{
				<div class="fph">
					$community
					<div class="b">$name_first $name_last</div>
                <div>$w{'w_alert_code_220'}</div>
					$button
				</div>};
		}
	}
	if ($output eq '') {
		$output = qq{<div class="fph">$w{'You have no alerts at this time.'}</div>};
	}
	return $output;
}
sub archive_and_delete_alerts() {
	my $query = shift;	
	my @entries = &query($query);
	foreach my $entry (@entries) {
		&archive_alert($entry);
		&input(qq{DELETE FROM rc_alerts WHERE entry="$entry"});
	}
}
sub archive_alert() {
	my ($alert_id, $archive_uid, $archive_comment) = @_;
	my $archive_alert_id = &input(qq{INSERT INTO rc_alerts_archive (alert_entry, alert_type, uid, pid, cid, lid, tid, show_after, sid) SELECT entry, alert_type, uid, pid, cid, lid, tid, show_after, sid FROM rc_alerts WHERE entry="$alert_id"});
	if ($archive_alert_id ne '') {
		&input(qq{UPDATE rc_alerts_archive SET archive_date = CURRENT_TIMESTAMP() WHERE entry="$archive_alert_id"});
		if ($archive_uid ne '') {
			&input(qq{UPDATE rc_alerts_archive SET archive_uid="$archive_uid" WHERE entry="$archive_alert_id"});
		}
		if ($archive_comment ne '') {
			&input(qq{UPDATE rc_alerts_archive SET archive_comment="$archive_comment" WHERE entry="$archive_alert_id"});
		}
	}
}
sub generate_alerts() {
	&archive_and_delete_alerts(qq{SELECT rc_alerts.entry FROM rc_alerts, rc_cases WHERE rc_alerts.cid=rc_cases.entry AND rc_cases.closed='1'});
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
	my @cases = &querymr(qq{SELECT entry, patient FROM rc_cases WHERE closed="0"});
	foreach my $case (@cases) {
		my ($cid, $pid) = @$case;
		my @abx = &querymr(qq{SELECT dose_amount, dose_amount_units FROM rc_antibiotics WHERE case_id="$cid" AND (antibiotic="Tobramycin" OR antibiotic="Gentamicin") AND date_end >= curdate() AND date_stopped >= curdate()});
		my $trigger = 0;
		my ($weight, $ccpd) = &query(qq{SELECT weight, dialysis_type FROM rc_patients WHERE entry="$pid"});
		my $target = 0.6;
		if ($ccpd eq "CCPD") {
			$target = 0.5;
		}
		foreach my $a (@abx) {
			my ($dose, $unit) = @$a;
			if ($dose ne '') {
				if ($unit ne "mg") {
					$dose = $dose * 1000;
				}
				if ($weight ne '') {
					my $total = $weight * $target + 10;
					if ($total < $dose) {
						$trigger = 1;
					}
				}
			}
		}
		if ($trigger == 1) {
			if (&fast(qq{SELECT entry FROM rc_alerts WHERE alert_type="5" AND cid="$cid"}) eq '') {
				&input(qq{INSERT INTO rc_alerts (alert_type, pid, cid) VALUES ("5", "$pid", "$cid")});
			}
		} else {
			&archive_and_delete_alerts(qq{SELECT entry FROM rc_alerts WHERE alert_type="5" AND cid="$cid"});
		}
	}
}
sub generate_alerts_10_vancomycin_underdose() {
	my $uid = $sid[2];
	my @cases = &querymr(qq{SELECT entry, patient FROM rc_cases WHERE closed="0"});
	foreach my $case (@cases) {
		my ($cid, $pid) = @$case;
		my @abx = &querymr(qq{SELECT dose_amount, dose_amount_units FROM rc_antibiotics WHERE case_id="$cid" AND antibiotic="Vancomycin" AND (route <> "IV" OR route IS NULL) AND date_end >= curdate() AND date_stopped >= curdate()});
		my $trigger = 0;
		if ($abx[0] ne '') {
			my $ton = &fast(qq{SELECT weight FROM rc_patients WHERE entry="$pid"});
			if ($ton ne '') {
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
			if (&fast(qq{SELECT entry FROM rc_alerts WHERE alert_type="10" AND cid="$cid"}) eq '') {
				&input(qq{INSERT INTO rc_alerts (alert_type, pid, cid) VALUES ("10","$pid","$cid")});
			}
		} else {
			&archive_and_delete_alerts(qq{SELECT entry FROM rc_alerts WHERE alert_type="10" AND cid="$cid"});
		}
	}
}
sub generate_alerts_15_on_fluconazole_hold_statins() {
	my $uid = $sid[2];
	my @cases = &querymr(qq{SELECT entry, patient FROM rc_cases WHERE closed="0"});
	foreach my $case (@cases) {
		my ($cid, $pid) = @$case;
		my $aid = &fast(qq{SELECT entry FROM rc_antibiotics WHERE case_id="$cid" AND antibiotic="Fluconazole" AND date_end >= curdate() AND date_stopped >= curdate() LIMIT 1});
		if ($aid ne '') {
			if (&fast(qq{SELECT entry FROM rc_alerts WHERE alert_type="15" AND cid="$cid"}) eq '') {
				&input(qq{INSERT INTO rc_alerts (alert_type, pid, cid) VALUES ("15","$pid","$cid")});
			}
		} else {
			&archive_and_delete_alerts(qq{SELECT entry FROM rc_alerts WHERE alert_type="15" AND cid="$cid"});
		}
	}
}
sub generate_alerts_20_mrsa_wrong_antibiotic() {
	my $uid = $sid[2];
	my @cases = &query(qq{SELECT entry FROM rc_cases WHERE closed="0"});
	foreach my $case (@cases) {
		my ($cid, $pid) = &query(qq{SELECT DISTINCTROW rc_cases.entry, rc_cases.patient FROM rc_labs, rc_cases WHERE rc_cases.entry="$case" AND rc_cases.entry=rc_labs.case_id AND (rc_labs.pathogen_1="Final: (Gram +ve) Staphylococcus aureus (MRSA)" OR rc_labs.pathogen_2="Final: (Gram +ve) Staphylococcus aureus (MRSA)" OR rc_labs.pathogen_3="Final: (Gram +ve) Staphylococcus aureus (MRSA)" OR rc_labs.pathogen_4="Final: (Gram +ve) Staphylococcus aureus (MRSA)") LIMIT 1});
		if ($cid ne '') {
			if (&fast(qq{SELECT entry FROM rc_antibiotics WHERE case_id="$cid" AND (antibiotic="Vancomycin" OR antibiotic="Linezolid") LIMIT 1}) eq '') {
				if (&fast(qq{SELECT entry FROM rc_alerts WHERE alert_type="20" AND cid="$cid"}) eq '') {
					&input(qq{INSERT INTO rc_alerts (alert_type, pid, cid) VALUES ("20", "$pid", "$cid")});
				}
			} else {
				&archive_and_delete_alerts(qq{SELECT entry FROM rc_alerts WHERE alert_type="20" AND cid="$cid"});
			}
		} else {
			&archive_and_delete_alerts(qq{SELECT entry FROM rc_alerts WHERE alert_type="20" AND cid="$cid"});
		}
	}
}
sub generate_alerts_30_yeast_remove_pd_catheter_asap() {
	my $uid = $sid[2];
	my @cases = &query(qq{SELECT entry FROM rc_cases WHERE closed="0"});
	foreach my $case (@cases) {
		my ($cid, $pid) = &query(qq{SELECT DISTINCTROW rc_cases.entry, rc_cases.patient FROM rc_labs, rc_cases WHERE rc_cases.entry="$case" AND rc_cases.entry=rc_labs.case_id AND (rc_labs.pathogen_1 LIKE "\%Yeast\%" OR rc_labs.pathogen_2 LIKE "\%Yeast\%" OR rc_labs.pathogen_3 LIKE "\%Yeast\%" OR rc_labs.pathogen_4 LIKE "\%Yeast\%") LIMIT 1});
		if ($cid ne '') {
			if (&fast(qq{SELECT entry FROM rc_alerts WHERE alert_type="30" AND cid="$cid"}) eq '') {
				&input(qq{INSERT INTO rc_alerts (alert_type, pid, cid) VALUES ("30", "$pid", "$cid")});
			}
		} else {
			&archive_and_delete_alerts(qq{SELECT entry FROM rc_alerts WHERE alert_type="30" AND cid="$cid"});
		}
	}
}
sub generate_alerts_90_no_flu_prophylaxis() {
	my $uid = $sid[2];
	my @cases = &querymr(qq{SELECT entry, patient FROM rc_cases WHERE closed="0"});
	foreach my $case (@cases) {
		my ($case_id, $patient_id) = @$case;
		if (&fast(qq{SELECT antibiotic FROM rc_antibiotics WHERE case_id="$case_id" AND antibiotic="Fluconazole"}) eq '') {
			if (&fast(qq{SELECT entry FROM rc_alerts WHERE alert_type="90" AND cid="$case_id"}) eq '') {
				&input(qq{INSERT INTO rc_alerts (alert_type, pid, cid) VALUES ("90", "$patient_id", "$case_id")});
			}
		} else {
			&archive_and_delete_alerts(qq{SELECT entry FROM rc_alerts WHERE alert_type="90" AND cid="$case_id"});
		}
	}
}
sub generate_alerts_110_no_prelim_results() {
	my $uid = $sid[2];
	my @lab_not_arrived = &querymr(qq{SELECT rc_labs.case_id, rc_labs.entry FROM rc_cases, rc_labs WHERE rc_cases.closed="0" AND rc_cases.entry=rc_labs.case_id AND rc_labs.result_pre="0" AND rc_labs.result_final="0" AND rc_labs.ordered < SUBTIME(CURRENT_TIMESTAMP(), '1 0:0:0') ORDER BY rc_labs.created DESC});
	foreach my $d (@lab_not_arrived) {
		my ($cid, $lid) = @$d;
		my $pid = &fast(qq{SELECT patient FROM rc_cases WHERE entry="$cid"});
		if (&fast(qq{SELECT entry FROM rc_alerts WHERE alert_type="110" AND cid="$cid"}) eq '') {
			&input(qq{INSERT INTO rc_alerts (alert_type, pid, cid, lid) VALUES ("110", "$pid", "$cid", "$lid")});
		}
	}
}
sub generate_alerts_120_no_final_results() {
	my $uid = $sid[2];
	my @lab_not_arrived = &querymr(qq{SELECT rc_labs.case_id, rc_labs.entry FROM rc_cases, rc_labs WHERE rc_cases.closed="0" AND rc_cases.entry=rc_labs.case_id AND rc_labs.result_pre='1' AND rc_labs.result_final="0" AND rc_labs.ordered < SUBTIME(CURRENT_TIMESTAMP(), '3 0:0:0') ORDER BY rc_labs.created DESC});
	foreach my $d (@lab_not_arrived) {
		my ($cid, $lid) = @$d;
		my $pid = &fast(qq{SELECT patient FROM rc_cases WHERE entry="$cid"});
		my $good = &fast(qq{SELECT COUNT(*) FROM rc_labs WHERE case_id="$cid" AND result_final='1'});
		if ($good < 1) {
			if (&fast(qq{SELECT entry FROM rc_alerts WHERE alert_type="120" AND cid="$cid"}) eq '') {
				&input(qq{INSERT INTO rc_alerts (alert_type, pid, cid, lid) VALUES ("120","$pid","$cid","$lid")});
			}
		} else {
			&archive_and_delete_alerts(qq{SELECT entry FROM rc_alerts WHERE alert_type="120" AND cid="$cid"});
		}
	}
}
sub generate_alert_200_prelim_results_arrived() {
	my $lid = shift;
	my $cid = &fast(qq{SELECT case_id FROM rc_labs WHERE entry="$lid"});
	my $pid = &fast(qq{SELECT patient FROM rc_cases WHERE entry="$cid"});
	&input(qq{DELETE FROM rc_alerts WHERE (alert_type="110" OR alert_type="200") AND cid="$cid"});
	my @uids = &query(qq{SELECT primary_nurse, nephrologist FROM rc_patients WHERE entry="$pid"});
	foreach my $uid (@uids) {
		&input(qq{INSERT INTO rc_alerts (alert_type,uid,pid,cid,lid) VALUES ("200","$uid","$pid","$cid","$lid")});
	}
}
sub generate_alert_210_final_results_arrived() {
	my $lid = shift;
	my $cid = &fast(qq{SELECT case_id FROM rc_labs WHERE entry="$lid"});
	my $pid = &fast(qq{SELECT patient FROM rc_cases WHERE entry="$cid"});
	&input(qq{DELETE FROM rc_alerts WHERE (alert_type="110" OR alert_type="120" OR alert_type="200" OR alert_type="210") AND cid="$cid"});
	my @uids = &query(qq{SELECT primary_nurse, nephrologist FROM rc_patients WHERE entry="$pid"});
	foreach my $uid (@uids) {
		&input(qq{INSERT INTO rc_alerts (alert_type,uid,pid,cid,lid) VALUES ("210","$uid","$pid","$cid","$lid")});
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
		'1' => $w{'Specify empiric treatment'},
		"2" => $w{'Get culture result'},
		"3" => $w{'Get final culture result'},
		"4" => $w{'Specify final antibiotic'},
		"5" => $w{'Complete antibiotic course'},
		"6" => $w{'Collect follow-up culture'},
		"7" => $w{'Arrange home visit'},
		"8" => $w{'Specify case outcome'},
		"9" => $w{'(closed)'},
	);
	$text = $next{$text};
	$text = $next{9} if $text eq '';
	return $text;
}
sub get_next_step() {
	my $cid = shift;
	my $next = 1;
	my $outcome = &fast(qq{SELECT outcome FROM rc_cases WHERE entry="$cid"});
	my $pid = &fast(qq{SELECT patient FROM rc_cases WHERE entry="$cid"});
	if ($outcome ne "Outstanding") {
		$next = 9;
	} else {
		if (&fast(qq{SELECT entry FROM rc_antibiotics WHERE case_id="$cid"}) eq '') {
			$next = 1;
		} else {
			if (&fast(qq{SELECT entry FROM rc_labs WHERE case_id="$cid" AND (result_pre='1' OR result_final='1') ORDER BY entry DESC LIMIT 1}) eq '') {
				$next = 2;
			} else {
				if (&fast(qq{SELECT entry FROM rc_labs WHERE case_id="$cid" AND result_final='1' ORDER BY entry DESC LIMIT 1}) eq '') {
					$next = 3;
				} else {							
					if (&fast(qq{SELECT entry FROM rc_antibiotics WHERE case_id="$cid" AND basis_final='1'}) eq '') {
						$next = 4;
					} else {							
						if (&fast(qq{SELECT entry FROM rc_antibiotics WHERE case_id="$cid" AND (date_end >= CURDATE() AND date_stopped >= CURDATE())}) ne '') {
							$next = 5;
						} else {
							if (&fast(qq{SELECT follow_up_culture FROM rc_cases WHERE entry="$cid" AND follow_up_culture="Pending" AND is_peritonitis='1'}) eq "Pending") {
								# SEND EMAIL REMINDER
								my $email = &fast(qq{SELECT email FROM rc_patients WHERE email_reminder='1' AND entry="$pid"});
								if ($email ne '') {
									my $already_sent = &fast(qq{SELECT entry FROM rc_reminders WHERE send_to="$email" AND created > SUBDATE(CURDATE(), INTERVAL 7 DAY)});
									if ($already_sent eq '') {
										# SEND EMAIL
										my @list_to_bcc = &query(qq{SELECT email FROM rc_users WHERE opt_in='1'});
										my %patient_info = &queryh(qq{SELECT * FROM rc_patients WHERE entry="$pid"});
										my $greeting = $patient_info{"name_first"} . " " . $patient_info{"name_last"};
										if ($patient_info{"gender"} eq "Male") {
											$greeting = "$w{'Mr.'} " . $greeting;
										} elsif ($patient_info{"gender"} eq "Female") {
											$greeting = "$w{'Ms.'} " . $greeting;
										}
										my $list_to_bcc = join(", ", @list_to_bcc);
										my %mail = (
											"to" => $email,
											"from" => $local_settings{"email_sender_from"},
											"cc" => '',
											"bcc" => $list_to_bcc,
                                        "subject" => $w{'w_email_bring_pd_reminder_subject'},
                                        "body" => qq{$w{'Dear'} $greeting,\n\n$w{'w_email_bring_pd_reminder_body'}}	);
										&mailer(\%mail);
										&input(qq{DELETE FROM rc_reminders WHERE send_to="$email"});
										&input(qq{INSERT INTO rc_reminders (send_to) VALUES ("$email")});
									}
								}
							}
							if (&fast(qq{SELECT is_peritonitis FROM rc_cases WHERE entry="$cid"}) ne '1') {
								$next = 8;
							} else {
								if (&fast(qq{SELECT follow_up_culture FROM rc_cases WHERE entry="$cid" AND (follow_up_culture="Not tracked" OR follow_up_culture="Received" OR follow_up_culture="Collected" OR follow_up_culture="Declined")}) eq '' and $outcome ne "Catheter removal" and $outcome ne "Catheter removal and death") {
									$next = 6;
								} else {
									my $hv = &fast(qq{SELECT home_visit FROM rc_cases WHERE entry="$cid"});
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
	&input(qq{UPDATE rc_cases SET next_step="$next" WHERE entry="$cid"});
	if ($next eq "9") {
		&input(qq{UPDATE rc_cases SET closed='1' WHERE entry="$cid"});
		&cache_rebuild_patient($pid);
	}
}
sub report_list_percentage_hd_with_va() {
	my ($start, $end, $filter, $look_in, $look_for, $mysql_filter, $heading, $good_is_low_or_high) = @_;
	my $limit_to_months_ago;
	if ($look_in eq 'modality_at_six_months') {
		$limit_to_months_ago = qq{ AND tn_initial_assessment_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH)};
	} elsif ($look_in eq 'modality_at_twelve_months') {
		$limit_to_months_ago = qq{ AND tn_initial_assessment_date < DATE_SUB(CURDATE(), INTERVAL 12 MONTH)};
	}
	my @centres = &query(qq{SELECT DISTINCTROW home_centre FROM rc_lists WHERE (tn_initial_assessment_date IS NOT NULL) AND (tn_initial_assessment_date >= "$start") AND (tn_initial_assessment_date <= "$end") $mysql_filter $filter $limit_to_months_ago});
	my @data = &querymr(qq{SELECT home_centre, $look_in, vascular_access_at_hd_start FROM rc_lists WHERE (((status_at_initial_meeting = "Hemodialysis") OR ((modality_at_six_months LIKE "\%hemodialysis\%" OR modality_at_six_months IS NULL OR modality_at_six_months = "") AND (modality_at_twelve_months LIKE "\%hemodialysis\%" OR modality_at_twelve_months IS NULL OR modality_at_twelve_months = ""))) AND (pd_start_date IS NULL OR pd_start_date = "0000-00-00" OR pd_start_date = "")) AND (tn_initial_assessment_date IS NOT NULL) AND (tn_initial_assessment_date >= "$start") AND (tn_initial_assessment_date <= "$end") $mysql_filter $filter $limit_to_months_ago});
	@centres = ("All centres", @centres);
	my $centre_count = @centres;
	my $column_width = int(100 / $centre_count);
	my $output = qq{<h4><span class="b">$heading</span></h4>};
	my $percentage_of_all_centres;
	my $low_color = "txt-gre";
	my $high_color = "txt-ora";
	if ($good_is_low_or_high eq '') {
		$good_is_low_or_high = "low";
	} elsif ($good_is_low_or_high eq "high") {
		$low_color = "txt-ora";
		$high_color = "txt-gre";
	}
	foreach my $centre (@centres) {
		my $included_starts = 0;
		my $positive_starts = 0;
		my $percentage;
		foreach my $d (@data) {
			my $home_centre = @$d[0];
			my $look_in = @$d[1];
			my $va_type = @$d[2];
			if (($centre ne "All centres") and ($centre ne $home_centre)) {
				next;
			}
			$included_starts++;
			if ($va_type =~ /AV/) {
				if ($look_in =~ /hemodialysis/) {
					$positive_starts++;
				}
			}
		}
		if ($included_starts > 0) {
			$percentage = (int((($positive_starts / $included_starts) * 1000) + 0.5))/10;
			unless ($percentage =~ /\./) {
				$percentage .= ".0";
			}
			if ($centre eq "All centres") {
				$percentage_of_all_centres = $percentage;
				$percentage = qq{<span class="txt-blu">$percentage\%</span>};
			} elsif ($percentage > $percentage_of_all_centres) {
				$percentage = qq{<span class="$high_color">$percentage\%</span>};
			} elsif ($percentage < $percentage_of_all_centres) {
				$percentage = qq{<span class="$low_color">$percentage\%</span>};
			} else {
				$percentage = qq{$percentage\%};
			}
		} else {
			$percentage = "&ndash;";
		}
		if ($centre eq 'All centres') {
			$centre = $w{'All centres_uc'};
		}
		$output .= qq{
			<div class="rbox" style="width:$column_width\%;">
				<div class="rbox-in">
					<div class="rbox-hd">$centre</div>
					<div class="rbox-xl">$percentage</div>
					<div class="clear-l"></div>
					<div class="rbox-fp">
            			<div>$included_starts $w{'starts matching this time frame'}</div>
						<div>$positive_starts $w{'starts matching the criteria'}</div>
					</div>
				</div>
			</div>};
	}
	return $output;
}
sub report_list_percentage() {
	my ($start, $end, $filter, $look_in, $look_for, $mysql_filter, $heading, $good_is_low_or_high) = @_;
	my $limit_to_months_ago;
	if ($look_in eq 'modality_at_six_months') {
		$limit_to_months_ago = qq{ AND tn_initial_assessment_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH)};
	} elsif ($look_in eq 'modality_at_twelve_months') {
		$limit_to_months_ago = qq{ AND tn_initial_assessment_date < DATE_SUB(CURDATE(), INTERVAL 12 MONTH)};
	}
	my @centres = &query(qq{SELECT DISTINCTROW home_centre FROM rc_lists WHERE (tn_initial_assessment_date IS NOT NULL) AND (tn_initial_assessment_date >= "$start") AND (tn_initial_assessment_date <= "$end") $mysql_filter $filter $limit_to_months_ago});
	my @data = &querymr(qq{SELECT home_centre, $look_in FROM rc_lists WHERE (tn_initial_assessment_date IS NOT NULL) AND (tn_initial_assessment_date >= "$start") AND (tn_initial_assessment_date <= "$end") $mysql_filter $filter $limit_to_months_ago});
	@centres = ("All centres", @centres);
	my $centre_count = @centres;
	my $column_width = int(100 / $centre_count);
	my $output = qq{<h4><span class="b">$heading</span></h4>};
	my $percentage_of_all_centres;
	my $low_color = "txt-gre";
	my $high_color = "txt-ora";
	if ($good_is_low_or_high eq '') {
		$good_is_low_or_high = "low";
	} elsif ($good_is_low_or_high eq "high") {
		$low_color = "txt-ora";
		$high_color = "txt-gre";
	}
	foreach my $centre (@centres) {
		my $included_starts = 0;
		my $positive_starts = 0;
		my $percentage;
		foreach my $d (@data) {
			my $home_centre = @$d[0];
			my $look_in = @$d[1];
			if (($centre ne "All centres") and ($centre ne $home_centre)) {
				next;
			}
			$included_starts++;
			if ($look_for eq "NOT NULL") {
				if (($look_in ne '') and ($look_in ne "0000-00-00")) {
					$positive_starts++;
				}
			} else {
				if ($look_in eq $look_for) {
					$positive_starts++;
				}
			}
		}
		if ($included_starts > 0) {
			$percentage = (int((($positive_starts / $included_starts) * 1000) + 0.5))/10;
			unless ($percentage =~ /\./) {
				$percentage .= ".0";
			}
			if ($centre eq "All centres") {
				$percentage_of_all_centres = $percentage;
				$percentage = qq{<span class="txt-blu">$percentage\%</span>};
			} elsif ($percentage > $percentage_of_all_centres) {
				$percentage = qq{<span class="$high_color">$percentage\%</span>};
			} elsif ($percentage < $percentage_of_all_centres) {
				$percentage = qq{<span class="$low_color">$percentage\%</span>};
			} else {
				$percentage = qq{$percentage\%};
			}
		} else {
			$percentage = "&ndash;";
		}
		if ($centre eq 'All centres') {
			$centre = $w{'All centres_uc'};
		}
		$output .= qq{
			<div class="rbox" style="width:$column_width\%;">
				<div class="rbox-in">
					<div class="rbox-hd">$centre</div>
					<div class="rbox-xl">$percentage</div>
					<div class="clear-l"></div>
					<div class="rbox-fp">
            			<div>$included_starts $w{'starts matching this time frame'}</div>
						<div>$positive_starts $w{'starts matching the criteria'}</div>
					</div>
				</div>
			</div>};
	}
	return $output;
}
sub report_list_time_interval() {
	my ($start, $end, $filter, $startpoint, $endpoint, $mysql_filter, $heading) = @_;
	my $first_hd_date = 0;
	if ($startpoint eq "first_hd_date") {
		$first_hd_date = 1;
	}
	my @centres = &query(qq{SELECT DISTINCTROW home_centre FROM rc_lists WHERE (tn_initial_assessment_date IS NOT NULL) AND (tn_initial_assessment_date >= "$start") AND (tn_initial_assessment_date <= "$end") $mysql_filter $filter});
	my @data = &querymr(qq{SELECT home_centre, $startpoint, $endpoint, patient, entry FROM rc_lists WHERE (tn_initial_assessment_date IS NOT NULL) AND (tn_initial_assessment_date >= "$start") AND (tn_initial_assessment_date <= "$end") $mysql_filter $filter});
	@centres = ("All centres", @centres);
	my $centre_count = @centres;
	my $column_width = int(100 / $centre_count);
	my $output = qq{<h4><span class="b">$heading</span></h4>};
	my $average_of_all_centres;
	my $median_of_all_centres;
	foreach my $centre (@centres) {
		my $total_starts = 0;
		my $included_starts = 0;
		my $included_sum = 0;
		my $average;
		my @median;
		my $median;
		my $median_debug;
		my $median_number;
		my $min;
		my $max;
		my $close_button = &close_button();
		my $report_table = qq{
			$close_button
			<h2>$w{'List statistics'}</h2>
			<h3>$heading</h3>
			<div class="bg-lb">
				<div class="float-l w20p b p5to p5bo">&nbsp;$w{'Data point'}</div>
				<div class="float-l w20p b p5to p5bo">$w{'Duration'}</div>
				<div class="float-l w20p b p5to p5bo">$w{'Date 1'}</div>
				<div class="float-l w20p b p5to p5bo">$w{'Date 2'}</div>
				<div class="float-l w20p b p5to p5bo">$w{'Manage start_uc'}</div>
				<div class="clear-l"></div>
			</div>
		};
		my %report_table = ();
		foreach my $d (@data) {
			my $home_centre = @$d[0];
			my $first_hd_date = @$d[1];
			my $pd_start_date = @$d[2];
			my $patient_id = @$d[3];
			my $start_entry = @$d[4];
			my $length_of_time;
			if (($centre ne "All centres") and ($centre ne $home_centre)) {
				next;
			}
			$total_starts++;
			if ($first_hd_date eq '' or $first_hd_date eq '0000-00-00' or $pd_start_date eq '' or $pd_start_date eq '0000-00-00') {
				next;
			} else {
				$length_of_time = &fast(qq{SELECT DATEDIFF('$pd_start_date', '$first_hd_date')});
			}
			if ($length_of_time < 0) {
				next;
			}
			$included_starts++;
			$included_sum = $included_sum + $length_of_time;
			@median = (@median, $length_of_time);
			if ($min eq '' or $min > $length_of_time) {
				$min = $length_of_time;
			}
			if ($max eq '' or $max < $length_of_time) {
				$max = $length_of_time;
			}
			my $length_of_time_zeros = $length_of_time;
			while (length($length_of_time_zeros) < 6) {
				$length_of_time_zeros = "0" . $length_of_time_zeros;
			}
			$report_table{$length_of_time_zeros . "_" . $patient_id} = qq{
					<div class="float-l w20p p5to p5bo">$length_of_time $w{'days'}</div>
					<div class="float-l w20p p5to p5bo">$first_hd_date</div>
					<div class="float-l w20p p5to p5bo">$pd_start_date</div>
					<div class="float-l w20p p5to p5bo"><a href="ajax.pl?token=$token&do=view_list&amp;list_id=$start_entry" target="$hbin_target" onclick="blurry();">$w{'manage start'}</a></div>
					<div class="clear-l"></div>
				</div>};
		}
		my $number = 1;
		foreach my $row (sort keys %report_table) {
			$report_table .= qq{
				<div class="br-t">
					<div class="float-l w20p p5to p5bo gt">&nbsp;$number</div>} . $report_table{$row};
			$number++;
		}
		if ($included_starts > 0) {
			@median = sort {$a <=> $b} @median;
			$median_number = @median;
			$median_number = int($median_number / 2);
			$median = $median[$median_number];
			$average = (int((($included_sum / $included_starts) * 10) + 0.5))/10;
			unless ($average =~ /\./) {
				$average .= ".0";
			}
			if ($centre eq "All centres") {
				$average_of_all_centres = $average;
				$median_of_all_centres = $median;
				$average = qq{<span class="txt-blu">$average</span>};
				$median = qq{<span class="txt-blu">$median</span>};
			} elsif ($average > $average_of_all_centres) {
				$average = qq{<span class="txt-ora">$average</span>};
			} elsif ($average < $average_of_all_centres) {
				$average = qq{<span class="txt-gre">$average</span>};
			}
			if ($median > $median_of_all_centres) {
				$median = qq{<span class="txt-ora">$median</span>};
			} elsif ($median < $median_of_all_centres) {
				$median = qq{<span class="txt-gre">$median</span>};
			}
		} else {
			$average = "&ndash;";
			$min = "&ndash;";
			$max = "&ndash;";
		}
		if ($centre eq 'All centres') {
			$centre = $w{'All centres_uc'};
		}
		my $random_number = rand();
		$random_number =~ s/\.//g;
		$output .= qq{
			<div class="rbox" style="width:$column_width\%;">
				<div class="rbox-in">
					<div class="rbox-hd">$centre</div>
					<div class="rbox-xl">$average</div>
					<div class="rbox-st">
						$w{'days'}<br/>
						<span class="lgt">$w{'(mean)'}</span>
					</div>
					<div class="clear-l"></div>
					<div class="rbox-xl">$median</div>
					<div class="rbox-st">
						$w{'days'}<br/>
						<span class="lgt">($w{'median'})</span>
					</div>
					<div class="clear-l"></div>
					<div class="rbox-fp">
            			<div>$total_starts $w{'starts matching this time frame'}</div>
            			<div>$included_starts $w{'starts with data for this calculation'}</div>
            			<div>$w{'Range of'} $min $w{'to'} $max $w{'days'}</div>
            			<div class="lk b" onclick="ajax_pop_up('div_pop_up','popup$random_number');">Inspect data</div>
					</div>
					<div class="hide" id="popup$random_number">$report_table</div>
				</div>
			</div>};
	}
	return $output;
}
sub view_list_reports() {
	my %p = %{$_[0]};
	my ($start, $end, $filter);
	$p{"form_report_interval"} = &fast(qq{SELECT DATEDIFF('$p{"form_report_end"}', '$p{"form_report_start"}')});
	if ($p{"form_report_interval"} < 1 or $p{"form_report_interval"} eq '') {
		($start, $end) = (&fast(qq{SELECT SUBDATE(CURDATE(), INTERVAL 12 MONTH)}), &fast(qq{SELECT ADDDATE(CURDATE(), INTERVAL 1 DAY)}));
	} else {
		($start, $end) = ($p{"form_report_start"}, $p{"form_report_end"});
	}
	if ($p{'form_report_filter'} eq 'less') {
		$filter = qq{ AND (DATEDIFF(tn_initial_assessment_date, first_hd_date) < 181)};
	} elsif ($p{'form_report_filter'} eq 'more') {
		$filter = qq{ AND (DATEDIFF(tn_initial_assessment_date, first_hd_date) > 180)};
	}
	my $now = &fast(qq{SELECT ADDDATE(CURDATE(), INTERVAL 1 DAY)});
	my $ago_month = &fast(qq{SELECT SUBDATE(CURDATE(), INTERVAL 1 MONTH)});
	my $ago_quarter = &fast(qq{SELECT SUBDATE(CURDATE(), INTERVAL 3 MONTH)});
	my $ago_half_year = &fast(qq{SELECT SUBDATE(CURDATE(), INTERVAL 6 MONTH)});
	my $ago_year = &fast(qq{SELECT SUBDATE(CURDATE(), INTERVAL 12 MONTH)});
	my $ago_two_year = &fast(qq{SELECT SUBDATE(CURDATE(), INTERVAL 24 MONTH)});
	my $ago_five_year = &fast(qq{SELECT SUBDATE(CURDATE(), INTERVAL 48 MONTH)});
	my $year = &fast(qq{SELECT YEAR("$now")});
	my @year_range = (2012..$year);
	my $common_presets = qq{
		<a href="ajax.pl?token=$token&do=view_list_reports&form_report_start=$ago_month&form_report_end=$now" target="$hbin_target">$w{'month'}</a> &nbsp;
		<a href="ajax.pl?token=$token&do=view_list_reports&form_report_start=$ago_quarter&form_report_end=$now" target="$hbin_target">$w{'quarter'}</a> &nbsp;
		<a href="ajax.pl?token=$token&do=view_list_reports&form_report_start=$ago_half_year&form_report_end=$now" target="$hbin_target">$w{'six months'}</a> &nbsp; 
		<a href="ajax.pl?token=$token&do=view_list_reports&form_report_start=$ago_year&form_report_end=$now" target="$hbin_target">$w{'year'}</a> &nbsp; 
		<a href="ajax.pl?token=$token&do=view_list_reports&form_report_start=$ago_two_year&form_report_end=$now" target="$hbin_target">$w{'two years'}</a> &nbsp; 
	};
	my $common_years;
	foreach my $sub (@year_range) {
		my $y = $sub;
		$common_years .= qq{<a href="ajax.pl?token=$token&do=view_list_reports&form_report_start=$y-01-01&form_report_end=$y-12-31" target="$hbin_target">$y</a> &nbsp; };
	}
	my $hd_to_tn_assess = &report_list_time_interval($start, $end, $filter, "first_hd_date", "tn_initial_assessment_date", qq{}, $w{'From HD start to first TN assessment'});
	my $hd_to_pd_referral = &report_list_time_interval($start, $end, $filter, "first_hd_date", "pd_referral_date", qq{AND tn_chosen_modality="Peritoneal dialysis" AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'From HD start to PD referral'});
	my $hd_to_pd_cath = &report_list_time_interval($start, $end, $filter, "first_hd_date", "pd_cath_insertion_date", qq{AND tn_chosen_modality="Peritoneal dialysis" AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'From HD start to PD catheter insertion'});
	my $hd_to_pd_start = &report_list_time_interval($start, $end, $filter, "first_hd_date", "pd_start_date", qq{AND tn_chosen_modality="Peritoneal dialysis" AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'From HD start to PD start'});

	my $pd_ref_to_pd_cath = &report_list_time_interval($start, $end, $filter, "pd_referral_date", "pd_cath_insertion_date", qq{AND tn_chosen_modality="Peritoneal dialysis" AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'From PD referral to PD catheter insertion'});
	my $pd_ref_to_pd_start = &report_list_time_interval($start, $end, $filter, "pd_referral_date", "pd_start_date", qq{AND tn_chosen_modality="Peritoneal dialysis" AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'From PD referral to PD start'});

	my $pct_chose_pd = &report_list_percentage($start, $end, $filter, "tn_chosen_modality", "Peritoneal dialysis", qq{AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'Proportion of patients who chose PD after TN intervention'}, "high");
	my $pct_chose_pd_six_months = &report_list_percentage($start, $end, $filter, "modality_at_six_months", "Peritoneal dialysis", qq{AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'Proportion of patients who are on PD 6 months after TN intervention'}, "high");
	my $pct_chose_pd_twelve_months = &report_list_percentage($start, $end, $filter, "modality_at_twelve_months", "Peritoneal dialysis", qq{AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'Proportion of patients who are on PD 12 months after TN intervention'}, "high");

	my $hd_to_hhd_referral = &report_list_time_interval($start, $end, $filter, "first_hd_date", "homehd_hhd_referral_date", qq{AND tn_chosen_modality="Home hemodialysis" AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'From HD start to HHD referral'});
	my $hd_to_hhd_start = &report_list_time_interval($start, $end, $filter, "first_hd_date", "homehd_hhd_start_date", qq{AND tn_chosen_modality="Home hemodialysis" AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'From HD start to HHD start'});
	my $pct_chose_hhd = &report_list_percentage($start, $end, $filter, "tn_chosen_modality", "Home hemodialysis", qq{AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'Proportion of patients who chose HHD after TN intervention'}, "high");
	my $pct_chose_hhd_six_months = &report_list_percentage($start, $end, $filter, "modality_at_six_months", "Home hemodialysis", qq{AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'Proportion of patients who are on HHD 6 months after TN intervention'}, "high");
	my $pct_chose_hhd_twelve_months = &report_list_percentage($start, $end, $filter, "modality_at_twelve_months", "Home hemodialysis", qq{AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'Proportion of patients who are on HHD 12 months after TN intervention'}, "high");

	my $hd_to_va_referral = &report_list_time_interval($start, $end, $filter, "first_hd_date", "cvc_va_referral_date", qq{AND tn_chosen_modality LIKE "\%hemodialysis\%" AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'From HD start to VA referral for patients who chose HD'});
	my $hd_to_va_creation = &report_list_time_interval($start, $end, $filter, "first_hd_date", "tn_avf_creation_date", qq{AND tn_chosen_modality LIKE "\%hemodialysis\%" AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'From HD start to VA creation for patients who chose HD'});
	my $hd_to_va_use = &report_list_time_interval($start, $end, $filter, "first_hd_date", "tn_avf_use_date", qq{AND tn_chosen_modality LIKE "\%hemodialysis\%" AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'From HD start to VA use for patients who chose HD'});
	my $pct_chose_hd_with_proper_va_six_months = &report_list_percentage_hd_with_va($start, $end, $filter, "modality_at_six_months", qq{}, qq{AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'Proportion of patients who are on HD with VA (AVF or AVG) 6 months after TN intervention'}, "high");
	my $pct_chose_hd_with_proper_va_twelve_months = &report_list_percentage_hd_with_va($start, $end, $filter, "modality_at_twelve_months", qq{}, qq{AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'Proportion of patients who are on HD with VA (AVF or AVG) 12 months after TN intervention'}, "high");

	my $hd_to_most_completed = &report_list_time_interval($start, $end, $filter, "first_hd_date", "most_completed_date", qq{}, $w{'From HD start to ACP completion'});
	my $pct_with_acp = &report_list_percentage($start, $end, $filter, "acp_introduced", "Yes", qq{}, $w{'Proportion of patients introduced to ACP'}, "high");

	my $hd_to_tp_referral = &report_list_time_interval($start, $end, $filter, "first_hd_date", "transplant_referral_date", qq{AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'From HD start to transplant referral'});
	my $hd_to_tp_start = &report_list_time_interval($start, $end, $filter, "first_hd_date", "transplant_date", qq{AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'From HD start to transplant operation'});
	my $pct_referred_for_tp = &report_list_percentage($start, $end, $filter, "transplant_referral_date", "NOT NULL", qq{AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'Proportion of all patients referred for transplant'}, "high");
	my $pct_has_ld = &report_list_percentage($start, $end, $filter, "transplant_donor_identified", "Yes", qq{AND (recovered_from_dialysis_dependance = "No" OR recovered_from_dialysis_dependance IS NULL)}, $w{'Proportion of patients with an identified living donor'}, "high");

	my $nice_start = &nice_date($start);
	my $nice_end = &nice_date($end);
	my ($less_selected, $more_selected);
	if ($p{'form_report_filter'} eq 'less') {
		$less_selected = 'selected="selected"';
	} elsif ($p{'form_report_filter'} eq 'more') {
		$more_selected = 'selected="selected"';
	}
	my $past_localization = qq{<div class="tr gt">$w{'past'} &nbsp; $common_presets</div>};
	if ($w{'lang'} eq 'fr') {
		$past_localization = qq{<div class="tr gt">$common_presets</div>};
	}
	my $time_range_localization = qq{<h4><strong>$w{'List statistics'}</strong> $w{'for'} <strong>$nice_start</strong> $w{'to'} <strong>$nice_end</strong> $w{'inclusive'}</h4>};
	if ($w{'lang'} eq 'fr') {
		$time_range_localization = qq{<h4><strong>$w{'List statistics'}</strong> du <strong>$nice_start</strong> au <strong>$nice_end</strong> $w{'inclusive'}</h4>};
	}
	return qq{
		<div class=''>
			<div class="p20bo">
				<div class="float-l p10to">
        			$time_range_localization
				</div>
				<div class="tr">
					<div class="float-r p9to">
						<form name="report" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
							<input type="hidden" name="do" value="view_list_reports"/>
							<input type="hidden" name="token" value="$token"/>
							<div class="float-l b p1to">$w{'Switch to'} &nbsp;</div>
							<div class="float-l"><div class="itt w80"><input type="text" class="itt" name="form_report_start" value="$start" onclick="displayDatePicker('form_report_start');"/></div></div>
        <div class="float-l">&nbsp; $w{'to'} &nbsp;</div>
							<div class="float-l"><div class="itt w80"><input type="text" class="itt" name="form_report_end" value="$end" onclick="displayDatePicker('form_report_end');"/></div></div>
							<div class="clear-l"></div>
							<div class="float-l p5to">
								$w{'Include'} <select name="form_report_filter" class="w300">
									<option value="">$w{'all starts'}</option>
        <option value="less" $less_selected>$w{'starts &le; 180 days from HD start to TN 1st visit'}</option>
        <option value="more" $more_selected>$w{'starts &gt; 180 days from HD start to TN 1st visit'}</option>
								</select>
							</div>
							<div class="float-l p5to"><input type="submit" value="$w{'Go'}"/></div>
							<div class="clear-l"></div>
						</form>
					</div>
					<div class="clear-r"></div>
        $past_localization
        <div class="tr gt">$w{'year'} &nbsp; $common_years</div>
				</div>
			</div>
			<h2>$w{'TN assessment'}</h2>
			<div class="p20lo">
				<div>
					$hd_to_tn_assess
				</div>
			</div>
        <h2>$w{'Advance care planning'} <span class="lgt">$w{'outcomes'}</span></h2>
			<div class="p20lo">
				<div>
					$pct_with_acp
					$hd_to_most_completed
					<div class="clear-l"></div>
				</div>
			</div>

        <h2>$w{'Vascular access'} <span class="lgt">$w{'outcomes'}</span></h2>
			<div class="p20lo">
				<div>
					$hd_to_va_referral
					$hd_to_va_creation
					$hd_to_va_use
					$pct_chose_hd_with_proper_va_six_months
					$pct_chose_hd_with_proper_va_twelve_months
					<div class="clear-l"></div>
				</div>
			</div>

        <h2>$w{'Peritoneal dialysis'} <span class="lgt">$w{'outcomes'}</span></h2>
			<div class="p20lo">
				<div>
					$hd_to_pd_referral
					$hd_to_pd_cath
					$hd_to_pd_start
					$pd_ref_to_pd_cath
					$pd_ref_to_pd_start
					$pct_chose_pd
					$pct_chose_pd_six_months
					$pct_chose_pd_twelve_months
					<div class="clear-l"></div>
				</div>
			</div>

        <h2>$w{'Home hemodialysis (HHD)'} <span class="lgt">$w{'outcomes'}</span></h2>
			<div class="p20lo">
				<div>
					$hd_to_hhd_referral
					$hd_to_hhd_start
					$pct_chose_hhd
					$pct_chose_hhd_six_months
					$pct_chose_hhd_twelve_months
					<div class="clear-l"></div>
				</div>
			</div>
			
        <h2>$w{'Transplant'} <span class="lgt">$w{'outcomes'}</span></h2>
			<div class="p20lo">
				<div>
					$hd_to_tp_referral
					$hd_to_tp_start
					$pct_referred_for_tp
					$pct_has_ld
				</div>
			</div>
		</div>
	};
}
sub view_reports() {
	my %p = %{$_[0]};
	my ($start, $end);
	$p{"form_report_interval"} = &fast(qq{SELECT DATEDIFF('$p{"form_report_end"}', '$p{"form_report_start"}')});
	if ($p{"form_report_interval"} < 1 or $p{"form_report_interval"} eq '') {
		($start, $end) = (&fast(qq{SELECT SUBDATE(CURDATE(), INTERVAL 12 MONTH)}), &fast(qq{SELECT ADDDATE(CURDATE(), INTERVAL 1 DAY)}));
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
		<a href="ajax.pl?token=$token&do=view_reports&form_report_start=$ago_month&form_report_end=$now" target="$hbin_target">$w{'month'}</a> &nbsp; 
		<a href="ajax.pl?token=$token&do=view_reports&form_report_start=$ago_quarter&form_report_end=$now" target="$hbin_target">$w{'quarter'}</a> &nbsp;
		<a href="ajax.pl?token=$token&do=view_reports&form_report_start=$ago_half_year&form_report_end=$now" target="$hbin_target">$w{'six months'}</a> &nbsp; 
		<a href="ajax.pl?token=$token&do=view_reports&form_report_start=$ago_year&form_report_end=$now" target="$hbin_target">$w{'year'}</a> &nbsp; 
		<a href="ajax.pl?token=$token&do=view_reports&form_report_start=$ago_two_year&form_report_end=$now" target="$hbin_target">$w{'two years'}</a> &nbsp; 
	};
	my $common_years;
	foreach my $sub (@year_range) {
		my $y = $year - $sub;
		$common_years .= qq{<a href="ajax.pl?token=$token&do=view_reports&form_report_start=$y-01-01&form_report_end=$y-12-31" target="$hbin_target">$y</a> &nbsp; };
	}
	my $peritonitis_rate = &report_peritonitis($start, $end);
	my $hospitalization_rate = &report_percent_cases_hospitalized($start, $end);
	my $culture_negative_rate = &report_percent_cases_culture_negative($start, $end);
	my $pathogens_hospitalized = &report_pathogens($start, $end, qq{SELECT rc_labs.pathogen_1, rc_labs.pathogen_2, rc_labs.pathogen_3, rc_labs.pathogen_4 FROM rc_cases, rc_labs WHERE rc_cases.created >= "$start" AND rc_cases.created <= "$end" AND rc_cases.hospitalization_required="Yes" AND rc_cases.entry=rc_labs.case_id}, "$w{'Pathogens, hospitalized patients'}", "#3399ff");
	my $pathogens_all = &report_pathogens($start, $end, qq{SELECT rc_labs.pathogen_1, rc_labs.pathogen_2, rc_labs.pathogen_3, rc_labs.pathogen_4 FROM rc_cases, rc_labs WHERE rc_cases.created >= "$start" AND rc_cases.created <= "$end" AND rc_cases.entry=rc_labs.case_id}, "$w{'Pathogens, all infections'}", "#ffcc00");
	my $pathogens_peritonitis = &report_pathogens($start, $end, qq{SELECT rc_labs.pathogen_1, rc_labs.pathogen_2, rc_labs.pathogen_3, rc_labs.pathogen_4 FROM rc_cases, rc_labs WHERE rc_cases.created >= "$start" AND rc_cases.created <= "$end" AND rc_cases.is_peritonitis='1' AND rc_cases.entry=rc_labs.case_id}, "$w{'Pathogens, in peritonitis'}", "#ff3300");
	my $pathogens_exit_site = &report_pathogens($start, $end, qq{SELECT rc_labs.pathogen_1, rc_labs.pathogen_2, rc_labs.pathogen_3, rc_labs.pathogen_4 FROM rc_cases, rc_labs WHERE rc_cases.created >= "$start" AND rc_cases.created <= "$end" AND rc_cases.is_exit_site='1' AND rc_cases.entry=rc_labs.case_id}, "$w{'Pathogens, in exit site infections'}", "#B3FF00");
	my $pathogens_tunnel = &report_pathogens($start, $end, qq{SELECT rc_labs.pathogen_1, rc_labs.pathogen_2, rc_labs.pathogen_3, rc_labs.pathogen_4 FROM rc_cases, rc_labs WHERE rc_cases.created >= "$start" AND rc_cases.created <= "$end" AND rc_cases.is_tunnel='1' AND rc_cases.entry=rc_labs.case_id}, "$w{'Pathogens, in tunnel infections'}", "#ffee00");
	my $antibiotics_empiric = &report_antibiotics($start, $end, qq{SELECT rc_antibiotics.antibiotic FROM rc_cases, rc_antibiotics WHERE rc_cases.created >= "$start" AND rc_cases.created <= "$end" AND rc_cases.is_peritonitis='1' AND rc_cases.entry=rc_antibiotics.case_id AND rc_antibiotics.basis_empiric='1'}, "$w{'Antibiotics, as empiric treatment (peritonitis only)'}", "#FF00B3");
	my $antibiotics_final = &report_antibiotics($start, $end, qq{SELECT rc_antibiotics.antibiotic FROM rc_cases, rc_antibiotics WHERE rc_cases.created >= "$start" AND rc_cases.created <= "$end" AND rc_cases.is_peritonitis='1' AND rc_cases.entry=rc_antibiotics.case_id AND rc_antibiotics.basis_final='1'}, "$w{'Antibiotics, as final treatment (peritonitis only)'}", "#CC00FF");
	my $nice_start = &nice_date($start);
	my $nice_end = &nice_date($end);
	my $past_localization = qq{<div class="tr gt">$w{'past'} &nbsp; $common_presets</div>};
	if ($w{'lang'} eq 'fr') {
		$past_localization = qq{<div class="tr gt">$common_presets</div>};
	}
	my $time_range_localization = qq{<h4><strong>$w{'Case statistics'}</strong> $w{'for'} <strong>$nice_start</strong> $w{'to'} <strong>$nice_end</strong> $w{'inclusive'}</h4>};
	if ($w{'lang'} eq 'fr') {
		$time_range_localization = qq{<h4><strong>$w{'Case statistics'}</strong> du <strong>$nice_start</strong> au <strong>$nice_end</strong> $w{'inclusive'}</h4>};
	}
	return qq{
		<div class=''>
			<div class="p20bo">
				<div class="float-l p10to">
					$time_range_localization
				</div>
				<div class="tr">
					<div class="float-r p9to">
						<form name="report" action="ajax.pl" target="$hbin_target" method="post" accept-charset="utf-8">
							<input type="hidden" name="do" value="view_reports"/>
							<input type="hidden" name="token" value="$token"/>
							<div class="float-l b p1to">$w{'Switch to'} &nbsp;</div>
							<div class="float-l"><div class="itt w80"><input type="text" class="itt" name="form_report_start" value="$start" onclick="displayDatePicker('form_report_start');"/></div></div>
        					<div class="float-l">&nbsp; $w{'to'} &nbsp;</div>
							<div class="float-l"><div class="itt w80"><input type="text" class="itt" name="form_report_end" value="$end" onclick="displayDatePicker('form_report_end');"/></div></div>
							<div class="float-l">&nbsp; <input type="submit" value="$w{'Go'}"/></div>
							<div class="clear-l"></div>
						</form>
					</div>
					<div class="clear-r"></div>
        			$past_localization
        			<div class="tr gt">$w{'year'} &nbsp; $common_years</div>
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
		</div>
	};
}
sub report_percent_cases_culture_negative() {
	my ($start, $end) = @_;
	my @cultures = &querymr(qq{SELECT rc_labs.pathogen_1, rc_labs.pathogen_2, rc_labs.pathogen_3, rc_labs.pathogen_4 FROM rc_labs, rc_cases WHERE rc_labs.ordered >= "$start" AND rc_labs.ordered <= "$end" AND rc_labs.case_id=rc_cases.entry AND rc_cases.is_peritonitis = 1});
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
        		<div class="rbox-hd">$w{'Negative cultures'}</div>
				<div class="rbox-xl">$cultures_negative_percent</div>
				<div class="clear-l"></div>
        		<div class="rbox-st"> $w{'of cultures yield negative<br/>results during this time period'}</div>
				<div class="rbox-fp">
        			<div>$w{'only cultures from peritonitis cases are counted'}</div>
        			<div>$cultures_negative $w{'cultures negative'}</div>
        			<div>$cultures_all $w{'total cultures ordered'}</div>
				</div>
			</div>
		</div>};
}
sub report_percent_cases_hospitalized() {
	my ($start, $end) = @_;
	my $cases_all = &fast(qq{SELECT COUNT(*) FROM rc_cases WHERE created >= "$start" AND created <= "$end"});
	my $cases_hospitalized = &fast(qq{SELECT COUNT(*) FROM rc_cases WHERE hospitalization_required="Yes" AND created >= "$start" AND created <= "$end"});
	my $cases_hospitalized_percent = 0;
	if ($cases_all > 0) {
		$cases_hospitalized_percent = int(0.5 + (($cases_hospitalized / $cases_all) * 100));
	}
	return qq{
		<div class="rbox w50p">
			<div class="rbox-in">
        		<div class="rbox-hd">$w{'Hospitalization'}</div>
				<div class="rbox-xl">$cases_hospitalized_percent\%</div>
				<div class="clear-l"></div>
        		<div class="rbox-st"> $w{'of cases require hospitalization<br/>during this time period'}</div>
				<div class="rbox-fp">
        			<div>$cases_hospitalized $w{'cases requiring hospitalization'}</div>
        			<div>$cases_all $w{'cases in total'}</div>
				</div>
			</div>
		</div>};
}
sub report_peritonitis() {
	my ($start, $end) = @_;
	my @pds = &querymr(qq{SELECT start_date, stop_date, patient_id FROM rc_dialysis WHERE (stop_date IS NULL OR stop_date >= "$start") AND start_date IS NOT NULL});
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
		if ($pd_end ne '') {
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
		my $peritonitis_occurence_patient = &fast(qq{SELECT COUNT(*) FROM rc_cases WHERE is_peritonitis='1' AND created >= "$start" AND created <= "$end" AND patient="$patient_id"});
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
    #&fast(qq{SELECT COUNT(DISTINCTROW patient_id) FROM rc_dialysis WHERE (start_date >= "$start" AND start_date <= "$end") OR (stop_date <= "$end" AND stop_date >= "$start")});
    my $patients_peritonitis = &fast(qq{SELECT COUNT(DISTINCTROW patient) FROM rc_cases WHERE is_peritonitis='1' AND created >= "$start" AND created <= "$end"});
    my $patients_peritonitis_free = $patients_at_risk_new - $patients_peritonitis;
	$months_at_risk = $days_at_risk / 30.4368499;
	my $months_at_risk_rounded = int(0.5 + $months_at_risk);
	my $peritonitis_occurence = &fast(qq{SELECT COUNT(*) FROM rc_cases WHERE is_peritonitis='1' AND created >= "$start" AND created <= "$end"});
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
		if ($subtract_of_mean_squared_counter > 0) {
			$peritonitis_rate_sum_of_subtract_of_mean_squared = $peritonitis_rate_sum_of_subtract_of_mean_squared / $subtract_of_mean_squared_counter;
		} else {
			$peritonitis_rate_sum_of_subtract_of_mean_squared = 0;
		}
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
        		<div class="rbox-hd">$w{'Peritonitis rate'}</div>
				<div class="rbox-xl">$peritonitis_rate</div>
				<div class="clear-l"></div>
        		<div class="rbox-st">$w{'months between episodes'}</div>
				<div class="rbox-fp">
        			<div>$months_at_risk_rounded $w{'patient-months of peritoneal dialysis at risk'}</div>
        			<div>$peritonitis_occurence $w{'new cases of peritonitis in'} $patients_peritonitis patients</div>
        			<div>$patients_at_risk_new $w{'patients at risk'}</div>
        			<div>$patients_peritonitis_free $w{'patients peritonitis-free'}</div>
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
			if ($ps ne '') {
				if ($pathogens{$ps} eq '') {
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
		my $name = $w{$key};
		if ($name eq '') {
			$name = $key;
		}
		# $name =~ s/species/<em>spp<\/em>/g;
		# $name =~ s/negative/-ve/g;
		# $name =~ s/\(Gram //g;
		# $name =~ s/ve\)/ve/g;
		if ($width < 1) {
			$width = 1;
		}
		if ($percent < 1) {
			$percent = qq{&lt;1};
		}
		$print .= qq{
			<div class="sml">
				<div style="float:left; display:block; height:11px; width:} . $width . qq{\%; background-color:$color;"></div>
				<div class=''>&nbsp;<span class="b txt-blk">$percent\%</span> <span class="txt-blk">$name</span> &nbsp; <span class="gt">$quantity</span></div>
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
		if ($a ne '') {
			if ($antibiotics{$a} eq '') {
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
		if ($percent < 1) {
			$percent = qq{&lt;1};
		}
		my $name = $key;
		$print .= qq{
			<div class="sml">
				<div style="float:left; display:block; height:11px; width:} . $width . qq{\%; background-color:$color;"></div>
				<div class=''>&nbsp;<span class="b txt-blk">$percent\%</span> <span class="txt-blk">$name</span> &nbsp; <span class="gt">$quantity</span></div>
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