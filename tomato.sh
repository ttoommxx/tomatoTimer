#!/bin/bash

input=0
cycle=$(<$(dirname -- "$0")/cycle.log)
while [ "$input" != "252" ]
do
	timeStudy=$(cut -d "|" -f 1 $(dirname -- "$0")/settings.log)
	timeBreak=$(cut -d "|" -f 2 $(dirname -- "$0")/settings.log)
	
	yad --title "Tomato" \
	--text "Cycle number $cycle" \
	--button="Tomato":1 \
	--button="Break":2 \
	--button="Settings":3 \
	--button="Reset counter":4 \
	--button="About":5 \
	--width=400 --height=40
	
	input=$?
	case $input in
		"1")
			if [ $(cut -d "|" -f 1 $(dirname -- "$0")/settings.log) -le 120 -o $(cut -d "|" -f 1 $(dirname -- "$0")/settings.log) -ge 1 ];
			then	
				yad --title "Study" \
				--text "Start   $(date -d "now" +%H:%M) \nEnd     $(date -d "now + ${timeStudy} minutes" +%H:%M)" --text-align=center \
				--timeout=$(( $timeStudy*60 )) --timeout-indicator=bottom \
				--button="Done":1 \
				--button="Lock the screen":"xdg-screensaver lock" \
				--width=400
				
				case $? in
					"1")
						cycle=$((cycle + 1))
					;;
					"70")
						paplay $(dirname -- "$0")/stopStudy.wav
						notify-send "Take a break"
						cycle=$((cycle + 1))	
					;;
					*)
						notify-send "Timer interrupted"
					;;
				esac
						
			else
				notify-send "Corrupted settings"
			fi
		;;
		"2")
			if [ $(cut -d "|" -f 2 $(dirname -- "$0")/settings.log) -le 30 -o $(cut -d "|" -f 2 $(dirname -- "$0")/settings.log) -ge 1 ];
			then
				yad --title "Break" \
				--text "Start   $(date -d 'now' +%H:%M) \nEnd     $(date -d "now + ${timeBreak} minutes" +%H:%M)" --text-align=center \
				--timeout=$(( $timeBreak*60 )) --timeout-indicator=bottom \
				--button="Lock the screen":"xdg-screensaver lock" \
				--width=400
				
				if [ $? = 70 ]; then
					paplay $(dirname -- "$0")/startStudy.wav
					notify-send "Go back to work"
				fi
				
			else
				notify-send "Corrupted settings"
			fi
		;;
		"3")		
		newSettings=($(yad --form --title "Settings" --columns=1 \
		--field="Study time (1-120 min):":NUM $(cut -d "|" -f 1 $(dirname -- "$0")/settings.log)!1..120!1!0 \
		--field="Break time (1-30 min):":NUM $(cut -d "|" -f 2 $(dirname -- "$0")/settings.log)!1..30!1!0 \
		--button="Ok" \
		--width=400
		))

		echo $newSettings > $(dirname -- "$0")/settings.log
		;;
		"4")
			cycle=0
		;;
		"5")
			yad --title "About" \
			--text "Version 0.4.1 \nWritten by Tommaso Seneci" \
			--no-buttons
		;;
	esac
done

echo $cycle > $(dirname -- "$0")/cycle.log
