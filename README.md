# 🧬 Forensic Shotgun Microbiome Pipeline
**Comprehensive Snakemake workflow for oral and forensic microbiome analysis**

This repository provides an **end-to-end, reproducible pipeline** for shotgun metagenomic data processing, designed especially for **forensic microbiome investigations**.  
It automates all major stages — from raw FASTQ reads to taxonomic profiling, AMR gene detection, and a fully rendered **RMarkdown forensic report** — enabling comparative analysis across lifestyle (smoking, diet) and demographic (age, sex) variables.

---

## 🚀 Key Features
- **Preprocessing**
  - Adapter & quality trimming with **Fastp**
  - Host (human) read removal via **Kneaddata**
- **Taxonomic Profiling**
  - **Kraken2 + Bracken** for accurate species-level abundance estimation  
- **Functional & AMR Analysis**
  - **AMR detection** using Abricate or AMRFinder  
  - Co-occurrence network (GEXF) generation for **AMR gene relationships**
- **Statistical Analysis & Reporting**
  - Automatic rendering of the **`Microbiome_Group_Comparison_Report.Rmd`**  
  - Multivariable statistical models with **MaAsLin2**
  - Integrated **Random Forest classifier** with ROC and calibration plots
  - Forensic summaries per `case_id` (similarity metrics, dominant taxa, AMR profiles)
- **Reproducible workflow**
  - Implemented in **Snakemake**
  - Configurable via a simple `config.yaml`

---

## ⚙️ Installation & Setup

### 1️⃣ Clone this repository
```bash
git clone https://github.com/<your-username>/forensic-microbiome-pipeline.git
cd forensic-microbiome-pipeline
```

### 2️⃣ Create and activate Conda environment
This project includes a Conda environment file (`environment.yml`) that installs all required tools and R packages.

```bash
conda env create -f environment.yml
conda activate forensic-microbiome
```

Verify installations:
```bash
fastp -v
kraken2 --version
Rscript -e "library(phyloseq); library(DESeq2); cat('R packages OK\n')"
```

---

## 🧩 How to Run the Pipeline

### Step 1 — Prepare input data
Organize paired-end FASTQ files as:
```
data/raw_fastq/
 ├── Sample1_R1.fastq.gz
 ├── Sample1_R2.fastq.gz
 ├── Sample2_R1.fastq.gz
 └── Sample2_R2.fastq.gz
```

Provide a metadata file `config/samples.tsv`:
```
sample_id	group_smoking	group_diet	age	sex	batch	case_id	location	substrate
Sample1	yes	veg	32	M	A1	C01	mouth	swab
Sample2	no	nonveg	29	F	A1	C02	mouth	swab
```

### Step 2 — Edit configuration
Open and update **`config.yaml`** to match your environment (paths, DBs, threads, classifier target).

### Step 3 — Run Snakemake workflow
From the main directory (where the Snakefile is located):
```bash
snakemake --use-conda --cores 16
```

Or, for cluster/HPC systems:
```bash
snakemake --use-conda --jobs 50 --cluster "sbatch -A your_account -t 24:00:00"
```

### Step 4 — View outputs
After completion, main outputs are written to `results/`:

| Output | Description |
|---------|--------------|
| `results/bracken/bracken_species_table.tsv` | Combined species-level abundance table |
| `results/amr/amr_matrix.tsv` | AMR gene presence/absence matrix |
| `results/report/Microbiome_Group_Comparison_Report.html` | Interactive forensic microbiome report |
| `results/report/forensic_case_summary.tsv` | Per-case forensic summary |
| `results/report/amr_networks/*.gexf` | AMR gene co-occurrence networks (Gephi compatible) |

---

## 📘 Environment Overview
All dependencies are installed via Conda (see `environment.yml`).  
To update your environment:
```bash
conda activate forensic-microbiome
conda env update -f environment.yml
```

---

## 📊 Workflow Overview
```mermaid
flowchart TD
    A[Raw FASTQ] --> B[fastp QC]
    B --> C[Kneaddata (host removal)]
    C --> D[Kraken2 taxonomic classification]
    D --> E[Bracken species abundance]
    E --> F[AMR detection (Abricate/AMRFinder)]
    F --> G[Merge results & QC]
    G --> H[RMarkdown forensic report]
```

---

## 📚 Citations & Credits
Please cite the tools used within this pipeline:

- Wood, D. E., et al. (2019). **Kraken 2**: _Improved metagenomic analysis with Kraken 2._ Genome Biology.  
- Lu, J., et al. (2017). **Bracken**: _Estimating species abundance from metagenomic data._ PeerJ.  
- Beghini, F., et al. (2021). **MaAsLin2**: _Multivariable association discovery in population microbiome studies._ Nature Methods.  
- Feldgarden, M., et al. (2019). **AMRFinderPlus**: _Antimicrobial resistance gene detection tool._ Antimicrobial Agents & Chemotherapy.  
- Li, D., et al. (2015). **MEGAHIT**: _Ultra-fast assembly for metagenomics._ Bioinformatics.

---

## 🧑‍⚖️ License
**MIT License** — open use and modification permitted with attribution.

---

## ✉️ Contact / Issues
For questions, feature requests, or collaboration inquiries, please open a GitHub Issue or contact:

**[Your Name]** · [Your Institution] · [Your Email]

---
