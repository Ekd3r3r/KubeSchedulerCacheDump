#!/bin/bash

# Function to check and install kubectl-node-shell if needed
check_and_install_node_shell() {
    if ! command -v kubectl-node_shell &> /dev/null; then
        echo "kubectl-node-shell is not installed. Installing..."
        curl -LO https://github.com/kvaps/kubectl-node-shell/raw/master/kubectl-node_shell
        chmod +x ./kubectl-node_shell
        sudo mv ./kubectl-node_shell /usr/local/bin/kubectl-node_shell
    fi
}

# Check and install kubectl-node-shell
check_and_install_node_shell


# Check if a kubeconfig path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <kubeConfigPath>"
    exit 1
fi

kubeconfig="$1"

# Get the pods running kube-scheduler
pods_info=$(KUBECONFIG="$kubeconfig" kubectl get pods -A -o wide | grep kube-scheduler)

# Loop through each pod info
while IFS= read -r line; do
    pod_name=$(echo "$line" | awk '{print $2}')
    namespace=$(echo "$line" | awk '{print $1}')
    node_name=$(echo "$line" | awk '{print $8}')

     # Get Scheduler PID and use it to send SIGUSR2 signal using node-shell
    KUBECONFIG="$kubeconfig" kubectl node-shell "$node_name" -- sh -c 'pid=$(pgrep kube-scheduler); echo "kube-scheduler PID: $pid"; sudo kill -SIGUSR2 $pid; echo "SIGUSR2 signal sent to kube-scheduler process to Dump the Scheduler Cache in Logs"'

    # Get kube-scheduler log
    log_output=$(KUBECONFIG="$kubeconfig" kubectl logs "$pod_name" -n "$namespace" | sed -n '/Dump of cached NodeInfo/,$p')

    echo "------------------------------------------------------------------------------------------------"
    echo "------------------------------------------------------------------------------------------------"
    echo "$log_output"
    echo "------------------------------------------------------------------------------------------------"
    echo "------------------------------------------------------------------------------------------------"

done <<< "$pods_info"
