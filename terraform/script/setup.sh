#!/bin/bash

set -eux  # デバッグのためのオプション（エラー時に停止）

# 必要なパッケージをインストール
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt -y install cargo
sudo apt-get -y install git binutils rustc pkg-config libssl-dev gettext


# EFSマウントツールのインストール
git clone https://github.com/aws/efs-utils
cd efs-utils
./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb

# EFSのマウント
sudo mkdir -p /mnt/efs
sudo mount -t efs ${EFS_ID}:/ /mnt/efs
echo "${EFS_ID}:/ /mnt/efs efs defaults,_netdev 0 0" | sudo tee -a /etc/fstab

# Node.jsのインストール
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Ruby & その他ツール
sudo apt install -y ruby-full wget

# CodeDeployのインストール
cd /home/ubuntu
wget https://aws-codedeploy-${AWS_REGION}.s3.${AWS_REGION}.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

# SQLiteのビルドとインストール
sudo apt install -y build-essential libreadline-dev
cd /usr/local/src
sudo curl -OL https://www.sqlite.org/2024/sqlite-autoconf-3450300.tar.gz
sudo tar xvzf sqlite-autoconf-3450300.tar.gz
cd sqlite-autoconf-3450300/
sudo ./configure
sudo make -j$(nproc)
sudo make install

# データベースディレクトリの作成（存在していなければ）
DB_PATH="/mnt/efs/db/app.db"
sudo mkdir -p /mnt/efs/db
sudo chmod -R 777 /mnt/efs/db

# すでにDBが存在するかチェックして、存在しない場合のみ作成
if [ ! -f "$DB_PATH" ]; then
    echo "Database not found. Creating new database..."
    sqlite3 "$DB_PATH" <<EOF
CREATE TABLE ingredients (
    id INTEGER NOT NULL,
    name TEXT NOT NULL,
    amount INTEGER NOT NULL,
    unit TEXT NOT NULL,
    deadline DATE NOT NULL,
    user_name TEXT NOT NULL,
    PRIMARY KEY (id, user_name)
);
EOF
fi

# Nginxのインストール
sudo apt-get install -y nginx

# Nginxの設定
cat <<EOF | sudo tee /etc/nginx/sites-available/default
server {
    listen 80;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /api/ {
        proxy_pass http://localhost:3500;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

EOF

# Nginxの再起動
sudo systemctl restart nginx

echo "Setup complete."
