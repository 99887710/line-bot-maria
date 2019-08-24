#!/bin/bash

# Initialise some local variables for terminal control.
COLUMNS=$(tput cols)
if [ $COLUMNS -gt 78 ]; then COLUMNS=78; fi
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

# Prepare and handle the optional parameters.
PROFILE_NAME=
TEMPLATE_FILE=template.file
S3_BUCKET=rms-developer-bucket-002
REGION=
while getopts "b:p:t:r:" o; do
	case "${o}" in
		p)
			PROFILE_NAME="--profile ${OPTARG}"
			;;
		t)
			TEMPLATE_FILE="${OPTARG}"
			;;
		b)
			S3_BUCKET="${OPTARG}"
			;;
		r)
		    REGION="--region ${OPTARG}"
		    ;;
		*)
			echo Unrecognised option \"${o}\";
			exit 1
			;;
	esac
done
shift $((OPTIND-1))

# Pick up the mandatory positional parameters.
STACK_NAME=${1?The stack name must be supplied.}

# Check that the template file exists.
if [ ! -r ${TEMPLATE_FILE} ]; then
	echo Template file \"${TEMPLATE_FILE}\" does not exist.
	exit 1
fi

function bannerDisplay() {
	echo
	echo '##############################################################################'
	echo
	
	while [ $# -gt 0 ]; do
		printf "${BOLD}%*s${NORMAL}\n" $(( ($COLUMNS + ${#1})/2 )) "${1}"
		shift
	done
	
	echo
	echo '##############################################################################'
	echo
}

function buildCommand() {
	local STAGE=$1
	local COMMAND=$2

	eval "(set -x; $COMMAND)"
	local RetCode=$?
	if [ $RetCode -ne 0 ]; then
		bannerDisplay "$STAGE failed."
		exit 1
	else
		bannerDisplay "$STAGE succeeded."
	fi
}

buildCommand Build "mvn clean package -DskipTests"

buildCommand Package "aws cloudformation package ${PROFILE_NAME} ${REGION} --template-file ${TEMPLATE_FILE} --s3-bucket ${S3_BUCKET} --output-template-file packaged.yaml"

buildCommand Deploy "aws cloudformation deploy ${PROFILE_NAME} ${REGION} --template-file packaged.yaml --stack-name ${STACK_NAME} --capabilities CAPABILITY_IAM"
