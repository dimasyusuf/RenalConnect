#!/usr/bin/perl

use lib "lib";
use ptms::io;
use strict;

my $q = &ptms::io::get_q();
my @sid = &ptms::io::get_sid();
my $token = $sid[1];
my %p = &ptms::io::params();
my %local_settings = &ptms::io::get_local_settings();

my $header = &ptms::io::header("Password Recovery");
my $footer = &ptms::io::footer();
my $iframe = &ptms::io::iframe();
my $htdocs = &ptms::io::get_path_htdocs();
my $domain = &ptms::io::get_http_domain();
my $msgs;

@sid = &ptms::io::get_sid();

if ($p{"do"} eq "reset_password" and $p{"param_email"} ne "") {
	my $confirm_email = &ptms::io::fast(qq{SELECT email FROM ptms_users WHERE email="$p{"param_email"}" AND deactivated="0"});
	if ($confirm_email ne "") {
		my $reset_password = substr(rand(),3,11);
		my $encrypted_pass = &ptms::io::encrypt($reset_password);
		&ptms::io::input(qq{UPDATE ptms_users SET password="$encrypted_pass" WHERE email="$confirm_email"});
		my %mail = (
			"to" => $confirm_email,
			"from" => $local_settings{"email_sender_from"};
			"subject" => "Password Recovery",
			"body" => qq{Hello,\n\nSomeone, hopefully you, have requested to reset your password for your RenalConnect application. Your password has been reset to: $reset_password\n\nPlease use the following updated account information to access RenalConnect.\n\nUsername: $confirm_email\nPassword: $reset_password\n\nWe strongly recommend that you delete this email and create a new, personalized password immediately.\n\nBest regards,\nThe RenalConnect Team\n}
		);
		my $reply = &ptms::io::mailer(\%mail);
		$msgs = qq{<div class="suc"><span class="b">A temporary password has been sent to &quot;$confirm_email&quot;.</span> Please check this email account in the next few minutes. If you do not receive the email in the next hour, please check your junk mail folder, or contact your peritoneal dialysis team leader for further assistance.</div><div class="hide">$reply</div>};
	} else {
		$msgs = qq{<div class="emp"><span class="b">The user with the email address &quot;$p{"param_email"}&quot; is currently not a registered and active user in the system.</span> Please contact your peritoneal dialysis team leader for further assistance.</div>};
	}
}
print $sid[0] . $header . qq{
	<body>
		<div id="div_all" class="div_all">
			<div id="div_main">
				<div class="w800 p30to align-middle">
					<div class="bg-cloud">
						<div class="align-middle w360 p100to">
							<img src="$htdocs/images/img_logo_rc_new.png" alt="RenalConnect"/>
							<form name="form_login" action="password.pl" method="post" accept-charset="utf-8">
								<input type="hidden" name="token" value="$token"/>
								<input type="hidden" name="do" value="reset_password"/>
								<div class="p10 gt">Have you lost your password? You may use this form to reset your password by email. Please enter your RenalConnect email address and then submit the form, to have a temporary password sent to your email address. If you can't remember the email address you use to access this system, or if you are unsure whether you have an account, please ask your peritoneal dialysis team leader.</div>
								<div class="p10bo">$msgs</div>
								<table>
									<tbody>
										<tr>
											<td class="tr gt w60">Email</td>
											<td class="tl p10lo"><div class="itt w250"><input type="text" class="itt" name="param_email"/></div></td>
										</tr><tr>
											<td class="">&nbsp;</td>
											<td class="tl p10to p10lo">
												<input type="submit" value="Submit"/></td>
										</tr>
									</tbody>
								</table>
								<div class="p10 gt"><a href="index.pl" class="b">&laquo; return to sign in screen</a></div>
							</form>
						</div>
					</div>
				</div>
			</div>
		</div>
		$iframe
		<div id="div_pop_up_bg" class="hide">
			<div id="div_pop_up_container">
				<div id="div_pop_up_top"></div>
				<div id="div_pop_up_mid">
					<div id="div_pop_up"></div>
				</div>
				<div id="div_pop_up_bot"></div>
			</div>
		</div>
		<div id="def" class="hide"><img src="$htdocs/images/img_definitions.png" alt="Definitions"/></div>} . $footer;