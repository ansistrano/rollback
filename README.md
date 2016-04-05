Ansistrano
==========

[![Build Status](https://travis-ci.org/ansistrano/rollback.svg?branch=master)](https://travis-ci.org/ansistrano/rollback)

**ansistrano.deploy** and **ansistrano.rollback** are Ansible roles to easily manage the deployment process for scripting applications such as PHP, Python and Ruby. It's an Ansible port for Capistrano.

History
-------

[Capistrano](http://capistranorb.com/) is a remote server automation tool and it's currently in Version 3. [Version 2.0](https://github.com/capistrano/capistrano/tree/legacy-v2) was originally thought in order to deploy RoR applications. With additional plugins, you were able to deploy non Rails applications such as PHP and Python, with different deployment strategies, stages and much more. I loved Capistrano v2. I have used it a lot. I developed a plugin for it.

Capistrano 2 was a great tool and it still works really well. However, it is not maintained anymore since the original team is working in v3. This new version does not have the same set of features so it is less powerful and flexible. Besides that, other new tools are becoming easier to use in order to deploy applications, such as Ansible.

So, I have decided to stop using Capistrano because v2 is not maintained, v3 does not have enough features, and I can do everything Capistrano was doing with Ansible. If you are looking for alternatives, check Fabric or Chef Solo.

Project name
------------

Ansistrano comes from Ansible + Capistrano, easy, isn't it?

Early adopters
--------------

If you were an early adopter, you should know we have broken BC by moving from using `ansistrano_custom_tasks_path` to individual and specific files per step. See "Role Variables". **The role displays a warning if the variable is defined and although your old playbooks may still run with no errors, you will see that your code is uploaded but custom tasks are not run.**

Ansistrano anonymous usage stats
--------------------------------

We have recently added an extra optional step in Ansistrano so that we can know how many people are deploying their applications with our project. Unfortunately, Ansible Galaxy does not provide any numbers on usage or downloads so this is one of the only ways we have to measure how many users we really have.

You can check the code we use to store your anonyomus stats at [the ansistrano.com repo](https://github.com/ansistrano/ansistrano.com) and anyway, if you are not comfortable with this, you will always be able to disable this extra step by setting `ansistrano_allow_anonymous_stats` to false in your playbooks.

Who is using Ansistrano?
------------------------

Is Ansistrano ready to be used? Here are some companies currently using it:

* [Atrápalo](http://www.atrapalo.com)
* [Another Place Productions](http://www.anotherplaceproductions.com)
* [Suntransfers](http://www.suntransfers.com)
* [Ulabox](https://www.ulabox.com)
* [Euromillions.com](http://euromillions.com/)
* [Uvinum](http://www.uvinum.com)
* [Cycloid](http://www.cycloid.io)
* [Spotahome](https://www.spotahome.com)
* [Ofertix](http://www.ofertix.com)
* [Nice&Crazy](http://www.niceandcrazy.com)
* [Gstock](http://www.g-stock.es)
* [CMP Group](http://www.teamcmp.com)

If you are also using it, please let us know via a PR to this document.

Requirements
------------

In order to deploy your apps with Ansistrano, you will need:

* Ansible in your deployer machine

Installation
------------

Ansistrano is an Ansible role distributed globally using [Ansible Galaxy](https://galaxy.ansible.com/). In order to install Ansistrano role you can use the following command.

```
$ ansible-galaxy install carlosbuenosvinos.ansistrano-deploy carlosbuenosvinos.ansistrano-rollback
```

Update
------

If you want to update the role, you need to pass **--force** parameter when installing. Please, check the following command:

```
$ ansible-galaxy install --force carlosbuenosvinos.ansistrano-deploy carlosbuenosvinos.ansistrano-rollback
```

Features
--------

* Rollback in seconds (with ansistrano.rollback role)
* Customize your deployment with hooks before and after critical steps
* Save disk space keeping a maximum fixed releases in your hosts
* Choose between SCP (push), RSYNC (push) or GIT (pull) deployment strategies

Main workflow
-------------

Ansistrano deploys applications following the Capistrano flow.

* Setup phase: Creates the folder structure to hold your releases
* Code update phase: Puts the new release into your hosts
* Symlink phase: After deploying the new release into your hosts, this step changes the `current` softlink to new the release
* Cleanup phase: Removes any old version based in the `ansistrano_keep_releases` parameter (see "Role Variables")

![Ansistrano Flow](https://raw.githubusercontent.com/ansistrano/deploy/master/docs/ansistrano-flow.png)

Role Variables
--------------

```yaml
- vars:
  ansistrano_deploy_to: "/var/www/my-app" # Base path to deploy to.
  ansistrano_version_dir: "releases" # Releases folder name
  ansistrano_current_dir: "current" # Softlink name. You should rarely changed it.
  ansistrano_remove_rolled_back: yes # You can change this setting in order to keep the rolled back release in the server for later inspection
  ansistrano_allow_anonymous_stats: yes

  # Hooks: custom tasks if you need them
  ansistrano_before_symlink_tasks_file: "{{ playbook_dir }}/<your-deployment-config>/my-before-symlink-tasks.yml"
  ansistrano_after_symlink_tasks_file: "{{ playbook_dir }}/<your-deployment-config>/my-after-symlink-tasks.yml"
  ansistrano_before_cleanup_tasks_file: "{{ playbook_dir }}/<your-deployment-config>/my-before-cleanup-tasks.yml"
  ansistrano_after_cleanup_tasks_file: "{{ playbook_dir }}/<your-deployment-config>/my-after-cleanup-tasks.yml"
```

`{{ playbook_dir }}` is an Ansible variable that holds the path to the current playbook.

Deploying
---------

In order to deploy with Ansistrano, you need to perform some steps:

* Create a new `hosts` file. Check [ansible inventory documentation](http://docs.ansible.com/intro_inventory.html) if you need help. This file will identify all the hosts where to deploy to. For multistage environments check "Multistage environments"
* Create a new playbook for deploying your app, for example, deploy.yml
* Include carlosbuenosvinos.ansible-deploy role
* Set up role variables (see "Role Variables")
* Run the deployment playbook

```ansible-playbook -i hosts deploy.yml```

If everything has been set up properly, this command will create the following approximate directory structure on your server. Check how the hosts folder structure would look like after one, two and three deployments.

```
-- /var/www/my-app.com
|-- current -> /var/www/my-app.com/releases/20100509145325
|-- releases
|   |-- 20100509145325
|-- shared
```

```
-- /var/www/my-app.com
|-- current -> /var/www/my-app.com/releases/20100509150741
|-- releases
|   |-- 20100509150741
|   |-- 20100509145325
|-- shared
```

```
-- /var/www/my-app.com
|-- current -> /var/www/my-app.com/releases/20100512131539
|-- releases
|   |-- 20100512131539
|   |-- 20100509150741
|   |-- 20100509145325
|-- shared
```

Rollbacking
-----------

In order to rollback with Ansistrano, you need to set up the deployment and run the rollback playbook.

```ansible-playbook -i hosts rollback.yml```

If you try to roll back with zero or one releases deployed, an error will be raised and no actions performed.

Variables you can tune in rollback role are less than in deploy one:

```yaml
- vars:
  ansistrano_deploy_to: "/var/www/my-app" # Base path to deploy to.
  ansistrano_version_dir: "releases" # Releases folder name
  ansistrano_current_dir: "current" # Softlink name. You should rarely changed it.

  # Hooks: custom tasks if you need them
  ansistrano_before_symlink_tasks_file: "{{ playbook_dir }}/<your-deployment-config>/my-before-symlink-tasks.yml"
  ansistrano_after_symlink_tasks_file: "{{ playbook_dir }}/<your-deployment-config>/my-after-symlink-tasks.yml"
  ansistrano_before_cleanup_tasks_file: "{{ playbook_dir }}/<your-deployment-config>/my-before-cleanup-tasks.yml"
  ansistrano_after_cleanup_tasks_file: "{{ playbook_dir }}/<your-deployment-config>/my-after-cleanup-tasks.yml"
```

Multistage environment (devel, preprod, prod, etc.)
---------------------------------------------------

If you want to deploy to different environments such as devel, preprod and prod, it's recommended to create different hosts files. When done, you can specify a different host file when running the deployment playbook using the **-i** parameter. On every host file, you can specify different users, password, connection parameters, etc.

```ansible-playbook -i hosts_devel deploy.yml```

```ansible-playbook -i hosts_preprod deploy.yml```

```ansible-playbook -i hosts_prod deploy.yml```

Hooks: Custom tasks
-------------------

You will typically need to reload your webserver after the `Symlink` step, or download your dependencies before `Code update` or even do it in production before the `Symlink`. So, in order to perform your custom tasks you have some hooks that Ansistrano will execute before and after each of the main 3 steps. **This is the main benefit against other similar deployment roles.**

```
-- /my-local-machine/my-app.com
|-- hosts
|-- deploy.yml
|-- my-custom-tasks
|   |-- before-code-update.yml
|   |-- after-code-update.yml
|   |-- before-symlink.yml
|   |-- after-symlink.yml
|   |-- before-cleanup.yml
|   |-- after-cleanup.yml
```

For example, in order to restart apache after `Symlink` step, we'll add in the `after-symlink.yml`

```
- name: Restart Apache
  service: name=httpd state=reloaded
```

* **Q: Where would you add sending email notification after a deployment?**
* **Q: (for PHP and Symfony developers) Where would you clean the cache?**

You can specify a custom tasks file for before and after every step using `ansistrano_before_*_tasks_file` and `ansistrano_after_*_tasks_file` role variables. See "Role Variables" for more information.

Variables in custom tasks
-------------------------

When writing your custom tasks files you may need some variables that Ansistrano makes available to you:

* ```{{ ansistrano_timestamp.stdout }}```: Timestamp for the current deployment
* ```{{ ansistrano_release_path.stdout }}```: Path to current deployment release (probably the one you are going to use the most)
* ```{{ ansistrano_releases_path.stdout }}```: Path to releases folder
* ```{{ ansistrano_shared_path.stdout }}```: Path to shared folder (where common releases assets can be stored)

Pruning old releases
--------------------

In continuous delivery environments, you will possibly have a high number of releases in production. Maybe you have tons of space and you don't mind, but it's common practice to keep just a custom number of releases.

After the deployment, if you want to remove old releases just set the `ansistrano_keep_releases` variable to the total number of releases you want to keep.

Let's see three deployments with an `ansistrano_keep_releases: 2` configuration:

```
-- /var/www/my-app.com
|-- current -> /var/www/my-app.com/releases/20100509145325
|-- releases
|   |-- 20100509145325
|-- shared
```

```
-- /var/www/my-app.com
|-- current -> /var/www/my-app.com/releases/20100509150741
|-- releases
|   |-- 20100509150741
|   |-- 20100509145325
|-- shared
```

```
-- /var/www/my-app.com
|-- current -> /var/www/my-app.com/releases/20100512131539
|-- releases
|   |-- 20100512131539
|   |-- 20100509150741
|-- shared
```

See how the release `20100509145325` has been removed.

Example Playbook
----------------

In the folder, `example` you can check an example project that shows how to deploy with Ansistrano. In order to run it, you should:

```
$ cd example
$ ansible-playbook -i hosts deploy.yml
```

Sample projects
---------------

We have added Ansistrano support for other projects we are working on.

* LastWishes: Domain-Driven Design PHP Sample App: https://github.com/dddinphp/last-wishes

As an example, see the execution log of the LastWishes deployment:

```
PLAY [Deploy last wishes app to my server] ************************************

GATHERING FACTS ***************************************************************
ok: [quepimquepam.com]

TASK: [carlosbuenosvinos.ansistrano-deploy | Ensure deployment base path exists] ***
ok: [quepimquepam.com]

TASK: [carlosbuenosvinos.ansistrano-deploy | Ensure releases folder exists] ***
ok: [quepimquepam.com]

TASK: [carlosbuenosvinos.ansistrano-deploy | Ensure shared elements folder exists] ***
ok: [quepimquepam.com]

TASK: [carlosbuenosvinos.ansistrano-deploy | Get release timestamp] ***********
changed: [quepimquepam.com]

TASK: [carlosbuenosvinos.ansistrano-deploy | Get release path] ****************
changed: [quepimquepam.com]

TASK: [carlosbuenosvinos.ansistrano-deploy | Get releases path] ***************
changed: [quepimquepam.com]

TASK: [carlosbuenosvinos.ansistrano-deploy | Get shared path (in rsync case)] ***
changed: [quepimquepam.com]

TASK: [carlosbuenosvinos.ansistrano-deploy | Rsync application files to remote shared copy (in rsync case)] ***
changed: [quepimquepam.com -> 127.0.0.1]

TASK: [carlosbuenosvinos.ansistrano-deploy | Deploy existing code to servers] ***
changed: [quepimquepam.com]

TASK: [carlosbuenosvinos.ansistrano-deploy | Deploy existing code to remote servers] ***
skipping: [quepimquepam.com]

TASK: [carlosbuenosvinos.ansistrano-deploy | Update remote repository] ********
skipping: [quepimquepam.com]

TASK: [carlosbuenosvinos.ansistrano-deploy | Export a copy of the repo] *******
skipping: [quepimquepam.com]

TASK: [carlosbuenosvinos.ansistrano-deploy | Deploy code from to servers] *****
skipping: [quepimquepam.com]

TASK: [carlosbuenosvinos.ansistrano-deploy | Copy release version into REVISION file] ***
changed: [quepimquepam.com]

TASK: [carlosbuenosvinos.ansistrano-deploy | Touches up the release code] *****
changed: [quepimquepam.com]

TASK: [carlosbuenosvinos.ansistrano-deploy | Change softlink to new release] ***
changed: [quepimquepam.com]

TASK: [carlosbuenosvinos.ansistrano-deploy | Reload Apache] *******************
changed: [quepimquepam.com]

TASK: [carlosbuenosvinos.ansistrano-deploy | Clean up releases] ***************
skipping: [quepimquepam.com]

PLAY RECAP ********************************************************************
quepimquepam.com           : ok=14   changed=10   unreachable=0    failed=0
```

License
-------

MIT

Other resources
---------------

* [Thoughts on deploying with Ansible](http://www.future500.nl/articles/2014/07/thoughts-on-deploying-with-ansible/)
