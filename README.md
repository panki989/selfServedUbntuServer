# Ubuntu 20.04 Server Self Service
Configs for the spinning up ubuntu 20.04 server without human interventions or click.

## Credits
https://gist.github.com/s3rj1k/55b10cd20f31542046018fcce32f103e

## Prerequisite
1. https://opensource.com/article/17/2/linux-boot-and-startup
2. https://ubuntu.com/server/docs/install/autoinstall
3. https://www.ipaddressguide.com/cidr
4. https://www.virtualbox.org/manual/ch06.html#networkingmodes
5. https://linuxize.com/post/how-to-configure-static-ip-address-on-ubuntu-20-04/
6. Basic of [Cloudinit](https://cloudinit.readthedocs.io/en/latest/index.html)
7. More info about files required in [unattended installation](https://www.youtube.com/watch?v=wpWZJ7wrTRI&t=4s)
8. https://www.geeksforgeeks.org/customising-vim-from-scratch-without-plug-ins/
9. https://www.tecmint.com/speed-up-ssh-connections-in-linux/
10. https://unix.stackexchange.com/a/511017


## How to start
```
# Command to generate crypt(salt based) passwd
openssl passwd -6 -salt "/PYpVMtUyP2E18jr" "yourP@$$w0rd"

# To generate key-pair for jump-box(client machine)
ssh-keygen

# Become sudo in your host
sudo -i

# Make executable
chmod 744 build-iso.sh

# Start process
./build-iso.sh

# After server comes up:
# Login with myuser:$crypt-passwd
# Get ip of server by
ip a

# Once you have ip, try login from Jump box
# Ex: ssh -i ~/.ssh/id_rsa -p 9222 myuser@172.16.8.11
ssh -i <pathToPrivateKey> -p 9222 myuser@<ip>
```
___

## FAQ
**Q: Why should I go with autoinstaller if I can do the same steps manually in few clicks?**


**A:** Setting up large no. of server can be tedious sometimes and more error-prone as well. This has following advantages over click method:

* SSH keys are already setup for the initial user.
* You can just start using [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) or other tools as soon as server comes up.


##

**Q: In which case I need to include the network config?**

**A:** You can think of these to start with:

* You have more the one live eth adapters avaliable.
* You want to have static IP for you server given by you.
* You need to configure bond configs for adapters.

##

**Q: What will happen if I'll not use the network config?**

**A:** Few cases that I can imagine or have experienced:

* It will select the one which is present and request new IP from DHCP server.
* If static IP configuration is missing in your DHCP server then IP might change in next boot which can eventually break things. 
##

**Q: Where these configs are tested?**


**A:** Legacy mode. Haven't tried it for UEFI but I guess, It should be working for that as well.
##

**Q: How can I add more users initially?**


**A:** I recommend to use [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) with [jenkins](https://www.jenkins.io/doc/) for your next users and their management. If still you want to explore with [cloudinit](https://cloudinit.readthedocs.io/en/latest/topics/modules.html?highlight=users#users-and-groups), try below:
```
user-data:
	users:
	  - default
	  - name: test
	    passwd: "<Your crypt hash>"
	    shell: /bin/bash
	    lock-passwd: false
	    ssh_pwauth: True
	    chpasswd: { expire: False }
	    sudo: ALL=(ALL) NOPASSWD:ALL
	    groups: users, admin
	    ssh_authorized_keys:
	     - <add-keys here>
```
##

**Q: I've not changed anything in user-data so what password I need to use for login?**


**A:** `myuser:changeme`. Still you can't access server remotely if you've not created your own key-pair with [ssh-keygen](https://www.ssh.com/academy/ssh/keygen#ssh-keys-and-public-key-authentication) and replaced the public key or copied the private.key [correctly](https://superuser.com/a/215506) and specified in ssh command.
##
