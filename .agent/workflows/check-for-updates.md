---
description: Verifica se existem atualizações no GitHub e pergunta ao usuário se deseja baixar (git pull) antes de prosseguir.
---

1. Execute `git fetch origin` para buscar as últimas atualizações do repositório remoto.
2. Execute `git status -uno` para verificar se a branch local está atrás da remota.
3. Analise a saída do comando anterior.
    - Se a saída contiver "Your branch is behind" ou "Sua branch está atrás", prossiga para o passo 4.
    - Caso contrário, a verificação está concluída e você pode informar ao usuário que o projeto está atualizado ou simplesmente prosseguir com a tarefa original.
4. Pergunte ao usuário: "Existe uma nova versão disponível no GitHub. Deseja atualizar o projeto agora (git pull)?"
5. Se o usuário responder "Sim" ou "Yes":
    - Execute `git pull`
    - Informe o resultado da atualização.
6. Se o usuário responder "Não", prossiga com a tarefa original sem atualizar.
