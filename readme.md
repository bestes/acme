Acme
====

Example DevOps setup using Ansible and AWS
------------------------------------------

There are so many tools and services available in the world of DevOps today, it
can be daunting just to select a finite set and get to work. In this example, I
picked Ansible and AWS as the main components.

I wanted to explore what it takes to create a complete configuration, from the
network up through load balanced web servers, with no manual intervention.

Finally, I wanted a realistic and practical way to manage multiple environments,
like dev and prod, including the management of sensitive data.

This is the result.


#### Tools and Services

- Ansible (configuration management)
- Amazon Web Services (Infrastructure as a Service)
- Papertrail (logging)
- Postgres (database)
- Memcached (caching)
- Nginx (web)


Goals
-----

#### Environment/Infrastructure

- Create an isolated VPC for each environment (dev, prod, etc.).
- Allocate subnets across Availability Zones within each VPC.
- Create security groups both per service and per environment.
- Limit each environment to a single region.
- Ensure it is idempotent so you can re-run at any time.

#### Services

- Create the database, caching and web servers in the proper order.
- Use roles to manage common components, like NTP and logging.
- Spread services across Availability Zones, as appropriate.


Security
--------

Security is a tough area to manage. The temptation is to keep secret files
outside the configuration management repository, for, you know, security.
But, then you lose the versioning, central storage and all other benefits
of source control. I picked three main principles to follow for this example.

- Honor the Principle of Least Privilege.
- Include secrets in source control as encrypted files.
- Share no credentials between production and other environments.


For such a small environment, the breadth of credentials is surprisingly large.


#### Amazon Web Services (AWS)

- As our IaaS provider, we must have an account to create resources.
- Actual files: .aws/credentials (and ./aws/config, but no secrets in there).

#### Nginx

- Requires a certificate and key-file for TLS.
- Non-production environments can create their own, self-signed, certificates.
- The ACME demo auto-creates certificates unless you provide them.
- Certificates must be uploaded to AWS if you want the ELB to use them.
- Actual files: nginx.crt, nginx.key

#### SSH

- AWS accounts require a master SSH key to initially connect to an instance
- Each environment should have its own set of keys.
- Ansible, which is SSH-based, requires properly installed SSH keys.
- SSH keys are usually encrypted and then added to ssh-agent for the logged-in
  user. ssh-agent allows you to include multiple keys.
- The ACME demo auto-creates a set of keys, unless you provide them.
- Actual files: ENV\_id\_rsa and ENV\_id\_rsa.pub where ENV is the name of your
  environment.

#### Ansible

- Passwords, like the one for the database, need to be stored somewhere.
- Ansible has a feature called ansible-vault which can automatically manage
  encrypted YAML files.
- ansible-vault itself requires a password to encrypt YAML files.
- The ACME demo asks you for a new password, if necessary.
- Actual file: secrets.yml

#### awscli/boto

- Ansible uses boto, which requires AWS credentials.
- There are a couple of instances where awscli is used, so credentials must be
  stored in such a way that both Ansible and awscli can use them.


Setup
=====

Requirements
------------

- An Amazon AWS account (and the credentials that go along with it).
- Money to pay for the resources consumed.
- Docker. In order to keep this example as separate as possible from your
  regular working environment, I created a special image you can use to try
  this demo out. I highly encourage using this image instead of trying the demo
  on your regular system.


Using Docker
-------------

See the readme, in docker_image/readme.md, for detailed instructions. The
setup script and instructions are all written with the docker container in
mind.


Results
=======

So, what will the demo actually do? I could explain everything here, but the
Ansible playbooks are probably readable enough that it will simply be
duplication of effort.

There is one special playbook, called "site.yml", that is a collection of all
the others, in order. As for the others, you can tell from their names what each
will do.

- 01-create\_vpc.yml                - creates the VPC
- 02-create\_security\_groups.yml   - creates security groups
- ...

You see where this is going.


Resources configured
--------------------

In the end, for the "dev" environment, you should have:

- A VPC called dev with four subnets, split across three AZs
- Security groups for each of the server types
- A (possibly new) set of SSH keys
- A (possibly new) certificate for nginx
- (1) memcached server
- (1) postgres server
- (1) nginx server
- (1) ELB that points to your nginx server


<b>Make sure to terminate these resources once you are finished! They will keep
costing you money as long as they exist.</b>


Purpose
--------

Great! So what does the application actually DO?

Well, nothing really! My thing is infrastructure, not applications. This
environment is an example of one ready to host an application, configure it,
secure it, and help manage the changes through development, testing, staging
and production.

I wouldn't mind a nice demo app that actually uses the database and caching
servers, but it wouldn't really add much and might even detract from the focus.


Next Steps
----------

If you try this demo, please leave some feedback! Did it work? What parts were
difficult? How could it be improved?

Feel free to leave comments in my blog, submit pull requests or create issues
in GitHub.


