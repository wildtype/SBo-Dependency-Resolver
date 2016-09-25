#!/usr/bin/env perl
use strict;
use warnings;
use File::Slurp;
use Graph::Directed;

unless (scalar @ARGV == 1) {
  print "Usage: $0 PACKAGE_NAME\n";
  exit(1);
}

my @sbopkgs   = split "\n\n", read_file('SLACKBUILDS.TXT');
my $dep       = {};

foreach my $pkg (@sbopkgs) {
  my ($pkgname)    = $pkg =~ /SLACKBUILD NAME: (.*)/m;
  my ($pkgdeps)    = $pkg =~ /SLACKBUILD REQUIRES: (.*)/m;
  $dep->{$pkgname} = $pkgdeps;
}

my @match_packages = search_package($ARGV[0]);
my $packages_count = scalar @match_packages;

if ($packages_count == 1) {
  my @packages = reverse build_graph($match_packages[0])->topological_sort;
  print "Required packages to install $match_packages[0]:\n";
  print join("\n", add_leading_spaces(@packages));
  print "  $match_packages[0]" if (scalar @packages == 0);
  print "\n";
} elsif ($packages_count < 1) { 
  print "Package not found: $ARGV[0]\n";
} else {
  print "Matched package name:\n";
  print join("\n", add_leading_spaces(@match_packages));
  print "\n"; 
}

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

sub search_package
{
  my $package_name = shift;
  return () unless $package_name;
  my $query = qr|^$package_name$|;
  return grep {/$query/i} keys %{$dep};
}

sub add_leading_spaces
{
  return map { "  " . $_ } @_;
}
