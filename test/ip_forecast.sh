#!/bin/bash

#This is a coding exercise to demonstrate you can write a shell script that will take input, interact with APIs, parse and manipulate the returned data.
#
#You will write a script to fetch the weather forecast for the next 3 days for a given IP address.
#
#For this, you will query 2 APIs and parse the output using jq (https://stedolan.github.io/jq/)
#
#Using the http://ipinfo.io API, you will get the location of an IP which you will use against DarkSky's API to retrieve the forecast.
#
#
#APIs:
#
#http://ipinfo.io/<ip>
#
#https://api.darksky.net/forecast/6ce2cb95ebf7afee7f2d76afcc037fb3/<loc> where loc is 37.8267,-122.4233 for example
#
#
#If no ip is passed to ipinfo, it will default to use your current location.
#
#Your output should be similar to the following:
#
#
#~/Documents/work> ./ip_forecast.sh
#Weather forecast for my location
#2019-01-02: Clear throughout the day.
#2019-01-03: Partly cloudy throughout the day.
#2019-01-04: Mostly cloudy throughout the day.
#
#~/Documents/work> ./ip_forecast.sh http://212.95.67.222
#Weather forecast for IP http://212.95.67.222
#2019-01-01: Mostly cloudy until evening.
#2019-01-02: Mostly cloudy until evening.
#2019-01-03: Foggy overnight.
#
#
#

## 3 days in seconds
days=259200


curl -s http://ipinfo.io/ > ipinfo.json

my_ip=$( cat ipinfo.json | jq '.ip' )
ip=${1:-$my_ip}

loc=$( cat ipinfo.json | jq ''.loc'' | sed -e 's/\"//g' )

curl -s "https://api.darksky.net/forecast/6ce2cb95ebf7afee7f2d76afcc037fb3/${loc}" > weather.json

epoch_now=$( date +%s )
for days in 0 1 2; do

    my_date=$( cat weather.json | jq ".daily.data[${days}].time")
    r_date=$( date +%Y-%m-%d -d @${my_date} )
    forecast=$( cat weather.json | jq ".daily.data[${days}].summary" )
    printf "${r_date}: ${forecast}\n"
done


