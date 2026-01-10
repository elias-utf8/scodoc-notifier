#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use LWP::UserAgent;
use HTTP::Cookies;
use JSON;
use lib 'lib';
use EmailNotifier;
use TelegramNotifier;
use NtfyNotifier;

my $json_file = 'notes.json';

# load .env
if (-e '.env') {
    open my $fh, '<', '.env';
    while (<$fh>) {
        chomp;
        my ($k, $v) = split /=/, $_, 2;
        $ENV{$k} = $v;
    }
    close $fh;
}

my $username = $ENV{SCODOC_USER} or die "SCODOC_USER not defined\n";
my $password = $ENV{SCODOC_PASS} or die "SCODOC_PASS not defined\n";
my $smtp_host = $ENV{SMTP_HOST} or die "SMTP_HOST not defined\n";
my $smtp_user = $ENV{SMTP_USER} or die "SMTP_USER not defined\n";
my $smtp_pass = $ENV{SMTP_PASS} or die "SMTP_PASS not defined\n";
my $email_from = $ENV{EMAIL_FROM} or die "EMAIL_FROM not defined\n";
my $email_to = $ENV{EMAIL_TO} or die "EMAIL_TO not defined\n";

# Telegram (optional)
my $telegram_token = $ENV{TELEGRAM_BOT_TOKEN} // '';
my $telegram_chat_id = $ENV{TELEGRAM_CHAT_ID} // '';

# ntfy.sh (optional)
my $ntfy_topic = $ENV{NTFY_TOPIC} // '';

# load old grades
my $old_data = -e $json_file ? decode_json(do { open my $fh, '<', $json_file; local $/; <$fh> }) : {};

# login Scodoc
my $ua = LWP::UserAgent->new(
    agent => 'Mozilla/5.0',
    cookie_jar => HTTP::Cookies->new,
    requests_redirectable => ['GET', 'POST']
);

my $cas_url = 'https://cas.u-bordeaux.fr/cas/login?service=https%3A%2F%2Fnotes.iut.u-bordeaux.fr%2Fservices%2FdoAuth.php%3Fhref%3Dhttps%3A%2F%2Fnotes.iut.u-bordeaux.fr%2F';

my $page = $ua->get($cas_url);
my ($execution) = $page->decoded_content =~ /name="execution" value="([^"]+)"/;

$ua->post($cas_url, {
    username => $username,
    password => $password,
    execution => $execution,
    _eventId => 'submit'
});

# fetch new grades
my $response = $ua->post('https://notes.iut.u-bordeaux.fr/services/data.php?q=dataPremièreConnexion');
my $new_data = decode_json($response->decoded_content);

my $old_notes = $old_data->{relevé}{ressources} // {};
my $new_notes = $new_data->{relevé}{ressources} // {};
my @changes;

foreach my $res (keys %$new_notes) {
    foreach my $eval (@{$new_notes->{$res}{evaluations}}) {
        my $id = $eval->{id};
        my $old_eval = find_eval($old_notes, $id);
        
        # Notify only when a new grade appears (not modifications)
        if (!$old_eval) {
            push @changes, "Nouvelle note : $res - " . $eval->{description};
        }
    }
}

# send notifications if changes detected
if (@changes) {
    my $body = join("\n", @changes);
    my $title = "Nouvelles notes sur Scodoc !";
    my @sent;

    # Email
    if (eval { EmailNotifier::send_notification($smtp_host, $smtp_user, $smtp_pass, $email_from, $email_to, $title, $body) }) {
        push @sent, "Email";
    } else {
        warn "Email error: $@\n" if $@;
    }

    # Telegram
    if ($telegram_token && $telegram_chat_id) {
        if (eval { TelegramNotifier::send_notification($telegram_token, $telegram_chat_id, "$title\n\n$body") }) {
            push @sent, "Telegram";
        } else {
            warn "Telegram error: $@\n" if $@;
        }
    }

    # ntfy.sh
    if ($ntfy_topic) {
        if (eval { NtfyNotifier::send_notification($ntfy_topic, $title, $body) }) {
            push @sent, "ntfy.sh";
        } else {
            warn "ntfy.sh error: $@\n" if $@;
        }
    }

    if (@sent) {
        print "Notifications sent via: " . join(", ", @sent) . " (" . scalar(@changes) . " change(s))\n";
    } else {
        print "Warning: No notifications were sent successfully!\n";
    }
} else {
    print "No changes detected.\n";
}

# Save
open my $fh, '>', $json_file;
print $fh encode_json($new_data);
close $fh;

sub find_eval {
    my ($notes, $id) = @_;
    foreach my $res (values %$notes) {
        foreach my $eval (@{$res->{evaluations} // []}) {
            return $eval if $eval->{id} == $id;
        }
    }
    return undef;
}