#!/bin/bash
# @sacloud-once
# @sacloud-desc Minecraft Serverをセットアップします。
# @sacloud-desc （このスクリプトは、CentOS6.XもしくはScientific Linux6.Xでのみ動作します）
# @sacloud-require-archive distro-centos distro-ver-6.*
# @sacloud-require-archive distro-sl distro-ver-6.*

#---------iptablesの設定---------#
cat <<'EOT' > /etc/sysconfig/iptables
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
:fail2ban-SSH - [0:0]
-A INPUT -p tcp -m multiport --dports 22 -j fail2ban-SSH
-A INPUT -p TCP -m state --state NEW ! --syn -j DROP
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
-A INPUT -p udp --sport 123 --dport 123 -j ACCEPT
-A INPUT -p udp --sport 53 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 25565 -j ACCEPT
-A fail2ban-SSH -j RETURN
COMMIT
EOT
service iptables restart
#---------iptablesの設定終わり---------#
#---------Javaのインストール---------#
yum install -y java-1.8.0-openjdk
#---------Javaのインストール終わり---------#
#---------Minecraft Serverのインストール---------#
wget -P ~/minecraft https://s3.amazonaws.com/Minecraft.Download/versions/1.8.7/minecraft_server.1.8.7.jar

# 一度起動し、eula.txtファイルを生成させる
java -Xms1024M -Xmx1024M -jar minecraft_server.1.8.7.jar nogui
echo eula=true > ~/minecraft/eula.txt

# upstartの設定ファイルを作成
cat <<'EOT' > /etc/init/minecraft.conf
description "Minecraft server"
chdir /root/minecraft
exec java -Xms1024M -Xmx1024M -jar minecraft_server.1.8.7.jar nogui
start on startup
EOT

# 起動
start minecraft
#---------Minecraft Serverのインストール終わり---------#