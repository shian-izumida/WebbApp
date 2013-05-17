#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use CGI::Fast;
use Time::HiRes;
use Digest::SHA1 qw(sha1_base64);
my $start_time = Time::HiRes::time;


#テンプレートファイル(コース作成用)
my $create_course = "../../html/WA/tmpl/create.html";

#テンプレートファイル(コース完成後)
my $created_course = "../../html/WA/tmpl/created.html";


#---------------------
#設定完了
#---------------------
my $mode;
my $post_data;
my $course_id; 
my $course_title;
my $topic;
my $day_length;
my $price;
my $level_id;
my $category;
my $dbh;
my $renew;
my $key;
my $cat;

&parse_form;
&header();
if($mode eq "main"){ &main; }
if($mode eq "create"){ &create; }
if($mode eq "all"){ &all_course;}
if($key ne ""){ &key; }
if($cat ne ""){ &cat; }
if($post_data){ &post_data; }
if($mode eq "" && $post_data eq "" &&  $cat eq "" && $key eq ""){&main;}
&fooder();


#---------------------
#トップ画面表示
#---------------------
sub main{
#トップ画面
	my $skey = &create_key();
print <<EOM;
<h3>Training DB Webapp</h3>
<img src="../../icons/logomysql.png" alt='logo' width='85' height='56.6'>

<h3>Search</h3>
<a href="main.pl?mode=all">all course</a>
<p>
<form action="serch_key.pl" method="post">
	keyword:
	<input type="hidden" name="request_key" value="$skey">
	<input type="text" name="key" size="35">
	<input type="submit" value="送信"><br>
</form>
<form action ="serch_cat.pl" method="post">
	category:
	<input type="hidden" name="request_key" value="$skey">
	<input type="text" name="cat" size="35">
	<input type="submit" value="送信"><br>
</p>
</form>
EOM
}

#----------------------
#createフォーム表示
#----------------------
sub create{
	#createフォーム表示
	open IN, "$create_course";
	print "<h3> new course</h3>";
	print <IN>;
	close(IN);
}

#----------------------
#全登録コースの表示
#----------------------
sub all_course{

	print "<h3>all course</h3>";

	&dbh();
#件数取得
my $sql = "select count(*) from course ";

my $sth = $dbh->prepare($sql);
if(!$sth->execute){
	print "SQL失敗\n";
	exit;
}
my @rec = $sth->fetchrow_array;
print "rows...$rec[0]\n";

#SQL実行  
$sth = $dbh->prepare(
	"SELECT course_id, course_title, price, level_id, category 
	FROM course
	ORDER BY course_id");
	    
	    if(!$sth->execute){
		    print "SQL失敗\n";
		    exit;
	    }
	    #結果出力
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
}

#---------------------
#新コース挿入
#---------------------
sub post_data{
	#入力時エラー確認
	if(	$course_id !~ /^[a-zA-Z0-9-]{1,20}$/ || 
		$course_title !~ /^.{1,50}$/ || 
		$topic !~ /^.{0,100}$/ || 
		$day_length !~ /^[1-9][0-9]?$/|| 
		$price !~ /^\d{1,6}$/ || 
		$level_id !~ /^[1-5]$/ || 
		$category !~ /^[a-zA-Z0-9-]{1,20}$/
		){
			&validation_error();
	}
	else
	{
	#コース挿入
	&dbh();
	
	#重複チェック
	my $sql = "select count(*) from course ";
	   $sql .= "where course_id = $course_id";
	
	my $sth = $dbh->prepare($sql);
	if(!$sth->execute){
		print "SQL失敗\n";
		exit;
	}
	my @rec = $sth->fetchrow_array;
	if($rec[0] > 0){
		print "<h3>validation error</h3>\n";
		print "PK duplicate error<br>\n";
		print qq|<a href="main.pl?mode=main">back to top.</a>\n|;
	}else{
		my $sth = $dbh->prepare(
			"INSERT INTO course 
			VALUES(?,?,?,?,?,?,?)");

		$sth->bind_param(1,$course_id);
		$sth->bind_param(2,$course_title);
		$sth->bind_param(3,$topic);
		$sth->bind_param(4,$day_length);
		$sth->bind_param(5,$price);
		$sth->bind_param(6,$level_id);
		$sth->bind_param(7,$category);
		if(!$sth->execute){
			    print "SQL失敗\n";
			    exit;
		    }
		$sth->finish;
		$dbh->disconnect;
		#コース完成ページ表示
		&renew();
		}
	}
}

#----------------------
#更新ページ
#----------------------
sub renew{
print <<EOM;
<h3>course created.</h3>
<a href="delete.pl?mode=$course_id">delete this course? ...</a>
<p>
<form action="renew.pl?" method="post">
<table border>
<tr><th>course_id</th>
<td> <input type="hidden" name="course_id" value="$course_id" size="20"> $course_id</td></tr>
<tr><th>course_title</th>
<td><input type="text" name="course_title" value="$course_title" size="20"></td></tr>
<tr><th>topic</th>
<td><textarea type="text" name="topic" cols="20" rows="3">$topic</textarea></td></tr>
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
<input type="submit" name="renewd" value="送信">
</p>
</form>
EOM
} 	
#----------------------
#ヘッダーの設定
#----------------------
sub header{
	my $ttl ='Training DB';	

	print "Content-type: text/html\n\n";
    	print  <<"EOM";
<html>
<head>
<meta http-equiv="Content-type" content="text/html; charset=Shift_JIS">
<title>$ttl</title>
</head>
<body>
<a href="main.pl?mode=main">Top</a> |
<a href="main.pl?mode=create">create course</a> |
<a href="main.pl?mode=all">all course</a> |
<hr>
EOM
	}

#----------------------
#フッダーの設定
#----------------------
sub fooder{
print "<hr>\n";
print qq|<Div Align="right">Shian Izumida Webapp.</Div>\n|;
printf("DEBUG:elapsed time:%f  mili second\n",(Time::HiRes::time - $start_time)*1000);
print "</body>\n";
print "</html>\n";
}
#---------------------
#DB接続
#---------------------
sub dbh{
	$dbh =DBI->connect("DBI:mysql:training_db", "root", "",{
		AutoCommit=>0,RaiseError=>1,PrintError=>0}) || die;
}


#---------------------
#サニタイジング
#---------------------
sub sanitize{
	my  $html = $_[0];
	$html =~ s/ //g; #スペースを削除
	$html =~ s/&/&amp/g;
	$html =~ s/</&lt/g;
	$html =~ s/>/&gt/g;
	$html =~ s/"/&qeot/g;
	$html =~ s/'/&#39/g;
	return $html;
}

#----------------------
#htmlファイルのオープン
#----------------------
sub parse_form{
	my $q = new CGI::Fast();

	#tableのコース取得
	$course_id = &sanitize($q->param("course_id"));
	$course_title = &sanitize($q->param("course_title"));
	$topic = &sanitize($q->param("topic"));
	$day_length = &sanitize($q->param("day_length"));
	$price = &sanitize($q->param("price"));
	$level_id = &sanitize($q->param("level_id"));
	$category = &sanitize($q->param("category"));

	$mode = &sanitize($q->param('mode'));
	$post_data = $q->param('post_data'); #コース挿入
	$key = &sanitize($q->param('key'));#keyword
	$cat = &sanitize($q->param('cat'));#category
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


#-----------------------
#認証key作成
#-----------------------
sub create_key{
	 my $secret = &_getSecretKey();
	 my $ip = $ENV{'REMOTE_ADDR'};
	 my $msec = Time::HiRes::time();

	 my $skey = $msec . "-" .sha1_base64($msec . $ip . $secret);
	 return $skey;
 }

 sub _getSecretKey{
	 	my $skeyfile = "/var/www/html/secret-key.txt";
		open(F, "<$skeyfile") || return -1;
		my $skey = <F>;
		chomp($skey);
		close(F);
		return $skey;
	}

#-----------------------
#key認証
#-----------------------
sub _checkKey{
	my $secret = &_getSecretKey();
	print "\$secret = $secret<br>\n";
	my $q = new CGI();
	my $ip = $ENV{'REMOTE_ADDR'};
	
	#my $reqKey = "mysql";
	my $reqKey = $q->param('request_key');
	print "\$reqKey = $reqKey<br>\n";
	my ($msec, $k) = split(/-/, $reqKey);
	my $calcKey = $msec . '-' . sha1_base64($msec . $ip . $secret);
	print "\$calcKey = $calcKey<br>\n";
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
