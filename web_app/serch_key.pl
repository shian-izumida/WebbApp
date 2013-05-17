#!/usr/bin/perl
use strict;
use warnings;
use CGI::Fast;
use DBI;
use Time::HiRes;
use Digest::SHA1 qw(sha1_base64);

my $start_time = Time::HiRes::time;

my $q = CGI::Fast->new;
my $top = "../../WA/tmpl/top.html";
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

if( &_checkKey() != 1){
	print "Error\n";
	return -1;
}

my $key = $q->param('key');
#入力が無い場合はトップページへ
if($key eq ""){
	print qq|<meta http-equiv="Refresh" content="0;
	URL=main.pl">\n|;  
	print "</body></html>\n";
	return -1;
}


print "<h3>found courses</h3>\n";
my $dbh =DBI->connect("DBI:mysql:training_db", "root", "",{
		AutoCommit=>0, RaiseError=>1,PrintError=>0}) || die;
 
if(!$dbh){
	print "接続失敗\n";
	exit;
}
#件数取得
my $sql = "select count(*) from course ";
$sql .= "where course_id like ? or";
$sql .= " course_title like ? or";
$sql .= " topic like ? or";
$sql .= " day_length like ? or";
$sql .= " price like ? or";
$sql .= " level_id like ? or";
$sql .= " category like ? ";
my $sth = $dbh->prepare($sql);
$sth->bind_param(1,$key);
$sth->bind_param(2,$key);
$sth->bind_param(3,$key);
$sth->bind_param(4,$key);
$sth->bind_param(5,$key);
$sth->bind_param(6,$key);
$sth->bind_param(7,$key);
if(!$sth->execute){
	print "SQL失敗\n";
	exit;
}
my @rec = $sth->fetchrow_array;
print "$rec[0]\n";
if($rec[0] == 1){
 print qq|<meta http-equiv="Refresh" content="0;
	URL=course_s.pl?key=$key">\n|;
	print"</body></html>\n";
	exit;
}

print "rows...$rec[0]\n";
#bind_param用に%つける
$key = "%$key%";


my $sql = "select course_id, course_title, price, level_id, category from course ";
$sql .= "where course_id like ? or";
$sql .= " course_title like ? or";
$sql .= " topic like ? or";
$sql .= " day_length like ? or";
$sql .= " price like ? or";
$sql .= " level_id like ? or";
$sql .= " category like ?";
$sql .= " order by course_id";

my $sth = $dbh->prepare($sql);
$sth->bind_param(1,$key);
$sth->bind_param(2,$key);
$sth->bind_param(3,$key);
$sth->bind_param(4,$key);
$sth->bind_param(5,$key);
$sth->bind_param(6,$key);
$sth->bind_param(7,$key);

if(!$sth->execute){
	print "SQL失敗\n";
	exit;
}

print "<table border=1>\n";
print "<tr><th>course_id</th><th>title</th><th>price</th><th>level_id</th><th>category</th></tr>\n";
while(my @rec = $sth->fetchrow_array()) {
	print "<tr>\n";
	print qq|<td><a href="course_s.pl?mode=$rec[0]"> $rec[0] </a></td>\n|;
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


#-----------------------
#key認証
#-----------------------
sub _checkKey{
	my $secret = &_getSecretKey();
	my $ip = $ENV{'REMOTE_ADDR'};
	
	my $reqKey = $q->param('request_key');
	my ($msec, $k) = split(/-/, $reqKey);
	my $calcKey = $msec . '-' . sha1_base64($msec . $ip . $secret);
	if($reqKey eq $calcKey && $msec > time() -600){
		return 1;
	}
	return -1;
}

sub _getSecretKey{
	my $skeyfile = "/var/www/html/secret-key.txt";
	open (F, "<$skeyfile") || return -1;
	my $skey = <F>;
	chomp($skey);
	close(F);
	return $skey;
}

sub _printError{
	print "認証失敗\n";
}
