#%%
import os
import numpy as np
import pandas as pd

# %%
columns = ['QUAL', 'FILTER', 'INFO', 'dataset', 'svtype', 'svlen']


# %%
filePath = '/mnt/WD/VGP/VN_007_920_benchmark/sv_deeplearning/data/sv_vn007_list.txt'
with open(filePath, 'r') as fp:
    listFilePath = fp.read().split("\n")
# %%
df_list = []

def getProperty(x, keys):
    try:
        tmp = x.split(";")
        for i in tmp:
            if keys in i:
                return i.split("=")[-1]
    except:
        return None

def filterSVlen(x, threshold=50):
    if (x['svtype'] == 'INS') | (x['svtype'] == 'DEL'):
        return True if abs(int(x['svlen'])) >= threshold else False
    return True

def calcEnd(x):
    if (x['svtype'] == 'INS') | (x['svtype'] == 'DEL'):
        return df['start'] + df['svlen']
    else: 
        return 0


for i in listFilePath:
    fileNamePath = i
    df = pd.read_csv(fileNamePath, sep='\t', header=0, dtype=str)
    df['svtype'] = df['INFO'].map(lambda x: getProperty(x, "SVTYPE"))
    df['svlen'] = df['INFO'].map(lambda x: getProperty(x, "SVLEN"))
    df['start'] = df['POS']
    df['end'] = df[['svtype', 'start', 'svlen']].map(lambda x: calcEnd(x), axis=1)
    df = df[df.apply(lambda x: filterSVlen(x), axis=1)]
    df['dataset'] = i
    # df = df[columns]
    df_list.append(df)


# %%
df = pd.DataFrame()
df = pd.concat(df_list)
df = df[df.apply(lambda x: filterSVlen(x), axis=1)]

def intersection_sv(df_list):
    pass

def make_intersection_and_quality_control(df_list):
    df = intersection_sv(df_list)



# for i in np.diag(np.full(22,1)):
#     inter_list.append("".join(i.astype(str)))

# df_inter = df[df['inter'].isin(inter_list)]
filePath
#%%




# %%
SV_TYPES = ['UNK', 'BND', 'DEL', 'INS', 'INV']
columns = ['QUAL', 'FILTER', 'INFO', 'dataset', 'svtype', 'svlen']

def make_info_dictionary(info):
    spl_info = info.split(";")
    info_dict = {}

    for key_val in spl_info:
        if "=" in key_val:
            key, val = key_val.split("=")
            info_dict[key] = val
        else:
            info_dict[key_val] = ""

    return info_dict

def getProperty(x, keys):
    try:
        tmp = x.split(";")
        for i in tmp:
            if keys in i:
                return i.split("=")[-1]
    except:
        return None

def filterSVlen(x, threshold=50):
    if (x['svtype'] == 'INS') | (x['svtype'] == 'DEL'):
        return True if abs(int(x['svlen'])) >= threshold else False
    return True

filePath = '/mnt/WD/VGP/VN_007_920_benchmark/sv_deeplearning/data/sv_vn007_list.txt'
with open(filePath, 'r') as fp:
    listFilePath = fp.read().split("\n")
    
def get_tech_and_aligh(x):
    fileName = os.path.basename(x)
    items = fileName.split(".")

    return (items[0], items[-4])

sv_call_aligh_tech = tuple(map(get_tech_and_aligh,listFilePath))

class SV(object):
    """
    Constructs a structural variant (SV) candidate
    """
    def __init__(self, vcf_record, check_type = True):
        self.check_type = check_type
        self.chromosome = vcf_record['#CHROM']
        self.begin = vcf_record['POS']
        self.end = self.begin

        info_dict = make_info_dictionary(vcf_record['INFO'])
        
        # Join related SV types
        if "SVTYPE" in info_dict:
            if info_dict["SVTYPE"] == "DEL_ALU" or info_dict["SVTYPE"] == "DEL_LINE1":
                info_dict["SVTYPE"] = "DEL"
            elif info_dict["SVTYPE"] == "ALU" or info_dict["SVTYPE"] == "LINE1" or info_dict["SVTYPE"] == "SVA" or \
                 info_dict["SVTYPE"] == "DUP" or info_dict["SVTYPE"] == "CNV" or info_dict["SVTYPE"] == "INVDUP" or \
                 info_dict["SVTYPE"] == "INV":
                info_dict["SVTYPE"] = "INS"
            elif info_dict["SVTYPE"] == "TRA":
                info_dict["SVTYPE"] = "BND"

        if "SVTYPE" in info_dict and ((info_dict["SVTYPE"] == "DEL") or (info_dict["SVTYPE"] == "INS")):
            if "END" in info_dict:
                self.end = int(info_dict["END"])
            else:
                if "SVSIZE" in info_dict:
                    self.end = self.begin + abs(int(info_dict["SVSIZE"]))
                elif "SVLEN" in info_dict:
                    self.end = self.begin + abs(int(info_dict["SVLEN"]))

        if check_type:
            if "SVTYPE" in info_dict and info_dict["SVTYPE"] in SV_TYPES:
                self.type = SV_TYPES.index(info_dict["SVTYPE"])
            else:
                self.type = 0  # Unknown type
                
        else:
            self.type = 0

        # Get all begins and ends
        self.min_begin = self.begin
        self.max_begin = self.begin
        self.begins = [self.begin]
        self.ends = [self.end]
        self.infos = [vcf_record[7]]
        self.unique_begins_and_ends = set()
        self.unique_begins_and_ends.add((int(self.begin), int(self.end)))
        self.refs = [vcf_record[3]]
        self.alts = [vcf_record[4]]
        self.supp_vec = vcf_record['supp_vec']
        self.supp_percent = sum(list(map(int, [*vcf_record['supp_vec']])))/len([*vcf_record['supp_vec']])
        self.tech = {
            "svisionPro": 0,
            "svision": 0,
            "cuteSV": 0,
            "pbsv": 0,
            "sniffles": 0,
            "sniffles2": 0,
            "debreak": 0
        }
        self.align = {
            "minimap2": 0,
            "lra": 0,
            "winnowmap": 0,
            "ngmlr": 0
        }
        def find(s, ch):
            return [i for i, ltr in enumerate(s) if ltr == ch]
        self.index_tech = find(vcf_record['supp_vec'], "1")
        # for i in self.index_tech:
        #     tech = sv_call_aligh_tech[i]
        #     self.tech[tech[0]] += 1
        #     self.align[tech[1]] += 1




# %%
import pandas as pd
import os

filePathSURVIVOR = '/mnt/WD/VGP/VN_007_920_benchmark/SURVIVOR/Debug/vn007.vcf.gen'
df_sur = pd.read_csv(filePathSURVIVOR, sep='\t', header=0, dtype=str)
df_sur['svtype'] = df_sur['INFO'].map(lambda x: getProperty(x, "SVTYPE"))
df_sur['svlen'] = df_sur['INFO'].map(lambda x: getProperty(x, "SVLEN"))
df_sur['supp_vec'] = df_sur['INFO'].map(lambda x: getProperty(x, "SUPP_VEC"))
df_sur['cipos'] = df_sur['INFO'].map(lambda x: getProperty(x, "CIPOS"))
df_sur['ciend'] = df_sur['INFO'].map(lambda x: getProperty(x, "CIEND"))
df_sur['dataset'] = None
df_sur = df_sur[df_sur.apply(lambda x: filterSVlen(x), axis=1)]
# df_sur = df_sur[columns + ['ID', 'supp_vec', 'cipos', 'ciend', '#CHROM', 'POS']]
# df_sur = df_sur[df_sur['QUAL'] != '.']
# df_sur = df_sur[df_sur['QUAL'].astype(int) > df_sur['QUAL'].astype(int).mean()]
# %%

tech = {
    "SVision-pro": 0,
    "SVision": 0,
    "cutesv": 0,
    "pbsv": 0,
    "sniffles": 0,
    "sniffles2": 0,
    "debreak": 0
}
align = {
    "minimap2": 0,
    "lra": 0,
    "winnowmap": 0,
    "ngmlr": 0,
    "8": 0,
    'svision': 0
}
for index, row in df_sur.iterrows():
    sv = SV(row)
    for i in sv.index_tech:
        tmp = sv_call_aligh_tech[i]
        tech[tmp[0]] += 1
        align[tmp[1]] += 1


# %%
sv.infos
# %%
