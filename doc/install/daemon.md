Copie o arquivo `/opt/spcalling/bin/spcallingd.template` para `/opt/spcalling/bin/spcallingd`
e mude sua flag executável:

	# cd /opt/spcalling/bin
	# cp spcallingd.template spcallingd
	# chmod +x spcallingd

Se não for o ambiente de produção, edite o arquivo `spcallingd` e altere a
definição da variável `NODE_ENV` para o ambiente correto.


#### Configurar logrotate

Copie o script do repositório em `docs/install/resources/spcalling.logrotate.conf`
para a pasta `/etc/logrotate.d`:

    # cp /opt/spcalling/docs/install/resources/spcalling.logrotate.conf /etc/logrotate.d


#### Configurar para iniciar se não estiver rodando

Copie o script do repositório em `docs/install/resources/spcalling.monit.conf`
para a pasta `/etc/monit/conf.d` e reinicie o monit:

    # cp /opt/spcalling/docs/install/resources/spcalling.monit.conf /etc/monit/conf.d
    # kill `pidof monit`
		
#

	# cd /opt/spcalling/bin
	# cp spcallingd.template spcallingd
	# chmod +x spcallingd

#### Configurar logrotate

Copie o script do repositório em `docs/install/resources/spcalling.logrotate.conf`
para a pasta `/etc/logrotate.d`:

    # cp /opt/spcalling/docs/install/resources/spcalling.logrotate.conf /etc/logrotate.d


#### Configurar para iniciar se não estiver rodando

Copie o script do repositório em `docs/install/resources/spcalling.monit.conf`
para a pasta `/etc/monit/conf.d` e reinicie o monit:

    # cp /opt/spcalling/docs/install/resources/spcalling.monit.conf /etc/monit/conf.d
    # kill `pidof monit`