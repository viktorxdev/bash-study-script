#!/bin/bash

DB_CONTAINER_NAME="spring-postgres"
projectDir="$(pwd)/spring-starter"


help() {
  echo "
  Usage:
    ./test-app init - init working directory and database
    ./test-app clean - clean working directory and stop database
    ./test-app build - run JUnit tests to check app health (-skipTests arg to skip tests) and build jar
    ./test-app up - launch application
  "
}

init() {
  echo "Project directory is ${projectDir}"
# git clone
  if [[ ! -d "spring-starter" ]]; then
      git clone git@github.com:dmdev2020/spring-starter.git
  fi
  cd "spring-starter" || exit 1
  git checkout lesson-125

# Postgres init
  docker pull postgres
  if docker ps -a | grep "${DB_CONTAINER_NAME}"; then
    docker start "${DB_CONTAINER_NAME}"
  else
    docker run --name "${DB_CONTAINER_NAME}" \
        -e POSTGRES_PASSWORD=pass \
        -e POSTGRES_USER=postgres \
        -e POSTGRES_DB=postgres \
        -p 5433:5432 \
        -d postgres
  fi
}

clean() {
# remove project directory
  echo "Removing project directory ${projectDir}..."
  rm -rf "${projectDir}"
# stop docker container Postgres
  if docker ps | grep "${DB_CONTAINER_NAME}"; then
    echo "Stopping postgres container ${DB_CONTAINER_NAME}"
    docker stop "${DB_CONTAINER_NAME}"
  fi
}

build() {
  cd "${projectDir}" || exit 1
  ./gradlew clean

  if [[ "$1" == "-skipTests" ]] || ./gradlew test; then
    echo "Application is building..."
    ./gradlew bootJar
  else
    echo "Tests failed. Fix test or use -skipTests arg"
    exit 1
  fi
}

up() {
  cd "${projectDir}/build/libs" || exit 1
  java -jar spring-starter-*.jar
}

case $1 in
help)
  help
  ;;
"")
  help
  ;;
init)
  init
  ;;
clean)
  clean
  ;;
build)
  build "$2"
  ;;
up)
  up
  ;;
*)
  echo "$1 command is not valid"
  exit 1
esac
