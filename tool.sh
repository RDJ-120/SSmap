#!/usr/bin/env bash

clear

rows=$(( ($(tput lines) / 2) - 4 ))
cols=$(( ($(tput cols) / 2) - 12 ))


if [[ -z $(command -v nmap) ]]; then
	printf "\e[38;2;255;0;0mNmap Tool Not Found\n\e[38;5;83mWant To Download it?[ Y - N ]:  " && read err
	printf "\e[0m"
	if [[ ${err,,} == "y" ]]; then
		clear
		if [[ $HOME == "/data/data/com.termux/files/home" ]]; then
			pkg install nmap
		else
			sudo apt install nmap -y || sudo dnf install nmap -y || sudo pacman -S nmap --noconfirm
		fi
	else
		clear
		printf "\e[38;5;83mPlease downlaod nmap and use it again..."
		exit 1
	fi
fi
clear
printf "\e[38;5;120mWant one IP or All Network?[ O - A ]:  " && read ans

if [[ ${ans,,} == "a" ]]; then
	printf "\e[38;2;255;255;0mWARNING: Be careful and put only All network format"
	sleep 5
fi

clear

printf "\e[${cols}C\e[${rows}B\e[38;5;120m[ \e[0m+ \e[38;5;120m] Enter The IP:\n \e[38;5;123m\e[${cols}C   " && read ip

clear

if [[ -z "$ip" ]]; then
	printf "\e[38;2;255;0;0mERROR: \e[38;5;160mNo IP Entered.\n"
	exit 1
fi

allsimple() {
	local text=$(nmap $ip)
	local text=$(echo "$text" | sed -E '/Starting Nmap/d')
	readarray -d '' nmaphosts < <(awk -v RS='Nmap scan report for ' 'NF { printf "%s\0", "Nmap scan report for " $0}' <<< "$text")
	for one in "${nmaphosts[@]}"; do
		local txt=$(echo "$one" | head -n 1 | sed 's/Nmap/SSmap/')
		printf "\e[38;5;120m$txt\n"
		if [[ "$one" == *"seems down"* ]]; then
			printf "\e[38;2;255;0;0mERROR: \e[38;5;160mThe IP is dead.\e[0m\n\n"
		elif [[ "$one" == *"resolve"* ]]; then
			printf "\e[38;2;255;0;0mERROR: \e[38;5;160mBad IP pattern\e[0m\n\n"       
		elif [[ "$one" != *"PORT"* ]]; then
			printf "\e[38;5;124mNo Open Or Filtered Ports Found.\e[0m\n\n"
		else
			local res=$(echo "$one" | awk '/PORT/,/Nmap/' | sed -E '/PORT/d; /Nmap/d; /^[ +]*$/d')
			printf "\e[38;5;87m$res\n\e[0m\n\n"
		fi
	done
	exit 0
}

allbetter() {
	local rows=$(( ($(tput lines) / 2) - 4 ))
	local cols=$(( ($(tput cols) / 2) - 16 ))

	printf "\e[${cols}C\e[${rows}B\e[38;5;83mMay take long time... please wait\e[0m"
	tput civis
	text=$(nmap -sV $ip)
	tput cnorm
	clear

	local text=$(echo "$text" | sed -E '/Starting Nmap/d')
	readarray -d '' nmaphosts < <(awk -v RS='Nmap scan report for ' 'NF { printf "%s\0", "Nmap scan report for " $0}' <<< "$text")
	for one in "${nmaphosts[@]}"; do
		local txt=$(echo "$one" | head -n 1 | sed 's/Nmap/SSmap/')
		printf "\e[38;5;46m$txt\n"
		if [[ "$one" == *"seems down"* ]]; then
			printf "\e[38;2;255;0;0mERROR: \e[38;5;160mThe IP is dead.\e[0m\n\n"
		elif [[ "$one" == *"resolve"* ]]; then
			printf "\e[38;2;255;0;0mERROR: \e[38;5;160mBad IP pattern\e[0m\n\n"
		elif [[ "$one" != *"PORT"* ]]; then
			printf "\e[38;5;124mNo Open Or Filtered Ports Found.\e[0m\n\n"
		else
			local res=$(echo "$one" | awk '/PORT/,/Nmap/' | sed -E '/PORT/d; /Nmap/d; /^[ +]*$/d')
			local info=$(echo "$res" | grep --color=never "Service Info" | sed 's/Service Info: //')
			local final=$(echo "$res" | sed -E '/Service/d')
			IFS=";" read -ra ele <<< "$info"
			printf "\e[38;5;120mPorts and Info about it:\n"
			printf "\e[38;5;87m$final\n\e[0m\n\n"
			printf "\e[38;5;120mService Info:\n"

			for one in "${ele[@]}"; do
				local onee=$(echo $one | sed 's/^[ ]+//')
				printf "\e[38;5;51m$onee\n"
			done

			if [[ -z $ele ]]; then
				printf "\e[38;5;124mNo Information Found."
			fi
			printf "\n\n"
		fi
	
	done
	exit 0
}	
simple() {
	tput civis
	local res1="$(nmap $ip 2>&1)"
	tput cnorm
	clear
	if [[ "$res1" == *"seems down"* ]]; then
		printf "\e[38;2;255;0;0mERROR: \e[38;5;160mThe IP is dead.\e[0m\n"
		exit 1
	elif [[ "$res1" == *"resolve"* ]]; then
		printf "\e[38;2;255;0;0mERROR: \e[38;5;160mBad IP pattern\e[0m\n"
		exit 1
	elif [[ "$res1" != *"PORT"* ]]; then
		printf "\e[38;5;120mNo Open Or Filtered Ports Found.\e[0m\n"
		exit 0
	fi

	local new="$(echo "$res1" | awk '/PORT/,/Nmap/' | sed -E '/PORT/d; /Nmap/d; /^[ +]*$/d')"

	printf "\e[38;5;120mFinished scanning successfully, RESULT:\n"
	printf "\e[38;5;87m$new\n\e[0m"
	exit 0

}

better() {
	printf "\e[${cols}C\e[${rows}B\e[38;5;83mWe are scanning... please wait\e[0m"
	
	tput civis
	local res1="$(nmap -sV "${ip}")"
	tput cnorm
	clear
	if [[ "$res1" == *"seems down"* ]]; then
		printf "\e[38;2;255;0;0mERROR: \e[38;5;160mThe IP is dead.\e[0m\n"
		exit 1
	elif [[ "$res1" == *"resolve"* ]]; then
		printf "\e[38;2;255;0;0mERROR: \e[38;5;160mBad IP pattern\e[0m\n"
		exit 1
	elif [[ "$res1" != *"PORT"* ]]; then
		printf "\e[38;5;120mNo Open Or Filtered Ports Found.\e[0m\n"
		exit 0
	fi

	local new="$(echo "$res1" | awk '/PORT/,/Nmap/' | sed -E '/Nmap/d; /detection performed/d; /PORT/d')"
	local info=$(echo "$new" | grep --color=never "Service Info" | sed 's/Service Info: //')
	local final=$(echo "$new" | sed -E '/Service/d')

	IFS=";" read -ra ele <<< "$info"
	

	printf "\e[38;5;120mPorts and Info about it:\n"
	printf "\e[38;5;51m$final\n\n"
	printf "\e[38;5;120mService Info:\n"
	
	for one in "${ele[@]}"; do
		local onee=$(echo $one | sed 's/^[ ]+//')
		printf "\e[38;5;51m$onee\n"
	done

	if [[ -z $ele ]]; then
		printf "\e[38;5;124mNo Information Found."
	fi

	exit 0
}
clear
printf "\e[38;5;120mWant surface info only?[ Y - N ]:  \e[38;5;123m" && read answer
clear
if [[ "${answer,,}" == "y" ]]; then
	if [[ ${ans,,} == "a" ]]; then
		allsimple
	else
		printf "\e[${cols}C\e[${rows}B\e[38;5;83mWe are scanning... please wait\e[0m"
		simple
	fi
else
	if [[ ${ans,,} == "a" ]]; then
		allbetter
	else
		better
	fi
fi
