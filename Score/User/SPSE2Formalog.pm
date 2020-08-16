package Score::User::SPSE2Formalog;

use KBS2::Util;
use PerlLib::SwissArmyKnife;
use UniLang::Util::TempAgent;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Goals NewGoals MyTempAgent Counter /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Goals({});
  $self->Counter(1);
  $self->MyTempAgent(UniLang::Util::TempAgent->new);
}

sub QuerySPSE2Formalog {
  my ($self,%args) = @_;
  # my $query = [['_prolog_list',$variables,$interlingua]];
  my $res1 = $self->MyTempAgent->MyAgent->QueryAgent
    (
     Receiver => $args{Agent} || "SPSE2-Formalog-Agent1",
     Data => {
	      _DoNotLog => 1,
	      Eval => $args{Query},
	     },
    );
  return $res1->{Data}{Result};
}

sub GetDependencies {
  my ($self,%args) = @_;
  my $res1 = $self->QuerySPSE2Formalog
    (
     Query => [['_prolog_list',['_prolog_list',Var('?Entry1'),Var('?Entry2')],['depends',Var('?Entry1'),Var('?Entry2')]]],
    );
  # print Dumper({Res1 => $res1});
  shift @$res1;
  return $res1;
}

sub GetGoals {
  my ($self,%args) = @_;
  my $goals = $self->QuerySPSE2Formalog
    (
     Query => [['_prolog_list',['_prolog_list',Var('?Entry1'),Var('?NL')],['goalAndNL',Var('?Entry1'),Var('?NL')]]],
    );
  # print Dumper({Goals => $goals});
  shift @$goals;
  my $newgoals = {};
  foreach my $goal (@$goals) {
    my $hash = $self->ConvertGoal(Goal => $goal);
    $newgoals->{$hash->{ID}} = $hash;
  }
  # print Dumper($newgoals);
  $self->NewGoals($newgoals);
  return $newgoals;
}

sub ConvertGoal {
  my ($self,%args) = @_;
  # [
  #  '_prolog_list',
  #  [
  #   'entry-fn',
  #   'pse+11172014',
  #   1
  #  ],
  #  'Remove this node'
  # ];
  # 102' => {
  #  'AgentID' => 1,
  #  'Date' => '2005-11-29 02:00:00',
  #  'SourceID' => undef,
  #  'Description' => 'contact people try to get some basic\\nkind of cyc mode together',
  #  'Status' => undef,
  #  'ID' => 102,
  #  'Source' => undef
  # },
  my $id = $self->IndexGoal(Goal => $args{Goal});
  my $desc = $args{Goal}->[2];
  return {
	  AgentID => 1,
	  Date => '2020-07-30 12:00:00',
	  SourceID => undef,
	  Description => $desc,
	  Status => undef,
	  ID => $id,
	  Source => undef,
	 };
}

sub IndexGoal {
  my ($self,%args) = @_;
  my $text = ClearDumper($args{Goal}->[1]);
  if (! exists $self->Goals->{$text}) {
    $self->Goals->{$text} = $self->Counter;
    $self->Counter($self->Counter + 1);
  }
  return $self->Goals->{$text};
}

sub UpdateSPSE2FormalogRes1 {
  my ($self,%args) = @_;
  # "78" => {
  #           "ID" => 78
  #         },

  foreach my $id (keys %{$self->NewGoals}) {
    $hash->{$id} = {ID => $id};
  }
  return $hash;
}

sub UpdateSPSE2FormalogRes2 {
  my ($self,%args) = @_;
  my $i = 1;
  my $dependencies = $self->GetDependencies();
  # [
  #   "_prolog_list",
  #   [
  #     "entry-fn",
  #     "pse+DebConf2020-Presentation",
  #     10
  #   ],
  #   [
  #     "entry-fn",
  #     "pse+DebConf2020-Presentation",
  #     6
  #   ]
  # ],
  my $hash = {};
  foreach my $dependency (@$dependencies) {
    # "32" => {
    #           "Child" => 42,
    #           "Parent" => 111,
    #           "ID" => 32
    #         },
    my $id1 = $self->Goals->{ClearDumper($dependency->[1])};
    my $id2 = $self->Goals->{ClearDumper($dependency->[2])};
    $hash->{$i} =
      {
       Child => $id1,
       Parent => $id2,
       ID => $i++,
      };
  }
  return $hash;
}


1;
