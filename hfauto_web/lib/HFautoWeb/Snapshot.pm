package HFautoWeb::Snapshot;
use Mojo::Base 'Mojolicious::Controller';

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
    if ($self->app->{'hfa_json_changed'}) {
      $self->send($self->app->{'hfa_json'});
    }
  });
}


sub prep {
  my $self = shift;

  $self->render();
}


1;
