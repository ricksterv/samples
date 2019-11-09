#!/bin/bash
for readfile in discussions/*.json; do

	file=$({ cat "$readfile"; } 2>&1)

	SubjectRe='"RE: '
	replace_quote="'"
	replace_doublequote='"'
	# sed 's/[^a-zA-Z 0-9]/\\&/g'

	HLCommunityKey=$({ echo "$file" | jq -r '.CommunityKey'; } 2>&1)
	HLContactKeyJson=$({ echo "$file" | jq -r '.DiscussionPostData[].ContactKey'; } 2>&1)
	HLSubjectJson=$({ echo "$file" | jq -r '.DiscussionPostData[].Subject'; } 2>&1)
	HLBodyJson=$({ echo "$file" | jq -r '.DiscussionPostData[].Body'; } 2>&1)
	HLDatePostedJson=$({ echo "$file" | jq -r '.DiscussionPostData[].DatePosted'; } 2>&1)

	SAVEIFS=$IFS # Save current IFS
	IFS=$'\n'    # Change IFS to new line
	HLContactKeyArray=($HLContactKeyJson)
	HLSubjectArray=($HLSubjectJson)
	HLBodyArray=($HLBodyJson)
	HLDatePostedArray=($HLDatePostedJson)
	IFS=$SAVEIFS # Restore IFS

	for ((i = 0; i < ${#HLContactKeyArray[@]}; i++)); do
		HLContactKey="${HLContactKeyArray[$i]}"
		HLSubject=$({ echo "${HLSubjectArray[$i]}" | sed "s~$replace_doublequote~$replace_quote~g"; } 2>&1)
		HLBody=$({ echo "${HLBodyArray[$i]}" | sed "s~$replace_doublequote~$replace_quote~g"; } 2>&1)
		HLDatePosted=$({ echo "${HLDatePostedArray[$i]}" | sed 's/.$//'; } 2>&1)
		HLDatePosted=$({ date -j -f "%Y-%m-%dT%H:%M:%S" "$HLDatePosted" "+%s"; } 2>&1)

		case "$HLCommunityKey" in
		"59d8db95-7023-4e9b-8488-454d2b886b4b")
			topic_id="360001311753"
			;;
		"d9a56a4f-bf15-4426-8ea3-3ad437f89051")
			topic_id="360001311753"
			;;
		"3c4defb0-265b-4af5-9688-df94f187f229")
			topic_id="360001253514"
			;;
		"36a173bf-38e6-4799-955f-35fab3db5f46")
			topic_id="360001253534"
			;;
		"3e987888-5d59-41e2-be98-b7e00bf49e6b")
			topic_id="360001253514"
			;;
		esac

		for readfile2 in step-3-ZD-HL-db-match.csv; do

			file2=$({ cat "$readfile2"; } 2>&1)
			ZDToParse=$({ echo "$file2"; } 2>&1)

			SAVEIFS=$IFS                # Save current IFS
			IFS=$'\n'                   # Change IFS to new line
			ZDToParseArray=($ZDToParse) # split to array $names
			IFS=$SAVEIFS                # Restore IFS

			for ((j = 0; j < ${#ZDToParseArray[@]}; j++)); do
				ZDKeyMatch=$({ echo "${ZDToParseArray[j]}" | cut -d \, -f1; } 2>&1)
				HLCommunityKeyMatch=$({ echo "${ZDToParseArray[j]}" | cut -d \, -f2; } 2>&1)

				#echo "ZDKeyMatch = $ZDKeyMatch"
				#echo "HLCommunityKeyMatch = $HLCommunityKeyMatch"
				if [[ "$HLCommunityKeyMatch" == "$HLContactKey" ]]; then
					# Create Post
					#	echo "Matching Contact Key"
					if [[ "$HLSubject" != "RE: "* ]]; then
						updateContents=$({ curl -X POST -H "Cache-Control: no-cache" -H "Content-Type: application/json" -v -u supportbot@act-on.net/token:123 -d '{"post": {"title": "'"$HLSubject"'", "details": "'"$HLBody"'", "author_id": '"$ZDKeyMatch"', "topic_id": '"$topic_id"', "created_at": '"$HLDatePosted"'}, "notify_subscribers": false}' https://actonsoftware.zendesk.com/api/v2/community/posts.json; } 2>&1)

						#updateContents=$( { echo -X POST -H "Cache-Control: no-cache" -H "Content-Type: application/json" -v -u supportbot@act-on.net/token:123 -d '{"post": {"title": "'"$HLSubject"'", "details": "'"$HLBody"'", "author_id": '"$ZDKeyMatch"', "topic_id": '"$topic_id"', "created_at": '"$HLDatePosted"'}, "notify_subscribers": false}'  https://actonsoftware.zendesk.com/api/v2/community/posts.json ; } 2>&1 )

						echo "updateContents = $updateContents"
						echo "$updateContents" >>log-output/insert-community-log.txt
						echo "" >>log-output/insert-community-log.txt
						echo "" >>log-output/insert-community-log.txt
					fi
				fi
			done
		done
	done
done

echo "Bazinga"
