params.str = 'Hello world!'

process splitLetters {
    input:
    path bamFilePath
    path vcfPath

    output:
    path outputPath


listFileVCF=`cat /mnt/WD/VGP/VN_007_920_benchmark/SURVIVOR/Debug/file_system.txt`
bamFilePath='/mnt/WD/VGP/alignment/VN007/VN007.merge.bam'
outputFile=`cat /mnt/WD/VGP/VN_007_920_benchmark/sv_deeplearning/data/output_vcf_cnnlsv.txt`

    """
    bash script_run_sv.sh $1 $2 $3
    """
}

process convertToUpper {
    input:
    path x

    output:
    stdout

    """
    cat $x | tr '[a-z]' '[A-Z]'
    """
}

workflow {
    splitLetters | flatten | convertToUpper | view { it.trim() }
}
