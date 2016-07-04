#!/usr/bin/env perl
use EV;
use AnyEvent;
use Mojolicious::Lite;
use AnyEvent::Socket;
use AnyEvent::Handle::UDP;
use XML::Simple ':strict';
use JSON::XS;

my $hfa_json;
my $hfauto_rx = AnyEvent::Handle::UDP->new(
    bind => ['10.34.34.34', 15080],
    on_recv => sub {
        my ($datagram, $ae_handle, $sock_addr) = @_;
        my ($service, $host) = AnyEvent::Socket::unpack_sockaddr($sock_addr);

        $hfa_json = encode_json(XMLin(
                  $datagram, KeyAttr => 'HFAUTO', ForceArray => 0));
    });



# Documentation browser under "/perldoc"
plugin 'PODRenderer';

get '/snapshot' => sub {
  my $self = shift;
  $self->stash('hfa_json' => $hfa_json);
  $self->render('snapshot');
};


websocket '/wstest' => sub {
  my $self = shift;
};

app->start;


__DATA__

@@ snapshot.html.ep
<html>
  <head>
    <title>Snapshot of json</title>
  </head>
  <body><%= $hfa_json %></body>
</html>


@@ wstest.html.ep
<html>
  <head><title>Web Socket Snapshot of json</title>
  <script>
// Create a socket instance
var socket = new WebSocket('ws://10.34.34.34:3000');

// Open the socket
socket.onopen = function(event) {

       // Send an initial message
        socket.send('I am the client and I\'m listening!');

        // Listen for messages
        socket.onmessage = function(event) {
                console.log('Client received a message',event);
        };

        // Listen for socket closes
        socket.onclose = function(event) {
                console.log('Client notified socket has closed',event);
        };

        // To close the socket....
        //socket.close()

};
</script>
  </head>
  <body><%= $hfa_json %></body>
</html>
