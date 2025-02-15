#!/bin/bash
echo "本次操作需要「管理员权限」，请输入密码"
#sudo spctl --master-disable
path=${0%/*}
#curl -L https://github.com/yanhuacuo/squirrel-wb98-install/archive/refs/tags/2.0.zip -o autorun.zip
unzip -oq autorun.zip
if [ ! -d ""$path"/squirrel-wb98-install-2.0" ];then
  unzip -oq autorun.zip
fi
cd ./squirrel-wb98-install-2.0/
unzip -oq app.zip
cat 98wb-fonts.tar.gzaa 98wb-fonts.tar.gzab 98wb-fonts.tar.gzac 98wb-fonts.tar.gzad > 98wb-font.tar.gz
tar -xf 98wb-font.tar.gz
cp -rf 98wb-fonts/*.otf ~/Library/Fonts

if [ ! -d "/Library/Input Methods/Squirrel.app" ];then
    echo "本机尚未安装过鼠须管，即将执行全新安装"
else
    echo "检测到本机已有鼠须管，我们执行卸旧装新"
    login_user=`/usr/bin/stat -f%Su /dev/console`
    squirrel_app_root="${DSTROOT}/Squirrel.app"
    squirrel_executable="${squirrel_app_root}/Contents/MacOS/Squirrel"
    sudo spctl --master-disable
    /Library/Input\ Methods/Squirrel.app/Contents/MacOS/Squirrel --quit
    sudo rm -rf /Library/Input\ Methods/Squirrel.app
    sudo rm -rf ~/Library/Rime/*
    echo "已停用旧版"
fi
sudo cp -rf ./app/Squirrel.app /Library/Input\ Methods/
sudo cp -rf /Library/Input\ Methods/Squirrel.app/Contents/SharedSupport/* ~/Library/Rime
sudo rm -rf /Library/Input\ Methods/Squirrel.app/Contents/SharedSupport/build
sudo chmod -R 777 /Library/Input\ Methods/Squirrel.app
sudo chmod -R 777 ~/Library/Rime
sudo xattr -rd im.rime.inputmethod.Squirrel /Library/Input\ Methods/Squirrel.app
/usr/bin/sudo -u "${login_user}" /Library/Input\ Methods/Squirrel.app/Contents/MacOS/Squirrel --install
/Library/Input\ Methods/Squirrel.app/Contents/MacOS/Squirrel --reload
echo "请「注销系统一次」，并在「设置-键盘-输入法」中添加「鼠须管」选项。"