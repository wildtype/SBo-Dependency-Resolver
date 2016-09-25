use Test::More;
use FindBin;
require "$FindBin::Bin/../sbo_dependency_resolver.pl";

subtest "#initialize" => sub {
  Main->initialize("$FindBin::Bin/data/SLACKBUILDS.TEST.TXT");

  subtest "it store packages and their dependencies" => sub {
    is($Main::dep->{paket1}, 'paket2'       );
    is($Main::dep->{paket2}, undef          );
    is($Main::dep->{paket3}, 'paket1 paket2');
  };
};

subtest "#search_package" => sub{
  Main->initialize("$FindBin::Bin/data/SLACKBUILDS.TEST.TXT");

  subtest "it can search exact name" => sub {
    is_deeply([Main->search_package('paket2')], ['paket2']);
  };

  subtest "it can search case insensitive" => sub {
    is_deeply([Main->search_package('paKet2')], ['paket2']);
  };

  subtest "it can search using regex" => sub {
    is_deeply([sort Main->search_package('p.*et[13]')], [sort ('paket1', 'paket3')]);
  };
};

subtest "#build_graph" => sub {
  Main->initialize("$FindBin::Bin/data/SLACKBUILDS.TEST.TXT");

  subtest "it add nodes of package name and its dependencies" => sub {
    ok(Main->build_graph('paket3')->has_vertex('paket3'));
    ok(Main->build_graph('paket3')->has_vertex('paket2'));
    ok(Main->build_graph('paket3')->has_vertex('paket1'));
  };

  subtest "it add edge from package and its dependencies to their dependencies" => sub {
    ok(Main->build_graph('paket3')->has_edge('paket3', 'paket1'));
    ok(Main->build_graph('paket3')->has_edge('paket3', 'paket2'));
    ok(Main->build_graph('paket3')->has_edge('paket1', 'paket2'));
  };
};

done_testing;
