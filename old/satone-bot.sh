#!/bin/sh

NAME="[ SATONE BOT DAEMON ]"
PID="./satone-bot-daemon.pid"
SLACK_API_TOKEN=`cat satone-secrets.json | /usr/bin/python -c 'import json,sys;print(json.load(sys.stdin).get("slack_api_token"))'`
CMD="bundle exec ruby satone-bot.rb"

start()
{
    if [ -e $PID ]; then
        echo "$NAME already started"
        exit 1
    fi
    echo "$NAME START!"
    export SLACK_API_TOKEN=$SLACK_API_TOKEN
    $CMD
}

stop()
{
    if [ ! -e $PID ]; then
        echo "$NAME not started"
        exit 1
    fi
    echo "$NAME STOP!"
    kill -KILL `cat ${PID}`
    rm $PID
}

update_system()
{
    git checkout master
    git pull
    bundle install --path vendor/bundle
}

restart()
{
    stop
    sleep 2
    start
}

deploy()
{
    bundle exec ruby satone-cron.rb deploy_start_notifier develop
    stop
    sleep 2
    update_system
    sleep 2
    start
    bundle exec ruby satone-cron.rb deploy_finish_notifier develop
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    deploy)
        deploy
        ;;
    *)
        echo "Usage: ./satone-bot.sh [start|stop|restart|deploy]"
        ;;
esac
