#!/bin/bash

## Validate the pretrained model
set -e
Usage()
{
	echo "Usage:"
	echo "sh validate.sh [-t PATH_TO_AVA_TXT] [-c DIR_OF_CSV] [-d DIR_OF_IMAGES] [-b BATCH_SIZE] [-n NUM_WORKERS] [-m PATH_TO_MODEL] [-p PREPARE_DATASET]"
	echo ""
	echo "Description:"
	echo "	PATH_TO_AVA_TXT, the path to AVA .txt file"
	echo "	DIR_OF_IMAGES, the directory of images"
	echo "	DIR_OF_CSV, the directory to save .csv file"
	echo "	BATCH_SIZE, the batch size"
	echo "	NUM_WORKERS, the number of worker threads to use"
	echo "	PATH_TO_MODEL, the path to the pretrained model"
	echo "	PREPARE_DATASET, whether to prepare and split dataset"
	exit
}

PATH_TO_AVA_TXT="./DATA/AVA.txt"
DIR_OF_CSV="./DATA/"
DIR_OF_IMAGES="./DATA/images/"
PATH_TO_MODEL="./DATA/pretrain-model.pth"
BATCH_SIZE=16
NUM_WORKERS=4
PREPARE_DATASET="true"

while getopts 'ht:c:d:b:n:p:m:' OPT; do
	case "$OPT" in
		t) PATH_TO_AVA_TXT="$OPTARG";;
		c) DIR_OF_CSV="$OPTARG";;
		d) DIR_OF_IMAGES = "$OPTARG";;
		b) BATCH_SIZE=$OPTARG;;
		n) NUM_WORKERS=$OPTARG;;
		p) PREPARE_DATASET="$OPTARG";;
		m) PATH_TO_MODEL="$OPTARG";;
		h) Usage;;
		?) Usage;;
	esac
done

echo "PATH_TO_AVA_TXT = $PATH_TO_AVA_TXT"
echo "DIR_OF_CSV = $DIR_OF_CSV"
echo "DIR_OF_IMAGES = $DIR_OF_IMAGES"
echo "BATCH_SIZE = $BATCH_SIZE"
echo "NUM_WORKERS = $NUM_WORKERS"
echo "PATH_TO_MODEL = $PATH_TO_MODEL"

# Clean and prepare dataset
if [ $PREPARE_DATASET = "true" ];then
	python3 -m nima.cli prepare_dataset --path_to_ava_txt $PATH_TO_AVA_TXT \
					    --path_to_save_csv $DIR_OF_CSV \
					    --path_to_images $DIR_OF_IMAGES
fi

# If the model doesn't exist, download one from the Internet
if [ ! -f $PATH_TO_MODEL ];then
	echo "The model doesn't exist there"
	echo "Start downloading a pretrain-model from https://s3-us-west-1.amazonaws.com/models-nima/pretrain-model.pth"
	curl https://s3-us-west-1.amazonaws.com/models-nima/pretrain-model.pth -o $PATH_TO_MODEL
fi

# Validate the model
python3 -m nima.cli validate_model --path_to_model_weight $PATH_TO_MODEL \
                                    --path_to_save_csv $DIR_OF_CSV \
                                    --path_to_images $DIR_OF_IMAGES \
                                    --batch_size $BATCH_SIZE \
                                    --num_workers $NUM_WORKERS

