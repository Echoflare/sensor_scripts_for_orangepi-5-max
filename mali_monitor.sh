#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later

GPU_PATH="/sys/class/devfreq/fb000000.gpu-panthor/load"
AVAIL_FREQ_PATH="/sys/class/devfreq/fb000000.gpu-panthor/available_frequencies"
tab=$(printf '\t')

if [ -f "$AVAIL_FREQ_PATH" ]; then
    MAX_FREQ=$(tr ' ' '\n' < "$AVAIL_FREQ_PATH" | sort -nr | head -1)
else
    MAX_FREQ=1000000000
fi

while :; do
    read query
    
    case "$query" in
        "?")
            echo "mali_gpu_load${tab}mali_gpu_freq${tab}mali_gpu_weighted"
            ;;
            
        "mali_gpu_load${tab}value")
            if [ -f "$GPU_PATH" ]; then
                cat "$GPU_PATH" | cut -d '@' -f 1
            else
                echo "0"
            fi
            ;;
        "mali_gpu_load${tab}name")
            echo "Mali Load (Raw)"
            ;;
        "mali_gpu_load${tab}min")
            echo "0"
            ;;
        "mali_gpu_load${tab}max")
            echo "100"
            ;;
        "mali_gpu_load${tab}unit")
            echo "%"
            ;;

        "mali_gpu_freq${tab}value")
            if [ -f "$GPU_PATH" ]; then
                raw_freq=$(cat "$GPU_PATH" | cut -d '@' -f 2 | sed 's/Hz//')
                echo $((raw_freq))
            else
                echo "0"
            fi
            ;;
        "mali_gpu_freq${tab}name")
            echo "Mali Freq"
            ;;
        "mali_gpu_freq${tab}unit")
            echo "Hz"
            ;;

        "mali_gpu_weighted${tab}value")
            if [ -f "$GPU_PATH" ]; then
                line=$(cat "$GPU_PATH")
                load=$(echo "$line" | cut -d '@' -f 1)
                freq=$(echo "$line" | cut -d '@' -f 2 | sed 's/Hz//')
                if [ "$MAX_FREQ" -gt 0 ]; then
                    echo $(( (load * freq) / MAX_FREQ ))
                else
                    echo "$load"
                fi
            else
                echo "0"
            fi
            ;;
        "mali_gpu_weighted${tab}name")
            echo "Mali Usage (Weighted)"
            ;;
        "mali_gpu_weighted${tab}min")
            echo "0"
            ;;
        "mali_gpu_weighted${tab}max")
            echo "100"
            ;;
        "mali_gpu_weighted${tab}unit")
            echo "%"
            ;;
            
        *)
            echo
            ;;
    esac
done