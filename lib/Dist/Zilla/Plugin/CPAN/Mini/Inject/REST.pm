use strict;
use warnings;
package Dist::Zilla::Plugin::CPAN::Mini::Inject::REST;

our $VERSION = '0.001';

use Moose;
use Data::Dump;
extends 'CPAN::Mini::Inject::REST::Client::API';

with 'Dist::Zilla::Role::Releaser';

has '+port' => ( default => 80 );
has '+protocol' => ( default => 'http' );

sub release {
    my ($self, $archive) = @_;

    $self->log_debug(sprintf "Sending %s to %s://%s:%d", $archive, $self->protocol, $self->host, $self->port);

    my ($code, $result) = $self->post(
        qq(repository/$archive) => {
            file => ["$archive"]
        }
    );
    
    if ($code >= 500) {
        # FIXME - does it give us info?
        $self->log_fatal("$code: Server error");
    }
    elsif ($code >= 400) {
        my $error = ref $result ? $result->{error} : $result;

        $error = pp $error if ref $error;

        $self->log_fatal("$code: Client error: $error");
    }
    elsif ($code >= 300) {
        $self->log_fatal("Unexpected $code that wasn't followed");
    }
    else {
        $self->log("Successfully indexed $archive");
    }
}

1;

__END__

=encoding utf-8

=head1 NAME

Dist::Zilla::Plugin::CPAN::Mini::Inject::REST - Uploads to a
L<CPAN::Mini::Inject> mirror using L<CPAN::Mini::Inject::REST>

=head1 DESCRIPTION

Like L<Dist::Zilla::Plugin::Inject>, this plugin is a release-stage plugin that
uploads to a L<CPAN::Mini> mirror. This one expects that the remote is a
L<CPAN::Mini::Inject::REST> server, since it uses
L<CPAN::Mini::Inject::REST::Client::API> to do it.

=ATTRIBUTES

This plugin extends L<CPAN::Mini::Inject::REST::Client::API> and therefore all of its properties can be provided. A summary:

=over

=item host - Required - without the protocol.

=item protocol - Optional. Defaults to C<http>. This differs from the parent class, where it is required.

=item port - Optional. Defaults to C<80>. This differs from the parent class, where it is required.

=item username - Optional. Username for HTTP basic auth.

=item password - Optional. Password for HTTP basic auth.

=back