#!/bin/bash



##################HPV
LIBRARY_INPUT="/nucleus/projects/saraj/sample_data/vifi_data/hpv.unaligned_with_tax_id.fasta"
BASE_NODE_ID=9000000
INCLUDE_HUMAN_GENOME=1
SUFFIX="hpv_hg";
#for K in 25 ; do
#  bash download_custom_kraken_library.sh $K $SUFFIX $LIBRARY_INPUT $BASE_NODE_ID $INCLUDE_HUMAN_GENOME &>> log
#  bash build_custom_kraken_index.sh $SUFFIX $K
#done
INCLUDE_HUMAN_GENOME=0
SUFFIX="hpv"
for K in 22 ; do
  bash download_custom_kraken_library.sh $K $SUFFIX $LIBRARY_INPUT $BASE_NODE_ID $INCLUDE_HUMAN_GENOME &>> log
  bash build_custom_kraken_index.sh $SUFFIX $K
done

exit 0

##################HCV
LIBRARY_INPUT="/nucleus/projects/saraj/sample_data/hcv/ncbi/hcv_complete_genome.fasta"
BASE_NODE_ID=9200000
INCLUDE_HUMAN_GENOME=1
SUFFIX="hcv_hg";
#for K in 20 25 ; do
#  bash download_custom_kraken_library.sh $K $SUFFIX $LIBRARY_INPUT $BASE_NODE_ID $INCLUDE_HUMAN_GENOME &>> log
#  bash build_custom_kraken_index.sh $SUFFIX $K
#done
INCLUDE_HUMAN_GENOME=0
SUFFIX="hcv"
for K in 24 ; do
  bash download_custom_kraken_library.sh $K $SUFFIX $LIBRARY_INPUT $BASE_NODE_ID $INCLUDE_HUMAN_GENOME &>> log
  bash build_custom_kraken_index.sh $SUFFIX $K
done

#################EBV
LIBRARY_INPUT="/nucleus/projects/saraj/sources/ViFi/viral_data/ebv/ebv.unaligned.fasta"
BASE_NODE_ID=9300000
INCLUDE_HUMAN_GENOME=1
SUFFIX="ebv_hg";
for K in 25 ; do
  bash download_custom_kraken_library.sh $K $SUFFIX $LIBRARY_INPUT $BASE_NODE_ID $INCLUDE_HUMAN_GENOME &>> log
  bash build_custom_kraken_index.sh $SUFFIX $K
done
INCLUDE_HUMAN_GENOME=0
SUFFIX="ebv"
for K in 24 ; do
  bash download_custom_kraken_library.sh $K $SUFFIX $LIBRARY_INPUT $BASE_NODE_ID $INCLUDE_HUMAN_GENOME &>> log
  bash build_custom_kraken_index.sh $SUFFIX $K
done
