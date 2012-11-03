#!/usr/bin/perl

use lib "lib";
use ptms::io;
use strict;

my $q = &ptms::io::get_q();
my @sid = &ptms::io::get_sid();
my %p = &ptms::io::params();
my %local_settings = &ptms::io::get_local_settings();

my $header = &ptms::io::header("Welcome");
my $footer = &ptms::io::footer();
my $viewer = &ptms::io::viewer(\%p);
my $iframe = &ptms::io::iframe();
my $htdocs = &ptms::io::get_path_htdocs();

@sid = &ptms::io::get_sid();

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
	<div id="def" class="hide"><img src="$htdocs/images/img_definitions.png" alt="Definitions"/></div>} . $footer;