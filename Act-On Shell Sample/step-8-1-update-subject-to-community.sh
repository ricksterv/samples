#!/bin/bash
#for readfile in test/*.json; do
for readfile in discussions-edit/*.json; do

	file=$({ cat "$readfile"; } 2>&1)

	SubjectRe='"RE: '
	replace_quote="'"
	replace_doublequote='"'
	# sed 's/[^a-zA-Z 0-9]/\\&/g'

	HLContactKeyJson=$({ echo "$file" | grep -o '"ContactKey.*' | cut -d \" -f4; } 2>&1)
	HLSubjectJson=$({ echo "$file" | grep -o '"Subject.*' | cut -d \" -f4; } 2>&1)

	SAVEIFS=$IFS # Save current IFS
	IFS=$'\n'    # Change IFS to new line
	HLContactKeyArray=($HLContactKeyJson)
	HLSubjectArray=($HLSubjectJson)
	IFS=$SAVEIFS # Restore IFS

	for ((i = 0; i < ${#HLContactKeyArray[@]}; i++)); do
		HLSubject=$({ echo "${HLSubjectArray[$i]}" | sed "s~$replace_doublequote~$replace_quote~g"; } 2>&1)
		if [[ "$HLSubject" != "RE: "* ]]; then
			#echo "Inside first IF - $HLSubject"
			HLContactKey="${HLContactKeyArray[$i]}"
			for readfile2 in step-3-ZD-HL-db-match.csv; do

				file2=$({ cat "$readfile2"; } 2>&1)
				ZDToParse=$({ echo "$file2"; } 2>&1)

				SAVEIFS=$IFS                # Save current IFS
				IFS=$'\n'                   # Change IFS to new line
				ZDToParseArray=($ZDToParse) # split to array $names
				IFS=$SAVEIFS                # Restore IFS

				for ((j = 0; j < ${#ZDToParseArray[@]}; j++)); do
					HLid=$({ echo "${ZDToParseArray[j]}" | cut -d \, -f2; } 2>&1)
					#echo  "ZDemail = $ZDemail"
					#echo  "HLid = $HLid"
					#echo  "ZDid = $ZDid"

					if [[ "$HLContactKey" == "$HLid" ]]; then
						#echo "Inside second IF - $HLContactKey"
						ZDid=$({ echo "${ZDToParseArray[j]}" | cut -d \, -f3; } 2>&1)
						for readfile3 in step-4-ZD-Post-ID-Title.txt; do

							file3=$({ cat "$readfile3"; } 2>&1)
							PostToParse=$({ echo "$file3"; } 2>&1)

							SAVEIFS=$IFS                    # Save current IFS
							IFS=$'\n'                       # Change IFS to new line
							PostToParseArray=($PostToParse) # split to array $names
							IFS=$SAVEIFS                    # Restore IFS

							for ((k = 0; k < ${#PostToParseArray[@]}; k++)); do
								Postid=$({ echo "${PostToParseArray[k]}" | cut -d \, -f1; } 2>&1)
								PostSubject=$({ echo "${PostToParseArray[k]}" | sed "s~$replace_doublequote~$replace_quote~g" | cut -d \, -f2; } 2>&1)
								#	echo  "Postid = $Postid"
								#	echo  "PostSubject = $PostSubject"

								if [[ "$PostSubject" == "$HLSubject" ]]; then
									EmptyUpdateContents=""
									OneSpaceUpdateContents=""
									updateContents=$({ echo https://actonsoftware.zendesk.com/api/v2/community/posts/''"$Postid"''.json -d '{"post": {"title": "'"$PostSubject"'"}, "notify_subscribers": false}' -v -u supportbot@act-on.net/token:eFc9Pfech2fFNguEdCP7sUVscOJEqFmTRF6rOp6p -X PUT -H "Content-Type: application/json"; } 2>&1)

									EmptyUpdateContents=$({ echo "$updateContents" | grep '"details": ""'; } 2>&1)
									OneSpaceUpdateContents=$({ echo "$updateContents" | grep '"details": " "'; } 2>&1)

									#echo "EmptyUpdateContents = $EmptyUpdateContents"
									#echo "OneSpaceUpdateContents = $OneSpaceUpdateContents"
									if [[ "$EmptyUpdateContents" == "" ]] && [[ "$OneSpaceUpdateContents" == "" ]]; then
										CurlupdateContents=$({ curl https://actonsoftware.zendesk.com/api/v2/community/posts/''"$Postid"''.json -d '{"post": { "title": "'"$PostSubject"'" }, "notify_subscribers": false}' -v -u supportbot@act-on.net/token:eFc9Pfech2fFNguEdCP7sUVscOJEqFmTRF6rOp6p -X PUT -H "Content-Type: application/json"; } 2>&1)
										#echo "updateContents = $updateContents"
										echo "$CurlupdateContents" >>log-output/update-community-subject-log.txt
										echo "" >>log-output/update-community-subject-log.txt
										echo "" >>log-output/update-community-subject-log.txt
									fi
								fi #77
							done #69
						done #58
					fi #54
				done #47
			done #36
		fi #28
	done #24
done #2

echo "Bazinga"
