# read the vcf_list.txt contain column: sample_name, method, vcf_path
# for each vcf file, rename sample to sample_method
# write bashscript to process all vcfs


#!/bin/bash 

vcf_list="/home/giangvm1/bit_bucket/pangenom/pipeline/old_code/genome_graph_mc_pipeline/scripts/old_upsets/vcf_list_ad.txt"
output_dir="/home/giangvm1/bit_bucket/pangenom/pipeline/old_code/genome_graph_mc_pipeline/scripts/old_upsets/processed_vcfs_ad/"
mkdir -p ${output_dir}

while IFS=',' read -r vcf_path method sample_name; do
    vcf_path=$(echo "$vcf_path" | xargs)
    method=$(echo "$method" | xargs)
    sample_name=$(echo "$sample_name" | xargs)
    
    output_vcf="${output_dir}/${sample_name}_${method}.ad.txt"
    echo "Processing: $vcf_path -> $output_vcf"
    vt decompose -s $vcf_path |\
        bcftools filter -i 'FILTER="PASS" & GQ>=20 & DP>10' | bcftools query -f '%CHROM\t%POS\t%REF\t%ALT[\t%DP\t%AD\t%GT]\n' | tr ',' '\t' > $output_vcf
    echo "  Done: $output_vcf"
    
done < ${vcf_list}

rm -f rename_samples.txt
echo "All VCF files processed successfully!"

mkdir -p ${output_dir}/linear_sr
mkdir -p ${output_dir}/graph_sr
mv ${output_dir}/*linear_sr* ${output_dir}/linear_sr/
mv ${output_dir}/*graph_sr* ${output_dir}/graph_sr/