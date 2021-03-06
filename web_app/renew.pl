#!/usr/bin/perl
use strict;
use CGI::Fast;
use DBI;
use Time::HiRes;
my $start_time = Time::HiRes::time;
my $q = CGI::Fast->new;

print "Content-type: text/html\n\n";

print  <<EOM;
<html>
<head>
<meta http-equiv="Content-type" content="text/html; charset=Shift_JIS">
<title>Training DB</title>
</head>
<body>
<a href="main.pl?mode=main">Top</a> |
<a href="main.pl?mode=create">create course</a> |
<a href="main.pl?mode=all">all course</a> |
<hr>
EOM

my $course_id = &sanitize($q->param('course_id'));
my $course_title = &sanitize($q->param('course_title'));
my $day_length = &sanitize($q->param('day_length'));
my $price = &sanitize($q->param('price'));
my $day_length = &sanitize($q->param('day_length'));
my $level_id = &sanitize($q->param('level_id'));
my $topic = &sanitize($q->param('topic'));
my $category = &sanitize($q->param('category'));
#入力時エラー確認
if(
	$course_id !~ /^[a-zA-Z0-9-]{1,20}$/ || 
	$course_title !~ /^.{1,50}$/ || 
	$topic !~ /^.{0,100}$/ || 
	$day_length !~ /^[1-9][0-9]?$/|| 
	$price !~ /^\d{1,6}$/ || 
	$level_id !~ /^[1-5]$/ || 
	$category !~ /^[a-zA-Z0-9-]{1,20}$/
){
	&validation_error();
}else{

	my $dbh =DBI->connect("DBI:mysql:training_db", "root", "",{
	AutoCommit=>0, RaiseError=>1,PrintError=>0}) || die;

if(!$dbh){
	print "接続失敗\n";
	exit;
}


my $sql = "update course set ";
   $sql .= "course_title=?,";
   if(" . $q->param('topic') ." ne ""){
	   $sql .= "topic=?,";
   }
   $sql .= "day_length=?,";
   $sql .= "price=?,";
   $sql .= "level_id=?,";
   $sql .= "category=?";
   $sql .= "where course_id =?";
 
my $sth = $dbh->prepare($sql);
	$sth->bind_param(1,$course_title);
	$sth->bind_param(2,$topic);
	$sth->bind_param(3,$day_length);
	$sth->bind_param(4,$price);
	$sth->bind_param(5,$level_id);
	$sth->bind_param(6,$category);
	$sth->bind_param(7,$course_id);

if(!$sth->execute){
	print "SQL失敗\n";
	exit;
}
$sth->finish;
$dbh->disconnect;

print <<EOM;
<h3>course created.</h3>
<a href="delete.pl?mode=$course_id">delete this course? ...</a>
<p>
<form action=renew.pl method="post">
<table border>
<tr><th>course_id</th>
<td> <input type="hidden" name="course_id" value="$course_id">$course_id</td></tr>
<tr><th>course_title</th>
<td><input type="text" name="course_title" value="$course_title" size="20"></td></tr>
<tr><th>topic</th>
<td><textarea type="text" name="topic" cols="20" rows="3">$topic</textarea></tr>
<tr><th>day_length</th>
<td><input type="text" name="day_length" value="$day_length" size="20"></td></tr>
<tr><th>price</th>
<td><input type="text" name="price" value="$price" size="20"></td></tr>
<tr><th>level_id</th> 
<td><input type="text" name="level_id" value="$level_id" size="20"></td></tr>
<tr><th>category</th>
<td><input type="text" name="category" value="$category" size="20"></td></tr>
</table>
<br>
<input type="submit" value="更新">
</p>
</form>
EOM
}
#フッダー
print "<hr>\n";
print qq|<Div Align="right">Shian Izumida Webapp.</Div>\n|;
printf("DEBUG:elapsed time:%f  mili second\n",(Time::HiRes::time - $start_time)*1000);
print "</body>\n";
print "</html>\n";


#---------------------
#サニタイジング
#---------------------
sub sanitize{
	my  $html = $_[0];
#	$html =~ s/ //g; #空白を削除
	$html =~ s/&/&amp/g;
	$html =~ s/</&lt/g;
	$html =~ s/>/&gt/g;
	$html =~ s/"/&qeot/g;
	$html =~ s/'/&#39/g;
	return $html;
}
#------------------------
#認証失敗
#------------------------
sub validation_error{

	print "<h3>validation error</h3>\n";

	if($course_id !~ /^[a-zA-Z0-9-]{1,20}$/){
		print "course_id is not valid.<br>\n";
	}
	if($course_title !~ /^.{1,3}$/){
		print "course_title is not valid.<br>\n";
	}
	if($topic !~ /^.{0,100}$/){
		print "topic less than 101 words.<br>\n";
	}
	if($day_length !~ /^[1-9][0-9]?$/){
		print "day_length between 1 and 99.<br>\n";
	}
	if($price !~ /^\d{1,6}$/){
		print "price between 0 and 999999.<br>\n";
	}
	if($level_id !~ /^[1-5]$/){
		print "level_id between 1 and 5.<br>\n";
	}
	if($category !~ /^[a-zA-Z0-9-]{1,20}$/){
		print "category is required and less than 40 characters.<br>\n";
	}

	print qq|<a href="main.pl?mode=main">browser back or click.</a>\n|;
}
