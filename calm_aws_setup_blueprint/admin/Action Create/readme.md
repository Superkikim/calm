Variables for the admin service Create action

|Name|Value|Type|Secret|Runtime|Description|
|---|---|---|:---:|:---:|---|
|ssh_key|[SSH Public key]|string|False|True|SSH key for the admin service user|
|sshgroup|sshusers|string|False|False|Allowed users will be added to the group|
|rootpassword|[Password for root]|string|True|True|Will be set as root password in the admin service|
|pc_ip|[Prism Central IP]|string|False|False|IP address for Prism Central, autopopulated|
|public_ip|[Public IP]|string|False|False|Public IP of the gateway from admin service to Internet|
