#!/bin/bash

if [ $# -ne 3 ]; then
	echo "Usage: bash $0 <virus name> <input fasta> <base node id>"
    echo "<virus name>: virus name in lower case, e.g. hpv"
	echo "<input fasta>: path to the input fasta file containing all references of the same virus"
	echo "<base node id>: is the node id to label the custom reference genomes when adding to kraken2. Use 9000000 if adding a single virus type. If adding multiple virus types (e.g. HBV and HCV), indicate different base ids for each virus. for example, build HBV with base node 9000000 and HCV with base node 9100000."
	exit 1
fi
VIRUS_NAME=$1
LIBRARY_INPUT=$2
BASE_NODE_ID=$3
INCLUDE_HUMAN_GENOME=1
SUFFIX="${VIRUS_NAME}_hg";
for K in 25 ; do
  bash download_custom_kraken_library.sh $K $SUFFIX $LIBRARY_INPUT $BASE_NODE_ID $INCLUDE_HUMAN_GENOME &>> log
  bash build_custom_kraken_index.sh $SUFFIX $K
done
INCLUDE_HUMAN_GENOME=0
SUFFIX=$VIRUS_NAME
for K in 18 22 ; do
  bash download_custom_kraken_library.sh $K $SUFFIX $LIBRARY_INPUT $BASE_NODE_ID $INCLUDE_HUMAN_GENOME &>> log
  bash build_custom_kraken_index.sh $SUFFIX $K
done
