#!/bin/bash

# Script de inicialização para o container PHP-FPM com Moodle

echo "Iniciando configuração do Moodle..."

# Aguardar o MySQL estar disponível
echo "Aguardando MySQL estar disponível..."
while ! mysqladmin ping -h"mysql" -u"root" -p"rootpassword" --silent; do
    echo "MySQL não está pronto ainda. Aguardando..."
    sleep 2
done

echo "MySQL está pronto!"

# Verificar se o Moodle já está configurado
if [ ! -f /var/www/html/config.php ]; then
    echo "Criando configuração inicial do Moodle..."
    
    # Criar arquivo de configuração do Moodle
    cat > /var/www/html/config.php << EOF
<?php  // Moodle configuration file

unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();

\$CFG->dbtype    = 'mysqli';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = 'mysql';
\$CFG->dbname    = 'moodle';
\$CFG->dbuser    = 'moodleuser';
\$CFG->dbpass    = 'moodlepass';
\$CFG->prefix    = 'mdl_';
\$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => 3306,
  'dbsocket' => '',
  'dbcollation' => 'utf8mb4_unicode_ci',
);

\$CFG->wwwroot   = 'http://localhost';
\$CFG->dataroot  = '/var/moodledata';
\$CFG->admin     = 'admin';

\$CFG->directorypermissions = 0777;

// Performance settings
\$CFG->cachejs = true;
\$CFG->cachecss = true;
\$CFG->langstringcache = true;
\$CFG->themedesignermode = false;

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
EOF

    # Definir permissões corretas
    chown www-data:www-data /var/www/html/config.php
    chmod 644 /var/www/html/config.php
    
    echo "Arquivo de configuração criado com sucesso!"
fi

# Garantir que as permissões estão corretas
echo "Ajustando permissões..."
chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /var/moodledata
chmod -R 755 /var/www/html
chmod -R 755 /var/moodledata

# Iniciar cron em background
echo "Iniciando cron..."
service cron start

# Iniciar PHP-FPM
echo "Iniciando PHP-FPM..."
php-fpm
