package EmailNotifier;

use strict;
use warnings;
use MIME::Lite;

sub send_notification {
    my ($smtp_host, $smtp_user, $smtp_pass, $email_from, $email_to, $subject, $body) = @_;
    
    my $msg = MIME::Lite->new(
        From    => $email_from,
        To      => $email_to,
        Subject => $subject,
        Data    => $body
    );
    
    MIME::Lite->send('smtp', $smtp_host, 
        Port => 587,
        AuthUser => $smtp_user,
        AuthPass => $smtp_pass
    );
    
    $msg->send;
    
    return 1;
}

1;
