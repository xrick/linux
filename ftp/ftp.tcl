#!/usr/bin/expect
set user "anonymous"
spawn ftp -i 10.23.144.140
expect "Name"
send "$user\r"
expect "Password"
send "\r"
expect "ftp>"
send "cd /pub/redembedded/cnf-523/\r"
expect "ftp>"
interact