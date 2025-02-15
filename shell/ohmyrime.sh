#!/bin/bash
echo "为您配置 Gnome_ibus 下的薄荷输入法！"
if [ -d ~/.local/autoRunRime/Gnome_ibus ];then
  echo "检测到 Gnome_ibus 文件夹已存在，执行清空！"
  rm -rf ~/.local/autoRunRime/Gnome_ibus/*
else
  echo "检测到 Gnome_ibus 文件夹不存在，将创建这个目录！"
  mkdir -p ~/.local/autoRunRime/Gnome_ibus
fi

curl -Lo ~/.local/autoRunRime/Gnome_ibus/oh-my-rime-full.tar.xz https://gitee.com/wubi98/fcitx5-98wb/releases/download/v6.0/oh-my-rime-full.tar.xz

echo "文件已下载！"

tar -xvf ~/.local/autoRunRime/Gnome_ibus/oh-my-rime-full.tar.xz -C ~/.local/autoRunRime/Gnome_ibus/

if [ -d ~/.local/autoRunRime/Gnome_ibus ];then
  echo "执行本地解压缩..."
  chmod -R 777 ~/.local/autoRunRime/Gnome_ibus
  cd ~/.local/autoRunRime/Gnome_ibus/oh-my-rime-full
else
  tar -xvf ~/.local/autoRunRime/Gnome_ibus/oh-my-rime-full.tar.xz -C ~/.local/autoRunRime/Gnome_ibus/
  chmod -R 777 ~/.local/autoRunRime/Gnome_ibus
  cd ~/.local/autoRunRime/Gnome_ibus/oh-my-rime-full
fi

file="$HOME/.local/autoRunRime/Gnome_ibus/oh-my-rime-full/rime.sh"

if test -e "$file"; then
    chmod 777 ~/.local/autoRunRime/Gnome_ibus/oh-my-rime-full/rime.sh
    echo "配置文件安装中，请稍后..."
    bash  rime.sh
    echo "配置文件安装完毕！"
else
    echo "$file 不存在"
    echo "请检查网络！"
fi

cd ~/.local/

echo "脚本执行完毕！"
