#!/bin/bash

set -ue

yay -Sy --noconfirm docker docker-compose
systemctl enable docker
systemctl start docker

BUCKET=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/script_bucket" -H "Metadata-Flavor: Google")
INSTANCE_NAME=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")
export MAIL_HOST_NAME=$(curl  -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/mail_host_name")
  


mkdir -p /opt/docker-mail-server/data/{config,etc,mail-data,mail-logs,mail-state}
cd /opt/docker-mail-server

BACKUP=/tmp/$INSTANCE_NAME/backups/docker-mail-server.tar.gz
if [ -f $BACKUP ]
then
   tar xvfz $BACKUP 
fi

MAIL_RELAY=$(gcloud secrets versions access latest --secret="mail-relay" )
export RELAY_HOST=$(echo $MAIL_RELAY | jq -r .host)
export RELAY_PORT=$(echo $MAIL_RELAY | jq -r .port)
export RELAY_USER=$(echo $MAIL_RELAY | jq -r .user)
export RELAY_PASSWORD=$(echo $MAIL_RELAY | jq -r .password)


cat << EOF >> ./mailserver.env
# -----------------------------------------------
# --- Mailserver Environment Variables ----------
# -----------------------------------------------

# DOCUMENTATION FOR THESE VARIABLES IS FOUND UNDER
# https://docker-mailserver.github.io/docker-mailserver/edge/config/environment/

# -----------------------------------------------
# --- General Section ---------------------------
# -----------------------------------------------

# empty => uses the _hostname_ command to get the mail server's canonical hostname
# => Specify a fully-qualified domainname to serve mail for.  This is used for many of the config features so if you can't set your hostname (e.g. you're in a container platform that doesn't let you) specify it in this environment variable.
OVERRIDE_HOSTNAME=$MAIL_HOST_NAME

# REMOVED in version v11.0.0! Use LOG_LEVEL instead.
DMS_DEBUG=0

# Set the log level for DMS.
# This is mostly relevant for container startup scripts and change detection event feedback.
#
# Valid values (in order of increasing verbosity) are: _error_, _warn_, _info_, _debug_ and _trace_.
# The default log level is _info_.
LOG_LEVEL=info

# critical => Only show critical messages
# error => Only show erroneous output
# **warn** => Show warnings
# info => Normal informational output
# debug => Also show debug messages
SUPERVISOR_LOGLEVEL=

# 0 => mail state in default directories
# 1 => consolidate all states into a single directory (_/var/mail-state_) to allow persistence using docker volumes
ONE_DIR=1

# **empty** => use FILE
# LDAP => use LDAP authentication
# OIDC => use OIDC authentication (not yet implemented)
# FILE => use local files (this is used as the default)
ACCOUNT_PROVISIONER=

# empty => postmaster@domain.com
# => Specify the postmaster address
POSTMASTER_ADDRESS=

# Check for updates on container start and then once a day
# If an update is available, a mail is sent to POSTMASTER_ADDRESS
# 0 => Update check disabled
# 1 => Update check enabled
ENABLE_UPDATE_CHECK=1

# Customize the update check interval.
# Number + Suffix. Suffix must be 's' for seconds, 'm' for minutes, 'h' for hours or 'd' for days.
UPDATE_CHECK_INTERVAL=1d

# Set different options for mynetworks option (can be overwrite in postfix-main.cf)
# **WARNING**: Adding the docker network's gateway to the list of trusted hosts, e.g. using the _network_ or
# _connected-networks_ option, can create an open relay
# https://github.com/docker-mailserver/docker-mailserver/issues/1405#issuecomment-590106498
# The same can happen for rootless podman. To prevent this, set the value to "none" or configure slirp4netns
# https://github.com/docker-mailserver/docker-mailserver/issues/2377
#
# none => Explicitly force authentication
# container => Container IP address only
# host => Add docker container network (ipv4 only)
# network => Add all docker container networks (ipv4 only)
# connected-networks => Add all connected docker networks (ipv4 only)
PERMIT_DOCKER=none

# Set the timezone. If this variable is unset, the container runtime will try to detect the time using
# _/etc/localtime_, which you can alternatively mount into the container. The value of this variable
# must follow the pattern _AREA/ZONE_, i.e. of you want to use Germany's time zone, use _Europe/Berlin_.
# You can lookup all available timezones here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List
TZ=Europe/Helsinki

# In case you network interface differs from 'eth0', e.g. when you are using HostNetworking in Kubernetes,
# you can set NETWORK_INTERFACE to whatever interface you want. This interface will then be used.
#  - **empty** => eth0
NETWORK_INTERFACE=

# empty => modern
# modern => Enables TLSv1.2 and modern ciphers only. (default)
# intermediate => Enables TLSv1, TLSv1.1 and TLSv1.2 and broad compatibility ciphers.
TLS_LEVEL=

# Configures the handling of creating mails with forged sender addresses.
#
# empty => (not recommended, but default for backwards compatibility reasons)
#           Mail address spoofing allowed. Any logged in user may create email messages with a forged sender address.
#           See also https://en.wikipedia.org/wiki/Email_spoofing
# 1 => (recommended) Mail spoofing denied. Each user may only send with his own or his alias addresses.
#       Addresses with extension delimiters(http://www.postfix.org/postconf.5.html#recipient_delimiter) are not able to send messages.
SPOOF_PROTECTION=1

# Enables the Sender Rewriting Scheme. SRS is needed if your mail server acts as forwarder. See [postsrsd](https://github.com/roehling/postsrsd/blob/master/README.md#sender-rewriting-scheme-crash-course) for further explanation.
#  - **0** => Disabled
#  - 1 => Enabled
ENABLE_SRS=0

# 1 => Enables POP3 service
# empty => disables POP3
ENABLE_POP3=
ENABLE_CLAMAV=0

# Amavis content filter (used for ClamAV & SpamAssassin)
# 0 => Disabled
# 1 => Enabled
ENABLE_AMAVIS=0

# -1/-2/-3 => Only show errors
# **0**    => Show warnings
# 1/2      => Show default informational output
# 3/4/5    => log debug information (very verbose)
AMAVIS_LOGLEVEL=0

# This enables the [zen.spamhaus.org](https://www.spamhaus.org/zen/) DNS block list in postfix
# and various [lists](https://github.com/docker-mailserver/docker-mailserver/blob/f7465a50888eef909dbfc01aff4202b9c7d8bc00/target/postfix/main.cf#L58-L66) in postscreen.
# Note: Emails will be rejected, if they don't pass the block list checks!
# **0** => DNS block lists are disabled
# 1     => DNS block lists are enabled
ENABLE_DNSBL=0

# If you enable Fail2Ban, don't forget to add the following lines to your _docker-compose.yml_:
#    cap_add:
#      - NET_ADMIN
# Otherwise, _nftables_ won't be able to ban IPs.
ENABLE_FAIL2BAN=0

# Fail2Ban blocktype
# drop   => drop packet (send NO reply)
# reject => reject packet (send ICMP unreachable)
FAIL2BAN_BLOCKTYPE=drop

# 1 => Enables Managesieve on port 4190
# empty => disables Managesieve
ENABLE_MANAGESIEVE=

# **enforce** => Allow other tests to complete. Reject attempts to deliver mail with a 550 SMTP reply, and log the helo/sender/recipient information. Repeat this test the next time the client connects.
# drop => Drop the connection immediately with a 521 SMTP reply. Repeat this test the next time the client connects.
# ignore => Ignore the failure of this test. Allow other tests to complete. Repeat this test the next time the client connects. This option is useful for testing and collecting statistics without blocking mail.
POSTSCREEN_ACTION=enforce

# empty => all daemons start
# 1 => only launch postfix smtp
SMTP_ONLY=

# Please read [the SSL page in the documentation](https://docker-mailserver.github.io/docker-mailserver/edge/config/security/ssl) for more information.
#
# empty => SSL disabled
# letsencrypt => Enables Let's Encrypt certificates
# custom => Enables custom certificates
# manual => Let's you manually specify locations of your SSL certificates for non-standard cases
# self-signed => Enables self-signed certificates
SSL_TYPE=letsencrypt

# These are only supported with _SSL_TYPE=manual_.
# Provide the path to your cert and key files that you've mounted access to within the container.
SSL_CERT_PATH=
SSL_KEY_PATH=
# Optional: A 2nd certificate can be supported as fallback (dual cert support), eg ECDSA with an RSA fallback.
# Useful for additional compatibility with older MTA and MUA (eg pre-2015).
SSL_ALT_CERT_PATH=
SSL_ALT_KEY_PATH=

# Set how many days a virusmail will stay on the server before being deleted
# empty => 7 days
VIRUSMAILS_DELETE_DELAY=

# This Option is activating the Usage of POSTFIX_DAGENT to specify a lmtp client different from default dovecot socket.
# empty => disabled
# 1 => enabled
ENABLE_POSTFIX_VIRTUAL_TRANSPORT=

# Enabled by ENABLE_POSTFIX_VIRTUAL_TRANSPORT. Specify the final delivery of postfix
#
# empty => fail
# _lmtp:unix:private/dovecot-lmtp_ (use socket)
# _lmtps:inet:<host>:<port>_ (secure lmtp with starttls, take a look at https://sys4.de/en/blog/2014/11/17/sicheres-lmtp-mit-starttls-in-dovecot/)
# _lmtp:<kopano-host>:2003_ (use kopano as mailstore)
# etc.
POSTFIX_DAGENT=

# Set the mailbox size limit for all users. If set to zero, the size will be unlimited (default).
#
# empty => 0
POSTFIX_MAILBOX_SIZE_LIMIT=

# See https://docker-mailserver.github.io/docker-mailserver/edge/config/user-management/accounts/#notes
# 0 => Dovecot quota is disabled
# 1 => Dovecot quota is enabled
ENABLE_QUOTAS=1

# Set the message size limit for all users. If set to zero, the size will be unlimited (not recommended!)
#
# empty => 10240000 (~10 MB)
POSTFIX_MESSAGE_SIZE_LIMIT=

# Mails larger than this limit won't be scanned.
# ClamAV must be enabled (ENABLE_CLAMAV=1) for this.
#
# empty => 25M (25 MB)
CLAMAV_MESSAGE_SIZE_LIMIT=

# Enables regular pflogsumm mail reports.
# This is a new option. The old REPORT options are still supported for backwards compatibility. If this is not set and reports are enabled with the old options, logrotate will be used.
#
# not set => No report
# daily_cron => Daily report for the previous day
# logrotate => Full report based on the mail log when it is rotated
PFLOGSUMM_TRIGGER=

# Recipient address for pflogsumm reports.
#
# not set => Use REPORT_RECIPIENT or POSTMASTER_ADDRESS
# => Specify the recipient address(es)
PFLOGSUMM_RECIPIENT=

# Sender address (_FROM_) for pflogsumm reports if pflogsumm reports are enabled.
#
# not set => Use REPORT_SENDER
# => Specify the sender address
PFLOGSUMM_SENDER=

# Interval for logwatch report.
#
# none => No report is generated
# daily => Send a daily report
# weekly => Send a report every week
LOGWATCH_INTERVAL=

# Recipient address for logwatch reports if they are enabled.
#
# not set => Use REPORT_RECIPIENT or POSTMASTER_ADDRESS
# => Specify the recipient address(es)
LOGWATCH_RECIPIENT=

# Sender address (_FROM_) for logwatch reports if logwatch reports are enabled.
#
# not set => Use REPORT_SENDER
# => Specify the sender address
LOGWATCH_SENDER=

# Defines who receives reports if they are enabled.
# **empty** => POSTMASTER_ADDRESS
# => Specify the recipient address
REPORT_RECIPIENT=

# Defines who sends reports if they are enabled.
# **empty** => mailserver-report@DOMAINNAME
# => Specify the sender address
REPORT_SENDER=

# Changes the interval in which log files are rotated
# **weekly** => Rotate log files weekly
# daily => Rotate log files daily
# monthly => Rotate log files monthly
#
# Note: This Variable actually controls logrotate inside the container
# and rotates the log files depending on this setting. The main log output is
# still available in its entirety via _docker logs mail_ (Or your
# respective container name). If you want to control logrotation for
# the Docker-generated logfile see:
# https://docs.docker.com/config/containers/logging/configure/
#
# Note: This variable can also determine the interval for Postfix's log summary reports, see [_PFLOGSUMM_TRIGGER_](#pflogsumm_trigger).
LOGROTATE_INTERVAL=weekly

# Choose TCP/IP protocols for postfix to use
# **all** => All possible protocols.
# ipv4 => Use only IPv4 traffic. Most likely you want this behind Docker.
# ipv6 => Use only IPv6 traffic.
#
# Note: More details at http://www.postfix.org/postconf.5.html#inet_protocols
POSTFIX_INET_PROTOCOLS=ipv4

# Choose TCP/IP protocols for dovecot to use
# **all** => Listen on all interfaces
# ipv4 => Listen only on IPv4 interfaces. Most likely you want this behind Docker.
# ipv6 => Listen only on IPv6 interfaces.
#
# Note: More information at https://dovecot.org/doc/dovecot-example.conf
DOVECOT_INET_PROTOCOLS=ipv4

# -----------------------------------------------
# --- SpamAssassin Section ----------------------
# -----------------------------------------------

ENABLE_SPAMASSASSIN=0

# deliver spam messages in the inbox (eventually tagged using SA_SPAM_SUBJECT)
SPAMASSASSIN_SPAM_TO_INBOX=1

# KAM is a 3rd party SpamAssassin ruleset, provided by the McGrail Foundation.
# If SpamAssassin is enabled, KAM can be used in addition to the default ruleset.
# - **0** => KAM disabled
# - 1 => KAM enabled
#
# Note: only has an effect if _ENABLE_SPAMASSASSIN=1_
ENABLE_SPAMASSASSIN_KAM=0

# spam messages will be moved in the Junk folder (SPAMASSASSIN_SPAM_TO_INBOX=1 required)
MOVE_SPAM_TO_JUNK=1

# add spam info headers if at, or above that level:
SA_TAG=2.0

# add 'spam detected' headers at that level
SA_TAG2=6.31

# triggers spam evasive actions
SA_KILL=6.31

# add tag to subject if spam detected
SA_SPAM_SUBJECT=***SPAM*****

# -----------------------------------------------
# --- Fetchmail Section -------------------------
# -----------------------------------------------

ENABLE_FETCHMAIL=0

# The interval to fetch mail in seconds
FETCHMAIL_POLL=300

# -----------------------------------------------
# --- LDAP Section ------------------------------
# -----------------------------------------------

# A second container for the ldap service is necessary (i.e. https://github.com/osixia/docker-openldap)
# For preparing the ldap server to use in combination with this container this article may be helpful: http://acidx.net/wordpress/2014/06/installing-a-mailserver-with-postfix-dovecot-sasl-ldap-roundcube/

# with the :edge tag, use ACCOUNT_PROVISIONER=LDAP
# empty => LDAP authentification is disabled
# 1 => LDAP authentification is enabled
ENABLE_LDAP=

# empty => no
# yes => LDAP over TLS enabled for Postfix
LDAP_START_TLS=

# If you going to use the mailserver in combination with docker-compose you can set the service name here
# empty => mail.domain.com
# Specify the dns-name/ip-address where the ldap-server
LDAP_SERVER_HOST=

# empty => ou=people,dc=domain,dc=com
# => e.g. LDAP_SEARCH_BASE=dc=mydomain,dc=local
LDAP_SEARCH_BASE=

# empty => cn=admin,dc=domain,dc=com
# => take a look at examples of SASL_LDAP_BIND_DN
LDAP_BIND_DN=

# empty** => admin
# => Specify the password to bind against ldap
LDAP_BIND_PW=

# e.g. _"(&(mail=%s)(mailEnabled=TRUE))"_
# => Specify how ldap should be asked for users
LDAP_QUERY_FILTER_USER=

# e.g. _"(&(mailGroupMember=%s)(mailEnabled=TRUE))"_
# => Specify how ldap should be asked for groups
LDAP_QUERY_FILTER_GROUP=

# e.g. _"(&(mailAlias=%s)(mailEnabled=TRUE))"_
# => Specify how ldap should be asked for aliases
LDAP_QUERY_FILTER_ALIAS=

# e.g. _"(&(|(mail=*@%s)(mailalias=*@%s)(mailGroupMember=*@%s))(mailEnabled=TRUE))"_
# => Specify how ldap should be asked for domains
LDAP_QUERY_FILTER_DOMAIN=

# -----------------------------------------------
# --- Dovecot Section ---------------------------
# -----------------------------------------------

# empty => no
# yes => LDAP over TLS enabled for Dovecot
DOVECOT_TLS=

# e.g. _"(&(objectClass=PostfixBookMailAccount)(uniqueIdentifier=%n))"_
DOVECOT_USER_FILTER=

# e.g. _"(&(objectClass=PostfixBookMailAccount)(uniqueIdentifier=%n))"_
DOVECOT_PASS_FILTER=

# Define the mailbox format to be used
# default is maildir, supported values are: sdbox, mdbox, maildir
DOVECOT_MAILBOX_FORMAT=maildir

# empty => no
# yes => Allow bind authentication for LDAP
# https://wiki.dovecot.org/AuthDatabase/LDAP/AuthBinds
DOVECOT_AUTH_BIND=

# -----------------------------------------------
# --- Postgrey Section --------------------------
# -----------------------------------------------

ENABLE_POSTGREY=0
# greylist for N seconds
POSTGREY_DELAY=300
# delete entries older than N days since the last time that they have been seen
POSTGREY_MAX_AGE=35
# response when a mail is greylisted
POSTGREY_TEXT="Delayed by Postgrey"
# whitelist host after N successful deliveries (N=0 to disable whitelisting)
POSTGREY_AUTO_WHITELIST_CLIENTS=5

# -----------------------------------------------
# --- SASL Section ------------------------------
# -----------------------------------------------

ENABLE_SASLAUTHD=0

# empty => pam
# _ldap_ => authenticate against ldap server
# _shadow_ => authenticate against local user db
# _mysql_ => authenticate against mysql db
# _rimap_ => authenticate against imap server
# Note: can be a list of mechanisms like pam ldap shadow
SASLAUTHD_MECHANISMS=

# empty => None
# e.g. with SASLAUTHD_MECHANISMS rimap you need to specify the ip-address/servername of the imap server  ==> xxx.xxx.xxx.xxx
SASLAUTHD_MECH_OPTIONS=

# empty => Use value of LDAP_SERVER_HOST
# Note: since version 10.0.0, you can specify a protocol here (like ldaps://); this deprecates SASLAUTHD_LDAP_SSL.
SASLAUTHD_LDAP_SERVER=

# empty => Use value of LDAP_BIND_DN
# specify an object with priviliges to search the directory tree
# e.g. active directory: SASLAUTHD_LDAP_BIND_DN=cn=Administrator,cn=Users,dc=mydomain,dc=net
# e.g. openldap: SASLAUTHD_LDAP_BIND_DN=cn=admin,dc=mydomain,dc=net
SASLAUTHD_LDAP_BIND_DN=

# empty => Use value of LDAP_BIND_PW
SASLAUTHD_LDAP_PASSWORD=

# empty => Use value of LDAP_SEARCH_BASE
# specify the search base
SASLAUTHD_LDAP_SEARCH_BASE=

# empty => default filter _(&(uniqueIdentifier=%u)(mailEnabled=TRUE))_
# e.g. for active directory: _(&(sAMAccountName=%U)(objectClass=person))_
# e.g. for openldap: _(&(uid=%U)(objectClass=person))_
SASLAUTHD_LDAP_FILTER=

# empty => no
# yes => LDAP over TLS enabled for SASL
# If set to yes, the protocol in SASLAUTHD_LDAP_SERVER must be ldap:// or missing.
SASLAUTHD_LDAP_START_TLS=

# empty => no
# yes => Require and verify server certificate
# If yes you must/could specify SASLAUTHD_LDAP_TLS_CACERT_FILE or SASLAUTHD_LDAP_TLS_CACERT_DIR.
SASLAUTHD_LDAP_TLS_CHECK_PEER=

# File containing CA (Certificate Authority) certificate(s).
# empty => Nothing is added to the configuration
# Any value => Fills the _ldap_tls_cacert_file_ option
SASLAUTHD_LDAP_TLS_CACERT_FILE=

# Path to directory with CA (Certificate Authority) certificates.
# empty => Nothing is added to the configuration
# Any value => Fills the _ldap_tls_cacert_dir_ option
SASLAUTHD_LDAP_TLS_CACERT_DIR=

# Specify what password attribute to use for password verification.
# empty => Nothing is added to the configuration but the documentation says it is _userPassword_ by default.
# Any value => Fills the _ldap_password_attr_ option
SASLAUTHD_LDAP_PASSWORD_ATTR=

# empty => No sasl_passwd will be created
# string => _/etc/postfix/sasl_passwd_ will be created with the string as password
SASL_PASSWD=

# empty => _bind_ will be used as a default value
# _fastbind_ => The fastbind method is used
# _custom_ => The custom method uses userPassword attribute to verify the password
SASLAUTHD_LDAP_AUTH_METHOD=

# Specify the authentication mechanism for SASL bind
# empty => Nothing is added to the configuration
# Any value => Fills the _ldap_mech_ option
SASLAUTHD_LDAP_MECH=

# -----------------------------------------------
# --- SRS Section -------------------------------
# -----------------------------------------------

# envelope_sender => Rewrite only envelope sender address (default)
# header_sender => Rewrite only header sender (not recommended)
# envelope_sender,header_sender => Rewrite both senders
# An email has an "envelope" sender (indicating the sending server) and a
# "header" sender (indicating who sent it). More strict SPF policies may require
# you to replace both instead of just the envelope sender.
SRS_SENDER_CLASSES=envelope_sender

# empty => Envelope sender will be rewritten for all domains
# provide comma separated list of domains to exclude from rewriting
SRS_EXCLUDE_DOMAINS=

# empty => generated when the image is built
# provide a secret to use in base64
# you may specify multiple keys, comma separated. the first one is used for
# signing and the remaining will be used for verification. this is how you
# rotate and expire keys
SRS_SECRET=

# -----------------------------------------------
# --- Default Relay Host Section ----------------
# -----------------------------------------------

# Setup relaying all mail through a default relay host
#
# empty => don't configure default relay host
# default host and optional port to relay all mail through
DEFAULT_RELAY_HOST=[$RELAY_HOST]:$RELAY_PORT

# -----------------------------------------------
# --- Multi-Domain Relay Section ----------------
# -----------------------------------------------

# Setup relaying for multiple domains based on the domain name of the sender
# optionally uses usernames and passwords in postfix-sasl-password.cf and relay host mappings in postfix-relaymap.cf
#
# empty => don't configure relay host
# default host to relay mail through
RELAY_HOST=$RELAY_HOST

# empty => 25
# default port to relay mail
RELAY_PORT=$RELAY_PORT

# empty => no default
# default relay username (if no specific entry exists in postfix-sasl-password.cf)
RELAY_USER=$RELAY_USER

# empty => no default
# password for default relay user
RELAY_PASSWORD=$RELAY_PASSWORD

EOF

cat << EOF >> ./docker-compose.yaml
services:
  mailserver:
    image: docker.io/mailserver/docker-mailserver:latest
    container_name: mailserver
    hostname: eugener.one
    env_file: mailserver.env
    ports:
      - "25:25"    # SMTP  (explicit TLS => STARTTLS)
      - "143:143"  # IMAP4 (explicit TLS => STARTTLS)
      - "465:465"  # ESMTP (implicit TLS)
      - "587:587"  # ESMTP (explicit TLS => STARTTLS)
      - "993:993"  # IMAP4 (implicit TLS)
    volumes:
      - ./data/mail-data/:/var/mail/
      - ./data/mail-state/:/var/mail-state/
      - ./data/mail-logs/:/var/log/mail/
      - ./data/config/:/tmp/docker-mailserver/
      - /etc/localtime:/etc/localtime:ro
      - /etc/letsencrypt:/etc/letsencrypt
    restart: always
    stop_grace_period: 1m
    cap_add:
      - NET_ADMIN
    healthcheck:
      test: "ss --listening --tcp | grep -P 'LISTEN.+:smtp' || exit 1"
      timeout: 3s
      retries: 0
EOF

docker-compose up -d
