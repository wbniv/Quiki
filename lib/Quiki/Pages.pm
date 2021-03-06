package Quiki::Pages;

use warnings;
use strict;

use File::Slurp 'slurp';
use Text::Patch;
use Text::Diff;

sub unlock {
    my ($class, $node) = @_;
    unlink "data/locks/$node" if -f "data/locks/$node";
}

sub locked {
    my ($class, $node, $user) = @_;
    if (-f "data/locks/$node") {
        if (-M "data/locks/$node" < 0.01) {
            if ($user) {
                return (slurp("data/locks/$node") ne $user);
            }
            else {
                return 1;
            }
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}


sub locked_for_user {
    my ($class, $node, $user) = @_;
    return 0 unless $user;
    return 0 unless -f "data/locks/$node";
    return 0 unless -M "data/locks/$node" < 0.01;
    return (slurp("data/locks/$node") eq $user);
}

sub lock {
    my ($class, $node, $user) = @_;

    open LOCK, "> data/locks/$node" or die;
    print LOCK $user;
    close LOCK;
}

sub check_in {
    my ($class, $Quiki, $node, $contents) = @_;

    # XXX nasty check, needed for diff
    $contents .= "\n" unless ($contents =~ m/\n$/);

    my $rev = $Quiki->{meta}{rev} || 0;

    if ($rev > 0) {
        my $current = slurp "data/content/$node";
        my $diff = diff(\$contents, \$current, { STYLE=>'Unified' });

        open F, ">data/revs/$node.$rev" or die $!;
        print F $diff;
        close F;
    }

    my $file = "data/content/$node";

    #if (defined($contents)) {
    unless ($contents =~ m/^Edit me!/) {
        $Quiki->{meta}{revs}{$Quiki->{meta}{rev}}{last_update_by} = $Quiki->{meta}{last_update_by};
        $Quiki->{meta}{revs}{$Quiki->{meta}{rev}}{last_updated_in} = $Quiki->{meta}{last_updated_in};
        $Quiki->{meta}{rev}++ ;
    }


    open O, "> $file" or die $!;
    print O $contents;
    close O;
    #}
    #else {
    #    unlink "data/contents/$node"
    #}
}

sub check_out {
    my ($class, $Quiki, $node, $rev) = @_;

    my $cur_rev  = $Quiki->{meta}{rev};
    my $content = slurp "data/content/$node";

    while (($rev || 0) < $cur_rev--) {
        my $patch = slurp "data/revs/$node.$cur_rev";

        $content = patch($content, $patch, {STYLE=>'Unified'});
    }

    return $content;
}

sub calc_diff {
    my ($class, $Quiki, $node, $rev, $target) = @_;

    my $one = Quiki::Pages->check_out($Quiki, $node, $rev);
    my $two = Quiki::Pages->check_out($Quiki, $node, $target);

    diff(\$one, \$two, { STYLE=>'Unified' });
}

'\o/';

=head1 NAME

Quiki::Users - Quiki pages manager

=head1 SYNOPSIS

  use Quiki::Pages;

  # lock a node
  Quiki::Pages->lock($node, $self->{sid});

  # unlock a node
  Quiki::Pages->unlock($node);

  # verify lock status
  $locked = Quiki::Pages->locked($node, $self->{sid}))

  # check in new content
  Quiki::Pages->check_in($self, $node, $content);

  # retrieve content
  $content = Quiki::Pages->check_out($self,$node,$rev);

=head1 DESCRIPTION

This module is handles the needed operations to maintain the pages
information. It is used to gain and free locks to edit pages, and
implements a simple revision system for page's content.

=head2 lock

This method is used to gain a lock to edit a given page.

=head2 unlock

This method is used to free a lock to edit a given page.

=head2 locked

This method is used to verify if exists a lock to a given page.  It
returns false (page not locked) if there isn't a lock or, if a user is
supplied and that user owns the lock.

=head2 locked_for_user

This method is similar to C<< locked >> and needs that a user is supplied.
It returns true only if the page is locked by the supplied user.

=head2 check_in

This method is used to update new content to a page. It creates
a diff file and increments the revision number.

=head2 check_out

This method returns the content for a given page and revision
number.

=head2 calc_diff

This method calculates the diff between any two given revisions for
a page.

=head1 SEE ALSO

Quiki, perl(1)

=head1 AUTHOR

Alberto Simões, E<lt>ambs@cpan.orgE<gt>
Nuno Carvalho, E<lt>smash@cpan.orgE<gt>

=head1 COPYRIGHT & LICENSE

Copyright 2009-2010 Alberto Simoes and Nuno Carvalho.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

