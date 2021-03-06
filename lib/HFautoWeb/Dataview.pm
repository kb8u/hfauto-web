package HFautoWeb::Dataview;
use Mojo::Base 'Mojolicious::Controller';
use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Handle::UDP;
use JSON;
use XML::Simple ':strict';
use Data::Compare;
use Net::Address::IP::Local;



sub stream {
  my $self = shift;

  my $sa = $self->app;
  my $id = sprintf "%s", $self->tx;
  $sa->{'clients'}->{$id} = $self->tx;
  $self->app->log->debug("New websocket client $id");

  # guess IP and port if they're not in the conf file
  my $udp_ip = $sa->config->{w1tr_ip} // 0;
  $udp_ip = $udp_ip ? $udp_ip : Net::Address::IP::Local->public;
  my $udp_port = $sa->config->{w1tr_port} // 15080;

  my $hfauto_rx = AnyEvent::Handle::UDP->new(
    bind => [$udp_ip, $udp_port],
    on_recv => sub {
        my ($datagram, $ae_handle, $sock_addr) = @_;

        my $hfa = XMLin($datagram, KeyAttr => 'HFAUTO', ForceArray => 0);
        # frequency has last 3 digits always zero so change it to khz
        for (1..3) { chop $hfa->{'ATU_FREQ'} }
        $hfa->{'ATU_FREQ'} = $hfa->{'ATU_FREQ'} ? $hfa->{'ATU_FREQ'} : 'No RF yet';
        # modes are in all caps, change it to first letter cap only
        $hfa->{'ATU_ANT_SEL_METHOD'} = lc $hfa->{'ATU_ANT_SEL_METHOD'};
        $hfa->{'ATU_ANT_SEL_METHOD'} = ucfirst $hfa->{'ATU_ANT_SEL_METHOD'};
        $hfa->{'ATU_OPER_MODE'} = lc $hfa->{'ATU_OPER_MODE'};
        $hfa->{'ATU_OPER_MODE'} = ucfirst $hfa->{'ATU_OPER_MODE'};

        $sa->{'hfa_json'} = encode_json($hfa);

        # initialize last_hfa_json for new client to random junk so 
        # Compare(decode_json(...)) doesn't complain about invalid json later
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

  my $wsUri = $self->app->config->{wsUri} //
              'http://10.34.34.34:3000/json_stream';
  $self->stash( wsUri => $self->app->config->{wsUri} );
  $self->render();
}


sub display {
  my $self = shift;

  $self->render();
}

1;
