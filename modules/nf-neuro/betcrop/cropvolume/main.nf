
process BETCROP_CROPVOLUME {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_2.0.0.sif':
        'scilus/scilus:2.0.0' }"

    input:
    tuple val(meta), path(image), path(bounding_box)

    output:
    tuple val(meta), path("*_*_cropped.nii.gz") , emit: image
    tuple val(meta), path("*.pkl")              , emit: bounding_box, optional: true
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    def input_bbox = bounding_box ? "--input_bbox $bounding_box" : ""
    def suffix = task.ext.first_suffix ? "${task.ext.first_suffix}" : ""
    def output_bbox = task.ext.output_bbox ? "--output_bbox ${prefix}_${suffix}_bbox.pkl" : ""

    """
    scil_volume_crop.py $image ${prefix}_${suffix}_cropped.nii.gz $input_bbox $output_bbox

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 2.0.0
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def suffix = task.ext.first_suffix ? "${task.ext.first_suffix}" : ""

    """
    scil_volume_crop.py -h

    touch ${prefix}_${suffix}_cropped.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 2.0.0
    END_VERSIONS
    """
}
