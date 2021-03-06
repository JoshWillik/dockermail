# Check if we have SSL certificates in config, otherwise copy it there
# First the key file
if [ -f /mail_settings/ssl-cert-snakeoil.key ]; then
	cp /mail_settings/ssl-cert-snakeoil.key /etc/ssl/private/ssl-cert-snakeoil.key
else
	cp /etc/ssl/private/ssl-cert-snakeoil.key /mail_settings/ssl-cert-snakeoil.key
fi
# Then the pem file
if [ -f /mail_settings/ssl-cert-snakeoil.pem ]; then
	cp /mail_settings/ssl-cert-snakeoil.pem /etc/ssl/certs/ssl-cert-snakeoil.pem
else
	cp /etc/ssl/certs/ssl-cert-snakeoil.pem /mail_settings/ssl-cert-snakeoil.pem
fi

# Copy OpenDKIM config
cp /mail_settings/opendkim.conf /etc/opendkim.conf
cp /mail_settings/mail.private /etc/dkim.key
chown opendkim:opendkim /etc/dkim.key
chmod 600 /etc/dkim.key

if [ -f /mail_settings/myhostname ]; then
	sed -i -e "s/myhostname = localhost/myhostname = $(sed 's:/:\\/:g' /mail_settings/myhostname)/" /etc/postfix/main.cf
	echo $(sed 's:/:\\/:g' /mail_settings/myhostname) > /etc/mailname
fi

# configure mail delivery to dovecot
cp /mail_settings/aliases /etc/postfix/virtual
cp /mail_settings/domains /etc/postfix/virtual-mailbox-domains

# todo: this could probably be done in one line
mkdir /etc/postfix/tmp
awk < /etc/postfix/virtual '{print $2}' > /etc/postfix/tmp/virtual-receivers
sed -r 's,(.+)@(.+),\2/\1/,' /etc/postfix/tmp/virtual-receivers > /etc/postfix/tmp/virtual-receiver-folders
paste /etc/postfix/tmp/virtual-receivers /etc/postfix/tmp/virtual-receiver-folders > /etc/postfix/virtual-mailbox-maps

# give postfix the ownership of his files
chown -R postfix:postfix /etc/postfix

# map virtual aliases and user/filesystem mappings
postmap /etc/postfix/virtual
postmap /etc/postfix/virtual-mailbox-maps
chown -R postfix:postfix /etc/postfix

# make user vmail own all mail folders
chown -R vmail:vmail /vmail
chmod u+w /vmail

# Add password file
cp /mail_settings/passwords /etc/dovecot/passwd
