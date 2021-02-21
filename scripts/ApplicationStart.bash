#!/bin/bash -e

cd /opt/app/stock_container
sudo systemctl start docker

sudo git pull
sudo docker-compose restart
