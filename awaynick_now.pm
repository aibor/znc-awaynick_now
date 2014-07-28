package awaynick_now;

use base 'ZNC::Module';
sub module_types { $ZNC::CModInfo::UserModule }

sub description {
  "Change your nick while you are away - immediately"
}

sub OnLoad {
  my $self = shift;
  my ($sArgs, $sErrorMsg) = @_;
  my @args = split(' ', $sArgs);
  $self->{sAWawaynick} = $args[0];
  1
}
 
sub OnIRCConnected {
  my $self = shift;
  my $user = $self->GetUser;
  $self->SetAway unless($user->IsUserAttached);
}

sub OnClientLogin {
  my $self = shift;
  my $user = $self->GetUser;
  my $nick = $user->GetIRCNick->GetNick;
  $self->SetBack if($user->IsIRCConnected and ($nick eq $self->{sAWawaynick}));
}
 
sub OnClientDisconnect {
  my $self = shift;
  my $user = $self->GetUser;
  $self->SetAway if($user->IsIRCConnected and !$user->IsUserAttached);
}

sub SetBack {
  my $self = shift;
  my $nick = $self->{sAWnick} // $self->GetUser->GetNick;
  $self->PutIRC("NICK " . $nick);
}

sub SetAway {
  my $self = shift;
  $self->{sAWnick} = $self->GetUser->GetIRCNick->GetNick;
  $self->PutIRC("NICK " . $self->{sAWawaynick});
}

1;
