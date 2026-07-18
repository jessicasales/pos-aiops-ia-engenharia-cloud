### QUESTÃO 1 - Dockerfile para o Lift


>O Lift vai sair das VMs onde vem rodando e entrar no cluster Kubernetes da empresa. O código já está pronto: uma API Python/Flask na porta 8080, dependências declaradas em requirements.txt, e duas variáveis de ambiente que precisam estar presentes no runtime, DATABASE_URL e API_KEY.
>
>Estrutura do projeto:
>```text
>lift/
>├── app.py
>├── requirements.txt
>├── lib/
>│   ├── auth.py
>│   └── storage.py
>└── tests/
>    └── test_app.py
>```
>
>Conteúdo de requirements.txt:
>```text
>Flask==3.0.0
>gunicorn==21.2.0
>requests==2.31.0
>python-dotenv==1.0.0
>psycopg2-binary==2.9.9
>```
>Em produção o serviço sobe com gunicorn --bind 0.0.0.0:8080 --workers 4 app:app.
>
>Falta o Dockerfile. Seguir todas as boas práticas de criação.
>
>Tarefa. Aplicando o framework R-T-F, escrever o prompt de IA que produza esse Dockerfile.
>
>Entregue. Prompt, modelo, output e justificativa mostrando como Role, Task e Format aparecem no prompt.
>
---
#### 🤖 Prompt:
```text
#Role
Você é um DevOps sênior com mais de 15 anos experiência, especializado em Docker e Kubernetes.

#Task
Escreva um Dockerfile para geração da imagem do Lift.

O Lift é um projeto de API Python/Flask que tem as informações
- Porta 8080;
- Precisa das variáveis DATABASE_URL e API_KEY no runtime;
- Tem os requirements:
Flask==3.0.0
gunicorn==21.2.0
requests==2.31.0
python-dotenv==1.0.0
psycopg2-binary==2.9.9
- O serviço sobe com gunicorn --bind 0.0.0.0:8080 --workers 4 app:app

A estrutura do projeto é:

lift/
├── app.py
├── requirements.txt
├── lib/
│   ├── auth.py
│   └── storage.py
└── tests/
    └── test_app.py

#Format
Retorne um arquivo Dockerfile pronto escrito com boas práticas 
```
---
#### 🛠️ Modelo:
Sonnet 5 Médio

---
#### 📦 Output:

Enviou o arquivo Dockerfile1 junto com o texto:

>Observações sobre as decisões de projeto
>
>- Multi-stage build: separa dependências de compilação (build-essential, libpq-dev) da imagem final, reduzindo tamanho e superfície de ataque — a imagem final só leva libpq5 (runtime da lib PostgreSQL).
>- Usuário não-root: o container roda como lift, evitando escalonamento de privilégios caso a aplicação seja comprometida.
>- .dockerignore: recomendo criar um arquivo .dockerignore para excluir tests/, .git, __pycache__, *.pyc e afins do contexto de build — isso não foi copiado no Dockerfile, já que testes normalmente não devem ir para a imagem de produção.
>- DATABASE_URL e API_KEY: declaradas como ENV vazias apenas para documentar que são esperadas — na prática você deve injetá-las via docker run -e, Kubernetes Secret/ConfigMap, ou similar, nunca hardcoded na imagem.
>- Healthcheck: assume um endpoint /health; ajuste ou remova conforme a API real do Lift.
>- --no-cache-dir: evita que o pip guarde cache de pacotes, reduzindo o tamanho da imagem.
>- Layers ordenadas por frequência de mudança: requirements.txt é copiado e instalado antes do código-fonte, para que alterações no app.py/lib/ não invalidem o cache da instalação de dependências.
>
>Sugestão de .dockerignore:
>```text
>tests/
>__pycache__/
>*.pyc
>.git
>.gitignore
>.env
>Dockerfile
>```
>Se quiser, posso complementar com um docker-compose.yml para desenvolvimento local ou com manifests Kubernetes (Deployment + Secret) para as variáveis DATABASE_URL e API_KEY.

---
#### 💡 Justificativa: 
Após eu inserir o prompt pedindo genericamente um Dockerfile e receber essa saída, vi que poderia ter adicionado no "Format" algo como:

```text
Faca um dockerfile
- multibuild
- Visando reutilização para vários ambientes de forma que altere as variáveis por envs de ambiente
- visando segurança
- clareza
- organizacao
```

Assim que fiz essa alteração, o Dockerfile gerado ficou melhor e mais profissional, gerando o arquivo Dockerfile2 e trazendo essa outra saída:
>
>Como isso resolve os requisitos
>Reutilização entre ambientes
>
>- ARG controla decisões de build (usuário, UID/GID, diretório da app).
>- ENV controla valores de runtime, sobrescrevíveis sem rebuild:
>```text
>bash  docker run -e DATABASE_URL=postgres://... -e API_KEY=xxx -e WORKERS=8 lift:prod
>```
>- WORKERS e PORT também parametrizados — útil se stage/prod tiverem tamanhos de pool diferentes.
>- Um único Dockerfile serve dev, staging e prod; o que muda é o --env-file ou os -e na hora de subir o container, não a imagem.
>
>Multi-stage / multi-build
>
>- base: usuário e configs comuns.
>- dependencies: só o necessário para compilar pacotes Python.
>- test: stage isolado que roda pytest, usado no CI (--target test), não vai para produção.
>- runtime: imagem final enxuta, sem build-essential/libpq-dev.
>
>Segurança
>
> - Usuário não-root (lift) com UID/GID fixos e fake shell (/sbin/nologin).
>- Nenhum valor sensível hardcoded — DATABASE_URL/API_KEY ficam vazias, apenas documentando o contrato.
>- Superfície mínima: dependências de compilação não existem na imagem final.
>--chown no COPY evita RUN chown -R (mais rápido e menos layers).
>
>Clareza e organização
>
>- Comentários por seção (STAGE N).
>- Separação clara de responsabilidades por stage.
>- .dockerignore sugerido abaixo para não vazar lixo para o contexto de build.
> 
>.dockerignore sugerido
>```text 
>tests/
>__pycache__/
>*.pyc
>.git
>.gitignore
>.env*
>Dockerfile
>docker-compose*.yml
>README.md
>```
>Exemplos de uso por ambiente
>
>```text
>#Build (mesma imagem para todos os ambientes)
>docker build --target runtime -t lift:latest .
>
># CI — rodar testes antes de buildar runtime
>docker build --target test -t lift:test .
>
># Dev
>docker run --env-file .env.dev -p 8080:8080 lift:latest
>
># Staging
>docker run --env-file .env.staging -p 8080:8080 lift:latest
>
># Produção (via Kubernetes Secret, por exemplo)
>kubectl create secret generic lift-secrets \
>  --from-literal=DATABASE_URL=postgres://... \
>  --from-literal=API_KEY=xxx
> ```
>Se quiser, posso gerar também os arquivos .env.dev, .env.staging, um docker-compose.yml com múltiplos profiles, ou manifests Kubernetes (Deployment + Secret + ConfigMap) já integrados a essas variáveis.
>