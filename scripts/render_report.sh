#!/usr/bin/env bash
Rscript -e "rmarkdown::render('Microbiome_Group_Comparison_Report.Rmd', params=list(bracken_table='results/bracken/bracken_species_table.tsv', samples_tsv='config/samples.tsv'), output_file='results/report/Microbiome_Group_Comparison_Report.html')"
