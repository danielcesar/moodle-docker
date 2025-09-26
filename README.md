# Moodle 4.5.6 com Docker

Esta configuração Docker instala o Moodle 4.5.6 com MySQL 8 e Nginx para execução em localhost.

## Estrutura do Projeto

```
moodle-docker/
├── docker-compose.yml
├── Dockerfile.php
├── nginx/
│   ├── nginx.conf
│   └── default.conf
├── php/
│   ├── php.ini
│   └── opcache.ini
├── mysql/
│   └── my.cnf
├── scripts/
│   └── init.sh
└── README.md
```

## Pré-requisitos

- Docker
- Docker Compose
- Pelo menos 4GB de RAM disponível
- Porta 80 livre no sistema

## Instalação

### 1. Crie a estrutura de diretórios

```bash
mkdir -p moodle-docker/{nginx,php,mysql,scripts}
cd moodle-docker
```

### 2. Crie todos os arquivos de configuração

Copie o conteúdo de cada arquivo fornecido para os respectivos diretórios conforme a estrutura mostrada acima.

### 3. Torne o script de inicialização executável

```bash
chmod +x scripts/init.sh
```

### 4. Execute o Docker Compose

```bash
docker-compose up -d
```

### 5. Aguarde a inicialização

A primeira execução pode demorar alguns minutos para:
- Baixar as imagens Docker
- Baixar o Moodle 4.5.6
- Compilar o container PHP
- Configurar o banco de dados

Acompanhe os logs com:
```bash
docker-compose logs -f
```

## Acesso ao Moodle

1. Abra o navegador e acesse: `http://localhost`

2. Na primeira execução, você será direcionado para o instalador do Moodle

3. Siga as instruções de instalação:
   - O banco de dados já estará configurado automaticamente
   - Crie a conta de administrador quando solicitado

## Configurações Padrão

### Banco de Dados
- **Host**: mysql
- **Database**: moodle
- **Usuário**: moodleuser
- **Senha**: moodlepass
- **Usuário Root**: root / rootpassword

### Diretórios
- **Moodle**: `/var/www/html`
- **Dados**: `/var/moodledata`

### Portas
- **Nginx**: 80
- **MySQL**: 3306

## Comandos Úteis

### Parar os serviços
```bash
docker-compose down
```

### Reiniciar os serviços
```bash
docker-compose restart
```

### Ver logs de um serviço específico
```bash
docker-compose logs nginx
docker-compose logs php-fpm
docker-compose logs mysql
```

### Acessar o container PHP para comandos CLI
```bash
docker exec -it moodle_php bash
```

### Backup do banco de dados
```bash
docker exec moodle_mysql mysqldump -u root -prootpassword moodle > backup_moodle.sql
```

### Restaurar banco de dados
```bash
docker exec -i moodle_mysql mysql -u root -prootpassword moodle < backup_moodle.sql
```

## Customizações

### Alterar configurações do PHP
Edite o arquivo `php/php.ini` e reinicie o container:
```bash
docker-compose restart php-fpm
```

### Alterar configurações do Nginx
Edite os arquivos em `nginx/` e reinicie o container:
```bash
docker-compose restart nginx
```

### Alterar configurações do MySQL
Edite o arquivo `mysql/my.cnf` e reinicie o container:
```bash
docker-compose restart mysql
```

## Performance

Esta configuração inclui otimizações para performance:

- **OPcache** habilitado para PHP
- **Gzip** habilitado no Nginx
- **Cache de query** habilitado no MySQL
- **InnoDB** otimizado para Moodle

## Problemas Comuns

### Porta 80 ocupada
Se a porta 80 estiver ocupada, altere no `docker-compose.yml`:
```yaml
nginx:
  ports:
    - "8080:80"  # Usar porta 8080 ao invés de 80
```

### Permissões de arquivo
Se houver problemas de permissão:
```bash
docker exec moodle_php chown -R www-data:www-data /var/www/html
docker exec moodle_php chown -R www-data:www-data /var/moodledata
```

### Logs de erro
Para ver logs detalhados:
```bash
docker exec moodle_php tail -f /var/log/php_errors.log
docker-compose logs nginx
```

## Segurança

**IMPORTANTE**: Esta configuração é apenas para desenvolvimento local. Para produção, considere:

- Alterar todas as senhas padrão
- Configurar SSL/HTTPS
- Implementar firewall adequado
- Fazer backup regular dos dados
- Monitorar logs de segurança

## Suporte

Para mais informações sobre o Moodle, consulte:
- [Documentação oficial do Moodle](https://docs.moodle.org/)
- [Fórum da comunidade Moodle](https://moodle.org/community/)