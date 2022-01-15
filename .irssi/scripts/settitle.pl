use strict;
use warnings;
use Irssi;

sub set_title {
	my $curname = Irssi::active_win()->{active}->{name} || Irssi::active_win()->{name};
	my $act = '';
	my $first = 1;
	for my $win (Irssi::windows()) {
		if ($win->{data_level} > 1) {
			$act .= ',' if not $first;
			$act .= '@' if $win->{data_level} == 3;
			$act .= $win->{refnum};
			$first = 0;
		}
	}
	print STDERR "\e]0;irssi $curname [$act]\a";
}

sub window_activity {
	my ($window, $old_level) = @_;
	return if $old_level == $window->{data_level};
	set_title;
}

Irssi::signal_add('window activity', 'window_activity');
Irssi::signal_add('window changed', 'set_title');

set_title;
