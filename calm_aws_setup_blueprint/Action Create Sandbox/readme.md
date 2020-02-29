# Variables for the Create Sandbox action

  |Name        |Runtime  |Data Type   |Input Type  |Default Value|Label       |Description |Secret    |Private  |Mandatory |Regex     |
  |------------|:-------:|------------|------------|-------------|------------|------------|:--------:|:-------:|:--------:|          |
  |project_name|Yes |String   |Simple      |project_name|Project Name|Define a unique project name. This project name will be used as a prefix for all necessary objects within AWS and Prism Central|No|No|Yes|^[a-zA-Z0-9\_]+$|
  |aws_access_key_id|Yes|String|Simple|aws_access_key_id|AWS Access Key ID|Enter your AWS Access Key ID. The user need the following permissions: AmazonEC2FullAccess, AmazonVPCFullAccess, IAMFullAccess|No|No|Yes||
  |aws_secret_access_key|Yes|String|Simple|aws_secret_access_key|AWS Secret Access Key|Enter the AWS Secret Access Key corresponding to the previously entered AWS Access Key ID|Yes|No|Yes||
  |region     |Yes|String|Predefined|eu-west-2us-west-1,ap-southeast-1|AWS Region|Select the region where you would like to create an image. Default is West Europe 2|No|No|Yes||
  |cidr       |Yes|String|Simple|10.0.0.0/16|VPC CIDR|CIDR for the AWS VCP. |No|No|Yes|^([0-9]{1,3}\.){3}[0-9]{1,3}($|/(16|24))$|
  |subnet     |Yes|String|Simple|10.0.10.0/24|AWS Subnet|This will be the subnet assigning IPs to your VMs in your sandbox. The subnet must fit inside the CIDR|No|No|Yes|^([0-9]{1,3}\.){3}[0-9]{1,3}($|/(16|24))$|
  |ami_id     |Yes|String|eScript|View script|CentOS image ID|This field defaults to the AWS Marketplace Centos 7 x86-64. It is retrieve automatically based on region selected. The image will be used to create a new image for your sandbox|No|No|No||
  |instance_type|Yes|String|Simple|t2.micro|Instance used to create the image for your sandbox|No|Yes|Yes||
  |tcp_ports  |Yes|String|Simple|22,80,443,53|TCP Ports|This is the list of TCP ports that will be open on the AWS security group to allow access to the internet from the instance, allowing to update and install packages|No|No|Yes|^[0-9]+(,[0-9]+)*$|
  |udp_ports  |Yes|String|Simple|53|UDP Ports|This is the list of UDP ports that will be open on the AWS security group to allow access to the internet from the instance, allowing to update and install packages|No|No|Yes|^[0-9]+(,[0-9]+)*$|
  |pc_user    |Yes|String|Simple|pc_user|Prism Central Username|Enter the username of a Prism Central administrator. These credentials will be used to create an AWS account in Prism Central for your sandbox|No|No|Yes||
  |pc_password|Yes|String|Simple|pc_password||Prism Central Password|Enter the password of a Prism Central administrator. These credentials will be used to create an AWS account in Prism Central for your sandbox|Yes|No|Yes||

## ami_id script
```import boto3


ec2 = boto3.client(
    'ec2',
    region_name="@@{region}@@",
    aws_access_key_id="@@{aws_cred.username}@@",
    aws_secret_access_key="@@{aws_cred.secret}@@",
)

response = ec2.describe_images(
    Owners=[
        'aws-marketplace'
        ],
        Filters=[
            {
                'Name': 'product-code',
                'Values': [
                    'aw0evgkw8e5c1q413zgy5pjce'
                    ]
                }
            ]
        )

images = []
for ami in response['Images']:
    images.append([ami['ImageId'],ami['CreationDate'],ami['Architecture']])

imgs = sorted(images,key=lambda x:x[1])
# for img in imgs:
print((imgs[-1])[0])```
