#QC file ref
#Remove multi-allelic and singletons
file_input=$1
fileName=`basename $file_input`
path=`dirname $file_input`
fileNameTT=${fileName:0:-7}

#remove singletons
vcftools --gzvcf $file_input --singletons --out $path/$fileNameTT
vcftools --gzvcf $file_input --exclude-positions $path/$fileNameTT.singletons --recode --recode-INFO-all --out $path/$fileNameTT.removeSingletons

#remove multi-allelic
bcftools norm -m+any $path/$fileNameTT.removeSingletons.recode.vcf -Ou |\
    bcftools view -v 'snps,indels' -M 2 -Oz -o $path/$fileNameTT.QC.vcf.gz

#convert to m3vcf
/tool/Minimac3/bin/Minimac3 --refHaps $path/$fileNameTT.QC.vcf.gz --chr chr20 --processReference --prefix $path/$fileNameTT.QC --log --cpus 4