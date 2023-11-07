#!/bin/sh

cd /usr/src/photos

PATH_PHOTOS="À trier"
echo -n "$(date '+%Y-%m-%d %H:%M:%S') - "
echo "Start updating photos"

# Remove photos in cached folders
find "$PATH_PHOTOS"/ -type d -name "*.@__thumb" -print0 | xargs -0 -r rm -r
echo -n "$(date '+%Y-%m-%d %H:%M:%S') - "
echo "Removed cached folders"

# WHATSAPP photos does not have date in metadata but the date can be retrieved by the date
# at least it's the date the photo has been sent on, but it's better than nothing
WHATSAPP_PHOTOS=$(find "$PATH_PHOTOS" -regex ".*(VID|IMG)-[0-9]{8}-WA[0-9]{4}.*.(mp4|jpg)" -not -path '*/\.*' -printf "\"%p\"\n")
n=0
for photo in "$WHATSAPP_PHOTOS"
do
  DATE=$(echo "$photo" | grep -Eo "(VID|IMG)-[0-9]{8}-WA[0-9]{4}.*.(mp4|jpg)" | grep -Eo "[0-9]{8}" | xargs -I date_str date -d date_str "+%Y:%m:%d 00:00:00")
  exiftool -overwrite_original "-createdate=$DATE" "$photo" > /dev/null
  let "x+=1"
done
echo -n "$(date '+%Y-%m-%d %H:%M:%S') - "
echo "$n whatsapp photos updated"

# Pictures with both a complete datetime and camera model
# Note that some pictures (for example taken with honor camera)
# seems to not format well metadata leading to a warning with exiftool
# Therefore, warnings are redirected to /dev/null
echo -n "$(date '+%Y-%m-%d %H:%M:%S') - "
exiftool \
  -r \
  -d %Y/%m/%d/%Y%m%d-%H%M%S \
  '-filename<${datetimeoriginal}_${model}%-.2nc.%e' \
  -if '($datetimeoriginal and $model)' \
  "$PATH_PHOTOS" 2> /dev/null | \
  awk 'BEGIN{x=0} /image files updated/{x=$1} END{print x " photos with datetime and camera model updated"}'

# Pictures with datetime but no camera model
echo -n "$(date '+%Y-%m-%d %H:%M:%S') - "
exiftool \
  -r \
  -d %Y/%m/%d/%Y%m%d-%H%M%S \
  '-filename<${datetimeoriginal}%-.2nc.%e' \
  -if '($datetimeoriginal)' \
  "$PATH_PHOTOS" 2> /dev/null | \
  awk 'BEGIN{x=0} /image files updated/{x=$1} END{print x " photos with datetime updated"}'

# Pictures with not datetime but a createdate
echo -n "$(date '+%Y-%m-%d %H:%M:%S') - "
exiftool \
  -r \
  -d %Y/%m/%d/%Y%m%d-%H%M%S \
  '-filename<${createdate}%-.2nc.%e' \
  -if '$createdate and (not $createdate eq "0000:00:00 00:00:00")' \
  "$PATH_PHOTOS" 2> /dev/null | \
  awk 'BEGIN{x=0} /image files updated/{x=$1} END{print x " photos with create date updated"}'
 
# Pictures with no datetime but a contentcreatedate
echo -n "$(date '+%Y-%m-%d %H:%M:%S') - "
exiftool \
  -r \
  -d %Y/%m/%d/%Y%m%d-%H%M%S \
  '-filename<${contentcreatedate}%-.2nc.%e' \
  -if '$contentcreatedate and (not $contentcreatedate eq "0000:00:00 00:00:00")' \
  "$PATH_PHOTOS" 2> /dev/null | \
  awk 'BEGIN{x=0} /image files updated/{x=$1} END{print x " photos with content date updated"}'
  
# Pictures with no datetime but a modification datetime
#echo -n "$(date '+%Y-%m-%d %H:%M:%S') - "
#exiftool \
#  -r \
#  -d %Y/%m/%d/%Y%m%d-%H%M%S \
#  '-filename<${filemodifydate}%-.2nc.%e' \
#  -if '$filemodifydate and (not $filemodifydate eq "0000:00:00 00:00:00")' \
#  "$PATH_PHOTOS" 2> /dev/null | \
#  awk 'BEGIN{x=0} /image files updated/{x=$1} END{print x " photos with modify date updated"}'

# Remove duplicates
echo -n "$(date '+%Y-%m-%d %H:%M:%S') - "
fdupes -rAdNo 'name' . 2&> /dev/null
echo "Removed duplicates"

# Remove empty folders
echo -n "$(date '+%Y-%m-%d %H:%M:%S') - "
find  "$PATH_PHOTOS" ! -path "$PATH_PHOTOS" -type d -empty -delete
echo "Removed empty folders"
