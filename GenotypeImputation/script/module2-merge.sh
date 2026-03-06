

INPUT="SG10K.chr20.hg38_QC2.QC.vcf.gz"
ARG="VN_916.HaplotypeData.chr20.QC.m3vcf.gz"
OUTPUT="Reference"`basename $INPUT | sed 's/_.*/_impute.vn916/'` ; echo $OUTPUT
# echo "minimac4 --haps $INPUT --refHaps $ARG \
#     --ChunkLengthMb 20 --ChunkOverlapMb 3 --allTypedSites \
#     --prefix $OUTPUT --cpus 8"
# minimac4 --haps $INPUT --refHaps $ARG \
#     --ChunkLengthMb 20 --ChunkOverlapMb 3 --allTypedSites \
#     --prefix $OUTPUT --log --cpus 8 
# impute from 1kgp to vn920, do not require pre-phase
INPUT="Reference/VN_916.HaplotypeData.chr20.QC.vcf.gz"
ARG="Reference/SG10K.chr20.hg38_QC2.QC.m3vcf.gz"
OUTPUT="Reference/"`basename $INPUT | sed 's/_.*/_impute.SG10k/'` ; echo $OUTPUT
# minimac4 --haps $INPUT --refHaps $ARG \
#     --ChunkLengthMb 20 --ChunkOverlapMb 3 --allTypedSites \
#     --prefix $OUTPUT --cpus 8 
# # merge *dose.vcf.gz [merge multi-allelic]; then remove them from OUTPUT
INPUT="Reference/SG10K.chr20.hg38_impute.vn916.dose.vcf.gz"
bcftools index $INPUT 
INPUT2="Reference/VN_impute.SG10k.dose.vcf.gz"
bcftools index $INPUT2
OUTPUT="Reference/merge-SG10K-vn916.chr20_forprephase.vcf.gz"
bcftools merge --merge all $INPUT $INPUT2 -Ou |\
    bcftools view -M 2 -Oz -o $OUTPUT
[[ -f $OUTPUT.csi ]] || bcftools index $OUTPUT && echo "file was indexed"
# convert m3vcf
INPUT=$OUTPUT
# bcftools index $INPUT
ARG=`basename $INPUT | grep -o 'chr[0-9X]*'`
OUTPUT="Reference/`basename $INPUT | sed 's/_.*/_forimpute/'`" ; echo "asd" $OUTPUT
/tool/Minimac3/bin/Minimac3 --refHaps $INPUT --chr $ARG --processReference \
    --prefix $OUTPUT --log --cpus 8
