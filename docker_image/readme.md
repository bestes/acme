Using this Docker image
-----------------------

This docker image is designed to work with the ACME Ansible repository to
bring up a complete AWS environment, including a VPC, security groups, SSH
key and EC2 instances. In order to do this, it is going to require your AWS
credentials.

Even though I'm including the Dockerfile itself here, the instructions assume
you will just be running it from the Docker registry.


!! Warning !!
-------------

>  <b>To be extra clear: running this demo will incur charges on AWS.</b>

> It shouldn't cost much, as I've selected t2.micro instances and you can take
them down right away, but there will be some cost. And, of course, there could
be bugs that drive up the cost considerably.


Quick Start
-----------

The bare minimum necessary to run the demo

<pre>
<code>
    $ docker run -it bestes/acme

    (pause while it downloads the image, if necessary)

    Setup AWS
    AWS Access Key ID [None]: (your_credential_here)
    AWS Secret Access Key [None]: (your_credential_here)
    Default region name [None]: (us-west-2)
    Default output format [None]: (json)

    Setup SSH
    Generating new SSH keypair
    '/root/.ssh/id_rsa.pub' -> '/root/acme/env/dev/files/id_rsa.pub'

    Ansible Vault
    Using password: (demo)

    Setup complete.

    root@1f36c6423784:~/acme#
</code>
</pre>

At this point, it drops you at a bash prompt inside the container. If everything
went well, proceed. Otherwise, re-run setup from /root/setup.sh

From here, switch to the /root/acme directory and then run all the playbooks
at once, like so:

<pre><code>
    root@1f36c6423784:~# cd /root/acme
    root@1f36c6423784:~/acme# ./run.sh dev site.yml
</code></pre>

This will run all the playbooks, using the "dev" environment. Look through the
Ansible repo in order to learn more about what it is doing.


Setup options
-------------

Instead of having credentials generated, you can provide your own. There are
two main ways to do this.


Directory Mapping
-----------------

To use existing credentials, this is one of the easiest ways. First, create an
empty directory. If you are using boot2docker for the Mac, please make sure
this directory is located somewhere under /Users/.

Now, copy your credentials into that directory. Here is how it should look when
you are finished:

<pre><code>
  conf
    aws_credentials
    aws_config
    id_rsa
    id_rsa.pub
    vault-pw-dev
</code></pre>


A couple of things to note: the aws credentials are named differently than they
will be on your system and the vault-pw file does not have an environment
appended to it, like it will inside the image.

Here is some example code that will copy your existing credentials.

<pre><code>
    mkdir conf
    cp ~/.aws/credentials conf/aws_credentials
    cp ~/.aws/config      conf/aws_config
    cp ~/.ssh/id_rsa*     conf/
    echo "MySecretPass" > conf/vault-pw
</code></pre>

Once you have these gathered, start the Docker container like so:

<pre><code>
    docker RUN -it                  \
      -v /path/to/conf:/root/conf   \
      bestes/acme
</code></pre>


Environmental Variables
-----------------------

Another way to provide credentials is via environmental variables.

<pre><code>
    export AWS_ACCESS_KEY_ID=(your access key)
    export AWS_SECRET_ACCESS_KEY=(your_secret_key)
    export AWS_REGION=(your_region)
    export VAULT_PW=(your_vault_pw)
</code></pre>

Once you have them set, start the Docker container like so:

<pre><code>
    docker RUN -it \
      -e AWS_ACCESS_KEY_ID=(your_access_key)     \
      -e AWS_SECRET_ACCESS_KEY=(your_secret_key) \
      -e AWS_REGION=(your_region)                \
      -e VAULT_PW=(your_vault_pw)                \
      bestes/acme
</code></pre>

Note that in this method, the SSH keys have been omitted. The setup file will
automatically generate some new ones for you.


Saving Credentials
------------------

The .gitignore file in the ACME repo will try not to let you accidentally
check in any unencrypted credentials. A side-effect is that it might not be
obvious when there are new credentials that must be saved. If you plan to use
this for anything more than the demo, please make sure to save any credentials
generated in a safe place.

To find them, look in the directory:

    acme/env/dev/files

*Replace "dev" with the name of your environment

In some cases, the credentials from the regular system locations will be used.
Here are the locations of these special files:

    $HOME/.ssh/

        id_rsa
        id_rsa.pub

    $HOME/.aws/

        credentials
        config

The nginx certificates don't have a natural location on your admin box.


Encryption
----------

I played around with the idea of encrypting credentials in-place, but haven't
had time to write the code and try it out yet.

The idea is to store all credentials in the repo, encrypted with the same
password used with ansible-vault for each environment. Even better would be to
use ansible-vault itself, but it doesn't appear to have the ability to do
automatic encryption/decryption on non-YAML files today.

Unfortunately, I will have to leave the secure storage or credentials as an
exercise for the reader.







