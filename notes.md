Notes
=====


Environment naming
------------------

I haven't tested the exact limitations for the names of environments, but
here are a few things to keep in mind: the were designed to be short, all
lowercase and have no spaces.

    Good examples: dev, prod, qa, stage
    Bad example: "John's Development Environment"


Self-modifying YAML files
-------------------------

The first four playbooks, the "setup", do their tasks, then write the results
back into the YAML group_vars file. I have mixed feelings about this and am
curious to see what people have to say.

The benefit is that the playbooks can be run by themselves after you have done
the setup.


ELB Limitations
---------------

The aws\_elb\_lb module has a couple of limitations that forced me to write a
little Python helper script. I thought this would be my chance to actually
submit some code to the Ansible project, but it looks like boto doesn't have
the functionality either, which makes it a much bigger task.

Another issue I ran into was the ability to choose a "Cipher". This is how you
would disable SSLv3, for example. I don't see any way to do this with Ansible.
The only reason I didn't address this is that the default is quite strict at
this point, which is how I would have set it.


Certificates on AWS
-------------------

This is an unusual area of AWS. Inside of using a straightforward list, like
pretty much everything else on AWS, the certificates live in a special little
drop-down you select from when setting up TLS. It wasn't quite as bad as the
cipher, in that I actually found a way to create and change them. To delete
them, though, the only way I found was using awscli.


Route 53
--------

Giving everything, or at least the ELB, a pretty name would be a nice addition,
but would require everyone to have an extra domain laying around to play with.
I would still like to add this at some point.
