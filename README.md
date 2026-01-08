# Scodoc Notifier <img src="https://github.com/elias-utf8/scodoc-notifier/blob/master/media/logo.png" alt="logo" width="65"/>

Perl script that monitors grade changes on Scodoc and sends notifications via email, Telegram, or ntfy.sh.

Designed to work with the Bordeaux University Institute of Technology's scodoc.

## Dependencies

Install the required Perl modules:

```bash
cpan JSON MIME::Lite
```

## Configuration

Create a `.env` file at the root of the project with the following variables:

```bash
# Scodoc credentials
SCODOC_USER=your_username
SCODOC_PASS=your_password

# Email configuration (required)
SMTP_HOST=smtp.your-provider.com
SMTP_USER=your_smtp_username
SMTP_PASS=your_smtp_password
EMAIL_FROM=Sender Name <sender@example.com>
EMAIL_TO=recipient@example.com

# Telegram configuration (optional)
TELEGRAM_BOT_TOKEN=your_bot_token
TELEGRAM_CHAT_ID=your_chat_id

# ntfy.sh configuration (optional)
NTFY_TOPIC=your_topic_name
```
You can use [Brevo](https://app.brevo.com/) for smtp provider (300 emails per day).

### Configuration details:

- **SCODOC_USER** / **SCODOC_PASS**: Your Scodoc login credentials
- **SMTP_HOST**: Your SMTP server address
- **SMTP_USER** / **SMTP_PASS**: Your SMTP authentication credentials
- **EMAIL_FROM**: Sender name and email address (format: `Name <email@domain.com>`)
- **EMAIL_TO**: Recipient email address for notifications
- **TELEGRAM_BOT_TOKEN** / **TELEGRAM_CHAT_ID**: Telegram bot credentials (optional)
- **NTFY_TOPIC**: Your ntfy.sh topic name (optional)

## Usage

Run the script:

```bash
perl main.pl
```

### Automate with Cron

To check for new grades automatically every 30 minutes, add this to your crontab:

```bash
crontab -e
```

Then add:

```
*/30 * * * * cd /path/to/scodoc-notifier && perl main.pl
```

Replace `/path/to/scodoc-notifier` with the actual path to your project directory.

## Screenshot

<p align="center">
  <img src="https://github.com/elias-utf8/scodoc-notifier/blob/master/media/screen.jpg" width="300"/>
</p>
