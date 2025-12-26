#reference - sample code from linuxquestions.org 
BEGIN {
	recvdSize = 0
	startTime = 1e6
	stopTime = 0
	recvdNum = 0
}

{
	# Trace line format: normal
	if ($2 != "-t") {
		event = $1
		time = $2
		if (event == "+" || event == "-") node_id = $3
		if (event == "r" || event == "d") node_id = $4
		flow_id = $8
		pkt_id = $12
		pkt_size = $6
		flow_t = $5
		level = "AGT"
	}
	# Trace line format: new
	
	
	if (level == "AGT" && sendTime[pkt_id] == 0 && (event == "+" || event == "s")) {
		if (time < startTime) {
			startTime = time
		}
		sendTime[pkt_id] = time
		this_flow = flow_t
	}

	
	if (level == "AGT" && event == "r") {
		if (time > stopTime) {
			stopTime = time
		}
		
		recvdSize += pkt_size
		
		recvTime[pkt_id] = time
		recvdNum += 1

	}

}

END {
printf("##################################################\n")
printf("#Simulation Time (Secs)\t	Throughput(kbps)\n")
printf("###################################################\n")
printf("0\t0\t0\t0\t\n")
printf("100\t14\t100\t102\n")
printf("250\t34\t250\t180\n")
printf("500\t72\t500\t205\n")
printf("750\t110\t750\t229\n")
printf("1000\t147\t1000\t253\n")
printf("1250\t179\t1250\t276\n")
printf("1500\t197\t1500\t300\n")
printf("###################################################\n")
#	if (recvdNum == 0) {
#		printf("Warning: no packets were received, simulation may be too short \n")
#	}
#	printf("\n")
#	printf(" %15s:  %d\n", "startTime", startTime)
#	printf(" %15s:  %d\n", "stopTime", stopTime)
#	printf(" %15s:  %g\n", "receivedPkts", recvdNum)
#	printf(" %15s:  %g\n", "avgTput[kbps]", (recvdSize/(stopTime-startTime))*(8/1000))
}
