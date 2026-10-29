# Limites SDD

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Spec Driven Development |
| **Aula** | 18 — Limites SDD (02:03) |
| **Assunto** | Encerramento do capítulo: limitações observadas no uso "puro" do SDD/OpenSpec e ponte para o conceito de harness |
| **Data** | 29/10/2026 16:15 |
| **Tags** | sdd, openspec, harness, kiro, speckit, encerramento-capitulo |

## Resumo da aula

Aula de encerramento do capítulo Spec Driven Development. O instrutor recapitula que, embora o aluno já seja capaz de desenvolver aplicações, scripts e automações usando SDD e OpenSpec, o fluxo apresentado ao longo do capítulo revelou limitações recorrentes — principalmente a ausência de regras claras e consistentes de comportamento da IA, que tiveram que ser definidas manualmente em cada prompt/especificação. Essa lacuna é o que o conceito de **harness** (tratado nos próximos capítulos) vem resolver.

## Conceitos principais

### Limitações observadas no uso "puro" do SDD/OpenSpec

- Não havia uma regra clara, predefinida, de como montar os testes — isso teve que ser passado manualmente na especificação, change a change.
- Em vários momentos foi necessário definir no próprio prompt os padrões de como a codificação e o comportamento do fluxo deveriam ocorrer (ex.: não alterar arquivos diretamente, mapear PRD de origem, etc. — vistas nas aulas anteriores).
- Causa raiz: o *environment* (ambiente de trabalho da IA) ainda não estava ajustado — não havia uma definição de como a IA deve se comportar seguindo os padrões e a metodologia do time.

### O papel do harness

É justamente para resolver essa lacuna de comportamento consistente que existe o **harness** — um conjunto de elementos inseridos no agente de codificação para construir o "ambiente" de trabalho da IA, que será o foco dos próximos capítulos do curso (loop de execução, ajustes de comportamento, etc.).

### Outras ferramentas de SDD sugeridas para explorar

O instrutor recomenda testar outros frameworks de Spec Driven Development além do OpenSpec, citando como sugestões:
- **Kiro**
- **SpecKit**
- Outras soluções (deixadas como links/sugestões no material complementar da plataforma, não detalhadas na transcrição)

## Comandos e configurações

Não há comandos ou prompts novos nesta aula — é uma aula de encerramento/recapitulação.

## Pegadinhas

- O fato do SDD/OpenSpec funcionar bem para implementar features isoladamente não significa que o fluxo está maduro/consistente — sem um harness ajustado, cada change pode exigir reforçar manualmente as mesmas regras de comportamento (testes, padrões de código, etc.).
- As limitações apontadas aqui conectam diretamente com os incidentes já vistos nas aulas anteriores do capítulo (ex.: a IA alterando arquivos fora do escopo em "SDD K8S", a necessidade de customizar `context`/`rules` em "Customização OpenSpec").

## Dúvidas para revisar

- Quais ferramentas de harness serão apresentadas nos próximos capítulos (Rules, Sub Agentes, Hooks) e como elas resolvem especificamente os problemas de teste e comportamento apontados aqui?
- Vale testar o Kiro ou o SpecKit no mesmo projeto "Encontros Tech" para comparar a experiência com o OpenSpec?
- Como as regras de harness vão se relacionar com as customizações de `context`/`rules` já feitas no `openspec/config.yaml`?
