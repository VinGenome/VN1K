run_cnnLSV(){ 
    baseVCF=$1
    vcfFile=$2
    fileName=`basename "$(dirname $vcfFile)"`.`basename $vcfFile`
    # tmpFolder="./${fileName}_tmp"
    bcftools view $vcfFile -Oz -o /mnt/nas/Bio/VinhDC/vn920/$fileName.gz
    bcftools sort /mnt/nas/Bio/VinhDC/vn920/$fileName.gz -o /mnt/nas/Bio/VinhDC/vn920/sorted.$fileName.gz
    bcftools index -t /mnt/nas/Bio/VinhDC/vn920/sorted.$fileName.gz
    truvari bench -b $baseVCF -c /mnt/nas/Bio/VinhDC/vn920/sorted.$fileName.gz -o /mnt/nas/Bio/VinhDC/vn920/truvari/$fileName
}
export -f run_cnnLSV

baseVCF='/mnt/nas/Bio/VinhDC/vn920_cnnlsv/vn920.sorted.vcf.gz'
# baseVCF=`cat /mnt/WD/VGP/VN_007_920_benchmark/list_vcf_920.txt`
listVCF=`cat /mnt/WD/VGP/VN_007_920_benchmark/list_vcf_920.txt`
parallel -j10  run_cnnLSV ::: $baseVCF ::: $listVCF

# Merge all file outfile of cnnLSV by SURVIVOR
# inputPath='/mnt/WD/VGP/VN_007_920_benchmark/sv_deeplearning/data/output_vcf_cnnlsv.txt'
# outputPath='/mnt/WD/VGP/VN_007_920_benchmark/sv_deeplearning/data/cnnLSV.survivor.vcf'
# maximumDistance=1000
# lenThreshold=50
# /mnt/WD/VGP/VN_007_920_benchmark/SURVIVOR/Debug/SURVIVOR merge $inputPath           $maximumDistance 2 1 1 0 $lenThreshold $outputPath

