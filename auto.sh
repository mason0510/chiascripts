#!/bin/bash

CHIAX=$HOME/chiax
ROLE=Ploter

CONCURRENT_LIMIT=48
FARMER_KEY=
POOL_KEY=
PARA='-k 32 -b 10000 -r 4 -u 128 -n 1'
TMP_DIR="$CHIAX/cache"
FINAL_DIR="$CHIAX/data/nfs"
LOG_DIR="$CHIAX/logs/5-3-48"

function usage() {
  echo " $1 -[cfprtih]"
  echo "    -c concurrent   "
  echo "    -f farmer key   "
  echo "    -p pool key     "
  echo "    -r paras        "
  echo "    -t tmp dir      "
  echo "    -i final dir    "
  echo "    -h help         Show this help"
  #exit 0
}

while getopts 'h:c:f:p:r:t:i:' OPT; do
  case $OPT in
    c) CONCURRENT_LIMIT=$OPTARG    ;;
    f) FARMER_KEY=$OPTARG      ;;
    p) POOL_KEY=$OPTARG    ;;
    r) PARA=$OPTARG     ;;
    t) TMP_DIR=$OPTARG      ;;
    i) FINAL_DIR=$OPTARG    ;;
    *) usage $0             ;;
  esac
done

while getopts 'h:d:' OPT; do
  case $OPT in
    d) TAR_DIR=$OPTARG	;;
    *) usage $0		;;
  esac
done

function error() {
  echo "  <E> -> $1 ~"
  exit 1
}

function warn() {
  echo "  <W> -> $1 ~"
}

function info() {
  echo "  <I> -> $1 ~"
}

#########################################

echo "Start plots ~"
mkdir -p $LOG_DIR

function plots() {
  #
  cache=$1
  final=`ls -d $2/*/ |awk -F' ' '{print $1}'`
  info "plots cache in $cache"
  info "plots final in $final"
  COMMAND="chia plots create -f $FARMER_KEY -p $POOL_KEY $PARA -t $cache "

  for tg in $final; do
    while true; do
      #ps aux | grep "chia_harvester"
      #[ ! $? -eq 0 ] && echo "Wait for harvester ~" && sleep 60 && continue

      plotlist=`ps aux|grep chia| awk -F " " '{print $13}'`
      ploted=0
      for l in $plotlist; do
        [ "xplots" == "x$l" ] && ploted=`expr $ploted + 1`
        # echo "Has plots = $ploted"
      done

      count=`expr $CONCURRENT_LIMIT - $ploted`
      echo "Still can launch $count chia plots upto $CONCURRENT_LIMIT ~"
      [ $count -eq 0 -o $count -lt 0 ] && date && sleep 600 && continue
      break
    done

    echo "Launch one chia plots to $tg"
    dt=$(date +%Y%m%d%H%M-%s)
    nohup $COMMAND -d $tg > $LOG_DIR/plot-$dt.log 2>&1 &
    echo "nohup $COMMAND -d $tg > $LOG_DIR/plot-$dt.log 2>&1 &"
    echo "plots to dir $tg over."
    sleep 300
  done

}


while true; do
 plots $TMP_DIR/nvme1 $FINAL_DIR
done


