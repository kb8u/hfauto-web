package HFautoWeb::Snapshot;
use Mojo::Base 'Mojolicious::Controller';
use JSON::XS;
use Data::Compare;

# This action will render a template
sub snapshot {
  my $self = shift;

  $self->stash('hfa_json' => $self->app->{'hfa_json'});
  $self->render(msg => 'Snap shot of hfauto');
}


sub stream {
  my $self = shift;

  $self->on(message => sub {
    my ($self) = @_;
    unless (exists $self->app->{'last_hfa_json'}->{$self->session('hfa_client')}) {
      $self->send($self->app->{'hfa_json'});
      $self->app->{'last_hfa_json'}->{$self->session('hfa_client')} =
          $self->app->{'hfa_json'};
      return;
    }
    unless (Compare(decode_json($self->app->{'hfa_json'}),
                    decode_json($self->app->{'last_hfa_json'}->{$self->session('hfa_client')}))) {
        $self->send($self->app->{'hfa_json'});
        $self->app->{'last_hfa_json'}->{$self->session('hfa_client')} = $self->app->{'hfa_json'};
    }
  });
}


sub prep {
  my $self = shift;

  $self->session( hfa_client => $self->random_string );
  $self->render();
}


1;
