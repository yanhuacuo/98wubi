#!/bin/bash
echo "为您配置 fcitx5-98wb 下的98五笔！"
if [ -d ~/.local/autoRun98wb/fcitx5-98wb ];then
  echo "检测到 fcitx5-98wb 文件夹已存在，执行清空！"
  rm -rf ~/.local/autoRun98wb/fcitx5-98wb/*
else
  echo "检测到 fcitx5-98wb 文件夹不存在，将创建这个目录！"
  mkdir -p ~/.local/autoRun98wb/fcitx5-98wb
fi

curl -Lo ~/.local/autoRun98wb/fcitx5-98wb/fcitx5-98wb.tar.xz https://gitee.com/wubi98/fcitx5-98wb/releases/download/v1.0/fcitx5-98wb.tar.xz

echo "文件已下载！"

tar -xvf ~/.local/autoRun98wb/fcitx5-98wb/fcitx5-98wb.tar.xz -C ~/.local/autoRun98wb/fcitx5-98wb/

if [ -d ~/.local/autoRun98wb/fcitx5-98wb ];then
  echo "执行本地解压缩..."
  chmod -R 777 ~/.local/autoRun98wb/fcitx5-98wb
  cd ~/.local/autoRun98wb/fcitx5-98wb
else
  tar -xvf ~/.local/autoRun98wb/fcitx5-98wb/fcitx5-98wb.tar.xz -C ~/.local/autoRun98wb/fcitx5-98wb/
  chmod -R 777 ~/.local/autoRun98wb/fcitx5-98wb
  cd ~/.local/autoRun98wb/fcitx5-98wb
fi

file="$HOME/.local/autoRun98wb/fcitx5-98wb/set.sh"

if test -e "$file"; then
    chmod 777 ~/.local/autoRun98wb/fcitx5-98wb/set.sh
    echo "配置文件安装中，请稍后..."
    bash set.sh
    echo "配置文件安装完毕！"
else
    echo "$file 不存在"
    echo "请检查网络！"
fi

cd ~/.local/

echo "脚本执行完毕！"