# Phase 1 - Step 2: VPC Setup

![VPC Architecture](../../diagrams/dev-vpc.png)

## Objective
This guide outlines the steps to manually set up a development VPC with a public and private subnet in AWS.

---

## A. Create VPC

1. Go to **Create VPC** (VPC only)
    - **Name:** `dev-vpc`
    - **IPv4 CIDR Block:** `10.0.0.0/16`
    - Click **Create VPC**

2. After creation:
    - Go to **Actions → Edit VPC settings → Enable DNS hostnames**

![Enable DNS Hostnames](../../assets/enable-dns-hostnames.png)

```hcl
# vpc.tf
resource "aws_vpc" "dev" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "dev-vpc"
  }
}
```

> Enabling **DNS hostnames** allows instances within the VPC to receive **public DNS names** 
> This is quite usefull for public subnets, where instances need to be reacheable from the internet. Without DNS hostnames enabled, even if an instance has a public IP, it won't have a public DNS names, making remote access and service that depend on DNS more difficult.


> ⚠️ After the creation, you might see an error:
> ```
> "Route 53 Resolver DNS Firewall rule groups"
> ```
> This means that a group of DNS firewall rules from Route 53 could not be assciated with the VPC. You can ignore because we are not building an environment that filter outgoing DNS traffic.

---

## B. Create Subnets

1. **Public Subnet**
    - **Name:** `dev-public-1a`
    - **Availability Zone:** Ireland (`eu-west-1a`)
    - **IPv4 VPC CIDR block:** `10.0.0.0/16`
    - **Ipv4 Subnet CIDR block:** `10.0.1.0/24`

```hcl
resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.dev_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "eu-west-1a"
    tags = {
        Name = "dev-public-1a"
    }
}
```

2. **Private Subnet**
    - **Name:** `dev-private-1a`
    - **Availability Zone:** Ireland (`eu-west-1a`)
    - **IPv4 VPC CIDR block:** `10.0.0.0/16`
    - **IPv4 Subnet CIDR block:** `10.0.2.0/24`

```hcl
resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.dev_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "eu-west-1a"
    tags = {
        Name = "dev-private-1a"
    }
}
```
3. **Private Subnet with Nat**
    - **Name:** `dev-private-with-nat-1a`
    - **Availability Zone:** Ireland (`eu-west-1a`)
    - **IPv4 VPC CIDR block:** `10.0.0.0/16`
    - **IPv4 Subnet CIDR block:** `10.0.3.0/24`

```hcl
resource "aws_subnet" "private_subnet_with_nat" {
    vpc_id = aws_vpc.dev_vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "eu-west-1a"
    tags = {
        Name = "dev-private-with-nat-1a"
    }
}
```

4. After subnet creation:
    - For 'dev-public-1a`, go to **Actions → Edit subnet settings**
    - Enable **Auto-assign public IPv4 address**
    -Click **Save**


![Auto-assign public IPv4](../../assets/public-subnet-settings.png)

>Instances in a **public subnet** need a **public IPv4 address** to communicate with the internet directly via the **Internet Gateway (IGW)**.  
> Enabling this ensures every EC2 instance launched into this subnet automatically gets a public IP.

> In contrast, **private subnets** do **not** have internet access directly.  
> Giving them public IPs is not only unnecessary it also defeats the purpose of network isolation in private subnets.

> The dev-private-with-nat-1a subnet was created to divide the private subnets into two: one with internet access and one without.
> This separation helps isolate resources that do not require internet connectivity, improving security and reducing exposure.

---

## C. Create Route Tables

1. **Private Route Table**
    - **Name:** `dev-private-rt`
    - **VPC:** `dev-vpc`
    - Click **Create route table**

2. Associate subnet:
    - Go to **Subnet associations**
    - Click **Edit subnet associations** of the **Explicit subnet associations** part
    - Choose `dev-private-1a` and `dev-private-with-nat-1a`
    - Save associations

![Subnet Association](../../assets/private-subnet-association.png)

3. **Public Route Table**
    - AWS creates a default route table under the name `-`
    - Rename this to `dev-public-rt` (or as desired)
    - In its **subnet association** section, you will see that `dev-public-1a`is already associated (no action needed) 

>We assign both private subnets — `dev-private-1a` and `dev-private-with-nat-1a` — to the dev-private-rt route table **for now,** to keep them isolated from the internet.
> Later, we will configure a **NAT Gateway** with an **Elastic IP**, and create a dedicated route table for it. At that point, the `dev-private-with-nat-1a` subnet will be reassigned to the new route table that routes traffic to the NAT Gateway.
> As for the `dev-public-1a` subnet, it's implicitly associated with the VPC's main route table, which we've renamed to dev-public-rt. This route table includes a default route `0.0.0.0/0` to the Internet Gateway (IGW). Everything that doesn't have a destination within the VPC's CIDR block will go outside.
```hcl
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.dev_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "dev-public-rt"
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.dev_vpc.id
    tags = {
      Name = "dev-private-rt"
    }
}

resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.private_subnet_with_nat.id
    route_table_id = aws_route_table.private_rt.id
}
```


---

## D. Create Internet Gateway (IGW)

1. Go to **Create Internet Gateway**
    - **Name:** `dev-igw`
    - Click **Create**

2. After creation:
    - Go to ** Actions → Attach to VPC**
    - Select VPC: `dev-vpc`
    - Click **Attach**

```hcl
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.dev_vpc.id
    tags = {
        Name = "dev-igw"
    }
}
```

---

## E. Route Internet Traffic

1. In **Route Tables**, select `dev-public-rt` (associated with `dev-public-1a`)

2. Add a new route:
    - **Destination:** `0.0.0.0/0`
    - **Target:** Internet Gateway → `dev-igw`

![Public Route Table](../../assets/public-route-table.png)

> All traffic within the CIDR block (`10.0.0.0/16`) will be routed **locally** by the VPC router. 
> Everything outside of the CIDR block will be routed to the **internet** via the **Internet Gateway**

3. Click **Save changes**

```hcl
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.dev_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "dev-public-rt"
    }
}
```

---

## Notes   

**Every VPC includes an internal router managed by AWS.**

- This **VPC router** handles all routing between subnets and external components.
- You don't create it manually, it's automatically included when you create a VPC.
- It uses the **route tables** to determine how to forward traffic, whether it's within the VPC or going out to the internet.

## Terraform
[View Terraform(VPC)](../../aws-infra/modules/vpc/)