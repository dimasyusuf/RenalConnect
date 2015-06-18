#!/usr/bin/perl

use lib "lib";
use rc::io;
use strict;

my $q = &rc::io::get_q();
my @sid = &rc::io::get_sid();
my %p = &rc::io::params();
%p = &rc::io::reset_expire(\%p);
my %local_settings = &rc::io::get_local_settings();
my %w = &rc::io::get_w();

my $header = &rc::io::header("Welcome");
my $footer = &rc::io::footer();
my $viewer = &rc::io::viewer(\%p);
my $iframe = &rc::io::iframe();

@sid = &rc::io::get_sid();

my $check_lock = &rc::io::fast(qq{SELECT value FROM rc_state WHERE uid="$sid[2]" AND param="lock" LIMIT 1});
if ($check_lock eq "1") {
	$check_lock = qq{<script>lock_screen_initiator();</script>};
} else {
	$check_lock = "";
}

print $sid[0] . $header . qq{<body onresize="pop_up_resize();">
	<div id="div_all" class="div_all">
		<div id="div_main">$viewer</div>
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
	<div class="hide" id="lang">$w{'lang'}</div>
	<div id="def" class="hide"><img src="$local_settings{'path_htdocs'}/images/img_definitions.png" alt="Definitions"/></div>
	<div id="lockscreen" class="hide"></div>
	$check_lock
	} . $footer;