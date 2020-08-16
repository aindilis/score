#!/usr/bin/perl -w

# this is a simple program to calculate the value of various goals.

use Data::Dumper;
use GraphViz;

print "generate random graph\n";
my $max = 100;
my $dep = {};
my $num = int(rand($max));
print "num: $num\n";

for (my $i = 0; $i < $num; ++$i) {
  $dep->{$i} = [];
  while (5 > rand(10)) {
    my $j;
    do {
      $j = int(rand($num));
    } while ($j == $i);
    push @{$dep->{$i}}, $j;
  }
}


print "now compute importance\n";
my $imp = {};
my $newimp = {};
foreach my $node (keys %$dep) {
  $imp->{$node} = 1;
}

my $i = 10;
while ($i) {
  foreach my $node (keys %$dep) {
    my $indegree = scalar @{$dep->{$node}};
    $newimp->{$node} = $imp->{$node};
    foreach my $child (@{$dep->{$node}}) {
      if ($indegree) {
	my $delta = $imp->{$node}/(2 * $indegree);
	$newimp->{$child} += $delta;
	$newimp->{$node} -= $delta;
      }
    }
  }
  $imp = $newimp;
  --$i;
}


print "now normalize importance\n";
my $maximp = 0;
foreach my $node (keys %$dep) {
  if ($imp->{$node} > $maximp) {
    $maximp = $imp->{$node};
  }
}
my $norm = {};
if ($maximp) {
  foreach my $node (keys %$dep) {
    $norm->{$node} = $imp->{$node} / $maximp;
  }
}


print "now print priorities\n";
foreach my $node (sort {$imp->{$b} <=> $imp->{$a}} keys %$dep) {
  print $node;
  print "\t";
  print $imp->{$node};
  print "\n";
}


print "now generate graphviz object\n";
my $g = GraphViz->new();

foreach my $key (keys %$dep) {
  # $color = rand(1).",".rand(1).",".rand(1);
  $color = "1,".$norm->{$key}.",1";
  $g->add_node($key, style => "filled", fillcolor => $color);
}

foreach my $key (keys %$dep) {
  foreach my $key2 (@{$dep->{$key}}) {
    $g->add_edge($key => $key2);
  }
}


# now print graph
$g->as_ps("out.ps");
system "gv out.ps";
