#!/bin/bash
inotifywait --monitor --event close_write --event move --event create --event delete /home/infoboard/Pictures/ | while read line
do
  echo $line
  systemctl restart getty@tty1.service
done