# Terraform Demo
This is a demonstration of running a secure web application in an isolated AWS VPC.

## Application
The web application is very simple:
 * Frontend server
 * Backend server
 * Database server

The frontend has no direct communication with the database server.

The frontend server makes a request to the backend service, which attempts a
connection to the database server and responds with its connection status.

If both connections are successful, then the frontend will display the message:
```
Connection OK; waiting to send.
```

### Testing
The web application can be built and run locally, given that you have `docker`
and `docker-compose` available.

Create a `.env` file from a copy of `.env.example` and set the values as
desired. (In a local environment, the Postgres database, username, and password
are mostly arbitrary as they are set on the database container at launch time.)

Run `make` (or `make images`) to build both the frontend and backend servers,
then `make up` to launch them. Once running, the application can be verified by
navigating to [localhost:8080](http://localhost:8080) from a browser.

The `make down` command can then be used to stop and remove the running the
application. You can also run `make test` to output a comparison using cURL.


## Network
The network is broken down like this:
* VPC (10.0.0.0/16)
  * Public subnet in first AZ (10.0.10.0/24)
  * Private subnet in first AZ (10.0.11.0/24)
  * Public subnet in second AZ (10.0.20.0/24)
  * Private subnet in second AZ (10.0.21.0/24)
* EC2
  * NAT instance in a public subnet
  * EC2 Container Service
    * Frontend cluster
      * One instance in each public subnet
    * Backend cluster
      * One instance in each private subnet
    * The application is deployed as load-balanced ECS services.
* RDS
  * Multi-AZ PostgreSQL instance in the private subnets

### Deployment
The network can be deployed using AWS credentials with permissions to create
resources.

Note: for this demo, the images for the web application are pre-built and will
be pulled from [Docker Hub](https://hub.docker.com/u/rypcarr).

Create a `terraform.tfvars` file from a copy of `terraform.tfvars.example` and
set the values as desired. As with local testing above, the database values
will both be used to initialize the database and be provided to the backend
application for its connection to the new database.

Run `make plan` to create an execution plan from the Terraform configuration.
When ready to launch, run `make deploy` to begin. (While all instances in the
demo are configured to be nano or micro, you will incur some AWS charges!)

The Terraform build should take 10-15 minutes (the multi-AZ RDS instance being
the most time-consuming), and when the process is complete the DNS name of the
frontend load balancer will be included in the output.

It may take a minute or two for the ECS services to start their tasks and
establish connections to the application load balancers. 

Once everything is in place, navigating to the frontend URL in a browser should
result in the seeing the expected message from the application:
```
Connection OK; waiting to send.
```
