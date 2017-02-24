#!/bin/sh
docker-compose up --force-recreate -d
docker-compose logs -f
