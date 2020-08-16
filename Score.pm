package Score;

# this is  a system to compose  daily scores for staying  on task.  it
# measures progress based on which activities you engaged in etc.  The
# first sample system will not include advanced behaviour reports.

use BOSS::Config;
use Manager::Dialog qw (Message Choose QueryUser);
use MyFRDCSA;
use PerlLib::MySQL;
use Score::Index;
use Score::User;

use Data::Dumper;

$UNIVERSAL::debug = 1;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Config MyUser MyIndex MyMySQL / ];

sub init {
  my ($self,%args) = @_;
  $specification = "
	-U <user>		User
	-p			Show Priorities
	-P			Show SPSE2 Formalog Priorities
	-r			Record Progress
	-g			Progress Report

	-i			Index Entries
	-m			Change Goal Status

	-s <regex>		Search Records

	-u [<host> <port>]	Run as a UniLang agent

	-w			Require user input before exiting
";

  $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"score");
  $self->Config(BOSS::Config->new
		(Spec => $specification,
		 ConfFile => ""));
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    $UNIVERSAL::agent->Register
      (Host => defined $conf->{-u}->{'<host>'} ?
       $conf->{-u}->{'<host>'} : "localhost",
       Port => defined $conf->{-u}->{'<port>'} ?
       $conf->{-u}->{'<port>'} : "9000");
  }
  $self->MyMySQL
    (PerlLib::MySQL->new
     (DBName => "score"));
}

sub Execute {
  my ($self,%args) = @_;
  my $conf = $self->Config->CLIConfig;
  my $username;
  if (exists $conf->{'-U'}) {
    $username = $conf->{'-U'};
  } else {
    $username = $self->ChooseUserName();
  }
  $self->MyUser
    (Score::User->new
     (User => $username));
  if (exists $conf->{'-p'}) {
    print $self->MyUser->ShowPriorities;
  }
  if (exists $conf->{'-P'}) {
    print $self->MyUser->ShowSPSE2FormalogPriorities;
  }
  if (exists $conf->{'-r'}) {
    $self->MyUser->RecordProgress;
  }
  if (exists $conf->{'-g'}) {
    $self->MyUser->ProgressReport;
  }
  if (exists $conf->{'-s'}) {
    $args{Regex} = $conf->{'-s'};
    print Dumper
      ($self->MyUser->Search(%args));
  }
  if (exists $conf->{'-m'}) {
    $self->MyUser->UserChangeGoalStatus();
  }
  if (exists $conf->{'-i'}) {
    $self->MyIndex(Score::Index->new);
    $self->MyIndex->Execute;
  }
  if (exists $conf->{'-u'}) {
    # enter in to a listening loop
    while (1) {
      $UNIVERSAL::agent->Listen(TimeOut => 10);
    }
  }
  if (exists $conf->{'-w'}) {
    Message(Message => "Press any key to quit...");
    my $t = <STDIN>;
  }
}

sub ChooseUserName {
  my ($self,%args) = (shift,@_);
  my $n = $self->MyMySQL->Do
    (Statement => "select * from agents",
     KeyField => "ID");
  my @names;
  foreach my $id (keys %$n) {
    push @names, $n->{$id}->{Name};
  }
  Message(Message => "Please choose a username");
  return Choose(@names);
}

sub ProcessMessage {
  my ($self,%args) = (shift,@_);
  my $m = $args{Message};
  my $it = $m->Contents;
  if ($it) {
    if ($it =~ /^-p\s*(.*)/) {
      my $contents = $self->MyUser->ShowPriorities;
      $UNIVERSAL::agent->SendContents
	(Contents => $contents);
    } elsif ($it =~ /^(quit|exit)$/i) {
      $UNIVERSAL::agent->Deregister;
      exit(0);
    }
  }
  my $d = $m->Data;
  if ($d->{Command} =~ /^record-event$/i) {
    if (! $self->My) {
      $self->MyPredict(Manager::Predict->new);
    }
    $UNIVERSAL::agent->QueryAgentReply
      (
       Message => $m,
       Data => {
		_DoNotLog => 1,
		Result => $self->MyPredict->Execute,
	       },
      );
  }
}

1;
