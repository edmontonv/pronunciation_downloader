#!/bin/bash

# Trick for mixing AWK and Shell programs in the same file
PARSER_PRG=$(awk '(/^### AWK PROGRAMM MARKER###$/ || body){body=1; print $0}' $0)

echo -n > result.txt

file="list.txt"
while IFS= read -r line
do
	URL_EN=$(curl 'http://dictionary.cambridge.org/dictionary/english/'$line 2> /dev/null | awk -v param=1 "$PARSER_PRG")
	#sleep 5s
	URL_US=$(curl 'http://dictionary.cambridge.org/dictionary/english/'$line 2> /dev/null | awk -v param=2 "$PARSER_PRG")
	# curl -x ://94.228.198.82:8080
	bool=false
	if [ $URL_EN ]; then
		echo $URL_EN
	else
		echo "URL for $line en wasn't found"
	fi
	if [ $URL_US ]; then
		echo $URL_US
	else
		echo "URL for $line us wasn't found"
	fi
	if (test -n "$URL_EN"); then
		wget -P ~/tempf $URL_EN -O "${line}_UK.mp3"
		mpg123 "${line}_UK.mp3"
	else 
		bool=true
	fi
	if (test -n "$URL_US"); then
		wget -P ~/tempf $URL_US -O "${line}_US.mp3"
		mpg123 "${line}_US.mp3"
		if [ "$bool"="true" ]; then
			echo "$line UK US" >> result.txt
		else
			echo "$line US" >> result.txt
		fi
	elif [ "$bool"="true" ]; then
		echo "$line EMPTY" >> result.txt
	else
		echo "$line UK" >> result.txt
	fi
done <"$file"
exit


### AWK PROGRAMM MARKER###
# parser - english pronunciation
BEGIN{ 
	FS 	= "@@" 		#field separator, " " - default value
	RS 	= "\""		#record separator, "\n" - default value
	OFS = " "		#output field separator, " " - default value
	ORS = "\n"		#output record separator, "\n" - default value
}
{
	if (param=="1")
	{
		if (match($0, /^http:\/\/dictionary\.cambridge\.org\/media\/english\/uk_pron.*\.mp3$/))
		{
			url = substr($0, start, RLENGTH)
		}
	}
	else if (param=="2")
	{
		if (match($0, /^http:\/\/dictionary\.cambridge\.org\/media\/english\/us_pron.*\.mp3$/))
		{
			url = substr($0, start, RLENGTH)
		}
	}
}
END{
	print url
}


# todo
# 1) Задержка между исполнениями - 	DONE
# 2) proxy
# 3) mplayer или любой другой		DONE
