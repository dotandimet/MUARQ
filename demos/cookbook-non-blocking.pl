use Mojo::Base -strict;

## https://mojolicious.org/perldoc/Mojolicious/Guides/Cookbook#Non-blocking
use Mojo::UserAgent;
use Mojo::IOLoop;

my @urls = (
  'mojolicious.org/perldoc/Mojo/DOM',  'mojolicious.org/perldoc/Mojo',
  'mojolicious.org/perldoc/Mojo/File', 'mojolicious.org/perldoc/Mojo/URL'
);

# User agent with a custom name, following up to 5 redirects
my $ua = Mojo::UserAgent->new(max_redirects => 5);
$ua->transactor->name('MyParallelCrawler 1.0');

# Use a delay to keep the event loop running until we are done
my $delay = Mojo::IOLoop->delay;
my $fetch;
$fetch = sub {

  # Stop if there are no more URLs
  return unless my $url = shift @urls;

  # Fetch the next title
  my $end = $delay->begin;
  $ua->get($url => sub {
    my ($ua, $tx) = @_;
    say "$url: ", $tx->result->dom->at('title')->text;

    # Next request
    $fetch->();
    $end->();
  });
};

# Process two requests at a time
$fetch->() for 1 .. 2;
$delay->wait;
