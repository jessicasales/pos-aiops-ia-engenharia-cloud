# Dicas para Skills — 13 regras para escrever um SKILL.md

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Skills |
| **Aula** | 11 — Dicas para Skills (21:30) |
| **Assunto** | Checklist de qualidade para revisar skills (inclusive as geradas pela skill-creator) |
| **Data** | 29/10/2026 19:02 |
| **Tags** | `boas práticas` `SKILL.md` `progressive disclosure` `janela de contexto` `references` `scripts` `MCP` `checklist` |

## Resumo da aula

Mesmo usando a skill-creator, **você precisa revisar** as skills. A aula traz 13 dicas em pares *errado × certo*, em cinco blocos, para usar como **checklist de revisão**: se algo não for atendido, peça para a IA corrigir.

## As 13 dicas

### Economia do corpo
1. **Não explique o que o modelo já sabe.** Nada de ensinar o que é log ou nível INFO/WARN/ERROR; entregue o critério que ele não tem.
   ```markdown
   ## Analisar logs de pod
   kubectl logs <pod> --since=1h --previous
   Procure primeiro pelo último ERROR antes do restart. Se o pod reiniciou, o --previous é onde está a causa; o log atual só mostra o efeito.
   ```
   Como saber o que o modelo já sabe? **Testando.**
2. **Corpo curto, o resto em arquivo.** `SKILL.md` identifica o sintoma e aponta a referência:
   ```markdown
   Identifique o sintoma e leia só o procedimento dele:
   - Pod não sobe → references/pod-nao-sobe.md
   - Serviço retorna 503 → references/servico-503.md
   - PVC fica Pending → references/pvc-pending.md
   ```
3. **Um padrão com saída de emergência, não cinco opções.** "Aplique com `kubectl apply -f`. Quando o serviço precisa de rollback versionado, use `helm upgrade`." — "escolha o que fizer mais sentido" faz o agente escolher diferente a cada execução. Exceção nomeada **por critério**, não por preferência.

### Durabilidade
4. **Nada sensível ao tempo.** Método atual no topo; legado guardado num `<details>` embaixo (ex.: PDB `policy/v1`; `policy/v1beta1` removido no 1.25). Alternativa: mandar consultar a doc atual via MCP (Context7).
5. **Terminologia consistente.** Um termo por conceito — "esteira", "workflow", "pipelines", "automação" viram quatro coisas para o agente. Repetir o termo é **precisão**.

### Navegação
6. **Referência a um nível de profundidade.** Nada de `SKILL.md → runbooks.md → banco-de-dados.md`. Índice plano no `SKILL.md`:
   ```markdown
   - Failover de banco → runbooks/failover-banco.md
   - Fila travada → runbooks/fila-travada.md
   - Certificado vencido → runbooks/certificado-vencido.md
   ```
   Arquivo apontado por arquivo tende a ser lido só em prévia.
7. **Sumário em arquivo de referência longo** (acima de ~100 linhas). Muitos modelos leem só o começo do arquivo; sem sumário, concluem que o arquivo não cobre o caso.
8. **Nome de arquivo descritivo.** `retencao-de-logs.md`, não `doc1.md`. O agente decide o que abrir pelo nome.

### As triviais e mortais
9. **Barra normal, sempre:** `scripts/checar_certificado.py` (barra invertida quebra em Linux/Mac; o Windows entende a normal).
10. **Não presuma que a ferramenta está instalada.** "Confira com `yq --version`. Se faltar: `brew install yq`." Sem isso o agente improvisa — e "erro você vê, improviso passa".
11. **Nome de tool MCP qualificado:** `Grafana:query_metrics`, não `query_metrics` (vários servidores podem ter tools com o mesmo nome → "tool not found" ou tool errada).

### Quando a skill tem script
12. **Resolva, não delegue.** Script trata exceções e devolve **veredito**, não stack trace:
    ```python
    def checar_saude(url):
        try:
            return requests.get(url, timeout=5).json()["status"]
        except requests.ConnectionError:
            return "INDISPONIVEL: nada atendendo na porta"
        except requests.Timeout:
            return "LENTO: sem resposta em 5s"
    ```
    Economiza contexto e evita que o modelo invente causa ou reescreva o script.
13. **Sem constantes vodu.** Todo número tem dono e justificativa:
    ```python
    # Rollout de deployment leva ~40s em staging; 90s cobre o pior caso
    ROLLOUT_TIMEOUT = 90
    # Duas tentativas cobrem o erro transitório de DNS do cluster;
    # na terceira o problema é real e vale falhar rápido
    MAX_RETRIES = 3
    ```
    O comentário é o **critério de ajuste** para o agente.

## O que fica
- O corpo entra na janela a cada disparo — não explique o que o modelo já sabe.
- Referência de peso vai para arquivo; corpo enxuto, linkado direto, um nível só.
- Um padrão com exceção nomeada bate cinco alternativas.
- Data no texto apodrece: método atual em cima, legado guardado embaixo.
- Um termo por conceito.
- Nome de arquivo é a única pista antes de abrir.
- Script devolve veredito, não traceback; todo número tem dono.

## Dúvidas para revisar
- Passar esse checklist em todas as skills que eu criar antes de distribuir.
