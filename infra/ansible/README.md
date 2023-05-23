# Run


```
IP=$(gcloud --format="value(networkInterfaces[0].accessConfigs[0].natIP)" compute instances list --filter="name~'edge'")
ansible-playbook -i ${IP}, sites.yaml --extra-vars @secrets.yaml
```
