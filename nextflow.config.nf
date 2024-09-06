docker.enabled = true

params.outdir = "results"
params.read = "data/*_{R1,R2}.fastq"
params.Silva_database = "ref/silva-138-99-nb-classifier.qza"
params.Green_gene_database = "ref/gg-13-8-99-nb-classifier.qza"



process {
    withName: trimmomatic {
        container = 'bingdong_qiime2_picrust_qc:1.2'
    }
    withName: fastqc {
        cpus = 10
        memory = {2.GB * task.cpus }
        publishDir = [ path: "${params.outdir}/QC/each", mode: 'copy' ]        
        container = 'bingdong_qiime2_picrust_qc:1.2'
    }
    withName: multiqc {
        publishDir = [ path: "${params.outdir}/QC/", mode: 'copy' ] 
        container = 'bingdong_qiime2_picrust_qc:1.2'
    }        
    withName: figaro_determin {
        publishDir = [ path: params.outdir, mode: 'copy' ]
        container = 'figaro_check:1.1'
    }
    withName: qiime_import {
        publishDir = [ path: params.outdir, mode: 'copy' ]
        container = 'bingdong_qiime2_picrust_qc:1.2'
    }
    withName: qiime_dada2 {
        cpus = 40
        publishDir = [ path: "${params.outdir}/DADA2_result", mode: 'copy' ]
        container = 'bingdong_qiime2_picrust_qc:1.2'
    }
    withName: qiime_silva_classifier {
        cpus = 40
        publishDir = [ path: "${params.outdir}/tax_result/silva", mode: 'copy' ]
        container = 'bingdong_qiime2_picrust_qc:1.2'
    }    
    withName: qiime_green_classifier {
        cpus = 40
        publishDir = [ path: "${params.outdir}/tax_result/green_gene", mode: 'copy' ]
        container = 'bingdong_qiime2_picrust_qc:1.2'
    }   
    withName: qiime_custmer_classifier {
        cpus = 40
        publishDir = [ path: "${params.outdir}/tax_result/customer", mode: 'copy' ]
        container = 'bingdong_qiime2_picrust_qc:1.2'
    } 
    withName: qiime_silva_barplot {
        cpus = 40
        publishDir = [ path: "${params.outdir}/tax_result/silva", mode: 'copy' ]
        container = 'bingdong_qiime2_picrust_qc:1.2'
    }       
    withName: qiime_green_barplot {
        cpus = 40
        publishDir = [ path: "${params.outdir}/tax_result/green_gene", mode: 'copy' ]
        container = 'bingdong_qiime2_picrust_qc:1.2'
    }   
    withName: qiime_custmer_barplot {
        cpus = 40
        publishDir = [ path: "${params.outdir}/tax_result/customer", mode: 'copy' ]
        container = 'bingdong_qiime2_picrust_qc:1.2'
    } 
}










