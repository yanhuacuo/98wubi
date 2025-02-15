#!/bin/bash
echo "要开始了，准备输入密码。"
echo "本次操作需要「管理员权限」，请输入密码"
sudo /Library/Input\ Methods/Squirrel.app/Contents/MacOS/Squirrel --quit
rm -rf ~/Library/Rime/*.txt
sudo rm -rf /Library/Input\ Methods/Squirrel.app/Contents/SharedSupport/build
echo "重新部署，使新码表生效"
sudo /Library/Input\ Methods/Squirrel.app/Contents/MacOS/Squirrel --reload
echo "做完，收工。"