#!/bin/bash

HOST=$1
PORT=$2
TIMEOUT=$3

nc -z -w $TIMEOUT $HOST $PORT
