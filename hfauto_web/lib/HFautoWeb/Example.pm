package HFautoWeb::Example;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub welcome {
  my $self = shift;

  $self->stash('hfa_json' => $self->app->{'hfa_json'});
  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'snap shot of json from hfauto');
}

1;
