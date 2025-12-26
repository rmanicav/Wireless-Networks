# packet loss
# Author - Rajesh Manicavasagam
# Reference - https://ns2blogger.blogspot.com/p/plotting-results-on-xgraph.html
BEGIN {
	
	
}	
{
#attack mode
snd_pkt[0]=250
rec_pkt[0]=98
snd_pkt[1]=500
rec_pkt[1]=196
snd_pkt[2]=600
rec_pkt[2]=255
snd_pkt[3]=700
rec_pkt[3]=327
snd_pkt[4]=800
rec_pkt[4]=355
snd_pkt[5]=1000
rec_pkt[5]=460
snd_pkt[6]=1500
rec_pkt[6]=656

#normal mode
s_pkt[0]=250
r_pkt[0]=247
s_pkt[1]=500
r_pkt[1]=496
s_pkt[2]=600
r_pkt[2]=588
s_pkt[3]=700
r_pkt[3]=689
s_pkt[4]=800
r_pkt[4]=790
s_pkt[5]=1000
r_pkt[5]=968
s_pkt[6]=1500
r_pkt[6]=1476

}
END {

printf("###################################################\n");
printf("#Attacker Packet Send\tPacket Loss\tPacket Send\tPacket Loss\n");
printf("###################################################\n");
printf("0\t0\t0\t0\n");
 for (i=0;i<7;i++)
 {
	printf("%d\t%d\t%d\t%d\n",snd_pkt[i],(rec_pkt[i]/snd_pkt[i]) *100,s_pkt[i],(r_pkt[i]/s_pkt[i]) * 100);
  
 }
 
 }

