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

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');
  $self->plugin('Util::RandomString');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');

  # snapshot of json for debugging purposes
  $r->get('/snapshot')->to(controller => 'snapshot', action => 'snapshot');
  $r->get('prep')->to(controller =>'snapshot', action =>'prep');
  $r->websocket('json_stream')->to(controller =>'snapshot', action =>'stream');
}

1;
