#!/bin/bash
platform=broadcom
model=$(/root/getmode.sh full_model)
if [ "$model" = "hum-hr24" -o "$model" = "pac-h24" ]; then
platform=entropic
fi
res=$(cat /proc/graphics/resolution)
case $res in
"1920x1080")
width="\x80\x07\x00\x00"
height="\xC8\xFB\xFF\xFF"
size="\x00\x90\x7E\x00"
file_size="\x7A\x90\x7E\x00"
;;
"1280x720")
width="\x00\x05\x00\x00"
height="\x30\xFD\xFF\xFF"
size="\x00\x40\x38\x00"
file_size="\x7A\x40\x38\x00"
;;
"720x480")
width="\xD0\x02\x00\x00"
height="\x20\xFE\xFF\xFF"
size="\x00\x18\x15\x00"
file_size="\x7A\x18\x15\x00"
;;
*)
echo "Invalid resolution: \"$res\""
exit
esac
if [ $# -eq 1 ]; then
out=$1
else
out="screenshot.$(date "+%s").bmp"
fi
echo -n "Writing screenshot to $out ... "
echo -ne "\x42\x4D" > $out
echo -ne "$file_size" >> $out
echo -ne "\x00\x00\x00\x00" >> $out
echo -ne "\x7A\x00\x00\x00" >> $out
echo -ne "\x6C\x00\x00\x00" >> $out
echo -ne "$width" >> $out
echo -ne "$height" >> $out
echo -ne "\x01\x00" >> $out
echo -ne "\x20\x00" >> $out
echo -ne "\x03\x00\x00\x00" >> $out
echo -ne "$size" >> $out
echo -ne "\x13\x0B\x00\x00" >> $out
echo -ne "\x13\x0B\x00\x00" >> $out
echo -ne "\x00\x00\x00\x00" >> $out
echo -ne "\x00\x00\x00\x00" >> $out
if [ $platform = "broadcom" ]; then
echo -ne "\xFF\x00\x00\x00" >> $out
echo -ne "\x00\xFF\x00\x00" >> $out
fi
echo -ne "\x00\x00\xFF\x00" >> $out
if [ $platform = "entropic" ]; then
echo -ne "\x00\xFF\x00\x00" >> $out
echo -ne "\xFF\x00\x00\x00" >> $out
fi
echo -ne "\x00\x00\x00\xFF" >> $out
echo -ne "\x01\x00\x00\x00" >> $out
echo -ne "\x00\x00\x00\x00""\x00\x00\x00\x00""\x00\x00\x00\x00" >> $out
echo -ne "\x00\x00\x00\x00""\x00\x00\x00\x00""\x00\x00\x00\x00" >> $out
echo -ne "\x00\x00\x00\x00""\x00\x00\x00\x00""\x00\x00\x00\x00" >> $out
echo -ne "\x00\x00\x00\x00" >> $out
echo -ne "\x00\x00\x00\x00" >> $out
echo -ne "\x00\x00\x00\x00" >> $out
cat /proc/graphics/screenshot >> $out
echo "completed."
