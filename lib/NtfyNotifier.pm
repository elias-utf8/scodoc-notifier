package NtfyNotifier;

use strict;
use warnings;
use LWP::UserAgent;

sub send_notification {
    my ($topic, $title, $message) = @_;

    return 0 unless $topic;

    my $ua = LWP::UserAgent->new(
        timeout => 10,
        ssl_opts => { verify_hostname => 0, SSL_verify_mode => 0 }
    );
    my $url = "https://ntfy.sh/$topic";

    my $response = $ua->post($url,
        'Content-Type' => 'text/plain; charset=utf-8',
        'Title' => $title,
        Content => $message
    );

    if ($response->is_success) {
        return 1;
    } else {
        warn "ntfy.sh notification failed: " . $response->status_line . "\n";
        return 0;
    }
}

1;
