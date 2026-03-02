#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later

DISK="mmcblk0"
MOUNT_POINT="/"
tab=$(printf '\t')

LAST_READ_SECTORS=0
LAST_READ_TIME=0
LAST_WRITE_SECTORS=0
LAST_WRITE_TIME=0

while :; do
    read query
    
    case "$query" in
        "?")
            echo -e "emmc_read_rate\temmc_write_rate\temmc_total_space\temmc_used_percent"
            ;;
            
        "emmc_read_rate${tab}value")
            NOW=$(date +%s%3N)
            CUR_SECTORS=$(awk -v dev="$DISK" '$3 == dev {print $6}' /proc/diskstats)
            
            if [ "$LAST_READ_TIME" -gt 0 ] && [ -n "$CUR_SECTORS" ]; then
                TIME_DIFF=$((NOW - LAST_READ_TIME))
                if [ "$TIME_DIFF" -gt 0 ]; then
                    SECTOR_DIFF=$((CUR_SECTORS - LAST_READ_SECTORS))
                    echo $((SECTOR_DIFF * 512 * 1000 / TIME_DIFF))
                else
                    echo "0"
                fi
            else
                echo "0"
            fi
            
            LAST_READ_SECTORS=$CUR_SECTORS
            LAST_READ_TIME=$NOW
            ;;
        "emmc_read_rate${tab}name")
            echo "eMMC Read Rate"
            ;;
        "emmc_read_rate${tab}unit")
            echo "B/s"
            ;;
            
        "emmc_write_rate${tab}value")
            NOW=$(date +%s%3N)
            CUR_SECTORS=$(awk -v dev="$DISK" '$3 == dev {print $10}' /proc/diskstats)
            
            if [ "$LAST_WRITE_TIME" -gt 0 ] && [ -n "$CUR_SECTORS" ]; then
                TIME_DIFF=$((NOW - LAST_WRITE_TIME))
                if [ "$TIME_DIFF" -gt 0 ]; then
                    SECTOR_DIFF=$((CUR_SECTORS - LAST_WRITE_SECTORS))
                    echo $((SECTOR_DIFF * 512 * 1000 / TIME_DIFF))
                else
                    echo "0"
                fi
            else
                echo "0"
            fi
            
            LAST_WRITE_SECTORS=$CUR_SECTORS
            LAST_WRITE_TIME=$NOW
            ;;
        "emmc_write_rate${tab}name")
            echo "eMMC Write Rate"
            ;;
        "emmc_write_rate${tab}unit")
            echo "B/s"
            ;;
            
        "emmc_total_space${tab}value")
            df -B1 "$MOUNT_POINT" | awk 'NR==2 {print $2}'
            ;;
        "emmc_total_space${tab}name")
            echo "eMMC Total Space"
            ;;
        "emmc_total_space${tab}unit")
            echo "B"
            ;;
            
        "emmc_used_percent${tab}value")
            df "$MOUNT_POINT" | awk 'NR==2 {print $5}' | tr -d '%'
            ;;
        "emmc_used_percent${tab}name")
            echo "eMMC Used"
            ;;
        "emmc_used_percent${tab}min")
            echo "0"
            ;;
        "emmc_used_percent${tab}max")
            echo "100"
            ;;
        "emmc_used_percent${tab}unit")
            echo "%"
            ;;
            
        *)
            echo
            ;;
    esac
done