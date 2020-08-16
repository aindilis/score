package Score::Util;

use UniLang::Util::TempAgent;

use Data::Dumper;

require Exporter;
@ISA = qw(Exporter);

@EXPORT = qw ( RecordEvent );

sub RecordEvent {
  my (%args) = @_;
  my $agent;
  if ($UNIVERSAL::agent) {
    $agent = $UNIVERSAL::agent;
  } else {
    $agent = UniLang::Util::TempAgent->new()->MyAgent;
  }
  my $res1 = $agent->QueryAgent
    (
     Receiver => 'Manager',
     Data => {
	      Command => 'record-event',
	      EventArgs => {
			    AgentID => $args{AgentID} || 1,
			    Event => $args{Event} || 'unknown',
			    Quality => $args{Quality} || 'bad',
			    Score => $args{Score} || -10,
			    Count => $args{Count} || 1,
			   },
	      _DoNotLog => 1,
	     },
    );
  print Dumper({ScoreResult =>  $res1});
}

1;
