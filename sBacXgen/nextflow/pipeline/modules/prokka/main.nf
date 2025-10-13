process runProkka {
  
  label 'prokka'
  tag {"$params.runid"}
  publishDir "$params.outputPath/process=$task.process"


  input:
    tuple val(base_id), path(fasta)

  output:
    path '*/*.{log,md5sum}', emit: logs
    path '*/*.gff', emit: gff_files

  shell:
    '''
    export entryDir=$(pwd)
    echo "--- Running !{task.process} !{fasta} ---"
    echo "----- List working directory"
    pwd ; ls -aFlh
    echo "----- Processing with $(prokka --version)"
    mkdir -p !{base_id}
    prokka --force --compliant  --outdir !{base_id} --prefix !{base_id} --centre UTS --cpus !{params.threads_prokka} !{fasta}
    echo "----- Generating checksums"
    cd !{base_id}
    find . -type f | parallel --will-cite -j+0 'md5sum {} ' | tee --append !{base_id}_!{task.process}.md5sum
    echo "--- End !{task.process} !{base_id} ---"
    cd -
    cp ${entryDir}/.command.out ${entryDir}/!{base_id}/!{base_id}_!{task.process}.log
    '''
}

