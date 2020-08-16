#!/usr/bin/perl -w

use Manager::Dialog qw(Message);
use PerlLib::MySQL;
use Text::Wrap;

use Data::Dumper;

$Text::Wrap::columns = 40;
$mysql = PerlLib::MySQL->new(DBName => "score");
$size = 25;

sub myformat {
  my $text = shift;
  $text =~ s/-/ /g;
  $text = wrap('', '', $text);
  $text =~ s/\n/\\n/g;
  return $text;
}

sub lookup {
  my ($type,$text) = @_;
  my $ref = $mysql->MySQLDo
    (Statement =>
     "select * from goals where $type=".$mysql->DBH->quote($text).";",
     KeyField => "ID");
  my $ret = {};
  foreach my $key (keys %$ref) {
    $ret->{$key} = $ref->{$key};
  }
  return $ret;
}

sub process {
  my $dep = {};
  my $f = "tsort";
  my $c = `cat "$f"`;
  foreach my $line (split /\n/,$c) {
    my @list = split /\s/,$line;
    my $a = pop @list;
    $dep->{$a} = [];
    foreach my $b (@list) {
      push @{$dep->{$a}}, $b;
    }
  }

  # now do the sql stuff
  foreach my $key (keys %$dep) {
    my $label = substr($key,0,$size);
    my $f = lookup(Name => $label);
    if (! scalar keys %$f) {
      my $a = $mysql->DBH->quote($label);
      my $b = $mysql->DBH->quote(myformat($key));
      my $c = "insert into goals values (NULL,".join(",",($a,$b,"NULL")).");";
      Message(Message => $c);
      $mysql->MySQLDo(Statement => $c);
    }
  }
  foreach my $key (keys %$dep) {
    my $label = substr($key,0,$size);
    my $a = lookup(Name => $label);
    foreach my $item (@{$dep->{$key}}) {
      my $label2 = substr($item,0,$size);
      my $b = lookup(Name => $label2);
      if (scalar keys %$a and scalar keys %$b) {
	my @l1 = keys %$a;
	my @l2 = keys %$b;
	my $c = "insert into dependencies values (NULL,$l1[0],$l2[0]);";
	Message(Message => $c);
	$mysql->MySQLDo(Statement => $c);
      }
    }
  }
}

process;
