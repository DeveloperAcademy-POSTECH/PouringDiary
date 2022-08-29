#!/bin/sh

#  ci_pre_xcodebuild.sh
#  PouringDiary
#
#  Created by devisaac on 2022/08/05.
#  


echo ${CI_FB_PLIST} >> ../Shared/Environment/GoogleService-Info.plist
echo "Firebase GoogleService-Info.plist created at"
cd ../Shared/Environment/
echo | pwd
echo | cat GoogleService-Info.plist
