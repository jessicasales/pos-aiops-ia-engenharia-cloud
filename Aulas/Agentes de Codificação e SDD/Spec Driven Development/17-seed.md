# Seed

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Spec Driven Development |
| **Aula** | 17 — Seed (13:55) |
| **Assunto** | Implementação do PRD002 (script de seed) com o ciclo opsx, incluindo correção de rota de população de dados (direto no banco vs. via endpoint) |
| **Data** | 29/10/2026 16:05 |
| **Tags** | opsx, openspec, seed, prd, python, docker, testes-manuais |

## Resumo da aula

Última implementação de feature do projeto: o script de seed (PRD002), que popula o sistema com eventos iniciais. Segue o mesmo fluxo já estabelecido (`explore → propose → apply → archive`), com o instrutor usando o Opus para a fase de especificação (por ser o melhor modelo disponível, apesar de já existir o modelo "Fable" disponível também, descartado por ser caro demais para esse cenário) e o Sonnet para a implementação. A aula destaca um ponto de atenção real: o agente implementou o seed inserindo os dados diretamente no banco, quando o PRD (relido durante a aula) determinava inserção via endpoint da aplicação — e o próprio PRD documentava essa decisão como "fora do escopo" (população via HTTP descartada explicitamente), levando o instrutor a aceitar a implementação como está.

## Conceitos principais

### Explore — resolvendo contradições de dados no PRD

Ao rodar `/opsx:explore` apontando para o PRD002, o agente (respondendo inicialmente em inglês, corrigido para português) identificou uma contradição entre dois pontos do PRD: o conteúdo de eventos é derivado de uma API HTTP cujas datas registradas são todas de 2024, mas o seed precisa gerar datas no futuro em relação à data real de execução. Isso significa que a data é o único campo que precisa ser "inventado" pelo script. Decisões tomadas:
- Usar datas até 7 dias à frente da data atual.
- O horário específico do dia não importa, já que é apenas um seed de teste.

### Propose — mesma estrutura já conhecida

`/opsx:propose` cria a change "seed eventos iniciais", com os 4 artefatos (proposal, spec, design, tasks) seguindo o mesmo padrão das changes anteriores — já citando o PRD de origem (efeito das customizações da aula "Customização OpenSpec"). O instrutor reforça: a especificação gerada na sua máquina pode variar em relação à demo (dependendo da ferramenta/modelo usado), mas deve seguir fielmente os critérios definidos no PRD.

O instrutor notou que o `tasks.md` gerado tinha um gate de revisão mas não incluía um teste real — pediu, via dictation, para adicionar uma tarefa de validação executando a aplicação em containers Docker e garantindo que o seed funciona.

### Apply — execução e descoberta do problema de escopo

Com o Sonnet, `/opsx:apply` executa as tarefas e cria o script de seed (localizado em `src/seed`). Ao revisar o plano de teste manual gerado a pedido do instrutor ("Crie um plano de testes manual para que eu execute"), ele percebeu que o script estava inserindo os dados **diretamente no banco de dados**, e não via endpoint HTTP da aplicação, como ele believed ser o esperado.

Ao tentar corrigir ("o seed deve fazer a inserção via endpoint da aplicação"), o agente sinalizou que o próprio PRD já tratava essa decisão explicitamente: a seção "fora do escopo" do documento **descartava explicitamente a população via HTTP**, optando por inserção direta no banco como trade-off aceito. Como o instrutor não lembrava desse detalhe (documento feito há tempo), ele revisou e confirmou: a decisão registrada estava correta, então manteve a implementação como estava — ilustrando a importância de revisar o PRD/specs antes de pedir alterações, pois a decisão já pode estar documentada e ser intencional.

### Testes manuais

1. Build e subida via `docker compose up -d --build`.
2. Identificação do container (`docker container ls`).
3. Acesso ao container (`docker exec -it <container> /bin/bash`).
4. Execução do script (`python seed`), populando o banco.
5. Verificação visual na aplicação, confirmando que os eventos foram criados.

### Archive final

`/opsx:archive` com instrução explícita para fazer o sync antes ("Faça o sync"), encerrando o ciclo da última change de implementação da sequência. O instrutor menciona que o projeto completo será disponibilizado como referência na plataforma, mas recomenda fortemente que o aluno construa o seu próprio projeto do zero, usando esse apenas como referência.

## Comandos e configurações

```
/opsx:explore @<PRD002>
"Use datas até sete dias à frente. O horário pode ser qualquer um."

/opsx:propose
"Adicione nas tasks o processo de validação da feature, executando essa
aplicação em containers docker e garantindo que o seed está sendo utilizado."

/opsx:apply   # modelo: Sonnet

"Crie um plano de testes manual para que eu execute."

"O seed deve fazer a inserção via endpoint da aplicação."
# → agente aponta que o PRD já descarta explicitamente a população via HTTP
#   como fora de escopo; instrutor aceita manter como está

/opsx:archive
"Faça o sync."
```

```
# testes manuais
docker compose up -d --build
docker container ls
docker exec -it <container> /bin/bash
python seed
```

## Pegadinhas

- Decisões antigas registradas em PRDs/specs podem já ter descartado explicitamente uma abordagem que parece "óbvia" meses depois — sempre vale revisar o documento antes de pedir uma mudança de comportamento ao agente, para não reverter uma decisão consciente sem querer.
- O agente pode implementar algo tecnicamente correto em relação ao PRD, mas que diverge da expectativa mental do desenvolvedor — é só revisando o plano de teste/implementação que esse tipo de desalinhamento aparece.
- Resultados de especificação variam conforme a ferramenta e o modelo utilizados — o importante é a fidelidade aos critérios do PRD, não a formatação exata.
- Usar o modelo mais caro disponível (ex. "Fable") nem sempre se justifica para tarefas simples como um script de seed — vale avaliar custo/benefício por tarefa.

## Dúvidas para revisar

- Vale atualizar o PRD002 para deixar mais explícita e visível a decisão de inserção direta no banco (hoje "escondida" numa seção de fora de escopo), evitando confusão futura?
- Como esse script de seed se comportaria em um ambiente com múltiplas réplicas da aplicação rodando simultaneamente?
- Faz sentido criar, no futuro, um endpoint de seed/admin específico para popular dados de teste via API, mesmo que a decisão atual seja population direta no banco?
