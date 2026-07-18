### QUESTÃO 2 - Script de backup do Ledger

>Lorraine chegou à conclusão de que o Ledger, o PostgreSQL que o George levantou na EC2 anos atrás, nunca teve rotina de backup automatizada. Hoje isso é uma dependência aberta no radar da SRE, e ela quer fechar com uma cron diária. O ambiente onde o script vai rodar:
>
>- Host: ledger-db.internal.hvt.io
>- Porta: 5432
>- Banco: ledger_prod
>- Usuário de backup: backup_user
>- Senha: variável de ambiente PGPASSWORD, populada pelo AWS Secrets Manager via IAM role da instância
>- Região AWS: us-east-1
>- SO da instância: Ubuntu 22.04 LTS
>- Diretório de trabalho com 80 GB livres: /var/backups/ledger
>- Tamanho médio atual do dump compactado: ~12 GB
>
>O script precisa fazer o dump com pg_dump, compactar com gzip, subir o arquivo pro bucket S3 hvt-ledger-backups via aws s3 cp, manter 30 dias de retenção no S3 (removendo os mais antigos), registrar cada execução em /var/log/ledger-backup.log com timestamp, e sair com exit code adequado em caso de falha.
>
>Tarefa. Aplicando o framework R-T-F, escrever o prompt de IA que produza esse script bash.
>
>Entregue. Prompt, modelo, output e justificativa mostrando como Role, Task e Format aparecem no prompt.

---
#### 🤖 Prompt:
```text
#Role
Você é um Engenheiro SRE Sênior especializado em cloud AWS e infra.

#Task
Desenvolva um script bash que irá rodar em um host EC2 através de uma CRON diária
- Host: ledger-db.internal.hvt.io
- Porta: 5432
- Banco: ledger_prod
- Usuário de backup: backup_user
- Senha: variável de ambiente PGPASSWORD, populada pelo AWS Secrets Manager via IAM role da instância
- Região AWS: us-east-1
- SO da instância: Ubuntu 22.04 LTS
- Diretório de trabalho com 80 GB livres: /var/backups/ledger
- Tamanho médio atual do dump compactado: ~12 GB

#Format
Entregue um arquivo script bash pronto para execução. O script deve seguir o passo a passo:
- Execute o dump com pg_dump
- Compactar com gzip
- Subir o arquivo pro bucket S3 hvt-ledger-backups via aws s3 cp
- Manter 30 dias de retenção no S3 (removendo os mais antigos)
- registrar cada execução em /var/log/ledger-backup.
- log com timestamp
- sair com exit code adequado em caso de falha.
```
---
#### 🛠️ Modelo:
Gemini - Flash 3.5

---
#### 📦 Output:

Enviou o arquivo script.sh com a saída:

>🛠️ Guia de Implementação no Host
>
>Para colocar esse script em produção no Ubuntu 22.04 LTS da AWS, siga os passos abaixo:
>
>1. Preparação do Ambiente e Permissões
>Certifique-se de que o diretório de backup e o arquivo de logs possuem as permissões corretas para o usuário que executará a CRON (geralmente root ou um usuário dedicado de aplicação):
>
>```text
>sudo mkdir -p /var/backups/ledger
>sudo touch /var/log/ledger-backup.log
>sudo chmod 640 /var/log/ledger-backup.log
>```
>Se o script for rodar com um usuário que não seja o root, garanta que ele seja o dono (chown) das pastas acima.
>
>2. IAM Role (Importante)
>Como SRE, reforço o princípio do privilégio mínimo. A instância EC2 deve possuir uma IAM Role anexada com uma policy similar a esta:
>
>```text
>{
>    "Version": "2012-10-17",
>    "Statement": [
>        {
>            "Sid": "SecretsManagerAccess",
>            "Effect": "Allow",
>            "Action": "secretsmanager:GetSecretValue",
>            "Resource": "arn:aws:secretsmanager:us-east-1:123456789012:secret:ledger/prod/backup_user-*"
>        },
>        {
>            "Sid": "S3BucketAccess",
>            "Effect": "Allow",
>            "Action": [
>                "s3:PutObject",
>                "s3:ListBucket",
>                "s3:DeleteObject"
>            ],
>            "Resource": [
>                "arn:aws:s3:::hvt-ledger-backups",
>                "arn:aws:s3:::hvt-ledger-backups/*"
>            ]
>        }
>    ]
>}
>```
>💡 Nota de Arquitetura SRE: Embora o script gerencie a expiração via CLI (limpando backups com mais de 30 dias), a prática ideal em produção AWS é configurar uma S3 Lifecycle Policy diretamente no bucket para fazer a transição para Glacier/deleção automática de objetos com mais de 30 dias. Isso reduz custos de API e garante a retenção mesmo se o script falhar.
>
>3. Configuração da CRON Diária
>Salve o script em /usr/local/bin/ledger-backup.sh e dê permissão de execução:
>
>```text
>sudo chmod +x /usr/local/bin/ledger-backup.sh
>```
>Adicione na CRON do sistema (sudo crontab -e) para rodar todas as madrugadas (ex: 02:00 AM):
>
>```text
>0 2 * * * /usr/local/bin/ledger-backup.sh > /dev/null 2>&1
>```
>(Os erros e saídas padrão já estão sendo jogados internamente para o /var/log/ledger-backup.log de forma estruturada, por isso o redirecionamento final para /dev/null na cron).
>
---
#### 💡 Justificativa: 
Pensei em inserir a role como SRE que é a posição ocupada por Luana, com especialização em Cloud AWS pra ser mais criterioso e assertivo quanto as especificações informadas. Na task pus sobre a especificação informada e no format pus o passo a passo de como fazer o script, pra forçar a desenvolver o raciocínio passo a passo informado, tendo mais clareza sobre o que fazer e a ordem dos fatos.