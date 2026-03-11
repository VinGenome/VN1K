run_xtea(){
	file=$1
	sampleName=`echo $file | awk -F'/' '{print $4}'`
	echo $sampleName
	type=`echo $file | awk -F'/' '{print $5}'`
	workdir=$path
	echo $type
	echo `cat mapping.txt | grep $sampleName | awk -F' ' '{print $2}'` illumina > $workdir/$sampleName/$type/bam_list.txt
	echo "docker run --rm -v $workdir:/home/ -v $data:/data -it xtea:v1 /bin/bash $1"
	docker run --rm -v $workdir:/home/ -v data:/data  xtea:v1 /bin/bash $1
}

export -f run_xtea

parallel -j64 run_xtea ::: `cat 35_sample.txt`
