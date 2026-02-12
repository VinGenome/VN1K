INPUT=$1
REF_PHASE=$2
REF_IMPUTE=$3

INPUT_BASENAME=$(basename $INPUT)
INPUT_SETNAME=${INPUT_BASENAME/.vcf.gz/}
INPUT_DIR=$(dirname $INPUT)

OUTPUT_DIR=${INPUT_DIR/"Input"/"Impute_APMRA"}
mkdir -p $OUTPUT_DIR

# remove multi
INPUT_QC=$INPUT_DIR/${INPUT_BASENAME/.vcf.gz/.no_multi.vcf.gz}
bcftools norm -m+any $INPUT |\
    bcftools view -M 2 -Oz -o $INPUT_QC
bcftools index -t -f $INPUT_QC

# phase
REF_PHASE_BASENAME=$(basename $REF_PHASE)
REF_PHASE_SETNAME=${REF_PHASE_BASENAME/.vcf.gz/}
PHASE_VCF=$OUTPUT_DIR/$INPUT_SETNAME.$REF_PHASE_SETNAME
shapeit4.2 --input $INPUT_QC --region chr20 --map maps/chr20.b38.gmap.gz \
        --reference $REF_PHASE --output $PHASE_VCF.vcf.gz \
        --log $PHASE_VCF.log --seed 15 

# impute
REF_IMPUTE_BASENAME=$(basename $REF_IMPUTE)
REF_IMPUTE_SETNAME=${REF_IMPUTE_BASENAME/.m3vcf.gz/}
IMPUTE_VCF=$OUTPUT_DIR/$INPUT_SETNAME.$REF_IMPUTE_SETNAME
minimac4 --haps $PHASE_VCF.vcf.gz \
    --refHaps $REF_IMPUTE \
    --ChunkLengthMb 20 --ChunkOverlapMb 3 --allTypedSites \
    --prefix $IMPUTE_VCF --cpus 8 
