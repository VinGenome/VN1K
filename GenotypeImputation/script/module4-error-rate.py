#%%
import os
import pandas as pd
import numpy as np
import allel
import subprocess
from sklearn.metrics import accuracy_score

#%%
# df = pd.read_csv("")

# %%
# path_hgdp_list = '/media/vinhdc/DATA/NAS/1KVG_imputation_panel/hgdp_list'
# path_impute = '/media/vinhdc/DATA/NAS/1KVG_imputation_panel/Impute_hgdp/impute'
# path_ground_truth = '/media/vinhdc/DATA/NAS/1KVG_imputation_panel/HGDP/hgdp_wgs.chr20.vcf.gz'
# for file_impute in os.listdir(path_impute):
#     for population in os.listdir(path_hgdp_list):
#         with open(os.path.join(path_hgdp_list, population), 'r') as fp:
#             sample = fp.read().rstrip().split()
#             print(path_ground_truth, file_impute)
#             gt = allel.read_vcf(path_ground_truth, samples=sample)
#             sample = gt['samples']
#             callset = allel.read_vcf(os.path.join(path_impute,file_impute), samples=sample)
#             # df = callset[np.isin(callset['samples'], sample)]
#             break
#     break
# print(sample)
# # %%

# %%
path_hgdp_list = '/media/vinhdc/DATA/NAS/1KVG_imputation_panel/AMPRA_list'
path_impute = '/media/vinhdc/DATA/NAS/1KVG_imputation_panel/Impute_APMRA/impute'
path_ground_truth = '/media/vinhdc/DATA/NAS/1KVG_imputation_panel/Reference_Tmp/VN_1011.HaplotypeData.chr20.vcf.gz'
dict_acc = {'Population':[]}
for file_impute in os.listdir(path_impute):
    dict_acc[file_impute] = []
for population in os.listdir(path_hgdp_list):
    for file_impute in os.listdir(path_impute):
        print(population)
        population_name = population.split("_")[0]
        with open(os.path.join(path_hgdp_list, population), 'r') as fp:
            sample = fp.read().rstrip().split()
        cmd_sample_gt = ['bcftools', 'query', '-l', path_ground_truth]
        sample_gt = subprocess.run(cmd_sample_gt, stdout=subprocess.PIPE).stdout.decode('utf-8').rstrip().split()
        sample = [i for i in sample if i in sample_gt]
        print(len(sample))
        cmd_genotype_gt = ['bcftools', 'query', '-f "%CHROM:%POS:%REF:%ALT[\\t%GT]\\n"', f'-s{",".join(sample)}', path_ground_truth, '>', 'df_gt_1.csv']
        os.system(' '.join(cmd_genotype_gt))
        cmd_gt = ['bcftools', 'query', '-f "%CHROM:%POS:%REF:%ALT[\\t%GT]\\n"', f'-S /media/vinhdc/DATA/NAS/1KVG_imputation_panel/sample_impute.txt', os.path.join(path_impute, file_impute), '>', 'df_impute.csv']
        print(' '.join(cmd_gt))
        os.system(' '.join(cmd_gt))
        df_ref = pd.read_csv('df_gt_1.csv', sep='\t', header=None)
        df_impute = pd.read_csv('df_impute.csv', sep='\t', header=None)
        id = pd.merge(df_impute,df_ref, how='inner', on=0)[0]
        df_ref = df_ref[df_ref[0].isin(id)]
        df_impute = df_impute[df_impute[0].isin(id)]
        
        df_ref = df_ref.replace(['0/0'],0).replace(['0|0'],0)
        df_ref = df_ref.replace(['./.'],0).replace(['.|.'],0)
        df_ref = df_ref.replace(['1/0'],1).replace(['1|0'],1)
        df_ref = df_ref.replace(['0/1'],1).replace(['0|1'],1)
        df_ref = df_ref.replace(['1/1'],2).replace(['1|1'],2)

        df_impute = df_impute.replace(['0|0'],0)
        df_impute = df_impute.replace(['1|0'],1)
        df_impute = df_impute.replace(['0|1'],1)
        df_impute = df_impute.replace(['1|1'],2)

        y_pred = df_impute.iloc[:, 1:].to_numpy()
        y_label = df_ref.iloc[:, 1:].to_numpy()
        acc = []  
        def Average(lst):
            return sum(lst) / len(lst)

        for i in range(y_pred.shape[1]):
            acc.append(accuracy_score(y_label[:, i], y_pred[:, i]))
        dict_acc[file_impute].append(Average(acc))
        print(dict_acc)
    dict_acc['Population'].append(population_name)
print(dict_acc)

# %%
pd.DataFrame(dict_acc).to_csv('/media/vinhdc/DATA/NAS/1KVG_imputation_panel/dict_acc/apmra94.csv')
# df = pd.read_csv('/media/vinhdc/DATA/NAS/1KVG_imputation_panel/HGDP_1KGP3.chr20.csv', sep='\t')
# %%
# df_gt = pd.read_csv('/media/vinhdc/DATA/NAS/1KVG_imputation_panel/HGDP/HGDP_ref.chr20.csv', sep='\t')
# %%
