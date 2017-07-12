#!/bin/bash

# -------------------------------------------------------------------------
# @Programa 
# 	@name: integraGZ.sh
#	@versao: 2.2
#	@Data 28 de Abril de 2017
#	@Copyright: Verdanatech Soluções em TI, 2016 - 2017
#	@Copyright: Pillares Consulting, 2016
# --------------------------------------------------------------------------
# LICENSE
#
# integraGZ.sh is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# integraGZ.sh is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# If not, see <http://www.gnu.org/licenses/>.
# --------------------------------------------------------------------------

# Variaveis

versionDate="April 28, 2017"
TITULO="integraGZ.sh - v.2.2"
BANNER="http://www.verdanatech.com"

devMail=halexsandro.sales@verdanatech.com
zabbixVersion=zabbix-3.2.5
TMP_DIR=/tmp
zabbixSource=$TMP_DIR/$zabbixVersion
verdanatechGIT=https://github.com/verdanatech/igz
serverAddress=$(hostname -I | cut -d' ' -f1)
glpiTag=0
zabbixTag=0

clear

echo -e " ------------------------------------------------ _   _   _ \n ----------------------------------------------- / \\ / \\ / \\ \n ---------------------------------------------- ( i | G | Z ) \n ----------------------------------------------- \\_/ \\_/ \\_/ \n| __      __          _                   _            _\n| \\ \\    / /         | |                 | |          | | \n|  \\ \\  / ___ _ __ __| | __ _ _ __   __ _| |_ ___  ___| |__ \n|   \\ \\/ / _ | '__/ _\` |/ _\` | '_ \\ / _\` | __/ _ \\/ __| '_ \\ \n|    \\  |  __| | | (_| | (_| | | | | (_| | ||  __| (__| | | | \n|     \\/ \\___|_|  \\__,_|\\__,_|_| |_|\\__,_|\\__\\___|\\___|_| |_| \n| \n|                    consulting, training and implamentation \n|                                  comercial@verdanatech.com \n|                                        www.verdanatech.com \n|                                          +55 81 3091 42 52 \n ------------------------------------------------------------ \n| integraGZ.sh  - GLPI 9.1.3 and a lot plugins + Zabbix 3.2.5| \n ------------------------------------------------------------ \n
"
sleep 5
REQ_TO_USE ()
{
# Testa se o usuário é o root
if [ $UID -ne 0 ]
then
	whiptail --title "${TITULO}" --backtitle "${BANNER}" --msgbox "We apologize! You need root access to use this script." --fb 10 50
	kill $$
fi
# Testa a versão do sistema
debianVersion=$(cat /etc/debian_version | cut -d"." -f1 )
if [ $debianVersion -ne 8 ]
then
	whiptail --title "${TITULO}" --backtitle "${BANNER}" --msgbox "We apologize! This script was developed for Debian 8.x. We will close the running now." --fb 10 50
	kill $$
fi
}
MAIN_MENU ()
{
 
menu01Option=$(whiptail --title "${TITULO}" --backtitle "${BANNER}" --menu "Select a option!" --fb 15 50 6 \
"1" "Verdanatech iGZ (complete installation)" \
"2" "GLPI and plugins" \
"3" "Zabbix + Verdanatech iGZ" \
"4" "Only Verdanatech iGZ" \
"5" "About" \
"6" "Exit" 3>&1 1>&2 2>&3)
 
status=$?
if [ $status != 0 ]; then
	echo "
You have selected out. Bye!
"
	exit;
fi
}
ABOUT ()
{
clear
whiptail --title "${TITULO}" --backtitle "${BANNER}" --msgbox "
Copyright:
- Verdanatech Solucoes em TI, $versionDate

Licence:
- GPL v3 <http://www.gnu.org/licenses/>

Project partners:
- Gustavo Soares <slot.mg@gmail.com>
- Halexsandro Sales <halexsandro@gmail.com>
- Janssen Lima <janssenreislima@gmail.com>
"  --fb 0 0 0
}
#
# Garante que o usuário tenha o whiptail instalado no computador
WHIPTAIL_INSTALL () 
{
echo "deb http://ftp.de.debian.org/debian jessie main" > /etc/apt/sources.list
apt-get update 2> /dev/null
apt-get install whiptail
clear
[ ! -e /usr/bin/whiptail ] && { echo -e "

 ###########################################################
#                       WARNING!!!                          #
 -----------------------------------------------------------
#                                                           #
#                                                           #
# There was an error installing the whiptail.               #
#  - Check your internet connection.                        #
#                                                           #
# The whiptail package is required to run the integraGZ.sh  #
# Please contact us: $devMail                               #
#                                                           #
#                                                           #
 ----------------------------------------------------------
      Verdanatech Solucoes em TI - www.verdanatech.com 
 ----------------------------------------------------------"; 
	exit 1; }
}
INFORMATION () 
{
whiptail --title "${TITULO}" --backtitle "${BANNER}" --msgbox "
This script aims to perform the installation automated systems:
 - GLPI 9.1.3  [http://glpi-project.com]
  -- With a lot plugins from community
 - Zabbix 3.2.5   [http://zabbix.com]
  -- zabbix-server-mysql
  -- zabbix-agent
" --fb 0 0 0
}
TIME_ZONE ()
# Configura timezone do PHP para o servidor
# Ref: http://php.net/manual/pt_BR/timezones.php
# 
{
whiptail --title "${TITULO}" --backtitle "${BANNER}" --msgbox "Now we configure the server's timezone. Select the timezone that best meets!." --fb 10 50
while [ -z $timePart1 ]
do
timePart1=$(whiptail --title "${TITULO}" --backtitle "${BANNER}" --radiolist \
"Select the timezone for your Server!" 20 60 10 \
	"Africa" "" OFF \
	"America" "" OFF \
	"Antarctica" "" OFF \
	"Arctic" "" OFF \
	"Asia" "" OFF \
	"Atlantic" "" OFF \
	"Australia" "" OFF \
	"Europe" "" OFF \
	"Indian" "" OFF \
	"Pacific" "" OFF  3>&1 1>&2 2>&3)
done
case $timePart1 in
	Africa)
	while [ -z $timePart2 ]
	do
		timePart2=$(whiptail --title  "${TITULO}" --backtitle "${BANNER}" --radiolist \
		"Select the timezone for your Server!" 20 50 12 \
			"Abidjan" "" OFF \
			"Accra" "" OFF \
			"Addis_Ababa" "" OFF \
			"Algiers" "" OFF \
			"Asmara" "" OFF \
			"Asmera" "" OFF \
			"Bamako" "" OFF \
			"Bangui" "" OFF \
			"Banjul" "" OFF \
			"Bissau" "" OFF \
			"Blantyre" "" OFF \
			"Brazzaville" "" OFF \
			"Bujumbura" "" OFF \
			"Cairo" "" OFF \
			"Casablanca" "" OFF \
			"Ceuta" "" OFF \
			"Conakry" "" OFF \
			"Dakar" "" OFF \
			"Dar_es_Salaam" "" OFF \
			"Djibouti" "" OFF \
			"Douala" "" OFF \
			"El_Aaiun" "" OFF \
			"Freetown" "" OFF \
			"Gaborone" "" OFF \
			"Harare" "" OFF \
			"Johannesburg" "" OFF \
			"Juba" "" OFF \
			"Kampala" "" OFF \
			"Khartoum" "" OFF \
			"Kigali" "" OFF \
			"Kinshasa" "" OFF \
			"Lagos" "" OFF \
			"Libreville" "" OFF \
			"Lome" "" OFF \
			"Luanda" "" OFF \
			"Lubumbashi" "" OFF \
			"Lusaka" "" OFF \
			"Malabo" "" OFF \
			"Maputo" "" OFF \
			"Maseru" "" OFF \
			"Mbabane" "" OFF \
			"Mogadishu" "" OFF \
			"Monrovia" "" OFF \
			"Nairobi" "" OFF \
			"Ndjamena" "" OFF \
			"Niamey" "" OFF \
			"Nouakchott" "" OFF \
			"Ouagadougou" "" OFF \
			"Porto-Novo" "" OFF \
			"Sao_Tome" "" OFF \
			"Timbuktu" "" OFF \
			"Tripoli" "" OFF   3>&1 1>&2 2>&3)
	done
	;;
	America)
	while [ -z $timePart2 ]
	do
		timePart2=$(whiptail --title  "${TITULO}" --backtitle "${BANNER}" --radiolist \
		"Select the timezone for your Server!" 20 50 12 \
			"Adak" "" OFF \
			"Anchorage" "" OFF \
			"Anguilla" "" OFF \
			"Antigua" "" OFF \
			"Araguaina" "" OFF \
			"Argentina/Buenos_Aires" "" OFF \
			"Argentina/Catamarca" "" OFF \
			"Argentina/ComodRivadavia" "" OFF \
			"Argentina/Cordoba" "" OFF \
			"Argentina/Jujuy" "" OFF \
			"Argentina/La_Rioja" "" OFF \
			"Argentina/Mendoza" "" OFF \
			"Argentina/Rio_Gallegos" "" OFF \
			"Argentina/Salta" "" OFF \
			"Argentina/San_Juan" "" OFF \
			"Argentina/San_Luis" "" OFF \
			"Argentina/Tucuman" "" OFF \
			"Argentina/Ushuaia" "" OFF \
			"Aruba" "" OFF \
			"Asuncion" "" OFF \
			"Atikokan" "" OFF \
			"Atka" "" OFF \
			"Bahia" "" OFF \
			"Bahia_Banderas" "" OFF \
			"Barbados" "" OFF \
			"Belem" "" OFF \
			"Belize" "" OFF \
			"Blanc-Sablon" "" OFF \
			"Boa_Vista" "" OFF \
			"Bogota" "" OFF \
			"Boise" "" OFF \
			"Buenos_Aires" "" OFF \
			"Cambridge_Bay" "" OFF \
			"Campo_Grande" "" OFF \
			"Cancun" "" OFF \
			"Caracas" "" OFF \
			"Catamarca" "" OFF \
			"Cayenne" "" OFF \
			"Cayman" "" OFF \
			"Chicago" "" OFF \
			"Chihuahua" "" OFF \
			"Coral_Harbour" "" OFF \
			"Cordoba" "" OFF \
			"Costa_Rica" "" OFF \
			"Creston" "" OFF \
			"Cuiaba" "" OFF \
			"Curacao" "" OFF \
			"Danmarkshavn" "" OFF \
			"Dawson" "" OFF \
			"Dawson_Creek" "" OFF \
			"Denver" "" OFF \
			"Detroit" "" OFF \
			"Dominica" "" OFF \
			"Edmonton" "" OFF \
			"Eirunepe" "" OFF \
			"El_Salvador" "" OFF \
			"Ensenada" "" OFF \
			"Fort_Nelson" "" OFF \
			"Fort_Wayne" "" OFF \
			"Fortaleza" "" OFF \
			"Glace_Bay" "" OFF \
			"Godthab" "" OFF \
			"Goose_Bay" "" OFF \
			"Grand_Turk" "" OFF \
			"Grenada" "" OFF \
			"Guadeloupe" "" OFF \
			"Guatemala" "" OFF \
			"Guayaquil" "" OFF \
			"Guyana" "" OFF \
			"Halifax" "" OFF \
			"Havana" "" OFF \
			"Hermosillo" "" OFF \
			"Indiana/Indianapolis" "" OFF \
			"Indiana/Knox" "" OFF \
			"Indiana/Marengo" "" OFF \
			"Indiana/Petersburg" "" OFF \
			"Indiana/Tell_City" "" OFF \
			"Indiana/Vevay" "" OFF \
			"Indiana/Vincennes" "" OFF \
			"Indiana/Winamac" "" OFF \
			"Indianapolis" "" OFF \
			"Inuvik" "" OFF \
			"Iqaluit" "" OFF \
			"Jamaica" "" OFF \
			"Jujuy" "" OFF \
			"Juneau" "" OFF \
			"Kentucky/Louisville" "" OFF \
			"Kentucky/Monticello" "" OFF \
			"Knox_IN" "" OFF \
			"Kralendijk" "" OFF \
			"La_Paz" "" OFF \
			"Lima" "" OFF \
			"Los_Angeles" "" OFF \
			"Louisville" "" OFF \
			"Lower_Princes" "" OFF \
			"Maceio" "" OFF \
			"Managua" "" OFF \
			"Manaus" "" OFF \
			"Marigot" "" OFF \
			"Martinique" "" OFF \
			"Matamoros" "" OFF \
			"Mazatlan" "" OFF \
			"Mendoza" "" OFF \
			"Menominee" "" OFF \
			"Merida" "" OFF \
			"Metlakatla" "" OFF \
			"Mexico_City" "" OFF \
			"Miquelon" "" OFF \
			"Moncton" "" OFF \
			"Monterrey" "" OFF \
			"Montevideo" "" OFF \
			"Montreal" "" OFF \
			"Montserrat" "" OFF \
			"Nassau" "" OFF \
			"New_York" "" OFF \
			"Nipigon" "" OFF \
			"Nome" "" OFF \
			"Noronha" "" OFF \
			"North_Dakota/Beulah" "" OFF \
			"North_Dakota/Center" "" OFF \
			"North_Dakota/New_Salem" "" OFF \
			"Ojinaga" "" OFF \
			"Panama" "" OFF \
			"Pangnirtung" "" OFF \
			"Paramaribo" "" OFF \
			"Phoenix" "" OFF \
			"Port-au-Prince" "" OFF \
			"Port_of_Spain" "" OFF \
			"Porto_Acre" "" OFF \
			"Porto_Velho" "" OFF \
			"Puerto_Rico" "" OFF \
			"Rainy_River" "" OFF \
			"Rankin_Inlet" "" OFF \
			"Recife" "" OFF \
			"Regina" "" OFF \
			"Resolute" "" OFF \
			"Rio_Branco" "" OFF \
			"Rosario" "" OFF \
			"Santa_Isabel" "" OFF \
			"Santarem" "" OFF \
			"Santiago" "" OFF \
			"Santo_Domingo" "" OFF \
			"Sao_Paulo" "" OFF \
			"Scoresbysund" "" OFF \
			"Shiprock" "" OFF \
			"Sitka" "" OFF \
			"St_Barthelemy" "" OFF \
			"St_Johns" "" OFF \
			"St_Kitts" "" OFF \
			"St_Lucia" "" OFF \
			"St_Thomas" "" OFF \
			"St_Vincent" "" OFF \
			"Swift_Current" "" OFF \
			"Tegucigalpa" "" OFF \
			"Thule" "" OFF \
			"Thunder_Bay" "" OFF \
			"Tijuana" "" OFF \
			"Toronto" "" OFF \
			"Tortola" "" OFF \
			"Vancouver" "" OFF \
			"Virgin" "" OFF \
			"Whitehorse" "" OFF \
			"Winnipeg" "" OFF \
			"Yakutat" "" OFF   3>&1 1>&2 2>&3)
		done
		;;
		
	Antarctica)
	while [ -z $timePart2 ]
	do
		timePart2=$(whiptail --title  "${TITULO}" --backtitle "${BANNER}" --radiolist \
		"Select the timezone for your Server!" 20 50 12 \
			"Casey" "" OFF \
			"Davis" "" OFF \
			"DumontDUrville" "" OFF \
			"Macquarie" "" OFF \
			"Mawson" "" OFF \
			"McMurdo" "" OFF \
			"Palmer" "" OFF \
			"Rothera" "" OFF \
			"South_Pole" "" OFF \
			"Syowa" "" OFF \
			"Troll" "" OFF \
			"Vostok"  "" OFF    3>&1 1>&2 2>&3)
	done
	;;
	Arctic)
	while [ -z $timePart2 ]
	do
		timePart2=$(whiptail --title  "${TITULO}" --backtitle "${BANNER}" --radiolist \
		"Select the timezone for your Server!" 20 50 12 \
			"Longyearbyen" "" OFF    3>&1 1>&2 2>&3)
	done
	;;
	Asia)
	while [ -z $timePart2 ]
	do
		timePart2=$(whiptail --title  "${TITULO}" --backtitle "${BANNER}" --radiolist \
		"Select the timezone for your Server!" 20 50 12 \
			"Aden" "" OFF \
			"Almaty" "" OFF \
			"Amman" "" OFF \
			"Anadyr" "" OFF \
			"Aqtau" "" OFF \
			"Aqtobe" "" OFF \
			"Ashgabat" "" OFF \
			"Ashkhabad" "" OFF \
			"Baghdad" "" OFF \
			"Bahrain" "" OFF \
			"Baku" "" OFF \
			"Bangkok" "" OFF \
			"Beirut" "" OFF \
			"Bishkek" "" OFF \
			"Brunei" "" OFF \
			"Calcutta" "" OFF \
			"Chita" "" OFF \
			"Choibalsan" "" OFF \
			"Chongqing" "" OFF \
			"Chungking" "" OFF \
			"Colombo" "" OFF \
			"Dacca" "" OFF \
			"Damascus" "" OFF \
			"Dhaka" "" OFF \
			"Dili" "" OFF \
			"Dubai" "" OFF \
			"Dushanbe" "" OFF \
			"Gaza" "" OFF \
			"Harbin" "" OFF \
			"Hebron" "" OFF \
			"Ho_Chi_Minh" "" OFF \
			"Hong_Kong" "" OFF \
			"Hovd" "" OFF \
			"Irkutsk" "" OFF \
			"Istanbul" "" OFF \
			"Jakarta" "" OFF \
			"Jayapura" "" OFF \
			"Jerusalem" "" OFF \
			"Kabul" "" OFF \
			"Kamchatka" "" OFF \
			"Karachi" "" OFF \
			"Kashgar" "" OFF \
			"Kathmandu" "" OFF \
			"Katmandu" "" OFF \
			"Khandyga" "" OFF \
			"Kolkata" "" OFF \
			"Krasnoyarsk" "" OFF \
			"Kuala_Lumpur" "" OFF \
			"Kuching" "" OFF \
			"Kuwait" "" OFF \
			"Macao" "" OFF \
			"Macau" "" OFF \
			"Magadan" "" OFF \
			"Makassar" "" OFF \
			"Manila" "" OFF \
			"Muscat" "" OFF \
			"Nicosia" "" OFF \
			"Novokuznetsk" "" OFF \
			"Novosibirsk" "" OFF \
			"Omsk" "" OFF \
			"Oral" "" OFF \
			"Phnom_Penh" "" OFF \
			"Pontianak" "" OFF \
			"Pyongyang" "" OFF \
			"Qatar" "" OFF \
			"Qyzylorda" "" OFF \
			"Rangoon" "" OFF \
			"Riyadh" "" OFF \
			"Saigon" "" OFF \
			"Sakhalin" "" OFF \
			"Samarkand" "" OFF \
			"Seoul" "" OFF \
			"Shanghai" "" OFF \
			"Singapore" "" OFF \
			"Srednekolymsk" "" OFF \
			"Taipei" "" OFF \
			"Tashkent" "" OFF \
			"Tbilisi" "" OFF \
			"Tehran" "" OFF \
			"Tel_Aviv" "" OFF \
			"Thimbu" "" OFF \
			"Thimphu" "" OFF \
			"Tokyo" "" OFF \
			"Ujung_Pandang" "" OFF \
			"Ulaanbaatar" "" OFF \
			"Ulan_Bator" "" OFF \
			"Urumqi" "" OFF \
			"Ust-Nera" "" OFF \
			"Vientiane" "" OFF \
			"Vladivostok" "" OFF \
			"Yakutsk" "" OFF \
			"Yekaterinburg" "" OFF     3>&1 1>&2 2>&3)
	done
	;;
	Atlantic)
	while [ -z $timePart2 ]
	do
		timePart2=$(whiptail --title  "${TITULO}" --backtitle "${BANNER}" --radiolist \
		"Select the timezone for your Server!" 20 50 12 \
			"Azores" "" OFF \
			"Bermuda" "" OFF \
			"Canary" "" OFF \
			"Cape_Verde" "" OFF \
			"Faeroe" "" OFF \
			"Faroe" "" OFF \
			"Jan_Mayen" "" OFF \
			"Madeira" "" OFF \
			"Reykjavik" "" OFF \
			"South_Georgia" "" OFF \
			"St_Helena" "" OFF \
			"Stanley" "" OFF      3>&1 1>&2 2>&3)
	done
	;;
	Australia)
	while [ -z $timePart2 ]
	do
		timePart2=$(whiptail --title  "${TITULO}" --backtitle "${BANNER}" --radiolist \
		"Select the timezone for your Server!" 20 50 12 \
			"ACT" "" OFF \
			"Adelaide" "" OFF \
			"Brisbane" "" OFF \
			"Broken_Hill" "" OFF \
			"Canberra" "" OFF \
			"Currie" "" OFF \
			"Darwin" "" OFF \
			"Eucla" "" OFF \
			"Hobart" "" OFF \
			"LHI" "" OFF \
			"Lindeman" "" OFF \
			"Lord_Howe" "" OFF \
			"Melbourne" "" OFF \
			"North" "" OFF \
			"NSW" "" OFF \
			"Perth" "" OFF \
			"Queensland" "" OFF \
			"South" "" OFF \
			"Sydney" "" OFF \
			"Tasmania" "" OFF \
			"Victoria" "" OFF \
			"West" "" OFF \
			"Yancowinna" "" OFF      3>&1 1>&2 2>&3)
	done
	;;
	Europe)
	while [ -z $timePart2 ]
	do
		timePart2=$(whiptail --title  "${TITULO}" --backtitle "${BANNER}" --radiolist \
		"Select the timezone for your Server!" 20 50 12 \
			"Amsterdam" "" OFF \
			"Andorra" "" OFF \
			"Athens" "" OFF \
			"Belfast" "" OFF \
			"Belgrade" "" OFF \
			"Berlin" "" OFF \
			"Bratislava" "" OFF \
			"Brussels" "" OFF \
			"Bucharest" "" OFF \
			"Budapest" "" OFF \
			"Busingen" "" OFF \
			"Chisinau" "" OFF \
			"Copenhagen" "" OFF \
			"Dublin" "" OFF \
			"Gibraltar" "" OFF \
			"Guernsey" "" OFF \
			"Helsinki" "" OFF \
			"Isle_of_Man" "" OFF \
			"Istanbul" "" OFF \
			"Jersey" "" OFF \
			"Kaliningrad" "" OFF \
			"Kiev" "" OFF \
			"Lisbon" "" OFF \
			"Ljubljana" "" OFF \
			"London" "" OFF \
			"Luxembourg" "" OFF \
			"Madrid" "" OFF \
			"Malta" "" OFF \
			"Mariehamn" "" OFF \
			"Minsk" "" OFF \
			"Monaco" "" OFF \
			"Moscow" "" OFF \
			"Nicosia" "" OFF \
			"Oslo" "" OFF \
			"Paris" "" OFF \
			"Podgorica" "" OFF \
			"Prague" "" OFF \
			"Riga" "" OFF \
			"Rome" "" OFF \
			"Samara" "" OFF \
			"San_Marino" "" OFF \
			"Sarajevo" "" OFF \
			"Simferopol" "" OFF \
			"Skopje" "" OFF \
			"Sofia" "" OFF \
			"Stockholm" "" OFF \
			"Tallinn" "" OFF \
			"Tirane" "" OFF \
			"Tiraspol" "" OFF \
			"Uzhgorod" "" OFF \
			"Vaduz" "" OFF \
			"Vatican" "" OFF \
			"Vienna" "" OFF \
			"Vilnius" "" OFF \
			"Volgograd" "" OFF \
			"Warsaw" "" OFF \
			"Zagreb" "" OFF \
			"Zaporozhye" "" OFF \
			"Zurich" "" OFF      3>&1 1>&2 2>&3)
	done
	;;
	Indian)
	while [ -z $timePart2 ]
	do
		timePart2=$(whiptail --title  "${TITULO}" --backtitle "${BANNER}" --radiolist \
		"Select the timezone for your Server!" 20 50 12 \
			"Antananarivo" "" OFF \
			"Chagos" "" OFF \
			"Christmas" "" OFF \
			"Cocos" "" OFF \
			"Comoro" "" OFF \
			"Kerguelen" "" OFF \
			"Mahe" "" OFF \
			"Maldives" "" OFF \
			"Mauritius" "" OFF \
			"Mayotte" "" OFF \
			"Reunion" "" OFF      3>&1 1>&2 2>&3)
	done
	;;
	Pacific)
	while [ -z $timePart2 ]
	do
		timePart2=$(whiptail --title  "${TITULO}" --backtitle "${BANNER}" --radiolist \
		"Select the timezone for your Server!" 20 50 12 \
			"Apia" "" OFF \
			"Auckland" "" OFF \
			"Bougainville" "" OFF \
			"Chatham" "" OFF \
			"Chuuk" "" OFF \
			"Easter" "" OFF \
			"Efate" "" OFF \
			"Enderbury" "" OFF \
			"Fakaofo" "" OFF \
			"Fiji" "" OFF \
			"Funafuti" "" OFF \
			"Galapagos" "" OFF \
			"Gambier" "" OFF \
			"Guadalcanal" "" OFF \
			"Guam" "" OFF \
			"Honolulu" "" OFF \
			"Johnston" "" OFF \
			"Kiritimati" "" OFF \
			"Kosrae" "" OFF \
			"Kwajalein" "" OFF \
			"Majuro" "" OFF \
			"Marquesas" "" OFF \
			"Midway" "" OFF \
			"Nauru" "" OFF \
			"Niue" "" OFF \
			"Norfolk" "" OFF \
			"Noumea" "" OFF \
			"Pago_Pago" "" OFF \
			"Palau" "" OFF \
			"Pitcairn" "" OFF \
			"Pohnpei" "" OFF \
			"Ponape" "" OFF \
			"Port_Moresby" "" OFF \
			"Rarotonga" "" OFF \
			"Saipan" "" OFF \
			"Samoa" "" OFF \
			"Tahiti" "" OFF \
			"Tarawa" "" OFF \
			"Tongatapu" "" OFF \
			"Truk" "" OFF \
			"Wake" "" OFF \
			"Wallis" "" OFF \
			"Yap" "" OFF      3>&1 1>&2 2>&3)
	done
	;;
	
esac
}
SET_REPOS ()
{
clear 
sleep 1
echo "Add repositories, updatind and upgrading the system..."
echo "deb http://ftp.br.debian.org/debian/ jessie main" > /etc/apt/sources.list
echo "deb-src http://ftp.br.debian.org/debian/ jessie main" >> /etc/apt/sources.list
echo "deb http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list
echo "deb-src http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list
echo "deb http://ftp.br.debian.org/debian/ jessie-updates main" >> /etc/apt/sources.list
echo "deb-src http://ftp.br.debian.org/debian/ jessie-updates main" >> /etc/apt/sources.list
echo "deb http://ftp.de.debian.org/debian/ jessie main non-free" >> /etc/apt/sources.list
echo "deb http://security.debian.org/debian-security jessie/updates main" >> /etc/apt/sources.list
apt-get update
apt-get upgrade -y
clear
}
GLPI_DEPS ()
{
clear
echo "Intalling Debian packages for GLPI..."
sleep 1
apt-get -y install apache2 php5 php5-apcu libapache2-mod-php5 php5-gd php5-ldap php5-curl php5-mysql php5-imap php-soap  php5-cli php5-common php5-snmp php5-xmlrpc libmysqld-dev libmysqlclient-dev mysql-server
}
ZABBIX_DEPS ()
{
clear
echo "Intalling Debian packages for Zabbix..."
sleep 1
apt-get -y install sudo git python-pip libxml2 libxml2-dev curl libcurl3 libcurl3-gnutls libcurl3-gnutls-dev libcurl4-gnutls-dev build-essential libssh2-1-dev libssh2-1 libiksemel-dev libiksemel-utils libiksemel3 fping libopenipmi-dev snmp snmp-mibs-downloader libsnmp-dev apache2 php5 php5-apcu libapache2-mod-php5 php5-gd php5-ldap php5-curl php5-mysql php5-imap php-soap  php5-cli php5-common php5-snmp php5-xmlrpc libmysqld-dev libmysqlclient-dev snmpd ttf-dejavu-core libltdl7 libodbc1 libgnutls28-dev libldap2-dev openjdk-7-jdk unixodbc-dev mysql-server
pip install zabbix-api
}
ZABBIX_INSTALL ()
{
zabbixTag=1
clear 
echo "Exec Zabbix Install..."
sleep 1
	## Processo de instalação do Zabbix 3.2
	# Criação de usuário e grupo do sistema
	groupadd zabbix
	useradd -g zabbix zabbix
	# Baixando e compilando o zabbix
	cd /tmp
	wget http://www.verdanatech.com/scripts/listaPortasSNMP.sh
	mv listaPortasSNMP.sh /bin/
	chmod 775 /bin/listaPortasSNMP.sh
	wget http://www.verdanatech.com/scripts/zbTemplateBuilder.sh
	mv zbTemplateBuilder.sh /bin/
	chmod 775 /bin/zbTemplateBuilder.sh
	wget "https://ufpr.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.2.5/zabbix-3.2.5.tar.gz"
	tar -zxvf zabbix-3.2.5.tar.gz
	cd zabbix-3.2.5
	./configure --enable-server --enable-agent --with-mysql --with-net-snmp --with-libcurl --with-libxml2 --with-ssh2 --with-ldap --with-iconv --with-gnutls --with-unixodbc --with-openipmi --with-jabber=/usr --enable-ipv6 --prefix=/usr/local/zabbix
	make install
	# Preparando scripts de serviço
	ln -s /usr/local/zabbix/etc /etc/zabbix
	mv misc/init.d/debian/zabbix* /etc/init.d/
	chmod 755 /etc/init.d/zabbix*
	sed -i 's/DAEMON=\/usr\/local\/sbin\/${NAME}*/DAEMON=\/usr\/local\/zabbix\/sbin\/${NAME}/' /etc/init.d/zabbix-server
	sed -i 's/DAEMON=\/usr\/local\/sbin\/${NAME}*/DAEMON=\/usr\/local\/zabbix\/sbin\/${NAME}/' /etc/init.d/zabbix-agent
	update-rc.d zabbix-server defaults
	update-rc.d zabbix-agent defaults
	# Adequando arquivos de log de zabbix-server e zabbix-agent
	mkdir /var/log/zabbix
	chown root:zabbix /var/log/zabbix
	chmod 775 /var/log/zabbix
	sed -i 's/LogFile=\/tmp\/zabbix_agentd.log*/LogFile=\/var\/log\/zabbix\/zabbix_agentd.log/' /etc/zabbix/zabbix_agentd.conf
	sed -i 's/LogFile=\/tmp\/zabbix_server.log*/LogFile=\/var\/log\/zabbix\/zabbix_server.log/' /etc/zabbix/zabbix_server.conf
	
	# Habilitando execução de comandos via Zabbix
	sed -i 's/# EnableRemoteCommands=0*/EnableRemoteCommands=1/' /etc/zabbix/zabbix_agentd.conf

	# Preparando o zabbix frontend
	mv frontends/php /var/www/html/zabbix

	TIME_ZONE

	echo -e "# Define /zabbix alias, this is the default\n<IfModule mod_alias.c>\n    Alias /zabbix /var/www/html/zabbix\n</IfModule>\n\n<Directory \"/var/www/html/zabbix\">\n\tOptions FollowSymLinks\n\tAllowOverride None\n\tOrder allow,deny\n\tAllow from all\n\n\tphp_value max_execution_time 300\n\tphp_value memory_limit 128M\n\tphp_value post_max_size 16M\n\tphp_value upload_max_filesize 2M\n\tphp_value max_input_time 300\n\tphp_value date.timezone $timePart1/$timePart2\n\tphp_value always_populate_raw_post_data -1\n</Directory>\n\n<Directory \"/var/www/html/zabbix/conf\">\n\tOrder deny,allow\n\tDeny from all\n\t<files *.php>\n\t\tOrder deny,allow\n\t\tDeny from all\n\t</files>\n</Directory>\n\n<Directory \"/var/www/html/zabbix/api\">\n\tOrder deny,allow\n\tDeny from all\n\t<files *.php>\n\t\tOrder deny,allow\n\t\tDeny from all\n\t</files>\n</Directory>\n\n<Directory \"/var/www/html/zabbix/include\">\n\tOrder deny,allow\n\tDeny from all\n\t<files *.php>\n\t\tOrder deny,allow\n\t\tDeny from all\n\t</files>\n</Directory>\n\n<Directory \"/var/www/html/zabbix/include/classes\">\n\tOrder deny,allow\n\tDeny from all\n\t<files *.php>\n\t\tOrder deny,allow\n\t\tDeny from all\n\t</files>\n</Directory>\n" > /etc/apache2/conf-available/zabbix.conf


	chmod +s /bin/ping
	chmod +s /usr/bin/fping
	chmod +s /bin/ping6
	chmod +s /usr/bin/fping6

	a2enconf zabbix

	# Reiniciando apache2

	chmod 775 /var/www/html/zabbix -Rf
	chown www-data:www-data /var/www/html/zabbix -Rf
	service apache2 restart

}

GLPI_INSTALL ()
{
glpiTag=1
clear 

echo "Exec GLPI Install..."
sleep 1

	#
	# Processo de instalação do GLPI
	#

	# Baixando o GLPI
	###
	wget https://github.com/glpi-project/glpi/releases/download/9.1.3/glpi-9.1.3.tgz
	tar -zxvf glpi-9.1.3.tgz
	mv glpi /var/www/html/

	#
	# Baixando o Racks

	# This plugin allows you to create bays. Manage the placement of your materials in your bays. And so know the space and its power 
	# 	consumption and heat dissipation.
	# - Bay detail : height - width - depth - weight - number of U.
	# - Front and back management.
	# - Definition of model specifications and materials used (power consumption, numbre of power supply, calorific waste, flow Rate, 
	# 	size (U), weight, depth)

	wget https://github.com/InfotelGLPI/racks/releases/download/1.7.0/glpi-racks-1.7.0.tar.gz
	tar -zxvf glpi-racks-1.7.0.tar.gz
	mv racks /var/www/html/glpi/plugins/

	#
	# Baixando o DashBoard
	# Dashboard. This plugin allows view statistics charts and reports from GLPI.
	# -Can be used with helpdesk.
	# wget https://forge.glpi-project.org/attachments/download/2179/GLPI-dashboard_plugin-0.8.2.tar.gz

	wget https://forge.glpi-project.org/attachments/download/2180/GLPI-dashboard_plugin-0.8.3.tar.gz
	tar -zxvf GLPI-dashboard_plugin-0.8.3.tar.gz
	mv dashboard /var/www/html/glpi/plugins/
	
	#
	# Baixando o MyDashboard
	# This plugin enables you to replace GLPI central by a dashboard
	# https://raw.githubusercontent.com/InfotelGLPI/mydashboard/master/README.md

	wget https://github.com/InfotelGLPI/mydashboard/releases/download/1.3.2/glpi-mydashboard-1.3.2.tar.gz
	tar -zxvf glpi-mydashboard-1.3.2.tar.gz
	mv mydashboard /var/www/html/glpi/plugins/mydashboard

	#
	# Baixando Seasonality
	# This plugin allows you to create seasonality for specific categories and thus increase the urgency and therefore the priority of the ticket

	wget https://github.com/InfotelGLPI/seasonality/releases/download/1.2.0/glpi-seasonality-1.2.0.tar.gz
	tar -zxvf glpi-seasonality-1.2.0.tar.gz
	mv seasonality /var/www/html/glpi/plugins/seasonality

	#
	# Baixando SimCard
	# Add simcards management, link them to computers and phones

	wget https://github.com/pluginsGLPI/simcard/releases/download/1.4.2/glpi-simcard-1.4.2.tar.gz
	tar -zxvf glpi-simcard-1.4.2.tar.gz
	mv simcard /var/www/html/glpi/plugins/simcard

	#
	# Baixando Data Injection
	# It allows to create models of injection for a future re-use. It's been created in order to:
	# - import data coming from others asset management softwares
	# - inject electronic delivery forms
	# Data to be imported using the plugains are:
	# - inventory data (except softwares and licenses)
	# - management data (contract, contact, supplier)
	# - configuration data (user, group, entity)

	wget https://github.com/pluginsGLPI/datainjection/releases/download/2.4.2/glpi-datainjection-2.4.2.tar.gz
	tar -zxvf glpi-datainjection-2.4.2.tar.gz
	mv datainjection /var/www/html/glpi/plugins/datainjection

	#
	# Baixando Generic Objects Management
	# This plugin allows you to do the inventory of new item types without having to code, it allows you to create those new item types, it 	# allows type creation, manages available fields. Has full integration with the software (Helpdesk, loans, templates, etc.) 
	# 	It has support  and connectivity for and with the File Injection plugin

	wget https://github.com/pluginsGLPI/genericobject/releases/download/2.4.0/glpi-genericobject-2.4.0.tar.gz
	tar -zxvf glpi-genericobject-2.4.0.tar.gz
	mv genericobject /var/www/html/glpi/plugins/genericobject

	#
	# Baixando Appliances Inventory
	# This plugin enables you to create appliance (several elements constituting a unit).
	# -Appliances creation (composed by various inventory item)
	# -Direct management from items
	# -Integrated with Helpdesk
	# NB : This plugin can be integrated in environment plugin and be used with archires plugin.

	wget https://forge.glpi-project.org/attachments/download/2168/glpi-appliances-2.2.1.tar.gz
	tar -zxvf glpi-appliances-2.2.1.tar.gz
	mv appliances /var/www/html/glpi/plugins/appliances

	#
	# Baixando Certificates Inventory
	# This plugin enables you to manage your certificates into your network and associate them with elements of the inventory.
	# A mailing system allow to verify already expired or soon expired certificates.
	# - Can be used with helpdesk
	# - Can be integrated into Environment plugin.
	# wget https://github.com/InfotelGLPI/certificates/releases/download/2.2.0/glpi-certificates-2.2.0.tar.gz

 	wget https://github.com/InfotelGLPI/certificates/releases/download/2.2.1/glpi-certificates-2.2.1.tar.gz
	tar -zxvf glpi-certificates-2.2.1.tar.gz
	mv certificates /var/www/html/glpi/plugins/certificates

	#
	# Baixando Databases Inventory
	# This plugin enables you to manage the databases of your network and associate them with elements of the inventory.
	# - Instances inventory
	# - Scripts inventory.
	# - Can be used with helpdesk
	# -Can be integrated into Environment plugin.

	wget https://github.com/InfotelGLPI/databases/releases/download/1.9.0/glpi-databases-1.9.0.tar.gz
	tar -zxvf glpi-databases-1.9.0.tar.gz
	mv databases /var/www/html/glpi/plugins/databases

	#
	# Baixando Domains Inventory
	# This plugin enables you to manage the domain names of your network and associate them with elements of the inventory.
	# A mailing system allow to verify already expired or soon expired domain names.
	# -Can be used with helpdesk
	# -Can be integrated into Environment plugin.
	# wget https://github.com/InfotelGLPI/domains/releases/download/1.8.0/glpi-domains-1.8.0.tar.gz

	wget https://github.com/InfotelGLPI/domains/releases/download/1.8.1/glpi-domains-1.8.1.tar.gz
	tar -zxvf glpi-domains-1.8.1.tar.gz
	mv domains /var/www/html/glpi/plugins/domains

	#
	# Baixando Human Resources Management
	# This plugin allows you to manage human resources to properly manage the allocation of material.
	# - Management of various modes (private, public, SSII)
	# Features :
	# - Checklists management
	# - Tasks management
	# - Notifications system
	# - Can be used with helpdesk
	# - Can be used with badges plugin
	# - Can be used with PDF plugin
	# wget https://github.com/InfotelGLPI/resources/releases/download/2.3.0/glpi-resources-2.3.0.tar.gz

	wget https://github.com/InfotelGLPI/resources/releases/download/2.3.1/glpi-resources-2.3.1.tar.gz
	tar -zxvf glpi-resources-2.3.1.tar.gz
	mv resources /var/www/html/glpi/plugins/resources

	#
	# Baixando Web Applications Inventory
	# This plugin allows you to list your Web applications of your network and associate them with elements of the inventory.
	# - Can be used with helpdesk,
	# - Can be used with PDF plugin,
	# - Can be used with Environment plugin
	# wget https://github.com/InfotelGLPI/webapplications/releases/download/2.3.0/glpi-webapplications-2.3.0.tar.gz

 	wget https://github.com/InfotelGLPI/webapplications/releases/download/2.3.1/glpi-webapplications-2.3.1.tar.gz
	tar -zxvf glpi-webapplications-2.3.1.tar.gz
	mv webapplications /var/www/html/glpi/plugins/webapplications

	#
	# Baixando Order Management
	# This plugin allows you to manage order management within GLPI :
	#	- Products references management
	#	- Order management (with approval workflow)
	#	- Budgets management

	wget https://github.com/pluginsGLPI/order/releases/download/1.9.6/glpi-order-1.9.6.tar.bz2
	tar -jxvf glpi-order-1.9.6.tar.bz2
	mv order /var/www/html/glpi/plugins/order

	#
	# Baixando Behaviors
	# This plugin allows you to add optional behaviors to GLPI.
	# - mandatory fields
	# - requester's group
	# - ticket's number format
	# - etc

	wget https://forge.glpi-project.org/attachments/download/2178/glpi-behaviors-1.3.tar.gz
	tar -zxvf glpi-behaviors-1.3.tar.gz
	mv behaviors /var/www/html/glpi/plugins/behaviors

	#
	# Baixando Escalade
	# This plugin simplifies the ticket escalation to different groups
	# It adds the following features :
	#
	#    Display a visual history of the assignement groups on a ticket.
	#    Rapid escalation to a group present in history.
	#    Assign initiator group when ticket solution provided.
	#    provide automatic assignment of tickets on ticket category change.
	#    Fast cloning of ticket.
	#    Closing cloned tickets simultaneously.
	#    Take the first or last group of technician (on ticket modification).	
	#    New button for rapid self-assignment of a ticket.

	wget https://github.com/pluginsGLPI/escalade/releases/download/2.1.0/glpi-escalade-2.1.0.tar.gz
	tar -zxvf glpi-escalade-2.1.0.tar.gz
	mv escalade /var/www/html/glpi/plugins/escalade

	#
	# Baixando Historical purge
	# This plugin enables historical purge

	wget https://github.com/pluginsGLPI/purgelogs/releases/download/1.2.2/glpi-purgelogs-1.2.2.tar.gz
	tar -zxvf glpi-purgelogs-1.2.2.tar.gz
	mv purgelogs /var/www/html/glpi/plugins/purgelogs

	#
	# Baixando Financial Reports
	# Financial report : Asset situation. This plugin allows you to generate a financial report (asset situation) for a given date.
	# - Export Csv, Pdf

	wget https://github.com/InfotelGLPI/financialreports/releases/download/2.3.0/glpi-financialreports-2.3.0.tar.gz
	tar -zxvf glpi-financialreports-2.3.0.tar.gz
	mv financialreports /var/www/html/glpi/plugins/financialreports

	#
	# Baixando Accounts Inventory
	# Manage accounts (login / password).
	# This plugin enables you to manage the accounts of your network and associate them with elements of the inventory.
	# The accounts are crypted in database with hash and crypting key.
	# A mailing system allow to verify expired accounts.
	
	wget https://github.com/InfotelGLPI/accounts/releases/download/2.2.0/glpi-accounts-2.2.0.tar.gz
	tar -zxvf glpi-accounts-2.2.0.tar.gz
	mv  accounts /var/www/html/glpi/plugins/accounts

	#
	# Baixando More Reporting
	# Add (and develop) new graphical reports for glpi.
	# 
	# This plugins embed a set of new statistics reports :
	# 
	#     Helpdesk
	#         Backlog
	#         Ticket age
	#         Tickets per group or technician
	#         Top categories or requester groups
	#         Number of group changes
	#         5 SLA reports
	# 
	#     Inventory
	#         Os versions and distributions
	#         Top manufacturers
	#         Top types (server, laptop, ...)
	#         Top status
	#         Age of computers
	#         FusionInventory agents
	# 
	#     Logs distribution
	# 
	# You can also develop new report with the framework of plugin.
	# See documentation : https://github.com/PluginsGLPI/mreporting/wiki


	wget https://github.com/pluginsGLPI/mreporting/releases/download/1.3.1/glpi-mreporting-1.3.1.tar.bz2
	tar -jxvf glpi-mreporting-1.3.1.tar.bz2
	mv mreporting /var/www/html/glpi/plugins/


	#
	# Baixando PDF
	# 
	# This plugin allow you to select and export informations of an equipment to PDF file.
	# - equipment types from GLPI
	# - equipment types from some plugins
	# - additional data from some plugins
	# - one or many object(s) in a file

	wget https://forge.glpi-project.org/attachments/download/2171/glpi-pdf-1.1.tar.gz
	tar -zxvf glpi-pdf-1.1.tar.gz
	mv pdf /var/www/html/glpi/plugins/

	#
	# Baixando Network Equipment Backup
	# 
	# This plugin allows you to back up the configuration of the network devices on TFTP server.

	wget https://github.com/jsamaniegog/nebackup/archive/2.1.2.zip
	unzip 2.1.2.zip
	mv nebackup-2.1.2 /var/www/html/glpi/plugins/nebackup

	#
	# Baixando Auto Login
	# 
	# This plugin add support to "Remember me" function in GLPI and skip the login page if you are already authenticated
	# Go to Configuration > General > Auto Login to configure remember time and default checkbox state

	wget https://github.com/edgardmessias/autologin/releases/download/2.1.1/autologin.zip
	unzip autologin.zip
	mv autologin /var/www/html/glpi/plugins/

	#
	# Baixando Father
	# 
	# Adicionando um campo para bilhetes GLPI (estendendo CommonDBTM).
	#     O campo "pai" é visível e editável no cabeçalho do objeto (abaixo do título).
	#     O campo "pai" pode ser pesquisado e exibido na lista de objetos

	wget https://github.com/Probesys/glpi-plugins-father/archive/v1.0.1.zip
	unzip v1.0.1.zip
	mv glpi-plugins-father-1.0.1 /var/www/html/glpi/plugins/father

	#
	# Baixando Browser Notification 
	# 
	# This plugin allow your browser to show notifications for GLPI

	wget https://github.com/edgardmessias/browsernotification/releases/download/1.1.8/browsernotification.zip
	unzip browsernotification.zip
	mv browsernotification /var/www/html/glpi/plugins/


	#
	# Baixando FusionInventory
	# FusionInventory is a free and open source project providing hardware, software inventory, software deployment and network 
	#	discovery to the IT asset management and helpdesk software called GLPI.
	# "FusionInventory for GLPI" is a collection of plugins communicating with some agents (FusionInventory-Agent), deployed on computers
	#
	#    FusionInventory Core: provides core functionnalities:
	#        Communication with inventory and network discovery agents.
	#        Tasks management and scheduling.
	#        Wake on LAN.
	#        Centralized rules for assets import in GLPI.
	#        Unknown devices management (temporary zone, in GLPI, before real asset management).
	#
	#    FusionInventory Inventory:
	#        Local inventory for computers (hardware, software, antivirus).
	#        Handle and update computers already in GLPI.
	#
	#    FusionInventory SNMP:
	#        Network discovery, unknown devices management (using FusionInventory core plugin).
	#        Remote network devices and printers (thanks to the SNMP protocol).	
	#        Get network port informations, VLANs, link between switchs network ports and assets already in GLPI (computers, network printers, 		
	#		network devices, etc.).
	#        Change history and reports for each network port.
	#        Printers cartridges' ink levels, daily page counters and reports.

	wget "https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi9.1%2B1.1/fusioninventory-for-glpi_9.1.1.1.tar.gz"
	tar -zxvf "fusioninventory-for-glpi_9.1.1.1.tar.gz"	
	mv fusioninventory /var/www/html/glpi/plugins/fusioninventory

######################################################################################################################################################	

	# Baixando o webservices

	wget https://forge.glpi-project.org/attachments/download/2186/glpi-webservices-1.7.0.tar.gz
	tar -zxvf glpi-webservices-1.7.0.tar.gz
	mv webservices /var/www/html/glpi/plugins/webservices

	# Baixando o MoreLDAP

	wget https://github.com/pluginsGLPI/moreldap/releases/download/0.2.3/glpi-moreldap-0.2.3.tar.bz2
	tar -jxvf glpi-moreldap-0.2.3.tar.bz2
	mv moreldap /var/www/html/glpi/plugins/moreldap

	# Baixando o HideFields

	wget https://github.com/tomolimo/hidefields/archive/1.0.0.tar.gz
	tar -zxvf hidefields-1.0.0.tar.gz
	mv hidefields-1.0.0 /var/www/html/glpi/plugins/hidefields

	# Baixando o FormValidation

	wget https://github.com/tomolimo/formvalidation/releases/download/0.1.7/formvalidation-0.1.7.zip
	unzip formvalidation-0.1.7.zip
	mv formvalidation /var/www/html/glpi/plugins/formvalidation

	
	# Baixando o IP Reports

	wget https://github.com/pluginsGLPI/addressing/releases/download/2.5.0/glpi-addressing-2.5.0.tar.gz
	tar -zxvf glpi-addressing-2.5.0.tar.gz
	mv addressing /var/www/html/glpi/plugins/addressing
	
	
	# Barscode nao possui compatibilidade

	
	#  Baixando o timezones

	wget https://github.com/tomolimo/timezones/releases/download/2.1.2/timezones-2.1.2.zip
	unzip timezones-2.1.2.zip
	mv timezones /var/www/html/glpi/plugins/timezones        

	
	# Monitoring nao possui compatibilidade
	
	
	# Baixando o Cartography

	wget https://github.com/InfotelGLPI/positions/releases/download/4.3.1/glpi-positions-4.3.1.tar.gz
	tar -zxvf glpi-positions-4.3.1.tar.gz
	mv positions /var/www/html/glpi/plugins/positions

	
	# Baixando o Inventory Number Generation

	wget https://github.com/pluginsGLPI/geninventorynumber/releases/download/9.1%2B1.0/glpi-geninventorynumber-9.1.1.0.tar.gz
	tar -zxvf glpi-geninventorynumber-9.1.1.0.tar.gz
	mv geninventorynumber /var/www/html/glpi/plugins/geninventorynumber

	
	# Connections nao possui compatibilidade
	# Renamer nao possui compatibilidade

	
	# Baixando Ticket Cleaner

	wget https://github.com/tomolimo/ticketcleaner/releases/download/2.0.4/ticketcleaner-2.0.4.zip
	unzip ticketcleaner-2.0.4.zip
	mv ticketcleaner /var/www/html/glpi/plugins/ticketcleaner

	# Escalation nao possui compatibilidade

	# Baixando o News
	
	wget https://github.com/pluginsGLPI/news/releases/download/1.3.2.5/glpi-news-1.3.2.5.tar.bz2
	tar -jxvf glpi-news-1.3.2.5.tar.bz2
	mv news /var/www/html/glpi/plugins/news

	# Baixando o ItilCategory Groups
	wget https://github.com/pluginsGLPI/itilcategorygroups/releases/download/2.0.1/glpi-itilcategorygroups-2.0.1.tar.bz2
	tar -jxvf glpi-itilcategorygroups-2.0.1.tar.bz2
	mv itilcategorygroups /var/www/html/glpi/plugins/itilcategorygroups


	# Baixando o Consumables
	wget https://github.com/InfotelGLPI/consumables/releases/download/1.2.1/glpi-consumables-1.2.1.tar.gz
	tar -zxvf glpi-consumables-1.2.1.tar.gz
	mv consumables /var/www/html/glpi/plugins/consumables

	
	# Baixando o PrinterCounters
	wget https://github.com/InfotelGLPI/printercounters/releases/download/1.3.0/glpi-printercounters-1.3.0.tar.gz
	tar -zxvf glpi-printercounters-1.3.0.tar.gz
	mv printercounters /var/www/html/glpi/plugins/printercounters

	
	# Baixando Timelineticket
	wget https://github.com/pluginsGLPI/timelineticket/releases/download/0.90%2B1.0/glpi-timelineticket-0.90.1.0.tar.gz
	tar -zxvf glpi-timelineticket-0.90.1.0.tar.gz
	mv timelineticket /var/www/html/glpi/plugins/timelineticket
	

	# Baixando FormCreator
	wget https://github.com/pluginsGLPI/formcreator/releases/download/2.5.1/glpi-formcreator-2.5.1.tar.bz2
	tar -jxvf glpi-formcreator-2.5.1.tar.bz2
	mv formcreator /var/www/html/glpi/plugins/formcreator	

	# Baixando MyAssets
	wget https://github.com/deadmanIsARabbit/myAssets/releases/download/stable/myAssets_v1.0.zip
	unzip myAssets_v1.0.zip
	mv myAssets /var/www/html/glpi/plugins/myAssets

	# Baixando o Modifications
	wget https://sourceforge.net/projects/glpithemes/files/PLUGIN/Plugin_mod-9.1.4-1.1.0.tar.gz/download
	tar -zxvf Plugin_mod-9.1.4-1.1.0.tar.gz
	mv mod /var/www/html/glpi/plugins/mod

	# ShowLoading nao possui compatibilidade

#######################################################################################################################################################

	# Adequando Apache
	
	echo -e "<Directory \"/var/www/html/glpi\">\n\tAllowOverride All\n</Directory>" > /etc/apache2/conf-available/glpi.conf

	a2enconf glpi.conf

	# Reiniciando apache2

	chmod 775 /var/www/html/glpi -Rf
	chown www-data:www-data /var/www/html/glpi -Rf
	service apache2 restart


}


DB_CREATE ()
{


clear 

echo "Making SQL.."
echo "Creating Data Base for systems.."
sleep 1


test_connection=1

while [ $test_connection != 0 ]
do

rootPWD_SQL=$(whiptail --title "${TITULO}" --backtitle "${BANNER}" --passwordbox "Enter the root user password for the SQL Server" --fb 10 50 3>&1 1>&2 2>&3) 

mysql -uroot -p$rootPWD_SQL -e "" 2> /dev/null

test_connection=$?

	if [ $test_connection != 0 ]
	then
whiptail --title "${TITULO}" --backtitle "${BANNER}" --msgbox "
The root user password entered is not valid. Try again!
" --fb 0 0 0
	fi
done

if [ $zabbixTag -eq 1 ]
then

zabbixPWD_SQL1=0
zabbixPWD_SQL2=1

while [ $zabbixPWD_SQL1 != $zabbixPWD_SQL2 ]
do

	zabbixPWD_SQL1=$(whiptail --title "${TITULO}" --backtitle "${BANNER}" --passwordbox "Step 4 - Enter the user's password zabbix to the Database." --fb 10 50 3>&1 1>&2 2>&3) 

	zabbixPWD_SQL2=$(whiptail --title "${TITULO}" --backtitle "${BANNER}" --passwordbox "Step 4 - Confirm password zabbix user to the Database." --fb 10 50 3>&1 1>&2 2>&3)
	
	if [ $zabbixPWD_SQL1 != $zabbixPWD_SQL2 ]
	then
whiptail --title "${TITULO}" --backtitle "${BANNER}" --msgbox "
Step 4 - Error! Informed passwords do not match. Try again.
" --fb 0 0 0

	fi
done

	# Criando a base de dados zabbix
	echo "Creating zabbix database..."
	mysql -u root -p$rootPWD_SQL -e "create database zabbix character set utf8";
	echo "Creating zabbix user at MariaDB Database..."
	mysql -u root -p$rootPWD_SQL -e "create user 'zabbix'@'localhost' identified by '$zabbixPWD_SQL1'";
	echo "Making zabbix user the owner to glpi database..."
	mysql -u root -p$rootPWD_SQL -e "grant all on zabbix.* to zabbix with grant option";
	sleep 2

	# Configurando /etc/zabbix/zabbix_server.conf

	sed -i 's/# DBPassword=/DBPassword='$zabbixPWD_SQL1'/' /etc/zabbix/zabbix_server.conf
	sed -i 's/# FpingLocation=\/usr\/sbin\/fping/FpingLocation=\/usr\/bin\/fping/' /etc/zabbix/zabbix_server.conf

	# Avisar que a base está sendo populada....
	# Popular base zabbix

	cd database/mysql/
	echo "Creating Zabbix Schema at MariaDB..."
	mysql -uroot -p$rootPWD_SQL zabbix < schema.sql
	echo "Importing zabbix images to MariaDB..."
	mysql -uroot -p$rootPWD_SQL zabbix < images.sql
	echo "Importing all Zabbix datas to MariaDB..."
	mysql -uroot -p$rootPWD_SQL zabbix < data.sql
	sleep 1

	# Inicializando os serviços 
	
	echo "Now re-initiate services Zabbix Server and Agent..."
	service zabbix-agent start
	service zabbix-server start

fi

if [ $glpiTag -eq 1 ]
then

glpiPWD_SQL1=0
glpiPWD_SQL2=1

while [ $glpiPWD_SQL1 != $glpiPWD_SQL2 ]
do

	glpiPWD_SQL1=$(whiptail --title "${TITULO}" --backtitle "${BANNER}" --passwordbox "Step 4 - Enter the user's password glpi to the Database." --fb 10 50 3>&1 1>&2 2>&3) 

	glpiPWD_SQL2=$(whiptail --title "${TITULO}" --backtitle "${BANNER}" --passwordbox "Step 4 - Confirm password glpi user to the Database." --fb 10 50 3>&1 1>&2 2>&3)
	
	if [ $glpiPWD_SQL1 != $glpiPWD_SQL2 ]
	then
whiptail --title "${TITULO}" --backtitle "${BANNER}" --msgbox "
Step 4 - Error! Informed passwords do not match. Try again.
" --fb 0 0 0

	fi
done

	# Criando a base de dados glpi
	echo "Creating glpi database..."
	mysql -u root -p$rootPWD_SQL -e "create database glpi character set utf8";
	echo "Creating glpi user at MariaDB Database..."
	mysql -u root -p$rootPWD_SQL -e "create user 'glpi'@'localhost' identified by '$glpiPWD_SQL1'";
	echo "Making glpi user the owner to glpi database..."
	mysql -u root -p$rootPWD_SQL -e "grant all on glpi.* to glpi with grant option";
	sleep 2

fi

}

INTEGRA ()
{

clear 

cd /tmp 

echo "Detecting externalScripts directory..."
externalScriptsDir=$(find / -iname externalscripts)
echo "ok..."
echo "Detecting frontend directory..."
zabbixFrontend=$(find / -name zabbix.php | sed 's/zabbix.php//')
echo "ok..."

echo "Making Systems Integration with Verdanatech iGZ..."
sleep 1

git clone $verdanatechGIT

chmod 775 igz/*

sed -i 's/ZABBIX_FRONTEND_DIR\//'$(echo $zabbixFrontend | sed 's/\//\\\//g')'/' igz/igz.php
sed -i 's/ZABBIX_EXTERNALSCRIPT_DIR/'$(echo $externalScriptsDir | sed 's/\//\\\//g')'/' igz/verdanatech_iGZ.php

mv igz/igz.php $externalScriptsDir/

mv igz/verdanatech_iGZ.php $zabbixFrontend/

mv igz/verdanatech_iGZ_menu.inc.php $zabbixFrontend/include/menu.inc.php

mv igz/verdanatech_processa_iGZ.php $zabbixFrontend/

touch $zabbixFrontend/conf/igz.conf.php

chown www-data $zabbixFrontend/conf/igz.conf.php
chmod +x $zabbixFrontend/conf/igz.conf.php

mv zabbix-glpi/*zabbix* $externalScriptsDir

chmod 775 $externalScriptsDir -Rf

chown zabbix:zabbix $externalScriptsDir -Rf

}

END_MSG ()
{
clear

whiptail --title "${TITULO}" --backtitle "${BANNER}" --msgbox "
Copyright:
- Verdanatech Solucoes em TI, $versionDate
Thank you for using our script. We are at your disposal to contact.
$devMail
PATHS: 
If you made installations, try to access 
GLPI, http://$serverAddress/glpi
Zabbix, try http://$serverAddress/zabbix
iGZ conf, zabbix menu (Administration > Verdanatech iGZ )
"  --fb 0 0 0

}



# Script start

clear

[ ! -e /usr/bin/whiptail ] && { INSTALA_WHIPTAIL; }

MAIN_MENU

while true
do
case $menu01Option in

	1)
		# instalação completa
		REQ_TO_USE
		SET_REPOS
		GLPI_DEPS
		GLPI_INSTALL
		ZABBIX_DEPS
		ZABBIX_INSTALL
		DB_CREATE
		INTEGRA
		END_MSG
		kill $$
	;;
	
	2)
		# Instala apenas GLPI
		REQ_TO_USE
		SET_REPOS
		GLPI_DEPS
		GLPI_INSTALL
		DB_CREATE
		END_MSG
		kill $$
	;;
		

	3)
		# Zabbix + iGZ
		REQ_TO_USE
		SET_REPOS
		ZABBIX_DEPS
		ZABBIX_INSTALL
		DB_CREATE
		INTEGRA
		END_MSG
		kill $$
	;;
	
	4)
		# Apenas iGZ
		INTEGRA
		END_MSG
		kill $$
	;;
	
	5)
		# Sobre
		ABOUT
		MAIN_MENU
	;;
	
	6)
		# Sair
		END_MSG
		kill $$
	;;

esac
done
