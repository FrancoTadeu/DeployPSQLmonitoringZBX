#!/bin/bash

#  Este script configura o monitoramento do PostgreSQL via User Parameters com o Zabbix Agent
#  -- Na execução é assumido que o Zabbix Agent está instalado, o usuário para o monitoramento do Postgre foi criado 
#  e a configuração para login remoto no arquivo pg_hba.conf foi feita

# INICIO
# Declara vars
home_zbx="/var/lib/zabbix"
mnt_zbx_path="/monitoracao/zabbix/etc"

# Cria o diretorio home do Zabbix Agent
mkdir $home_zbx  && chown zabbix:zabbix $home_zbx
chmod 755 $home_zbx

# Cria outro diretorio no home para Organizacao
mkdir $home_zbx/postgresql

cp /root/zabbix_templates/psql_script/* $home_zbx/postgresql/

chown zabbix:zabbix $home_zbx/postgresql/*.sql
chmod 766 $home_zbx/postgresql/*.sql

# Copia o arquivo de conf do template para o /etc/zabbix

cp /root/zabbix_templates/template_db_postgresql.conf $mnt_zbx_path/zabbix_agentd.conf.d
chmod 766 $mnt_zbx_path/zabbix_agentd.conf.d/template_db_postgresql.conf

# Backup do Arquivo de Conf do Zabbix Agent
cp $mnt_zbx_path/zabbix_agentd.conf /root/zabbix_agent.conf.bak

# Adiciona o parametro que permite caracteres especiais nos items de User Parameters
echo 'UnsafeUserParameters=1' >> $mnt_zbx_path/zabbix_agentd.conf

if grep -i 'unsafeuserparameters=1' $mnt_zbx_path/zabbix_agentd.conf > /dev/null 

		then 
	sleep 5
	echo -e "
    ########################################################

    String encontrada no arquivo de configuração, inciando restart do serviço do Zabbix Agent\n
    para finalizar o processo...
    
	#######################################################
    "
# Reinicia o Serviço do Agent
systemctl restart zabbix-agent.service

		else
	echo -e '

#############################################################

\033[05;31mERRO FATAL DURANTE A EXECUCAO\033[00;37m : A String não foi encontrada, abortando o reinicio do Zabbix Agent, por favor verifique o arquivo de configuração\n
Por favor retorne o backup anterior ...

#############################################################

'
fi
