#!/bin/bash
for i in {0..255};do printf " \e[48;5;${i}m  \e[0m\e[38;5;${i}m%03d\e[0m" $i;((i<=15&&i%8==7||i>15&&i%6==3))&&echo;done;unset i
