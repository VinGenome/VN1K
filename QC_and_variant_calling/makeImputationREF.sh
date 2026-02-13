#code: /dragennfs/area1/trangth18/Ref1008/*sh
HC_1KGP="/dragennfs/area1/trangth18/Ref/1KGP_HC.total.vcf.gz"
KHV_HC="/dragennfs/area11/IGSR_HC_Data/VCF/KHV/"

#VN_ref="/dragennfs/area7/PopTest/Consensus3/PostProcessConsensus_0830/consensusPop.multi.rmNonRef.vcf.gz"
VN_ref="/dragennfs/area15/GT_data/testData/1KGP_PRS/plink_ori/consensus.fillID.norm.vcf.gz"
VN_ref="/dragennfs/area15/tien/PostProcess/0123/consensus23.passKHV.passHWE.addMissingID.rsID.norm.filltags.multi.rmNonRef.vcf.gz"
#Final_ref="/dragennfs/area1/trangth18/Ref1008/"
Ref_folder="/dragennfs/area15/Ref_imputation/"
#Reference_root="/home/shared/references/Homo_sapiens_assembly38.fasta"
Reference_root="/mnt/isilon/GenomeAsia/tien/shared_67_bak/shared/references/Homo_sapiens_assembly38.fasta"
extractPIR_folder="/dragennfs/area1/trangth18/Ref/"extractPIRs.v1.r68.x86_64"/"
RefMerge_folder="$Ref_folder"RefMerge1008_splitChr"/"

#bcftools concat /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr1.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr2.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr3.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr4.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr5.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr6.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr7.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr8.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr9.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr10.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr11.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr12.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr13.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr14.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr15.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr16.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr17.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr18.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr19.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr20.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr21.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chr22.Total.vcf.gz /dragennfs/area11/IGSR_HC_Data/VCF/Total.unrelated/CCDG_14151_B01_GRM_WGS_2020-08-05_chrX.Total.vcf.gz -Oz -o /dragennfs/area1/trangth18/Ref/1KGP_HC.total.vcf.gz

#tabix -p vcf /dragennfs/area1/trangth18/Ref/1KGP_HC.total.vcf.gz

#bcftools view "$VN_ref" -S ^list_exclude_refImpute.csv | bcftools view -a | bcftools view -m 2 -Oz -o "$Final_ref"VN_ref.vcf.gz
#vcftools --gzvcf "$VN_ref" --remove list_exclude_refImpute.csv --recode --stdout | bcftools view -a | bcftools view -m 2 -Oz -o "$Final_ref"VN_ref.vcf.gz
#tabix -p vcf "$Final_ref"VN_ref.vcf.gz

#echo "exclude done... Continue!"

[ ! -d "$Ref_folder"VN_1008/ ] &&  mkdir "$Ref_folder"VN_1008/
[ ! -d "$Ref_folder"1KGP_splitChr/ ] && mkdir "$Ref_folder"1KGP_splitChr/
[ ! -d "$RefMerge_folder" ] && mkdir "$RefMerge_folder"
#for i in {1..22}
#do
        i=$1
        [ ! -d "$Final_ref"chr"$i" ] && mkdir "$Final_ref"chr"$i"
        [ ! -d "$RefMerge_folder"chr"$i" ] && mkdir "$RefMerge_folder"chr"$i"

        #awk -v i="$i" '{ print $1"\t"$2"\tchr"i}' /dragennfs/area1/analysis/Batches/SizeCheck/list_bamID_path.txt>"$Final_ref"list_bwaBam_chr"$i".txt
#        bcftools view "$VN_ref".vcf.gz -r chr"$i" -Oz -o "$Final_ref"VN_splitChr/VN_ref.chr"$i".vcf.gz
#        bcftools view "$HC_1KGP" -r chr"$i" -Oz -o "$Ref_folder""1KGP_splitChr/"HC_1KGP.chr"$i".vcf.gz
        bcftools view "$VN_ref" -r chr"$i" -a -Oz -o "$Ref_folder"chr"$i"/VN_1008.chr"$i".vcf.gz
        bcftools norm -m +any -f "$Reference_root" "$Ref_folder"chr"$i"/VN_1008.chr"$i".vcf.gz | bcftools +fill-tags -- -t all | bcftools view -i 'F_MISSING <= 0.01' -Oz -o "$Ref_folder"chr"$i"/VN_1008.chr"$i".filterMissing.vcf.gz

        vt decompose -s "$Ref_folder"chr"$i"/VN_1008.chr"$i".filterMissing.vcf.gz | vt normalize - -r "$Reference_root" | vt uniq -| bcftools +fill-tags -- -t all | bcftools view -c 2 -m2 -M2 -i 'MAF>=0.001' -Oz -o "$Ref_folder"chr"$i"/VN_1008.chr"$i".biallele.vcf.gz

        "$extractPIR_folder"extractPIRs --bam "$Final_ref"list_bwaBam_chr"$i".txt --vcf "$Ref_folder"chr"$i"/VN_1008.chr"$i".biallele.vcf.gz --out "$Ref_folder"chr"$i"/VN_1008.PIRsList.chr"$i"
        shapeit -assemble --input-vcf "$Ref_folder"chr"$i"/VN_1008.chr"$i".biallele.vcf.gz --input-pir "$Ref_folder"chr"$i"/VN_1008.PIRsList.chr"$i" -O "$Ref_folder"chr"$i"/VN_1008.HaplotypeData.chr"$i" -T 50
        shapeit -convert --input-haps "$Ref_folder"chr"$i"/VN_1008.HaplotypeData.chr"$i" --output-vcf "$Ref_folder"chr"$i"/VN_1008.HaplotypeData.chr"$i".vcf -T 50

        bgzip "$Ref_folder"chr"$i"/VN_1008.HaplotypeData.chr"$i".vcf
        tabix -p vcf "$Ref_folder"chr"$i"/VN_1008.HaplotypeData.chr"$i".vcf.gz

        bcftools view  "$Ref_folder""1KGP_splitChr/"HC_1KGP.chr"$i".vcf.gz -i 'MAF>=0.001' -Oz -o  "$Ref_folder""1KGP_splitChr/"HC_1KGP.chr"$i".filterMAF.vcf.gz
        tabix -p vcf  "$Ref_folder""1KGP_splitChr/"HC_1KGP.chr"$i".filterMAF.vcf.gz
        bcftools merge "$Ref_folder""1KGP_splitChr/"HC_1KGP.chr"$i".filterMAF.vcf.gz "$Ref_folder"chr"$i"/VN_1008.HaplotypeData.chr"$i".vcf.gz -0 -Oz -o "$RefMerge_folder"chr"$i"/VN1008_1KGP.all.chr"$i".vcf.gz
        tabix -p vcf -f "$RefMerge_folder"chr"$i"/VN1008_1KGP.all.chr"$i".vcf.gz

        vt decompose -s  "$RefMerge_folder"chr"$i"/VN1008_1KGP.all.chr"$i".vcf.gz  | vt normalize - -r "$Reference_root" | vt uniq - -o "$RefMerge_folder"chr"$i"/VN1008_1KGP.all.chr"$i".norm.vcf.gz
        tabix -p vcf -f "$RefMerge_folder"chr"$i"/VN1008_1KGP.all.chr"$i".norm.vcf.gz

        bcftools +setGT  "$RefMerge_folder"chr"$i"/VN1008_1KGP.all.chr"$i".norm.vcf.gz -- -t q -i 'GT~"\."' -n 0p | bgzip -c> "$RefMerge_folder"chr"$i"/VN1008_1KGP.all.chr"$i".fix.norm.vcf.gz
        tabix -p vcf -f "$RefMerge_folder"chr"$i"/VN1008_1KGP.all.chr"$i".fix.norm.vcf.gz

#        cp "$Final_ref""1KGP_splitChr/"HC_1KGP.chr"$i".vcf.gz* "$Ref_folder"

#done
1:17027762_MNV-0_B_F_2716756691,1:17027762_MNV,BOT,[T/C],0071681916,ATTCTTCAGATTGAAACAATAAATAGGGACTAATGACCAGTTTCTCACGC,,,37,1,17354257,diploid,Homo sapiens,clinvar,0,BOT,TTTGCAATAAATTCTTCAGATTGAAACAATAAATAGGGACTAATGACCAGTTTCTCACGC[T/C]NNNGGACTGCAGATACTGCTGCTTGCCTTCCTGAGATTCATCCTTCTTCTTCAAATAAGG,CCTTATTTGAAGAAGAAGGATGAATCTCAGGAAGGCAAGCAGCAGTATCTGCAGTCCNNN[A/G]GCGTGAGAAACTGGTCATTAGTCCCTATTTATTGTTTCAATCTGAAGAATTTATTGCAAA,1984,3,0,+
#bcftools merge "$HC_1KGP" "$Final_ref"VN_ref.vcf.gz -Oz -o "$Final_ref"VN_1KGP_ref.vcf.gz
#tabix -p vcf "$Final_ref"VN_1KGP_ref.vcf.gz

#bcftools +fill-tags "$Final_ref"VN_1KGP_ref.vcf.gz -Oz -o "$Final_ref"VN_1KGP_ref.filltags.vcf.gz  -- -t all
#tabix -p vcf "$Final_ref"VN_1KGP_ref.filltags.vcf.gz

#vt decompose -s "$Final_ref"VN_1KGP_ref.filltags.vcf.gz  | vt normalize - -r "$Ref_folder" | vt uniq - -o "$Final_ref"VN_1KGP_ref.norm.filltags.vcf.gz
#tabix -p vcf  "$Final_ref"VN_1KGP_ref.norm.filltags.vcf.gz


#cp  "$Final_ref"VN_1KGP_ref.norm.filltags.vcf.gz* "$Ref_folder"

