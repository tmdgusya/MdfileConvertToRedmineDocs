# !/bin/bash
#
# $1 MD DOC FILE 
# start covert file
# SHELL MUST BE RUN INTO MD FILE DIRECTORY
# USING PANDOC CONVERT FILE PROCESS
#
mkdir -p ../output/ # create output directory, if not exist output directory
#
FILE_NAME=${1}
SPLIT_MD=`echo $1 | cut -d'.' -f1`
REDMINE_TITLE=${SPLIT_MD}
OUT_PUT_FILENAME="${SPLIT_MD}"
#
pandoc ${1} -f gfm -t textile -s -o ../output/${OUT_PUT_FILENAME}.textile.tmp

echo file is converting......                           
echo file create ../output/${OUT_PUT_FILENAME}.textile.tmp 
#TEXTILE CONVER TO REDMINE DOCS PROCESS

#DELETE
echo "covert <br> tag to Newline"
sed -i 's/<br>/\n/g' ../output/${OUT_PUT_FILENAME}.textile.tmp
sed -i 's/<br\/>/\n/g' ../output/${OUT_PUT_FILENAME}.textile.tmp
sed -i 's/&quot;//g' ../output/${OUT_PUT_FILENAME}.textile.tmp
sed -i 's/<hr \/>//g' ../output/${OUT_PUT_FILENAME}.textile.tmp
sed -i 's/"module index":..\/README.md//g' ../output/${OUT_PUT_FILENAME}.textile.tmp

echo 'Header Changing....'
#Create Header Link

TMP_HEADER_LINE=(`grep -n ':#' ../output/${OUT_PUT_FILENAME}.textile.tmp | cut -d : -f1`)
TMP_HEADER_PARSE=(`grep -n ':#' ../output/${OUT_PUT_FILENAME}.textile.tmp`)

count=1
inline_count=0
for NAME in ${TMP_HEADER_PARSE[@]}
do
		CONDITION=$((${count}%2))
		echo ${CONDITION}
		if [ ${CONDITION} -eq 1 ]
		then
			SPLIT_HEADER_NAME+=(`echo ${TMP_HEADER_PARSE[count]} | cut -d '"' -f2`)
			NEW_HEADER_NAME+=("${REDMINE_TITLE}#${SPLIT_HEADER_NAME[$((${inline_count}))]}")
			echo 'Finish Conver to Header Name : '${NEW_HEADER_NAME[${inline_count}]}''
			inline_count=$((${inline_count}+1))
		fi
		count=$((${count}+1))
done

inline_count=0

#UPDATE HEADER LINK PART BY LINE_NUMBER

for NUM in ${TMP_HEADER_LINE[@]}
do
		echo 'line number : '${NUM}''
		EXPR="${NUM}s/.*/${NEW_HEADER_NAME[$inline_count]}"
		echo ${EXPR}
		sed -i "${NUM}s/.*/* [[${NEW_HEADER_NAME[$inline_count]}|${SPLIT_HEADER_NAME[${inline_count}]}]]/g" ../output/${OUT_PUT_FILENAME}.textile.tmp
	inline_count=$((${inline_count}+1))
done

echo 'code line create....'
PARENT_TAG_LINE=(`grep -n '<pre class="yaml">' ../output/${OUT_PUT_FILENAME}.textile.tmp | cut -d : -f1`)
CHILD_TAG_LINE=(`grep -n '</pre>' ../output/${OUT_PUT_FILENAME}.textile.tmp | cut -d : -f1`)
sed -i 's/bc(json)./<pre><code class="json">\n/g' ../output/${OUT_PUT_FILENAME}.textile.tmp
sed -i 's/bc(yaml)./<pre><code class="yaml">\n/g' ../output/${OUT_PUT_FILENAME}.textile.tmp

count=0

for line in ${PARENT_TAG_LINE[@]}
do

	echo 'PARENT_TAG_LINE : '${line}''
	sed -i "${line}s/.*/<pre><code class="'"'"yaml"'"'">/g" ../output/${OUT_PUT_FILENAME}.textile.tmp
	echo 'CHILE_TAG_LIEN : '${CHILD_TAG_LINE[${count}]}''
	sed -i "${CHILD_TAG_LINE[${count}]}s/.*/<\/code><\/pre>/g" ../output/${OUT_PUT_FILENAME}.textile.tmp
	count=$((${count}+1))
done

echo Process Success.....!!!
echo covert tmp file to textile file!

#IF ENDED PROCESS RENAME FILE

mv ../output/${OUT_PUT_FILENAME}.textile.tmp ../output/${OUT_PUT_FILENAME}.textile
