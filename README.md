
# Docker SFTP Server

<br>
![crate image](http://i.imgur.com/ejbjGOS.png)
<br> 

This dockerfile will allow you to create many SFTP servers. The data saved in the SFTP servers can be accessed from the host.

Authentication can be set up so that:

- You can log into all servers.
- Your customers can only log into their server.




### Quickstart

On your host machine:

```bash
# cloning this repository (the folder can be anything)
cd /opt
git clone https://github.com/42technologies/docker-sftp-server.git

# making initial directory structure
# - "data" directory will hold the data from sftp servers
# - "keys" directory can hold public keys that will allow login to ALL sftp servers
mkdir -p ./sftp/{data,keys}

# (optional) creating a key for global login
ssh-keygen -b 4096 -f ./sftp/sftp.key -q -N ""
cp ./sftp/sftp.key.pub ./sftp/keys

# building the docker image
docker build -t 42technologies/sftp docker-sftp-server

# running the sftp server
./docker-sftp-server/sftp-run.sh /opt/sftp jacobmarks 9000

# (optional) you can install public keys to allow login into the "jacobmarks" container
# cp jacobmarks.key.pub ./sftp/data/jacobmarks/keys

# (optional) or you can use the script to set a text password
# ./sftp-passwd.sh /opt/sftp jacobmarks

# connecting to the sftp server
sftp -i ./sftp/sftp.key -P 9000 wherewithal@localhost

# ... after put-ing files in the SFTP server, you can access them here
ls ./sftp/data/jacobmarks/data
```

Note that if you decide to install this stuff in a directory other than
`/opt`, you'll need to modify the command parameters accordingly.

---

### Detailed Installation Instructions

#### 1. Clone this repo and stick it somewhere

```
cd /opt
git clone https://github.com/42technologies/docker-sftp-server.git
```

#### 2. Create initial folder structure

```
mkdir -p /opt/sftp/{data, keys}
```

In the scripts, there is mention of a `<root>` argument. In this example, the `<root>` is `/opt/sftp`.

- The `/opt/sftp/data` directory will contain the data from the SFTP servers.
- The `/opt/sftp/keys` directory can hold public keys that will allow login to ALL sftp servers


#### 3. Build the docker image

```
docker build -t 42technologies/sftp docker-sftp-server
```


#### 4. Create an SFTP server for an organization 

Let's create an sftp container for organization `jacobmarks` that will run on port `10000`:

```
/opt/docker-sftp-server/sftp-run.sh /opt/sftp jacobmarks 10000
```

This creates a container that exposes it's SSH server via port `10000`. You
SFTP into the server by using `wherewithal` as the username, and port `10000`.

The `sftp-run.sh` script will create the directory `<root>/data/jacobmarks`.

The container will then be run, which upon starting will run a script that creates
the following directories (in the container):

- `/sftp/keys` which should contain org-level login public keys (maps to `<root>/data/jacobmarks/keys` in the host)
- `/sftp/data` which should contain the sftp data (maps to `<root>/data/jacobmarks/data` in the host)

Both of these directories will not be deleteable by the sftp user. 


#### 4. Authentication

##### a) Global Login

Access to all SFTP servers can be done by placing your public key in the `/opt/sftp/keys` folder.
This folder can contain any number of keys.

##### b) Organization-Level Login

After running the `sftp-run.sh` script for an organization, the organization's directory structure
will be initialized. You will then be able to place public keys in the `/opt/sftp/data/<organization>/keys`
directory.

If you want to use password-based authentication, you can use the `sftp-passwd.sh` script:

```
./sftp-passwd.sh <root> <organization>
```

#### 5. Connecting to the SFTP server

On some random machine, you can connect to the SFTP server by doing:

```
sftp -i <private key> -P <port> wherewithal@<host>
```

Note that the private key is not necessary if you have set a password.

#### 6. ????

#### 7. PROFIT


## Inside the SFTP server

As mentioned previously, each container only creates a single SFTP user: `wherewithal`. To "switch" accounts,
you just connect to a different SFTP server (aka use a different port).

The SFTP user will have full control over files in `/keys` and `/data`. The are however unable to delete
the directories. The SFTP user is also able to read anything that is placed in the `/` directory.

The idea here is that the user will upload his data to the `/data` folder, and he will upload his keys
to `/keys`.


## How does this authentication magic work?

We expose the host's `<root>/keys` directory to the container's `/keys` directory.

We configured SSHD to use the `AuthorizedKeysCommand` directive, which allows us call a script
to fetch the list of authorized public keys.

When a login attempt is made, `AuthrorizedKeysCommand` runs a script that concatenate all the public
keys in the `/keys` directory (global login) with the ones in `/sftp/keys` (org-level login). 



## Generating a key pair

Just as a reference, here's how you can generate keys using `ssh-keygen`:

```
ssh-keygen -b 4096
```


## How to create temporary containers, for testing and hacking

```
docker run -it \
-p <port>:22 \
-v /etc \
-v /home/core/sftp/keys:/keys \
42technologies/sftp bash
```

That should give you a shell with the sftp environment. To run SSHD in debug mode, do this:

```
/usr/sbin/sshd -d
```





