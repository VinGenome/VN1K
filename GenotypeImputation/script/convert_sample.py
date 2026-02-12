import os

with open('/home/vinhdc/Bioinfomatics/project/1KVG_imputation_panel/Sample/list-apmra96.txt', 'r')  as fp:
    apmra_sample = fp.read().rstrip().split()
    apmraSample = [i.split(".")[0].zfill(4) for i in apmra_sample]
print(apmraSample)

with open("/home/vinhdc/Bioinfomatics/project/1KVG_imputation_panel/Sample/list-VN1011.txt", 'r') as fp:
    VN1011Sample = fp.read().rstrip().split()
sample = []
for i in apmraSample:
    # print(i)
    sampleTmp = [s for s in VN1011Sample if i in s]
    sample.extend(sampleTmp)
print(sample, len(sample))

with open('/home/vinhdc/Bioinfomatics/project/1KVG_imputation_panel/Sample/list-VN95.txt', 'w') as fp:
    fp.write("\n".join(sample))
# for i in apmraSample:
#     sampleTmp = [s for s in sample if i in s]
#     print(sampleTmp)
