#!/usr/bin/perl

use lib "lib";
use rc::io;
use strict;

my $q = &rc::io::get_q();
my @sid = &rc::io::get_sid();
my $token = $sid[1];
my %p = &rc::io::params();
my %w = &rc::io::get_w();
my %local_settings = &rc::io::get_local_settings();

my $header = &rc::io::header("Get Technical Support");
my $footer = &rc::io::footer();
my $iframe = &rc::io::iframe();
my $htdocs = $local_settings{"path_htdocs"};
my $domain = $local_settings{"http_domain"};
my $msgs;

@sid = &rc::io::get_sid();

my $form = qq{
	<table>
		<tbody>
			<tr>
				<td class="tr gt w60">$w{'Email_uc'}</td>
				<td class="tl p10lo"><div class="itt w250"><input type="text" class="itt" name="param_email" value="$p{'param_email'}"/></div></td>
			</tr><tr>
				<td class="tr gt w60">$w{'Message'}</td>
				<td class="tl p10lo"><div class="itt w250"><textarea class="itt" name="param_message" rows="5"/>$p{'param_message'}</textarea></div></td>
			</tr><tr>
				<td class="tl gt w60">&nbsp;</td>
				<td class="tl p10lo p10to p10bo"><input type="submit" value="$w{'Submit'}"/></td>
			</tr>
		</tbody>
	</table>};

if ($p{'do'} eq "get_support") {
	if ($p{"param_email"} ne '' and $p{'param_message'} ne '') {
		my %mail = (
			"to" => $local_settings{"email_support_to"},
			"from" => $local_settings{"email_sender_from"},
			"cc" => $p{"param_email"},
			"bcc" => $local_settings{"email_support_bcc"},
			"subject" => $w{'Request for Technical Assistance'},
			"body" => qq{$w{'w_request_letter_part_1'} $p{"param_email"}:\n\n$w{'w_request_letter_part_2'}\n\n$p{'param_message'}\n\n$w{'w_request_letter_part_3'}}
		);
		my $reply = &rc::io::mailer(\%mail);
		$msgs = $w{'w_request_confirmed'};
		$form = qq{};
	} else {
		$msgs = qq{<div class="emp">$w{'w_error_information_cant_be_saved'}</div>};
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
							<form name="form_login" action="support.pl" method="post" accept-charset="utf-8">
								<input type="hidden" name="do" value="get_support"/>
								<input type="hidden" name="token" value="$token"/>
								<div class="p10 gt">$w{'w_request_blurb'}</div>
								<div class="p10bo">$msgs</div>
								$form
							</form>
							<a href="index.pl" class="b">&laquo; $w{'return to sign in screen'}</a>
						</div>
					</div>
				</div>
			</div>
			$iframe
		</div>
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