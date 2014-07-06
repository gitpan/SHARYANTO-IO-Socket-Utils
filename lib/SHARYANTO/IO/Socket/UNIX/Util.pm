package SHARYANTO::IO::Socket::UNIX::Util;

use 5.010001;
use strict;
use warnings;

use IO::Socket::UNIX;
use POSIX qw(locale_h);

our $DATE = '2014-07-06'; # DATE
our $VERSION = '0.01'; # VERSION

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       create_unix_socket
               );

sub create_unix_socket {
    my ($path, $mode) = @_;

    my $old_locale = setlocale(LC_ALL);
    setlocale(LC_ALL, "C"); # so that error messages are in English

    # probe the Unix socket first, delete if stale
    my $sock = IO::Socket::UNIX->new(
        Type => SOCK_STREAM,
        Peer => $path,
    );
    my $err = $@ unless $sock;
    if ($sock) {
        die "Some process is already listening on $path, aborting";
    } elsif ($err =~ /^connect: permission denied/i) {
        die "Cannot access $path, aborting";
    } elsif (1) { #$err =~ /^connect: connection refused/i) {
        unlink $path;
    } elsif ($err !~ /^connect: no such file/i) {
        die "Cannot bind to $path: $err";
    }

    setlocale(LC_ALL, $old_locale);

    if (defined $mode) {
        warn "Can't chmod $path: $!" unless chmod($mode, $path);
    }

    $sock;
}

1;
# ABSTRACT: Unix domain socket utilities

__END__

=pod

=encoding UTF-8

=head1 NAME

SHARYANTO::IO::Socket::UNIX::Util - Unix domain socket utilities

=head1 VERSION

This document describes version 0.01 of SHARYANTO::IO::Socket::UNIX::Util (from Perl distribution SHARYANTO-IO-Socket-Utils), released on 2014-07-06.

=head1 FUNCTIONS

=head2 create_unix_socket($path[, $mode]) => SOCKET

Create a listening Unix socket. Die on failure.

This function creates Unix domain socket with L<IO::Socket::UNIX> with some
extra stuffs: remove stale socket first, show more detailed/precise error
message, chmod with $mode.

=head1 SEE ALSO

L<SHARYANTO>

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/SHARYANTO-IO-Socket-Utils>.

=head1 SOURCE

Source repository is at L<https://github.com/sharyanto/perl-SHARYANTO-IO-Socket-Utils>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=SHARYANTO-IO-Socket-Utils>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
