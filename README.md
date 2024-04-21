# Tomasz Koralewski - Terraform, EC2, TicTacToe report

- Course: *Cloud programming*
- Group: W04IST-SI0828G # L # Programowanie w chmurze – Lab
- Date: 21/4/2024

## Environment architecture

The infrastructure developed in this project leverages several AWS services orchestrated via Terraform to host a simple TicTacToe game. The architecture is designed with scalability and security in mind.

AWS VPC (Virtual Private Cloud) - The foundation of the network architecture is the VPC my_vpc with a CIDR block of 10.0.0.0/16, enabling DNS support and hostnames to facilitate better name resolution within the network.

Subnets - Two subnets are created within this VPC:
public_subnet: This subnet, located in the us-east-1a availability zone with a CIDR block of 10.0.101.0/24, is designed to allow public access and is where the game server EC2 instance resides.

private_subnet: This subnet, located in the us-east-1b zone with a CIDR block of 10.0.102.0/24, is intended for internal services that don't require direct internet access.

Internet Gateway - The igw internet gateway is attached to the VPC, enabling communication between resources in the public subnet and the internet.

Route Tables - A route table public_route_table is associated with the public subnet to direct traffic to the internet gateway.

Security Groups - The server_sg security group is applied to the EC2 instance to define inbound and outbound traffic rules, allowing SSH, HTTP, and backend traffic (port 5000).

EC2 Instances - The server EC2 instance is launched within the public subnet. It's configured to run a web-based TicTacToe game, using a variety of technologies (Python, Flask, Node.js, and Nginx). The instance setup includes the use of provisioners for software installation and configuration.



## Reflections

- What did you learn?
Through this project, I gained hands-on experience with AWS services and Terraform, learning how to effectively design and deploy a cloud-based application infrastructure. The integration of various technologies to support a simple web application provided insights into the complexity and potential of cloud environments.
  
- What obstacles did you overcome?
Configuring network settings correctly within the VPC to ensure both security and accessibility.
Managing dependencies and correct sequencing in Terraform to avoid deployment errors.

- What did you help most in overcoming obstacles?
The Terraform documentation and AWS tutorials were invaluable in overcoming these challenges. Frequent testing and iteration allowed for resolving configuration issues promptly.

- Was that something that surprised you?
The power and flexibility of Terraform in managing infrastructure as code were particularly surprising. It simplified the process of building, changing, and versioning infrastructure safely and efficiently, showcasing how such tools are revolutionizing cloud environments.

This project not only enhanced my technical skills but also provided a practical understanding of the complexities involved in cloud infrastructure deployment and management.
