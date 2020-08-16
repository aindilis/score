#!/usr/bin/perl -w

use Corpus::TDT::GetEntries;
use Manager::Dialog qw(QueryUser);
use Data::Dumper;

sub Search {
  my (%args) = @_;
  my $ge = Corpus::TDT::GetEntries->new();
  $ge->Execute;
  my @matches = $ge->Search
    (Search => QueryUser("Search?"));
  print Dumper(\@matches);
}

Search();
