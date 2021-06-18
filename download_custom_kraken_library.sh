#!/bin/bash


#####################################################################################################################
# Note that input fasta files should match the required kraken fasta description. See make_seqid2taxid_map.pl
#####################################################################################################################

if [ $# -ne 5 ]; then
  echo "Usage: bash $0 <kmer length> <suffix> <fasta file containing all viral references> <first taxonomy id for the viral library to add> <include human genome? 0 or 1>" >> log
  exit 1
fi

K=$1
SUFFIX=$2
LIBRARY_INPUT=$3
BASE_NODE_ID=$4
INCLUDE_HUMAN_GENOME=$5

echo "--------------downloading the library--------------" &>> log &&

DB_NAME="Kraken2StandardDB_k_${K}_${SUFFIX}"

###############################################################################
if [ ! -d ${DB_NAME}/taxonomy ]; then
  echo "Downloading taxonomy for database ${DB_NAME}" >> log
  ./kraken2-build --download-taxonomy --db $DB_NAME --use-ftp &>>log
fi
if [ $INCLUDE_HUMAN_GENOME -eq 1 ]; then
    if [ ! -d ${DB_NAME}/library/human ]; then
      echo "Downloading human library from NCBI for database ${DB_NAME}" >> log
      ./kraken2-build --download-library human --db ${DB_NAME} --use-ftp &>>log
    fi
fi
###############################################################################

NODES_FILE="${DB_NAME}/taxonomy/nodes.dmp"
NAMES_FILE="${DB_NAME}/taxonomy/names.dmp"

#BASE_NODE_ID=$(head -n 1 $LIBRARY_INPUT | awk '{split($0, array, "|"); print(array[3])}')
LAST_NODE_ID=$(expr $BASE_NODE_ID + $(grep ">" $LIBRARY_INPUT | wc -l))
echo "virus first and last tax ids are: $BASE_NODE_ID, $LAST_NODE_ID" >> log
################################################################################
# Add taxonomy information for the viruses
#nodes.dmp file consists of taxonomy nodes. The description for each node includes the following
#fields:
#        tax_id                                  -- node id in GenBank taxonomy database
#        parent tax_id                           -- parent node id in GenBank taxonomy database
#        rank                                    -- rank of this node (superkingdom, kingdom, ...)
#        embl code                               -- locus-name prefix; not unique
#        division id                             -- see division.dmp file
#        inherited div flag  (1 or 0)            -- 1 if node inherits division from parent
#        genetic code id                         -- see gencode.dmp file
#        inherited GC  flag  (1 or 0)            -- 1 if node inherits genetic code from parent
#        mitochondrial genetic code id           -- see gencode.dmp file
#        inherited MGC flag  (1 or 0)            -- 1 if node inherits mitochondrial gencode from parent
#        GenBank hidden flag (1 or 0)            -- 1 if name is suppressed in GenBank entry lineage
#        hidden subtree root flag (1 or 0)       -- 1 if this subtree has no sequence data yet
#        comments                                -- free-text comments and citations
#
#Taxonomy names file (names.dmp):
#        tax_id                                  -- the id of node associated with this name
#        name_txt                                -- name itself
#        unique name                             -- the unique variant of this name if name not unique
#        name class                              -- (synonym, common name, ...)

###############################################################################
# Add the tax ids with parent to be virus family in nodes.py
if [ $(grep $BASE_NODE_ID $NODES_FILE | wc -l) == 0 ]; then
  for NODE_ID in $(seq $BASE_NODE_ID $LAST_NODE_ID); do
    echo -e "${NODE_ID}\t|\t10239\t|\tfamily\t|\t\t|\t9\t|\t1\t|\t1\t|\t1\t|\t0\t|\t1\t|\t0\t|\t0\t|\t\t|" >> $NODES_FILE
  done
fi
###############################################################################
# Add the tax ids and names to names.py
VIRUS_NAMES=$(grep ">" $LIBRARY_INPUT | awk '{split($0, array, "|"); print(array[3])}')
if [ $(grep $BASE_NODE_ID $NAMES_FILE | wc -l) == 0 ]; then
  NODE_ID=$BASE_NODE_ID
  for SEQ_NAME in $VIRUS_NAMES; do
    echo -e "${NODE_ID}\t|\t$SEQ_NAME\t|\t\t|\tacronym\t|" >> $NAMES_FILE
    NODE_ID=$(expr $NODE_ID + 1)
  done
fi

rm -r ${DB_NAME}/library/added &>>log
./kraken2-build --add-to-library $LIBRARY_INPUT --db ${DB_NAME} &>>log
