#!/usr/bin/expect
set user "anonymous"
spawn ftp -i 10.23.144.140      # -i option to download multiple files without being asked to input y for each file
expect "Name"
send "$user\r"
expect "Password"
send "\r"
expect "ftp>"
send "cd /pub/redembedded/cnf-523/\r"
expect "ftp>"
interact