#!/usr/bin/env nextflow
nextflow.enable.dsl = 2
params.author = 'qinying.xu@csiro.au'

// Check run parameters
assert params.year ==~ /[0-9]{4}/
assert params.month ==~ /[0-9]{2}/
assert params.runid ==~ /[a-zA-Z0-9-_\.]{8,48}/


workflow.onComplete {
log.info """
=========================================================================================

Pipeline Complete:
  Completed at:       $workflow.complete
  Duration:           $workflow.duration
  Execution status:   ${ workflow.success ? 'OK' : 'FAILED' }: $workflow.exitStatus

=========================================================================================
Pipeline Details:
  Name                  $workflow.manifest.name
  Description:          $workflow.manifest.description
  Version               $workflow.manifest.version
  Author:               $workflow.manifest.author

"""
}

workflow.onError {
log.info """
=========================================================================================

Error:
  Pipeline execution stopped with the following message:
  ${workflow.errorMessage}
  ${workflow.errorReport}

=========================================================================================
"""
}

include { runProkka } from './modules/prokka'
include { runRoary } from './modules/roary'

workflow {
  main:
    //channel can't check file exits
    fastas = Channel.fromPath(params.input).map { file -> tuple(file.baseName, file) }
    fastas.view { "FASTAS: ${it}" }  // Corrected view operator usage

    prokka_results = runProkka(fastas  )
    prokka_results.gff_files.collect().view { "Prokka collect: ${it}" } 


    roary_results = runRoary( prokka_results.gff_files.collect() )

    num_gff = prokka_results.gff_files.collect().size()
    // extractCoreGenes(roary_results.fa_files, num_gff)

    emit: runRoary.out.csv_files
}

workflow.onComplete {

    def msg = """\
        Pipeline execution summary
        ---------------------------
        Completed at: ${workflow.complete}
        Duration    : ${workflow.duration}
        exit status : ${workflow.exitStatus}
        Success     : ${workflow.success}
        Outputs     : ${params.results}
        """
        .stripIndent()

    sendMail(to: '${params.emailto}', subject: 'NF run (${params.runid}) is done', body: msg)
}
