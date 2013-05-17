#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use CGI::Fast;
use Time::HiRes;
my $start_time = Time::HiRes::time;
my $q = CGI::Fast->new;
my $course_id = $q->param('course_id');    

print "Content-type: text/html\n\n";

#header
print  <<"EOM";
<html>
<head><meta http-equiv="Content-type" content="text/html; charset=Shift_JIS">
</head>
<title>Training DB</title>
<body>
<a href="main.pl?mode=main">Top</a> |
<a href="main.pl?mode=create">create course</a> |
<a href="main.pl?mode=all">all course</a> |
<hr>
EOM

my $dbh =DBI->connect("DBI:mysql:training_db", "root", "",{
		AutoCommit=>0,RaiseError=>1,PrintError=>0}) || die;

my $sql = "delete from course where course_id = '$course_id'";

my $sth = $dbh->prepare($sql);
if(!$sth->execute){
print "SQL失敗\n";
exit;
}

print "<h3>course deleted.</h3>\n";
print "$course_id deleted.<br>\n";
print qq|<a href="main.pl?mode=main">go top</a>\n|;


print "<hr>\n";
print qq|<Div Align="right">Shian Izumida Webapp.</Div>\n|;
printf("DEBUG:elapsed time:%f  mili second\n",(Time::HiRes::time - $start_time)*1000);
print "</body>\n";
print "</html>\n";
