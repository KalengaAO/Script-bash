# 🖥️ Monitor de Sistema em Bash

## 🙏 Saudações e Agradecimento
Saudações e agradecimento para todos que aqui chegaram.  
A ideia é simples: **monitorar o sistema**.

---

## 📌 Descrição
O script em **Bash** realiza:
- Monitoramento de **CPU**
- Monitoramento de **Memória**
- Detecção e tratamento de **processos zumbi**

Além disso, acompanha exemplos em **C** para:
- Criar processos zumbi  
- Simular vazamentos de memória  

> ⚠️ Nota: o exemplo de vazamento de memória em C não é absoluto, pois o limite de memória pode variar entre sistemas.

---

## ⚙️ Funcionamento Geral
- O script utiliza um **loop infinito (`while true`)** para captura contínua.  
- As variáveis `CPU` e `MEM` definem limites de alerta.  
- O `echo` usado no código pode ser removido em algumas linhas, pois serve apenas para debug.  

---

## 🔎 Captura de CPU

```bash
top -bn1 | grep "CPU" | head -n 1 \
  | sed 's/,/./g' \
  | awk '{print "Usuário: " $2"%\tSistema: "$4 "%\tTotal: " $2 + $4"%"}'

Explicação

    top -bn1 → captura uma instância única de uso de CPU.
    grep "CPU" | head -n 1 → seleciona a primeira linha de CPU.
    sed 's/,/./g' → converte vírgula para ponto (necessário em sistemas com locale pt).
    awk → soma valores de usuário + sistema, exibindo em ponto flutuante.
    Em sistemas já no formato americano (9.3), o sed pode ser removido.

📋 Listagem de Processos

ps -eo user,pid,%cpu,%mem,cmd,comm,start --sort=-%cpu
ps -eo user,pid,%cpu,%mem,cmd,comm,start --sort=-%mem

Explicação

    -e → lista todos os processos, inclusive de outros usuários.

    -o → permite escolher colunas: usuário, PID, %CPU, %MEM, comando, etc.

    --sort → organiza por uso de CPU ou memória.

    tail -n +2 → remove cabeçalhos.

    head -n 20 → limita a listagem para os 20 primeiros processos.

🧮 Monitoramento de Limites

if [[ $(echo "$MEM_USADO > $LIM_MEM" | bc -l) -eq 1 ]]; then
    notify-send "⚠️ Alerta: consumo elevado de Memória"
fi

Detalhes

    bc -l → permite cálculos de ponto flutuante.

    echo "5 + 5" | bc -l → saída será 10 (sem -l seria apenas a string).

    notify-send → exibe pop-up no desktop.

    🔔 Para instalar o notify-send, veja este guia

    .

🧟 Captura e Mitigação de Processos Zumbi
1. Detectando zumbis
top -bn1 | grep "Tarefas" | awk '{print $11}'
    Captura número de processos zumbi.

2. Identificando
ps aux | grep "defunct"
    Processos zumbi são listados com a flag defunct.

3. Recuperando PID e PPID
    Cada zumbi tem um PID e um PPID (pai).
    Para enviar sinal ao pai:

kill -s SIGCHLD <PPID>

Nota Importante
    A aritmética de capturar PPID funciona melhor quando o processo pai tem apenas um filho.
    Caso contrário, pode ser necessário mitigar manualmente.
    Enquanto o processo persistir, o script continuará emitindo notificações com notify-send.

Intervalo de Atualização
    O script atualmente atualiza a cada 5 segundos.
    Este valor pode ser ajustado conforme a necessidade do sistema.

Exemplos em C
    Criação de zumbis → usado para teste do monitor.
    Vazamento de memória → demonstração didática (não absoluto, pois depende do limite do SO).

Resumo
Este projeto fornece:
    Monitoramento em tempo real de CPU e Memória.
    Detecção automática de processos zumbi.
    Notificações gráficas no desktop.
    Exemplos práticos em C para reforço de estudo.

Autor
Projeto escrito por António Pedro Kalenga
