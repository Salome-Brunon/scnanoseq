//
// Creates the gene-level matrices
//

// Local modules
include { SUBREAD_FEATURECOUNTS as SUBREAD_FEATURECOUNTS_GENE         } from '../../modules/local/subread_featurecounts'
include { SUBREAD_FEATURECOUNTS as SUBREAD_FEATURECOUNTS_GENE_INTRON2 } from '../../modules/local/subread_featurecounts'
include { TAG_FEATURES                                                } from '../../modules/local/tag_features'
include { UMITOOLS_COUNT                                              } from '../../modules/local/umi_tools_count'
include { SPLIT_FILE_BY_COLUMN                                        } from '../../modules/local/split_file_by_column'

// nf-core modules
include { SAMTOOLS_INDEX } from '../../modules/nf-core/samtools/index/main'

workflow GET_GENE_COUNTS_MATRIX {
    take:
    ch_bam
    ch_gtf
    gtf_preparation_method
    ch_gtf_intron2

    main:

    //
    // MODULE: Count Features 
    //
    subread_version = Channel.empty()

    SUBREAD_FEATURECOUNTS_GENE ( ch_bam, ch_gtf )
    ch_counts = SUBREAD_FEATURECOUNTS_GENE.out.counts

    //TODO: enable this once we have intron 2 GTF in the workflow
    // for intron method 2, perform a second round for introns count
    //if (gtf_preparation_method == "2") {
      //  SUBREAD_FEATURECOUNTS_GENE_INTRON2 ( ch_bam, ch_gtf_intron2 )
        //gene_counts_intron2_mtx = SUBREAD_FEATURECOUNTS_GENE_INTRON2.out.counts
        //}

    subread_version = SUBREAD_FEATURECOUNTS_GENE.out.versions

    //
    // MODULE: Tag Features
    //
    TAG_FEATURES ( ch_bam.join(ch_counts, by: 0) )

    ch_tag_bam = TAG_FEATURES.out.feature_bam

    //
    // MODULE: Index feature tagged bam
    //
    SAMTOOLS_INDEX (ch_tag_bam)
    ch_tag_bam_bai = SAMTOOLS_INDEX.out.bai

    //
    // MODULE: Generate the counts matrix
    //

    UMITOOLS_COUNT ( ch_tag_bam.join(ch_tag_bam_bai, by: 0) )
    ch_count_mtx = UMITOOLS_COUNT.out.counts_matrix

    //
    // MODULE: Split the count matrix
    //

    SPLIT_FILE_BY_COLUMN ( ch_count_mtx, 10 )

    gene_counts_mtx = Channel.empty()
    tag_gene_counts_mtx = Channel.empty()
    tag_gene_counts_intron2_mtx = Channel.empty()

    emit:
    gene_counts_mtx //TODO: can be removed once tagging is added (just here fore test)
    tag_gene_counts_mtx
    tag_gene_counts_intron2_mtx
    subread_version

}
