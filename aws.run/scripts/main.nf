#!/usr/bin/env nextflow

include { MAF_SELECT } from './modules/bcftool/select.nf'
include { RAND_SELECT } from './modules/bcftool/select.nf'
include { SPLIT_SAMPLE } from './modules/bcftool/count.nf'
include { GET_COUNTS } from './modules/bcftool/count.nf'
include { MERGE_COUNTS } from './modules/bcftool/count.nf'
include { CREATE_PCA } from './modules/pca'

workflow {

    in_vcfs = Channel.fromPath(params.reads, checkIfExists: true)

    if ( params.rand_fraction ) {
	in_vcfs = RAND_SELECT(in_vcfs, params.rand_fraction).vcfs 
    }

    if (params.maf_interval) {
	in_vcfs = MAF_SELECT(in_vcfs.flatten(), params.maf_interval).vcf 
    }

    // get subsample from one of the input vcf
    samples = SPLIT_SAMPLE(in_vcfs.first(), params.chunk_size).chunks

    chunk_counts = GET_COUNTS(in_vcfs.combine(samples.flatten()))
    all_counts = MERGE_COUNTS(chunk_counts.collect())
    CREATE_PCA(all_counts.counts, channel.fromPath(params.panel))

}


workflow.onComplete {
    def summary = [
        "Pipeline execution summary",
        "---------------------------",
        "Completed at : ${workflow.complete}",
        "Duration     : ${workflow.duration}",
        "Success      : ${workflow.success}",
        "Exit status  : ${workflow.exitStatus}",
        "Work dir     : ${workflow.workDir}",
        "Run name     : ${workflow.runName}",
        "Command line : ${workflow.commandLine}",
        "Results dir  : ${params.results ?: 'not specified'}"
    ]

    if (!workflow.success) {
        summary << "Error report : ${workflow.errorReport ?: 'N/A'}"
        summary << "Error message: ${workflow.errorMessage ?: 'N/A'}"
    }

    println summary.join('\n')
}

