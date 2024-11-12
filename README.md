# Google Cloud VM rolling restarter with stop start commands and some error handling
It can do a rolling restart on google cloud vm instances if given a line break separated vm name list. It can find project name, but the availability zone is fixed in the code. you need to make sure your copy of the script is runnable as a bash file. (chmod +x restarter.sh)
