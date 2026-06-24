> Exercício 2 — Automação
> Descreva uma tarefa manual repetitiva do seu dia a dia e peça um script ou comando para automatizar.
> Exemplos:
> - Rotacionar logs antigos de um diretório
> - Conferir quais nodes do cluster estão com mais de 80% de CPU
> - Listar todos os buckets S3 que estão sem criptografia
> - Gerar relatório mensal de custos de um recurso específico

---

# Experimento [03] — [Automatizar limpeza de snapshots vSphere]

- **Data:** 2026-06-23
- **Ferramenta usada:** [Claude Code]
- **Modelo:** [Sonnet 4.6]
- **Categoria:** [Automação]

## Contexto

Automatizar a limpeza de snapshots das máquinas virtuais do ambiente alocadas no vSphere 8.

## Prompt usado

> Exercício 2 — Automação
> Descreva uma tarefa manual repetitiva do seu dia a dia e peça um script ou comando para automatizar.
> Exemplos:
> - Rotacionar logs antigos de um diretório
> - Conferir quais nodes do cluster estão com mais de 80% de CPU
> - Listar todos os buckets S3 que estão sem criptografia
> - Gerar relatório mensal de custos de um recurso específico

Tenho esse exercício pra fazer e pensei em fazer forma de automatizar a limpeza de snapshots do ambiente que está no vsphere 8, seguindo as regras:

- não limpar snapshots daquele dia
- deixar snapshots de até 2 dias atrás, acima disso pode remover
- permitir passar nomes de vms da qual não deve excluir snapshot

## Resposta da IA

O Sonnet retornou um script em Python com a biblioteca pyVmomi que faz a função dita, deu uma forma de simulação e depois execução real tirando vms críticas.

``` text
#!/usr/bin/env python3
"""
cleanup_snapshots.py — Limpeza automática de snapshots no vSphere 8

Regras:
  - Snapshots do dia atual nunca são removidos
  - Snapshots com até 2 dias atrás são mantidos
  - Snapshots mais antigos que 2 dias são removidos
  - VMs na lista de exclusão nunca têm snapshots removidos

Uso:
  python3 cleanup_snapshots.py \
    --host vcenter.empresa.local \
    --user administrator@vsphere.local \
    --password 'SuaSenha' \
    [--port 443] \
    [--max-age-days 2] \
    [--exclude-vms vm-banco,vm-erp,vm-critica] \
    [--dry-run]

Dependências:
  pip install pyVmomi
"""

import argparse
import sys
from datetime import datetime, timezone, timedelta
from pyVim.connect import SmartConnect, Disconnect
from pyVmomi import vim
import ssl
import atexit


# ──────────────────────────────────────────────
# Argparse
# ──────────────────────────────────────────────

def parse_args():
    parser = argparse.ArgumentParser(
        description="Remove snapshots antigos de VMs no vSphere 8."
    )
    parser.add_argument("--host",         required=True,  help="Endereço do vCenter/ESXi")
    parser.add_argument("--user",         required=True,  help="Usuário (ex: administrator@vsphere.local)")
    parser.add_argument("--password",     required=True,  help="Senha")
    parser.add_argument("--port",         default=443,    type=int, help="Porta HTTPS (padrão: 443)")
    parser.add_argument(
        "--max-age-days",
        default=2,
        type=int,
        help="Manter snapshots com até N dias atrás (padrão: 2). "
             "Snapshots mais antigos serão removidos.",
    )
    parser.add_argument(
        "--exclude-vms",
        default="",
        help="Lista de nomes de VMs separados por vírgula que NÃO devem ter snapshots removidos.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Simula a execução sem remover nada (recomendado para testar primeiro).",
    )
    return parser.parse_args()


# ──────────────────────────────────────────────
# Conexão com vCenter
# ──────────────────────────────────────────────

def connect(host, user, password, port):
    """Conecta ao vCenter ignorando verificação de certificado (ambiente interno)."""
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
    context.check_hostname = False
    context.verify_mode = ssl.CERT_NONE

    si = SmartConnect(
        host=host,
        user=user,
        pwd=password,
        port=port,
        sslContext=context,
    )
    atexit.register(Disconnect, si)
    return si


# ──────────────────────────────────────────────
# Coleta de VMs e snapshots
# ──────────────────────────────────────────────

def get_all_vms(si):
    """Retorna lista de todas as VMs encontradas no inventário."""
    content = si.RetrieveContent()
    container = content.viewManager.CreateContainerView(
        content.rootFolder, [vim.VirtualMachine], recursive=True
    )
    vms = list(container.view)
    container.Destroy()
    return vms


def flatten_snapshots(snapshot_list, vm_name):
    """
    Percorre recursivamente a árvore de snapshots e retorna
    uma lista plana de (snapshot_object, creation_time, name_path).
    """
    result = []
    for snap in snapshot_list:
        result.append((snap.snapshot, snap.createTime, snap.name))
        if snap.childSnapshotList:
            result.extend(flatten_snapshots(snap.childSnapshotList, vm_name))
    return result


# ──────────────────────────────────────────────
# Lógica de limpeza
# ──────────────────────────────────────────────

def should_remove(create_time, now, max_age_days):
    """
    Retorna True se o snapshot deve ser removido.

    Regras:
      1. Snapshots criados HOJE (mesmo dia calendário) → nunca remove.
      2. Snapshots criados há até max_age_days dias → mantém.
      3. Snapshots mais antigos → remove.
    """
    # Normaliza para UTC se necessário
    if create_time.tzinfo is None:
        create_time = create_time.replace(tzinfo=timezone.utc)

    now_utc = now.astimezone(timezone.utc)

    # Regra 1: mesmo dia → nunca remove
    if create_time.date() == now_utc.date():
        return False

    # Regra 2 e 3: compara a idade
    age = now_utc - create_time
    return age > timedelta(days=max_age_days)


def remove_snapshot(snapshot_obj, dry_run):
    """Remove o snapshot. Se dry_run=True, apenas simula."""
    if dry_run:
        return
    task = snapshot_obj.RemoveSnapshot_Task(removeChildren=False)
    # Aguarda conclusão da task
    while task.info.state in (vim.TaskInfo.State.running, vim.TaskInfo.State.queued):
        pass  # polling simples; para produção use WaitForTask do pyVmomi


def cleanup(si, exclude_vms, max_age_days, dry_run):
    now = datetime.now(timezone.utc)
    cutoff = now - timedelta(days=max_age_days)

    print(f"\n{'=' * 60}")
    print(f"  vSphere Snapshot Cleanup")
    print(f"  Executado em : {now.strftime('%Y-%m-%d %H:%M:%S UTC')}")
    print(f"  Limite       : snapshots mais antigos que {max_age_days} dias ({cutoff.strftime('%Y-%m-%d')})")
    print(f"  VMs excluídas: {', '.join(exclude_vms) if exclude_vms else '(nenhuma)'}")
    print(f"  Modo         : {'DRY-RUN (simulação)' if dry_run else 'EXECUÇÃO REAL'}")
    print(f"{'=' * 60}\n")

    vms = get_all_vms(si)
    total_removed = 0
    total_kept = 0
    total_skipped_vm = 0

    for vm in vms:
        vm_name = vm.name

        # VM na lista de exclusão
        if vm_name in exclude_vms:
            if vm.snapshot:
                snaps = flatten_snapshots(vm.snapshot.rootSnapshotList, vm_name)
                total_skipped_vm += len(snaps)
                print(f"  [SKIP] {vm_name} — {len(snaps)} snapshot(s) ignorado(s) (VM excluída)")
            continue

        # VM sem snapshots
        if not vm.snapshot:
            continue

        snaps = flatten_snapshots(vm.snapshot.rootSnapshotList, vm_name)

        for snap_obj, create_time, snap_name in snaps:
            age_str = str(now.astimezone(timezone.utc) - create_time.astimezone(timezone.utc)).split(".")[0]

            if should_remove(create_time, now, max_age_days):
                action = "DRY-RUN/REMOVERIA" if dry_run else "REMOVENDO"
                print(
                    f"  [{action}] VM={vm_name!r:30s}  "
                    f"Snapshot={snap_name!r:25s}  "
                    f"Criado={create_time.strftime('%Y-%m-%d %H:%M')}  "
                    f"Idade={age_str}"
                )
                remove_snapshot(snap_obj, dry_run)
                total_removed += 1
            else:
                print(
                    f"  [MANTER ]  VM={vm_name!r:30s}  "
                    f"Snapshot={snap_name!r:25s}  "
                    f"Criado={create_time.strftime('%Y-%m-%d %H:%M')}  "
                    f"Idade={age_str}"
                )
                total_kept += 1

    print(f"\n{'=' * 60}")
    print(f"  Resumo:")
    print(f"    Removidos  : {total_removed}")
    print(f"    Mantidos   : {total_kept}")
    print(f"    Ignorados  : {total_skipped_vm} (VMs excluídas)")
    if dry_run:
        print(f"\n  ⚠  DRY-RUN ativo — nenhum snapshot foi removido de verdade.")
        print(f"     Execute sem --dry-run para aplicar as remoções.")
    print(f"{'=' * 60}\n")


# ──────────────────────────────────────────────
# Entrypoint
# ──────────────────────────────────────────────

def main():
    args = parse_args()

    exclude_vms = set(
        v.strip() for v in args.exclude_vms.split(",") if v.strip()
    )

    print(f"Conectando a {args.host}:{args.port} como {args.user} …")
    try:
        si = connect(args.host, args.user, args.password, args.port)
    except Exception as e:
        print(f"Erro ao conectar: {e}", file=sys.stderr)
        sys.exit(1)

    cleanup(si, exclude_vms, args.max_age_days, args.dry_run)


if __name__ == "__main__":
    main()
```

## O que funcionou

- Fez o script inteiro em Python e informou o que precisa pra rodar e testar antes de rodar de fato

## O que não funcionou

- Queria reformular para que rodasse da forma mais fácil possível sem instalações de dependências e outros, talvez em container pra já morrer após execução
- Não informei detalhes de onde iria rodar o script e por isso me deu comandos que não serviram corretamente em Windows

## Ajustes que eu fiz

- Falar que seria executado de máquina Windows

## Nota (1 a 5)

**Nota:** 3/5

**Justificativa:** Devido a maior parte de detalhes de minha parte o script não foi mais certeiro. Mas testei e funcionou realmente removendo alguns snapshots.

## O que eu faria diferente

Ser mais detalhista quanto as mudanças que quero que sejam feitas e qual ambiente tenho pra rodar o que preciso.