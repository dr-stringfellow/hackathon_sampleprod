# Setting everything up

colors="20,40,60,80,100,120,140,160,180,200,220,240,260,280,300,320,340,360,380,400,420,440,460,480,500"

IFS=',' read -r -a array <<< "$colors"

size=${#array[@]}
echo $size
index=$(($RANDOM % $size))
echo $index
color=${array[$index]}
echo $color


echo "We're in directory: "
pwd
echo "Content: "
ls -l
echo "Which color are we generating"
echo $color

#git clone https://gitlab.cern.ch/bmaier/hgcal_reco_analysis.git UserCode

#RESULT=$?
#if [ $RESULT -eq 0 ]; then
#  echo "Success"
#else
#  echo "Failed"
#  exit
#fi


#echo "Did GitHub get cloned? "
pwd
ls -l
#echo "With everything? "
#ls -l UserCode

source /cvmfs/cms.cern.ch/cmsset_default.sh
source environ.sh
export SCRAM_ARCH=$ARCH
scram p CMSSW $CMSSWVERSION
cd $CMSSWVERSION/src/
mv ../../$USERCODE .
tar xvaf $USERCODE
eval `scram runtime -sh`
scram b -j 1
cd ../../

RANDINT=`shuf -i1-99999999 -n1`

tar xvaf configs_$VERSION.tgz

# Step 1
cp $VERSION/$1/step1.py .
sed -i "s|ZZZ|$color|g" step1.py
cmsRun step1.py seed=${RANDINT}

# NoPU
# Step 2/3
cp $VERSION/step2.py .
cmsRun step2.py seed=${RANDINT}
cp $VERSION/step3.py .
cmsRun step3.py seed=${RANDINT}

mv step2.root $1_${RANDINT}_step2_nopu.root
mv step3.root $1_${RANDINT}_step3_nopu.root

# WithPU
# Step 2/3
cp $VERSION/step2_pu.py .
cmsRun step2_pu.py seed=${RANDINT}
cp $VERSION/step3_pu.py .
cmsRun step3_pu.py seed=${RANDINT}

mv step2.root $1_${RANDINT}_step2_pu140.root
mv step3.root $1_${RANDINT}_step3_pu140.root

# Copying output
cd $CMSSWVERSION/src/

cmsRun ${CMSSW_BASE}/src/UserCode/HGCMLAnalyzer/python/run_pid_cfg.py inputFiles=file:../../$1_${RANDINT}_step3_nopu.root outputFile=../../$1_${RANDINT}_postproc_nopu.root withPU=0

cmsRun ${CMSSW_BASE}/src/UserCode/HGCMLAnalyzer/python/run_pid_cfg.py inputFiles=file:../../$1_${RANDINT}_step3_pu140.root outputFile=../../$1_${RANDINT}_postproc_pu140.root withPU=0

eval `scram unsetenv -sh`
cd ../../

FILE=$1_${RANDINT}_step3_pu140.root

if [ -f "$FILE" ]; then
    #gfal-copy $1_${RANDINT}_step2_nopu.root $DEST/$1_${RANDINT}_step2_nopu_${color}.root
    #gfal-copy $1_${RANDINT}_step3_nopu.root $DEST/$1_${RANDINT}_step3_nopu_${color}.root
    gfal-copy $1_${RANDINT}_postproc_nopu.root $DEST/$1_${RANDINT}_postproc_nopu_${color}.root
    #gfal-copy $1_${RANDINT}_step2_pu140.root $DEST/$1_${RANDINT}_step2_pu140_${color}.root
    #gfal-copy $1_${RANDINT}_step3_pu140.root $DEST/$1_${RANDINT}_step3_pu140_${color}.root
    gfal-copy $1_${RANDINT}_postproc_pu140.root $DEST/$1_${RANDINT}_postproc_pu140_${color}.root
fi

echo "Done."
