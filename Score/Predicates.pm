package Score::Predicates;

use PerlLib::MySQL;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Predicate Arguments / ];

sub init {
  my ($self,%args) = @_;
  if ($args{ID}) {
    # lookup and retrieve this predicate
  $self->Arguments({});
}

sub TrueP {
  my ($self,%args) = @_;
  my $pred = $args{Predicate};
  # if we can find it in the database then its true
}

sub Save {
  my ($self,%args) = @_;
}

1;
