#!/bin/bash

alias tmux="tmux -L wei"

session="WEI"

folder="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/.."

tmux new-session -d -s $session
tmux set -g mouse on

window=0
tmux rename-window -t $session:$window 'redis'
tmux send-keys -t $session:$window 'cd ' $folder C-m
# Start the redis server, or ping if it's already up
if [ "$(redis-cli ping)" != "PONG" ]; then
	tmux send-keys -t $session:$window 'envsubst < redis.conf | redis-server -' C-m
fi

window=1
tmux new-window -t $session:$window -n 'server'
tmux send-keys -t $session:$window 'cd ' $folder C-m
tmux send-keys -t $session:$window 'python3 -m wei.server --workcell ../example_workcell.yaml' C-m

window=2
tmux new-window -t $session:$window -n 'engine'
tmux send-keys -t $session:$window 'cd ' $folder C-m
# Uncomment the following for ROS support
# tmux send-keys -t $session:$window 'source ~/wei_ws/install/setup.bash' C-m
tmux send-keys -t $session:$window 'python3 -m wei.engine --workcell ../example_workcell.yaml' C-m

bash -c $folder/examples/run_example_nodes.sh

window=5
tmux new-window -t $session:$window -n 'diapora_'
tmux send-keys -t $session:$window 'cd ' $folder C-m
tmux send-keys -t $session:$window 'python3 examples/experiment_example.py'

tmux attach-session -t $session
