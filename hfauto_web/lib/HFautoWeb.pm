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

  my $hfauto_rx = AnyEvent::Handle::UDP->new(
    bind => ['10.34.34.34', 15080],
    on_recv => sub {
        my ($datagram, $ae_handle, $sock_addr) = @_;
        my ($service, $host) = AnyEvent::Socket::unpack_sockaddr($sock_addr);

        $self->{'hfa_json'} = encode_json(XMLin(
                  $datagram, KeyAttr => 'HFAUTO', ForceArray => 0));
    });

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
