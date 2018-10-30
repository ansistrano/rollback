Ansistrano
==========

[![Build Status](https://travis-ci.com/ansistrano/rollback.svg?branch=master)](https://travis-ci.org/ansistrano/rollback)

**ansistrano.deploy** and **ansistrano.rollback** are Ansible roles to easily manage the deployment process for scripting applications such as PHP, Python and Ruby. It's an Ansible port for Capistrano.

BC Breaks in 3.0
----------------

You should know we have broken BC by moving from using `ansistrano_before_cleanup_tasks_file` to `ansistrano_rollback_before_cleanup_tasks_file` and the same for all hooks. See "Role Variables". **Although your old playbooks may still run with no errors, you will see that your code is rolled back but custom tasks are not run.**

You can check [this Pull Request](https://github.com/ansistrano/rollback/pull/21) for more details

History
-------

[Capistrano](http://capistranorb.com/) is a remote server automation tool and it's currently in Version 3. [Version 2.0](https://github.com/capistrano/capistrano/tree/legacy-v2) was originally thought in order to deploy RoR applications. With additional plugins, you were able to deploy non Rails applications such as PHP and Python, with different deployment strategies, stages and much more. I loved Capistrano v2. I have used it a lot. I developed a plugin for it.

Capistrano 2 was a great tool and it still works really well. However, it is not maintained anymore since the original team is working in v3. This new version does not have the same set of features so it is less powerful and flexible. Besides that, other new tools are becoming easier to use in order to deploy applications, such as Ansible.

So, I have decided to stop using Capistrano because v2 is not maintained, v3 does not have enough features, and I can do everything Capistrano was doing with Ansible. If you are looking for alternatives, check Fabric or Chef Solo.

Project name
------------

Ansistrano comes from Ansible + Capistrano, easy, isn't it?

Ansistrano anonymous usage stats
--------------------------------

We have recently added an extra optional step in Ansistrano so that we can know how many people are deploying their applications with our project. Unfortunately, Ansible Galaxy does not provide any numbers on usage or downloads so this is one of the only ways we have to measure how many users we really have.

You can check the code we use to store your anonyomus stats at [the ansistrano.com repo](https://github.com/ansistrano/ansistrano.com) and anyway, if you are not comfortable with this, you will always be able to disable this extra step by setting `ansistrano_allow_anonymous_stats` to false in your playbooks.

Requirements
------------

In order to deploy your apps with Ansistrano, you will need:

* Ansible in your deployer machine

Installation
------------

Ansistrano is an Ansible role distributed globally using [Ansible Galaxy](https://galaxy.ansible.com/). In order to install Ansistrano role you can use the following command.

```
$ ansible-galaxy install ansistrano.deploy ansistrano.rollback
```

Update
------

If you want to update the role, you need to pass **--force** parameter when installing. Please, check the following command:

```
$ ansible-galaxy install --force ansistrano.deploy ansistrano.rollback
```

Role Variables
--------------

```yaml
vars:
  ansistrano_deploy_to: "/var/www/my-app" # Base path to deploy to.
  ansistrano_version_dir: "releases" # Releases folder name
  ansistrano_current_dir: "current" # Softlink name. You should rarely changed it.
  ansistrano_rollback_to_release: "" # If specified, the application will be rolled back to this release version; previous release otherwise.
  ansistrano_remove_rolled_back: yes # You can change this setting in order to keep the rolled back release in the server for later inspection
  ansistrano_allow_anonymous_stats: yes

  # Hooks: custom tasks if you need them
  ansistrano_rollback_before_setup_tasks_file: "{{ playbook_dir }}/<your-deployment-config>/my-rollback-before-setup-tasks.yml"
  ansistrano_rollback_after_setup_tasks_file: "{{ playbook_dir }}/<your-deployment-config>/my-rollback-after-setup-tasks.yml"
  ansistrano_rollback_before_symlink_tasks_file: "{{ playbook_dir }}/<your-deployment-config>/my-rollback-before-symlink-tasks.yml"
  ansistrano_rollback_after_symlink_tasks_file: "{{ playbook_dir }}/<your-deployment-config>/my-rollback-after-symlink-tasks.yml"
  ansistrano_rollback_before_cleanup_tasks_file: "{{ playbook_dir }}/<your-deployment-config>/my-rollback-before-cleanup-tasks.yml"
  ansistrano_rollback_after_cleanup_tasks_file: "{{ playbook_dir }}/<your-deployment-config>/my-rollback-after-cleanup-tasks.yml"
```

`{{ playbook_dir }}` is an Ansible variable that holds the path to the current playbook.

Further details on Ansistrano
-----------------------------

If you want to know more about Ansistrano, please check the [complete Ansistrano docs](https://github.com/ansistrano/deploy/blob/master/README.md)
