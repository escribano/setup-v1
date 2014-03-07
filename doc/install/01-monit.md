apt-get install monit


#### Instalação e configuração básica do Monit

Instalação do pacote:

	# aptitude update
	# aptitude install monit

Edite o arquivo de configuração `/etc/monit/monitrc` e descomente as linhas:

	# set daemon  120
	# set logfile syslog facility log_daemon
	# set idfile /var/.monit.id
	# set statefile /var/.monit.state
	# set httpd port 2812 and
	#     use address localhost  # only accept connection from localhost
	#     allow localhost        # allow localhost to connect to the server and

Edite o arquivo `/etc/default/monit` e mude a linha `startup=0` para
`startup=1`.

Remova ele da inicialização normal:

	# update-rc.d monit remove

E adicione com respawn no inittab:

	# echo "mo:2345:respawn:/usr/sbin/monit -Ic /etc/monit/monitrc" >>/etc/inittab

Recarregue o inittab:

	# telinit q

Pronto.
