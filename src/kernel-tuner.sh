#!/usr/bin/env bash

#------------------------ Variable -----------------------------#

#------------------------ Function -----------------------------#

cin() {
	if [ "$1" == "action" ] ; then output="\e[01;32m[>]\e[00m" ; fi
	if [ "$1" == "info" ] ; then output="\e[01;33m[i]\e[00m" ; fi
	if [ "$1" == "warning" ] ; then output="\e[01;31m[w]\e[00m" ; fi
	if [ "$1" == "error" ] ; then output="\e[01;31m[e]\e[00m" ; fi
	output="$output $2"
	echo -en "$output"
}
 
cout() {
	if [ "$1" == "action" ] ; then output="\e[01;32m[>]\e[00m" ; fi
	if [ "$1" == "info" ] ; then output="\e[01;33m[i]\e[00m" ; fi
	if [ "$1" == "warning" ] ; then output="\e[01;31m[w]\e[00m" ; fi
	if [ "$1" == "error" ] ; then output="\e[01;31m[e]\e[00m" ; fi
	output="$output $2"
	echo -e "$output"
}

function checkRoot()
{
	if [[ $(whoami) != "root" ]]; then
		cout error "You don't have root privilege!"
		cout action "Quiting..."
		sleep 2
		exit 1
	fi
}

function interrupt()
{
	echo -e "\n"
	cout error "CAUGHT INTERRUPT SIGNAL!!!"
	askToQuit=true
	while [[ $askToQuit == "true" ]]; do
		cin info "Do you really want to exit? (Y/n) "
		read answer
		if [[ $answer == *[Yy]* ]] || [[ $answer == "" ]]; then
			cout action "Quiting..."
			if [[ -f "/etc/sysctl.conf.original" ]]; then
				cout action "Restore original sysctl.conf"
				mv /etc/sysctl.conf.original /etc/sysctl.conf
				sleep 1
				cout info "Done..."
			fi
			exit 0
		elif [[ $answer == *[Nn]* ]]; then
			cout action "Rock on..."
			askToQuit=false
		fi
	done
}

function setTerminal()
{
	cout action "Setup your default terminal..."
	sleep 1
	which terminator > /dev/null
	if [[ $(echo $?) -eq 0 ]]; then
		terminal=terminator
		cout info "Setup terminator as your terminal..."
	else
		cout error "Terminator not found! Finding another one..."
		sleep 1
		which gnome-terminal > /dev/null
		if [[ $(echo $?) -eq 0 ]]; then
			terminal=gnome-terminal
			cout info "Setup gnome-terminal as your terminal..."
		else
			cout error "gnome-terminal not found! Finding another one..."
			sleep 1
			which konsole > /dev/null
			if [[ $(echo $?) -eq 0 ]]; then
				terminal=konsole
				cout info "Setup konsole as your terminal..."
			else
				cout error "konsole not found! Finding another one..."
				which xterm > /dev/null
				if [[ $(echo $?)  -eq 0 ]]; then
					terminal=xterm
					cout info "Setup xterm as your terminal..."
				else
					cout error "xterm not found!"
					if [[ $terminal == "" ]]; then
						cout error "Looks like you don't have any terminal installed on your system. Make sure you have one of them, them execute this script again."
						cout action "Quiting..."
						sleep 2
						exit 1
					fi
				fi
			fi
		fi
	fi
}

function openTerminal()
{
	terminalCMD=$($terminal -e "$cmd")
}

function testTerminal()
{
	cout action "Testing your terminal..."
	sleep 1
	cmd="whoami; sleep 3"
	openTerminal > /dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		cout info "Looks good..."
		sleep 1
	else
		cout error "Looks not good... It's OK tho, but you may experience some problems on installation..."
	fi
}

function findSysCtl()
{
	cout action "Finding your sysctl.conf..."
	sleep 1
	if [[ -f "/etc/sysctl.conf" ]]; then
		cout info "Found sysctl in /etc directory!"
	else
		cout warning "sysctl.conf not found!"
	fi
}

function checkValue()
{
	cout action "Checking your kernel parameter..."
	sleep 1
	if [[ $(sysctl -n kernel.sem | awk {'print $1, $2, $3, $4'}) == "250 32000 100 128" ]]; then
		cout info "kernel.sem already optimized!"
	else
		cout warning "kernel.sem is not optimized!"
	fi
	sleep 1

	if [[ $(sysctl -n kernel.shmall) == "2097152" ]]; then
		cout info "kernel.shmall already optimized!"
	else
		cout warning "kernel.shmall is not optimized!"
	fi
	sleep 1

	if [[ $(sysctl -n kernel.shmmni) == "4096" ]]; then
		cout info "kernel.shmmni already optimized!"
	else
		cout warning "kernel.shmmni is not optimized!"
	fi
	sleep 1

	if [[ $(sysctl -n vm.swappiness) == "10" ]]; then
		cout info "vm.swappiness already optimized!"
	else
		cout warning "vm.swappiness is not optimized!"
	fi
	sleep 1

	if [[ $(sysctl -n vm.vfs_cache_pressure) == "50" ]]; then
		cout info "vm.vfs_cache_pressure already optimized!"
	else
		cout warning "vm.vfs_cache_pressure is not optimized!"
	fi
	sleep 1
	
	if [[ $(sysctl -n net.core.rmem_max) == "16777216" ]]; then
		cout info "net.core.rmem_max already optimized!"
	else
		cout warning "net.core.rmem_max is not optimized!"
	fi
	sleep 1
	
	if [[ $(sysctl -n net.core.wmem_max) == "16777216" ]]; then
		cout info "net.core.wmem_max already optimized!"
	else
		cout warning "net.core.wmem_max is not optimized!"
	fi
	sleep 1
	
	if [[ $(sysctl -n net.ipv4.tcp_rmem | awk {'print $1, $2, $3'}) == "4096 87380 16777216" ]]; then
		cout info "net.ipv4.tcp_rmem already optimized!"
	else
		cout warning "net.ipv4.tcp_rmem is not optimized!"
	fi
	sleep 1
	
	if [[ $(sysctl -n net.ipv4.tcp_wmem | awk {'print $1, $2, $3'}) == "4096 65536 16777216" ]]; then
		cout info "net.ipv4.tcp_wmem already optimized!"
	else
		cout warning "net.ipv4.tcp_wmem is not optimized!"
	fi
	sleep 1
	
	if [[ $(sysctl -n net.ipv4.tcp_no_metrics_save) == "1" ]]; then
		cout info "net.ipv4.tcp_no_metrics_save already optimized!"
	else
		cout warning "net.ipv4.tcp_no_metrics_save is not optimized!"
	fi
	sleep 1
	
	if [[ $(sysctl -n net.ipv4.tcp_low_latency) == "1" ]]; then
		cout info "net.ipv4.tcp_low_latency already optimized!"
	else
		cout warning "net.ipv4.tcp_low_latency is not optimized!"
	fi
	sleep 1
	
	if [[ $(sysctl -n net.ipv4.ipfrag_secret_interval) == "6000" ]]; then
		cout info "net.ipv4.ipfrag_secret_interval already optimized!"
	else
		cout warning "net.ipv4.ipfrag_secret_interval is not optimized!"
	fi
	sleep 1
	
	if [[ $(sysctl -n net.ipv4.conf.all.accept_redirects) == "0" ]]; then
		cout info "net.ipv4.conf.all.accept_redirects already optimized!"
	else
		cout warning "net.ipv4.conf.all.accept_redirects is not optimized!"
	fi
	sleep 1
	
	if [[ $(sysctl -n net.ipv6.conf.all.accept_redirects) == "0" ]]; then
		cout info "net.ipv6.conf.all.accept_redirects already optimized!"
	else
		cout warning "net.ipv6.conf.all.accept_redirects is not optimized!"
	fi
	sleep 1
	
	if [[ $(sysctl -n net.ipv4.tcp_syncookies) == "1" ]]; then
		cout info "net.ipv4.tcp_syncookies already optimized!"
	else
		cout warning "net.ipv4.tcp_syncookies is not optimized!"
	fi
	sleep 1
	
	if [[ $(sysctl -n net.ipv4.tcp_synack_retries) == "2" ]]; then
		cout info "net.ipv4.tcp_synack_retries already optimized!"
	else
		cout warning "net.ipv4.tcp_synack_retries is not optimized!"
	fi
	sleep 1
	
	if [[ $(sysctl -n fs.file-max) == "100000" ]]; then
		cout info "fs.file-max already optimized!"
	else
		cout warning "fs.file-max is not optimized!"
	fi
	sleep 1

	if [[ $(sysctl -n net.ipv4.tcp_sack) == "1" ]]; then
		cout info "net.ipv4.tcp_sack already optimized!"
	else
		cout warning "net.ipv4.tcp_sack is not optimized!"
	fi
	sleep 1

	if [[ $(sysctl -n net.ipv4.tcp_timestamps) == "1" ]]; then
		cout info "net.ipv4.tcp_timestamps already optimized!"
	else
		cout warning "net.ipv4.tcp_timestamps is not optimized!"
	fi
	sleep 1

	if [[ $(sysctl -n net.ipv4.tcp_fin_timeout) == "1" ]]; then
		cout info "net.ipv4.tcp_fin_timeout already optimized!"
	else
		cout warning "net.ipv4.tcp_fin_timeout is not optimized!"
	fi
	sleep 1

	if [[ $(sysctl -n net.ipv4.tcp_tw_recycle) == "1" ]]; then
		cout info "net.ipv4.tcp_tw_recycle already optimized!"
	else
		cout warning "net.ipv4.tcp_tw_recycle is not optimized!"
	fi
	sleep 1

	if [[ $(sysctl -n net.core.netdev_max_backlog) == "262144" ]]; then
		cout info "net.core.netdev_max_backlog already optimized!"
	else
		cout warning "net.core.netdev_max_backlog is not optimized!"
	fi
	sleep 1

	if [[ $(sysctl -n net.core.somaxconn) == "262144" ]]; then
		cout info "net.core.somaxconn already optimized!"
	else
		cout warning "net.core.somaxconn is not optimized!"
	fi
	sleep 1

	if [[ $(sysctl -n net.ipv4.tcp_max_orphans) == "262144" ]]; then
		cout info "net.ipv4.tcp_max_orphans already optimized!"
	else
		cout warning "net.ipv4.tcp_max_orphans is not optimized!"
	fi
	sleep 1

	if [[ $(sysctl -n net.ipv4.tcp_max_syn_backlog) == "262144" ]]; then
		cout info "net.ipv4.tcp_max_syn_backlog already optimized!"
	else
		cout warning "net.ipv4.tcp_max_syn_backlog is not optimized!"
	fi
	sleep 1
}

function backupOriginalSysctl()
{
	if [[ -f "/etc/sysctl.conf" ]]; then
		cout info "Found sysctl.conf, backing up."
		mv /etc/sysctl.conf /etc/sysctl.conf.original
		sleep 1
		cout action "Creating new fresh sysctl.conf"
		touch /etc/sysctl.conf
		sleep 1
		cout info "Done..."
	else
		cout warning "sysctl.conf not found!"
		sleep 1
		cout action "Creating new fresh sysctl.conf"
		touch /etc/sysctl.conf
		sleep 1
		cout info "Done..."
	fi
}

function insertConfiguration()
{
	echo "$1" >> /etc/sysctl.conf
}

function createNewSysctl()
{
	cout action "Building optimized settings for your system..."
	sleep 1

	cout action "Creating header..."
	sleep 1
	insertConfiguration "# /etc/sysctl.conf - Configuration file for setting system variables"
	insertConfiguration "# See /etc/sysctl.d/ for additional system variables"
	insertConfiguration "# This configuration made by t193r"
	insertConfiguration "# Please don't remove third line"
	insertConfiguration ""
	cout info "Done..."
	sleep 1

	cout action "Inserting kernel parameter"
	sleep 1

	cout action "Optimizing kernel.sem parameter..."
	sleep 1
	insertConfiguration "kernel.sem = 250 32000 100 128"

	cout action "Optimizing kernel.shmall parameter..."
	sleep 1
	insertConfiguration "kernel.shmall = 2097152"

	cout action "Optimizing kernel.shmmax parameter..."
	sleep 1
	insertConfiguration "kernel.shmmax = 2147483648"

	cout action "Optimizing kernel.shmmni parameter..."
	sleep 1
	insertConfiguration "kernel.shmmni = 4096"

	cout action "Optimizing vm.swappiness parameter..."
	sleep 1
	insertConfiguration "vm.swappiness = 10"

	cout action "Optimizing vm.vfs_cache_pressure parameter..."
	sleep 1
	insertConfiguration "vm.vfs_cache_pressure = 50"

	cout action "Optimizing net.core.rmem_max parameter..."
	sleep 1
	insertConfiguration "net.core.rmem_max = 16777216"

	cout action "Optimizing net.core.wmem_max parameter"
	sleep 1
	insertConfiguration "net.core.wmem_max = 16777216"

	cout action "Optimizing net.ipv4.tcp_rmem parameter..."
	sleep 1
	insertConfiguration "net.ipv4.tcp_rmem = 4096 87380 16777216"

	cout action "Optimizing net.ipv4.tcp_wmem parameter..."
	sleep 1
	insertConfiguration "net.ipv4.tcp_wmem = 4096 65536 16777216"

	cout action "Optimizing net.ipv4.tcp_no_metrics_save parameter..."
	sleep 1
	insertConfiguration "net.ipv4.tcp_no_metrics_save = 1"

	cout action "Optimizing net.ipv4.tcp_low_latency parameter..."
	sleep 1
	insertConfiguration "net.ipv4.tcp_low_latency = 1"

	cout action "Optimizing net.ipv4.ipfrag_secret_interval parameter..."
	sleep 1
	insertConfiguration "net.ipv4.ipfrag_secret_interval = 6000"

	cout action "Optimizing net.ipv4.conf.all.accept_redirects parameter..."
	sleep 1
	insertConfiguration "net.ipv4.conf.all.accept_redirects = 0"

	cout action "Optimizing net.ipv6.conf.all.accept_redirects parameter..."
	sleep 1
	insertConfiguration "net.ipv6.conf.all.accept_redirects = 0"

	cout action "Optimizing net.ipv4.tcp_syncookies parameter..."
	sleep 1
	insertConfiguration "net.ipv4.tcp_syncookies = 1"

	cout action "Optimizing net.ipv4.tcp_synack_retries parameter..."
	sleep 1
	insertConfiguration "net.ipv4.tcp_synack_retries = 2"

	cout action "Optimizing fs.file-max parameter..."
	sleep 1
	insertConfiguration "fs.file-max = 100000"

	cout action "Optimizing net.ipv4.tcp_sack parameter..."
	sleep 1
	insertConfiguration "net.ipv4.tcp_sack = 1"

	cout action "Optimizing net.ipv4.tcp_timestamps parameter..."
	sleep 1
	insertConfiguration "net.ipv4.tcp_timestamps = 1"

	cout action "Optimizing net.ipv4.tcp_fin_timeout parameter..."
	sleep 1
	insertConfiguration "net.ipv4.tcp_fin_timeout = 1"

	cout action "Optimizing net.ipv4.tcp_tw_recycle parameter..."
	sleep 1
	insertConfiguration "net.ipv4.tcp_tw_recycle = 1"

	cout action "Optimizing net.core.netdev_max_backlog parameter..."
	sleep 1
	insertConfiguration "net.core.netdev_max_backlog = 262144"

	cout action "Optimizing net.core.somaxconn parameter..."
	sleep 1
	insertConfiguration "net.core.somaxconn = 262144"

	cout action "Optimizing net.ipv4.tcp_max_orphans parameter..."
	sleep 1
	insertConfiguration "net.ipv4.tcp_max_orphans = 262144"

	cout action "Optimizing net.ipv4.tcp_max_syn_backlog parameter..."
	sleep 1
	insertConfiguration "net.ipv4.tcp_max_syn_backlog = 262144"

	cout info "All done..."
	sleep 1
}

function applyNewParameter()
{
	cout action "Apllying new configuration..."
	sleep 1
	cout info "If you find any error, or you have a suggest[s] please let me know by send me an email to hanggara33[at]gmail[dot]com"
	sysctl -p
	sleep 1
	cout info "All done... Have a nice day..."
}

#------------------------ Main Program -----------------------------#

trap 'interrupt' INT
checkRoot
setTerminal
testTerminal
findSysCtl
checkValue
backupOriginalSysctl
createNewSysctl
applyNewParameter