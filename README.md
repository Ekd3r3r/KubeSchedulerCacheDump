
**./scheduler_cachedump.sh**
Dumps the scheduler's cache given a KubeConfig file by opening a Node-Shell on the node with the kube-scheduler and sending SIGUSR2 signal to the kube-scheduler process

Usage:
./scheduler_cachedump.sh &lt;Path to KubeConfig file&gt;

**./scheduler_cachedump_kdebug.sh**
Dumps the scheduler's cache given a KubeConfig file by using kubectl debug and creating a ephemeral container with namespace access to kube-scheduler processes and sending SIGUSR2 signal to the kube-scheduler process

Usage:
./scheduler_cachedump_kdebug.sh &lt;Path to KubeConfig file&gt;
