#!/bin/bash

apt install opencc libopencc-dev libyaml-cpp-dev -y

cd ../opencc/

echo "清理原属 Windows 下的 OCD 文件"

rm -rf ~/*.ocd

echo "清理完毕，开始制作 Linux 专属 OCD 文件"

opencc_dict -i 98wb_spelling.txt -o 98wb_spelling.ocd -f text -t ocd

opencc_dict -i jiayin.txt -o jiayin.ocd -f text -t ocd

opencc_dict -i STCharacters.txt -o STCharacters.ocd -f text -t ocd

opencc_dict -i STPhrases.txt -o STPhrases.ocd -f text -t ocd

chmod 777 ./*

cd ../

rm -rf ~/.config/fcitx/rime

rm -rf ~/.config/ibus/rime

rm -rf /usr/share/rime-data/*

cp -rf ./*.yaml /usr/share/rime-data
cp -rf ./opencc /usr/share/rime-data
cp -rf ./*.yaml ~/.config/ibus/rime
cp -rf ./opencc ~/.config/ibus/rime

mkdir -p ~/.config/ibus/rime/build

cp -rf ./ibus_rime.yaml ~/.config/ibus/rime/build

mkdir -p ~/.config/fcitx/rime

cp -rf ./*.yaml ~/.config/fcitx/rime
cp -rf ./opencc ~/.config/fcitx/rime

chmod -R 755 /usr/share/rime-data

chmod -R 777 ~/.config/ibus

chmod -R 777 ~/.config/fcitx

rm -rf /usr/share/fonts/98WB

mkdir -p /usr/share/fonts/98WB

cp -rf ./fonts/98WB-1.otf /usr/share/fonts/98WB

chmod 755 /usr/share/fonts/98WB/98WB-1.otf

cd /usr/share/fonts/98WB

mkfontscale

mkfontdir 

fc-cache -fv

chmod -R 755 /usr/share/fonts/98WB

echo "中州韻配置文件安置成功，注銷系統後將重新部署。"
