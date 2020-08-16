#!/usr/bin/perl -w

use GraphViz;
use Text::Wrap;

my $count = 0;
my $TS = 0;
my $size = 25;
$Text::Wrap::columns = 40;
my $g = GraphViz->new(directed => 1,
		      rankdir => 'LR',
		      node => {shape => 'record'});
my $dep = {};
my $imp = {};
my $newimp = {};
my $norm = {};

sub process {
  open(TS,"<tsort");
  while (<TS>) {
    chomp;
    @list = split(/\s+/,$_);
    while (@list) {
      my $text = pop @list;
      my $label = substr($text,0,$size);
      if (!defined($H{$label})) {
	$text{$label} = myformat($text);
	$H{$label} = ++$count;
	$dep->{$label} = [];
      }
      @list2 = @list;
      while (@list2) {
	my $newtext = pop @list2;
	my $newlabel = substr($newtext,0,$size);
	$text{$newlabel} = myformat($newtext);
	$L{$label}{$newlabel} = "";
	push @{$dep->{$label}}, $newlabel;
      }
    }
  }
}

sub computepriority {
  print "now compute importance\n";
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
  if ($maximp) {
    foreach my $node (keys %$dep) {
      $norm->{$node} = $imp->{$node} / $maximp;
    }
  }
}

sub printpriorities {
  print "now print priorities\n";
  foreach my $node (sort {$imp->{$b} <=> $imp->{$a}} keys %H) {
    print $imp->{$node};
    print "\t";
    print $text{$node};
    print "\n";
  }
}

sub outputgraph {
  foreach $h (keys %H) {
    $color = "1,".$norm->{$h}.",1";
    $g->add_node($H{$h},
		 label => "<bala>$h|<f1>$text{$h}",
		 style => "filled",
		 fillcolor => $color);
  }

  foreach $h (keys %H) {
    foreach $i (keys %H) {
      if (defined($L{$h}{$i})) {
	$g->add_edge($H{$h} => $H{$i});
      }
    }
  }
  $g->as_ps("out.ps");
  system "gv -scale 1 -scalebase 10 out.ps";
}

sub myformat {
  my $text = shift;
  $text =~ s/-/ /g;
  $text = wrap('', '', $text);
  $text =~ s/\n/\\n/g;
  return $text;
}

process();
computepriority();
printpriorities();
outputgraph();
