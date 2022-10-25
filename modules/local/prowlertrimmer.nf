process PROWLERTRIMMER {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "jdoe062894::prowlertrimmer" : null)

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.fastq.gz"), emit: reads
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    python3 \$(which TrimmerLarge.py) $args -f ${prefix}.fastq

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        prowlertrimmer: \$(echo "1.0")
    END_VERSIONS
    """
}