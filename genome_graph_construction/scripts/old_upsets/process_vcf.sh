# read the vcf_list.txt contain column: sample_name, method, vcf_path
# for each vcf file, rename sample to sample_method
# write bashscript to process all vcfs


#!/bin/bash 

vcf_list="/home/giangvm1/bit_bucket/pangenom/pipeline/old_code/genome_graph_mc_pipeline/scripts/old_upsets/vcf_list.txt"
output_dir="/home/giangvm1/bit_bucket/pangenom/pipeline/old_code/genome_graph_mc_pipeline/scripts/old_upsets/processed_vcfs/"
mkdir -p ${output_dir}

while IFS=',' read -r vcf_path method sample_name; do
    vcf_path=$(echo "$vcf_path" | xargs)
    method=$(echo "$method" | xargs)
    sample_name=$(echo "$sample_name" | xargs)
    
    output_vcf="${output_dir}/${sample_name}_${method}.vcf.gz"
    echo "Processing: $vcf_path -> $output_vcf"
    
    # Get old sample name
    old_name=$(bcftools query -l ${vcf_path} 2>/dev/null | head -1)
    
    if [ -z "$old_name" ]; then
        echo "  Warning: Could not read VCF file, skipping: $vcf_path"
        continue
    fi
    
    new_name="${sample_name}_${method}"
    echo "  Renaming: $old_name -> $new_name"
    
    # Create rename file
    echo "${old_name} ${new_name}" > rename_samples.txt
    
    # Decompress, reheader, and re-compress to avoid segmentation faults
    bcftools view -c 1 ${vcf_path} | \
    bcftools reheader -s rename_samples.txt | \
    bcftools filter -i '(SVTYPE=="DEL" || SVTYPE=="INS") & ABS(SVLEN) >=50' | \
    bcftools view -o ${output_vcf/.vcf.gz/.vcf}
    
    # Index the output
    # tabix -p vcf ${output_vcf}
    
    echo "  Done: $output_vcf"
    
done < ${vcf_list}

rm -f rename_samples.txt
echo "All VCF files processed successfully!"
