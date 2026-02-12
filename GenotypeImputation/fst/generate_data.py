import os
import pandas as pd

all_fst = list()
for file in os.listdir("output_vcftools"):
    if file.endswith("fst_mean"):
        with open(os.path.join("output_vcftools", file), "r") as reader:
            lines = reader.readlines()
            mean = float(lines[0].split(": ")[-1])
            weighted = float(lines[1].split(": ")[-1])
        setname = file.replace(".fst_mean", "").replace("GSA_", "")
        all_fst.append([setname, mean, weighted])

df = pd.DataFrame(all_fst, columns = ["setname", "mean", "weighted"])
df.to_csv("all_fst.csv", sep="\t", index=False)