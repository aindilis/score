#!/usr/bin/perl -w

use Data::Dumper;

# just do it manually for now

use PerlLib::MySQL;

$mysql = PerlLib::MySQL->new(DBName => "score");

"select * from goals";
my $entries = LoadEntries();

# list all the items
# search for a todo item
my $res = QueryUser
  ("Please reference the item that needs to be done.\n");

# is this the number of is this the whole thing or is this a regular
# expression

my $entry;
if ($res =~ /^\d+$/) {
  # this is the id then?
  @e = SearchEntries
    (ID => $res);
} elsif (exists $entries->{$res}) {
  # this is the whole thing then
  @e = SearchEntries
    (Entry => $res);
} else {
  # this is a search
  @e = SearchEntries
    (Regex => $res);
}

# now that we have the entry, query its status
if (Approve("Is this the entry for which you are looking?")) {
  my $status = QueryEntryStatus(Entry => $entry);
  print "The status of entry is:\n";
  print Dumper($status);
}

sub LoadEntries {
  my (%args) = @_;
}

sub SearchEntries {
  my (%args) = @_;
  my @matches;
  if ($args{Regex}) {
    my $regex = $args{Regex};
    foreach my $entry (keys %$entries) {
      if ($entry =~ /$regex/) {
	push @matches, $entry;
      }
    }
  }
  return SubsetSelect(Set => \@matches);
}

sub QueryEntryStatus {
  my (%args) = @_;
}
