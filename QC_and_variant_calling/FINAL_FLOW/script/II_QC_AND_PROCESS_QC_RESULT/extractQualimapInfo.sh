#!/bin/
rm output.txt
touch output.txt
while read sample Sample_root
do
	echo $sample >> output.txt
	reads=""
        aligned_reads=""
        mapped_reads=""
        supplementary_reads=""
        paired_reads=""
        duplicated_reads=""

        aligned_bases=""
        mapped_bases=""
	head -n 200 "${Sample_root}""${sample}"/qualimap_"${sample}"/genome_results.txt | awk -F'=' '{
		if ($1 ~ /number of reads/) {
			reads=$2
		}

		if ($1 ~ /number of mapped reads/) {
			split($2,arr," ")
			aligned_reads=arr[1]
		}


		if ($1 ~ /number of mapped paired reads (both in pair)/) {
			paired_reads=$2
		}


		if ($1 ~ /number of duplicated reads/) {
			duplicated_reads=$2
		}

		if ($1 ~ /number of supplementary alignments/) {
			supplementary_reads=$2
		}

		mapped_reads=aligned_reads - duplicated_reads - supplementary_reads

		if ($1 ~ /number of mapped bases/) {
			aligned_bases=$2
		}

		if ($1 ~ /number of sequenced bases/) {
			mapped_bases=$2
		}
		if (NR==200){
			print "reads:"reads
			print "aligned_reads:"aligned_reads
			print "supplementary_reads:"supplementary_reads
			print "duplicated_reads:"duplicated_reads
			print "aligned_bases:"aligned_bases
			print "mapped_bases:"mapped_bases
		}

	}'>>output.txt

	head -n 200 "${Sample_root}""${sample}"/qualimap_"${sample}"/genome_results.txt | awk '{
		if ($1 == "chr22") {
			print "chr22:"$4
		}


		if ($1 == "chrX") {
			print "chrX:"$4
		}


		if ($1 == "chrY") {
			print "chrY:"$4
		} 
	}'>>output.txt

done<"$1"
