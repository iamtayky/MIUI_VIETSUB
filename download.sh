#!/bin/bash
echo "Starting donwload rom and auto run bhlnk script"
wget -O input.zip $1
./bhlnk.sh
