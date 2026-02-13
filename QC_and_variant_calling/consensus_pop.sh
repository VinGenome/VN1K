#Dragen_folder="/dragennfs/area1/trangth18/GDB/"
Dragen_folder="/dragennfs/area16/Population/final/Dragen_finalset/"

DV_folder="//dragennfs/area16/Population/final/DV_finalset/"

#GATK_folder="/dragennfs/area1/trangth18/GATKDB/"
#GATK_folder="/dragennfs/area1/trangth18/GATK_combineGVCF/"
GATK_folder="/dragennfs/area16/Population/final/GATK_finalset/"

Out_dir="/dragennfs/area7/PopTest/Consensus3/"
Ref_folder="/home/shared/references/Homo_sapiens_assembly38.fasta"

Current_folder=$(pwd)
GATK_root="/home/shared/tools/gatk-4.1.8.1/"

Dragen_file="testPop_1013.dragen"
GATK_file="testPop_1008.gatk"
DV_file="all_1008"

common_name="testPop_1008"

[ ! -d "$Out_dir"SNP ] && mkdir "$Out_dir"SNP
[ ! -d "$Out_dir"INDEL ] && mkdir "$Out_dir"INDEL

###----------------GATK pipeline processing-------------------
#bcftools view "$GATK_folder""$GATK_file".norm.pass.vqsr.vcf.gz -v snps  -Oz -o "$Out_dir"SNP/"$common_name".gatk.SNP.norm.pass.vqsr.vcf.gz
#bcftools view "$GATK_folder""$GATK_file".norm.pass.vqsr.vcf.gz -v indels -Oz -o "$Out_dir"INDEL/"$common_name".gatk.INDEL.norm.pass.vqsr.vcf.gz

#tabix -p vcf "$Out_dir"SNP/"$common_name".gatk.SNP.norm.pass.vqsr.vcf.gz
#tabix -p vcf "$Out_dir"INDEL/"$common_name".gatk.INDEL.norm.pass.vqsr.vcf.gz

###----------------------------------Dragen pipeline processing------------------------------
#bcftools view "$Dragen_folder""$Dragen_file".rm5more.norm.pass.vcf.gz -v snps -Oz -o "$Out_dir"SNP/"$common_name".dragen.SNP.norm.pass.vcf.gz
#bcftools view "$Dragen_folder""$Dragen_file".rm5more.norm.pass.vcf.gz -v indels -Oz -o "$Out_dir"INDEL/"$common_name".dragen.INDEL.norm.pass.vcf.gz

#tabix -p vcf "$Out_dir"SNP/"$common_name".dragen.SNP.norm.pass.vcf.gz
#tabix -p vcf "$Out_dir"INDEL/"$common_name".dragen.INDEL.norm.pass.vcf.gz

###---------------------DeepVariant pipeline processing ------------------
bcftools view "$DV_folder""$DV_file".norm.filltags.vcf.gz -v snps -Oz -o "$Out_dir"SNP/"$common_name".dv.SNP.norm.filltags.vcf.gz
bcftools view "$DV_folder""$DV_file".norm.filltags.vcf.gz -v indels -Oz -o "$Out_dir"INDEL/"$common_name".dv.INDEL.norm.filltags.vcf.gz

tabix -p vcf "$Out_dir"SNP/"$common_name".dv.SNP.norm.filltags.vcf.gz
tabix -p vcf "$Out_dir"INDEL/"$common_name".dv.INDEL.norm.filltags.vcf.gz


###--------------- intersection---------------------
bcftools isec -n +2 -c none "$Out_dir"SNP/"$common_name".gatk.SNP.norm.pass.vqsr.vcf.gz "$Out_dir"SNP/"$common_name".dragen.SNP.norm.pass.vcf.gz "$Out_dir"SNP/"$common_name".dv.SNP.norm.filltags.vcf.gz -p "$Out_dir"SNP/cmp
bcftools isec -n +2 -c none "$Out_dir"INDEL/"$common_name".gatk.INDEL.norm.pass.vqsr.vcf.gz "$Out_dir"INDEL/"$common_name".dragen.INDEL.norm.pass.vcf.gz "$Out_dir"INDEL/"$common_name".dv.INDEL.norm.filltags.vcf.gz -p "$Out_dir"INDEL/cmp

bash "$Current_folder"/consensus_handle3.sh "$Out_dir"SNP/cmp

bash "$Current_folder"/consensus_handle3.sh "$Out_dir"INDEL/cmp

