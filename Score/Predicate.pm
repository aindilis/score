package Score::Predicate;

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

sub Retrieve {
  my ($self,%args) = @_;
}

sub Save {
  my ($self,%args) = @_;
}

1;
