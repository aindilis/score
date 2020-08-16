package Score::Index::Entry;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / ID Sender Receiver Contents Date TimeStamp /

  ];

sub init {
  my ($self,%args) = @_;
  $self->ID($args{ID});
  $self->Sender($args{Sender});
  $self->Receiver($args{Receiver});
  $self->Contents($args{Contents});
  $self->Date($args{Date});
  $self->TimeStamp($args{TimeStamp});
}

1;
