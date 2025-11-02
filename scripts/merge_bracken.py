#!/usr/bin/env python3
"""merge_bracken.py -- merges per-sample bracken.species into a species x sample table"""
import argparse, os, pandas as pd, glob

p = argparse.ArgumentParser()
p.add_argument('--bracken_dir', required=True)
p.add_argument('--out', required=True)
args = p.parse_args()

files = sorted([f for f in glob.glob(os.path.join(args.bracken_dir,'*.bracken.species'))])
if len(files) == 0:
    raise SystemExit('No .bracken.species files found in ' + args.bracken_dir)

df_list = []
for f in files:
    sample = os.path.basename(f).split('.bracken.species')[0]
    t = pd.read_csv(f, sep='\t', header=None, comment='#', engine='python')
    # expected columns: name, taxid, fraction_total_reads, new_est_reads, ...
    # if headerless, attempt to handle common formats
    if t.shape[1] >= 4:
        t = t.iloc[:, :4]
        t.columns = ['name','taxid','fraction','est_reads']
    else:
        t.columns = ['name','est_reads']
    t2 = t[['name','est_reads']].copy()
    t2.columns = ['name', sample]
    df_list.append(t2)

merged = df_list[0]
for df in df_list[1:]:
    merged = merged.merge(df, on='name', how='outer')
merged = merged.fillna(0)
merged.to_csv(args.out, sep='\t', index=False)
print('Wrote merged table to', args.out)
