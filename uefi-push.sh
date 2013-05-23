#!/bin/bash
################################################################################
# Update uefi-next repo
#
# You can specifiy an alternative remote as the first parameter.
# nb. the remote has to have been added to the repo first.
#
# The public code goes to both the public and the private repo
#
################################################################################

################################################################################
source uefi-common
################################################################################

if [ "$1" = "" ]
then
	REPO=$UEFI_NEXT_GIT_PUSH_REMOTE
	echo "Using default repo: $REPO"
else
	REPO=$1
    echo "REPO is $REPO"
fi

INTERNAL_REPO=$UEFI_INTERNAL_GIT_PUSH_REMOTE

################################################################################
# Update core branches
################################################################################
git push $REPO          master
git push $INTERNAL_REPO master
git push $REPO          tianocore-edk2
git push $INTERNAL_REPO tianocore-edk2
git push $REPO          tianocore-edk2-fatdriver2
git push $INTERNAL_REPO tianocore-edk2-fatdriver2
git push $REPO          tianocore-edk2-basetools
git push $INTERNAL_REPO tianocore-edk2-basetools

################################################################################
# Update topic branches
# Use "push -f" because topic branches are rebased
################################################################################
branches=(`git branch --list linaro-topic-* | sed "s/*//"`)

for branch in "${branches[@]}" ; do
	echo "----------------------------------------"
	echo "Pushing branch $branch to $REPO"
	echo "----------------------------------------"
	# -f is needed because these branches are rebased
	git push -f $REPO $branch
	git push -f $INTERNAL_REPO $branch
done

################################################################################
# Update tracking branches
################################################################################
echo "Pushing out monthly branch $REPO $MONTH_BRANCH..."
git push $REPO          $(uefi_next_current_month_branch)
git push $INTERNAL_REPO $(uefi_next_current_month_branch)

git push $REPO          armlt-tracking
git push $INTERNAL_REPO armlt-tracking
git push $REPO          linaro-tracking
git push $INTERNAL_REPO linaro-tracking

git push $REPO `git tag -l linaro-uefi-????.??-rc*`
git push $INTERNAL_REPO `git tag -l linaro-uefi-????.??-rc*`

################################################################################
# Update internal topic and feature branches on the internal tree
# Use "push -f" because topic/feature branches are/may be rebased
################################################################################
#
#   PPP  RRR   I  V   V   AA  TTTTT  EEEE
#   P  P R  R  I  V   V  A  A   T    E
#   PPP  RRR   I   V V   AAAA   T    EEE
#   P    RR    I   V V   A  A   T    E
#   P    R R   I    V    A  A   T    EEEE
#
# Everything from here down goes to the private repo
#
################################################################################

# make sure REPO isn't used again in this script
REPO=error

branches=(`git branch --list linaro-internal-topic-* linaro-internal-feature-* | sed "s/*//"`)

for branch in "${branches[@]}" ; do
	echo "----------------------------------------"
	echo "Pushing branch $branch to $INTERNAL_REPO"
	echo "----------------------------------------"
	# -f is needed because these branches are rebased
	git push -f $INTERNAL_REPO $branch
done

################################################################################
# Update tracking branch
################################################################################
echo "Pushing out monthly branch $INTERNAL_REPO $(uefi_next_internal_current_month_branch)..."
git push $INTERNAL_REPO $(uefi_next_internal_current_month_branch)
git push $INTERNAL_REPO `git tag -l linaro-uefi-internal-????.??-rc*`
