#!/bin/bash

ROOT_DIR=$workdir
OUTPUT_FILE="xtea_summary.csv"
TEMP_FILE="xtea_raw_output.tmp"

process_sample() {
    sample_path=$1
    ROOT_DIR=$workdir
    
    if [ -d "$sample_path" ]; then
        sample=$(basename "$sample_path")

        count_variants() {
            local type=$1
            local vcf_path="$ROOT_DIR/$sample/$type"
            local vcf_file=$(find "$vcf_path" -maxdepth 1 -name "*.vcf" 2>/dev/null | head -n 1)

            if [[ -n "$vcf_file" && -f "$vcf_file" ]]; then
                bcftools query -f '%POS\n' "$vcf_file" | wc -l
            else
                echo 0
            fi
        }

        # Count types
        num_alu=$(count_variants "Alu")
        num_line1=$(count_variants "L1") 
        num_sva=$(count_variants "SVA")

        echo "$sample,$num_alu,$num_line1,$num_sva"
    fi
}

export -f process_sample

echo "Starting parallel processing..."

find "$ROOT_DIR" -maxdepth 1 -mindepth 1 -type d | \
parallel -j 10 --bar process_sample > "$TEMP_FILE"

echo "Generating final CSV..."

echo "STT,Sample,Number of Alu,Number of Line1,Number of SVA" > "$OUTPUT_FILE"

awk '{print FNR "," $0}' "$TEMP_FILE" >> "$OUTPUT_FILE"

rm "$TEMP_FILE"

echo "Done! Results saved to $OUTPUT_FILE"
