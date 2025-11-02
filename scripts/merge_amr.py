#!/usr/bin/env python3
"""merge_amr.py -- merges per-sample amr tsvs into presence/absence matrix"""
import argparse, os, glob, pandas as pd

p = argparse.ArgumentParser()
p.add_argument('--amr_dir', required=True)
p.add_argument('--out', required=True)
args = p.parse_args()

files = sorted(glob.glob(os.path.join(args.amr_dir,'*.amr.tsv')))
if len(files) == 0:
    # try abricate outputs
    files = sorted(glob.glob(os.path.join(args.amr_dir,'*.abricate')))
if len(files) == 0:
    print('No AMR files found in', args.amr_dir)
    open(args.out,'w').close()
    raise SystemExit

gene_sets = {}
samples = []
for f in files:
    sample = os.path.basename(f).split('.amr.tsv')[0]
    samples.append(sample)
    genes = set()
    try:
        df = pd.read_csv(f, sep='\t', comment='#', engine='python')
        # try to detect gene column
        cols = [c.lower() for c in df.columns]
        if 'gene' in cols:
            genes = set(df.iloc[:, cols.index('gene')].astype(str).tolist())
        elif 'name' in cols:
            genes = set(df.iloc[:, cols.index('name')].astype(str).tolist())
        else:
            # take first column
            genes = set(df.iloc[:,0].astype(str).tolist())
    except Exception as e:
        # fallback: read lines
        with open(f) as fh:
            for line in fh:
                line=line.strip()
                if line and not line.startswith('#'):
                    parts=line.split('\t')
                    genes.add(parts[0])
    gene_sets[sample] = genes

all_genes = sorted(set.union(*gene_sets.values()))
mat = pd.DataFrame(0, index=all_genes, columns=samples)
for s in samples:
    for g in gene_sets[s]:
        mat.at[g,s] = 1
mat.to_csv(args.out, sep='\t')
print('Wrote AMR matrix to', args.out)
