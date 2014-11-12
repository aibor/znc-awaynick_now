package awaynick_now;

use base 'ZNC::Module';
sub module_types { $ZNC::CModInfo::NetworkModule }

sub description { "Change your nick while you are away - immediately" }

sub has_args { 1 }

sub args_help_text { 'One argument needed: the awaynick.' }

sub OnLoad {
  my $self = shift;
  my ($sArgs, $sErrorMsg) = @_;
  my @args = split(' ', $sArgs);
  $self->{sAWawaynick} = $args[0];
  my $network = $self->GetNetwork;
  $self->SetAway if($network->IsIRCConnected and !$network->IsUserAttached);
  1
}
 
sub OnIRCConnected {
  my $self = shift;
  my $network = $self->GetNetwork;
  $self->SetAway unless($network->IsUserAttached);
}

sub OnClientLogin {
  my $self = shift;
  my $network = $self->GetNetwork;
  my $nick = $network->GetIRCNick->GetNick;
  $self->SetBack if($network->IsIRCConnected and ($nick eq $self->{sAWawaynick}));
}
 
sub OnClientDisconnect {
  my $self = shift;
  my $network = $self->GetNetwork;
  $self->SetAway if($network->IsIRCConnected and !$network->IsUserAttached);
}

sub SetBack {
  my $self = shift;
  my $nick = $self->{sAWnick} // $self->GetNetwork->GetNick;
  $self->PutIRC("NICK " . $nick);
}

sub SetAway {
  my $self = shift;
  $self->{sAWnick} = $self->GetNetwork->GetIRCNick->GetNick;
  $self->PutIRC("NICK " . $self->{sAWawaynick});
}

1;

