#!/bin/bash

# Sync with configs
source bot.conf
cd $HOME_DIR/$ROM_DIR
#source build/envsetup.sh

sendMessage() {
MESSAGE=$1

curl -s "https://api.telegram.org/bot${BOT_API_KEY}/sendmessage" --data "text=$MESSAGE&chat_id=$CHAT_ID" 1> /dev/null

echo -e;
}

if [ $? -eq 0 ]
then
		# Grab full file output
		FILE_OUTPUT=$(grep -Po 'Package Complete: \K[^ ]+' build.log)
		echo $FILE_OUTPUT

		ZIP_NAME=$(grep -Po 'Package Complete: \K[^ ]+' build.log | sed 's#.*/##')
		echo $ZIP_NAME

		# Upload to KontenaCloud via RClone
                rclone copy $FILE_OUTPUT kontena:test/rom -P
                URL=https://kontena.aikara.me/0:/test/rom/$ZIP_NAME
                echo $URL

else
	sendMessage "Build Failed!"
	echo "Build Failed!"
fi

rm url.log

		# Some Extra Summary to share
		MD5=`md5sum $FILE_OUTPUT | awk '{ print $1 }'`
		SIZE=`ls -sh $FILE_OUTPUT | awk '{ print $1 }'`

read -r -d '' SUMMARY << EOM
$FULL_ROM_NAME $A_VERSION for $FULL_DEVICE_NAME

Author: $TG_NAME
Build Date: $BUILD_DATE
Build Type: $BUILD_TYPE
LINK: $URL
SIZE: $SIZE
MD5: $MD5

NOTES: $NOTES
EOM

	curl -s "https://api.telegram.org/bot${BOT_API_KEY}/sendPhoto" -d parse_mode="Markdown" --data "photo=$PHOTO_LINK&caption=$SUMMARY&chat_id=$CHAT_ID"  1> /dev/null

	curl -s "https://api.telegram.org/bot${BOT_API_KEY}/sendSticker?chat_id=$CHAT_ID&sticker=$STICKER_ID"  1> /dev/null

exit 1

