#!/bin/bash

LIM_CPU=30.0 # limite de consumo de CPU
LIM_MEM=30.0 # limite de consumo de memória
PROC_ZUMBI=1

echo "******************* MONITOR DE PROCESSOS *******************"
printf "\n"

while true; do

	echo "Consumo de CPU: $(top -bn1 | grep "CPU" | head -n1 | sed 's/,/./g' | \
		awk '{print "Usuario: " $2"%\tSistema: "$4 "%\t Total: " $2 + $4"%"}')" 

	echo "Consumo de Memória: $(free -th | grep "Mem.:" | \
		awk '{print "Livre: " $4 "\tUsada: "$3 "\tTotal: " $2}')"

	
	ps -eo user,pid,%cpu,start,cmd --sort=-%cpu | tail -n +3 | head -n 5 >> /dev/null

	ps -eo user,pid,%mem,start,cmd --sort=-%mem | tail -n +3 | head -n 5 | while read -r  user pid cpu mem start cmd; do
		if [[ $(echo " $cpu > $LIM_CPU " | bc -l ) -eq 1 ]]; then
			echo -e "\n***Alerta de consumo da CPU: $cpu% ***" | tee -a alerta.log
			notify-send "Alerta de consumo da CPU"
			echo -e "Usuário: $user \nPid: $pid \nIniciado em: $cmd" | tee -a alerta.log
			echo -e "Horário: $start" | tee -a alerta.log 
		fi
		if [[ $(echo " $mem > $LIM_MEM " | bc -l) -eq 1 ]]; then
			echo -e "\n***Alerta de consumo da Memória: $mem% ***" | tee -a alerta.log
			notify-send "Alerta de consumo da Memória"
			echo -e "Usuário: $user \nPid: $pid \nIniciado em: $cmd" | tee -a alerta.log
			echo -e "Horário: $start" | tee -a alerta.log
		fi
	done < <(ps -eo user,pid,%cpu,%mem,start,cmd --sort=-%cpu | tail -n +3 | head -n 5) 

	zumbi=$(top -bn1 | head -n 4 | grep "Tarefas" | awk '{print $11}')
	if [[ $(echo " $zumbi > $PROC_ZUMBI " | bc -l ) -eq 1 ]]; then
		notify-send "Processo zumbi no sistema!"
		zum_pid=$(ps -aux | grep "defunct" | tail -n +1 | head -n1 | awk '{print $2}')
		ppid=$(echo " $pid - 1 " | bc -l)
		kill -SIGCHLD $ppid
		if [[ $( echo "$zumbi == 0" | bc -l) -eq 1 ]]; then
			notify-send "Processo zumbi terminado!"
		else
			notify-send "Processo zumbi não terminado!"
		fi
	fi	
	echo -e "\nAtualizando em 5 segundo... Pressiona Ctrl + C para sair\n"
	sleep 5
done
