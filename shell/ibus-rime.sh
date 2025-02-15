#!/bin/bash
echo "为您配置 Ubuntu-22.04-LTS 下的98五笔！"
if [ -d ~/.local/autoRun98wb/Ubuntu-22.04-LTS ];then
  echo "检测到 Ubuntu-22.04-LTS 文件夹已存在，执行清空！"
  rm -rf ~/.local/autoRun98wb/Ubuntu-22.04-LTS/*
else
  echo "检测到 Ubuntu-22.04-LTS 文件夹不存在，将创建这个目录！"
  mkdir -p ~/.local/autoRun98wb/Ubuntu-22.04-LTS
fi

curl -Lo ~/.local/autoRun98wb/Ubuntu-22.04-LTS/Ubuntu-22.04-LTS.tar.xz https://gitee.com/wubi98/fcitx5-98wb/releases/download/v3.0/Ubuntu-22.04-LTS.tar.xz

echo "文件已下载！"

tar -xvf ~/.local/autoRun98wb/Ubuntu-22.04-LTS/Ubuntu-22.04-LTS.tar.xz -C ~/.local/autoRun98wb/Ubuntu-22.04-LTS/

if [ -d ~/.local/autoRun98wb/Ubuntu-22.04-LTS ];then
  echo "执行本地解压缩..."
  chmod -R 777 ~/.local/autoRun98wb/Ubuntu-22.04-LTS
  cd ~/.local/autoRun98wb/Ubuntu-22.04-LTS
else
  tar -xvf ~/.local/autoRun98wb/Ubuntu-22.04-LTS/Ubuntu-22.04-LTS.tar.xz -C ~/.local/autoRun98wb/Ubuntu-22.04-LTS/
  chmod -R 777 ~/.local/autoRun98wb/Ubuntu-22.04-LTS
  cd ~/.local/autoRun98wb/Ubuntu-22.04-LTS
fi

file="$HOME/.local/autoRun98wb/Ubuntu-22.04-LTS/rime.sh"

if test -e "$file"; then
    chmod 777 ~/.local/autoRun98wb/Ubuntu-22.04-LTS/font.sh
    chmod 777 ~/.local/autoRun98wb/Ubuntu-22.04-LTS/rime.sh
    echo "配置文件安装中，请稍后..."
    bash font.sh
    bash rime.sh
    echo "配置文件安装完毕！"
else
    echo "$file 不存在"
    echo "请检查网络！"
fi

cd ~/.local/

echo "脚本执行完毕！"