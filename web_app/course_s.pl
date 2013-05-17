#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use CGI::Fast;
use Time::HiRes;
my $start_time = Time::HiRes::time;
my $q = CGI::Fast->new;
my $mode = $q->param('mode');    
my $key = $q->param('key');

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

my $sql = "select course_id, course_title,";
   $sql .= "topic,";
   $sql .= "day_length, price, level_id, category from course where course_id = '$mode'";

my $sth = $dbh->prepare($sql);

if($key){ 
  	my $sth;
	my $sql;
	&key;
}

if(!$sth->execute){
print "SQL失敗\n";
exit;
}

my @rec = $sth->fetchrow_array();

print <<EOM;
<h3>single course</h3>
<a href="delete.pl?mode=$rec[0]">delete this course? ...</a>
<p>
<form action=renew.pl method="post">
<table border>
<tr><th>course_id</th>
<td> <input type="hidden" name="course_id" value="$rec[0]">$rec[0]</td></tr>
<tr><th>course_title</th>
<td><input type="text" name="course_title" value="$rec[1]" size="20"></td></tr>
<tr><th>topic</th>
<td><textarea type="text" name="topic" cols="20" rows="3">$rec[2]</textarea></tr>
<tr><th>day_length</th>
<td><input type="text" name="day_length" value="$rec[3]" size="20"></td></tr>
<tr><th>price</th>
<td><input type="text" name="price" value="$rec[4]" size="20"></td></tr>
<tr><th>level_id</th> 
<td><input type="text" name="level_id" value="$rec[5]" size="20"></td></tr>
<tr><th>category</th>
<td><input type="text" name="category" value="$rec[6]" size="20"></td></tr>
</table>
<br>
<input type="submit" name="renewd" value="更新">
</p>
</form>
EOM



#fooder
print "<hr>\n";
print qq|<Div Align="right">Shian Izumida Webapp.</Div>\n|;
printf("DEBUG:elapsed time:%f  mili second\n",(Time::HiRes::time - $start_time)*1000);
print "</body>\n";
print "</html>\n";

sub key{

print "$key\n";
$key = "%$key%";
   $sql = "select course_id, course_title, topic, day_length, price, level_id, category";
   $sql .= " where course_id like ? or";
   $sql .= " course_title like ? or";
   $sql .= " topic like ? or";
   $sql .= " day_length like ? or";
   $sql .= " price like ? or";
   $sql .= " level_id like ? or";
   $sql .= " category like ?";

   $sth = $dbh->prepare($sql);
   $sth->bind_param(1,$key);
   $sth->bind_param(2,$key);
   $sth->bind_param(3,$key);
   $sth->bind_param(4,$key);
   $sth->bind_param(5,$key);
   $sth->bind_param(6,$key);
   $sth->bind_param(7,$key);

   print "3hoge\n";
  if(!$sth->execute){
	print "SQL失敗\n";
	exit;
}
  print "2hoge\n";
   my @rec = $sth->fetchrom_array;
   return @rec;
}
