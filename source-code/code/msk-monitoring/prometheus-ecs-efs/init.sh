#!/bin/bash

python3 /etc/prometheus/generate_targets.py

if [ ! -f /etc/prometheus/targets.json ]; then
    echo "Error creating targets.json for msk prometheus"
    exit 1
fi

/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/prometheus --web.console.libraries=/etc/prometheus/console_libraries --web.console.templates=/etc/prometheus/consoles