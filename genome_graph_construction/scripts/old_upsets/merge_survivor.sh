SURVIVOR merge HG02080.list_4_survivor.txt 500 1 1 1 0 50 HG02080_merged.vcf

bcftools query -l HG02080_merged.vcf |tr '\n' '\t'| sed 's/\t$/\n/' > HG02080_merged.header.txt
echo -e "CHROM\tPOS\tSUPP\tSUPP_VEC\tSVTYPE\tSVLEN\t$(cat HG02080_merged.header.txt)" > HG02080_merged.final_header.txt
bcftools sort HG02080_merged.vcf -o HG02080_merged.sorted.vcf
bcftools query -f'%CHROM\t%POS\t%SUPP\t%SUPP_VEC\t%SVTYPE\t%SVLEN[\t%GT]\n' HG02080_merged.sorted.vcf >> HG02080_merged.final_header.txt

SURVIVOR merge HG02059.list_4_survivor.txt 500 1 1 1 0 50 HG02059_merged.vcf
bcftools query -l HG02059_merged.vcf |tr '\n' '\t'| sed 's/\t$/\n/' > HG02059_merged.header.txt
echo -e "CHROM\tPOS\tSUPP\tSUPP_VEC\tSVTYPE\tSVLEN\t$(cat HG02059_merged.header.txt)" > HG02059_merged.final_header.txt
bcftools sort HG02059_merged.vcf -o HG02059_merged.sorted.vcf
bcftools query -f'%CHROM\t%POS\t%SUPP\t%SUPP_VEC\t%SVTYPE\t%SVLEN[\t%GT]\n' HG02059_merged.sorted.vcf >> HG02059_merged.final_header.txt