
#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 2
#SBATCH --mem=200GB
#SBATCH -o out_%A_%a.txt
#SBATCH -e error_%A_%a.txt
#SBATCH --job-name=download_hifi
#SBATCH --time=10:00:00
#SBATCH --partition=general
#SBATCH --account=<account_name>
#SBATCH --array=0-8

# Configuration: Use environment variable or default to relative path
DOWNLOAD_DIR=${VN1K_DOWNLOAD_DIR:-"./data/HG01596"}

# Create the directory if it does not exist
mkdir -p "$DOWNLOAD_DIR"


# HG02018 - ONT
# samples=(
#   'https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20230501_HGSVC_UL_ONT-UW/HG02018/20221025_HG02018_UL_eee-prom1-1D-PAM78083_guppy-5.0.11-sup-prom_fastq_pass.fastq.gz'
#   'https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20230501_HGSVC_UL_ONT-UW/HG02018/20221101_HG02018_UL_eee-prom1-1G-PAM79302_guppy-5.0.11-sup-prom_fastq_pass.fastq.gz'
#   'https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20230501_HGSVC_UL_ONT-UW/HG02018/20221102_HG02018_UL_eee-prom1-3H-PAM78744_guppy-5.0.11-sup-prom_fastq_pass.fastq.gz'
#   'https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20230501_HGSVC_UL_ONT-UW/HG02018/20221108_HG02018_UL_eee-prom1-3B-PAM64235_guppy-5.0.11-sup-prom_fastq_pass.fastq.gz'
#   'https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20230501_HGSVC_UL_ONT-UW/HG02018/20221130_HG02018_UL_eee-prom1-2C-PAM77931_guppy-5.0.11-sup-prom_fastq_pass.fastq.gz'
#   'https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20230501_HGSVC_UL_ONT-UW/HG02018/20221206_HG02018_UL_eee-prom1-2C-PAG68624_guppy-5.0.11-sup-prom_fastq_pass.fastq.gz'
#   'https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20230501_HGSVC_UL_ONT-UW/HG02018/20221207_HG02018_UL_eee-prom1-2C-PAG68624_guppy-5.0.11-sup-prom_fastq_pass.fastq.gz'
#   'https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20230501_HGSVC_UL_ONT-UW/HG02018/20230210_HG02018_UL_eee-prom1-3B-PAG76493_guppy-5.0.11-sup-prom_fastq_pass.fastq.gz'
# )

# List of HiFi files for HG01596
samples=(
  'https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20220831_JAX_HiFi/HG01596/m64039_220216_202046/JAX_HiFi_HG01596_m64039_220216_202046.bam'
  'https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20220831_JAX_HiFi/HG01596/m64039_220216_202046/JAX_HiFi_HG01596_m64039_220216_202046.bam.bai'
  'https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20220831_JAX_HiFi/HG01596/m64039_220216_202046/JAX_HiFi_HG01596_m64039_220216_202046.bam.pbi'
  'https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20220831_JAX_HiFi/HG01596/m64119_220209_052029/JAX_HiFi_HG01596_m64119_220209_052029.bam'
  'https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20220831_JAX_HiFi/HG01596/m64119_220209_052029/JAX_HiFi_HG01596_m64119_220209_052029.bam.bai'
  'https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20220831_JAX_HiFi/HG01596/m64119_220209_052029/JAX_HiFi_HG01596_m64119_220209_052029.bam.pbi'
  'https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20220831_JAX_HiFi/HG01596/m64119_220214_210708/JAX_HiFi_HG01596_m64119_220214_210708.bam'
  'https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20220831_JAX_HiFi/HG01596/m64119_220214_210708/JAX_HiFi_HG01596_m64119_220214_210708.bam.bai'
  'https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20220831_JAX_HiFi/HG01596/m64119_220214_210708/JAX_HiFi_HG01596_m64119_220214_210708.bam.pbi'
)

# Function to download a sample
download_file() {
    local url=$1
    echo "Downloading: $url"
    wget -c "$url" -P "$DOWNLOAD_DIR"
}

# Execute download for the current array task
sample_url=${samples[$SLURM_ARRAY_TASK_ID]}
download_file "$sample_url"
