#!/usr/bin/expect -f

#set là cách gán giá trị local, tương tự abc=123 bên bash và shell, tcl viết bằng ngôn ngữ C nên hơi khác so với bash và shell
set ip [lindex $argv 0]

puts "Please enter your STB password:" 
fconfigure stdin -blocking 1
set password [gets stdin]

set RootPrompt "(%|#|\\$) $"
set CDNHost "10.23.144.161"
set CDNPort "1500"
set PGWSHost "10.23.144.161"
set PGWSPort "1500"

#ssh to STB
spawn bash -c "ssh root@$ip"

expect {
	"\(yes/no\)\?" {
		send "yes\r"
		exp_continue
	}
	"password:"	{send "$password\r"}
}

#Delete folder /var/vdm_data
expect {
	-re "$RootPrompt"	{send "rm -rf /var/vdm_data \r"}
}

#Create folder /var/vdm_data
expect -re "$RootPrompt"	{send "mkdir /var/vdm_data \r"}

#Get rID
expect -re "$RootPrompt"	{send "getmode rid \r"}
expect -re "$RootPrompt"
set resp1 $expect_out(buffer)
set resp2 [split $resp1 "\n"]
set rID [lindex $resp2 1]

#remove newline character ater rID
set rID [string trim $rID]

close

#Copy vdm.config to /var/vdm_data
spawn scp vdm.config root@${ip}:/var/vdm_data/

expect "password:"	{send "$password\r"}

interact

#ssh to STB
spawn ssh root@$ip
expect "password:"	{send "$password\r"}

#setTestEToken
expect -re "$RootPrompt"	{send "dt setTestEToken -useTestEToken true -etoken 123456789 -rid ${rID} -useTestSignatureOptions true -signatureKey 123456789012345678901234 -astime 2014-04-01T17:55:22.000Z \r"}

#set EToken
expect -re "$RootPrompt"	{send "dt setTestEToken -useTestEtoken true -etoken aXJWNE3evgFrDBVQ6h9uMuPHVGEYcLH9/BvJgSYg/Ac9Y88SAewk+ummkdBz5b0CNO3PUkcQm1lkS5omzEUSUMJTm8InFE30w6J/jfAL6UJj//Aaf9WrTEWFXn0QuFRmGRScmoQl9PCrtmqcT34fVvxGOWcgdTDVPo2GCXVOuFI= -rid ${rID} -signatureKey 12-23-34-45-56-67-78-89-90-09-87-76-65-54-43-32-21-12-23-34-45-56-67-78- -useTestSignatureOptions true \r"}

#pipCheck off
expect -re "$RootPrompt"	{send "dt pipCheck off; dt materialIdCheck off; dt putQueueManagerInTestMode \r"}

#dt pointToMRMTest
expect -re "$RootPrompt"	{send "dt pointToMRMTest \r"}

#dt pointToMRMSim
#expect -re "$RootPrompt"	{send "dt pointToMRMSim \r"}

#=======================
#edit file setting.json

#"CDNHost": "cmd.dtvce.com"
#"CDNHost": "10.23.144.161"

set str1 "\"CDNHost\":\ \"cmd.dtvce.com\""
set rstr1 "\"CDNHost\":\ \"${CDNHost}\""

expect -re "$RootPrompt"	{send "sed -i -e 's/${str1}/${rstr1}/g' /var/viewer/pgwsclient/settings.json \r"}

#"CDNPort": "-1"
#"CDNPort": "1500"

set str2 "\"CDNPort\":\ \"-1\""
set rstr2 "\"CDNPort\":\ \"${CDNPort}\""

expect -re "$RootPrompt"	{send "sed -i -e 's/${str2}/${rstr2}/g' /var/viewer/pgwsclient/settings.json \r"}

#"PGWSHost": "pds.dtvce.com"
#"PGWSHost": "10.23.144.161"

set str3 "\"PGWSHost\":\ \"pds.dtvce.com\""
set rstr3 "\"PGWSHost\":\ \"${PGWSHost}\""

expect -re "$RootPrompt"	{send "sed -i -e 's/${str3}/${rstr3}/g' /var/viewer/pgwsclient/settings.json \r"}

#"PGWSPort": "443"
#"PGWSPort": "1500"

set str4 "\"PGWSPort\":\ \"443\""
set rstr4 "\"PGWSPort\":\ \"${PGWSPort}\""

expect -re "$RootPrompt"	{send "sed -i -e 's/${str4}/${rstr4}/g' /var/viewer/pgwsclient/settings.json \r"}

#"PGWSScheme": "httpssl"
#"PGWSScheme": "http"

set str5 "\"PGWSScheme\":\ \"httpssl\""
set rstr5 "\"PGWSScheme\":\ \"http\""

expect -re "$RootPrompt"	{send "sed -i -e 's/${str5}/${rstr5}/g' /var/viewer/pgwsclient/settings.json \r"}

# # "host": "http://5af10.v.fwmrm.net"
# # "host": "http://10.23.144.161"

# set str6 "\"host\":\ \"http:\/\/5af10.v.fwmrm.net\""
# set rstr6 "\"host\":\ \"http:\/\/10.23.144.161\""

# expect -re "$RootPrompt"	{send "sed -i -e 's:${str6}:${rstr6}:g' /var/viewer/pgwsclient/settings.json \r"}

# # "service": "ad/g/1?"
# # "service": "FW/fw?"

# set str7 "\"service\": \"ad\/g\/1?\""
# set rstr7 "\"service\": \"FW\/fw?\""

# expect -re "$RootPrompt"	{send "sed -i -e 's/${str7}\/${rstr7}/g' /var/viewer/pgwsclient/settings.json \r"}

#=========================

#sleep 5

#dt pgwsReloadSettings
expect -re "$RootPrompt"	{send "dt pgwsReloadSettings \r"}

#dt disableAdInsertableFlag –disable true
expect -re "$RootPrompt"	{send "dt disableAdInsertableFlag \-disable true \r"}

#dt enableCloudVOD
expect -re "$RootPrompt"	{send "dt enableCloudVOD \r"}

#enableShef
expect -re "$RootPrompt"	{send "dt shef -cmd onShef\n"}

#printPGWSStatus
expect -re "$RootPrompt"	{send "dt printPGWSStatus|grep Unconnected\n"}

#Set red color output
puts "\033\[32m"

expect -re "$RootPrompt"	{send "exit\n"}

#Set output color normal
puts "\033\[0m"

interact
