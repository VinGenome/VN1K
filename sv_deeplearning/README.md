# SV Merge - Deep Learning

## Usage

1. Remove header of VCF file without line of #CHROM

``bash
sed '/^##/d' $i 
``

2. Run pipeline

Edit list of variables path:

- listFileVCF=`cat /mnt/WD/VGP/VN_007_920_benchmark/SURVIVOR/Debug/file_system.txt`
- bamFilePath='/mnt/WD/VGP/alignment/VN007/VN007.merge.bam'
- outputFile=`cat /mnt/WD/VGP/VN_007_920_benchmark/sv_deeplearning/data/output_vcf_cnnlsv.txt`
- inputPath='/mnt/WD/VGP/VN_007_920_benchmark/sv_deeplearning/data/output_vcf_cnnlsv.txt'
- outputPath='/mnt/WD/VGP/VN_007_920_benchmark/sv_deeplearning/data/cnnLSV.survivor.vcf'

Run command line

``bash
time bash script/cnnlsv.sh $bamFilePath $listFileVCF $outputFile $outputPath
``

3. Check Quality

Check quality of SV by source code `quality_control.ipynb`

Metrics:

- "Calculate True Positives, False Positives, and False Negatives:",
- "True positives: SVs present in both VCF files and overlapping according to the defined criteria.",
- "False positives: SVs present in one VCF file but not the other, or present in both but not overlapping.",
- "False negatives: SVs present in one VCF file but not the other.",


