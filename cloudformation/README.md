# CloudFormation template for Aline stack
# Description
This template deploys a VPC with its subnets, gateways, route tables, and security group. This template also deploys an RDS DB instance, an EKS Cluster, and an ECS Cluster.

## Parameters
The list of parameters for this template:

### Initials 
Type: String 
Default: SM 
Description: Initials of the person creating this stack. For demo purposes. 
### EnvironmentName 
Type: String 
Default: Dev 
Description: Environment name that is suffixed to resource names. 
### Region 
Type: String  
Description: Region the resources will be created at. 
### VpcCIDR 
Type: String 
Default: 192.168.0.0/16 
Description: The IP range (CIDR notation) for this VPC. 
### PublicSubnet1CIDR 
Type: String 
Default: 192.168.101.0/24 
Description: An IP range for a subnet. 
### PublicSubnet2CIDR 
Type: String 
Default: 192.168.102.0/24 
Description: An IP range for a subnet. 
### PublicSubnet3CIDR 
Type: String 
Default: 192.168.103.0/24 
Description: An IP range for a subnet. 
### PrivateSubnet1CIDR 
Type: String 
Default: 192.168.1.0/24 
Description: An IP range for a subnet. 
### PrivateSubnet2CIDR 
Type: String 
Default: 192.168.2.0/24 
Description: An IP range for a subnet. 
### PrivateSubnet3CIDR 
Type: String 
Default: 192.168.3.0/24 
Description: An IP range for a subnet. 
### ClusterName 
Type: String 
Default: aline 
Description: Name given to the EKS Cluster. 
### AllocatedStorage 
Type: String 
Default: 20 
Description: Number of GBs allocated for storage. 
### DbName 
Type: String 
Default: alinedb 
Description: Name of the Database. 
### Engine 
Type: String 
Default: mysql 
Description: Engine of the Database. 
### EngineVersion 
Type: String 
Default: 8.0.28 
Description: Version of the Database's engine. 
### InstanceClass 
Type: String 
Default: db.t3.micro 
Description: Class of the Database's instance. 
### StorageType 
Type: String 
Default: gp2 
Description: Type of storage of the Database. 
### Port 
Type: String 
Default: 3306 
Description: The port to connect to the Database. 
### MasterUsername 
Type: String  
Description: Username of the master user. 
### MasterUserPassword 
Type: String  
Description: Password of the master user. 

## Resources
The list of resources this template creates:

### VPC 
Type: AWS::EC2::VPC  
### PublicSubnet1 
Type: AWS::EC2::Subnet  
### PublicSubnet2 
Type: AWS::EC2::Subnet  
### PublicSubnet3 
Type: AWS::EC2::Subnet  
### PrivateSubnet1 
Type: AWS::EC2::Subnet  
### PrivateSubnet2 
Type: AWS::EC2::Subnet  
### PrivateSubnet3 
Type: AWS::EC2::Subnet  
### InternetGateway 
Type: AWS::EC2::InternetGateway  
### InternetGatewayAttachment 
Type: AWS::EC2::VPCGatewayAttachment  
### EIP1 
Type: AWS::EC2::EIP  
### EIP2 
Type: AWS::EC2::EIP  
### EIP3 
Type: AWS::EC2::EIP  
### NATGateway1 
Type: AWS::EC2::NatGateway  
### NATGateway2 
Type: AWS::EC2::NatGateway  
### NATGateway3 
Type: AWS::EC2::NatGateway  
### PublicRouteTable 
Type: AWS::EC2::RouteTable  
### PrivateRouteTable1 
Type: AWS::EC2::RouteTable  
### PrivateRouteTable2 
Type: AWS::EC2::RouteTable  
### PrivateRouteTable3 
Type: AWS::EC2::RouteTable  
### PublicRoute 
Type: AWS::EC2::Route  
### PrivateRoute1 
Type: AWS::EC2::Route  
### PrivateRoute2 
Type: AWS::EC2::Route  
### PrivateRoute3 
Type: AWS::EC2::Route  
### PublicRouteTableAssociation1 
Type: AWS::EC2::SubnetRouteTableAssociation  
### PublicRouteTableAssociation2 
Type: AWS::EC2::SubnetRouteTableAssociation  
### PublicRouteTableAssociation3 
Type: AWS::EC2::SubnetRouteTableAssociation  
### PrivateRouteTableAssociation1 
Type: AWS::EC2::SubnetRouteTableAssociation  
### PrivateRouteTableAssociation2 
Type: AWS::EC2::SubnetRouteTableAssociation  
### PrivateRouteTableAssociation3 
Type: AWS::EC2::SubnetRouteTableAssociation  
### SecurityGroup 
Type: AWS::EC2::SecurityGroup  
### DBSubnetGroup 
Type: AWS::RDS::DBSubnetGroup  
### DbInstance 
Type: AWS::RDS::DBInstance  
### EksCluster 
Type: AWS::EKS::Cluster  
### EksClusterSecurityGroup 
Type: AWS::EC2::SecurityGroup  
### EksClusterRole 
Type: AWS::IAM::Role  
### EksPublicNodegroup 
Type: AWS::EKS::Nodegroup  
### EksPrivateNodegroup 
Type: AWS::EKS::Nodegroup  
### EksNodegroupRole 
Type: AWS::IAM::Role  
### EcsLoadBalancer 
Type: AWS::ElasticLoadBalancingV2::LoadBalancer  
### EcsLbTargetGroup 
Type: AWS::ElasticLoadBalancingV2::TargetGroup  
### EcsLbListener 
Type: AWS::ElasticLoadBalancingV2::Listener  
### EcsCluster 
Type: AWS::ECS::Cluster  
### EcsClusterCpAssociation 
Type: AWS::ECS::ClusterCapacityProviderAssociations  

## Outputs
The list of outputs this template exposes:

### VpcId 
Description: The ID of the VPC.  

### SecurityGroup 
Description: The ID of the default security group for the VPC.  

### PublicSubnetIds 
Description: The IDs of the public subnets.  

### PrivateSubnetIds 
Description: The IDs of the private subnets.  

### InternetGatewayId 
Description: The ID of the Internet Gateway.  

### NATGatewayIds 
Description: The ID of the NAT Gateways.  

### PublicRouteTableId 
Description: The ID of the Public Route Table.  

### PrivateRouteTableIds 
Description: The IDs of the Private Route Tables.  

### PublicRouteIds 
Description: The IDs of the Public Routes.  

### PrivateRouteIds 
Description: The IDs of the Private Routes.  

### PublicRouteTableAssociationIds 
Description: The IDs of the Public Route Table Associations.  

### PrivateRouteTableAssociationIds 
Description: The IDs of the Private Route Table Associations.  

### SecurityGroupIds 
Description: The ID of the Security Group.  

### ClusterCertificateAuthorityData 
Description: The certificate-authority-data for your cluster.  

### ClusterEndpoint 
Description: The endpoint for your Kubernetes API server.  

### ClusterOidcIssuerUrl 
Description: The issuer URL for the OIDC identity provider.  

