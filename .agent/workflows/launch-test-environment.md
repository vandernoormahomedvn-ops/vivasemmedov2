---
description: Lança as aplicações Utilizador e Motoboy simultaneamente no Simulador iOS para testes Real-time
---

# Lançamento Multi-App (Testes)

Quando testamos integrações com o Firebase (ex: Pedido do Cliente -> Aceitação do Motoboy), precisamos de ambas as aplicações a rodar ativamente no simulador. Para isso, precisamos de gerir dois processos de Flutter em paralelo.

> [!WARNING]
> Certifique-se de que tem um **Simulador iOS** ou **Emulador Android** aberto.

### Passo 1: Abrir a App do Utilizador
Abra um terminal (ou nova aba `Cmd+T`), cole e corra este comando:
```bash
cd flexpress_app && flutter run
```

### Passo 2: Abrir a App do Motoboy
Abra **outro** terminal (ou aba), cole e corra este comando:
```bash
cd flexpress_rider && flutter run
```

> [!TIP]
> Ao usar dois terminais separados, você mantém o poder de pressionar `r` (Hot Reload) em qualquer uma das apps individualmente, sem interferir na outra!
