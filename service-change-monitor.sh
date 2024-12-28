#!/bin/bash

SERVICE_FILE="k8s/service.yaml"
LOG_FILE="service-switch.log"

echo "Starting service monitor..." | tee -a $LOG_FILE

inotifywait -m -e modify,attrib,close_write,move,create,delete $SERVICE_FILE |
while read -r directory events filename; do
    echo "$(date): Service file change detected" | tee -a $LOG_FILE
    
    # Wait for kubectl apply to complete
    sleep 2
    
    # Kill existing port-forward
    echo "Terminating existing port-forward..." | tee -a $LOG_FILE
    pkill -f "kubectl port-forward service/node-app-service"
    
    sleep 2
    
    # Start new port-forward
    echo "Starting new port-forward..." | tee -a $LOG_FILE
    kubectl port-forward service/node-app-service 3000:3000 &
    
    sleep 3
    
    # Verify connection
    echo "Verifying connection..." | tee -a $LOG_FILE
    curl http://localhost:30000
done