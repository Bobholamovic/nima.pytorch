#!/bin/bash

## Train a new model
set -e
Usage()
{
	echo "Usage:"
	echo "sh train.sh [-t PATH_TO_AVA_TXT] [-c DIR_OF_CSV] [-d DIR_OF_IMAGES] [-b BATCH_SIZE] [-n NUM_WORKERS] [-e NUM_EPOCH] [-i INIT_LR] [-x EXPERIMENT_DIR_NAME] [-p PREPARE_DATASET] [-P PRETRAINED_MODEL]"
	echo ""
	echo "Description:"
	echo "	PATH_TO_AVA_TXT, the path to AVA .txt file"
	echo "	DIR_OF_IMAGES, the directory of images"
	echo "	DIR_OF_CSV, the directory to save .csv file"
	echo "	BATCH_SIZE, the batch size"
	echo "	NUM_WORKERS, the number of worker threads to use"
	echo "	NUM_EPOCH, the number of training epochs"
	echo "	INIT_LR, the initial LR value"
	echo "	EXPERIMENT_DIR_NAME, the directory to restore the model"
	echo "	PREPARE_DATASET, whether to prepare and split dataset"
	echo "	PRETRAINED_MODEL, whether to use a pretrain-model"
	exit
}

PATH_TO_AVA_TXT="./DATA/AVA.txt"
DIR_OF_CSV="./DATA/"
DIR_OF_IMAGES="./DATA/images/"
BATCH_SIZE=16
NUM_WORKERS=4
NUM_EPOCH=50
INIT_LR=0.0001
EXPERIMENT_DIR_NAME="./EXP/"
PREPARE_DATASET="true"
PRETRAINED_MODEL="true"

while getopts 'ht:c:d:b:n:e:i:x:p:P:' OPT; do
	case "$OPT" in
		t) PATH_TO_AVA_TXT="$OPTARG";;
		c) DIR_OF_CSV="$OPTARG";;
		d) DIR_OF_IMAGES = "$OPTARG";;
		b) BATCH_SIZE=$OPTARG;;
		n) NUM_WORKERS=$OPTARG;;
		e) NUM_EPOCH=$OPTARG;;
		i) INIT_LR=$OPTARG;;
		x) EXPERIMENT_DIR_NAME="$OPTARG";;
		p) PREPARE_DATASET="$OPTARG";;
		P) PRETRAINED_MODEL="$OPTARG";;
		h) Usage;;
		?) Usage;;
	esac
done

echo "$PRETRAINED_MODEL"
echo "PATH_TO_AVA_TXT = $PATH_TO_AVA_TXT"
echo "DIR_OF_CSV = $DIR_OF_CSV"
echo "DIR_OF_IMAGES = $DIR_OF_IMAGES"
echo "BATCH_SIZE = $BATCH_SIZE"
echo "NUM_WORKERS = $NUM_WORKERS"
echo "NUM_EPOCH = $NUM_EPOCH"
echo "INIT_LR = $INIT_LR"
echo "EXPERIMENT_DIR_NAME = $EXPERIMENT_DIR_NAME"

# Clean and prepare dataset
if [ $PREPARE_DATASET = "true" ];then
	python3 -m nima.cli prepare_dataset --path_to_ava_txt $PATH_TO_AVA_TXT \
					    --path_to_save_csv $DIR_OF_CSV \
					    --path_to_images $DIR_OF_IMAGES
fi

# Train model
python3 -m nima.cli train_model --path_to_save_csv $DIR_OF_CSV \
				--path_to_images $DIR_OF_IMAGES \
				--batch_size $BATCH_SIZE \
				--num_workers $NUM_WORKERS \
				--num_epoch $NUM_EPOCH \
				--init_lr $INIT_LR \
				--experiment_dir_name $EXPERIMENT_DIR_NAME \
				--pretrained_model $PRETRAINED_MODEL
# Use tensorboard to track training progress
tensorboard --logdir=${EXPERIMENT_DIR_NAME}logs
