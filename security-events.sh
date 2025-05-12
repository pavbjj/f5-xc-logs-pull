if [ "$#" -ne 6 ]; then
    echo "Illegal number of parameters"
    echo "domain namespace APIToken Load-Balancer start_time end_time"
    exit 1
fi


curl --location --request POST "https://$1.console.ves.volterra.io/api/data/namespaces/$2/app_security/events" \
--header "Authorization: APIToken $3" \
--header "Content-Type: application/json" \
--data-raw '{
    "query": "{vh_name=\"ves-io-http-loadbalancer-'$4'\"}",
    "namespace": "'$2'",
    "aggs": {},
    "start_time": "'$5'",
    "end_time": "'$6'"
}' |  jq "[.events[] | fromjson]"
