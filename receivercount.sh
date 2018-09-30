#!/bin/bash

EMS_BIN=/home/tibadmin/ems/bin
SCRIPT_DIR=/home/tibadmin/receivercount
cmd="info"
queuecmd1="show queue NAinterfaceZincommon.Logging.1.0.dev"
queuecmd2="show queue tst.q.route.naia.ceai.athena.geel"


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


echo $cmd > $SCRIPT_DIR/inputcmd.lst
for EMSInstanceName in `cat $SCRIPT_DIR/emsserver.lst`
do
$EMS_BIN/tibemsadmin64 -server $EMSInstanceName -user admin -password 'Yt9!sw8q' -script $SCRIPT_DIR/inputcmd.lst > $SCRIPT_DIR/EMSInstanceOut.txt

state=`cat EMSInstanceOut.txt | grep State | cut -d':' -f2 | tr -d ' '`

if [ "$state" == "active" ]
then

for (( i=1; i<=2; i++ ))
do

eval echo \$queuecmd$i > $SCRIPT_DIR/inputcmd.lst
$EMS_BIN/tibemsadmin64 -server $EMSInstanceName -user admin -password 'Yt9!sw8q' -script $SCRIPT_DIR/inputcmd.lst > $SCRIPT_DIR/EMSInstanceOut.txt

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

echo "</table>" >> $SCRIPT_DIR/emsout.html
echo "</body>" >> $SCRIPT_DIR/emsout.html
echo "</html>" >> $SCRIPT_DIR/emsout.html

cat $SCRIPT_DIR/emsout.html | mail -s "$(echo -e "Receiver Count Report\nContent-Type: text/html; charset=us-ascii\nContent-Transfer-Encoding: 7bit")" satyaprakash.prasad@accenture.com Satya-Prakash.Prasad-ext@sanofi.com

rm $SCRIPT_DIR/inputcmd.lst
rm $SCRIPT_DIR/emsout.html
rm $SCRIPT_DIR/EMSInstanceOut.txt
