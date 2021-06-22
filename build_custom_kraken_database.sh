#!/bin/bash

if [ $# -ne 3 ]; then
	echo "Usage: bash $0 <virus name> <input fasta> <base node id>"
    echo "<virus name>: virus name in lower case, e.g. hpv"
	echo "<input fasta>: path to the input fasta file containing all references of the same virus"
	echo "<base node id>: As the viral references are added to Kraken2 externally, the taxonomy information for the custom reference file should be provided (such as node IDs). Our custom database script creates taxonomy IDs for all the references in the input FASTA file, starting from the <base node id> and incrementing by 1. For <base node id>, choose a large number that is not repeated in the default taxonomy labeling in Kraken. Use 9000000 if only working on one virus type. To avoid confusions in the analysis, we suggest using a different base node ID if you are working with multiple viruses, even when creating different custom Kraken2 databases. For example, use 9000000 for HBV and 9100000 for HCV, if you are working on these two viruses."
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
