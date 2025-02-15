#!/bin/bash
echo "为您配置【鼠须管】下的98五笔！"
if [ -d ~/Library/autoRun98wb/wubi98 ];then
  echo "检测到 wubi98 文件夹已存在，执行清空！"
  rm -rf ~/Library/autoRun98wb/wubi98/*
else
  echo "检测到 wubi98 文件夹不存在，将创建这个目录！"
  mkdir -p ~/Library/autoRun98wb/wubi98
fi

curl -Lo ~/Library/autoRun98wb/wubi98/MacOS_wubi98.tar.xz https://github.com/yanhuacuo/98wubi/releases/download/v4.1/MacOS_wubi98.tar.xz

echo "文件已下载！"

tar -xvf ~/Library/autoRun98wb/wubi98/MacOS_wubi98.tar.xz -C ~/Library/autoRun98wb/wubi98/

if [ -d ~/Library/autoRun98wb/wubi98 ];then
  echo "执行本地解压缩..."
  chmod -R 777 ~/Library/autoRun98wb/wubi98
  cd ~/Library/autoRun98wb/wubi98
else
  tar -xvf ~/Library/autoRun98wb/wubi98/MacOS_wubi98.tar.xz -C ~/Library/autoRun98wb/wubi98/
  chmod -R 777 ~/Library/autoRun98wb/wubi98
  cd ~/Library/autoRun98wb/wubi98
fi

file="$HOME/Library/autoRun98wb/wubi98/rime.sh"

if test -e "$file"; then
    chmod 777 ~/Library/autoRun98wb/wubi98/rime.sh
    echo "配置文件安装中，请稍后..."
    bash rime.sh
    echo "配置文件安装完毕！"
else
    echo "$file 不存在"
    echo "请检查网络！"
fi

cd ~/Library/

echo "脚本执行完毕！"
echo "请「注销系统一次」，并在「设置-键盘-输入法」中添加「鼠须管」选项。"
