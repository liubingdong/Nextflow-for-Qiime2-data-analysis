include { fastqc                                                 } from './modules/qiime2_moulde.nf'
include { multiqc                                                } from './modules/qiime2_moulde.nf'
include { trimmomatic                                            } from './modules/qiime2_moulde.nf'
include { figaro_determin                                        } from './modules/qiime2_moulde.nf'
include { qiime_import                                           } from './modules/qiime2_moulde.nf'
include { figaro_parameter                                       } from './modules/qiime2_moulde.nf'
include { qiime_dada2                                            } from './modules/qiime2_moulde.nf'
include { qiime_feature_classifier as  qiime_silva_classifier    } from './modules/qiime2_moulde.nf'
include { qiime_feature_classifier as  qiime_green_classifier    } from './modules/qiime2_moulde.nf'
include { qiime_feature_classifier as  qiime_custmer_classifier  } from './modules/qiime2_moulde.nf'
include { qiime_barplot as  qiime_silva_barplot                  } from './modules/qiime2_moulde.nf'
include { qiime_barplot as  qiime_green_barplot                  } from './modules/qiime2_moulde.nf'
include { qiime_barplot as  qiime_custmer_barplot                } from './modules/qiime2_moulde.nf'





workflow  {
      Channel.fromPath(params.read,checkIfExists: true).set {fastq_files}
      Channel.fromFilePairs(params.read,checkIfExists: true).set {fastq_paired_files}
      Channel.fromPath(params.Silva_database,checkIfExists: true).set {Silva_database}
      Channel.fromPath(params.Green_gene_database,checkIfExists: true).set {Green_gene_database}
      
      fastq_paired_files | fastqc | collect | multiqc 
      trimmomatic_ch = trimmomatic(fastq_paired_files)
      figaro_parameter_ch =  trimmomatic_ch | collect | figaro_determin | figaro_parameter
      qiime_import_ch = trimmomatic_ch | collect | qiime_import
      qiime_dada2_ch = qiime_dada2(qiime_import_ch.paired_end_demux,figaro_parameter_ch)
      
      if (params.Silva_database) {
        qiime_silva_classifier_ch = qiime_silva_classifier(Silva_database,qiime_dada2_ch.rep_seqs)
        qiime_silva_barplot(qiime_dada2_ch.table_qza,qiime_silva_classifier_ch.taxonomy_qza)
      }

      if (params.Green_gene_database) {
        qiime_green_classifier_ch = qiime_green_classifier(Green_gene_database,qiime_dada2_ch.rep_seqs)
        qiime_green_barplot(qiime_dada2_ch.table_qza,qiime_green_classifier_ch.taxonomy_qza)
      }      

}





