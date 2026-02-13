#code location: /dragennfs/area15/Population/cmp_array/APMDA

#Directory
APT_app="/dragennfs/area9/analysis/trang_public_data/APMDA/apt_2.11.4_linux_64_bit_x86_binaries/bin/"
Axiom_analysisDir="/dragennfs/area9/analysis/trang_public_data/APMDA/r7/PMDA/"

#FOR BATCH 1 vs 2
batch_number="$1"
CEL_dir="/dragennfs/area9/analysis/trang_public_data/APMDA/T2D_raw/X401SC21110572-Z01-F00""$batch_number""/"
Output_QC_BP="/dragennfs/area15/Population/cmp_array/APMRA/Batch"$batch_number"/QC/"
Output_BP="/dragennfs/area15/Population/cmp_array/APMRA/Batch"$batch_number"/Output/"

Output_QC_BP="/dragennfs/area9/analysis/trang_public_data/APMDA/T2D_analysis/Batch"$batch_number"/QC/"
Output_BP="/dragennfs/area9/analysis/trang_public_data/APMDA/T2D_analysis/Batch"$batch_number"/Output/"
Output_VCF="/dragennfs/area9/analysis/trang_public_data/APMDA/T2D_analysis/Output_vcf_recommend/"

#FOR BATCH 2 vs 3
batch_number="$1"
plate=$2
CEL_dir="/dragennfs/area9/analysis/trang_public_data/APMDA/T2D_raw/X401SC21110572-Z01-F00""$batch_number""/plate ""$plate""/"
#Output_QC_BP="/dragennfs/area15/Population/cmp_array/APMDA/Batch"$batch_number"/QC/"
#Output_BP="/dragennfs/area15/Population/cmp_array/APMDA/Batch"$batch_number"/Output/"

Output_QC_BP="/dragennfs/area9/analysis/trang_public_data/APMDA/T2D_analysis/Batch"$batch_number"/QC/plate""$plate""/"
Output_BP="/dragennfs/area9/analysis/trang_public_data/APMDA/T2D_analysis/Batch"$batch_number"/Output/plate""$plate""/"

[ ! -d "$Output_QC_BP" ] && mkdir -p "$Output_QC_BP"
[ ! -d "$Output_BP" ] && mkdir -p "$Output_BP"
[ ! -d "$Output_BP"summary ] && mkdir -p "$Output_BP"summary
[ ! -d "$Output_BP"step2 ] && mkdir -p "$Output_BP"step2
[ ! -d "$Output_BP"cn ] && mkdir -p "$Output_BP"cn
[ ! -d "$Output_BP"SNPolisher ] && mkdir -p "$Output_BP"SNPolisher
[ ! -d "$Output_BP"analysis_step1 ] && mkdir -p "$Output_BP"analysis_step1

#----------- Axiom Best Practice -------------
#Step1: group samples into batches
echo "Step 1: group samples into batches"
#(echo "cel_files"; \ls -1 "$CEL_dir"*.CEL) > "$Output_BP"list_celB"$batch_number".txt

#Step 2: Generate the sample DQC
echo "Step 2: Dish QC...."
#"$APT_app"apt-geno-qc --analysis-files-path "$Axiom_analysisDir" --xml-file "$Axiom_analysisDir"Axiom_PMDA.r7.apt-geno-qc.AxiomQC1.xml --cel-files "$Output_BP"list_celB"$batch_number".txt --out-file "$Output_QC_BP"apt-geno-qc.txt --log-file "$Output_QC_BP"apt-geno-qc.log

#Step 3: Remove samples with Dish qc DQC value less than default threshold of 0.82
echo "Step 3: Scan if Cel files has DQC less than 0.82"
#awk '{ if ($18<0.82 && $1 !~ /^#/) print $1}' "$Output_QC_BP"apt-geno-qc.txt>"$Output_QC_BP"list_fail_DQC.txt
#a=$(wc -l "$Output_QC_BP"list_fail_DQC.txt)
#echo "The number of samples failed DQC: "$a
#[[ $(wc -l "$Output_QC_BP"list_fail_DQC.txt)>0 ]] && awk 'FNR==NR {a[$0];next} { n=split($0,b,"/"); if (!(b[n] in a)) { print $0 }  }' "$Output_QC_BP"list_fail_DQC.txt "$Output_BP"list_celB"$batch_number".txt > "$Output_BP"list_celB"$batch_number".filterDQC.txt
#[[ $(wc -l "$Output_QC_BP"list_fail_DQC.txt)==0 ]] && cp "$Output_BP"list_celB"$batch_number".txt "$Output_BP"list_celB"$batch_number".filterDQC.txt 

a=$(wc -l "$Output_BP"list_celB"$batch_number".filterDQC.txt)
echo "The total number of samples after removing DQC failure: "$a

#Step 4: Generate sample QC call rates
#"$APT_app"apt-genotype-axiom --log-file "$Output_QC_BP"apt-genotype-axiom.log --arg-file "$Axiom_analysisDir"Axiom_PMDA_96orMore_Step1.r7.apt-genotype-axiom.SnpSpecificPriors.AxiomGT1.apt2.xml --analysis-files-path "$Axiom_analysisDir" --out-dir "$Output_BP"analysis_step1 --dual-channel-normalization true --cel-files "$Output_BP"list_celB"$batch_number".filterDQC.txt

#Step 5: Remove samples with a QC call rate less than 97% - default threshold
echo "Step 5: Remove samples with QC call rate less than 97%"
awk '{ if ($3<97 && $0 !~ /^#/) print $1}' "$Output_BP"analysis_step1/AxiomGT1.report.txt>"$Output_QC_BP"list_fail_CR.txt
a=$(wc -l "$Output_QC_BP"list_fail_CR.txt)
echo "The number of samples failed CR: "$a
#[[ $(wc -l "$Output_QC_BP"list_fail_CR.txt)>0 ]] && awk 'FNR==NR {a[$0];next} { n=split($0,b,"/"); if (!(b[n] in a)) { print $0 }  }' "$Output_QC_BP"list_fail_CR.txt "$Output_BP"list_celB"$batch_number".filterDQC.txt>"$Output_BP"list_celB"$batch_number".filterCR_DQC.txt
#[[ $(wc -l "$Output_QC_BP"list_fail_CR.txt)==0 ]] && cp "$Output_BP"list_celB"$batch_number".txt "$Output_BP"list_celB"$batch_number".filterCR_DQC.txt


#Step 6: QC the plates
#Note: Plates with average QC call rate <98.5% are of low quality andcan result in lower genotyping performance of samples on plates with high average QC call rates. Samples on such plates should be removed from the final genotyping run and considered for reprocessing.

#Step 7: Genotyping passing samples and plates

#7a. Summary intensity signals for arrays with copy number-aware genotyping (CNAG)
"$APT_app"apt-genotype-axiom --analysis-files-path "$Axiom_analysisDir" --arg-file "$Axiom_analysisDir"Axiom_PMDA.r7.apt-genotype-axiom.AxiomCN_PS1.apt2.xml --cel-files "$Output_BP"list_celB"$batch_number".filterCR_DQC.txt --out-dir "$Output_BP"summary --log-file "$Output_BP"summary/apt2-axiom.log
#7b. Run copy number analysis - check if sample passes both mapd-max and waviness-sd-max 
"$APT_app"apt-copynumber-axiom-cnvmix --analysis-files-path "$Axiom_analysisDir" --arg-file "$Axiom_analysisDir"Axiom_PMDA.r7.apt-copynumber-axiom-cnvmix.AxiomCNVmix.apt2.xml --reference-file "$Axiom_analysisDir"Axiom_PMDA.r7.cn_models --mapd-max 0.35 --waviness-sd-max 0.1 --summary-file "$Output_BP"summary/AxiomGT1.summary.a5 --report-file "$Output_BP"summary/AxiomGT1.report.txt --out-dir "$Output_BP"cn --log-file "$Output_BP"cn/apt-copynumber-axiom.log
#7c. genotype calls for all SNPs and passing samples
"$APT_app"apt-genotype-axiom --log-file "$Output_BP"step2/apt-genotype-axiom.log --arg-file "$Axiom_analysisDir"Axiom_PMDA_96orMore_Step2.r7.apt-genotype-axiom.mm.SnpSpecificPriors.AxiomGT1.apt2.xml --analysis-files-path "$Axiom_analysisDir" --out-dir "$Output_BP"step2 --dual-channel-normalization true --summaries --genotyping-node:snp-posteriors-output true --batch-folder "$Output_BP"suitefiles -cel-files "$Output_BP"list_celB"$batch_number".filterCR_DQC.txt --multi-genotyping-node:multi-posteriors-output true --copynumber-probeset-calls-file "$Output_BP"cn/AxiomCNVMix.cnpscalls.txt --allele-summaries true


#Step 8A: Run ps-metrics
"$APT_app"ps-metrics --posterior-file "$Output_BP"step2/AxiomGT1.snp-posteriors.txt --call-file "$Output_BP"step2/AxiomGT1.calls.txt --metrics-file "$Output_BP"SNPolisher/metrics.txt --multi-posterior-file "$Output_BP"step2/AxiomGT1.snp-posteriors.multi.txt --multi-metrics-file "$Output_BP"SNPolisher/metrics.multi.txt --summary-file "$Output_BP"/step2/AxiomGT1.summary.txt

#Step 8B: Run ps-classification
"$APT_app"ps-classification -species-type human --metrics-file "$Output_BP"SNPolisher/metrics.txt --output-dir "$Output_BP"SNPolisher/ --ps2snp-file "$Axiom_analysisDir"Axiom_PMDA.r7.ps2multisnp_map.ps --multi-metrics-file "$Output_BP"SNPolisher/metrics.multi.txt

#Step 9: Use gtc2vcf to convert from summary file of Affymetrix best practice to VCF --> not work
bcftools +affy2vcf --csv /dragennfs/area9/analysis/trang_public_data/APMDA/r7/Axiom_PMDA.na36.r7.a8.annot.csv --no-version -t GT,CONF,BAF,LRR,NORMX,NORMY,DELTA,SIZE --fasta-ref /home/shared/references/Homo_sapiens_assembly38.fasta --calls Output/step2/AxiomGT1.calls.txt --confidences Output/step2/AxiomGT1.confidences.txt --summary Output/step2/AxiomGT1.summary.txt --snp Output/step2/AxiomGT1.snp-posteriors.txt -Ou | bcftools sort -Ou -T ./bcftools-sort.XXXXXX | bcftools norm --no-version -Oz -c x -f /home/shared/references/Homo_sapiens_assembly38.fasta -o Output/Batch1.vcf.gz

bcftools +affy2vcf --csv /dragennfs/area9/analysis/trang_public_data/APMDA/r7/Axiom_PMDA.na36.r7.a8.annot.csv --no-version -t GT,CONF --fasta-ref /home/shared/references/Homo_sapiens_assembly38.fasta --calls Output/step2/AxiomGT1.calls.txt --confidences Output/step2/AxiomGT1.confidences.txt --summary Output/step2/AxiomGT1.summary.txt --snp Output/step2/AxiomGT1.snp-posteriors.txt -Ou | bcftools sort -Ou -T ./bcftools-sort.XXXXXX | bcftools norm --no-version -Oz -c x -f /home/shared/references/Homo_sapiens_assembly38.fasta -o Output/Batch1.noMeta.vcf.gz

bcftools +affy2vcf --csv /dragennfs/area9/analysis/trang_public_data/APMDA/r7/Axiom_PMDA.na36.r7.a8.annot.csv --no-version -t GT,CONF --fasta-ref /home/shared/references/Homo_sapiens_assembly38.fasta --calls "$Output_BP"step2/plate"$plate"_AxiomGT1.calls.txt --confidences "$Output_BP"step2/plate"$plate"_AxiomGT1.confidences.txt --summary "$Output_BP"step2/plate"$plate"_AxiomGT1.summary.txt --snp "$Output_BP"step2/plate"$plate"_AxiomGT1.snp-posteriors.txt -Ou | bcftools sort -Ou -T ./bcftools-sort.XXXXXX | bcftools norm --no-version -Oz -c x -f /home/shared/references/Homo_sapiens_assembly38.fasta -o "$Output_VCF"plate""$plate"".noMeta.vcf.gz

#Step9 final: use apt-format-result
"$APT_app"apt-format-result --batch-folder "$Output_BP"suitefiles --performance-file "$Output_BP"SNPolisher/Ps.performance.txt  --annotation-file /dragennfs/area9/analysis/trang_public_data/APMDA/r7/Axiom_PMDA.na36.r7.a8.annot.db  --annotation-columns 'Alt_Allele' --export-confidence true --export-allele-signals true --export-chr-shortname true --export-call-format 'translated'  --export-vcf-file  "$Output_VCF"plate"$i".vcf

"$APT_app"apt-format-result --batch-folder "$Output_BP"suitefiles  --cn-region-calls-file "$Output_BP"cn/AxiomCNVMix.cnregioncalls.txt --snp-list-file "$Output_BP"SNPolisher/Recommended.ps --annotation-file /dragennfs/area9/analysis/trang_public_data/APMDA/r7/Axiom_PMDA.na36.r7.a8.annot.db --export-confidence true --export-allele-signals true --export-chr-shortname false --export-vcf-file  "$Output_VCF"plate"$i"_recommend.vcf --log-file "$Output_VCF"plate"$i"_recommend.log

awk '{ if ($0 ~ /^#/) print $0; else if ($0 !~ /^</) print "chr"$0 }' "$Output_VCF"plate"$i".vcf |bgzip -c>"$Output_VCF"plate"$i".vcf.gz
tabix -p vcf "$Output_VCF"plate"$i".vcf.gz
bcftools annotate "$Output_VCF"plate"$i".vcf.gz --rename-chrs chrM.txt -Oz -o "$Output_VCF"plate"$i".fix.vcf.gz
tabix -p vcf "$Output_VCF"plate"$i".fix.vcf.gz

bcftools sort "$Output_VCF"plate"$i".fix.vcf.gz -Ou -T ./bcftools-sort.XXXXXX | bcftools norm --no-version -Oz -c x -f /home/shared/references/Homo_sapiens_assembly38.fasta -o "$Output_VCF"plate"$i".norm.sort.vcf.gz -Oz
tabix -p vcf "$Output_VCF"plate"$i".norm.sort.vcf.gz

#CHECK PROBESET
cd /dragennfs/area15/Population/cmp_array/APMDA

#all probeset
awk '{ if ($0 !~ /^#/) print $1}' APMDA_sites.txt>list_probeSet.txt

#count #probeset after step 2
awk '{ if ($1 !~ /\:/ && $0 !~ /^#/) print $1 }' Output/step2/AxiomGT1.snp-posteriors.txt | sort >list_biallelic.txt
awk '{ if ($3 == 4) print $1 }' Output/step2/AxiomGT1.snp-posteriors.multi.txt | sort | uniq>list_multi4.txt
awk '{ if ($3 == 3) print $1 }' Output/step2/AxiomGT1.snp-posteriors.multi.txt | sort | uniq>list_multi3.txt

cat list_biallelic.txt list_multi3.txt list_multi4.txt | sort>list_allProbeset_fromstep2.txt

#list exclude by step 2 Affymetrix analysis a.txt
comm list_allProbeset_fromstep2.txt list_probeSet.txt -13>a.txt
comm list_allProbeset_fromstep2.txt list_probeSet.txt -23>b.txt

#COUNT SITES
awk '{ print $2"_"$3"_"$4"_"$5 }' APMDA_sitesOnly.txt >sites.txt
sort sites.txt >sites.sort.txt
uniq sites.sort.txt >sites.uniq.sort.txt
uniq -d sites.sort.txt >list_repeatSNP.txt

#COUNT AFFYMETRIX_ID
awk '{ print $2 }' APMDA_sites.txt | sort | uniq | wc -l

#COUNT CNV PROBESET
awk '{ if ($0 !~ /^#/) print $1 }' Output/cn/AxiomCNVMix.cnpscalls.txt >list_probesetCNV.txt
comm list_allProbeset_fromstep2.txt list_probesetCNV.txt -13 >c.txt


#Check #clusters generated by multiallelic
awk '{ if ($3 == 3) print $1 }' Output/step2/AxiomGT1.snp-posteriors.multi.txt | uniq | wc -l
awk '{ if ($3 == 4) print $1 }' Output/step2/AxiomGT1.snp-posteriors.multi.txt | uniq | wc -l

#repeat cluster
awk '{ if ($1 ~/\:/ && $0 !~ /^#/) print $1 }' Output/step2/AxiomGT1.snp-posteriors.txt | less

bash /Users/hatrang/Work/pipeline/helpful_scripts/combine_file.sh /Users/hatrang/Work/T2D/Batch4/QC AxiomGT1.report

## convert a5 file to txt file
cd /dragennfs/area9/analysis/trang_public_data/
/dragennfs/area9/analysis/trang_public_data/APMDA/apt_2.11.4_linux_64_bit_x86_binaries/bin/apt2-summary-file-util --a5 APMDA/T2D_analysis/Batch1/Output/summary/AxiomGT1.summary.a5 --a5totxt true --txt APMDA/T2D_analysis/Batch1/Output/summary/AxiomGT1.sum.txt

awk '{ if ($0 ~ /AX-1108758/) print }' ../../APMDA/T2D_analysis/Batch1/Output/summary/AxiomGT1.sum.txt > AX-1108758.txt

grep -rnw ../../APMDA/T2D_analysis/Batch1/Output/step2/ -e 'AX-15354544'






