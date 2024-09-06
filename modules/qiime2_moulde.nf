process fastqc {

    label "quality_control"  
    tag "fastqc on $sample_id"
    
    input:
    tuple val(sample_id), path(reads)

    output:
    path "fastqc_${sample_id}_logs/*"

    script:
    //flagstat simple stats on bam file
    """
    mkdir fastqc_${sample_id}_logs
    conda run -n qc_moudle fastqc -o fastqc_${sample_id}_logs -f fastq -q ${reads} -t ${task.cpus}
    """
}

process multiqc {

    label "quality_control"  

    input:
    path '*'

    output:
    path 'multiqc_report.html'

    script:
    """
    conda run -n qc_moudle multiqc .
    """
}



process trimmomatic {

    tag "trimmomatic $sample_id for figaro"
    input:
    tuple val(sample_id), path(reads)

    output:
    path "*_16s_R*fastq"

    script:
    """
    conda run -n qc_moudle trimmomatic PE -phred33 ${reads[0]} ${reads[1]} \
         ${sample_id}_16s_R1.fastq ${sample_id}_16s_unpaired_R1.fastq \
         ${sample_id}_16s_R2.fastq ${sample_id}_16s_unpaired_R2.fastq \
         HEADCROP:1 CROP:240 MINLEN:240
    """
}


process figaro_determin {

    input:
    path '*'

    output:
    path "figaro_result"

    script:
    """
    mkdir -p data_temp
    mv *fastq  data_temp/
    python /opt/figaro/figaro/figaro.py -i data_temp -o figaro_result/ -f 1 -r 1 -a 425 > figaro_result.tsv   
    mv figaro_result.tsv figaro_result/
    """
}


process figaro_parameter {
    
    input:
    path '*'

    output:
    env trim_f
    env trim_r
    script:
    """
    trim_f=\$(cat figaro_result/figaro_result.tsv|awk 'NR==3 {split(\$2,arr,",");print arr[1]}' | awk '{split(\$1,arr,"[");print arr[2]}')    
    trim_r=\$(cat figaro_result/figaro_result.tsv|awk 'NR==3 {split(\$3,arr,",");print arr[1]}' | awk '{split(\$1,arr,"]");print arr[1]}')
    """
}


process qiime_import {
    
    input:
    path '*'


    output:
    path "temp/"
    path "manifest.txt"
    path "paired-end-demux.qza", emit:paired_end_demux

    script:
    """
    mkdir temp/
    mv *fastq temp/
    name.sh temp/

    conda run -n qiime2-2023.2  qiime tools import \
            --type 'SampleData[PairedEndSequencesWithQuality]' \
            --input-path manifest.txt \
            --output-path paired-end-demux.qza \
            --input-format PairedEndFastqManifestPhred33V2
    """
}


process qiime_dada2 {
    
    input:
    path paired_end_demux
    val trim_f
    val trim_r


    output:
    path "table.qza", emit: table_qza
    path "rep-seqs.qza", emit:rep_seqs
    path "denoising-stats.qza"


    script:
    """
    conda run -n qiime2-2023.2 qiime dada2 denoise-paired \
    --i-demultiplexed-seqs ${paired_end_demux} \
    --p-trunc-len-f ${trim_f} \
    --p-trunc-len-r ${trim_r} \
    --o-table table.qza \
    --o-representative-sequences rep-seqs.qza \
    --o-denoising-stats denoising-stats.qza \
    --p-n-threads ${task.cpus} \
    --verbose
    """
}


process qiime_feature_classifier {
    
    input:
    path database
    path rep_seqs

    output:
    path "*taxonomy.qza", emit:taxonomy_qza

  
    """
    conda run -n qiime2-2023.2 qiime feature-classifier classify-sklearn \
    --i-classifier ${database} \
    --i-reads ${rep_seqs} \
    --o-classification taxonomy.qza \
    --p-n-jobs ${task.cpus}   
    """

}

process qiime_barplot {
    
    input:
    path table_qza
    path taxonomy_qza

    output:
    path "*taxa_barplot.qzv", emit:taxa_barplot_qzv

  
    """
    conda run -n qiime2-2023.2 qiime taxa barplot \
    --i-table ${table_qza} \
    --i-taxonomy ${taxonomy_qza} \
    --o-visualization taxa_barplot.qzv
    """

}