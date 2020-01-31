#!/bin/bash
#
# Copyright © 2017 Arm Ltd. All rights reserved.
# SPDX-License-Identifier: MIT
#

CMD=$( basename $0 )

# For pinning to a ref use this:
#DEFAULT_CLFRAMEWORKREVISION="branches/arm_compute_19_11" # Release 19.11
#
# For pinning to a revision use this:
DEFAULT_CLFRAMEWORKREVISION="94672fb2af6535adc6ea7fe8b8498580ad8cf3f4" #COMPMID-3003: Integrate assembly kernels utilizing MMLA instruction.

usage() {
    echo "Usage: $CMD (Use the default clframework SHA)"
    echo "Usage: $CMD -s <CLFRAMEWORK_SHA>"
    echo "Usage: $CMD -p (Print current default clframework SHA)"
  exit 0
}

PrintDefaultClframeworkSha() {
  echo $DEFAULT_CLFRAMEWORKREVISION
  exit 0;
}

function AssertZeroExitCode {
  EXITCODE=$?
  if [ $EXITCODE -ne 0 ]; then
    echo "$1"
    echo "+++ Command exited with code $EXITCODE. Please fix the above errors and re-run"
    exit 1
  fi
}

# process the options given
while getopts "s:phg:" opt; do
  case "$opt" in
    s) CLFRAMEWORK_SHA="$OPTARG";;
    p) PrintDefaultClframeworkSha;;
    g) DUMMY="$OPTARG";; # continue to accept -g for backward compatibility
    h|\?) usage;;
  esac
done
shift $((OPTIND - 1))

#
# This script is designed to be called from anywhere
# so it will resolve where to checkout out the clframework
# relative to its own location in armnn/scripts
#
SRC="${BASH_SOURCE[0]}"
# resolve $SRC until it is no longer a symlink
while [ -h "$SRC" ]; do
  DIR="$( cd -P "$( dirname "$SRC" )" >/dev/null && pwd )"
  SRC="$(readlink "$SRC")"
  # if $SRC was a relative symlink, we need to resolve it
  # relative to the path where the symlink file originally was
  [[ $SRC != /* ]] && SRC="$DIR/$SRC"
done
DIR="$( cd -P "$( dirname "$SRC" )" >/dev/null && pwd )"
pushd ${DIR} > /dev/null
cd ../..

if [ ! -d clframework ]; then
  git clone https://review.mlplatform.org/ml/ComputeLibrary clframework
  AssertZeroExitCode "Cloning CL Framework failed"
fi
pushd clframework > /dev/null

CLFRAMEWORKREVISION=$DEFAULT_CLFRAMEWORKREVISION
if [ ! -z "$CLFRAMEWORK_SHA" ]; then
    CLFRAMEWORKREVISION=$CLFRAMEWORK_SHA
fi

git fetch && git fetch https://review.mlplatform.org/ml/ComputeLibrary && git checkout ${CLFRAMEWORKREVISION}
AssertZeroExitCode "Fetching and checking out ${CLFRAMEWORKREVISION} failed"

# Set commit hook so we can submit reviews to gerrit
(curl -Lo `git rev-parse --git-dir`/hooks/commit-msg https://review.mlplatform.org/tools/hooks/commit-msg; chmod +x `git rev-parse --git-dir`/hooks/commit-msg)
AssertZeroExitCode "Setting commit hooks failed"

popd > /dev/null # out of clframework
popd > /dev/null # back to wherever we were when called
# Make sure the SHA of the revision that was checked out is the last line
# of output from the script... just in case we ever need it.
echo $CLFRAMEWORKREVISION
exit 0
