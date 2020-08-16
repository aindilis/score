#!/usr/bin/perl -w

sub Search {
  my (%args) = @_;
  my $ge = Corpus::TDT::GetEntries->new();
  $ge->Execute;
  my @matches = $ge->Search
    (Search => QueryUser("Search?"));
  print Dumper(\@matches);
}

Search();
