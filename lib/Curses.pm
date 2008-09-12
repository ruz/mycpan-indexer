package MyCPAN::Indexer::Interface::Curses;
use strict;
use warnings;

use Log::Log4perl qw(:easy);
use Curses;

=head1 NAME

MyCPAN::Indexer::Interface::Curses - Present the run info in a terminal

=head1 SYNOPSIS

Use this in backpan_indexer.pl by specifying it as the interface class:

	# in backpan_indexer.config
	interface_class  MyCPAN::Indexer::Interface::Curses

=head1 DESCRIPTION

This class presents the information as the indexer runs, using Curses.

=head2 Methods

=over 4

=item do_interface( $Notes )


=cut

sub do_interface 
	{
	my( $class, $Notes ) = @_;
	print "Calling do_interface\n";
	
	initscr();
	noecho();
	raw();
	
	$Notes->{curses}{rows} = LINES();
	$Notes->{curses}{cols} = COLS();
	
	addstr( 0, 0, 'BackPAN Indexer 1.00' );	
	refresh();
	
	$Notes->{curses}{windows}{progress}      = newwin( 3, COLS(),   1,  0 );
	$Notes->{curses}{windows}{left_tracker}  = newwin( 6, 8,   4,  0 );
	$Notes->{curses}{windows}{right_tracker} = newwin( 6, 8,   4, 12 );
	$Notes->{curses}{windows}{PID}           = newwin( 7, COLS(),  10,  0 );
	$Notes->{curses}{windows}{Errors}        = newwin( 7, COLS(), 17,  0 );

	foreach my $value ( values %{ $Notes->{curses}{windows} } )
		{
		box( $value, 0, 0 );
		refresh( $value );
		}
		
	my $count = 0;
	while( 1 )
		{
		$Notes->{interface_callback}->();

		_update_screen( $Notes );
		
		sleep 3;
		
		}

	}

{
my $labels = {
	# Label, win, row, column, key, key length, value length
	Total      => [ qw(left_tracker 1  1 Total         6   6) ],
	Done       => [ qw(left_tracker 2  1 Done          6   6) ],
	Left       => [ qw(left_tracker 3  1 Left          6   6) ],
	Errors     => [ qw(left_tracker 4  1 Errors        6   6) ],
	
#	UUID       => [ qw(right_tracker 1 1 UUID          7  30) ],
#	Started    => [ qw(right_tracker 2 1 Started       7 -30) ],
#	Elapsed    => [ qw(right_tracker 3 1 Elapsed       7 -30) ],
#	Rate       => [ qw(right_tracker 4 1 Rate          7 -30) ],
	};

=pod

	'##'       => [ qw(8  0 ##            2   0) ],
	PID        => [ qw(8  4 PID           6   0) ],
	Processing => [ qw(8 12 Processing   40   0) ],

	ErrorList  => [ qw(15 0 Errors        7   0) ],
=cut

	#};

my $values = {};

sub _update_screen
	{
	&_update_labels;
	&_update_progress;
	#&_update_values;
	}
	
sub _update_labels
	{
	my( $Notes ) = @_;
	
	#print "Calling _update_screen\n";
	
	foreach my $key ( keys %$labels )
		{
		my $tuple = $labels->{$key};
		
		addstr( 
			$Notes->{curses}{windows}{ $tuple->[0] },
			@$tuple[1,2,3] 
			);
		refresh( $Notes->{curses}{windows}{ $tuple->[0] } );
		}

=pod

	my $row = $labels->{'##'}[0];
	foreach my $i ( 1 .. $Notes->{Threads} )
		{
		my $width = $labels->{'##'}[3];
		move( $row + $i, $labels->{'##'}[1] );
		refresh();
		addstr( $row + $i, $labels->{'##'}[1], 
			sprintf "%${width}s", $i );
		refresh;
		}
=cut

	refresh();
	}

sub _update_progress
	{
	my( $Notes ) = @_;

	my $progress = COLS() - 2 / $Notes->{Total} * $Notes->{Done};
	
	addstr( 
		$Notes->{curses}{windows}{progress}, 
		1, 1,
		'*' x $progress 
		);
	refresh( $Notes->{curses}{windows}{progress} );	
	}
	
sub _update_values
	{
	my( $Notes ) = @_;
		
	no warnings;
	foreach my $key ( qw() )
		{
		my $tuple = $labels->{$key};

		next unless $tuple->[4];

		move( 
			$tuple->[0],
			$tuple->[1] + $tuple->[3] + 2
			);
		refresh;
		addstr( 
			$tuple->[0], 
			$tuple->[1] + $tuple->[3] + 2, 
			sprintf "%" . $tuple->[4] . "s", $Notes->{$tuple->[2]} 
			);
		refresh;
		}

=pod

	my $row = $labels->{PID}[0];
	foreach my $i ( 1 .. $Notes->{Threads} )
		{
		my $width = $labels->{'##'}[3];
		addstr( $row + $i, $labels->{'##'}[1], 
			sprintf "%${width}s", $i );

		$width = $labels->{PID}[3];
		addstr( $row + $i, $labels->{PID}[1], 
			sprintf "%${width}s", $Notes->{PID}[$i-1] );

		$width = $labels->{Processing}[3];
		addstr( $row + $i, $labels->{Processing}[1], ' ' x 70 );
		addstr( $row + $i, $labels->{Processing}[1], 
			sprintf "%${width}s", $Notes->{recent}[$i-1] );
		
		}

=cut

	}
}

END { endwin() }

=back


=head1 SEE ALSO

MyCPAN::Indexer

=head1 SOURCE AVAILABILITY

This code is in Github:

	git://github.com/briandfoy/mycpan-indexer.git

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2008, brian d foy, All Rights Reserved.

You may redistribute this under the same terms as Perl itself.

=cut

1;