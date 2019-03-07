#!/bin/bash

web_home=/home/myuser/data/web/$1

cd ${web_home}

git pull

npm install

npm run deploy-dev