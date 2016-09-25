#!/usr/bin/env perl
use strict;
use warnings;
use File::Slurp;
use Graph::Directed;

print "searching for: $ARGV[0]\n\n";

my @sbopkgs   = split "\n\n", read_file('SLACKBUILDS.TXT');
my $dep       = {};

foreach my $pkg (@sbopkgs) {
  my ($pkgname)    = $pkg =~ /SLACKBUILD NAME: (.*)/m;
  my ($pkgdeps)    = $pkg =~ /SLACKBUILD REQUIRES: (.*)/m;
  $dep->{$pkgname} = $pkgdeps;
}

print join("\n", reverse build_graph($ARGV[0])->topological_sort), "\n";

sub build_graph
{
  my $pkgname   = shift;
  my $dep_graph = shift || Graph::Directed->new;


  if ($dep->{$pkgname}) {
    $dep_graph->add_vertex($pkgname) unless $dep_graph->has_vertex($pkgname);

    foreach my $dep (split ' ', $dep->{$pkgname}) {
      $dep_graph->add_vertex($dep) unless $dep_graph->has_vertex($dep);
      $dep_graph->add_edge($pkgname, $dep) unless $dep_graph->has_edge($pkgname, $dep);
      $dep_graph = build_graph($dep, $dep_graph);
    }
  }

  return $dep_graph;
}
