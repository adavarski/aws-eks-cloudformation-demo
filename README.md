## AWS Cloudformation EKS: demo/examples

This is an example project to deploy and provisione an aws infrastructure using cloudformation and kubernetes (EKS) for development environments.

Note1: This project is only for development environments creation. 

Note2: For production use repo: https://github.com/adavarski/aws-eks-production, because HashiCorp Terraform is better than AWS Cloudformation for AWS EKS setup/configuration/update/etc., (better state management & modularization & etc). If something goes wrong when using "aws cloudformation delete-stack/create-stack/update-stack ..." (exampe: DELETE_FAILED/CREATE_FAILED), we have to manually delete/fix resources via AWS console, which is very RISKY for production environments!

---

### Requirementes

- aws user
- aws console
- kubectl 

### First steps

In order to use the provisioning scripts you will need to configure an aws user with priveleges to manage vpc, eks, ec2, you can follow this guide to configure the user: [aws user configuration guide](https://github.com/adavarski/aws-eks-cloudformation-demo/tree/main/images/aws-user)

If you have already configured an aws user you have to insert the **Access Key ID** and **Secret Access Key** values it in the aws console using the following command:

`aws configure`

and check awscli configuration:

```
$ cat ~/.aws/config 
[default]
region = eu-central-1

$ cat ~/.aws/credentials 
[default]
aws_access_key_id = XXXXXXXX
aws_secret_access_key = YYYYYYYY

```

## Example1: 2-public subnets 

### Deploying the infrastructure

In order to deploy your infrastructure execute the following script inside the **cloudformation/** folder:

NOTE: **You can deploy on any region so you could replace the value eu-central-1**
```
    sh ./create.sh workshop-devops network_and_eks.yml network_and_eks.json eu-central-1
```
Note: The creation of EKS cluster takes almost 10 minutes

```
$ while aws cloudformation describe-stacks --stack-name workshop-devops | grep StackStatus.*CREATE_IN_PROGRESS 1> /dev/null; do sleep 1; echo "Waiting for workshop-devops stack creation to complete...";done
$ aws cloudformation describe-stacks --stack-name workshop-devops | grep StackStatus.*CREATE_COMPLETE
            "StackStatus": "CREATE_COMPLETE",

```
After the EKS cluster creation is success you can add EKS context in your machine with following command:
```
    export KUBECONFIG=./workshop-devops-k8s-config
    aws --region eu-central-1 eks update-kubeconfig --name DevOps-NonProd
    cat ./workshop-devops-k8s-config
```
In order to check your cluster you can use the following command:
```
$ kubectl cluster-info
Kubernetes master is running at https://CD33CEF669519FAB78DC22AA0D562590.gr7.eu-central-1.eks.amazonaws.com
CoreDNS is running at https://CD33CEF669519FAB78DC22AA0D562590.gr7.eu-central-1.eks.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
$ kubectl get nodes -o wide
NAME                                          STATUS   ROLES    AGE   VERSION              INTERNAL-IP   EXTERNAL-IP     OS-IMAGE         KERNEL-VERSION                CONTAINER-RUNTIME
ip-10-0-0-147.eu-central-1.compute.internal   Ready    <none>   23m   v1.20.4-eks-6b7464   10.0.0.147    18.192.49.110   Amazon Linux 2   5.4.129-63.229.amzn2.x86_64   docker://19.3.13
ip-10-0-1-189.eu-central-1.compute.internal   Ready    <none>   23m   v1.20.4-eks-6b7464   10.0.1.189    35.158.118.12   Amazon Linux 2   5.4.129-63.229.amzn2.x86_64   docker://19.3.13
$ kubectl get all --all-namespaces
NAMESPACE     NAME                          READY   STATUS    RESTARTS   AGE
kube-system   pod/aws-node-llpgj            1/1     Running   0          23m
kube-system   pod/aws-node-mlwlq            1/1     Running   0          23m
kube-system   pod/coredns-85cc4f6d5-9zg2r   1/1     Running   0          27m
kube-system   pod/coredns-85cc4f6d5-c9pqv   1/1     Running   0          27m
kube-system   pod/kube-proxy-pczrr          1/1     Running   0          23m
kube-system   pod/kube-proxy-psv9w          1/1     Running   0          23m

NAMESPACE     NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE
default       service/kubernetes   ClusterIP   172.20.0.1    <none>        443/TCP         28m
kube-system   service/kube-dns     ClusterIP   172.20.0.10   <none>        53/UDP,53/TCP   28m

NAMESPACE     NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
kube-system   daemonset.apps/aws-node     2         2         2       2            2           <none>          28m
kube-system   daemonset.apps/kube-proxy   2         2         2       2            2           <none>          28m

NAMESPACE     NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
kube-system   deployment.apps/coredns   2/2     2            2           28m

NAMESPACE     NAME                                DESIRED   CURRENT   READY   AGE
kube-system   replicaset.apps/coredns-85cc4f6d5   2         2         2       28m
```
Screenshots:

- Stacks
<img src="https://github.com/adavarski/aws-eks-cloudformation-demo/blob/main/images/eks-cluster-example1/CF-stacks.png?raw=true" width="900">
 
- Clusters:  
<img src="https://github.com/adavarski/aws-eks-cloudformation-demo/blob/main/images/eks-cluster-example1/AWS-EKS-Clusters.png?raw=true" width="900">
- Cluster Overview:   
<img src="https://github.com/adavarski/aws-eks-cloudformation-demo/blob/main/images/eks-cluster-example1/AWS-EKS-Cluster-Overview.png?raw=true" width="900">
- Cluster Details:   
<img src="https://github.com/adavarski/aws-eks-cloudformation-demo/blob/main/images/eks-cluster-example1/AWS-EKS-Cluster-Configuration-Details.png?raw=true" width="900">
- Cluster:Configuration:Node Group:   
<img src="https://github.com/adavarski/aws-eks-cloudformation-demo/blob/main/images/eks-cluster-example1/AWS-EKS-Cluster-Configuration-Node_Group-Details.png?raw=true" width="900">
- Cluster Workloads:   
<img src="https://github.com/adavarski/aws-eks-cloudformation-demo/blob/main/images/eks-cluster-example1/AWS-EKS-Cluster-Workloads.png?raw=true" width="900">

### Provisioning Kubernetes

Create/Test docker images and push to DockerHub:

Exampe output:

```
$ docker build --tag davarski/basic_example:0.0.1 -f Dockerfile  .
$ docker run -ti --rm -p 5000:5000 davarski/basic_example:0.0.1
 * Serving Flask app 'app' (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: on
 * Running on all addresses.
   WARNING: This is a development server. Do not use it in a production deployment.
 * Running on http://10.30.0.2:5000/ (Press CTRL+C to quit)
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 734-016-872
$ curl http://10.30.0.2:5000/
{
  "biography": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur ac leo vehicula, tempus felis quis, sollicitudin felis. Donec vel erat mauris. Nulla facilisi. Aenean ac est eget ipsum pretium convallis quis vulputate nisl. Integer viverra neque quis elit pellentesque, viverra congue leo porta. Praesent elit justo, tempor sit amet varius ac,feugiat sed nibh. Nam sit amet semper nisi, vitae hendrerit erat. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Duis ultricies lorem libero, vel condimentum neque aliquam vel. Integer non odio nisi. Sed nec orci purus.", 
  "date": "Fri, 27 Aug 2021 09:27:28 GMT", 
  "email": "lorem.ipsum+34@email.com", 
  "id": "fefa772c-0718-11ec-80eb-02420a1e0002", 
  "telephone": "+593 151 704 177", 
  "username": "The user 34", 
  "version": "0.0.1", 
  "x_request_id": "fefa7a7e-0718-11ec-80eb-02420a1e0002"
} 

$ docker login
$ docker push davarski/basic_example:0.0.1

$ vi app.py (change 0.0.1 --> 0.0.2)
$ docker build --tag davarski/basic_example:0.0.2 -f Dockerfile  .

$ docker run -ti --rm -p 5000:5000 davarski/basic_example:0.0.2
 * Serving Flask app 'app' (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: on
 * Running on all addresses.
   WARNING: This is a development server. Do not use it in a production deployment.
 * Running on http://10.30.0.2:5000/ (Press CTRL+C to quit)
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 253-814-654
[2021-08-27 09:28:57,194] INFO in app: Get call on /
10.30.0.1 - - [27/Aug/2021 09:28:57] "GET / HTTP/1.1" 200 -

$ curl http://10.30.0.2:5000/
{
  "biography": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur ac leo vehicula, tempus felis quis, sollicitudin felis. Donec vel erat mauris. Nulla facilisi. Aenean ac est eget ipsum pretium convallis quis vulputate nisl. Integer viverra neque quis elit pellentesque, viverra congue leo porta. Praesent elit justo, tempor sit amet varius ac,feugiat sed nibh. Nam sit amet semper nisi, vitae hendrerit erat. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Duis ultricies lorem libero, vel condimentum neque aliquam vel. Integer non odio nisi. Sed nec orci purus.", 
  "date": "Fri, 27 Aug 2021 09:28:57 GMT", 
  "email": "lorem.ipsum+33@email.com", 
  "id": "34235266-0719-11ec-8daa-02420a1e0002", 
  "telephone": "+593 272 451 265", 
  "username": "The user 33", 
  "version": "0.0.2", 
  "x_request_id": "342355fe-0719-11ec-8daa-02420a1e0002"
}
$ docker push davarski/basic_example:0.0.2

```

Execute the following commands:

1. Install HAProxy Ingress Controller

   `kubectl apply -f ../k8s/1_haproxy-ingress.yaml`

2. Install deployment of app v1

   `kubectl apply -f ../k8s/2_app-v1.yaml`

3. Install the service

   `kubectl apply -f ../k8s/3_service.yaml`

4. Install the ingress

   `kubectl apply -f ../k8s/4_ingress.yaml`

5. Expose ingress controller with a load balancer service

   `sh ../k8s/5_expose_url_with_load_balancer.sh`

   Then you can know the **EXTERNAL-IP** and check the application deployed in your browser with the path `/`

Exampe output:
```

$ kubectl apply -f ../k8s/1_haproxy-ingress.yaml
namespace/haproxy-controller created
serviceaccount/haproxy-ingress-service-account created
clusterrole.rbac.authorization.k8s.io/haproxy-ingress-cluster-role created
clusterrolebinding.rbac.authorization.k8s.io/haproxy-ingress-cluster-role-binding created
configmap/haproxy created
deployment.apps/ingress-default-backend created
service/ingress-default-backend created
deployment.apps/haproxy-ingress created
service/haproxy-ingress created

$ kubectl apply -f ../k8s/2_app-v1.yaml
deployment.apps/app-version-1 created

$ kubectl apply -f ../k8s/3_service.yaml
service/app-service created

$ kubectl apply -f ../k8s/4_ingress.yaml
ingress.networking.k8s.io/app-ingress created

$ sh ../k8s/5_expose_url_with_load_balancer.sh
service/haproxy-ingress-lb-public exposed
NAME                        TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                                     AGE
haproxy-ingress-lb-public   LoadBalancer   172.20.183.165   <pending>     80:30514/TCP,443:31398/TCP,1024:31742/TCP   1s


 **** If EXTERNAL-IP is <pending> execute in your terminal -> 'kubectl get services/haproxy-ingress-lb-public -n haproxy-controller' ****
$ kubectl get services/haproxy-ingress-lb-public -n haproxy-controller
NAME                        TYPE           CLUSTER-IP       EXTERNAL-IP                                                                 PORT(S)                                     AGE
haproxy-ingress-lb-public   LoadBalancer   172.20.183.165   a0eae7b86e57b44ab9721c21a2096ed6-602491023.eu-central-1.elb.amazonaws.com   80:30514/TCP,443:31398/TCP,1024:31742/TCP   38s

$ curl http://a0eae7b86e57b44ab9721c21a2096ed6-602491023.eu-central-1.elb.amazonaws.com
{
  "email": "lorem.ipsum+66@email.com", 
  "id": "cdbfdbd4-072c-11ec-aaa6-f2dc8e69da8e", 
  "username": "The user 66", 
  "version": "0.0.1"
}

$ kubectl get all
NAME                                 READY   STATUS    RESTARTS   AGE
pod/app-version-1-7b6478bfdd-pqrq8   1/1     Running   0          8m25s
pod/app-version-2-5bd87857c4-m79lm   1/1     Running   0          86s

NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/app-service   NodePort    172.20.61.202   <none>        80:32096/TCP   7m10s
service/kubernetes    ClusterIP   172.20.0.1      <none>        443/TCP        38m

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/app-version-1   1/1     1            1           8m25s
deployment.apps/app-version-2   1/1     1            1           86s

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/app-version-1-7b6478bfdd   1         1         1       8m25s
replicaset.apps/app-version-2-5bd87857c4   1         1         1       86s

$ kubectl get ing
NAME          CLASS    HOSTS   ADDRESS   PORTS   AGE
app-ingress   <none>   *                 80      5s

$ kubectl get all --all-namespaces
NAMESPACE            NAME                                           READY   STATUS    RESTARTS   AGE
default              pod/app-version-1-7b6478bfdd-pqrq8             1/1     Running   0          25s
haproxy-controller   pod/haproxy-ingress-67f7c8b555-69hqn           1/1     Running   0          77s
haproxy-controller   pod/ingress-default-backend-78f5cc7d4c-8r6vp   1/1     Running   0          77s
kube-system          pod/aws-node-llpgj                             1/1     Running   0          26m
kube-system          pod/aws-node-mlwlq                             1/1     Running   0          26m
kube-system          pod/coredns-85cc4f6d5-9zg2r                    1/1     Running   0          30m
kube-system          pod/coredns-85cc4f6d5-c9pqv                    1/1     Running   0          30m
kube-system          pod/kube-proxy-pczrr                           1/1     Running   0          26m
kube-system          pod/kube-proxy-psv9w                           1/1     Running   0          26m

NAMESPACE            NAME                              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                     AGE
default              service/kubernetes                ClusterIP   172.20.0.1       <none>        443/TCP                                     30m
haproxy-controller   service/haproxy-ingress           NodePort    172.20.178.187   <none>        80:31865/TCP,443:32507/TCP,1024:31786/TCP   77s
haproxy-controller   service/ingress-default-backend   ClusterIP   172.20.199.163   <none>        8080/TCP                                    77s
kube-system          service/kube-dns                  ClusterIP   172.20.0.10      <none>        53/UDP,53/TCP                               30m

NAMESPACE     NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
kube-system   daemonset.apps/aws-node     2         2         2       2            2           <none>          30m
kube-system   daemonset.apps/kube-proxy   2         2         2       2            2           <none>          30m

NAMESPACE            NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
default              deployment.apps/app-version-1             1/1     1            1           25s
haproxy-controller   deployment.apps/haproxy-ingress           1/1     1            1           77s
haproxy-controller   deployment.apps/ingress-default-backend   1/1     1            1           77s
kube-system          deployment.apps/coredns                   2/2     2            2           30m

NAMESPACE            NAME                                                 DESIRED   CURRENT   READY   AGE
default              replicaset.apps/app-version-1-7b6478bfdd             1         1         1       25s
haproxy-controller   replicaset.apps/haproxy-ingress-67f7c8b555           1         1         1       77s
haproxy-controller   replicaset.apps/ingress-default-backend-78f5cc7d4c   1         1         1       77s
kube-system          replicaset.apps/coredns-85cc4f6d5                    2         2         2       30m

$ kubectl apply -f ../k8s/6_app-v2.yaml
deployment.apps/app-version-2 created

$ kubectl get all
NAME                                 READY   STATUS    RESTARTS   AGE
pod/app-version-1-7b6478bfdd-pqrq8   1/1     Running   0          8m25s
pod/app-version-2-5bd87857c4-m79lm   1/1     Running   0          86s

NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/app-service   NodePort    172.20.61.202   <none>        80:32096/TCP   7m10s
service/kubernetes    ClusterIP   172.20.0.1      <none>        443/TCP        38m

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/app-version-1   1/1     1            1           8m25s
deployment.apps/app-version-2   1/1     1            1           86s

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/app-version-1-7b6478bfdd   1         1         1       8m25s
replicaset.apps/app-version-2-5bd87857c4   1         1         1       86s

```

### Next steps

- Configure your pipeline
- Deploy [Kubernetes Add-ons/YAML templates](https://github.com/adavarski/aws-eks-cloudformation-demo/tree/main/k8s_templates)


### Upgrade EKS k8s (1.20->1.21 for example: network_and_eks.json)

```
 sh ./upgrade.sh workshop-devops network_and_eks.yml network_and_eks.json eu-central-1
```

### Upgrade EKS k8s Add-ons/YAML template


Kubernetes Add-ons/YAML templates
All the templates for additional deployments/daemonsets can be found in [k8s_templates](https://github.com/adavarski/aws-eks-cloudformation-demo/tree/main/k8s_templates).

Note1: To apply templates simply run kubectl apply -f . from a desired folder. Ensure to put in correct Role arn in service accounts configuration. Also, check that environment variables are correct.
Note2: Setup versions regarding k8s versions (1.20/1.21/etc.)

You will find templates for the following Kubernetes components:

ALB ingress controller
AWS Load Balancer controller
AWS node termination handler
Calico
Cert Manager
Cluster Autoscaler
CoreDns
Dashboard
External-DNS
External Secrets
Kube Proxy
Kube2iam
Metrics server
NewRelic
Reloader
Spot Interrupt Handler
VPC CNI Plugin
Secrets CSI Driver


### Remove/Clean the infrastructure:

   `sh ./destroy.sh workshop-devops  eu-central-1`
   
   
 Note: If stack delete is failed delete all failed resources manually (Detach IGW/Release ALL Elastic IPs/Delete LB/Delete ENIs/Delete Security Groups/Delete VPC/etc.) using console and run above command again untill "DELETE_COMPLETE"
 
 Example errors:
 ```
2021-08-27 15:11:24 UTC+0300	InternetGatewayAttachment	DELETE_FAILED	Network vpc-08dd6641dd2fc9d98 has some mapped public address(es). Please unmap those public address(es) before detaching the gateway. (Service: AmazonEC2; Status Code: 400; Error Code: DependencyViolation; Request ID: de55ec3b-8a14-47a7-ba85-1367aa87f566; Proxy: null)
 
2021-08-27 15:23:04 UTC+0300	PublicSubnet1	DELETE_FAILED	The subnet 'subnet-02d288776f1c5df6d' has dependencies and cannot be deleted. (Service: AmazonEC2; Status Code: 400; Error Code: DependencyViolation; Request ID: 6e638823-e0bd-4f9e-807f-511ebf8e83bc; Proxy: null)
2021-08-27 15:22:19 UTC+0300	PublicSubnet2	DELETE_FAILED	The subnet 'subnet-0051cb9cb99fc4da2' has dependencies and cannot be deleted. (Service: AmazonEC2; Status Code: 400; Error Code: DependencyViolation; Request ID: 0d280f43-35a0-40be-8c6e-6a4fd8709193; Proxy: null)
2021-08-27 15:11:24 UTC+0300	InternetGatewayAttachment	DELETE_FAILED	Network vpc-08dd6641dd2fc9d98 has some mapped public address(es). Please unmap those public address(es) before detaching the gateway. (Service: AmazonEC2; Status Code: 400; Error Code: DependencyViolation; Request ID: de55ec3b-8a14-47a7-ba85-1367aa87f566; Proxy: null)
2021-08-27 15:31:15 UTC+0300	InternetGateway	DELETE_FAILED	The internetGateway 'igw-0d21f5a84f1bfaac9' has dependencies and cannot be deleted. (Service: AmazonEC2; Status Code: 400; Error Code: DependencyViolation; Request ID: 66750714-46bf-4fc7-9fc1-1d0498144e7d; Proxy: null)
 ```
(Optional): use cloud-nuke for some resource deletion
```
$ wget https://github.com/gruntwork-io/cloud-nuke/releases/download/v0.5.0/cloud-nuke_linux_amd64
$ chmod 755 cloud-nuke_linux_amd64
$ ./cloud-nuke_linux_amd64 aws --list-resource-types
$ ./cloud-nuke_linux_amd64 aws --resource-type ec2
```
 check all resources:
 ```
 aws cloudformation list-stacks 
 aws resourcegroupstaggingapi get-resources --region eu-central-1
```
Example output:
```
$ aws cloudformation list-stacks 
{
    "StackSummaries": [
        {
            "StackId": "arn:aws:cloudformation:eu-central-1:218645542363:stack/workshop-devops/6e26c8f0-0726-11ec-99f8-0a0e3394becc",
            "StackName": "workshop-devops",
            "TemplateDescription": "Anastas Davarski / Cloud DevOps AWS EKS demo workshop\n",
            "CreationTime": "2021-08-27T11:03:38.101Z",
            "DeletionTime": "2021-08-27T12:55:32.929Z",
            "StackStatus": "DELETE_COMPLETE",
            "DriftInformation": {
                "StackDriftStatus": "NOT_CHECKED"
            }
    ]
}       
```

## Example2: 2-public & 2-private subnets + bastion host

Minimal working setup for AWS EKS (Amazon Elastic Kubernetes Service) using AWS CF (Amazon CloudFormation)

```

### Bastion host
$ aws ssm get-parameters-by-path --path /aws/service/ami-amazon-linux-latest --query "Parameters[].Value"
$ aws ssm get-parameters-by-path --path /aws/service/ami-amazon-linux-latest --query "Parameters[].Name"

Note: For bastion host use: Amazon Linux 2 AMI (HVM), SSD Volume Type - ami-0453cb7b5f2b7fca2 (64-bit x86) region = eu-central-1

### Retrieving Amazon EKS optimized Amazon Linux AMI IDs (for different k8s versions)

$ aws ssm get-parameters --names /aws/service/eks/optimized-ami/1.14/amazon-linux-2/recommended
$ aws ssm get-parameters --names /aws/service/eks/optimized-ami/1.20/amazon-linux-2/recommended
$ aws ssm get-parameters --names /aws/service/eks/optimized-ami/1.21/amazon-linux-2/recommended

### Create S3:eks-min-demo bucket

$ aws s3api create-bucket --bucket eks-min-demo --region eu-central-1 --create-bucket-configuration LocationConstraint=eu-central-1
{
    "Location": "http://eks-min-demo.s3.amazonaws.com/"
}

$ aws s3api list-buckets --query "Buckets[].Name"
[
    "eks-min-demo"
]

### Create ec2 key-pair (for bastion host)
$ aws ec2 --profile default create-key-pair --region eu-central-1 --key-name demo-aks --query 'KeyMaterial' --output text > demo-aks.pem
$ cat demo-aks.pem 

### Deploy stack

$ ./deploy-eks-min.sh -bn eks-min-demo -bu https://eks-min-demo.s3.eu-central-1.amazonaws.com
Successfully uploaded eks-min.yaml file to S3 bucket
Successfully initialized eks-min stack creation
Waiting for eks-min stack creation to complete...
Waiting for eks-min stack creation to complete...
...

Note1: Setup bastion host AMI and k8s version (1.20/1.21)
Note2: If CREATE_FAILED make request for resource limits increase for region (@Support Center)

Example limit issue:

2021-08-27 13:31:48 UTC+0300	PrivateSubnet1NatGatewayEIP	CREATE_FAILED	The maximum number of addresses has been reached. (Service: AmazonEC2; Status Code: 400; Error Code: AddressLimitExceeded; Request ID: 7b4f19cd-66f1-4946-af46-ca9c026b5f00; Proxy: null)
2021-08-27 13:31:48 UTC+0300	BastionHostSshPortAddress	CREATE_FAILED	The maximum number of addresses has been reached. (Service: AmazonEC2; Status Code: 400; Error Code: AddressLimitExceeded; Request ID: 24549375-3bdd-4745-81ab-59c84f26e0d0; Proxy: null)
2021-08-27 13:31:48 UTC+0300	PrivateSubnet2NatGatewayEIP	CREATE_FAILED	The maximum number of addresses has been reached. (Service: AmazonEC2; Status Code: 400; Error Code: AddressLimitExceeded; Request ID: ceacfc58-4a2e-4a35-8253-f79bff25646c; Proxy: null)

### Upgrade k8s infrastructure (1.20->1.21)

$ diff eks-min_1.20.yaml eks-min_1.21.yaml
25c25
<     Default: /aws/service/eks/optimized-ami/1.20/amazon-linux-2/recommended/image_id
---
>     Default: /aws/service/eks/optimized-ami/1.21/amazon-linux-2/recommended/image_id
45c45
<     Default: ""
---
>     Default: "--container-runtime containerd"
305c305
<       Version: '1.20'
---
>       Version: '1.21'
463c463
<           /etc/eks/bootstrap.sh ${ClusterName} ${BootstrapArguments}
---
>           /etc/eks/bootstrap.sh ${ClusterName} ${BootstrapArguments} 

$ aws s3 cp eks-min_1.21.yaml https://eks-min-demo.s3.eu-central-1.amazonaws.com
$ aws cloudformation update-stack --stack-name eks-min --capabilities CAPABILITY_NAMED_IAM --template-url https://eks-min-demo.s3.eu-central-1.amazonaws.com/eks-min_1.21.yaml

OR

$ cp eks-min.yaml_1.21.yaml eks-min.yaml
$ aws s3 cp eks-min.yaml https://eks-min-demo.s3.eu-central-1.amazonaws.com
$ aws cloudformation update-stack --stack-name eks-min --capabilities CAPABILITY_NAMED_IAM --template-url https://eks-min-demo.s3.eu-central-1.amazonaws.com/eks-min.yaml


### Remove/Clean the infrastructure
$ aws cloudformation delete-stack --stack-name eks-min
$ aws s3 rm s3://eks-min-demo --recursive
delete: s3://eks-min-demo/eks-min.yaml
$ aws s3 rb s3://eks-min-demo --force
remove_bucket: eks-min-demo
$  aws s3api list-buckets --query "Buckets[].Name"
[]
$ aws ec2 describe-key-pairs --key-name demo-aks --region eu-central-1
{
    "KeyPairs": [
        {
            "KeyPairId": "key-098df9a2cb7943ce7",
            "KeyFingerprint": "af:3d:d3:6e:2d:f8:28:a4:05:47:7e:3c:66:51:c2:6c:a7:91:68:e2",
            "KeyName": "demo-aks",
            "Tags": []
        }
    ]
}
$ aws ec2 delete-key-pair --region eu-central-1 --key-name demo-aks 
$ aws ec2 describe-key-pairs --key-name demo-aks --region eu-central-1

An error occurred (InvalidKeyPair.NotFound) when calling the DescribeKeyPairs operation: The key pair 'demo-aks' does not exist

$ aws cloudformation list-stacks 
{
    "StackSummaries": [
        {
            "StackId": "arn:aws:cloudformation:eu-central-1:218645542363:stack/eks-min/e458c1e0-0721-11ec-bc7d-0a9f22aa9aa8",
            "StackName": "eks-min",
            "TemplateDescription": "Creates API gateway and services for my projects",
            "CreationTime": "2021-08-27T10:31:08.946Z",
            "DeletionTime": "2021-08-27T10:33:26.629Z",
            "StackStatus": "DELETE_COMPLETE",
            "DriftInformation": {
                "StackDriftStatus": "NOT_CHECKED"
            }
        }
    ]
}

$ aws resourcegroupstaggingapi get-resources --region eu-central-1


```
