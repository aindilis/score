#!/usr/bin/perl -w

#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use Lingua::EN::StopWords qw(%StopWords);

# $UNIVERSAL::debug = 1;

my $projects = {};
foreach my $project (split /\n/, `ls /var/lib/myfrdcsa/codebases/minor /var/lib/myfrdcsa/codebases/internal`) {
  $projects->{$project} = 1;
}

my $c = read_file('/home/andrewdo/to.do');
my @tokens = split /[^-_a-zA-Z0-9\']+/, $c;
my $i = 10000;
my $tokenhash = {};
my $N = 1000.00;
my $lambda = 0.00001;
foreach my $token (@tokens) {
  ++$i;
  $tokenhash->{$token} += $N * (2.71 ** -($lambda * $i));
}

my $results = {};
my $max;
foreach my $token (sort {$tokenhash->{$b} <=> $tokenhash->{$a}} keys %$tokenhash) {
  next if $StopWords{$token};
  next if ! $projects->{$token};
  if (! $max) {
    $max = $tokenhash->{$token};
  }
  $results->{$token} = $tokenhash->{$token} * 100 / $max;
  print sprintf("%5.5d",$tokenhash->{$token})."\t\t".$token."\n" if $UNIVERSAL::debug;
}

print Dumper($results);
