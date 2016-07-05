## How do I install the Code Corps API?

### Requirements

You will need [VirtualBox](https://www.virtualbox.org/wiki/Downloads), [Vagrant](https://www.vagrantup.com/downloads.html) and [Ansible](http://docs.ansible.com/intro_installation.html) to be installed. Ansible also requires Python and some Python modules to be installed.

The fastest way to install VirtualBox and Vagrant is to use [`brew cask`](https://github.com/caskroom/homebrew-cask). Ansible can be installed with Homebrew as well:

```shell
brew install caskroom/cask/brew-cask
brew cask install virtualbox
brew cask install vagrant
brew install ansible
```

### Clone this repository

You'll want to [clone this repository](https://help.github.com/articles/cloning-a-repository/) with `git clone https://github.com/code-corps/code-corps-api.git`.

The directory structure will look like the following:

```shell
code-corps-api/   # → Root folder for this project
├── ansible/      # → Ansible root, containing playbooks for provisioning
├── app/
├── bin/
├── ...           # → More standard Rails files
├── ansible.cfg   # → Ansible configuration file; should not need to touch this
└── Vagrantfile   # → Configuration file for your virtual machine
```

### Start the VM

Go to the `code-corps-api` directory and type:

```shell
vagrant up
```

Vagrant will download a `trusty64` Linux box and provision it using the Ansible configuration provided in `code-corps-api/ansible`.

Vagrant will likely for a `sudo` password. This is normal. It's required when doing NFS folder synchronization.

When Vagrant has fully provisioned, you can log into the machine by running:

```shell
vagrant ssh
```

We'll automatically `cd` you into the `/code-corps-api` project directory, which is file synced to your cloned repository on your own machine. Changes made in `vagrant` will reflect on your machine, and vice versa.


### Start the server

Now you can simply run:

```shell
foreman s -f Procfile.dev
```

Point your browser (or make a direct request) to http://api.codecorps.dev:5000/ping. There should be a `{"ping":"pong"}` response from it.

### Pushing changes

You can use `git` as you normally would, either on the guest `vagrant` machine or on your own host machine.
