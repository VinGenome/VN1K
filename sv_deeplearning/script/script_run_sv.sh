bamFile=$1
vcfFile=$2
outputFile=$3
fileName=`basename "$(dirname $vcfFile)"`.`basename $vcfFile`
tmpFolder="./${fileName}_temp"
echo $bamFile $vcfFile $outputFile $tmpFolder
# bcftools view -f PASS $vcfFile -Ou -o ./cnnLSV/data/$fileName.filterd.vcf
if [ -f ./cnnLSV/data/$fileName.filterd.vcf ]; then
    (time python ./cnnLSV/src/cnnLSV.py $bamFile ./cnnLSV/data/$fileName.filterd.vcf $outputFile -t 5 --tempdir $tmpFolder --dataset real --model ./src/realmodel.pt) 2> log/`basename "$(dirname $vcfFile)"`.`basename $vcfFile`.log
    echo 'RUN DONE'
fi