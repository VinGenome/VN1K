#Dragen_folder="/dragennfs/area1/trangth18/GDB/"
#DV_folder="/dragennfs/area1/trangth18/GLNEXUS/"
#GATK_folder="/dragennfs/area1/trangth18/GATKDB/"
#GATK_folder="/dragennfs/area1/trangth18/GATK_combineGVCF/"
#GATK_folder="/dragennfs/area7/testIllumina/dragen3.7/"
Picard_root="/dragennfs/area1/analysis/picard/"
#Out_dir="/dragennfs/area7/PopTest/Consensus_chr22/"
Ref_folder="/home/shared/references/Homo_sapiens_assembly38.fasta"

Dragen_folder="/dragennfs/area16/Population/final/Dragen_finalset/"
Dragen_folder="/dragennfs/area1/TTS/tien/Consensus/consensus1/"
#GATK_folder="/dragennfs/area16/Population/final/GATK_finalset/"
GATK_folder="/dragennfs/area15/Population/GenomicsDB_GATK"
#DV_folder="/dragennfs/area16/Population/final/DV_finalset/"
DV_folder="/dragennfs/area15/Population/GLNexus/rerun/"


#list combine vcf
GATK1011_folder="/dragennfs/area15/Population/GATK_1011/"
Dragen1011_folder="/dragennfs/area15/Population/Dragen_1011/"
DV1011_folder="/dragennfs/area15/Population/GLNexus/rerun/"

GATK1011_file="GATK_1011.norm.vcf.gz"
DV1011_file="all_1011"
Dragen1011_file="dragen_1011.norm.vcf.gz"

GATK_file="testPop_1008.gatk"
GATK_file="all_GATK.norm.pass.vqsr.vcf.gz"
Dragen_file="testPop_1008.dragen"
DV_file="testPop_1008.dv"

DV_1011="all_1011"

In_dir="/dragennfs/area16/Population/final/consensus/"
#Out_dir="/dragennfs/area7/PopTest/Consensus3/PostProcessConsensus/"

Out_dir="/dragennfs/area15/tien/PostProcess/0123/consensus23.passKHV.passHWE.addMissingID.rsID.norm.filltags.multi.rmNonRef.vcf.gz"
#Out_dir="/dragennfs/area10/Pop/consensus23.passKHV.passHWE.addMissingID.rsID.norm.filltags.multi.rmNonRef.vcf.gz"
#Out_dir="/isilon/dragennfs/area15/tien/PostProcess/0123/consensus23.passKHV.passHWE.addMissingID.rsID.norm.filltags.multi.rmNonRef.vcf.gz"
sitesOnly_1KVG="/dragennfs/area15/tien/PostProcess/0123/Annotate/consensus23.sitesOnly.passKHV.passHWE.addMissingID.rsID.norm.filltags.multi.rmNonRef.vcf.gz"

Old_dir="/dragennfs/area9/analysis/trang_public_data/PostProcessConsensus_0830/"

gnomAD_db="/dragennfs/area9/analysis/trang_public_data/PostProcessConsensus_0830/gnomAD.v3_all.filtered.txt.gz"

IGSR_HC="/dragennfs/area11/IGSR_HC_Data/VCF/total.vcf.gz"
KHV_HC="/dragennfs/area11/IGSR_HC_Data/VCF/KHV/"

Current_folder=$(pwd)
GATK_root="/home/shared/tools/gatk-4.1.8.1/"

Chr=""
gnomAD_chr=""
KHV_chr=""

for i in {1..22}
do
        Chr += "$In_dir""$i""_consensus.filltags.vcf.gz "
        awk '{ if ($0 ~ /^chr/) print }' "$gnomAD_db""$i""_gnomAD.txt" | awk 'BEGIN { FS = OFS = "\t" } { for(i=1; i<=NF; i++) if($i ~ /^ *$/) $i = 0 }; 1' | sort -k 2n | bgzip -c>"$gnomAD_db""$i""_gnomAD.sorted.txt.gz"
        gnomAD_chr+="$gnomAD_db""$i""_gnomAD.sorted.txt.gz "
        KHV_chr+="$KHV_HC""CCDG_14151_B01_GRM_WGS_2020-08-05_chr""$i"".filtered.shapeit2-duohmm-phased.filtered.vcf "
done

#header gnomAD
#,CHROM,POS,ID,REF,ALT,AN,AN_male,AN_female,AC,AC_male,AC_female,nhomalt,nhomalt_male,nhomalt_female
cat /dragennfs/area7/testVEP/gnomAD/gnomeAD_v3.chr1_1.csv /dragennfs/area7/testVEP/gnomAD/gnomeAD_v3.chr1_2.csv /dragennfs/area7/testVEP/gnomAD/gnomeAD_v3.chr1_3.csv /dragennfs/area7/testVEP/gnomAD/gnomeAD_v3.chr1_4.csv | awk -F',' '{ if ($0 !~ /^,/) print $2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15 }' |bgzip -c>/dragennfs/area7/testVEP/gnomAD/gnomeAD_v3.chr1.txt.gz

cmd="bcftools concat $Chr -Oz -o "$Out_dir"consensusPop.vcf.gz"
$cmd

tabix -p vcf "$Out_dir"consensusPop.vcf.gz
bcftools stats  "$Out_dir"consensusPop.vcf.gz> "$Out_dir"consensusPop.bcftools_stats.txt

bcftools view -a  "$Out_dir"consensusPop.vcf.gz |bcftools view -m 2 -Oz -o "$Out_dir"consensusPop.rmNonRef.vcf.gz
tabix -p vcf "$Out_dir"consensusPop.rmNonRef.vcf.gz
bcftools stats "$Out_dir"consensusPop.rmNonRef.vcf.gz>"$Out_dir"consensusPop.rmNonRef.bcftools_stats.txt

bcftools norm -m +any -f "$Ref_folder" "$Out_dir"consensusPop.rmNonRef.vcf.gz -Oz -o "$Out_dir"consensusPop.multi.rmNonRef.vcf.gz
tabix -p vcf "$Out_dir"consensusPop.multi.rmNonRef.vcf.gz
bcftools stats "$Out_dir"consensusPop.multi.rmNonRef.vcf.gz>"$Out_dir"consensusPop.multi.rmNonRef.bcftools_stats.txt

bcftools +fill-tags "$Out_dir"consensusPop.multi.rmNonRef.vcf.gz -Oz -o "$Out_dir"consensusPop.filltags.multi.rmNonRef.vcf.gz -- -t all
tabix -p vcf "$Out_dir"consensusPop.filltags.multi.rmNonRef.vcf.gz
bcftools stats "$Out_dir"consensusPop.filltags.multi.rmNonRef.vcf.gz>"$Out_dir"consensusPop.filltags.multi.rmNonRef.bcftools_stats.txt

bcftools +af-dist "$Out_dir"consensusPop.filltags.multi.rmNonRef.vcf.gz>"$Out_dir"consensusPop.filltags.multi.rmNonRef.af_dist.txt
bcftools +allele-length "$Out_dir"consensusPop.filltags.multi.rmNonRef.vcf.gz>"$Out_dir"consensusPop.filltags.multi.rmNonRef.allele_length.txt
bcftools +check-sparsity "$Out_dir"consensusPop.filltags.multi.rmNonRef.vcf.gz>"$Out_dir"consensusPop.filltags.multi.rmNonRef.check_sparsity.txt
bcftools +mendelian "$Out_dir"consensusPop.filltags.multi.rmNonRef.vcf.gz>"$Out_dir"consensusPop.filltags.multi.rmNonRef.mendelian.txt

bcftools view -G "$Out_dir"consensusPop.filltags.multi.rmNonRef.vcf.gz -Oz -o "$Out_dir"consensusPop.sitesOnly.filltags.multi.rmNonRef.vcf.gz
tabix -p vcf "$Out_dir"consensusPop.sitesOnly.filltags.multi.rmNonRef.vcf.gz

vt decompose -s "$Out_dir"consensusPop.sitesOnly.filltags.multi.rmNonRef.vcf.gz | vt normalize - -r "$Ref_folder" | vt uniq - -o "$Out_dir"consensusPop.sitesOnly.norm.filltags.multi.rmNonRef.vcf.gz
tabix -p vcf "$Out_dir"consensusPop.sitesOnly.norm.filltags.multi.rmNonRef.vcf.gz

bcftools stats  "$Out_dir"consensusPop.sitesOnly.norm.filltags.multi.rmNonRef.vcf.gz> "$Out_dir"consensusPop.sitesOnly.norm.filltags.multi.rmNonRef.bcftools_stats.txt


bcftools view -G "$Out_dir"consensusPop.filltags.multi.rmNonRef.vcf.gz -Oz -o "$Out_dir"consensusPop.sitesOnly.filltags.multi.rmNonRef.vcf.gz
tabix -p vcf "$Out_dir"consensusPop.sitesOnly.filltags.multi.rmNonRef.vcf.gz

vcftools --gzvcf "$Out_dir"consensusPop.sitesOnly.vep.filltags.multi.rmNonRef.vcf.gz --positions "$gnomAD_db"gnomAD.v3_all.txt.gz --recode |bgzip -c>"$Out_dir"cmp_gnomAD/consensusPop.includeGnomAD.vcf.gz
vcftools --gzvcf "$Out_dir"consensusPop.sitesOnly.vep.filltags.rmNonRef.vcf.gz --gzdiff "$Out_dir"1KGP_HC.sitesOnly.vcf.gz --diff-site --out "$Out_dir"cmp_1KGP/VN_1KGP
vcftools --gzvcf "$Out_dir"consensusPop.sitesOnly.vep.filltags.rmNonRef.vcf.gz --gzdiff "$Out_dir"1KGP_HC.sitesOnly.vcf.gz --diff-site-discordance --out "$Out_dir"cmp_1KGP/VN_1KGP
vcftools --gzvcf "$Out_dir"consensusPop.sitesOnly.vep.filltags.rmNonRef.vcf.gz --gzdiff "$Out_dir"1KGP_HC.sitesOnly.vcf.gz --diff-discordance-matrix --out "$Out_dir"cmp_1KGP/VN_1KGP

vcftools --gzvcf "$Out_dir"consensusPop.sitesOnly.vep.filltags.rmNonRef.vcf.gz --gzdiff "$Out_dir"KHV_HC.sitesOnly.vcf.gz --diff-site --out "$Out_dir"cmp_KHV/VN_KHV
vcftools --gzvcf "$Out_dir"consensusPop.sitesOnly.vep.filltags.rmNonRef.vcf.gz --gzdiff "$Out_dir"KHV_HC.sitesOnly.vcf.gz --diff-site-discordance --out "$Out_dir"cmp_KHV/VN_KHV
vcftools --gzvcf "$Out_dir"consensusPop.sitesOnly.vep.filltags.rmNonRef.vcf.gz --gzdiff "$Out_dir"KHV_HC.sitesOnly.vcf.gz --diff-discordance-matrix --out "$Out_dir"cmp_KHV/VN_KHV

#prepare data for annotation

#KHV header file
##INFO=<ID=KHV_HC_AF,Number=A,Type=Float,Description="KHV Allele Frequency from 1KGP High coverage, for each ALT allele, in the same order as listed">

#gnomAD header file
##INFO=<ID=gnomAD_AC,Number=1,Type=Integer,Description="Allele Count from gnomAD version 3">
##INFO=<ID=gnomAD_AF,Number=A,Type=Float,Description="Allele Frequency from gnomAD version 3">
##INFO=<ID=gnomAD_EAS_AC,Number=1,Type=Integer,Description="EAS Allele Count from gnomAD version 3">
##INFO=<ID=gnomAD_EAS_AF,Number=A,Type=Float,Description="EAS Allele Frequency from gnomAD version 3">

#1KGP header file
##INFO=<ID=1KGP_HC_AF,Number=A,Type=Float,Description="Allele Frequency from 1KGP High coverage">
##INFO=<ID=1KGP_HC_EAS_AF,Number=A,Type=Float,Description="EAS Allele Frequency from 1KGP High coverage">

cmd="cat $gnomAD_chr
$cmd>"$gnomAD_db"gnomAD.txt.gz"
tabix -s1 -b2 -e2 "$gnomAD_db"gnomAD.txt.gz

#cmd="bcftools concat $KHV_chr -Oz -o "$Out_dir"KHV_HC.vcf.gz"
#$cmd

#tabix -p vcf "$Out_dir"KHV_HC.vcf.gz
#bcftools view -G "$Out_dir"KHV_HC.vcf.gz -Oz -o "$Out_dir"KHV_HC.sitesOnly.vcf.gz
#tabix -p vcf "$Out_dir"KHV_HC.sitesOnly.vcf.gz

bcftools view -G "${IGSR_HC}" -Oz -o "$Out_dir"1KGP_HC.sitesOnly.vcf.gz
tabix -p vcf "$Out_dir"1KGP_HC.sitesOnly.vcf.gz

bcftools query "$Out_dir"KHV_HC.sitesOnly.vcf.gz -f '%CHROM\t%POS\t%REF\t%ALT\t%AF\n' |bgzip -c>"$Out_dir"KHV_HC.anno.txt.gz
bcftools query "$Out_dir"1KGP_HC.sitesOnly.vcf.gz -f '%CHROM\t%POS\t%REF\t%ALT\t%AF\n' |bgzip -c>"$Out_dir"1KGP_HC.anno.txt.gz
zcat /dragennfs/area1/TTS/tien/SNPChip/gnomAD/gnomAD.v3_all.txt.gz | awk '{ if ($7 >0) print }' |bgzip -c>"$Out_dir"gnomAD.v3_all.filtered.txt.gz
bgzip  /dragennfs/area7/HGMD/HGMD_202101/hgmd_pro_2021.1_hg38.vcf -c >"$Out_dir"HGMD_pro_2021.1.hg38.vcf.gz

sort -k1,1V -k2,2n "$Out_dir"GWAS_catelog.extracted.txt>"$Out_dir"GWAS_catelog.extracted.sorted.txt
bgzip "$Out_dir"GWAS_catelog.extracted.sorted.txt

tabix -s1 -b2 -e2 "$Out_dir"GWAS_catelog.extracted.sorted.txt.gz
tabix -s1 -b2 -e2 "$Out_dir"KHV_HC.anno.txt.gz
tabix -s1 -b2 -e2 "$Out_dir"1KGP_HC.anno.txt.gz
tabix -s1 -b2 -e2 "$Out_dir"gnomAD.v3_all.filtered.txt.gz
tabix -p vcf "$Out_dir"HGMD_pro_2021.1.hg38.vcf.gz

bcftools annotate "$Out_dir"consensusPop.sitesOnly.norm.filltags.multi.rmNonRef.vcf.gz -a "$Out_dir"KHV_HC.anno.txt.gz -h KHV.header -c CHROM,POS,REF,ALT,KHV_HC_AF -Oz -o "$Out_dir"consensusPop.sitesOnly.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz

tabix -p vcf "$Out_dir"consensusPop.sitesOnly.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz

bcftools annotate "$Out_dir"consensusPop.sitesOnly.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz -a "$Out_dir"1KGP_HC.anno.txt.gz -c CHROM,POS,REF,ALT,1KGP_HC_AF -h 1KGP.hdr -Oz -o "$Out_dir"consensusPop.sitesOnly.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz

tabix -p vcf "$Out_dir"consensusPop.sitesOnly.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz

#CHROM   POS     ID      REF     ALT     FILTER  AC      AF      AN      AN_male AN_female       AC_male AC_female       AF_male AF_female       AC_eas  AF_eas  AC_sas  AF_sas  AC_female_1     nhomalt nhomalt_male    nhomalt_female
bcftools annotate "$Out_dir"consensusPop.sitesOnly.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz -a "$Out_dir"gnomAD.v3_all.filtered.txt.gz -h gnomAD_anno.hdr -c CHROM,POS,-,REF,ALT,-,gnomAD_AC,gnomAD_AF,-,-,-,-,-,gnomAD_AF_male,gnomAD_AF_female,gnomAD_AC_eas,gnomAD_AF_eas,gnomAD_AC_sas,gnomAD_AF_sas,-,gnomAD_nhomalt,gnomAD_nhomalt_male,gnomAD_nhomalt_female -Oz -o "$Out_dir"consensusPop.sitesOnly.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz

tabix -p vcf -f "$Out_dir"consensusPop.sitesOnly.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz
tabix -s1 -b2 -e2 "$Out_dir"hgmd.txt.gz

bcftools annotate "$Out_dir"consensusPop.sitesOnly.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz -a "$Out_dir"hgmd.txt.gz -h HGMD.hdr -c CHROM,POS,-,REF,ALT,HGMD_PubmedID,HGMD_rankscore,HGMD_disease,HGMD_comment,HGMD_class,HGMD_MUT -Oz -o "$Out_dir"consensusPop.sitesOnly.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz

tabix -p vcf "$Out_dir"consensusPop.sitesOnly.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz

vep -i "$Out_dir"consensusPop.sitesOnly.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz --offline --cache --cache_version 100 --dir_cache /home/shared/.vep/  -fasta /home/shared/.vep/homo_sapiens/100_GRCh38/Homo_sapiens.GRCh38.dna.toplevel.fa.gz --plugin Phenotypes,dir=/dragennfs/area7/PopTest/vep_plugins/phenotypes.gff.gz,include_types=Gene --vcf --verbose --fork 48 --buffer_size 30000 --minimal --vcf_info_field "ANN" --output_file "$Out_dir"consensusPop.sitesOnly.addPhenotype.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz --compress_output bgzip
tabix -p vcf "$Out_dir"consensusPop.sitesOnly.addPhenotype.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz

vep -i "$Out_dir"consensusPop.sitesOnly.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz --offline  --cache --cache_version 100 --dir_cache /home/shared/.vep/  -fasta /home/shared/.vep/homo_sapiens/100_GRCh38/Homo_sapiens.GRCh38.dna.toplevel.fa.gz --plugin dbNSFP,/dragennfs/area7/PopTest/vep_plugins/dbNSFP/dbNSFP4.2a_hg38.gz,genename,Ensembl_geneid,Ensembl_transcriptid,Ensembl_proteinid,APPRIS,TSL,VEP_canonical,cds_strand,refcodon,codonpos,codon_degeneracy,Ancestral_allele,AltaiNeandertal,Denisova,VindijiaNeandertal,SIFT_score,SIFT_pred,SIFT4G_score,SIFT4G_pred,Polyphen2_HDIV_score,Polyphen2_HDIV_pred,Polyphen2_HVAR_score,Polyphen2_HVAR_pred,LRT_score,LRT_pred,LRT_Omega,MutationTaster_score,MutationTaster_pred,MutationAssessor_score,MutationAssessor_pred,FATHMM_score,FATHMM_pred,PROVEAN_score,PROVEAN_pred,VEST4_score,MetaSVM_score,MetaSVM_pred,MetaLR_score,MetaLR_pred,MetaRNN_score,MetaRNN_pred,REVEL_score,MutPred_score,MutPred_protID,MutPred_Top5features,MVP_score,MPC_score,PrimateAI_score,PrimateAI_pred,DEOGEN2_score,DEOGEN2_pred,BayesDel_addAF_score,BayesDel_addAF_pred,ClinPred_score,ClinPred_pred,Aloft_pred,Aloft_Confidence,CADD_raw,CADD_phred,DANN_score,GenoCanyon_score,integrated_fitCons_score,gnomAD_genomes_AC,gnomAD_genomes_AN,gnomAD_genomes_AF,gnomAD_genomes_nhomalt,gnomAD_genomes_POPMAX_AC,gnomAD_genomes_POPMAX_AF,clinvar_id,clinvar_clnsig,clinvar_trait,clinvar_review,clinvar_hgvs,clinvar_var_source,clinvar_MedGen_id,clinvar_OMIM_id,clinvar_Orphanet_id,Interpro_domain,GTEx_V8_gene,GTEx_V8_tissue,Geuvadis_eQTL_target_gene --vcf --verbose --fork 48 --buffer_size 30000 --minimal --vcf_info_field "ANN" --output_file "$Out_dir"consensusPop.sitesOnly.addDNFS.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz --compress_output bgzip

tabix -p vcf "$Out_dir"consensusPop.sitesOnly.addDNFS.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz

#bcftools +split-vep "$Out_dir"consensusPop.sitesOnly.addDNFS.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/AF\t%INFO/AC\t%INFO/AC_Hom\t%INFO/AC_Het\t%INFO/AC_Hemi\t%INFO/MAF\t%INFO/HGMD_PubmedID\t%INFO/HGMD_rankscore\t%INFO/HGMD_disease\t%INFO/HGMD_comment\t%INFO/HGMD_class\t%INFO/HGMD_MUT\t%INFO/KHV_HC_AF\t%INFO/1KGP_HC_AF\t%INFO/gnomAD_AC\t%INFO/gnomAD_AF\t%INFO/gnomAD_AF_male\t%INFO/gnomAD_AF_female\t%INFO/gnomAD_AF_eas\t%INFO/gnomAD_AF_sas\t%INFO/gnomAD_nhomalt\t%INFO/gnomAD_nhomalt_male\t%INFO/gnomAD_nhomalt_female\t%genename\t%Ensembl_geneid\t%Ensembl_transcriptid\t%Ensembl_proteinid\t%APPRIS\t%TSL\t%VEP_canonical\t%cds_strand\t%refcodon\t%codonpos\t%codon_degeneracy\t%Ancestral_allele\t%AltaiNeandertal\t%Denisova\t%VindijiaNeandertal\t%SIFT_score\t%SIFT_pred\t%SIFT4G_score\t%SIFT4G_pred\t%Polyphen2_HDIV_score\t%Polyphen2_HDIV_pred\t%Polyphen2_HVAR_score\t%Polyphen2_HVAR_pred\t%LRT_score\t%LRT_pred\t%LRT_Omega\t%MutationTaster_score\t%MutationTaster_pred\t%MutationAssessor_score\t%MutationAssessor_pred\t%FATHMM_score\t%FATHMM_pred\t%PROVEAN_score\t%PROVEAN_pred\t%VEST4_score\t%MetaSVM_score\t%MetaSVM_pred\t%MetaLR_score\t%MetaLR_pred\t%MetaRNN_score\t%MetaRNN_pred\t%REVEL_score\t%MutPred_score\t%MutPred_protID\t%MutPred_Top5features\t%MVP_score\t%MPC_score\t%PrimateAI_score\t%PrimateAI_pred\t%DEOGEN2_score\t%DEOGEN2_pred\t%BayesDel_addAF_score\t%BayesDel_addAF_pred\t%ClinPred_score\t%ClinPred_pred\t%LIST-S2_score\t%LIST-S2_pred\t%Aloft_pred\t%Aloft_Confidence\t%CADD_raw\t%CADD_phred\t%DANN_score\t%Eigen-phred_coding\t%GenoCanyon_score\t%integrated_fitCons_score\t%GERP++_NR\t%GERP++_RS\t%GERP++_RS_rankscore\t%gnomAD_genomes_POPMAX_AC\t%gnomAD_genomes_POPMAX_AF\t%clinvar_id\t%clinvar_clnsig\t%clinvar_trait\t%clinvar_review\t%clinvar_hgvs\t%clinvar_var_source\t%clinvar_MedGen_id\t%clinvar_OMIM_id\t%clinvar_Orphanet_id\t%Interpro_domain\t%GTEx_V8_gene\t%GTEx_V8_tissue\t%Geuvadis_eQTL_target_gene' -s worst -a ANN |bgzip -c >"$Out_dir"consensusPop.score.extracted.txt.gz

bcftools +split-vep "$Out_dir"consensusPop.sitesOnly.addDNFS.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/AF\t%INFO/AC\t%INFO/AC_Hom\t%INFO/AC_Het\t%INFO/AC_Hemi\t%INFO/MAF\t%INFO/HGMD_PubmedID\t%INFO/HGMD_rankscore\t%INFO/HGMD_disease\t%INFO/HGMD_comment\t%INFO/HGMD_class\t%INFO/HGMD_MUT\t%INFO/KHV_HC_AF\t%INFO/1KGP_HC_AF\t%INFO/gnomAD_AC\t%INFO/gnomAD_AF\t%INFO/gnomAD_AF_male\t%INFO/gnomAD_AF_female\t%INFO/gnomAD_AF_eas\t%INFO/gnomAD_AF_sas\t%INFO/gnomAD_nhomalt\t%INFO/gnomAD_nhomalt_male\t%INFO/gnomAD_nhomalt_female\t%ANN' -a ANN -A tab -d -s worst |bgzip -c >"$Out_dir"consensusPop.score.extract.txt.gz

bcftools annotate "$Out_dir"consensusPop.sitesOnly.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz -a "$Out_dir"GWAS_catelog.sorted.extracted.txt.gz -h GWAS.hdr -c CHROM,POS,GWAS_RSID,GWAS_RISK_ALLELE,GWAS_REPORTED_GENES,GWAS_MAPPED_GENES,GWAS_RISK_ALLELE_AF,GWAS_OR,GWAS_PVALUE,GWAS_TRAIT -Oz -o "$Out_dir"consensusPop.sitesOnly.annoGWAS.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz

bcftools query "$Out_dir"consensusPop.sitesOnly.annoGWAS.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/AF\t%INFO/AC\t%INFO/AC_Hom\t%INFO/AC_Het\t%INFO/AC_Hemi\t%INFO/MAF\t%GWAS_RSID\t%GWAS_RISK_ALLELE\t%GWAS_REPORTED_GENES\t%GWAS_MAPPED_GENES\t%GWAS_RISK_ALLELE_AF\t%GWAS_OR\t%GWAS_PVALUE\t%GWAS_TRAIT\t%HGMD_rankscore\t%HGMD_disease\t%HGMD_comment\t%HGMD_class\t%HGMD_MUT\t%KHV_HC_AF\t%1KGP_HC_AF\t%INFO/gnomAD_AC\t%INFO/gnomAD_AF\t%INFO/gnomAD_AF_male\t%INFO/gnomAD_AF_female\t%INFO/gnomAD_AF_eas\t%INFO/gnomAD_AF_sas\t%INFO/gnomAD_nhomalt\t%INFO/gnomAD_nhomalt_male\t%INFO/gnomAD_nhomalt_female\n'|bgzip -c>"$Out_dir"cmp_GWAS/consensusPop.GWAS.overlapHGMD.GnomAF.KHVAF.1KGPAF.txt.gz


zcat "$Out_dir"consensusPop.score.extracted.txt.gz | awk '{ if ($16 != "") print }' |bgzip -c>"$Out_dir"cmp_HGMD/consensusPop.filterHGMD.scored.extracted.txt.gz
zcat "$Out_dir"consensusPop.score.extracted.txt.gz | awk '{ if ($17 != "") print }' |bgzip -c>"$Out_dir"cmp_KHV/consensusPop.filterKHV.scored.extracted.txt.gz
zcat "$Out_dir"consensusPop.score.extracted.txt.gz | awk '{ if ($19 != "") print }' |bgzip -c>"$Out_dir"cmp_1KGP/consensusPop.filter1KGP.scored.extracted.txt.gz
zcat "$Out_dir"consensusPop.score.extracted.txt.gz | awk '{ if ($99 != "") print }' |bgzip -c>"$Out_dir"cmp_ClinVar/consensusPop.filterClinvar.scored.extracted.txt.gz

vep -i "$Out_dir"consensusPop.sitesOnly.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz --cache --cache_version 100 --dir_cache /home/shared/.vep/ --sift b --symbol --offline --polyphen b --gene_phenotype --variant_class --af_1kg --hgvs --regulatory --protein --biotype --phased --allele_number --transcript_version --ccds --domain --uniprot --hgvsg -fasta /home/shared/.vep/homo_sapiens/100_GRCh38/Homo_sapiens.GRCh38.dna.toplevel.fa.gz -force_overwrite --vcf --verbose --fork 48 --buffer_size 30000 --minimal --vcf_info_field "ANN" --transcript_version --tsl --appris --canonical --mane --domains --check_existing --af --max_af --af_gnomad --pubmed --output_file "$Out_dir"consensusPop.sitesOnly.vep.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz --compress_output bgzip

/mnt/isilon/GenomeAsia/tien/shared_67_bak/shared/.vep/ 

vep -i cmp_dbsnp/0000.vcf.gz --cache --cache_version 100 --dir_cache /mnt/isilon/GenomeAsia/tien/shared_67_bak/shared/.vep/ --sift b --symbol --offline --polyphen b --gene_phenotype --variant_class --af_1kg --hgvs --regulatory --protein --biotype --phased --allele_number --transcript_version --ccds --domain --uniprot --hgvsg -fasta /mnt/isilon/GenomeAsia/tien/shared_67_bak/shared/.vep/homo_sapiens/100_GRCh38/Homo_sapiens.GRCh38.dna.toplevel.fa.gz -force_overwrite --vcf --verbose --fork 48 --buffer_size 30000 --minimal --vcf_info_field "ANN" --transcript_version --tsl --appris --canonical --mane --domains --check_existing --af --max_af --af_gnomad --pubmed --output_file cmp_dbsnp/novel_1KVG.vep.vcf.gz 

tabix -p vcf -f "$Out_dir"consensusPop.sitesOnly.vep.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz

bcftools +split-vep "$Out_dir"consensusPop.sitesOnly.vep.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.vcf.gz -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/AF\t%INFO/AC\t%INFO/AC_Hom\t%INFO/AC_Het\t%INFO/AC_Hemi\t%INFO/MAF\t%INFO/HGMD_PubmedID\t%INFO/HGMD_rankscore\t%INFO/HGMD_disease\t%INFO/HGMD_comment\t%INFO/HGMD_class\t%INFO/HGMD_MUT\t%INFO/KHV_HC_AF\t%INFO/1KGP_HC_AF\t%INFO/gnomAD_AC\t%INFO/gnomAD_AF\t%INFO/gnomAD_AF_male\t%INFO/gnomAD_AF_female\t%INFO/gnomAD_AF_eas\t%INFO/gnomAD_AF_sas\t%INFO/gnomAD_nhomalt\t%INFO/gnomAD_nhomalt_male\t%INFO/gnomAD_nhomalt_female\t%IMPACT\t%Consequence\t%SYMBOL\t%Existing_variation\t%SIFT\t%PolyPhen\t%TSL\t%APPRIS\t%CCDS\t%ENSP\t%SWISSPROT\t%TREMBL\t%UNIPARC\t%UNIPROT_ISOFORM\t%MAX_AF\t%MAX_AF_POPS\t%MOTIF_NAME\t%CLIN_SIG\t%SOMATIC\t%EXON\t%INTRON\t%CDS_position\t%Protein_position\t%Amino_acids\n' -s worst -a ANN |bgzip -c >"$Out_dir"consensusPop.sitesOnly.vep.annoGnomAD.add1KGP_AF.addKHV_AF.norm.filltags.multi.rmNonRef.extracted.txt.gz

###INFO=<ID=ANN,Number=.,Type=String,Description="Consequence annotations from Ensembl VEP. Format: Allele|Consequence|IMPACT|SYMBOL|Gene|Feature_type|Feature|BIOTYPE|EXON|INTRON|HGVSc|HGVSp|cDNA_position|CDS_position|Protein_position|Amino_acids|Codons|Existing_variation|ALLELE_NUM|DISTANCE|STRAND|FLAGS|MINIMISED|SYMBOL_SOURCE|HGNC_ID|APPRIS|Aloft_Confidence|Aloft_pred|AltaiNeandertal|Ancestral_allele|BayesDel_addAF_pred|BayesDel_addAF_score|CADD_phred|CADD_raw|ClinPred_pred|ClinPred_score|DANN_score|DEOGEN2_pred|DEOGEN2_score|Denisova|Eigen-phred_coding|Ensembl_geneid|Ensembl_proteinid|Ensembl_transcriptid|FATHMM_pred|FATHMM_score|GERP++_NR|GERP++_RS|GERP++_RS_rankscore|GTEx_V8_gene|GTEx_V8_tissue|GenoCanyon_score|Geuvadis_eQTL_target_gene|Interpro_domain|LIST-S2_pred|LIST-S2_score|LRT_Omega|LRT_pred|LRT_score|MPC_score|MVP_score|MetaLR_pred|MetaLR_score|MetaRNN_pred|MetaRNN_score|MetaSVM_pred|MetaSVM_score|MutPred_Top5features|MutPred_protID|MutPred_score|MutationAssessor_pred|MutationAssessor_score|MutationTaster_pred|MutationTaster_score|PROVEAN_pred|PROVEAN_score|Polyphen2_HDIV_pred|Polyphen2_HDIV_score|Polyphen2_HVAR_pred|Polyphen2_HVAR_score|PrimateAI_pred|PrimateAI_score|REVEL_score|SIFT4G_pred|SIFT4G_score|SIFT_pred|SIFT_score|TSL|VEP_canonical|VEST4_score|VindijiaNeandertal|cds_strand|clinvar_MedGen_id|clinvar_OMIM_id|clinvar_Orphanet_id|clinvar_clnsig|clinvar_hgvs|clinvar_id|clinvar_review|clinvar_trait|clinvar_var_source|codon_degeneracy|codonpos|genename|gnomAD_genomes_POPMAX_AC|gnomAD_genomes_POPMAX_AF|integrated_fitCons_score|refcodon">


#header
#1       2       3       4       5       6       7       8       9       10      11      12      13      14      15      16      17      18      19      20      21      22      23      24      25      26      27      28      29      30      31      32      33      34      35      36      37      38      39      40      41      42      43      44      45
#CHROM  POS     REF     ALT     INFO/AF INFO/AC INFO/AC_Hom     INFO/AC_Het     INFO/AC_Hemi    INFO/MAF        INFO/KHV_HC_AF  INFO/1KGP_HC_AF INFO/gnomAD_AC  INFO/gnomAD_AF  INFO/gnomAD_AF_male     INFO/gnomAD_AF_female   INFO/gnomAD_AF_eas      INFO/gnomAD_AF_sas      INFO/gnomAD_nhomalt     INFO/gnomAD_nhomalt_male        INFO/gnomAD_nhomalt_female      IMPACT  Consequence     SYMBOL  Existing_variation      SIFT    PolyPhen        TSL     APPRIS  CCDS    ENSP    SWISSPROT       TREMBL  UNIPARC UNIPROT_ISOFORM MAX_AF  MAX_AF_POPS     MOTIF_NAME      CLIN_SIG        SOMATIC EXON    INTRON  CDS_position    Protein_position        Amino_acids\n

zcat "$Out_dir"consensusPop.score.extracted.txt.gz | awk '{ if ($16 != "") print }' |bgzip -c>"$Out_dir"cmp_HGMD/consensusPop.filterHGMD.scored.extracted.txt.gz
zcat "$Out_dir"consensusPop.score.extracted.txt.gz | awk '{ if ($17 != "") print }' |bgzip -c>"$Out_dir"cmp_KHV/consensusPop.filterKHV.scored.extracted.txt.gz
zcat "$Out_dir"consensusPop.score.extracted.txt.gz | awk '{ if ($19 != "") print }' |bgzip -c>"$Out_dir"cmp_1KGP/consensusPop.filter1KGP.scored.extracted.txt.gz
zcat "$Out_dir"consensusPop.score.extracted.txt.gz | awk '{ if ($99 != "") print }' |bgzip -c>"$Out_dir"cmp_ClinVar/consensusPop.filterClinvar.scored.extracted.txt.gz

zcat "$Out_dir"consensusPop.sitesOnly.vep.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.filltags.multi.rmNonRef.extracted.txt.gz | awk '{ if ($39 ~ /Pathogenic/) print }'|bgzip -c >"$Out_dir"cmp_ClinVar/Pathogenic.txt.gz
zcat "$Out_dir"consensusPop.sitesOnly.vep.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.filltags.multi.rmNonRef.extracted.txt.gz | awk '{ if ($39 ~ /drug/) print }'|bgzip -c >"$Out_dir"cmp_ClinVar/drug_response.txt.gz

zcat "$Out_dir"consensusPop.sitesOnly.vep.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.filltags.multi.rmNonRef.extracted.txt.gz | awk '{ if ($22 ~ /HIGH/) print }'|bgzip -c >"$Out_dir"cmp_impact/HIGH.txt.gz
zcat "$Out_dir"consensusPop.sitesOnly.vep.annoHGMD.annoGnomAD.add1KGP_AF.addKHV_AF.filltags.multi.rmNonRef.extracted.txt.gz | awk '{ if ($22 ~ /MODERATE/) print }'|bgzip -c >"$Out_dir"cmp_impact/MODERATE.txt.gz
zcat "$Out_dir"consensusPop.sitesOnly.vep.annoGnomAD.annoHGMD.add1KGP_AF.addKHV_AF.filltags.multi.rmNonRef.extracted.txt.gz | awk '{ if ($22 ~ /LOW/) print }'|bgzip -c >"$Out_dir"cmp_impact/LOW.txt.gz
zcat "$Out_dir"consensusPop.sitesOnly.vep.annoGnomAD.annoHGMD.add1KGP_AF.addKHV_AF.filltags.multi.rmNonRef.extracted.txt.gz | awk '{ if ($22 ~ /MODIFIER/) print }'|bgzip -c >"$Out_dir"cmp_impact/MODIFIER.txt.gz

vep -i /mnt/isilon/1KVG/consensus23.sitesOnly.addDNFS.annoGnomAD.addHGMD.add1KGP_AF.addKHV_AF.passKHV.passHWE.addMissingID.rsID.norm.filltags.multi.rmNonRef.vcf.gz --offline  --cache --cache_version 100 --dir_cache /mnt/isilon/GenomeAsia/tien/shared_67_bak/shared/.vep/ -fasta /mnt/isilon/GenomeAsia/tien/shared_67_bak/shared/.vep/homo_sapiens/100_GRCh38/Homo_sapiens.GRCh38.dna.toplevel.fa.gz --plugin LoFtool,/mnt/isilon/GenomeAsia/tien/shared_67_bak/shared/.vep/Plugins/LoFtool_scores.txt --vcf --verbose --fork 48 --buffer_size 30000 --minimal --vcf_info_field "ANN" --output_file /mnt/isilon/1KVG/consensus23.LoF.vcf.gz --compress_output bgzip  --force_overwrite

perl ../../GenomeAsia/TrangTH/annovar/convert2annovar.pl -format vcf4 /dragennfs/area15/tien/PostProcess/0123/Annotate/consensus23.sitesOnly.passKHV.passHWE.addMissingID.rsID.norm.filltags.multi.rmNonRef.vcf.gz -outfile annovar_annot/1kvg.annovar_input --includeinfo 

perl ../../GenomeAsia/TrangTH/annovar/annotate_variation.pl -infoasscore -buildver hg38 -filter -dbtype vcf -vcfdbfile HGMD_pro.add_chr.vcf  annovar_annot/1kvg.annovar_input ../../GenomeAsia/TrangTH/annovar/humandb/

perl ../../GenomeAsia/TrangTH/annovar/annotate_variation.pl -infoasscore -buildver hg38 -filter -dbtype clinvar_20220320  annovar_annot/1kvg.annovar_input ../../GenomeAsia/TrangTH/annovar/humandb/