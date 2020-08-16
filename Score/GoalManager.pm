package Score::GoalManager;

use PerlLib::MySQL;

use Data::Dumper;
use XMLRPC::Lite;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / / ];

sub init {
  my ($self,%args) = @_;
  # $UNIVERSAL::score->;

  # one way to  calculate score would be to  represent everything in a
  # planning language, and then run  a plan and measure the difficulty
  # of solving all our problems

  # also, this  plan could serve  to also compute the  essential steps
  # which would displayed in the agenda

  # have to  work out  both the scoring  algebra and the  embedding of
  # normal goals within a planning domain description language
}

sub AddGoal {
  my ($self,%args) = @_;
}

sub InterrelateGoals {
  my ($self,%args) = @_;
  # this will help us both establish links between existing goals such
  # as dependencies  and preconditions, as  well as suggest  new goals
  # based on existing ones using common sense reasoning.
  $self->AutomaticallyInferDependencies;
  $self->SuggestRelatedGoals;
}

sub AutomaticallyInferDependencies {
  my ($self,%args) = @_;
}

sub SuggestRelatedGoals {
  my ($self,%args) = @_;
  # connect to the conceptnet server
  my $results = {};
  foreach my $id (@{$self->GetPriorities}) {
    my $goal = Score::Goal->New(ID => $id);
    my $text = $goal->Description;
    $text =~ s/[^\w\,\.\?\"\s]//g;
    $res = XMLRPC::Lite
      -> proxy('http://localhost:8000')
	-> call('guess_topic',($text))
	  -> result;
    $results->{$id} = $res;
  }
}

sub ChangeGoalStatus {
  my ($self,%args) = @_;
  @comments = [
	       "I do not want to do this now",
	       "I plan to do this later",
	       "I don't feel like doing it now",
	       "It's unnecessary",
	       "It isn't as important as other things",
	       "I would like to do this immediately",
	       "This is absolutely essential",
	       "This needs to be done by a certain time",
	       "This cannot wait any longer",
	       "I'm not sure how important this is",
	       "I wish someone else would be able to do this",
	       "I'd like to pay someone to do this",
	       "I'm not sure there is enough time to do this",
	       "I don't think this will get done",
	       "I think the task is too complex",
	       "I do not think the task is worth the doing",
	       "I'd like to do this just as a change of pace",
	       "I'd like to do this, but other people are preventing me in some way from doing it",
	       "This task is too general",
	       "This task is necessary to another task",
	       "I would like to do this task if someone can help get me started",
	       "I would like to do this task if someone can explain it to me",
	       "I would like to do this task after I study about it",
	      ];
}

sub ComputeProgressScore {
  my ($self,%args) = @_;
  # actually progress score should be completed using moving averages,
  # we also therefore  have a need for a  time series analysis system,
  # that keeps track of various variables

  my $difficulty = $self->ComputeDifficulty;
}

sub ComputeDifficulty {
  my ($self,%args) = @_;
  $self->ExportGoalsToPDDL;
  $self->GeneratePlan;
  $self->ComputeValueOfGoals;
}

sub ExportGoalsToPDDL {
  my ($self,%args) = @_;
}

1;
