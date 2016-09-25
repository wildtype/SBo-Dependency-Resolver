#!/usr/bin/env perl
package Main;
use strict;
use warnings;
use File::Slurp;
use Graph::Directed;

our @sbopkgs;
our $dep;

sub initialize
{
  my $self = shift;
  my $file = shift || 'SLACKBUILDS.TXT';
  @sbopkgs = split "\n\n", read_file($file);
  $dep     = {};

  foreach my $pkg (@sbopkgs) {
    my ($pkgname)    = $pkg =~ /SLACKBUILD NAME: (.*)/m;
    my ($pkgdeps)    = $pkg =~ /SLACKBUILD REQUIRES: (.*)/m;
    $dep->{$pkgname} = $pkgdeps;
  }
}

sub build_graph
{
  my $self = shift;
  my $pkgname   = shift;
  my $dep_graph = shift || Graph::Directed->new;


  if ($dep->{$pkgname}) {
    $dep_graph->add_vertex($pkgname) unless $dep_graph->has_vertex($pkgname);

    foreach my $dep (split ' ', $dep->{$pkgname}) {
      $dep_graph->add_vertex($dep) unless $dep_graph->has_vertex($dep);
      $dep_graph->add_edge($pkgname, $dep) unless $dep_graph->has_edge($pkgname, $dep);
      $dep_graph = $self->build_graph($dep, $dep_graph);
    }
  }

  return $dep_graph;
}

sub search_package
{
  my $self = shift;
  my $package_name = shift;
  return () unless $package_name;
  my $query = qr|^$package_name$|i;
  return grep {/$query/i} keys %{$dep};
}

sub add_leading_spaces
{
  my $self = shift;
  return map { "  " . $_ } @_;
}

sub run
{
  my $self = shift;

  unless (scalar @ARGV == 1) {
    print "Usage: $0 PACKAGE_NAME\n";
    exit(1);
  }

  $self->initialize;

  my @match_packages = $self->search_package($ARGV[0]);
  my $packages_count = scalar @match_packages;

  if ($packages_count == 1) {
    my @packages = reverse($self->build_graph($match_packages[0])->topological_sort);

    print "Required packages to install $match_packages[0]:\n";
    print join("\n", $self->add_leading_spaces(@packages));
    print "  $match_packages[0]" if (scalar @packages == 0);
    print "\n";

  } elsif ($packages_count < 1) { 

    print "Package not found: $ARGV[0]\n";

  } else {

    print "Matched package name:\n";
    print join("\n", $self->add_leading_spaces(@match_packages));
    print "\n"; 

  }
}

__PACKAGE__->run unless caller;

1;
