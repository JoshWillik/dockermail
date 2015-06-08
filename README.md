docker-made-special-mail
==========

Based on https://github.com/lava/dockermail

A secure, minimal-configuration mail server in a docker container.
This repository is tailored to small private servers, where you own a domain and want to host your own mail.

This container uses postfix as MTA and dovecot as IMAP server.
All incoming mail to your domains is accepted.
For outgoing mail, only authenticated (logged in with username and password) clients can send messages via STARTTLS.

SPAM stuff
=====
Outgoing mail is signed by OpenDKIM, you need to generate a key and set up your domain records (see step 5).
You should add PTR record to your IP (aka reverse DNS) which is done by your server provider.
And finally, generate and add an SPF record to your domain, search for instructions on this - there are a few generator site around and the setup steps depend on your domain name provider.


Setup
=====
Create 2 folders: one for mail configuration (`/opt/dockermail/settings`), another for mail storage (`/opt/dockermail/vmail`).
Use the the example config files in `config/example` of this repo.

1. Add all domains you want to receive mail for to the file `/opt/dockermail/settings/domains`, like this:

		example.org
		example.net

2. Add user aliases to the file `/opt/dockermail/settings/aliases`, like

		johndoe@example.org       john.doe@example.org
		john.doe@example.org      john.doe@example.org
		admin@forum.example.org   forum-admin@example.org
		@example.net              catch-all@example.net

	An IMAP mail account is created for each entry on the right hand side.
	Every mail sent to one of the addresses in the left column will be delivered to the corresponding account in the right column.

3. Add user passwords to the file `/opt/dockermail/settings/passwords` like this

		john.doe@example.org:{PLAIN}password123
		admin@example.org:{SHA256-CRYPT}$5$ojXGqoxOAygN91er$VQD/8dDyCYOaLl2yLJlRFXgl.NSrB3seZGXBRMdZAr6

	To get the hash values, you can either install dovecot locally or use `docker exec -it dockermail bash` to attach to the running container (step 7) and run `doveadm pw -s <scheme-name>` inside.

4. Change the hostname in file `/opt/dockermail/settings/myhostname` to the correct fully qualified domain of your server.

5. Add DKIM settings files: `/opt/dockermail/settings/opendkim.conf` and `/opt/dockermail/settings/mail.private`
	 See https://help.ubuntu.com/community/Postfix/DKIM on the info about these settings.
	 You will need to generate your own `mail.private` key and set up your domain records, the `opendkim.conf` from `config/example`
	 is ready to use.

6. Build container

		make

7. Run container and map ports 25 and 143 from the host to the container.
	 To store your mail outside the container, map `/opt/dockermail/vmail/` to
	 a directory on your host. (This is recommended, otherwise
	 you have to remember to backup your mail when you want to restart the container)

	```
	docker run -d \
		-name dockermail \
		-p 25:25 \
		-p 587:587 \
		-p 143:143 \
		-v /opt/dockermail/settings:/mail_settings \
		-v /opt/dockermail/vmail:/vmail joshwillik/dockermail
	```

8. Enjoy!
