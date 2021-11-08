#!/usr/bin/expect

set timeout -1

spawn ./quartus/setup.sh

expect {
    "Press \\\[Enter\\\] to continue:" { send "\r"; exp_continue }
    "Do you accept this license? \\\[y/n\\\]" { send "y\r"; exp_continue }
    "Installation directory \\\[/root/intelFPGA_lite/" { send "/opt/intel\r"; exp_continue }
    "Quartus Prime Lite Edition (Free)  \\\[Y/n\\\] :" { send "y\r"; exp_continue }
    "Quartus Prime Lite Edition (Free)  - Quartus Prime Help" { send "n\r"; exp_continue }
    "Quartus Prime Lite Edition (Free)  - Devices \\\[Y/n\\\] " { send "y\r"; exp_continue }
    "Quartus Prime Lite Edition (Free)  - Devices - MAX 10 FPGA" { send "y\r"; exp_continue }
    "Quartus Prime Lite Edition (Free)  - Devices - " { send "n\r"; exp_continue }
    "Questa - Intel FPGA Starter Edition (A zero cost license required)" { send "n\r"; exp_continue }
    "Questa - Intel FPGA Edition" { send "n\r"; exp_continue }
    "Is the selection above correct? \\\[Y/n\\\]:" { send "y\r"; exp_continue }
    "Create shortcuts on Desktop \\\[Y/n\\\]:" { send "n\r"; exp_continue }
    "Launch Quartus Prime Lite Edition \\\[Y/n\\\]:" { send "n\r"; exp_continue }
    "Provide your feedback at" { send "n\r"; exp_continue }
    eof { }
}
