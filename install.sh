#!/bin/sh

sudo apt update
sudo apt install -y build-essential python3-django python3-pip libcurl4-openssl-dev libssl-dev libboost-all-dev python3-venv python-celery-common

git clone https://github.com/danielsundfeld/astar_msa
cd astar_msa
make
sudo cp bin/msa_astar bin/msa_pastar /usr/bin/
cd ../worker
python3 -m pip install celery[sqs]

sudo cp ../deploy/pastar_web_worker.service /etc/systemd/system/
sudo systemctl start pastar_web_worker
sudo systemctl enable pastar_web_worker

echo Now fixup -AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, CELERY_BROKER_TRANSPORT_OPTIONS
