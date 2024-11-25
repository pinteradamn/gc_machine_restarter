#!/bin/bash

# Hardcoded zone
ZONE="us-central1-c"

# Input file containing VM names
INPUT_FILE="list"

# Array to keep track of not found VMs and successfully processed VMs
not_found_vms=()
successfully_processed_vms=()

# Color definitions
RED='\033[0;31m'   # Red color for errors
GREEN='\033[0;32m' # Green color for success messages
NC='\033[0m'       # No Color

echo "Getting dummy vm description to force cli auth without skipping the first vm in file"
echo "The following error should be ignored!"
#Dummy describe to force the shell to authorise without skipping the first vm in file. It will throw an error because the zone does not exist but no worries
gcloud compute instances describe dummy --zone=dummy --format='get(selfLink)'

# Loop through each VM name in the input file
while read -r VM_NAME; do
  if [ -n "$VM_NAME" ]; then
    # Get the project ID from the VM description
    PROJECT_ID=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format='get(selfLink)' | grep -oP '(?<=projects/)[^/]+')

    # Check if project ID was found
    if [ -z "$PROJECT_ID" ]; then
      printf "${RED}Failed to get project ID for VM: $VM_NAME${NC}\n"
      not_found_vms+=("$VM_NAME") # Add to not found list
      continue
    fi

    # Stop the VM
    echo "Stopping VM: $VM_NAME in project $PROJECT_ID"
    gcloud compute instances stop "$VM_NAME" --project="$PROJECT_ID" --zone="$ZONE"
    
    # Wait for the VM to stop
    echo "Waiting for VM $VM_NAME to stop..."
    while true; do
      STATUS=$(gcloud compute instances describe "$VM_NAME" --project="$PROJECT_ID" --zone="$ZONE" --format='get(status)')
      if [[ "$STATUS" == "TERMINATED" ]]; then
        break
      fi
      sleep 2
    done

    # Start the VM
    echo "Starting VM: $VM_NAME in project $PROJECT_ID"
    gcloud compute instances start "$VM_NAME" --project="$PROJECT_ID" --zone="$ZONE"
    
    # Wait for the VM to start
    echo "Waiting for VM $VM_NAME to start..."
    while true; do
      STATUS=$(gcloud compute instances describe "$VM_NAME" --project="$PROJECT_ID" --zone="$ZONE" --format='get(status)')
      if [[ "$STATUS" == "RUNNING" ]]; then
        break
      fi
      sleep 2
    done

    printf "${GREEN}Successfully processed VM:\n $VM_NAME${NC}\n"
    successfully_processed_vms+=("$VM_NAME") # Add to successfully processed list
  else
    printf "End of file.\n"
  fi
done < "$INPUT_FILE"

# Print the VMs that were not found
if [ ${#not_found_vms[@]} -gt 0 ]; then
  printf "${RED}The following VMs were not found or could not be processed:${NC}\n"
  for vm in "${not_found_vms[@]}"; do
    echo "$vm"
  done
else
  printf "${GREEN}All VMs processed successfully.${NC}\n"
fi

# Print the VMs that were successfully processed
if [ ${#successfully_processed_vms[@]} -gt 0 ]; then
  printf "${GREEN}The following VMs were successfully restarted:${NC}\n"
  for vm in "${successfully_processed_vms[@]}"; do
    echo "$vm"
  done
fi
