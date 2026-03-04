import sys

SV_TYPES = ['UNK', 'BND', 'DEL', 'INS', 'INV']

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
                assert False
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
        self 