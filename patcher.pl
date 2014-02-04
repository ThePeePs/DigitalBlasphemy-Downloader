#!/usr/bin/perl -w

use Tie::File;

# This script will update the sizes available for download from Digital Blasphemy,
# as Ryan changes what sizes are available from time to time.
# Run after doing a "git pull".

@dft = ();
open($dftfh,'<','db-rss-reader.ini.default') or die "Cannot open db-rss-reader.default: $!\n";
foreach $line (<$dftfh>) {
    chomp($line);
    push(@dft, $line);
};
close($dftfh);
tie @cfg, 'Tie::File', "db-rss-reader.ini" or die "Cannot open db-rss-reader.ini: $!\n";

$start = 83;
$dtotal = @dft;
$ctotal = @cfg;
@linesadded = ();
@linesdel = ();

# Check for sizes that Ryan removed, and pull them from the config file.
for ($i=$start; $i<$ctotal; $i++) {
    if ( $cfg[$i] =~ /^(#|$)/ ) {
        next;
    };
    @line = split(/ /, $cfg[$i]);
    $size = $line[0];
    $size =~ s/^;//s;
    $match = 0;
    for ( $l=$start; $l<$dtotal; $l++) {
        if ( $dft[$l] =~ /^(#|$)/ ) {
            next;
        };
        if ( grep(/$size/, $dft[$l]) == 1 ) {
            $match = 1;
        };
    };
    if ( $match == 0 ) {
        push(@linesdel, $cfg[$i]);
        splice(@cfg, $i, 1);
        $ctotal--;
    };
};

# Check for new sizes, and add them to the config file.
for ($i=$start; $i<$dtotal; $i++) {
    if ( $dft[$i] =~ /^(#|$)/ ) {
        next;
    };
    @line = split(/ /, $dft[$i]);
    $size = $line[0];
    $size =~ s/^;//s;
    $match = 0;
    for ( $l=$start; $l<$ctotal; $l++) {
        if ( $cfg[$l] =~ /^(#|$)/ ) {
            next;
        };
        if ( grep(/$size/, $cfg[$l]) == 1 ) {
            $match = 1;
        };
    };
    if ( $match == 0 ) {
        splice(@cfg, $i, 0, $dft[$i]."\n");
        push(@linesadded, $dft[$i]);
    };
};

untie @cfg;

# Tell user what has been added and removed.
print "Sizes that were added:\n";
foreach $new (@linesadded) {
    print "$new\n";
};

print "Sizes that were removed:\n";
foreach $old (@linesdel) {
    print "$old\n";
};

