#!/usr/bin/perl -w

use Data::Dumper;
use PerlLib::MySQL;

$mysql1 = PerlLib::MySQL->new
  (DBName => "unilang");

$mysql2 = PerlLib::MySQL->new
  (DBName => "score");

# valid categories to be considered for score
my @validids = qw(37 38 40 46 49 50 51 53 57 61 65);
my @validnames =
  qw(verber-task-definition icodebase-capability-request
     icodebase-solution-to-extant-problem solution-to-extant-problem SOP
     goal system-request priority-shift icodebase-task capability-request
     shopping-list-item);

# what we are going to do is  insert into the goal map a goal for each
# of the entries that are in this class

my $results = {};
foreach my $id (@validids) {
  # get all instances of this
  my $ref = $mysql1->Do
    (Statement => "select * from classifications where CategoryID=$id",
     KeyField => "ID");
  foreach my $key (%$ref) {
    if ($ref->{$key}) {
      $results->{$key} = $ref->{$key};
    }
  }
}

# now with all the items, insert these into the score database
my $agentid = 1;

# print Dumper($mysql1);

foreach my $key (keys %$results) {
  my $id = $results->{$key}->{MessageID};
  my $res = $mysql1->Lookup
    (Table => "messages",
     Key => "ID",
     Value => $id);
  my $contents = $mysql2->DBH->quote($res->{$id}->{Contents});
  my $date = $mysql2->DBH->quote($res->{$id}->{Date});
  my $c = "insert into goals values (NULL,$agentid,$contents,$date,'unilang.messages',$id,'open')";
  # print $c."\n";
  $mysql2->Do(Statement => $c);
}

