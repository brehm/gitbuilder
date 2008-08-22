package Autobuilder;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(find_errors mtime catfile basename stripwhite 
    shorten git_describe);

use strict;


sub find_errors($)
{
	my $filename = shift;
	my $out = "";
	my @tail = ();
	
	open my $fh, "<$filename"
		or die("Can't open $filename: $!\n");
	while (defined(my $s = <$fh>)) {
		if ($s =~ /\s(hint|warning|error|fatal)\s*:\s*(.*)/i) {
			$out .= "$1: $2\n\n";
		}
		push @tail, $s;
		if (@tail > 25) {
		    shift @tail;
		}
	}
	close $fh;
	return $out . "\n\nLast messages:\n\n@tail\n";
}

sub mtime($)
{
	my $filename = shift @_;
	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
	    $atime,$mtime,$ctime,$blksize,$blocks) = stat($filename)
	    or die("stat $filename: $!\n");
	return $mtime;
}

sub catfile(@)
{
	my @list = ();
	foreach my $file (@_) {
		open my $fh, "<$file" or die("$file: $!\n");
		push @list, <$fh>;
		close $fh;
	}
	return join('', @list);
}

sub basename($)
{
	my $filename = shift @_;
	$filename =~ m{.*/([^/]+)}  &&  ($filename = $1);
	return $filename;
}

sub stripwhite($)
{
	my $s = shift @_;
	$s =~ s/^\s+//mg;
	$s =~ s/\s+$//mg;
	return $s;
}

sub shorten($$)
{
	my ($s, $len) = @_;
	if (length($s) > $len) {
		return substr($s, 0, $len) . "...";
	} else {
		return $s;
	}
}

sub git_describe($)
{
    my $commit = shift;
    if (-d '../build/.') {
	return stripwhite(
	    `cd ../build && git-describe --contains --all $commit`);
    } else {
	return stripwhite(catfile("describe/$commit"));
    }
}

1;
