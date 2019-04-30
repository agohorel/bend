#!/bin/bash

DATE=$(date +"%d_%H%M")

raspistill -t 5000 -w 1280 -h 720 -vf -hf -o /home/pi/Desktop/alephBend/data/capture/$DATE.jpg