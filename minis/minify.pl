#!/usr/bin/perl
# Generate ripple-min, ripple-min.gz, and ripple-packed from ripple.
use v5.32;

my %renames = (
    'ride_send'       => 'rs',
    'ride_recv'       => 'rr',
    'wait_for_prompt' => 'wfp',
    '$addr'           => '$a',
    '@exprs'          => '@e',
    '$sock'           => '$s',
    '$payload'        => '$p',
    '$escaped'        => '$x',
    '$chunk'          => '$c',
);

use File::Basename;
chdir dirname(__FILE__);

open my $in, '<', '../ripple' or die "Cannot open ../ripple: $!";

my @lines;
my $first = 1;
while (<$in>) {
    if ($first) { $first = 0; next }
    next if /^\s*#/;
    next if /^\s*$/;
    s/^\s+//; s/\s+$//;
    for my $from (keys %renames) {
        s/\Q$from\E/$renames{$from}/g;
    }
    push @lines, $_;
}

# ripple-min: one-line minified
my $code = join ' ', @lines;
# Strip spaces that Perl doesn't need
$code =~ s/ ?=> ?/=>/g;        # around =>
$code =~ s/ ?\. ?/./g;         # around .
$code =~ s/; /;/g;             # after ;
$code =~ s/ ?\{ ?/{/g;         # around {
$code =~ s/ ?\} ?/}/g;         # around }
$code =~ s/\( /(/g;            # after (
$code =~ s/ \)/)/g;            # before )
$code =~ s/, /,/g;             # after ,
$code =~ s/die "/die"/g;       # after die
$code =~ s/ \|\| /\|\|/g;      # around ||
$code =~ s/ \/\/ /\/\//g;      # around //
$code =~ s/ +/ /g;             # collapse multiple spaces

open my $out, '>', 'ripple-min' or die "Cannot write ripple-min: $!\n";
print $out "#!/usr/bin/perl\n";
print $out "$code\n";
close $out;
chmod 0755, 'ripple-min';

# ripple-min.gz: gzipped
system('gzip -9 -kf ripple-min');

# ripple-packed: self-extracting, raw gzip in __DATA__
open $out, '>:raw', 'ripple-packed' or die "Cannot write ripple-packed: $!\n";
print $out qq{#!/usr/bin/perl\n};
print $out qq{use IO::Uncompress::Gunzip qw(gunzip);binmode DATA;local\$/;gunzip(\\scalar<DATA>,\\my\$c);eval\$c;\n};
print $out "__DATA__\n";
open my $gz, '<:raw', 'ripple-min.gz' or die "Cannot read ripple-min.gz: $!\n";
print $out do { local $/; <$gz> };
close $out;
chmod 0755, 'ripple-packed';

say sprintf "ripple-min:    %d bytes", -s 'ripple-min';
say sprintf "ripple-min.gz: %d bytes", -s 'ripple-min.gz';
say sprintf "ripple-packed: %d bytes", -s 'ripple-packed';
