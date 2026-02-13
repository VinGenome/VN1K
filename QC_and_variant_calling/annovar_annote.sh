cd /dragennfs/area3/BC


perl ../annovar_annot/annovar/convert2annovar.pl -format vcf4 BC_cases.vcf.gz -allsample -includeinfo -withfreq -comment -outfile BC_cases.avinput
perl ../annovar_annot/annovar/table_annovar.pl BC_cases.avinput --buildver hg38 --out BC_cases.annovar ../annovar_annot/annovar/humandb/ --remove --protocol refGene,cytoBand,exac03,avsnp150,dbnsfp42c,
clinvar_20220320 --operation g,r,f,f,f,f --nastring . --polish --otherinfo


perl ../../GenomeAsia/TrangTH/annovar/annotate_variation.pl -infoasscore -buildver hg38 -filter -dbtype vcf  -vcfdbfile hg38_clinvar_20220320  annovar_annot/1kvg.annovar_input ../../GenomeAsia/TrangTH/annovar/humandb/

perl ../../GenomeAsia/TrangTH/annovar/annotate_variation.pl -infoasscore -buildver hg38 -filter -dbtype clinvar_20220320  annovar_annot/1kvg.annovar_input ../../GenomeAsia/TrangTH/annovar/humandb/

perl /mnt/isilon/GenomeAsia/TrangTH/annovar/table_annovar.pl -buildver hg38 -out 1kvg_anno  annovar_annot/1kvg.annovar_input /mnt/isilon/GenomeAsia/TrangTH/annovar/humandb/ -remove -protocol refGene,cytoBand,exac03,avsnp150,dbnsfp42c,clinvar_20220320 -operation g,r,f,f,f,f -nastring . -polish

cd /dragennfs/area3/annovar_annot/
perl annovar/table_annovar.pl --buildver hg38 --out 1kvg_annovar 1kvg.annovar_input annovar/humandb/ --remove --protocol refGene,cytoBand,exac03,avsnp150,dbnsfp42c,clinvar_20220320 --operation g,r,f,f,f,f --nastring . --polish --otherinfo

Current_folder=$(pwd)
###--- filter HGMD
#awk '{ if ($0 ~ /AC=1;/) print }' "${Current_folder}"/1kvg.annovar_input.hg38_vcf_dropped > "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.HGMD.AC_1.txt
#awk '{ if ($0 ~ /AC=2;/) print }' "${Current_folder}"/1kvg.annovar_input.hg38_vcf_dropped > "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.HGMD.AC_2.txt
#awk '{ if ($0 ~ /AC=3;/) print }' "${Current_folder}"/1kvg.annovar_input.hg38_vcf_dropped > "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.HGMD.AC_3.txt
#awk '{ if ($0 !~ /AC=3;/ && $0 !~ /AC=1;/ && $0 !~ /AC=2;/ ) print }' "${Current_folder}"/1kvg.annovar_input.hg38_vcf_dropped > "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.HGMD.AC_over3.txt

#Category of HGMD: DP, DFP, FP, DM, DM?, R
#awk '{ if ($0 ~ /CLASS=DP;/) print }' "${Current_folder}"/1kvg.annovar_input.hg38_vcf_dropped > "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.CLASS_DP.txt
#awk '{ if ($0 ~ /CLASS=DFP;/) print }' "${Current_folder}"/1kvg.annovar_input.hg38_vcf_dropped > "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.CLASS_DFP.txt
#awk '{ if ($0 ~ /CLASS=FP;/) print }' "${Current_folder}"/1kvg.annovar_input.hg38_vcf_dropped > "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.CLASS_FP.txt
#awk '{ if ($0 ~ /CLASS=DM\?;/) print }' "${Current_folder}"/1kvg.annovar_input.hg38_vcf_dropped > "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.CLASS_DM_?.txt
#awk '{ if ($0 ~ /CLASS=R;/) print }' "${Current_folder}"/1kvg.annovar_input.hg38_vcf_dropped > "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.CLASS_R.txt

#awk '{ if ($0 ~ /CLASS=DM;/) print }' "${Current_folder}"/1kvg.annovar_input.hg38_vcf_dropped > "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.CLASS_DM.txt
#awk '{ if ($0 ~ /AC=1;/) print }' "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.CLASS_DM.txt > "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.CLASS_DM.AC_1.txt
#awk '{ if ($0 ~ /AC=2;/) print }' "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.CLASS_DM.txt > "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.CLASS_DM.AC_2.txt
#awk '{ if ($0 ~ /AC=3;/) print }' "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.CLASS_DM.txt > "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.CLASS_DM.AC_3.txt
#awk '{ if ($0 !~ /AC=3;/ && $0 !~ /AC=1;/ && $0 !~ /AC=2;/) print }' "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.CLASS_DM.txt > "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.CLASS_DM.AC_over3.txt
#wc -l "${Current_folder}"/Classify_HGMD/1kvg.annovar_input.CLASS*

###--- filter CLINVAR
#awk '{ if ($0 ~ /AC=1;/) print }' "${Current_folder}"/1kvg.annovar_input.hg38_clinvar_20220320_dropped > "${Current_folder}"/Classify_Clinvar/1kvg.annovar_input.clinvar.AC_1.txt
#awk '{ if ($0 ~ /AC=2;/) print }' "${Current_folder}"/1kvg.annovar_input.hg38_clinvar_20220320_dropped > "${Current_folder}"/Classify_Clinvar/1kvg.annovar_input.clinvar.AC_2.txt
#awk '{ if ($0 ~ /AC=3;/) print }' "${Current_folder}"/1kvg.annovar_input.hg38_clinvar_20220320_dropped > "${Current_folder}"/Classify_Clinvar/1kvg.annovar_input.clinvar.AC_3.txt
#awk '{ if ($0 !~ /AC=3;/ && $0 !~ /AC=1;/ && $0 !~ /AC=2;/ ) print }' "${Current_folder}"/1kvg.annovar_input.hg38_clinvar_20220320_dropped > "${Current_folder}"/Classify_Clinvar/1kvg.annovar_input.clinvar.AC_over3.txt

#awk '{ if ($0 ~ /AC=1;/) print }' "${Current_folder}"/Classify_Clinvar/1kvg.annovar_input.hg38_clinvar_20220320_BENIGN.txt >"${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.BENIGN.AC_1.txt
#awk '{ if ($0 ~ /AC=2;/) print }' "${Current_folder}"/Classify_Clinvar/1kvg.annovar_input.hg38_clinvar_20220320_BENIGN.txt >"${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.BENIGN.AC_2.txt
#awk '{ if ($0 ~ /AC=3;/) print }' "${Current_folder}"/Classify_Clinvar/1kvg.annovar_input.hg38_clinvar_20220320_BENIGN.txt >"${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.BENIGN.AC_3.txt
#awk '{ if ($0 !~ /AC=3;/ && $0 !~ /AC=1;/ && $0 !~ /AC=2;/) print }'  "${Current_folder}"/Classify_Clinvar/1kvg.annovar_input.hg38_clinvar_20220320_BENIGN.txt >"${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.BENIGN.AC_over3.txt

#awk '{ if ($0 ~ /AC=1;/) print }' "${Current_folder}"/Classify_Clinvar/1kvg.annovar_input.hg38_clinvar_20220320_NOT_BENIGN.txt >"${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_1.txt
#awk '{ if ($0 ~ /AC=2;/) print }' "${Current_folder}"/Classify_Clinvar/1kvg.annovar_input.hg38_clinvar_20220320_NOT_BENIGN.txt >"${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_2.txt
#awk '{ if ($0 ~ /AC=3;/) print }' "${Current_folder}"/Classify_Clinvar/1kvg.annovar_input.hg38_clinvar_20220320_NOT_BENIGN.txt >"${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_3.txt
#awk '{ if ($0 !~ /AC=3;/ && $0 !~ /AC=1;/ && $0 !~ /AC=2;/) print }'  "${Current_folder}"/Classify_Clinvar/1kvg.annovar_input.hg38_clinvar_20220320_NOT_BENIGN.txt >"${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.txt

#awk '{ if ($0 ~ /Uncertain_significance/) print }' "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.txt > "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.VUS.txt

#awk '{ if ($0 ~ /Conflict/) print }' "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.txt > "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.Conflict.txt

#awk '{ if ($0 !~ /Uncertain_significance/ && $0 !~ /Conflict/) print }' "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.txt > "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.NOT-conflict-VUS.txt

#ls -lah "${Current_folder}"/Classify_Clinvar/*
#wc -l "${Current_folder}"/Classify_Clinvar/*

awk '{ if ($0 ~ /drug_response/) print }' "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.NOT-conflict-VUS.txt > "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.NOT-conflict-VUS.drug_response.txt
awk '{ if ($0 ~ /Pathogenic/) print }' "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.NOT-conflict-VUS.txt > "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.NOT-conflict-VUS.pathogenic.txt
awk '{ if ($0 ~ /Likely_pathogenic/) print }' "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.NOT-conflict-VUS.txt > "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.NOT-conflict-VUS.likely_pathogenic.txt
awk '{ if ($0 ~ /association/) print }' "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.NOT-conflict-VUS.txt > "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.NOT-conflict-VUS.association.txt
awk '{ if ($0 ~ /not_provided/) print }' "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.NOT-conflict-VUS.txt > "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.NOT-conflict-VUS.not_provided.txt

awk '{ if ($0 ~ /risk_factor/) print }' "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.NOT-conflict-VUS.txt > "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.NOT-conflict-VUS.risk_factor.txt

awk '{ if ($0 !~ /drug_response/ && $0 !~ /Pathogenic/ && $0 !~ /Likely_pathogenic/ && $0 !~ /association/ && $0 !~ /not_provided/ && $0 ~ /risk_factor/ ) print }' "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.NOT-conflict-VUS.txt > "${Current_folder}"/Classify_Clinvar/1KVG_Clinvar.NOT_BENIGN.AC_over3.NOT-conflict-VUS.Other.txt