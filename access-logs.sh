#!/bin/bash

# Set the following environmental variables to use:
# 	NAMESPACE
# 	DOMAIN
# 	VH_NAME
# 	VES_P12_PASSWORD
# 	P12_FILE

if [[ -z "$NAMESPACE" ]]; then
	echo "Error: Set the evironmental variable NAMESPACE you want to view logs for."
	exit 1
fi
if [[ -z "$VES_P12_PASSWORD" ]]; then
	echo "Error: Set the evironmental variable VES_P12_PASSWORD to authenticate your P12 file."
	exit 1
fi
if [[ -z "$P12_FILE" ]]; then
	echo "Error: Set the evironmental variable P12_FILE as the path to your P12 file."
	exit 1
fi
if [[ -z "$DOMAIN" ]]; then
	echo "Error: Set the evironmental variable DOMAIN, this will be the domain in https://$DOMAIN.console.ves.volterra.io."
	exit 1
fi
if [[ -z "$VH_NAME" ]]; then
	echo "Error: Specify the virtual host name in the evironmental variable VH_NAME."
	exit 1
fi

NOW=$(date +%s)
START_TIME=$(($NOW - 86400)) # 24 hours ago

QUERY="{vh_name=\"$VH_NAME\"}"
data_binary=$(jq -c -n \
				--arg query "$QUERY" \
				--arg namespace "$NAMESPACE" \
				--arg start_time "$START_TIME" \
				--arg now "$NOW" \
				'{"query":$query,"namespace":$namespace,"start_time":$start_time,"end_time":$now}'
			)
echo $data_binary

logs=$(curl -s --cert-type P12 \
		--cert "$P12_FILE:$VES_P12_PASSWORD" \
		-X POST "https://$DOMAIN.console.ves.volterra.io/api/data/namespaces/$NAMESPACE/access_logs" \
		--data-binary $data_binary \
		--compressed | jq '[.logs[] | fromjson]')
echo $logs| jq . > "${NOW}-accesslogs.json"
