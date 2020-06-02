# Jumpbox

It's a single docker container which contains all software utilities which I need on an instance to perform different daily tasks. Also, I have added an init scheme to manage some utilities which run as a process.

We have used **`supervisor`** as an init scheme for linux processes. So, we can run multiple processes in our container which will be administered by it. 

## Software utilities

**Init scheme:** `supervisor`
* jq
* yq
* zip
* unzip
* sqlcmd
* mysql-client
* kubectl
* helm
* az
* powershell
* azCopy
* mongodb
* git
* node
* docker
* docker-compose
