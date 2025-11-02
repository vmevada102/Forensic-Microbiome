# Snakefile - shotgun preprocessing + profiling + report rendering
import os
import pandas as pd

configfile: 'config.yaml'

RAW_DIR = config['raw_dir']
RESULTS = config['results_dir']
SAMPLES_TSV = config['samples_tsv']
THREADS = config['threads']

# read samples to build targets
SAMPLES_DF = pd.read_csv(SAMPLES_TSV, sep='\t')
SAMPLES = SAMPLES_DF['sample_id'].tolist()

rule all:
    input:
        expand(os.path.join(RESULTS,'kraken2','{sample}.kraken.report'), sample=SAMPLES),
        os.path.join(RESULTS,'bracken','bracken_species_table.tsv'),
        os.path.join(RESULTS,'amr','amr_matrix.tsv'),
        os.path.join(RESULTS,'report','Microbiome_Group_Comparison_Report.html')

rule fastp:
    input:
        r1=lambda wildcards: os.path.join(RAW_DIR, wildcards.sample + '_R1.fastq.gz'),
        r2=lambda wildcards: os.path.join(RAW_DIR, wildcards.sample + '_R2.fastq.gz')
    output:
        r1=os.path.join(RESULTS,'qc','{sample}_R1.trim.fastq.gz'),
        r2=os.path.join(RESULTS,'qc','{sample}_R2.trim.fastq.gz')
    threads: THREADS
    shell:
        """{config[fastp]} -i {input.r1} -I {input.r2} -o {output.r1} -O {output.r2} --detect_adapter_for_pe --thread {threads} """

rule kneaddata:
    input:
        r1=os.path.join(RESULTS,'qc','{sample}_R1.trim.fastq.gz'),
        r2=os.path.join(RESULTS,'qc','{sample}_R2.trim.fastq.gz')
    output:
        r1=os.path.join(RESULTS,'kneaddata','{sample}','{sample}_paired_1.fastq'),
        r2=os.path.join(RESULTS,'kneaddata','{sample}','{sample}_paired_2.fastq')
    threads: THREADS
    shell:
        """mkdir -p {os.path.dirname(output.r1)}
        {config[kneaddata]} --input {input.r1} --input {input.r2} --output {os.path.dirname(output.r1)} --reference-db {config[human_bowtie2_index]} --threads {threads}
        """

rule kraken2:
    input:
        r1=os.path.join(RESULTS,'kneaddata','{sample}','{sample}_paired_1.fastq'),
        r2=os.path.join(RESULTS,'kneaddata','{sample}','{sample}_paired_2.fastq')
    output:
        report=os.path.join(RESULTS,'kraken2','{sample}.kraken.report'),
        out=os.path.join(RESULTS,'kraken2','{sample}.kraken.out')
    threads: THREADS
    shell:
        """mkdir -p {os.path.dirname(output.report)}
        {config[kraken2]} --db {config[kraken_db]} --paired {input.r1} {input.r2} --report {output.report} --output {output.out} --use-names --threads {threads}
        """

rule bracken:
    input:
        report=os.path.join(RESULTS,'kraken2','{sample}.kraken.report')
    output:
        bracken=os.path.join(RESULTS,'bracken','{sample}.bracken.species')
    threads: 2
    shell:
        """mkdir -p {os.path.dirname(output.bracken)}
        {config[bracken]} -d {config[bracken_db]} -i {input.report} -o {output.bracken} -r 150 -l S
        """

rule merge_bracken:
    input:
        expand(os.path.join(RESULTS,'bracken','{sample}.bracken.species'), sample=SAMPLES)
    output:
        table=os.path.join(RESULTS,'bracken','bracken_species_table.tsv')
    run:
        shell('python3 scripts/merge_bracken.py --bracken_dir {os.path.join(RESULTS,"bracken")} --out {output.table}')

rule amr_detection:
    input:
        r1=os.path.join(RESULTS,'kneaddata','{sample}','{sample}_paired_1.fastq'),
        r2=os.path.join(RESULTS,'kneaddata','{sample}','{sample}_paired_2.fastq')
    output:
        amr=os.path.join(RESULTS,'amr','{sample}.amr.tsv')
    threads: THREADS
    shell:
        """mkdir -p {os.path.dirname(output.amr)}
        scripts/run_amr_detection.sh {input.r1} {input.r2} {output.amr} {config[amr_db_dir]}
        """

rule merge_amr:
    input:
        expand(os.path.join(RESULTS,'amr','{sample}.amr.tsv'), sample=SAMPLES)
    output:
        matrix=os.path.join(RESULTS,'amr','amr_matrix.tsv')
    run:
        shell('python3 scripts/merge_amr.py --amr_dir {os.path.join(RESULTS,"amr")} --out {output.matrix}')

rule render_report:
    input:
        bracken_table=os.path.join(RESULTS,'bracken','bracken_species_table.tsv'),
        samples=SAMPLES_TSV
    output:
        html=os.path.join(RESULTS,'report','Microbiome_Group_Comparison_Report.html')
    shell:
        """mkdir -p {os.path.join(RESULTS,'report')}
        {config[Rscript]} -e "rmarkdown::render('{config[rmd_report]}', params=list(bracken_table='{input.bracken_table}', samples_tsv='{input.samples}'), output_file='{output.html}')"
        """
