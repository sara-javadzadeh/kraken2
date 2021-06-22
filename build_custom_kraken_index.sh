#!/bin/bash
if [ $# -ne 2 ]; then
  echo "Usage: bash $0 <virus name, also the suffix for the database> <kmer length>"
  exit 1
fi

# Note that the minimizer length must be no more than 31 for nucleotide databases, and 15 for protein databases.
# Additionally, the minimizer length $\ell$ must be no more than the $k$-mer length. There is no upper bound on the value of $k$, but sequences less than $k$ bp in length cannot be classified.
# Kraken 2 also utilizes a simple spaced seed approach to increase accuracy. A number $s$ < $\ell$/4 can be chosen, and $s$ positions in the minimizer will be masked out during all comparisons.
virus=$1
K=$2
echo "Building database with virus $virus and k $K" >> log

# 0.89 is the ratio of the default kmer and minimizer (35 and 31).
# / 1 is to truncate the floating point number
M=$(awk "BEGIN{print (int($K * 0.89))}") &&
echo "For k = $K : Minimizer length = $M" >> log &&
S=$(awk "BEGIN{print (int( $M /4) - 1)}") &&
echo "For k = $K : Minimizer spaces = $S" >> log &&
DB_NAME="Kraken2StandardDB_k_${K}_${virus}"
rm ./${DB_NAME}/seqid2taxid.map ./${DB_NAME}/hash.k2d ./${DB_NAME}/opts.k2d ./${DB_NAME}/taxo.k2d &>>log
/usr/bin/time -v ./kraken2-build --build --db $DB_NAME --kmer-len $K --minimizer-len $M --minimizer-spaces $S &>>log &&
echo "done with k= $K" >> log
