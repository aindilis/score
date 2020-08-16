#!/usr/bin/perl -w

# there is a basic strategy for determining task importance that
# requires some manual labor but converges towards what we want.

# the  idea  is  that  we  perform  a sort  of  tasks,  and  we  posit
# constraints relating  which tasks we think  are more/most important.
# then we will have a basic ordering from which we can compute general
# importance, and this can guide the Manager Context warning system

# now on to design the persistance strategy for this program

# what should this become part of?

use Manager::Dialog qw(Choose ChooseByProcessor);
use PerlLib::MySQL;

use Data::Dumper;

sub Execute {
  my $number = $ARGV[0] || 20;
  die "Not a number" unless $number =~ /^\d+$/;
  my $mysql = PerlLib::MySQL->new
    (DBName => "unilang");
  my $ret = $mysql->Do
    (
     Statement => "select *,UNIX_TIMESTAMP(Date) from messages where Sender='UniLang-Client' and Contents != 'Register' ORDER BY ID desc limit $number;"
    );

  PrioritizeEntries($ret);
}

sub PrioritizeEntries {
  my $ret = shift;
  my $priorities =  {};
  my $ipriorities =  {};
  my $bothersorting = {
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
		      };
  my @prioritylist = (
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
		     );
  foreach my $k1 (sort {$ret->{$b}->{'UNIX_TIMESTAMP(Date)'} <=>
			  $ret->{$a}->{'UNIX_TIMESTAMP(Date)'}} keys %$ret) {
    # just get a priority
    print "$k1\t".$ret->{$k1}->{Contents}."\n";
    # $priorities->{$k1} = Choose(@prioritylist);
    $priorities->{$k1} = "Critical";
    $ipriorities->{$priorities->{$k1}}->{$k1} = $ret->{$k1};
  }

  # now we can do manual sorts, time permitting, to sort out the
  # current top priorities

  # we have to come to an understanding of how task dependencies
  # affect things.  Maybe we can automatically estimate dependencies
  # from this structure, since the user will inherently know what is
  # important, transitively over dependencies

  # do not sort after some level, since its worthless to sort exceptionally unimportant tasks
  my $cutoff = "Important";
  my $rank = {};
  foreach my $p (@prioritylist) {
    if ($bothersorting->{$p}) {
      if (scalar keys %{$ipriorities->{$p}}) {
	$rank->{$p} = SortEntries($ipriorities->{$p});
      }
    } else {
      if (scalar keys %{$ipriorities->{$p}}) {
	$rank->{$p} = [keys %{$ipriorities->{$p}}];
      }
    }
  }

  DisplayRank
    (Ret => $ret,
     Rank => $rank,
     PriorityList => \@prioritylist);
}

sub SortEntries {
  my $ret = shift;
  my @order;
  foreach my $k1 (reverse sort {CheckImportanceWithUser($ret,$a,$b)} keys %$ret) {
    print "$k1\t".$ret->{$k1}->{Contents}."\n";
    push @order, $k1;
  }
  return \@order;
}

sub CheckImportanceWithUser {
  my ($ret,$a,$b) = @_;
  print "Choose the item that has higher priority (or cancel if they are equal or you don't know) :\n";
  my $v = ChooseByProcessor
    (Processor => sub {$_->{Contents}},
     Values => [$ret->{$a},$ret->{$b}]);
  print Dumper($v);
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
  my %args = @_;
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
  my %args = @_;
  # the idea here is to bootstrap the determination of which tasks we
  # ought to work on, so we

  # this could eventually be done w/ bayesian classification too
}

Execute();

# since sort is so computationally expensive, maybe we can just have
# the user go through and assign a priority to items

# that won't be as accurate

# now add some sort of persistance, since we are working with larger manually created datasets
