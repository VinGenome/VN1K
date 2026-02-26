vcf=$1
REF_GENOME=/mnt/nas/share/ReferenceData/Reference.Broad-resourcebundle_GRCh38/Homo_sapiens_assembly38.fasta
tabix -p vcf $vcf
bcftools norm -m -any -f $REF_GENOME $vcf -Oz -o ${vcf/.sv.vcf.gz/.normed.sv.vcf.gz} 

python /home/giangvm1/bit_bucket/pangenom/pipeline/old_code/genome_graph_mc_pipeline/scripts/annotate_vg_sv.py \
    ${vcf/.sv.vcf.gz/.normed.sv.vcf.gz} \
    ${vcf/.sv.vcf.gz/.normed.annotated.sv.vcf.gz}

