#!/bin/bash

## Get scores for one image
set -e
Usage()
{
	echo "Usage:"
	echo "sh predict.sh [-m PATH_TO_MODEL] [-i PATH_TO_IMAGE]"
	echo ""
	echo "Description:"
	echo "	PATH_TO_MODEL, the path to the pretrained model"
	echo "	PATH_TO_IMAGE, the path to the image to be evaluated"
	exit
}

PATH_TO_MODEL="./DATA/pretrain-model.pth"

while getopts 'hi:m:' OPT; do
	case "$OPT" in
		i) PATH_TO_IMAGE="$OPTARG";;
		m) PATH_TO_MODEL="$OPTARG";;
		h) Usage;;
		?) Usage;;
	esac
done

# If the model doesn't exist, download one from the Internet
if [ ! -f $PATH_TO_MODEL ];then
	echo "The model doesn't exist there"
	echo "Start downloading a pretrain-model from https://s3-us-west-1.amazonaws.com/models-nima/pretrain-model.pth"
	curl https://s3-us-west-1.amazonaws.com/models-nima/pretrain-model.pth -o $PATH_TO_MODEL
fi

python3 -m nima.cli get_image_score --path_to_model_weight $PATH_TO_MODEL --path_to_image $PATH_TO_IMAGE


