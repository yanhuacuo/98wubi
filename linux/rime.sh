#!/bin/bash

echo "安装Librime运行环境"

sudo apt install opencc libopencc-dev libyaml-cpp-dev -y

cd ../opencc/

echo "清理原属 Windows 下的 OCD 文件"

rm -rf ./*.ocd

echo "清理完毕，开始制作 Linux 专属 OCD 文件"

opencc_dict -i 98wb_spelling.txt -o 98wb_spelling.ocd -f text -t ocd

opencc_dict -i jiayin.txt -o jiayin.ocd -f text -t ocd

opencc_dict -i STCharacters.txt -o STCharacters.ocd -f text -t ocd

opencc_dict -i STPhrases.txt -o STPhrases.ocd -f text -t ocd

sudo chmod 777 ./*

echo "成功制作 OCD 文件，即将准备安放配置文件"

cd ../

echo "清理目标文件夹"

rm -rf ~/.config/ibus/rime/build
rm -rf ~/.config/fcitx/rime/build
rm -rf ~/.config/fcitx/skin
rm -rf ~/.config/fcitx/rime/*
rm -rf ~/.config/ibus/rime/*

mkdir ~/.config/ibus/rime/build
mkdir ~/.config/fcitx/rime/build
mkdir ~/.config/fcitx/skin

sudo rm -rf /usr/share/rime-data/*

echo "准备添加fcitx皮肤文件"

cp -rf ./98wb-B ~/.config/fcitx/skin

echo "添加fcitx皮肤文件成功"

echo "开始拷贝98五笔输入法文件"

sudo cp -rf ./*.yaml /usr/share/rime-data
sudo cp -rf ./opencc /usr/share/rime-data

cp -rf ./*.yaml ~/.config/ibus/rime
cp -rf ./opencc ~/.config/ibus/rime
cp -rf ./ibus_rime.yaml ~/.config/ibus/rime/build
cp -rf ./*.yaml ~/.config/fcitx/rime
cp -rf ./opencc ~/.config/fcitx/rime

sudo chmod -R 755 /usr/share/rime-data

sudo chmod -R 777 ~/.config/ibus

sudo chmod -R 777 ~/.config/fcitx

echo "输入法相关文件安置结束，为码元拆分提示准备矢量字体支持"

sudo rm -rf /usr/share/fonts/98WB

sudo mkdir -p /usr/share/fonts/98WB

sudo cp -rf ./fonts/98WB-1.otf /usr/share/fonts/98WB

sudo chmod 755 /usr/share/fonts/98WB/98WB-1.otf

cd /usr/share/fonts/98WB

sudo mkfontscale

sudo mkfontdir 

sudo fc-cache -fv

sudo chmod -R 755 /usr/share/fonts/98WB

echo "矢量字体添加成功"

echo "中州韻配置文件安置成功，注銷系統後將重新部署。"
