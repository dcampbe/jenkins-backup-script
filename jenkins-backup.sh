#!/bin/bash -xe

##################################################################################
function usage(){
  echo "usage: ./jenkins-backup.sh /path/to/jenkins_home archive.tar.gz [/some/target/dir]"
}
##################################################################################

readonly JENKINS_HOME=$1
readonly DIST_FILE=$2
readonly TARGET_DIR=$3
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
readonly TMP_DIR="$CUR_DIR/tmp"
readonly ARC_NAME="jenkins-backup"
readonly ARC_DIR="$TMP_DIR/$ARC_NAME"
readonly TMP_TAR_NAME="archive.tar.gz"

if [ -z "$JENKINS_HOME" -o -z "$DIST_FILE" ] ; then
  usage
  exit 1
fi

if [[ -f "$TMP_DIR/$TMP_TAR_NAME" ]]; then
    rm $TMP_DIR/$TMP_TAR_NAME
fi
rm -rf $ARC_DIR
mkdir -p $ARC_DIR/plugins
mkdir -p $ARC_DIR/jobs
mkdir -p $ARC_DIR/users

cp $JENKINS_HOME/*.xml $ARC_DIR
cp $JENKINS_HOME/plugins/*.jpi $ARC_DIR/plugins
cp -R $JENKINS_HOME/users/* $ARC_DIR/users

cd $JENKINS_HOME/jobs/
ls -1 | while read job_name
do
  mkdir -p $ARC_DIR/jobs/"$job_name"/
  cp $JENKINS_HOME/jobs/"$job_name"/*.xml $ARC_DIR/jobs/"$job_name"/
done

cd $TMP_DIR
tar czvf $TMP_TAR_NAME $ARC_NAME/*
cp $TMP_DIR/$TMP_TAR_NAME $DIST_FILE

if [ ! -z "$TARGET_DIR"  ] ; then
echo "mv $DIST_FILE $TARGET_DIR"
  mv $DIST_FILE $TARGET_DIR
fi

exit 0
