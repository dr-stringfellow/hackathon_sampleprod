VERSION="v5_monochrome_clue3d_minrh1"
BASEDIR="/store/group/dpg_hgcal/comm_hgcal/bmaier/clue3d/"$VERSION"/"
SE="gsiftp://eoscmsftp.cern.ch/eos/cms"
DEST=$SE$BASEDIR
CMSSWVERSION="CMSSW_12_4_0_pre2"
ARCH="slc7_amd64_gcc10"
USERCODE="usercode_v5_monochrome_clue3d_minrh1.tgz"

gfal-mkdir $DEST

