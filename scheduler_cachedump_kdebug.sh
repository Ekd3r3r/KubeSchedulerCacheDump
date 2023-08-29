#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <Path to kubeconfig yaml file>"
    exit 1
fi

KubeConfigPath="$1"

# Get pods running the kube-scheduler
scheduler_pod_info=$(KUBECONFIG="$KubeConfigPath" kubectl get pods -A -o wide | grep kube-scheduler)

# Loop through each line of scheduler_pod_info
while IFS= read -r line; do
    scheduler_pod_name=$(echo "$line" | awk '{print $2}')
    scheduler_namespace=$(echo "$line" | awk '{print $1}')

    # Debug the kube-scheduler pod to send SIGUSR2 signal to dump the scheduler cache
    KUBECONFIG="$KubeConfigPath" kubectl debug -it "$scheduler_pod_name" --image=busybox:1.28 --target=kube-scheduler -n "$scheduler_namespace" -- /bin/sh -c 'pid=$(pgrep kube-scheduler); kill -SIGUSR2 $pid; echo "SIGUSR2 signal sent to kube-scheduler process to Dump the Scheduler Cache in Logs"'
   
    # Get logs after "Dump of cached NodeInfo"
    scheduler_logs=$(KUBECONFIG="$KubeConfigPath" kubectl logs "$scheduler_pod_name" -n "$scheduler_namespace" | sed -n '/Dump of cached NodeInfo/,$p')

    # Print the output
    echo "-----------------------------------------------------------------------------------------------------------------------------------------------------"
    echo "-----------------------------------------------------------------------------------------------------------------------------------------------------"
    echo "Logs from kube-scheduler pod: $scheduler_pod_name in namespace: $scheduler_namespace"
    echo "$scheduler_logs"
    echo "-----------------------------------------------------------------------------------------------------------------------------------------------------"
    echo "-----------------------------------------------------------------------------------------------------------------------------------------------------"
    
    # Break the loop if scheduler_logs is not empty
    if [ -n "$scheduler_logs" ]; then
        break
    fi

done <<< "$scheduler_pod_info"

