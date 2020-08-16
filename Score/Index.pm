package Score::Index;

use Manager::Dialog qw(Approve Choose ChooseByProcessor Message QueryUser SubsetSelect);
use PerlLib::MySQL;
use Score::Index::Entry;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMySQL MyMySQL2 Priorities IPriorities Sorting PriorityList
   Entries Handlers PreviousEntries Properties Classes MyEntry /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Sorting
    ({
      "ETC < 1 Hour" => 1,
      "ETC < 1 Day" => 1,
      "ETC < 1 Week" => 1,
      "ETC < 1 Month" => 0,
      "Critical" => 1,
      "Important" => 1,
      "Normal" => 0,
      "Unimportant" => 0,
      "Dispensible" => 0,
      "Atemporal" => 0,
     });
  $self->PriorityList
    ([
      "ETC < 1 Hour",
      "ETC < 1 Day",
      "ETC < 1 Week",
      "ETC < 1 Month",
      "Critical",
      "Important",
      "Normal",
      "Unimportant",
      "Dispensible",
      "Atemporal",
     ]);
  $self->Handlers
    ({
      "Seeker Entry" => sub {
	# send something over unilang to seeker
	# should use the OAA solvability model
      },
      "Manager/Spark Entry" => sub {},
      "Problem" => sub {},
      "Solution" => sub {},
      "Implementation" => sub {},
     });
  $self->Entries([]);
  $self->PreviousEntries([]);
  $self->Properties({});

  $self->Priorities
    ({});
  $self->IPriorities
    ({});
}

sub Execute {
  my ($self,%args) = @_;
  $self->MyMySQL
    (PerlLib::MySQL->new
     (DBName => "unilang"));
  $self->MyMySQL2
    (PerlLib::MySQL->new
     (DBName => "score"));
  $self->IndexEntries(%args);
}

sub IndexEntries {
  my ($self,%args) = @_;
  # select all unindexed entries in unilang
  # foreach unindexed entry, present interface for indexing entry
  # while there are more entries
  my $number = $args{Depth} || 1000;
  my $id = $self->MyMySQL->InsertID
    (Table => "messages");
  print Dumper({ID => $id}) if $UNIVERSAL::debug;
  if ($id) {
    my $ret = $self->MyMySQL->Do
      (Statement => "select *,UNIX_TIMESTAMP(Date) from messages where ".
       "Sender='UniLang-Client' and ID > ".($id - $number));

    # add items to the queue
    foreach my $k1 (sort {$ret->{$b}->{'UNIX_TIMESTAMP(Date)'} <=>
			    $ret->{$a}->{'UNIX_TIMESTAMP(Date)'}} keys %$ret) {
      my $h = $ret->{$k1};
      my $entry = Score::Index::Entry->new
	(ID => $h->{ID},
	 Sender => $h->{Sender},
	 Receiver => $h->{Receiver},
	 Contents => $h->{Contents},
	 Date => $h->{Date},
	 TimeStamp => $h->{'UNIX_TIMESTAMP(Date)'});
      push @{$self->Entries}, $entry;
    }
    print Dumper({Entries => $self->Entries}) if $UNIVERSAL::debug;
    # actually we want to also make sure that the user doesn't want to exit
    $self->InteractivelyIndex;
  }
}

sub InteractivelyIndex {
  my ($self,%args) = (shift,@_);
  my @commands = qw|ignore correct next_entry previous_entry
    next_unclassified_entry|;
  my %sizes;
  $self->Classes([sort keys %{$self->Handlers}]);
  $self->PreviousEntries([]);
  $self->MyEntry(shift @{$self->Entries});
  while (@{$self->Entries}) {
    # clear screen
    system "clear";
    $size{commands} = scalar @commands;
    $size{classes} = scalar @{$self->Classes};
    my @menu = @commands;
    push @menu, @{$self->Classes};
    $self->PrintEntry
      (Entry => $self->MyEntry);
    my $choice = UIChoose(@menu);
    if ($choice >= 0) {
      if ($choice < $size{commands}) {
	my $command = $commands[$choice];
	if ($command eq "next_entry") {
	  $self->Advance;
	} elsif ($command eq "next_unclassified_entry") {
	  do {
	    $self->Advance;
	  } while ((exists $self->Properties->{$self->MyEntry->ID}) and
		   ((scalar keys %{$self->Properties->{$self->MyEntry->ID}})));
	} elsif ($command eq "ignore") {
	  $self->Properties->{$self->MyEntry->ID}->{"ignore"} = ! $self->Properties->{$self->MyEntry->ID}->{"ignore"};
	  $self->Advance;
	} elsif ($command eq "correct") {
	  $self->Properties->{$self->MyEntry->ID}->{"correct"} = ! $self->Properties->{$self->MyEntry->ID}->{"correct"};
	  $self->Advance;
	} elsif ($command eq "previous_entry") {
	  $self->Recede;
	}
      } elsif ($choice < $size{commands} + $size{classes}) {
	my $class = $self->Classes->[$choice-$size{commands}];
	print Dumper($class);
	if (defined ($self->Properties->{$self->MyEntry->ID}->{$class})) {
	  delete $self->Properties->{$self->MyEntry->ID}->{$class};
	} else {
	  $self->Properties->{$self->MyEntry->ID}->{$class} = 1;
	}
      }
    }
  }
}

sub UIChoose {
  my @list = @_;
  my $i = 0;
  if (!@list) {
    return;
  } elsif (@list == 1) {
    print "<Chose:".$list[0].">\n";
    return $list[0];
  } else {
    foreach my $item (@list) {
      print "$i) $item\n";
      ++$i;
    }
    my $response;
    while (defined ($response = <STDIN>) and ($response !~ /^\d+$/)) {
    }
    chomp $response;
    return $response;
  }
}

sub PrintEntry {
  my ($self,%args) = (shift,@_);
  print "#" x 80;
  print "\n";
  print "<<<".$args{Entry}->Contents.">>>\n";
  print Dumper($self->Properties->{$args{Entry}->ID});
  print "\n";
}

sub Advance {
  my $self = shift;
  # print "$class\n";
  # &{$self->Handlers->{$class}}($entry);

  if (scalar @{$self->Entries}) {
    push @{$self->PreviousEntries}, $self->MyEntry;
    $self->MyEntry(shift @{$self->Entries});
  } else {
    print "Entries empty\n";
  }
}

sub Recede {
  my $self = shift;
  if (scalar @{$self->PreviousEntries}) {
    unshift @{$self->Entries},$self->MyEntry;
    $self->MyEntry(pop @{$self->PreviousEntries});
  } else {
    print "Previous entries empty\n";
  }
}

sub HasProperties {
  my ($self,%args) = (shift,@_);
  if ((exists $self->Properties->{$args{Entry}->ID}) and
	(scalar keys %{$self->Properties->{$args{Entry}->ID}})) {
    return 1;
  } else {
    return 0;
  }
}

sub PrioritizeEntry {
  my ($self,%args) = @_;
  my $entry = $args{Entry};
  print "$k1\t".$ret->{$k1}->{Contents}."\n";
  $self->Priorities->{$k1} = Choose(@{$self->PriorityList});
  $self->IPriorities->{$self->Priorities->{$k1}}->{$k1} = $ret->{$k1};
}


sub SortLevels {
  my ($self,%args) = @_;
  # now we can do manual sorts, time permitting, to sort out the
  # current top priorities

  # we have to come to an understanding of how task dependencies
  # affect things.  Maybe we can automatically estimate dependencies
  # from this structure, since the user will inherently know what is
  # important, transitively over dependencies

  # do not sort after some level, since its worthless to sort exceptionally unimportant tasks
  my $cutoff = "Important";
  my $rank = {};
  foreach my $p (@{$self->PriorityList}) {
    if ($self->Sorting->{$p}) {
      if (scalar keys %{$self->IPriorities->{$p}}) {
	$rank->{$p} = $self->SortEntries(Ret => $self->IPriorities->{$p});
      }
    } else {
      if (scalar keys %{$self->IPriorities->{$p}}) {
	$rank->{$p} = [keys %{$self->IPriorities->{$p}}];
      }
    }
  }
  $self->DisplayRank
    (Ret => $ret,
     Rank => $rank,
     PriorityList => $self->PriorityList);
}

sub SortEntries {
  my ($self,%args) = @_;
  my $ret = $args{Ret};
  my @order;
  foreach my $k1 
    (reverse sort {$self->CheckImportanceWithUser
		     (Ret => $ret, A => $a, B => $b)} keys %$ret) {
      print "$k1\t".$ret->{$k1}->{Contents}."\n";
      push @order, $k1;
    }
  return \@order;
}

sub CheckImportanceWithUser {
  my ($self,%args) = @_;
  my ($ret,$a,$b) = ($args{Ret},$args{A},$args{B});
  my $v = ChooseByProcessor
    (Processor => sub {$_->{Contents}},
     Values => [$ret->{$a},$ret->{$b}]);
  if (ref $v->[0] ne "HASH") {
    # print "0\n";
    return 0;
  } else {
    if ($v->[0]->{ID} eq $a) {
      # print "1\n";
      return 1;
    } elsif ($v->[0]->{ID} eq $b) {
      # print "-1\n";
      return -1;
    }
  }
}

sub DisplayRank {
  my ($self,%args) = @_;
  print "\n\n\n";
  print "DISPLAYING RANK\n";
  foreach my $p (@{$args{PriorityList}}) {
    if (exists $args{Rank}->{$p} and @{$args{Rank}->{$p}}) {
      print "PRIORITY:\t$p\n";
      foreach my $k1 (@{$args{Rank}->{$p}}) {
	print "TASK:\t\t".$args{Ret}->{$k1}->{Contents}."\n";
      }
      print "\n";
    }
  }
}

sub ClassifyEntriesWRTTaskContext {
  my ($self,%args) = @_;
  # the idea here is to bootstrap the determination of which tasks we
  # ought to work on, so we

  # this could eventually be done w/ bayesian classification too
}

1;
