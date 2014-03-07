

	# tail -f var/error.log
	
	
	# cp -Rv /mnt/backup/restore /mnt/calling/data
		
		
	### Restauração de backup

	Estas instruções são para o caso de ser feita uma restauração de backup.

	Restaure o banco de dados de acordo com o documento `docs/mongo_bkp_restore.md`.

	Faça uma cópia dos arquivos para o lugar definitivo:

		# cp -Rv /mnt/backup/restore /mnt/calling/data


	## Configurar backup

	Copie o arquivo `/opt/spcalling/bin/backup.template.sh` para
	`/opt/spcalling/bin/backup.sh` e mude sua flag executável:

		# cd /opt/spcalling/bin
		# cp backup.template.sh backup.sh
		# chmod +x backup.sh

	Edite o arquivo `backup.sh` e modifique as variáveis `data_folder`,
	`mongodb_db`, `bkp_root` e `bkp_retention` de acordo com seu ambiente. 

	Configure o backup para rodar diariamente, edite o crontab usando o comando:

		# crontab -e

	e adicione a linha abaixo para executá-lo à meia noite:

		@daily sudo -i /opt/spcalling/bin/backup.sh


	## Ativação do script de limpeza dos posts temporários

	O procedimento abaixo é responsavél por ativar o script de limpeza de posts
	temporários criados durante o upload de imagens/videos no dashboard.

	Basicamente, o único requisito é a definição da chave: all.tmpPostsDays, com um valor
	inteiro, por exemplo: 2, representando o número de dias a ser deduzido da data atual,
	gerando assim a data de filtro para remoção dos registro do banco. Se não definido, o
	valor 1 (dia) será usado por default.

	Deverá ser inserida uma entrada no crontab para execução do script clear-temp-posts-job.
	Exemplo:

	    @hourly sudo -i /opt/spcalling/bin/clear-temp-posts-job -e ENV 2>&1 >> /opt/spcalling/var/clear-temp-posts.log

	    onde ENV é o ambiente de execução da aplicação, se omitido, o padrão será: development

	Dessa forma, o script será executado todos os dias, e suas mensagens serão
	gravadas no arquivo de log `/opt/spcalling/var/clear-temp-posts.log`.