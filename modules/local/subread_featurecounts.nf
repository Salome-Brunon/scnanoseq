process SUBREAD_FEATURECOUNTS {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::subread=2.0.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/subread:2.0.1--hed695b0_0' :
        'quay.io/biocontainers/subread:2.0.1--hed695b0_0' }"

    input:
    tuple val(meta), path(bams)
    path gtf

    output:
    tuple val(meta), path("*.featureCounts")        , emit: counts
    tuple val(meta), path("*_assigned")             , emit: assigned
    tuple val(meta), path("*_assigned.summary")     , emit: summary
    path "versions.yml"                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    featureCounts \\
        $args \\
        -T $task.cpus \\
        -a $gtf \\
        -o ${prefix}_assigned \\
        $bams

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        subread: \$( echo \$(featureCounts -v 2>&1) | sed -e "s/featureCounts v//g")
    END_VERSIONS
    """
}