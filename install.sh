#!/bin/bash
INSTALL_DIR="/opt/pastar_web_worker"
AWS_KEY_FILE="$INSTALL_DIR/.aws_keys"
INSTALL_USER=ubuntu
INSTALL_GROUP=ubuntu

cd $(dirname $0)

if [ "x$AWS_ACCESS_KEY_ID" = "x" ]; then
    echo "Please enter the AWS_ACCESS_KEY_ID"
    read AWS_ACCESS_KEY_ID
fi
if [ "x$AWS_SECRET_ACCESS_KEY" = "x" ]; then
    echo "Please enter the AWS_SECRET_ACCESS_KEY"
    read AWS_SECRET_ACCESS_KEY
fi

AWS_REGION=$(curl http://169.254.169.254/latest/meta-data/placement/region 2>/dev/null)
if [ "x$AWS_REGION" = "x" ]; then
    echo "Please enter the AWS_REGION"
    read AWS_REGION
else
    echo "Installing for $AWS_REGION region"
fi
echo "Install dir: $INSTALL_DIR"

sudo apt update
sudo apt install -y build-essential python3-django python3-pip libcurl4-openssl-dev libssl-dev libboost-all-dev python3-venv python-celery-common

sudo mkdir -p /opt/
sudo cp -apv worker/ $INSTALL_DIR

git clone https://github.com/danielsundfeld/astar_msa
cd astar_msa
make
sudo cp bin/msa_astar bin/msa_pastar /usr/bin/
cd ..
python3 -m pip install celery[sqs]

cat > $AWS_KEY_FILE <<EOL
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
AWS_REGION=$AWS_REGION
EOL

chmod 400 $AWS_KEY_FILE

sudo chown -R $INSTALL_USER:$INSTALL_GROUP $INSTALL_DIR

sudo cp ./deploy/pastar_web_worker.service /etc/systemd/system/
sudo systemctl start pastar_web_worker
sudo systemctl enable pastar_web_worker
