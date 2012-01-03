#!/bin/sh
sh -e /etc/init.d/xvfb start
echo "echo \"127.0.0.1    test.example.com\" >> /etc/hosts" | sudo sh
sudo hostname test.example.com
