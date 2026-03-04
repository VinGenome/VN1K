run_cnnLSV(){ 
    bamFile=$1
    vcfFile=$2
    echo $vcfFile
    fileName=`basename $vcfFile`
    outputFile=$fileName.output.cnnlsv.vcf
    path_output='./log'
    mkdir -p $path_output
    tmpFolder="$path_output/${fileName}_tmp"
    bcftools view -f PASS $vcfFile -Ou -o $path_output/$fileName.filterd.vcf
    bcftools view -h $vcfFile > $path_output/hdr.txt
    sed -i '15i ##FILTER=<ID=STRANDBIAS,Description="some description"' $path_output/hdr.txt
    bcftools reheader -h $path_output/hdr.txt  $vcfFile > $path_output/$fileName.reheader.filterd.vcf
    bcftools sort $path_output/$fileName.reheader.filterd.vcf -o $path_output/$fileName.reheader.sorted.filterd.vcf
    if [ -f $path_output/$fileName.reheader.sorted.filterd.vcf ]; then
        (time python ./tools/cnnLSV/src/cnnLSV.py $bamFile $path_output/$fileName.reheader.sorted.filterd.vcf $path_output/$outputFile -t 1 --tempdir $tmpFolder --dataset real --model ./tools/cnnLSV/src/realmodel.pt) 2> $path_output/`basename "$(dirname $vcfFile)"`.`basename $vcfFile`.log
        echo 'RUN DONE'
    fi
}
export -f run_cnnLSV




 
listFileVCF=`cat $2` # listFileVCF=array
bamFilePath=$1 # file to reference bam
# echo $bamFilePath $outputFile $listFileVCF
echo $listFileVCF
parallel -j2  run_cnnLSV ::: $bamFilePath ::: $listFileVCF 


#Merge all file outfile of cnnLSV by SURVIVOR
ls ./log/*output.cnnlsv.vcf > ./log/output_cnnlsv.txt #listFileVCFOutput

outputPath=$3 #listFileVCFOutput
maximumDistance=1000
lenThreshold=50
./tools/SURVIVOR/Debug/SURVIVOR merge ./log/output_cnnlsv.txt $maximumDistance 1 1 1 0 $lenThreshold $outputPath

