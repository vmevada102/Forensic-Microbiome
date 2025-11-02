#!/usr/bin/env bash
# run_amr_detection.sh <read1> <read2> <out_amr_tsv> <amr_db_dir>
R1=$1
R2=$2
OUT=$3
AMR_DB=$4

set -euo pipefail

# quick assembly then abricate (user may replace with amrfinder workflow)
WORKDIR=$(mktemp -d)
megahit -1 ${R1} -2 ${R2} -o ${WORKDIR} --min-contig-len 500
ASSEMBLY=${WORKDIR}/final.contigs.fa
if [ ! -f ${ASSEMBLY} ]; then
  # megahit output contigs may be named differently depending on version
  if [ -f ${WORKDIR}/final.contigs.fa ]; then
    ASSEMBLY=${WORKDIR}/final.contigs.fa
  elif [ -f ${WORKDIR}/contigs.fa ]; then
    ASSEMBLY=${WORKDIR}/contigs.fa
  else
    echo "Assembly not found"
    touch ${OUT}
    exit 0
  fi
fi

# run abricate if available
if command -v abricate >/dev/null 2>&1; then
  abricate --db card ${ASSEMBLY} > ${OUT} || true
elif command -v amrfinder >/dev/null 2>&1; then
  amrfinder -n ${ASSEMBLY} -o ${OUT} || true
else
  echo "No AMR tool (abricate or amrfinder) found in PATH" > ${OUT}
fi

# cleanup
rm -rf ${WORKDIR}
