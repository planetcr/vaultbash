#!/bin/bash
echo email address,username,email status,drive status > result.csv
COOKIE=""
MATTER_GUID=""

while IFS= read -r USER

do
	#Remove any trailing space or garbage
	USER=${USER//[$'\t\r\n ']}
	#Get just the email address
	EXPORT_NAME=${USER%@*}
	echo Vaulting $USER
	
	rm response.out 
	sleep 1
	curl -i -s -k  -X $'PUT' \
    -H $'User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:45.0) Gecko/20100101 Firefox/45.0' -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Framework-Xsrf-Token: AESnhQQGXTFyxT_EH04ADULb2esk_prDHA:1492176559674' -H $'Referer: https://ediscovery.google.com/discovery/?pli=1' \
    -b "$COOKIE" \
    --data-binary "q=%7B%221%22:%22%22,%222%22:%5B%22$USER%22%5D,%228%22:%5B1%5D,%2210%22:0,%2212%22:1,%2214%22:0,%2215%22:1%7D&n=$EXPORT_NAME-email&acl_expansion=false" \
    "https://ediscovery.google.com/discovery/matters/$MATTER_GUID/exports?hl=en" -o response.out
	
#	cat response.out
	EMAIL_RESPONSE="unknown error"
	
	if grep -q SEARCH "response.out"; then
		EMAIL_RESPONSE="not licensed"	
	fi

	if grep -q exportly "response.out"; then
		EMAIL_RESPONSE="created"	
	fi

	if grep -q 500 "response.out"; then
		EMAIL_RESPONSE="not found"	
	fi
	
	rm response.out 
	sleep 1
	curl -i -s -k  -X $'PUT' \
    -H $'User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:45.0) Gecko/20100101 Firefox/45.0' -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Framework-Xsrf-Token: AESnhQQGXTFyxT_EH04ADULb2esk_prDHA:1492176559674' -H $'Referer: https://ediscovery.google.com/discovery/?pli=1' \
    -b "$COOKIE" \
    --data-binary "q=%7B%221%22:%22%22,%222%22:%5B%22$USER%22%5D,%228%22:%5B2%5D,%2210%22:0,%2212%22:1,%2214%22:0,%2215%22:1%7D&n=$EXPORT_NAME-drive&acl_expansion=false" \
    "https://ediscovery.google.com/discovery/matters/$MATTER_GUID/exports?hl=en" -o response.out
	
#	cat response.out
	DRIVE_RESPONSE="unknown error"
	
	if grep -q SEARCH "response.out"; then
		DRIVE_RESPONSE="not licensed"	
	fi

	if grep -q exportly "response.out"; then
		DRIVE_RESPONSE="created"	
	fi

	if grep -q 500 "response.out"; then
		DRIVE_RESPONSE="not found"	
	fi

	
	echo "$USER,$EXPORT_NAME,$EMAIL_RESPONSE,$DRIVE_RESPONSE" >> result.csv
	
done < vault_users.csv