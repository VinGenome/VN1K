Picard_root="/dragennfs/area1/analysis/picard/"
GATK_root="/home/shared/tools/gatk-4.1.8.1/"
GATK3_root="/home/shared/tools/GenomeAnalysisTK-3.8-1-0/"
Reference_root="/home/shared/references/Homo_sapiens_assembly38.fasta"
Resource_root="/home/shared/standards/"
Picard_root="/home/shared/tools/picard/"

#DV_folder="/dragennfs/area4/Population/dragen-genotyper/"

#DV_file="testPop_1013.dragen"
#DV_file="testPop_1009.dv"

DV_folder="/dragennfs/area15/Population/GLNexus/rerun/"
DV_file="testPop_1011.dv_glnexus"

for i in {1..22}
do
        glnexus_cli --dir GLnexus_new --config DeepVariant --bed /dragennfs/area1/analysis/Batches/bed_files/chr"$i".bed /dragennfs/area4/Population/DV_gvcf/*.dv.gvcf.gz > "$DV_folder""$DV_file".chr"$i".bcf
        rm -r GLnexus_new/

        bcftools +fill-tags "$DV_folder""$DV_file".chr"$i".bcf -Oz -o "$DV_folder""$DV_file".chr"$i".filltags.vcf.gz -- -t all
        tabix -p vcf "$DV_folder""$DV_file".chr"$i".filltags.vcf.gz

        vt decompose -s "$DV_folder""$DV_file".chr"$i".filltags.vcf.gz |vt normalize - -r /home/shared/references/Homo_sapiens_assembly38.fasta | vt uniq - -o "$DV_folder""$DV_file".chr"$i".norm.filltags.vcf.gz
        tabix -p vcf "$DV_folder""$DV_file".chr"$i".norm.filltags.vcf.gz
                
        bcftools view "$DV_folder""$DV_file".chr"$i".norm.filltags.vcf.gz -S ^list_exclude1.csv | bcftools view -a | bcftools view -m 2 -Oz -o /dragennfs/area16/Population/final/DV_finalset/testPop_1008.dv_glnexus.chr"$i".norm.filltags.vcf.gz 
        tabix -p vcf /dragennfs/area16/Population/final/DV_finalset/testPop_1008.dv_glnexus.chr"$i".norm.filltags.vcf.gz
        
        vcftools --gzvcf "$DV_folder""$DV_file".chr"$i".norm.filltags.vcf.gz  --missing-site --out "$DV_folder"QC/"$DV_file".chr"$i"
        vcftools --gzvcf "$DV_folder""$DV_file".chr"$i".norm.filltags.vcf.gz  --missing-indv --out "$DV_folder"QC/"$DV_file".chr"$i"
        vcftools --gzvcf "$DV_folder""$DV_file".chr"$i".norm.filltags.vcf.gz  --indv-freq-burden --out "$DV_folder"QC/"$DV_file".chr"$i"
        vcftools --gzvcf "$DV_folder""$DV_file".chr"$i".norm.filltags.vcf.gz  --singletons --out "$DV_folder"QC/"$DV_file".chr"$i"
        vcftools --gzvcf "$DV_folder""$DV_file".chr"$i".norm.filltags.vcf.gz  --site-quality --out "$DV_folder"QC/"$DV_file".chr"$i"
done

arr=( 'X' 'Y' '_others')


for i in "${arr[@]}"
do
        glnexus_cli --dir GLnexus_new --config DeepVariant --bed /dragennfs/area1/analysis/Batches/bed_files/chr"$i".bed /dragennfs/area4/Population/DV_gvcf/*.dv.gvcf.gz > "$DV_folder""$DV_file".chr"$i".bcf
        rm -r GLnexus_new/
        
        bcftools +fill-tags "$DV_folder""$DV_file".chr"$i".bcf -Oz -o "$DV_folder""$DV_file".chr"$i".filltags.vcf.gz -- -t all
        tabix -p vcf "$DV_folder""$DV_file".chr"$i".filltags.vcf.gz

        vt decompose -s "$DV_folder""$DV_file".chr"$i".filltags.vcf.gz |vt normalize - -r /home/shared/references/Homo_sapiens_assembly38.fasta | vt uniq - -o "$DV_folder""$DV_file".chr"$i".norm.filltags.vcf.gz
        tabix -p vcf "$DV_folder""$DV_file".chr"$i".norm.filltags.vcf.gz

        bcftools view "$DV_folder""$DV_file".chr"$i".norm.filltags.vcf.gz -S ^list_exclude1.csv | bcftools view -a | bcftools view -m 2 -Oz -o /dragennfs/area16/Population/final/DV_finalset/testPop_1008.dv_glnexus.chr"$i".norm.filltags.vcf.gz
        tabix -p vcf /dragennfs/area16/Population/final/DV_finalset/testPop_1008.dv_glnexus.chr"$i".norm.filltags.vcf.gz

        vcftools --gzvcf "$DV_folder""$DV_file".chr"$i".norm.filltags.vcf.gz  --missing-site --out "$DV_folder"QC/"$DV_file".chr"$i"
        vcftools --gzvcf "$DV_folder""$DV_file".chr"$i".norm.filltags.vcf.gz  --missing-indv --out "$DV_folder"QC/"$DV_file".chr"$i"
        vcftools --gzvcf "$DV_folder""$DV_file".chr"$i".norm.filltags.vcf.gz  --indv-freq-burden --out "$DV_folder"QC/"$DV_file".chr"$i"
        vcftools --gzvcf "$DV_folder""$DV_file".chr"$i".norm.filltags.vcf.gz  --singletons --out "$DV_folder"QC/"$DV_file".chr"$i"
        vcftools --gzvcf "$DV_folder""$DV_file".chr"$i".norm.filltags.vcf.gz  --site-quality --out "$DV_folder"QC/"$DV_file".chr"$i"
done

java -jar "${Picard_root}"picard.jar MergeVcfs I=list1011_gl.csv O="$DV_folder"all_1011.norm.filltags.vcf.gz

java -jar "${Picard_root}"picard.jar MergeVcfs I=list1008_gl.csv O=/dragennfs/area16/Population/final/DV_finalset/all_1008.norm.filltags.vcf.gz

bcftools stats "$DV_folder"all_1011.norm.filltags.vcf.gz>"$DV_folder"all_1011.norm.filltags.bcftools_stats.txt
bcftools stats /dragennfs/area16/Population/final/DV_finalset/all_1008.norm.filltags.vcf.gz>/dragennfs/area16/Population/final/DV_finalset/all_1008.norm.filltags.bcftools_stats.txt

DV_file="all_1011"
mkdir "${DV_folder}"QC_"$DV_file"

vcftools --gzvcf "${DV_folder}""$DV_file".norm.filltags.vcf.gz --missing-site --out "${DV_folder}"QC_"$DV_file"

vcftools --gzvcf "${DV_folder}""$DV_file".norm.filltags.vcf.gz --missing-site --out "${DV_folder}"QC_"$DV_file"

vcftools --gzvcf "${DV_folder}""$DV_file".norm.filltags.vcf.gz --missing-indv --out "${DV_folder}"QC_"$DV_file"

vcftools --gzvcf "${DV_folder}""$DV_file".norm.filltags.vcf.gz --indv-freq-burden --out "${DV_folder}"QC_"$DV_file"

vcftools --gzvcf "${DV_folder}""$DV_file".norm.filltags.vcf.gz --singletons --out "${DV_folder}"QC_"$DV_file"

vcftools --gzvcf "${DV_folder}""$DV_file".norm.filltags.vcf.gz --site-quality --out "${DV_folder}"QC_"$DV_file"

vcftools --gzvcf "${DV_folder}""$DV_file".norm.filltags.vcf.gz --relatedness2 --out "${DV_folder}"QC_"$DV_file"

vcftools --gzvcf "${DV_folder}""$DV_file".norm.filltags.vcf.gz --relatedness --out "${DV_folder}"QC_"$DV_file"