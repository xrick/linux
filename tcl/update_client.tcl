#!/usr/bin/expect

#20150818: ThangNguyen: add Force/Normal mode
#20150820: ThangNguyen: Get info from CIAIMG_FILE file.
#20150910: ThangNguyen: Add c51 to list; Change way input stb pass; add force to update_client.sh
#20151012: ThangNguyen: Set timeout to upgrade/downgrade VPL's clients from local.
#20151127: Add full mfrid 
#20160224: add c41w
#20160308: Removed absolute path
#20160425: Removed Force/Normal mode

package require Expect

set ListArg [list]
#set path [file dirname [file normalize ./update_client.tcl] ]
set path [file dirname [file normalize [info script]]]
puts "SRC=$path"

proc getPass {prompt} {
  # Required package is Expect. It could be installed using teacup:
  # teacup install Expect
  package require Expect
  set oldmode [stty -echo -raw]
  send_user "$prompt"
  set timeout -1
  expect_user -re "(.*)\n"
  send_user "\n"
  eval stty $oldmode
  return $expect_out(1,string)
}

if {$argc > 0} {
	for {set x 0} {$x<$argc} {incr x} {
		lappend ListArg [lindex $argv $x]
	}
} else {
	puts ""
	puts "COMMAND:"
	puts "update_client.tcl <SERVER IP> <CLIENT_MODEL(c31/c41/c41w/c51/c61)> <CLIENT_MFR(pac/tmm/hum)> <SW_VERSION(Hex)> <CIAIMG_FILE(Path)>"
	puts "update_client.tcl <SERVER IP> <CIAIMG_FILE(Path)>"
	puts ""
	return
}

#puts "Please enter your STB password:" 
fconfigure stdin -blocking 1
#set STBPass [gets stdin]
set STBPass [getPass "Please enter your STB password: "]

# flush stdout
# set STBPass [gets stdin]

#set STBUser root

if { [llength $ListArg] == 6 } {

set SERVER_IP [lindex $ListArg 0]
set CLIENT_MODEL [ string tolower [lindex $ListArg 1] ]
set CLIENT_MFR [ string tolower [lindex $ListArg 2] ]
set CLIENT_VERSION [lindex $ListArg 3]
set CIAIMG_FILE [lindex $ListArg 4]
set Force [lindex $ListArg 5]

if {$Force == 1} {
	#Force mode
	spawn -noecho $path/update_client/update_client.sh $CLIENT_MODEL $CLIENT_MFR $CLIENT_VERSION $CIAIMG_FILE $SERVER_IP 1
} else {
		#Normal mode
		spawn -noecho $path/update_client/update_client.sh $CLIENT_MODEL $CLIENT_MFR $CLIENT_VERSION $CIAIMG_FILE $SERVER_IP
	}

} else {
	 if { [llength $ListArg] == 5 } {
		set SERVER_IP [lindex $ListArg 0]
		set CLIENT_MODEL [ string tolower [lindex $ListArg 1] ]
		set CLIENT_MFR [ string tolower [lindex $ListArg 2] ]
		set CLIENT_VERSION [lindex $ListArg 3]
		set CIAIMG_FILE [lindex $ListArg 4]
		
		#Normal mode
		spawn -noecho $path/update_client/update_client.sh $CLIENT_MODEL $CLIENT_MFR $CLIENT_VERSION $CIAIMG_FILE $SERVER_IP
	 } else {
		if { [llength $ListArg] == 3 } {
			set SERVER_IP [lindex $ListArg 0]
			set CIAIMG_FILE [lindex $ListArg 1]
			set Force [lindex $ListArg 2]
			
			#Get info from CIAIMG_FILE file
			set BASE_CIAIMG_FILE [file tail $CIAIMG_FILE]
			set CLIENT_VERSION [lindex [ split [ lindex [ split $BASE_CIAIMG_FILE "x"] 1] "_"] 0 ]
			set CLIENT_MODEL [lindex [split $BASE_CIAIMG_FILE "-"] 0]
			set CLIENT_MFR [lindex [split $BASE_CIAIMG_FILE "-"] 1]
			
			if {$Force == 1} {
				#Force mode
				spawn -noecho $path/update_client/update_client.sh $CLIENT_MODEL $CLIENT_MFR $CLIENT_VERSION $CIAIMG_FILE $SERVER_IP 1
			} else {
					#Normal mode
					spawn -noecho $path/update_client/update_client.sh $CLIENT_MODEL $CLIENT_MFR $CLIENT_VERSION $CIAIMG_FILE $SERVER_IP
				}
		} else {
			if { [llength $ListArg] == 2 } {
				set SERVER_IP [lindex $ListArg 0]
				set CIAIMG_FILE [lindex $ListArg 1]
				
				#Turn off update-clients
				if { [string tolower $CIAIMG_FILE] == "off" } {
					puts ""
					puts "TURN OFF UPDATE-CLIENTS SERVICE"
					spawn -noecho $path/update_client/update_client.sh [string tolower $CIAIMG_FILE] $SERVER_IP
					#return
				} else {
					set BASE_CIAIMG_FILE [file tail $CIAIMG_FILE]
					set CLIENT_VERSION [lindex [ split [ lindex $[ split $BASE_CIAIMG_FILE "x"] 1] "_"] 0 ]
					set CLIENT_MODEL [lindex [split $BASE_CIAIMG_FILE "-"] 0]
					set CLIENT_MFR [lindex [split $BASE_CIAIMG_FILE "-"] 1]
					
					#Normal mode
					spawn -noecho $path/update_client/update_client.sh $CLIENT_MODEL $CLIENT_MFR $CLIENT_VERSION $CIAIMG_FILE $SERVER_IP
				}
			} else {
				puts "INVALID COMMAND !"
				return
			}
		}
	 }
}

expect {
	"\(yes/no\)\?"	{
		send "yes\r"
		exp_continue
		}
	"password:"	{
		send "$STBPass\r"
		exp_continue
		}
	#"Sending configuration"	\{
	"Permission denied, please try again."	{
		exec rm -f .ssh/known_hosts
		puts "rm \-f \.ssh\/known_hosts"
		puts "Please run gain!"
		exit
	}
}

if { [string tolower $CIAIMG_FILE] != "off" } {
	set timeout 200
	expect {
		# "*Could not open GTK*" {
		# puts "YOUR SERVICE IS NOT AVAILABLE, PLEASE REBOOT YOUR STB THEN TRY AGAIN!"
		# exp_continue
		# }
		"password:" { 
		send "$STBPass\r" 
		exp_continue
		}
	}
}