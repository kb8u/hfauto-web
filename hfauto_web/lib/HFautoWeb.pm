package HFautoWeb;
use EV;
use AnyEvent;
use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::Util::RandomString;
use AnyEvent::Socket;
use AnyEvent::Handle::UDP;
use XML::Simple ':strict';
use JSON::XS;


# This method will run once at server start
sub startup {
  my $self = shift;

  $self->plugin('Util::RandomString');

  # Router
  my $r = $self->routes;

  # prep_debug is the main page, it get json_stream for data to display
  # shows json data as it arrives, no efforts to keep alive websocket
  $r->get('prep_debug')->to(controller =>'dataview', action =>'prep_debug');
  $r->websocket('json_stream')->to(controller =>'dataview', action =>'stream');
}

1;
