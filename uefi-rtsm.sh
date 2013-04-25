#!/bin/bash
################################################################################
# This is an example of how to run the A15x2 RTSM model
#
# Future versions will be more flexible and allow other models to be run too.
# This script relies on the users having first built the .fd file.
################################################################################
WORKSPACE=/linaro/uefi/master/uefi-next.git

FLEXLM_TUNNEL="ssh -L 8224:localhost:8224 -L 18224:localhost:18224 -N portfwd@23.21.178.17"
flexlm=`ps aux | grep $FLEXLM_TUNNEL`

if [ "$flexlm" == "" ]
then
	echo "FlexLm tunnel not running, starting it...."

	# Run the license pass-through
	ssh -L 8224:localhost:8224 -L 18224:localhost:18224 -N portfwd@23.21.178.170 &
fi

# add RTSM stuff to your env
source $HOME/ARM/FastModelsTools_7.1/source_all.sh

# add a variable for the model you want
RTSM_MODEL=$HOME/ARM/RTSM/Linux64_RTSM_VE_Cortex-A15x2/RTSM_VE_Cortex-A15x2

RTSM_UEFI=$WORKSPACE/Build/ArmVExpress-RTSM-A15_MPCore/DEBUG_ARMLINUXGCC/FV/RTSM_VE_CORTEX-A15_MPCORE_EFI.fd

# Run the model
$RTSM_MODEL \
-C motherboard.flashloader0.fname=$RTSM_UEFI \
-C motherboard.mmc.p_mmc_file=$RTSM_MMC

