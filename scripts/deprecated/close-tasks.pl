#!/usr/bin/perl -w

# close tasks
sub CloseTasks {
  my @res;
  while () { # while we can close many tasks
    # subsetselect current important items
    @res = SubsetSelect
      (Set => []);
  }
  if (! scalar @res) {
    # if no matches, do a search for a match using query tools but
    # maybe also Seeker
    SearchEntries();
  }
}

sub SearchEntries {
  
}
