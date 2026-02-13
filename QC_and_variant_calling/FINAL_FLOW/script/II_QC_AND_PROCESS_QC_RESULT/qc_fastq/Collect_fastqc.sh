echo "Process QC Before"

# Step 1: Run file printQCinfoLane1.sh to generate output.txt collect required information
bash qc_fastq/printQCinfoBefore.sh "$@"

# Step 2: Run file processQCoutputLane.sh to process output.txt to columns filling to the report
bash qc_fastq/processQCBefore.sh "$@"

echo "Process QC After"
#Step 3: Run file printQCinfo2.sh to generate output.txt collecting raw information
bash qc_fastq/printQCinfoAfter.sh "$@"

#Step 4: Run file processQCoutput.sh to process generated output.txt to columns filling to the report
bash qc_fastq/processQCAfter.sh "$@"


