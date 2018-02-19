#!/bin/bash

export PORT=5100

cd ~/www/tracker
./bin/tracker stop || true
./bin/tracker start

