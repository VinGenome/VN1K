# Genotype Imputation Project

## Overview
This project focuses on genotype imputation, a crucial step in genetic analysis that involves predicting missing genotypes in a dataset based on known genotypes. The goal is to enhance the quality and completeness of genetic data for further analysis.

## Directory Structure
- **fst/**: Contains scripts related to FST calculations and data generation.
  - `fst_plot.R`: R script for plotting FST results.
  - `generate_data.py`: Python script for generating synthetic genotype data.
  - `run.sh`: Shell script to execute the FST analysis.

- **script/**: Contains various scripts for genotype imputation and analysis.
  - `convert_sample.py`: Python script for converting sample formats.
  - `hla_impute_acc_plot.R`: R script for plotting accuracy of HLA imputation.
  - `module1-prep-hgdp.sh`: Shell script for preparing HGDP data.
  - `module1-prep-ref.sh`: Shell script for preparing reference data.
  - `module2-merge.sh`: Shell script for merging datasets.
  - `module3-impute-hgdp-parallel.sh`: Shell script for parallel imputation of HGDP data.
  - `module3-impute-hgdp.sh`: Shell script for imputation of HGDP data.
  - `module3-impute.sh`: Shell script for general imputation.
  - `module3-run-impute-parallel.sh`: Shell script to run imputation in parallel.
  - `module4-error-rate-plot-final.R`: R script for plotting error rates.
  - `module4-error-rate-plot-final2.R`: Another R script for error rate plotting.
  - `module4-error-rate.py`: Python script for calculating error rates.
  - `module5_fst.sh`: Shell script for FST analysis.
  - **plot/**: Contains plotting functions and scripts.
    - `function.convert_gt_matrix.R`: Function to convert genotype matrices.
    - `function.plot_accuracy.R`: Function to plot accuracy results.
    - `function.plot_error_rate.R`: Function to plot error rates.
    - `function.plot_hqvariants.R`: Function to plot high-quality variants.
    - `function.test_accuracy.R`: Function to test accuracy of imputation.
    - `module1-plot-accuracy-changepath.R`: R script for plotting accuracy with changed paths.
    - `module1-plot-accuracy-final.R`: Final R script for accuracy plotting.
    - `module2-plot-hgdp-error-rate.R`: R script for plotting HGDP error rates.

## Installation
To set up the project, clone the repository and install the required dependencies:

```bash
# Clone the repository
git clone <repository-url>

# Navigate to the project directory
cd VN1K

# Install dependencies (if applicable)
# e.g., pip install -r requirements.txt or Rscript -e "install.packages('package_name')"
```

## Usage
To run the analysis, execute the relevant scripts in the `fst/` or `script/` directories. For example:

```bash
# Run the FST analysis
bash fst/run.sh

# Run genotype imputation
bash script/module3-impute.sh
```

## Contributing
Contributions are welcome! Please submit a pull request or open an issue for discussion.

## License
This project is licensed under the MIT License. See the LICENSE file for details.

## Acknowledgments
- Acknowledge any collaborators, libraries, or datasets used in the project.

---

Feel free to modify this README to better fit your project's specifics!  

