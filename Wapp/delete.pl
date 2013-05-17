#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use CGI::Fast;
use Time::HiRes;
my $start_time = Time::HiRes::time;
my $q = CGI::Fast->new;
my $mode = $q->param('mode');    

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

my $sql = "select course_title,";
   $sql .= "topic,";
   $sql .= "day_length, price, level_id, category from course where course_id = '$mode'";

my $sth = $dbh->prepare($sql);
if(!$sth->execute){
print "SQL失敗\n";
exit;
}

my @rec = $sth->fetchrow_array();
print <<EOM;
<h3>delete this course?</h3>
<p>
<form action=deleted.pl method="post">
<table border>
<tr><th>course_id</th>
<td> <input type="hidden" name="course_id" value="$mode">$mode</td></tr>
<tr><th>course_title</th>
<td><input type="hidden" name="course_title" value="$rec[0]" size="20">$rec[0]</td></tr>
<tr><th>topic</th>
<td><input type="hidden" name="topic" value="$rec[1]" size="20">$rec[1]</tr>
<tr><th>day_length</th>
<td><input type="hidden" name="day_length" value="$rec[2]" size="20">$rec[2]</td></tr>
<tr><th>price</th>
<td><input type="hidden" name="price" value="$rec[3]" size="20">$rec[3]</td></tr>
<tr><th>level_id</th> 
<td><input type="hidden" name="level_id" value="$rec[4]" size="20">$rec[4]</td></tr>
<tr><th>category</th>
<td><input type="hidden" name="category" value="$rec[5]" size="20">$rec[5]</td></tr>
</table>
<br>
Are you sure ?
<input type="submit" value="消去">
</p>
</form>
EOM


#fooder
print "<hr>\n";
print qq|<Div Align="right">Shian Izumida Webapp.</Div>\n|;
printf("DEBUG:elapsed time:%f  mili second\n",(Time::HiRes::time - $start_time)*1000);
print "</body>\n";
print "</html>\n";
