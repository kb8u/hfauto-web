package HFautoWeb::Snapshot;
use Mojo::Base 'Mojolicious::Controller';
use Mojolicious::Plugin::Util::RandomString;
use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Handle::UDP;
use JSON::XS;
use XML::Simple ':strict';
use Data::Compare;

# This action will render a template
sub snapshot {
  my $self = shift;

  $self->stash('hfa_json' => $self->app->{'hfa_json'});
  $self->render(msg => 'Snap shot of hfauto');
}


sub stream {
  my $self = shift;

  my $hfauto_rx = AnyEvent::Handle::UDP->new(
    bind => ['10.34.34.34', 15080],
    on_recv => sub {
        my ($datagram, $ae_handle, $sock_addr) = @_;
        my ($service, $host) = AnyEvent::Socket::unpack_sockaddr($sock_addr);

        $self->app->{'hfa_json'} = encode_json(XMLin(
                  $datagram, KeyAttr => 'HFAUTO', ForceArray => 0));

        # send json if there's a new client (no cookie)
        unless (exists $self->app->{'last_hfa_json'}->{$self->session('hfa_client')}) {
          $self->send($self->app->{'hfa_json'});
          $self->app->{'last_hfa_json'}->{$self->session('hfa_client')} =
            $self->app->{'hfa_json'};
          return;
        }

        # send new json if it's different than the last json sent
        unless (Compare(decode_json($self->app->{'hfa_json'}),
                        decode_json($self->app->{'last_hfa_json'}->{$self->session('hfa_client')}))) {
          $self->send($self->app->{'hfa_json'});
          $self->app->{'last_hfa_json'}->{$self->session('hfa_client')} = $self->app->{'hfa_json'};
        }
    });

  $self->on(finish => sub { $hfauto_rx->destroy });
}


sub prep {
  my $self = shift;

  $self->session( hfa_client => $self->random_string );
  $self->render();
}


1;
