process CORRECT_GTF {
    tag "$meta.id"
    label 'process_low'

    input:
    tuple val(meta), path(gtf)

    output:
    tuple val(meta), path("*.corrected.gtf"), emit: gtf
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    cat ${gtf} | tr -d '\000' | awk -F \$'\t' 'BEGIN{OFS="\t"} \$3="intron", \$7="+"' | grep -v exon_id > ${prefix}.corrected.gtf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        correct_gtf: v1.0
    END_VERSIONS
    """
}