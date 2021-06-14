#!/bin/bash
INSTALL_DIR="/opt/pastar_web_worker"
AWS_KEY_FILE="$INSTALL_DIR/.aws_keys"

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

echo "Please enter the AWS_ACCESS_KEY"
read AWS_ACCESS_KEY_ID
echo "Please enter the AWS_SECRET_ACCESS_KEY"
read AWS_SECRET_ACCESS_KEY

AWS_REGION=$(curl http://169.254.169.254/latest/meta-data/placement/region 2>/dev/null)
echo "Installing for $AWS_REGION region"

cat > $AWS_KEY_FILE <<EOL
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
AWS_REGION=$AWS_REGION
EOL

chmod 400 $AWS_KEY_FILE

sudo cp ./deploy/pastar_web_worker.service /etc/systemd/system/
sudo systemctl start pastar_web_worker
sudo systemctl enable pastar_web_worker
