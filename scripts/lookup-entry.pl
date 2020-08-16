#!/usr/bin/perl -w

# lookup in the database for the goal that matches this

use Lingua::EN::Sentence qw(get_sentences);
use Data::Dumper;
use PerlLib::MySQL;

my $search = shift;
my $sentences = get_sentences($search);
my $mysql = PerlLib::MySQL->new(DBName => "unilang");

$search =~ s/^\W+//;
$search =~ s/\W+$//;

my $res = $mysql->Do
   (Statement => "select * from messages where Contents like '%$search%'");
my @reskeys = keys %$res;
if (scalar @reskeys == 1) {
  print $reskeys[0];
}

