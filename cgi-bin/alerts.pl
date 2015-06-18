#!/usr/bin/perl

use lib "lib";
use rc::io;
use strict;

my $payload;
my @sid = &rc::io::get_sid();
my %p = &rc::io::params();
my %local_settings = &rc::io::get_local_settings();

if ($p{'do'} eq "logout") {
	my $uid = &rc::io::logout(\%p);
	my $get = &rc::io::viewer(\%p);
	$payload = qq{
		<body onload="ajax('div_main','transfer');">
			<div id="transfer">$get</div>
		</body>};
} else {
	my $view_alerts;
	if ($sid[2] ne '') {
		$view_alerts = &rc::io::get_alerts(\%p);
	}
	$payload = qq{
		<body onload="ajax('alerts','alerts');">
			<div id="alerts">$view_alerts</div>
		</body>};
}
print $sid[0] . qq{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="refresh" content="1000;url=alerts.pl"/>
	<title>RenalConnect</title>
	<style type="text/css" media="all">\@import "/main.css";</style>
	<script src="/jquery.js"></script>
	<script src="/date.js" type="text/javascript"></script>
	<script src="/main.js" type="text/javascript"></script>
</head>
$payload
</html>};