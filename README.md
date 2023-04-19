# CS 2340 Project
Creators
* Jichuan 
* Gueren
* Aaryan

## Possible Algorithm Idea
### Stage 1
Create list of available boxes with three or more lines open. We randomly choose from these boxes until there is one box left. When there is one left, we compare the chains that could be formed when one of these lines is chosen. If choosing that line results in no chain being formed, choose it. Otherwise, choose the chain with the smallest number of boxes.

### Stage 2
All the boxes have a max of two options now, which means choosing one of these lines results in a box forming somwhere. So we compare the clusters available, chooose the smaller cluster to make a move in. For example if there is a cluster of 1 box, fill out the box and then move to the next one. If the next cluster is of 2, then put the line in the middle so the opponent has to fill it in. This forces them to make a move on one of the bigger clusters, setting us up to fill out the entire chain. However, when chains/clusters are greater than 3, fill out everything but the last 2 boxes of the chain. This allows us to be the one to make a move on the next chain.
ignore im just keeping some stuuf b4 pull
