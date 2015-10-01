#!/usr/bin/perl
#
# copyright Martin Pot 2003
# http://martybugs.net/linux/hddtemp.cgi
#
# Modified by Joseph Lo 2011
# for Buffalo Linkstation LS-QVL/R5 Quad Pro
# http://josephlo.wordpress.com
#
# rrd_hddtemp.pl

#use RRDs;

# define location of rrdtool databases
my $rrd = '/opt/var/lib/rrd';
# define location of images
my $img = '/mnt/disk1/Web/htdocs/rrd';

# process data for each specified HDD (add/delete as required)
&ProcessHDD("sda", "Seagate Barracuda Green 2TB (ST2000DL003) Disk 1");
&ProcessHDD("sdb", "Seagate Barracuda Green 2TB (ST2000DL003) Disk 2");
&ProcessHDD("sdc", "Seagate Barracuda Green 2TB (ST2000DL003) Disk 3");
&ProcessHDD("sdd", "Seagate Barracuda Green 2TB (ST2000DL003) Disk 4");

sub ProcessHDD
{
# process HDD
# inputs: $_[0]: hdd (ie, hda, etc)
#         $_[1]: hdd description

	# get hdd temp for master drive on secondary IDE channel
	my $txt=`smartctl -A -d marvell /dev/$_[0] | grep "194 Temperature_Celsius" | awk '{print $10}'`;

	$txt =~ s/[\n ]//g;  # remove eol chars and white space
	$re1='.*?';		# Non-greedy match on filler
	$re2='\\d+';		# Uninteresting: int
	$re3='.*?';		# Non-greedy match on filler
	$re4='\\d+';		# Uninteresting: int
	$re5='.*?';		# Non-greedy match on filler
	$re6='\\d+';		# Uninteresting: int
	$re7='.*?';		# Non-greedy match on filler
	$re8='(\\d+)';	# Integer Number 1
	$re=$re1.$re2.$re3.$re4.$re5.$re6.$re7.$re8;
	if ($txt =~ m/$re/is)
	{
    		$temp=$1;
	#	Debug purposes only
  	#	print "($temp) \n";
	}
	#	Debug purposes only
	 	print "$_[1] (/dev/$_[0]) temp: $temp degrees C\n";
	
	# if rrdtool database doesn't exist, create it
	if (! -e "$rrd/$_[0].rrd")
	{
		print "creating rrd database for /dev/$_[0]...\n";
		`rrdtool create "$rrd/$_[0].rrd" --step 300 DS:temp:GAUGE:600:0:100 RRA:AVERAGE:0.5:1:576 RRA:AVERAGE:0.5:6:672 RRA:AVERAGE:0.5:24:732 RRA:AVERAGE:0.5:144:1460`;

		# Debug purposes for running in bash shell
		# rrdtool create "$rrd/$_[0].rrd" --step 300 DS:temp:GAUGE:600:0:100 RRA:AVERAGE:0.5:1:576 RRA:AVERAGE:0.5:6:672 RRA:AVERAGE:0.5:24:732 RRA:AVERAGE:0.5:144:1460;
	}

	# insert value into rrd
	`rrdtool update "$rrd/$_[0].rrd" -t temp N:$temp`;

	# create graphs
	&CreateGraph($_[0], "day", $_[1]);
	&CreateGraph($_[0], "week", $_[1]);
	&CreateGraph($_[0], "month", $_[1]);
	&CreateGraph($_[0], "year", $_[1]);
}

sub CreateGraph
{
# creates graph
# inputs: $_[0]: hdd name (ie, hda, etc)
#         $_[1]: interval (ie, day, week, month, year)
#         $_[2]: hdd description

	`rrdtool graph "$img/$_[0]-$_[1].png" -S "$_[1]" -t "hdd temperature" -h240 -w600 -a PNG -v "degrees C" DEF:temp="$rrd/$_[0].rrd":temp:AVERAGE LINE2:temp#0000FF:"$_[2] (/dev/$_[0])" GPRINT:temp:MIN:"Min %2.lf" GPRINT:temp:MAX:"Max %2.lf" GPRINT:temp:AVERAGE:"Avg %4.1lf" GPRINT:temp:LAST:"Current %2.lf degrees C";`

#	Debug purposes for running in bash shell
#	rrdtool graph /mnt/disk1/Web/htdocs/rrd/sda-day.png -S 300 -t "hdd temperature" -h240 -w600 -a PNG -v "degrees C" DEF:temp="/opt/var/lib/rrd/sda.rrd":temp:AVERAGE LINE2:temp#0000FF:"$_[2] (/dev/$_[0])" GPRINT:temp:MIN:"Min %2.lf" GPRINT:temp:MAX:"Max %2.lf" GPRINT:temp:AVERAGE:"Avg %4.1lf" GPRINT:temp:LAST:"Current %2.lf degrees C\\n"
}
