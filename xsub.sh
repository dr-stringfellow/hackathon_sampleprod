rm -f tmp
sed 's/XXX/'$1'/g' $2 > tmp
condor_submit tmp
rm -f tmp
