package Mojolicious::Plugin::Resque;
use Mojo::Base 'Mojolicious::Plugin';
use Resque;
use strict;

#ABSTRACT: Mojolicious helper for sending jobs to a Resque queue.

has _config => sub {{}};
has resque => sub { Resque->new(%{shift->_config}) };

sub register {
    my ( $self, $app, $cfg ) = @_;
    $cfg ||= {};
    my $helper = delete $cfg->{helper} || 'resque';
    $self->_config($cfg);

    $app->helper( $helper => sub { 
        my $c = shift;
        return $self->resque unless @_;
        $self->resque->push(@_);
    });
}

1;

=head1 SYNOPSIS

Provides a helper to ease the use of Resque in your Mojolicious application.

    # Lite app with options
    plugin 'resque' => {
        server => 'localhost:6379',
        helper => 'resque'
    };

    # Same as
    plugin 'resque';


    # Full app at startup()
    sub startup {
      my $self = shift;

      $self->plugin( resque => {
        server => 'localhost:6379',
        helper => 'resque'
      });
    }

=head1 CONFIGURATION OPTIONS

You can pass any argument accepted by L<Resque> constructor plus:

=head2 helper

Name for the helper method created by this plugin. By default it will be 'resque'.

=head1 HELPERS

=head2 resque

When used without arguments this helper will return an instance of resque ready to use.
If you pass arguments those will be passed to L<Resque/push> as this is the most common method
to be used from your app in runtime.

So, this two examples do just the same:

    sub my_action {
      my $self = shift;

      # ping Redis server
      $self->resque->push( my_queue => {
        class => 'My::Task',
        args  => [ 'Bite my shiny metal ass!' ]
      });

      $self->resque( my_queue => {
        class => 'My::Task',
        args  => [ 'Bite my shiny metal ass!' ]
      });
    }

=cut

