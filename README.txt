Snakemake pipeline for shotgun microbiome preprocessing and forensic-focused report
-------------------------------------------------------------------------------
Files in this archive:
- Snakefile
- config.yaml  (EDIT this to specify paths and DBs)
- scripts/merge_bracken.py
- scripts/merge_amr.py
- scripts/run_amr_detection.sh
- scripts/render_report.sh

Usage:
1. Edit config.yaml: set raw_dir, results_dir, samples_tsv, and database/tool paths.
2. Place your paired FASTQ files in raw_dir named <sample>_R1.fastq.gz and <sample>_R2.fastq.gz.
3. Ensure samples_tsv (tab-separated) contains a header and a 'sample_id' column matching file sample names.
4. Run: snakemake --cores 16

Notes:
- The AMR detection step uses megahit + abricate by default; replace run_amr_detection.sh with your preferred AMR workflow if needed.
- The report rendering depends on the RMarkdown file 'Microbiome_Group_Comparison_Report.Rmd' being present in the same working directory.
