#!/usr/bin/perl
use strict;
use warnings;
#use CGI::Fast;
use DBI;
use Time::HiRes;
my $start_time = Time::HiRes::time;
print "Content-type: text/html\n\n";
print  <<"EOM";
<html>
<head>
<meta http-equiv="Content-type" content="text/html; charset=Shift_JIS">
</head>
<body>
<a href="main.pl?mode=main">Top</a> |
<a href="main.pl?mode=create">create course</a> |
<a href="main.pl?mode=all">all course</a> |
<hr>
EOM

my $dbh =DBI->connect("DBI:mysql:training_db", "root", "",{
		AutoCommit=>0,RaiseError=>1,PrintError=>0}) || die;
 
if(!$dbh){
       	print "接続失敗\n";
      	exit; 
}

my $sql = "select course_id, course_title, price, level_id, category from course order by course_id";
print "eee\n";
my $sth = $dbh->prepare($sql);
print "aaa\n";
if(!$sth->execute){
       		print "SQL失敗\n";
	      	exit;
	}
print "rrr\n";
 #結果出力

 print "<table border=1>\n";
 print "<tr><th>course_id</th><th>title</th><th>price</th><th>lev    el_id</th><th>category</th></tr>\n";
 while(my @rec = $sth->fetchrow_array()) {
	 print "<tr>\n";
         print "<td>" . $rec[0] . "</td>\n";
	 print "<td>" . $rec[1] . "</td>\n";
	 print "<td>" . $rec[2] . "</td>\n";
	 print "<td>" . $rec[3] . "</td>\n";
	 print "<td>" . $rec[4] . "</td>\n";
	 print "</tr>\n";
 }
 print "</table>\n";
 
 $sth->finish;
 $dbh->disconnect;
print "<hr>\n";
print qq|<Div Align="right">Shian Izumida Webapp.</Div>\n|;
printf("DEBUG:elapsed time:%f  mili second\n",(Time::HiRes::time - $start_time)*1000);
print "</body>\n";
print "</html>\n";
