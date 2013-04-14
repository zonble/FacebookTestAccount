#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use HTTP::Lite;

package FacebookTestUserManager;
sub new
{
	my $class = shift;
	my $self = {};
	$self->{'appID'} = shift;
	$self->{'appSecret'} = shift;
	bless $self, $class;
	return $self;
}

sub _join_url
{
	my ($self, $base_url, $param) = @_;
	my %params = %{$param};
	for my $key (keys %params) {
		my $value = $params{$key};
		$base_url .= $key . '=' . $value ."&";
	}
	return $base_url;
}

sub _obtainAppAccessToken
{
	my ($self) = @_;
	my $URL = \
		$self->_join_url("https://graph.facebook.com/oauth/access_token?",
						 {'client_id'=> $self->{'appID'},
						  'client_secret' => $self->{'appSecret'},
						  'grant_type' => 'client_credentials'});
	my $http = HTTP::Lite->new;
	my $req = $http->request($URL) or die "Unable to get document: $!";
	print $req->body();
}
1;


my $appID = '181603781919524';
my $appSecret = 'f075c9b716d5b48d04d40275a92c7fc7';
my $m = new FacebookTestUserManager($appID, $appSecret);
print $m->_obtainAppAccessToken();
