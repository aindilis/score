sub AnnotateEntry {
  my ($self,%args) = @_;
  if ($args{Type} eq "Problem") {
    # If it is a problem, classify two things, how
    # important it is perceived to be, and secondly, how
    # much work is required to complete it.
    $self->PrioritizeEntry
      (Entry => $entry);
    $self->GetPerceivedDifficulty
      (Entry => $entry);
  } elsif ($args{Type} eq "Solution") {
    # If it is a solution, record to which problem it is.
    # Sometimes you may get a problem and solution in the
    # same entry.  It would be necessary to separate them.
    # actually, they have already been separated

    $self->MySemanticSimilarity->EntrySemanticSimilaritySearch
      (Entry => $key);

    # if it was separated, first check whether the problem
    # was recorded in the conjoined entry otherwise,
    # search the database for the problem sets that this
    # solution solves
  } elsif ($args{Type} eq "Implementation") {
    # if it was conjoined, first check whether the
    # solution was recorded in the conjoined entry
    # otherwise search the database for the solution sets
    # that this implementation implements

    # If it is an implementation of a solution, record
    # which solution it is an using KBFS, which resources
    # it takes.  Also, report the problem as having been
    # solved and update the score accordingly.
  } elsif ($args{Type} eq "Other") {
    # update the database to say that it none of these

  }
}

sub AddNewEntry {
  my ($self,%args) = @_;
  # just insert the thing into the database
  # which database, what values?
  # goals
}

# multiple items, we're going to have to break it down

# note that we could possible do clausal analysis and
# break the sentence down for them
my $entries;
do {
  $entries = {};
  foreach my $type (@types) {
    $entries->{$type} = QueryUser("What is the entry for <$type>?");
  }
  print Dumper($entries);
}
  while (! Approve("Add this?"));
# need to correct this to allow a failure exception
foreach my $k (keys %$entries) {
  AddNewEntry($k => $entries->{$k});
}


  # multiple items, we're going to have to break it down

  # note that we could possible do clausal analysis and
  # break the sentence down for them

  # Is it a problem, a solution, or an implementation of a solution.

  # find all the other areas that this is supposed to be marked

  # mark as seeker entry
  # mark as manager/spark entry

  # etc

  # also allow to put urgency, or say, find sub/supertasks

  # mark as completed (in the database)


  # Is it a problem, a solution, or an implementation of a solution.

  # find all the other areas that this is supposed to be marked

  # mark as seeker entry
  # mark as manager/spark entry

  # etc

  # also allow to put urgency, or say, find sub/supertasks

  # mark as completed (in the database)

