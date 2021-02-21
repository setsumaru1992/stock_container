#!/bin/bash -e

cd /opt/app/fortune_calculator
sudo systemctl start docker

sudo git pull
sudo docker-compose restart
