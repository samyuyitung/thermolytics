#!/bin/sh

## Sleep to let the bluetooth setup
sleep 10

/usr/bin/python /home/pi/scripts/ble-uart-peripheral/pi/serial_uart_server.py