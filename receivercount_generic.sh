#!/bin/bash

EMS_BIN=/home/tibadmin/ems/bin
SCRIPT_DIR=`pwd`
## data.list should contain fields seperated by "|". 1st and 2nd field for EMS FT instance(if there is only one instance then 2nd field should contain space)
## 3rd field is for ems user and 4th filed for ems password
## from 5th field queue names will be added
DATA_FILE=$SCRIPT_DIR/data.lst

######################################################### HTML START ########################################################
echo "<!DOCTYPE html>
<html>
<br>
<h1 align=center ><u>Queue Details</u></h1>
<br>
<head>
<style>
table,th,td
{
border:1px solid black;
border-collapse:collapse;
}
th,td
{
padding:5px;
}
</style>
</head>
<body>
<table style=width:1200px>
<tr>
<th style='width: 150px' bgcolor=8a8a5c><font face=Times New Roman size=5>EMS Server</font></th>
<th style='width: 150px' bgcolor=8a8a5c><font face=Times New Roman size=5>Queue Name</font></th>
<th style='width: 150px' bgcolor=8a8a5c><font face=Times New Roman size=5>Pending Messages</font></th>
<th style='width: 150px' bgcolor=8a8a5c><font face=Times New Roman size=5>Receiver Count</font></th>
</tr>" > $SCRIPT_DIR/emsout.html

################################################# EMS Execution Start ######################################################

cmd="info"
lines=`wc -l $DATA_FILE | cut -d' ' -f1`

for (( i=1; i<=$lines; i++ ))
do

echo $cmd > $SCRIPT_DIR/inputcmd.lst

for (( instance=1; instance<=2; instance++ ))
do

emsusername=`cat $DATA_FILE | sed -n "$i p" | cut -d'|' -f3`
emspassword=`cat $DATA_FILE | sed -n "$i p" | cut -d'|' -f4`
EMSInstanceName=`cat $DATA_FILE | sed -n "$i p" | cut -d'|' -f$instance`

$EMS_BIN/tibemsadmin64 -server $EMSInstanceName -user $emsusername -password $emspassword -script $SCRIPT_DIR/inputcmd.lst > $SCRIPT_DIR/EMSInstanceOut.txt

state=`cat EMSInstanceOut.txt | grep State | cut -d':' -f2 | tr -d ' '`

if [ "$state" == "active" ]
then

columns=`cat $DATA_FILE | awk -F'|' '{print NF}' | sed -n "$i p"`
for (( j=5; j<=$columns; j++ ))
do
queuename=`cat $DATA_FILE | sed -n "$i p" | cut -d'|' -f$j`
echo "show queue $queuename" > $SCRIPT_DIR/inputcmd.lst

$EMS_BIN/tibemsadmin64 -server $EMSInstanceName -user $emsusername -password $emspassword -script $SCRIPT_DIR/inputcmd.lst > $SCRIPT_DIR/EMSInstanceOut.txt

queue=`cat $SCRIPT_DIR/EMSInstanceOut.txt | grep Queue | cut -d':' -f2 | tr -d ' '`
pendingmgs=`cat $SCRIPT_DIR/EMSInstanceOut.txt | grep "Pending Msgs:" | cut -d':' -f2 | tr -d ' '`
receiverCount=`cat $SCRIPT_DIR/EMSInstanceOut.txt | grep "Receivers" | cut -d':' -f2 | tr -d ' '`

echo "<tr>" >> $SCRIPT_DIR/emsout.html
echo "<td align=center><font face=Calibri>$EMSInstanceName</font></td>" >> $SCRIPT_DIR/emsout.html
echo "<td align=center><font face=Calibri>$queue</font></td>" >> $SCRIPT_DIR/emsout.html
echo "<td align=center><font face=Calibri>$pendingmgs</font></td>" >> $SCRIPT_DIR/emsout.html

if [ "$receiverCount" -eq 0 ];then
echo "<td bgcolor=ff1a1a align=center><font face=Calibri>$receiverCount</font></td>" >> $SCRIPT_DIR/emsout.html
else
echo "<td bgcolor=00ff00 align=center><font face=Calibri>$receiverCount</font></td>" >> $SCRIPT_DIR/emsout.html
fi

echo "</tr>" >> $SCRIPT_DIR/emsout.html
done
fi
done
done

##################################################### EMS Execution End ####################################################

echo "</table>" >> $SCRIPT_DIR/emsout.html
echo "</body>" >> $SCRIPT_DIR/emsout.html
echo "</html>" >> $SCRIPT_DIR/emsout.html

######################################################### HTML End #########################################################

cat $SCRIPT_DIR/emsout.html | mail -s "$(echo -e "Receiver Count Report\nContent-Type: text/html; charset=us-ascii\nContent-Transfer-Encoding: 7bit")" -r tibadmin@tibserver.sanofi.com satyaprakash.prasad@accenture.com Satya-Prakash.Prasad-ext@sanofi.com

