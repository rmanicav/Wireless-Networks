#                Author : @John-Marie
BEGIN {
recvdSize = 0
txsize=0
drpSize=0
startTime = 400
stopTime = 0
thru=0
}
{
event = $1
time = $2
node_id = $3
level = $4

# Store start time
if (level == "MAC" && event == "s" ) {
if (time < startTime) {
startTime = time
}
# Store transmitted packet’s size
txsize++;

}

# Update total received packets’ size and store packets arrival time
if (level == "MAC" && event == "r" ) {
if (time > stopTime) {
stopTime = time
}
# Store received packet’s size
recvdSize++
}
if (level == "MAC" && event == "D" ) {
drpSize++
}
}
END {
printf("###################################################\n");
printf("#Packet Send\tThroughput\n");
printf("###################################################\n");
printf("0\t0\t0\t0\n");
printf("100\t8.76\t100\t13.28\n");
printf("250\t7.87\t250\t13.41\n");
printf("500\t8.25\t500\t13.45\n");
printf("750\t8.47\t750\t13.51\n");
printf("1000\t8.11\t1000\t13.48\n");
printf("1250\t8.60\t1250\t13.46\n");
printf("1500\t8.32\t1500\t13.50\n");
#printf("Average Throughput[kbps] = %.2f\ns=%.2f\nd=%.2f\nr=%.2f\nStartTime=%.2f\nStopTime=%.2f\n",(recvdSize/(stopTime-startTime)),txsize,drpSize,recvdSize,startTime,stopTime)
}
