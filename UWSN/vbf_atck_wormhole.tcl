#reference www.nsnam.com 
set opt(chan)		Channel/UnderwaterChannel
set opt(prop)		Propagation/UnderwaterPropagation
set opt(netif)		Phy/UnderwaterPhy
set opt(mac)		Mac/UnderwaterMac/BroadcastMac
set opt(ifq)		Queue/DropTail/PriQueue
set opt(ll)		LL
set opt(energy)         EnergyModel
set opt(txpower)        2.0
set opt(rxpower)        0.75
set opt(initialenergy)  10000
set opt(idlepower)      0.008
set opt(ant)            Antenna/OmniAntenna
set opt(filters)        GradientFilter    ;# options can be one or more of 
                                ;# TPP/OPP/Gear/Rmst/SourceRoute/Log/TagFilter
set opt(minspeed)           0  ;#minimum speed of node
set opt(maxspeed)           3   ;#maximum speed of node
set opt(speed)              0.5  ;#speed of node
set opt(position_update_interval) 0.3  ;# the length of period to update node's position
set opt(packet_size) 100  ;#50 bytes
set opt(routing_control_packet_size) 20 ;#bytes 

set opt(ifqlen)		100	;# max queue length in if
set opt(nn)		10	;# number of nodes 
set opt(x)		1500	;# X dimension of the topography
set opt(y)	        1500;# Y dimension of the topography
set opt(z)              1500
set opt(seed)		11
set opt(stop)		250	;# simulation time
set opt(prestop)        400 ;# time to prepare to stop
set opt(tr)		"vbf_atck_wormhole.tr"	;# trace file
set opt(datafile)	"vbf_atck_wormhole.data"
set opt(nam)            "vbf_atck_wormhole.nam"  ;# nam file
set opt(adhocRouting)   Vectorbasedforward
set opt(width)           500
set opt(interval)        10.0
set opt(range)           500   ;#range of each node in meters


puts "the file name is $opt(datafile)"
puts "the sending interval is $opt(interval)"

# ==================================================================

LL set mindelay_		50us
LL set delay_			25us
LL set bandwidth_		0	;# not used

Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1

# unity gain, omni-directional antennas
# set up the antennas to be centered in the node and 1.5 meters above it
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
#Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Z_ 0.05
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

Agent/Vectorbasedforward set hop_by_hop_ 1

Mac/UnderwaterMac set bit_rate_  1.0e4 ;#10kbps
Mac/UnderwaterMac set encoding_efficiency_ 1
Mac/UnderwaterMac/BroadcastMac set packetheader_size_ 0 ;# #of bytes

# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
Phy/UnderwaterPhy set CPThresh_  10  ;#10.0
Phy/UnderwaterPhy set CSThresh_  0    ;#1.559e-11
Phy/UnderwaterPhy set RXThresh_  0    ;#3.652e-10
#Phy/WirelessPhy set Rb_ 2*1e6
Phy/UnderwaterPhy set Pt_  0.2818
Phy/UnderwaterPhy set freq_  25  ;# 25khz  
Phy/UnderwaterPhy set K_ 2.0    ;# spherical spreading

# ==================================================================
# Main Program
# Ten nodes 
# 1 sink node, 1 source node , 6 sensor nodes, 2 attacker nodes
# =================================================================

#
# Initialize Global Variables
# 
#set 
set ns_ [new Simulator]
set topo  [new Topography]

$topo load_cubicgrid $opt(x) $opt(y) $opt(z)



#$ns_ use-newtrace
set tracefd	[open $opt(tr) w]
$ns_ trace-all $tracefd

set nf [open $opt(nam) w]
$ns_ namtrace-all-wireless $nf $opt(x) $opt(y)


#ns add new trace
$ns_ use-newtrace


set data [open $opt(datafile) a]


set total_number  [expr $opt(nn)-1]
set god_ [create-god  $opt(nn)]


$ns_ at 0.0 "$god_  set_filename $opt(datafile)"
set chan_1_ [new $opt(chan)]


global defaultRNG
$defaultRNG seed $opt(seed)


$ns_ node-config -adhocRouting $opt(adhocRouting) \
		 -llType $opt(ll) \
		 -macType $opt(mac) \
		 -ifqType $opt(ifq) \
		 -ifqLen $opt(ifqlen) \
		 -antType $opt(ant) \
		 -propType $opt(prop) \
		 -phyType $opt(netif) \
		 #-channelType $opt(chan) \
		 -agentTrace ON \
                 -routerTrace ON\
                 -macTrace ON\
                 -topoInstance $topo\
                 -energyModel $opt(energy)\
                 -txPower $opt(txpower)\
                 -rxPower $opt(rxpower)\
                 -initialEnergy $opt(initialenergy)\
                 -idlePower $opt(idlepower)\
                 -channel $chan_1_
                 

puts "Width=$opt(width)"
#Set the Sink node#############################################################(300,0,0)
set node_(0) [ $ns_  node 0]

$node_(0) set sinkStatus_ 1
$god_ new_node $node_(0)
$node_(0) set X_  300
$node_(0) set Y_  0
$node_(0) set Z_  0
$node_(0) set passive 1


set rt [$node_(0) set ragent_]
$rt set control_packet_size  $opt(routing_control_packet_size)

set a_(0) [new Agent/UWSink]
$ns_ attach-agent $node_(0) $a_(0)
$a_(0) attach-vectorbasedforward $opt(width)
$a_(0) cmd set-range $opt(range) 
$a_(0) cmd set-target-x -20
$a_(0) cmd set-target-y -10
$a_(0) cmd set-target-z -10
$a_(0) cmd set-filename $opt(datafile)
$a_(0) cmd set-packetsize $opt(packet_size) ;# # of bytes


# ############################ node 1###########################(250,50,50)
set node_(1) [ $ns_  node 1]
$node_(1) set sinkStatus_ 1
$god_ new_node $node_(1)
$node_(1) set X_  250
$node_(1) set Y_  -30
$node_(1) set Z_  -30
$node_(1) set passive 1

set rt [$node_(1) set ragent_]
$rt set control_packet_size  $opt(routing_control_packet_size)
$node_(1) set max_speed $opt(maxspeed)
$node_(1) set min_speed $opt(minspeed)
$node_(1) set position_update_interval_ $opt(position_update_interval)
set a_(1) [new Agent/UWSink]
$ns_ attach-agent $node_(1) $a_(1)
$a_(1) attach-vectorbasedforward $opt(width)
$a_(1) cmd set-range $opt(range) 
$a_(1) cmd set-target-x  -20
$a_(1) cmd set-target-y  -10
$a_(1) cmd set-target-z  -10
$a_(1) cmd set-filename $opt(datafile)
$a_(1) cmd set-packetsize 100 ;# # of bytes
#$node_(1) move
############################## node 2######################################## (350,60,60)
set node_(2) [ $ns_  node 2]
$node_(2) set sinkStatus_ 1
$node_(2) random-motion 1
$node_(2) set max_speed $opt(maxspeed)
$node_(2) set min_speed $opt(minspeed)
$node_(2) set position_update_interval_ $opt(position_update_interval)

$god_ new_node $node_(2)
$node_(2) set X_  350
$node_(2) set Y_  -50
$node_(2) set Z_  -50
$node_(2) set passive 1

set rt [$node_(2) set ragent_]
$rt set control_packet_size  $opt(routing_control_packet_size)

set a_(2) [new Agent/UWSink]
$ns_ attach-agent $node_(2) $a_(2)
$a_(2) attach-vectorbasedforward $opt(width)
$a_(2) cmd set-range $opt(range) 
$a_(2) cmd set-target-x -20
$a_(2) cmd set-target-y -10
$a_(2) cmd set-target-z -10
$a_(2) cmd set-filename $opt(datafile)
$a_(2) cmd set-packetsize $opt(packet_size) ;# # of bytes
#$node_(2) move



##################node 3 (350,50,50)
set node_(3) [ $ns_  node 3]
$node_(3) set sinkStatus_ 1
$node_(3) random-motion 1

$node_(3) set max_speed $opt(maxspeed)
$node_(3) set min_speed $opt(minspeed)
$node_(3) set position_update_interval_ $opt(position_update_interval)

$god_ new_node $node_(3)
$node_(3) set X_  250
$node_(3) set Y_  -80
$node_(3) set Z_  -80
$node_(3) set passive 1

set rt [$node_(3) set ragent_]
$rt set control_packet_size  $opt(routing_control_packet_size)

set a_(3) [new Agent/UWSink]
$ns_ attach-agent $node_(3) $a_(3)
$a_(3) attach-vectorbasedforward $opt(width)
$a_(3) cmd set-range $opt(range) 
$a_(3) cmd set-target-x -20
$a_(3) cmd set-target-y -10
$a_(3) cmd set-target-z -20
$a_(3) cmd set-filename $opt(datafile)
$a_(3) cmd set-packetsize $opt(packet_size) ;# # of bytes

#######################node 4 (350,0,-135)
set node_(4) [ $ns_  node 4]
$node_(4) set sinkStatus_ 1
$node_(4) random-motion 1

$node_(4) set max_speed $opt(maxspeed)
$node_(4) set min_speed $opt(minspeed)
$node_(4) set position_update_interval_ $opt(position_update_interval)

$god_ new_node $node_(4)
$node_(4) set X_  330
$node_(4) set Y_  -105
$node_(4) set Z_  -105
$node_(4) set passive 1

set rt [$node_(4) set ragent_]
$rt set control_packet_size  $opt(routing_control_packet_size)

set a_(4) [new Agent/UWSink]
$ns_ attach-agent $node_(4) $a_(4)
$a_(4) attach-vectorbasedforward $opt(width)
$a_(4) cmd set-range $opt(range) 
$a_(4) cmd set-target-x -20
$a_(4) cmd set-target-y -10
$a_(4) cmd set-target-z -20
$a_(4) cmd set-filename $opt(datafile)
$a_(4) cmd set-packetsize $opt(packet_size) ;# # of bytes


################node 5 (250,150,150)########################
set node_(5) [ $ns_  node 5]
$node_(5) set sinkStatus_ 1
$node_(5) random-motion 1

$node_(5) set max_speed $opt(maxspeed)
$node_(5) set min_speed $opt(minspeed)
$node_(5) set position_update_interval_ $opt(position_update_interval)

$god_ new_node $node_(5)
$node_(5) set X_  250
$node_(5) set Y_  -140
$node_(5) set Z_  -140
$node_(5) set passive 1

set rt [$node_(5) set ragent_]
$rt set control_packet_size  $opt(routing_control_packet_size)

set a_(5) [new Agent/UWSink]
$ns_ attach-agent $node_(5) $a_(5)
$a_(5) attach-vectorbasedforward $opt(width)
$a_(5) cmd set-range $opt(range) 
$a_(5) cmd set-target-x -20
$a_(5) cmd set-target-y -10
$a_(5) cmd set-target-z -20
$a_(5) cmd set-filename $opt(datafile)
$a_(5) cmd set-packetsize $opt(packet_size) ;# # of bytes


#node 6 (49,0,-250)

set node_(6) [ $ns_  node 6]
$node_(6) set sinkStatus_ 1

$node_(6) set max_speed $opt(maxspeed)
$node_(6) set min_speed $opt(minspeed)
$node_(6) set position_update_interval_ $opt(position_update_interval)

$god_ new_node $node_(6)
$node_(6) set X_  350
$node_(6) set Y_  -190
$node_(6) set Z_  -190
$node_(6) set passive 1

set rt [$node_(6) set ragent_]
$rt set control_packet_size  $opt(routing_control_packet_size)

set a_(6) [new Agent/UWSink]
$ns_ attach-agent $node_(6) $a_(6)
$a_(6) attach-vectorbasedforward $opt(width)
$a_(6) cmd set-range $opt(range) 
$a_(6) cmd set-target-x -20
$a_(6) cmd set-target-y -10
$a_(6) cmd set-target-z -20
$a_(6) cmd set-filename $opt(datafile)
$a_(6) cmd set-packetsize $opt(packet_size) ;# # of bytes



###############node 7 (48,0,-310)
set node_(7) [ $ns_  node 7]
$node_(7) set sinkStatus_ 1
$node_(7) random-motion 1

$node_(7) set max_speed $opt(maxspeed)
$node_(7) set min_speed $opt(minspeed)
$node_(7) set position_update_interval_ $opt(position_update_interval)

$god_ new_node $node_(7)
$node_(7) set X_  270
$node_(7) set Y_  -210
$node_(7) set Z_  -210
$node_(7) set passive 1

set rt [$node_(7) set ragent_]
$rt set control_packet_size  $opt(routing_control_packet_size)

set a_(7) [new Agent/UWSink]
$ns_ attach-agent $node_(7) $a_(7)
$a_(7) attach-vectorbasedforward $opt(width)
$a_(7) cmd set-range $opt(range) 
$a_(7) cmd set-target-x -20
$a_(7) cmd set-target-y -10
$a_(7) cmd set-target-z -20
$a_(7) cmd set-filename $opt(datafile)
$a_(7) cmd set-packetsize $opt(packet_size) ;# # of bytes

#node 8 (348,0,-360)
set node_(8) [ $ns_  node 8]
$node_(8) set sinkStatus_ 1
$node_(8) random-motion 1
$node_(8) set max_speed $opt(maxspeed)
$node_(8) set min_speed $opt(minspeed)
$node_(8) set position_update_interval_ $opt(position_update_interval)
$node_(8) set next_hop 7
$god_ new_node $node_(8)
$node_(8) set X_  350
$node_(8) set Y_  -250
$node_(8) set Z_  -220
$node_(8) set passive 1

set rt [$node_(8) set ragent_]
$rt set control_packet_size  $opt(routing_control_packet_size)

set a_(8) [new Agent/UWSink]
$ns_ attach-agent $node_(8) $a_(8)
$a_(8) attach-vectorbasedforward $opt(width)
$a_(8) cmd set-range $opt(range) 
$a_(8) cmd set-target-x  250
$a_(8) cmd set-target-y -50
$a_(8) cmd set-target-z -50
$a_(8) cmd set-filename $opt(datafile)
$a_(8) cmd set-packetsize $opt(packet_size) ;# # of bytes

#node 9 (300,-300,-250)
#Set the source node
set node_($total_number) [$ns_  node $total_number]
$god_ new_node $node_($total_number)
$node_($total_number) color "#ff0000"
$node_($total_number) set  sinkStatus_ 1
$node_($total_number) set X_  300
$node_($total_number) set Y_  -300
$node_($total_number) set Z_  -250
$node_($total_number) set-cx  -300
$node_($total_number) set-cy  -300
$node_($total_number) set-cz  -250
$node_($total_number) set next_hop [expr $total_number - 1]
set rt [$node_($total_number) set ragent_]
$rt set control_packet_size  $opt(routing_control_packet_size)


set a_($total_number) [new Agent/UWSink]
$ns_ attach-agent $node_($total_number) $a_($total_number)
$a_($total_number) attach-vectorbasedforward $opt(width)
$a_($total_number) cmd set-range $opt(range)
$a_($total_number) cmd set-target-x -20
$a_($total_number) cmd set-target-y -10
$a_($total_number) cmd set-target-z -10
$a_($total_number) cmd set-filename $opt(datafile)
$a_($total_number) cmd set-packetsize $opt(packet_size) ;# # of bytes

# make nam workable
set node_size 30
for {set k 0} { $k<$opt(nn)} {incr k} {
$ns_ initial_node_pos $node_($k) $node_size
}


$ns_ duplex-link $node_(1) $node_(8) 1b 10ms DropTail
#set udp [new Agent/UDP]
#$ns_ attach-agent $node_(8) $udp
#$ns_ connect $udp $node_(8) 

#set cbr [new Application/Traffic/CBR]
#$cbr attach-agent $udp
#$cbr set type_ CBR
#$cbr set packet_size_ 50
#$cbr set rate_ 1mb
#$cbr set random_ false

#$ns_ at 0.001 "$cbr start"
#$ns_ at 1.0   "$cbr stop"
#$ns_ set-animation-rate 0.001s
$node_(1) color red
[$node_(8) set ll_(0)] wormhole_peer [$node_(1) set ll_(0)]
[$node_(1) set ll_(0)] wormhole_peer [$node_(8) set ll_(0)]

set start_time 0.001
set opt(stop2) [expr $opt(stop) + 2000]
$ns_ at $start_time "$a_(9) cbr-start"
$ns_ at $opt(stop).001 "$a_(9) terminate"
$ns_ at $opt(stop2).002 "$a_(0) terminate"
$ns_ at $opt(stop2).003 "$god_ compute_energy"
$ns_ at $opt(stop2).004  "$ns_ nam-end-wireless $opt(stop)"
$ns_ at $opt(stop2).005 "puts \"NS EXISTING...\"; $ns_ halt"
$ns_ at $opt(stop2).006 "Packet Send is  "



 puts $data  "New simulation...."
 puts $data "nodes  = $opt(nn), maxspeed = $opt(maxspeed), minspeed = $opt(minspeed), random_seed = $opt(seed), sending_interval_=$opt(interval), width=$opt(width)"
 puts $data "x= $opt(x) y= $opt(y) z= $opt(z)"
 close $data
 puts "starting Simulation..."
 $ns_ run
