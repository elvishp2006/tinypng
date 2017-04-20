#!/bin/bash
keys=(
"92eMC5fvjMhqyn3rnFhvnV7HH4QyQAR4"
"Zkf1LHXMWyyGcpUhsgH8bjET9j5oSw7S"
"DC7Fxhf-iEw40XfDmAb3KrWRnEPfBEDN"
"qJ2q_PJPcwPNkh-67iyBFLjja08hTaF6"
)
key_index=0
echo $key
echo "" >> tinypng_record.txt
removeQuotation(){
	val=$1
	len=${#val}
	echo ${val:1:len-2}
}

compress(){
	echo "begin compress $img"
	conent="curl --user api:${keys[key_index]} --data-binary @$1 https://api.tinify.com/shrink"
	echo "exec:$conent"
	response2=`$conent`
	echo $response2
	error=`echo $response2|jq ".error"`
	if [[ x$error != x"null" ]]; then
		echo "error msg:$error"
		key_index=`expr $key_index + 1`
		length=${#keys[@]}
		if [[ $key_index -ge $length ]]; then
			echo "no useful key,last file $img"
			exit
		else
			compress $1
		fi
	else
		url=`echo $response2|jq ".output.url"`
		url=$(removeQuotation $url)
		echo "begin download url:$url"
		curl $url -o $img
		echo "done $url"
		echo "$1 " >> tinypng_record.txt
		echo ""
	fi
}

list_alldir(){
    for file2 in `ls -a $1`
    do
        if [ x"$file2" != x"." -a x"$file2" != x".." ];then
            if [ -d "$1/$file2" ];then
            	if [[ x$file2 = x"build" ]]; then
            		echo "skip build dir"
            	else
            		list_alldir "$1/$file2"
            	fi
            else
            	img="$1/$file2"

            	result=`cat tinypng_record.txt | grep $img`
            	if [[ x$result != x""  ]]; then
            		echo "skip $img,have already compress"
            		continue;
            	fi

            	right=${img##*.}
            	if [[ x"$right" = x"png" ]]; then
            		compress $img
            	fi

                if [[ x"$right" = x"jpg" ]]; then
                        compress $img
                fi

            fi
        fi
    done
}

list_alldir .
