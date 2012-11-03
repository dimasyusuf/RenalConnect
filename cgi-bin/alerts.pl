#!/usr/bin/perl

use lib "lib";
use ptms::io;
use strict;

my $payload;
my @sid = &ptms::io::get_sid();
my %p = &ptms::io::params();
%p = &ptms::io::check_expire(\%p);
my %local_settings = &ptms::io::get_local_settings();

if ($p{"do"} eq "logout") {
	my $uid = &ptms::io::logout(\%p);
	my $get = &ptms::io::viewer(\%p);
	$payload = qq{
		<body onload="ajax('div_main','transfer');">
			<div id="transfer">$get</div>
		</body>};
} else {
	my $view_alerts;
	if ($sid[2] ne "") {
		$view_alerts = &ptms::io::get_alerts(\%p);
	}
	$payload = qq{
		<body onload="ajax_page('alerts','alerts');">
			<div id="alerts">$view_alerts</div>
		</body>};
}
print $sid[0] . qq{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="refresh" content="10;url=alerts.pl"/>
	<title>RenalConnect</title>
	<style type="text/css" media="all">\@import "/main.css";</style>
	<script src="/date.js" type="text/javascript"></script>
	<script src="/main.js" type="text/javascript"></script>
</head>
$payload
</html>};