process CREATE_REGEX {
    label 'process_low'

    conda (params.enable_conda ? "conda-forge::python=3.8.3" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3':
        'quay.io/biocontainers/python:3.8.3' }"
    
    input:
    val cell_barcode_pattern
    val identifier_pattern
    val cell_barcode_lengths
    val umi_lengths
    val fixed_seqs

    output:
    path "regex_patterns.txt", emit: regex_pattern_file
    path "versions.yml"      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    
    """
    OUT_FILE="regex_patterns.txt"

    if [[ "${cell_barcode_pattern}" ]]; then
       echo -e "REGEX: ${cell_barcode_pattern}" > \${OUT_FILE}
       echo -e "BC_PATTERN: N/A" >> \${OUT_FILE}

    else
        create_regex.py -i "${identifier_pattern}" \\
                        -c "${cell_barcode_lengths}" \\
                        -u "${umi_lengths}" \\
                        -f "${fixed_seqs}" \\
                        -o \${OUT_FILE}
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g' )
    END_VERSIONS
    """
}