#!/usr/bin/perl -w 



$RPMDB='./rpmfile';

$ARGS=@ARGV; #得到参数个数

if( $ARGS==0 ){
	print "aix rpm package install tool\n";
	print "Usage:\n";
	print "------------------------------\n";
	print "yum.pl <search> [packagename] \n";
	print "yum.pl <install> [packagename] \n";
	print "------------------------------\n";
	print "example: \n";
	print "\tyum.pl search git \n\n";

	exit 0 ;
}

sub getdeps{
	my ($rpmfile)=@_;

	@haha=readpipe("./getdeps.sh $rpmfile");
	return @haha;
}


sub isInstall{
	my ($rpmfile)=@_;
	$rpmfile=~ s/\.aix5\.1\.ppc\.rpm//g;
	$rpmfile=~ s/\.aix5\.2\.ppc\.rpm//g;
	$rpmfile=~ s/\.aix5\.3\.ppc\.rpm//g;
	$rpmfile=~ s/\.aix6\.1\.ppc\.rpm//g;
	$rpmfile=~ s/\.aix7\.1\.ppc\.rpm//g;
my $cmd=<<EOF;
rpm -qa|grep ${rpmfile}
EOF
my $rets=`$cmd`;
	if (length($rets)==0){
		return 0;   #没有安装
	}else{
		return 1;   #安装过了
	}

}


sub instSoft{
	my ($rpmfile)=@_;
        @deps=getdeps($rpmfile);	
	$depsnum=@deps;
	if($depsnum>1){  # 1是已经安装 0 是安装成功  其它的是失败
		foreach(@deps){
			my $ret=instSoft($_);	
		}
	}
	
}


print "-------------------------------------\n";
# 1是已经安装 0 是安装成功  其它的是失败

sub getRecuDeps{
	my ($rpmfile,$level)=@_;
	my @returns=();
	
	chomp($rpmfile);
	push(@returns,$rpmfile);
	
        my @deps=getdeps($rpmfile);	
	my $depsnum=@deps;
	if($depsnum>0){  # 1是已经安装 0 是安装成功  其它的是失败
		push(@returns,@deps);
		
		foreach(@deps){
			my @ret=getRecuDeps($_,$level+1);	
				foreach(@ret){
#					for( my $j=0; $j<$level; $j++)  { print "-"; }
#					printf(">$_ ||\n");
				}
			push(@returns,@ret);
		}
	}
	my @array2;
	foreach(@returns){
		chomp($_);
		if(isInstall($_)==0	){
			push(@array2,$_);
		}else{
			printf("%40s already installed\n",$_);
		}
	}
	return  @array2;
}

if($ARGV[0] eq  "search" ) {
	my @filelist=`cd ./$RPMDB/ && ls $ARGV[1]*.rpm`;
	foreach (@filelist){
		 chomp($_);
                my $inst=isInstall($_)  ?"installed":"noinstall";
                printf("%-40s    [%10s ]\n",$_,$inst);
	}
	exit 0;

}

if($ARGV[0] eq "test"){
}

if($ARGV[0] eq "update"){

	unless ( -d "db" ){
		`mkdir db`;
	}

	my @files=`ls ./$RPMDB/*.rpm`;
	foreach(@files){
	my	$rets=`./rpminfo.sh $_`;
		print $rets;
	}
}

if($ARGV[0] eq  "install" ) {
	unless ( -f  "./$RPMDB/$ARGV[1]"){
		print "$ARGV[1] not existed\n";	
	}
	
#	@myfail=();

	print "---------------------------------\n";
	print "-----------开始分析依赖----------\n";
	my @retus=getRecuDeps("$ARGV[1]",1);

	print "---------------------------------\n";
	print "-----------开始安装软件----------\n";

	chomp(@retus);
	my %hash;

	@array = grep { ++$hash{$_} < 2 } @retus;

	$list1=join(" ",@array);	
	
	print $list1;
	print "\n";
	system("cd $RPMDB && rpm -i $list1");
	
=pod
	
	for(my $i=$#retus;$i>-1;$i--){
		my $rpmfile=$retus[$i];
		chomp($rpmfile);
		print $rpmfile,"\n";
		my $rt=system("rpm -i ./rpmfile/$rpmfile");	
		if($rt!=256){
			  print "error $rt:$rpmfile\n";
			  push(@myfail,$rpmfile);
		}
	}
	

	print "---------------------------------\n";
	print "---install fail's package list---\n";	
	foreach(@myfail){
		print "$_";
	}
	
=cut
	exit 0
}

