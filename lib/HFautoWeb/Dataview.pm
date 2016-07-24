package HFautoWeb::Dataview;
use Mojo::Base 'Mojolicious::Controller';
use Mojolicious::Plugin::Util::RandomString;
use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Handle::UDP;
use JSON::XS;
use XML::Simple ':strict';
use Data::Compare;


sub stream {
  my $self = shift;

  my $sa = $self->app;
  my $id = sprintf "%s", $self->tx;
  $sa->{'clients'}->{$id} = $self->tx;
  $self->app->log->debug("New websocket client $id");

  my $hfauto_rx = AnyEvent::Handle::UDP->new(
    bind => [$sa->config->{w1tr_ip}, $sa->config->{w1tr_port}],
    on_recv => sub {
        my ($datagram, $ae_handle, $sock_addr) = @_;
        $sa->{'hfa_json'} = encode_json(XMLin(
                  $datagram, KeyAttr => 'HFAUTO', ForceArray => 0));

        # initialize last_hfa_json for new client
        unless (exists $sa->{'last_hfa_json'}->{$id}) {
          $sa->{'last_hfa_json'}->{$id} = encode_json({a => 0});
        }

        # send if json is different than the last json sent for each client
        for my $id (keys %{$sa->{'clients'}}) {
            unless (Compare(decode_json($sa->{'hfa_json'}),
                            decode_json($sa->{'last_hfa_json'}->{$id}))) {
                $sa->{'clients'}->{$id}->send($sa->{'hfa_json'});
                $sa->{'last_hfa_json'}->{$id} = $sa->{'hfa_json'};
            }
        }
    });

  $self->on(message => sub { $self->send('keep-alive') });
  $self->on(finish => sub { delete $sa->{'clients'}->{$id} });
}


sub prep_debug {
  my $self = shift;

  $self->stash( wsUri => $self->app->config->{wsUri} );
  $self->render();
}


sub display {
  my $self = shift;

  $self->stash( wsUri => $self->app->config->{wsUri} );
  $self->render();
}

1;