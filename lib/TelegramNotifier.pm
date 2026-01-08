package TelegramNotifier;

use strict;
use warnings;
use LWP::UserAgent;
use JSON;

sub send_notification {
    my ($bot_token, $chat_id, $message) = @_;

    return 0 unless $bot_token && $chat_id;

    my $ua = LWP::UserAgent->new(
        timeout => 10,
        ssl_opts => { verify_hostname => 0, SSL_verify_mode => 0 }
    );
    my $url = "https://api.telegram.org/bot$bot_token/sendMessage";

    my $response = $ua->post($url, {
        chat_id => $chat_id,
        text    => $message
    });

    if ($response->is_success) {
        return 1;
    } else {
        warn "Telegram notification failed: " . $response->status_line . "\n";
        return 0;
    }
}

1;
