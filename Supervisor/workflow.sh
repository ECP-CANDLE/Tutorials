#!/bin/bash
set -eu

# WORKFLOW SH
# Main user entry point

if [[ ${#} != 1 ]]
then
  echo "Usage: ./workflow.sh EXPERIMENT_ID"
  exit 1
fi
export EXPID=$1

# Turn off Swift/T debugging
export TURBINE_LOG=0 TURBINE_DEBUG=0 ADLB_DEBUG=0

# Find my installation directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 ) ; /bin/pwd )

export MODEL_SH=$EMEWS_PROJECT_ROOT/model.sh
export MODEL_NAME="p3b1"

# Set the output directory
export TURBINE_OUTPUT=$EMEWS_PROJECT_ROOT/experiments/$EXPID
mkdir -pv $TURBINE_OUTPUT

# Total number of processes available to Swift/T
# Of these, 2 are reserved for the system
export PROCS=3

# EMEWS resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

# mlrMBO settings
PARAM_SET_FILE=$EMEWS_PROJECT_ROOT/data/params.R
MAX_CONCURRENT_EVALUATIONS=2
MAX_ITERATIONS=3

# Benchmark settings
BENCHMARK_TIMEOUT=${BENCHMARK_TIMEOUT:-3600}

# Construct the command line given to Swift/T
CMD_LINE_ARGS=( -pp=$MAX_CONCURRENT_EVALUATIONS
                -it=$MAX_ITERATIONS
                -param_set_file=$PARAM_SET_FILE
              )

EQR=$EMEWS_PROJECT_ROOT/EQ-R
# USER: set the R variable to your R installation
R=$HOME/Public/sfw/R-3.4.3/lib/R
export LD_LIBRARY_PATH=$R/lib:$R/library/Rcpp/lib:$R/library/RInside/lib
MACHINE=""
ENVS=""

set -x
swift-t $MACHINE -p -n $PROCS \
        -I $EQR -r $EQR $ENVS \
        $EMEWS_PROJECT_ROOT/workflow.swift ${CMD_LINE_ARGS[@]}

echo WORKFLOW COMPLETE.
