package Score::User;

use Score::User::SPSE2Formalog;

# this is  a system to compose  daily scores for staying  on task.  it
# measures progress based on which activities you engaged in etc.  The
# first sample system will not include advanced behaviour reports.

use Manager::Dialog qw(Approve Choose Message QueryUser SubsetSelect);

use Data::Dumper;
use GraphViz;
use KBS::Store;
use Text::Wrap;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / User MyGraphViz Dependencies Importance Norm Goals MyStore MySPSE2Formalog /

  ];

sub init {
  my ($self,%args) = @_;
  $self->User($args{User});
  $self->MyGraphViz
    (GraphViz->new
     (directed => 1,
      rankdir => 'LR',
      node => {shape => 'record'}));
  $Text::Wrap::columns = 40;
  $self->MyStore
    (KBS::Store->new);
}

sub AddGoal {
  my ($self,%args) = @_;
}

sub ShowPriorities {
  my ($self,%args) = @_;
  $self->ComputePriorities;
  $self->PrintGraph;
  return $self->PrintPriorities;
}

sub ShowSPSE2FormalogPriorities {
  my ($self,%args) = @_;
  if (! defined $self->MySPSE2Formalog) {
    $self->MySPSE2Formalog(Score::User::SPSE2Formalog->new);
  }
  $self->ComputeSPSE2FormalogPriorities;
  # $self->PrintGraph;
  return $self->PrintPriorities;
}

sub UpdateGoals {
  my ($self,%args) = @_;
  return if $self->Goals;
  $self->Goals
    ($UNIVERSAL::score->MyMySQL->MySQLDo
     (Statement => "select * from goals",
      KeyField => "ID"));
  print Dumper($self->Goals);
}

sub UpdateSPSE2FormalogGoals {
  my ($self,%args) = @_;
  return if $self->Goals;
  $self->Goals
    ($self->MySPSE2Formalog->GetGoals());
}

sub ComputeSPSE2FormalogPriorities {
  my ($self,%args) = @_;
  # first load the priorities into the dep structure
  $self->Dependencies({});
  my $agentid = 1;

  print "This will take a second while it queries SPSE2Formalog (which you must ensure is running)\n";

  $self->UpdateSPSE2FormalogGoals;

  my $res1 = $self->MySPSE2Formalog->UpdateSPSE2FormalogRes1;
  # my $res1 = $UNIVERSAL::score->MyMySQL->Do
  #   (Statement => "select ID from goals where AgentID=$agentid and ID < 400;",
  #    KeyField => "ID");
  # print Dumper({Res1 => $res1});

  my $res2 = $self->MySPSE2Formalog->UpdateSPSE2FormalogRes2;
  # my $res2 = $UNIVERSAL::score->MyMySQL->Do
  #   (Statement => "select dependencies.* from dependencies,goals where goals.AgentID=$agentid and dependencies.Parent=goals.ID;",
  #    KeyField => "ID");
  # print Dumper({Res2 => $res2});

  foreach my $id (keys %$res1) {
    $self->Dependencies->{$id} = [];
  }

  foreach my $id (keys %$res2) {
    push @{$self->Dependencies->{$res2->{$id}->{Parent}}}, $res2->{$id}->{Child};
  }

  Message(Message => "Computing importance");
  my $imp = {};
  my $newimp = {};
  my $norm = {};
  foreach my $node (keys %{$self->Dependencies}) {
    $imp->{$node} = 1;
  }

  my $i = 10;
  while ($i) {
    foreach my $node (keys %{$self->Dependencies}) {
      my $indegree = scalar @{$self->Dependencies->{$node}};
      $newimp->{$node} = $imp->{$node};
      foreach my $child (@{$self->Dependencies->{$node}}) {
	if ($indegree) {
	  my $delta = $imp->{$node}/(2 * $indegree);
	  $newimp->{$child} += $delta;
	  $newimp->{$node} -= $delta;
	}
      }
    }
    $imp = $newimp;
    --$i;
  }

  Message(Message => "Normalizing importance");
  my $maximp = 0;
  foreach my $node (keys %{$self->Dependencies}) {
    if ($imp->{$node} > $maximp) {
      $maximp = $imp->{$node};
    }
  }
  if ($maximp) {
    foreach my $node (keys %{$self->Dependencies}) {
      $norm->{$node} = $imp->{$node} / $maximp;
    }
  }
  $self->Importance($imp);
  $self->Norm($norm);
}

sub ComputePriorities {
  my ($self,%args) = @_;
  # first load the priorities into the dep structure
  $self->Dependencies({});
  my $agentid = 1;
  $self->UpdateGoals;

  my $res1 = $UNIVERSAL::score->MyMySQL->Do
    (Statement => "select ID from goals where AgentID=$agentid and ID < 400;",
     KeyField => "ID");

  my $res2 = $UNIVERSAL::score->MyMySQL->Do
    (Statement => "select dependencies.* from dependencies,goals where goals.AgentID=$agentid and dependencies.Parent=goals.ID;",
     KeyField => "ID");

  foreach my $id (keys %$res1) {
    $self->Dependencies->{$id} = [];
  }

  foreach my $id (keys %$res2) {
    push @{$self->Dependencies->{$res2->{$id}->{Parent}}}, $res2->{$id}->{Child};
  }

  Message(Message => "Computing importance");
  my $imp = {};
  my $newimp = {};
  my $norm = {};
  foreach my $node (keys %{$self->Dependencies}) {
    $imp->{$node} = 1;
  }

  my $i = 10;
  while ($i) {
    foreach my $node (keys %{$self->Dependencies}) {
      my $indegree = scalar @{$self->Dependencies->{$node}};
      $newimp->{$node} = $imp->{$node};
      foreach my $child (@{$self->Dependencies->{$node}}) {
	if ($indegree) {
	  my $delta = $imp->{$node}/(2 * $indegree);
	  $newimp->{$child} += $delta;
	  $newimp->{$node} -= $delta;
	}
      }
    }
    $imp = $newimp;
    --$i;
  }

  Message(Message => "Normalizing importance");
  my $maximp = 0;
  foreach my $node (keys %{$self->Dependencies}) {
    if ($imp->{$node} > $maximp) {
      $maximp = $imp->{$node};
    }
  }
  if ($maximp) {
    foreach my $node (keys %{$self->Dependencies}) {
      $norm->{$node} = $imp->{$node} / $maximp;
    }
  }
  $self->Importance($imp);
  $self->Norm($norm);
}

sub PrintAllGoals {
  my ($self,%args) = @_;
  # rarely used if ever

}

sub PrintPriorities {
  my ($self,%args) = @_;
  my $retval = "Printing priorities\n";
  # Message(Message => "Printing priorities");
  my @l = sort {$self->Importance->{$b} <=> $self->Importance->{$a}}
    keys %{$self->Dependencies};
  # foreach my $node (splice @l,0,20) {
  # foreach my $node (splice @l,0,1000) {
  foreach my $node (@l) {
    $retval .= sprintf("%-08f",$self->Importance->{$node});
    $retval .= " ";
    $retval .= $self->Goals->{$node}->{Description};
    $retval .=  "\n";
  }
  return $retval;
}

sub PrintGraph {
  my ($self,%args) = @_;
  foreach $id (keys %{$self->Dependencies}) {
    $color = "1,".$self->Norm->{$id}.",1";
    my $desc = $self->Goals->{$id}->{Description};
    my $text = $self->FormatDescription(Description => $desc);
    $desc =~ s/[-<>\"\']/./g;
    my $short = substr($desc,0,25);
    $self->MyGraphViz->add_node
      ($id,
       label => sprintf("%s",$text),
       style => "filled",
       fillcolor => $color);
  }

  foreach $id1 (keys %{$self->Dependencies}) {
    foreach $id2 (@{$self->Dependencies->{$id1}}) {
      $self->MyGraphViz->add_edge($id1 => $id2);
    }
  }
  # print $self->MyGraphViz->as_canon;
  $self->MyGraphViz->as_jpeg("out.jpg");
  # system "gv -scale 1 -scalebase 10 out.ps";
  system "xdg-open out.jpg";
}

sub FormatDescription {
  my ($self,%args) = @_;
  my $text = $args{Description};
  $text =~ s/[-<>\"\']/./g;
  $text = wrap('', '', $text);
  $text =~ s/\n/\\n/g;
  $text = substr($text,0,125);
  return $text;
}

sub ProgressReport {
  my ($self,%args) = @_;
  Message(Message => "Your score for the last 24 hours is:");
  Message(Message => $self->ComputeScore);
}

sub ComputeScore {
  my ($self,%args) = @_;
  # do it for simply the last 24 hours
  if (! $self->Importance) {
    $self->ComputePriorities;
  }

  my $score = 0;
  # get all the problems that have been solved in the last 24 hours

  # need to start doing some interesting things here

  #   my $ref = $self->MyKBS->Do
  #     (Statement => "select ID from goals where (Date - DATE_SUB(Now(), INTERVAL 1 DAY)) > 0 and ID = ANY".
  #      $self->MyKBS->GQuery(Relation => ['status',undef,'open']).")");

  #   my $ref = $UNIVERSAL::score->MyMySQL->Do
  #     (Statement => "select ID from goals where (Date - DATE_SUB(Now(), INTERVAL 1 DAY)) > 0 and status='solved';",
  #      KeyField => "ID");
  foreach my $id (keys %$ref) {
    # add up the importance of the solved goal
    $score += $self->Importance->{$id};
  }
  return $score;
}

sub Search {
  my ($self,%args) = (shift,@_);
  my $regex = $args{Regex};
  my $number = $args{Depth} || 50;
  my $id = $UNIVERSAL::score->MyMySQL->InsertID(Table => "goals");
  my @retval;
  if ($id) {
    print $id."\n";
    my $ret;
    if ($args{Depth}) {
      $ret = $UNIVERSAL::score->MyMySQL->Do
	(Statement => "select *,UNIX_TIMESTAMP(Date) from goals where ".
	 "ID > ".($id - $number).
	 " and ".
	 "Description like '$regex';");
    } else {
      my $statement = "select *,UNIX_TIMESTAMP(Date) from goals where ".
	"Description like '$regex';";
      # print "$statement\n";
      $ret = $UNIVERSAL::score->MyMySQL->Do
	(Statement => $statement);
    }
    foreach my $k1 (sort {$ret->{$a}->{'UNIX_TIMESTAMP(Date)'} <=>
			    $ret->{$b}->{'UNIX_TIMESTAMP(Date)'}} keys %$ret) {
      my $it = $ret->{$k1}->{Description};
      push @retval, $it;
      # print "$k1\t$it\n";
    }
  }
  return \@retval;
}

sub UserChangeGoalStatus {
  my ($self,%args) = @_;
  my $res = QueryUser
    ("Please reference the item that needs to be done.");
  my $entry;
  if ($res =~ /^\d+$/) {
    # this is the id then?
    @e = $self->SearchEntries
      (ID => $res);
  } else {
    # this is a search
    @e = $self->SearchEntries
      (Regex => $res);
  }
  foreach my $goal (@e) {
    $self->ChangeGoalStatus(ID => $goal->{ID});
  }
}

sub ChangeGoalStatus {
  my ($self,%args) = @_;
  my $id = $args{ID};
  my $goal = $self->GetGoal
    (ID => $args{ID});
  if (Approve("Is this the goal for which you are looking? $goal->{Description}")) {
    print "The status of goal is:\n";
    print Dumper($goal->{Status});
    Message
      (Message => "Please select the status to which you would like to set the goal.");
    $self->SetGoalStatus
      (
       ID => $args{ID},
       Status => Choose(qw(open solved)),
      );
  }
}

sub GetGoal {
  my ($self,%args) = @_;
  my $res = $UNIVERSAL::score->MyMySQL->MySQLDo
    (Statement => "select * from goals where ID=$args{ID}");
  return $res->{$args{ID}};
}

sub SetGoalStatus {
  my ($self,%args) = @_;
  my $status = $args{Status};
  # $self->MyStore->Map($args{Status}, ['status',$args{ID},undef]);

  $self->MyStore->UnAssert
    (Relation => ['status',$args{ID},undef]);
  $self->MyStore->Assert
    (Relation => ['status',$args{ID},$args{Status}]);
  $UNIVERSAL::score->MyMySQL->MySQLDo
    (Statement => "update goals set Status='$status' where ID=$args{ID}");
}

sub SearchEntries {
  my ($self,%args) = @_;
  $self->UpdateGoals;
  my @matches;
  if ($args{ID}) {
    push @matches, $self->Goals->{$args{ID}};
  } elsif ($args{Regex}) {
    my $regex = $args{Regex};
    foreach my $id (keys %{$self->Goals}) {
      my $description = $self->Goals->{$id}->{Description};
      if ($description =~ /$regex/) {
	push @matches, $self->Goals->{$id};
      }
    }
  }
  return SubsetSelect
    (Set => \@matches,
     Processor => sub {$_->{Description}});
}

1;
