package HFautoWeb;
use EV;
use AnyEvent;
use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::Config;
use Mojo::Log;
use AnyEvent::Socket;
use AnyEvent::Handle::UDP;
use XML::Simple ':strict';
use JSON;


# This method will run once at server start
sub startup {
  my $self = shift;

  $self->secrets(['Hte83oKX93OR@#ozM#be3%08hcA-j232']);
  $self->plugin('Config');

  # Router
  my $r = $self->routes;

  # prep_debug is the main page, it get json_stream for data to display
  # shows json data as it arrives, no efforts to keep alive websocket
  $r->get('prep_debug')->to(controller =>'dataview', action =>'prep_debug');

  # graphical display of xml data from hfauto
  $r->get('hfauto')->to(controller =>'dataview', action =>'display');

  # encode xml into json
  $r->websocket('json_stream')->to(controller =>'dataview', action =>'stream');
}

1;
