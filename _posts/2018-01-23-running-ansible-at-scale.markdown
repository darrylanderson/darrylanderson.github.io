---
layout: post
title: Running Ansible at Scale
author: darryl
date: '2018-01-23 02:56:39'
cover:  assets/images/cover-ansible.jpeg
navigation: True
class: post-template
tags: [devops]
---

I've used plenty of automation solutions over the years. Chef, Puppet, Fabric, SaltStack, Capistrano, custom scripts, etc... all of them work well to varying degrees, but only one tool has stood the test of time for me. That tool is [Ansible](https://ansible.com).

In my humble opinion, no other tool combines the same level of functionality, ease of use, maintainability, portability, extensibility, and security as Ansible. I've used it for everything as simple as checking the time on a fleet of AWS EC2 instances, to complex orchestration operations like a zero-downtime blue/green deployment.

In this article I'll give a brief overview of Ansible, and then quickly jump into some examples of how I've used it in the past for automation activities in a cloud environment.


## The Basics

Ansible uses an agentless approach, making it a perfect fit for dynamic cloud environments. Since it uses SSH to communicate with remote hosts, there's no additional infrastructure required.

Ansible has 3 primary concepts:

* **Host Inventory**: A set of named groupings of hosts. It can be a static map, or it can be dynamic when dealing with constantly changing cloud infrastructure.
* **Playbooks**: Indicates to Ansible which set of hosts should have what tasks performed on them. For example, there may be a web server farm which should all have Nginx installed.
* **Roles**: A grouping of tasks run on a single host. For example, there may be a role for installing, configuring, and starting Nginx. A role has no concept of _which_ host it will apply to.


We'll look at each of these in more detail in the following sections.


## Host Inventory



### Static Host Inventory

The simplest approach to defining host groupings is with a static inventory file.

>`inventories/mycloud/hosts`
>```
>[webservers]
>10.0.0.1
>10.0.0.2
>10.0.0.3
>
>[dbservers]
>10.10.0.1
>10.10.0.2
>```

This file defines 3 "webserver" hosts, and 2 "dbserver" hosts. While this may be fine when dealing with a traditional data center, it becomes nearly impossible to manage in a dynamic cloud environment. What we want is for the list of hosts to be dynamically constructed based on metadata. This is what the dynamic inventory feature of Ansible provides.


### Dynamic Host Inventory

[Dynamic inventory](http://docs.ansible.com/ansible/latest/intro_dynamic_inventory.html) is what makes Ansible such a great fit in a cloud environment. As servers come and go, Ansible can dynamically build a list of hosts. 

The exact mechanism of how this works depends on the cloud provider. In AWS, a script `ec2.py` is used to make calls to the EC2 metadata service and group hosts by whatever metadata you choose. For example, you may have a web server farm consisting of a number of identically configured servers running Nginx. You could add EC2 tags for each instance using a key of "Service", and a value of "Webserver". Ansible's dynamic inventory can then be used to discover any of these EC2 instances using the host name `tag_Service_Webserver`. 

A similar option exists for [Azure](http://docs.ansible.com/ansible/latest/guide_azure.html). In this case the script is called `azure_rm.py`. 

For [Google Cloud](http://docs.ansible.com/ansible/latest/guide_gce.html) the script is `gce.py`.

All of the available dynamic inventory scripts can be found here: 
https://github.com/ansible/ansible/tree/stable-2.4/contrib/inventory.

To use these scripts, place them in a subdirectory of the `inventory` folder. For example, this is what my folder structure looks like for AWS.

```
inventories/aws/ec2.py
inventories/aws/ec2.ini
```

To use the inventory, simply pass it to the ansible-playbook command.

`ansible-playbook -i inventories/aws playbooks/myplaybook.yml`



## Playbooks

Now that we know how to define named groups of hosts, we can create a playbook. A playbook is a yaml file which describes the tasks and roles which should be applied to a given set of hosts.

In the example below, we configure any EC2 instance with the tag key-value pair of "service:zeppelin" to run Apache Zeppelin (a fantastic data analytics workbench).

> `playbooks/setup-zeppelin.yml`
>```yaml
> ---
> - hosts: tag_service_zeppelin
>   become: true  
>   roles:
>   - java8
>   - zeppelin
>```

For all matching hosts, this playbook will first apply the `java8` role, and then the `zeppelin` role. It is the responsiblity of the role to define what should actually happen.


## Roles

Defining [roles](http://docs.ansible.com/ansible/latest/playbooks_reuse_roles.html) is where most of the work takes place in setting up an Ansible-based automation solution. The role is where you define what packages to install, any users to create, systemd templates, configuration file templates, start/stop the service, etc. 

Fortunately a large and active community can be found at [Ansible Galaxy](https://galaxy.ansible.com/). There you can find roles already built for most common applications.




## Variables

We want to reuse our playbooks and roles as much as possible, so we'll extract any environment-specific values into variables.

With a dynamic inventory, you can easily group variables by host group using the following layout:
```
inventories/aws/group_vars/tag_PROD_webserver/vars.yml
inventories/aws/group_vars/tag_PROD_webserver/vault.yml
```

`vars.yml` contains property key-values that don't need to be encrypted at rest.
```yaml
---
http_port: 8080
```

`vault.yml` uses [Ansible Vault](https://docs.ansible.com/ansible/2.4/vault.html) to store properties requiring encryption. Database passwords, private keys, etc. Start by creating a plain text properties file called `vault.yml` as follows:
```yaml
---
db_password: some_complex_password
```

To encrypt the file:
`ansible-vault encrypt vault.yml`

To use the encrypted values during a playbook run, you need to supply the vault password. One way is to prompt for it with the `--ask-vault-pass` flag:
`ansible-playbook --ask-vault-pass -i inventories/aws playbooks/myplaybook.yml`


## Directory Layout

Ansible has a [recommended directory layout](http://docs.ansible.com/ansible/latest/playbooks_best_practices.html#directory-layout), but I've found that having all the playbooks at the root level adds clutter.

This is the structure that has worked well for me:

```
inventories/
    aws/
        ec2.py
        group_vars/      # variables for groups

playbooks/  
    setup-kafka.yml    # playbook to setup a Kafka cluster
    deploy-myapp.yml   # playbook to deploy 'myapp'
    
    roles/
        common/
        kafka/
        java8/
        myapp/
```


## Putting It All Together

The title of this article was "Running Ansible at Scale". But we haven't yet addressed how all of this should work when dealing with multiple teams, prod/uat/dev environments, and how to meet the normal enterprise requirements of least privilege and separation of duties.

In order for Ansible to work we need a control server somewhere. I've found it works best to have separate control servers as dictated by security requirements. For example, you might have a locked down server for production automation, and a separate one for uat automation. This allows you to limit what each Ansible master can do. Network isolation, security groups, and separate SSH keys all contribute to keeping things locked down.

You also should limit _who_ is allowed to run Ansible. My preferred approach here is to restrict ssh access to the Ansible control hosts by using named-user accounts along with MFA. See here for details on how to do this: 
https://www.andersontech.consulting/multifactor-everything

And finally, you need to ensure you have a full audit trail. All of your Ansible code should be stored in a version control system. Each Ansible playbook run should write its log output to a centralized logging system. While I prefer using syslog along with a log shipping system such as logstash, there are plenty of other logging options detailed here: https://docs.ansible.com/ansible/devel/plugins/callback.html

An excellent option for integrating Ansible into an enterprise is to use the commercial [Ansible Tower](https://www.ansible.com/products/tower) product, or the open-source upstream [AWX](https://github.com/ansible/awx) project.





## Examples

### Time Checks

Ansible can be used to run ad-hoc commands across a set of hosts. Basically we forgo the use of a playbook, and instead execute a single command.

The example below shows how to run an arbitrary command across a set of servers. In this case, we want to check the time and date of all EC2 instances with a tag key of `Role` and value of `PROD_apigateway`, `PROD_serviceA`, or `PROD_serviceB`. This particular command is useful to check for any servers with excessive clock drift due to ntp issues.

```
ansible tag_Role_PROD_apigateway, tag_Role_PROD_serviceA, tag_Role_PROD_serviceB -i inventories/aws -a "date"
```


### Rolling AWS Deployment

The real value of playbooks can be seen when a complex orchestration of operations need to be performed across a fleet of servers.

Let's assume we have a fairly basic web application architecture. A fronting web server farm, an application server cluster, and a backend MySQL database.  We also assume that our applications can tolerate simultaneous different versions running across tiers.

![Web-App-Reference-Architecture-1](/content/images/2018/01/Web-App-Reference-Architecture-1.png)


At a high level, our deployment pipeline requires the following tasks to be orchestrated by Ansible (all running from the Ansible control host in our AWS devzone).

1. Record start of deployment process in release tracking tool
2. Perform database schema upgrade
3. For each tier (webserver, appserver):
    1. Disable monitoring
    2. Remove server from ELB pool
    3. Shut down application
    4. Update application
    5. Start application
    6. Enable monitoring
    7. Add server to ELB pool
    8. Wait for service to pass health checks  
4. Record deployment complete in release tracking tool

Here is a sample playbook showing the process:

```yaml
---
#################
# Send a slack notification that the deployment is starting
################# 
- hosts: tag_Role_PROD_webserver  
  tasks:
    - name: Send slack notification
      slack:
        token: "{{ slack_token }}"
        msg: "Starting production deployment..."
        color: warning
        icon_url: ''
      run_once: true
      delegate_to: localhost


#################
# Run database scheme update
################# 
- hosts: tag_Role_PROD_db 
  roles:
    - database.liquibase


#################
# Rolling deployment: web server farm
################# 

# Roll out updates to the webserver farm 2 nodes at a time
- hosts: tag_Role_PROD_webserver
  become: yes  
  serial: 2

  # These are the tasks to run before applying updates:
  pre_tasks:    
    - name: Gather EC2 facts
      action: ec2_facts

    - name: disable the server in the loadbalancer
      local_action: ec2_elb
      args:
        instance_id: "{{ ansible_ec2_instance_id }}"
        region:      "us-west-2"
        ec2_elbs:    "{{ aws_elb_webserver }}"
        state:       'absent'

    - name: Disable service monitor
      service: name='zabbix-agent' state=stopped

  # Execute the deployment
  roles:  
    - application.webserver.deploy    

  # These tasks run after the roles:
  post_tasks:
    - name: Enable service monitor
      service: name='zabbix-agent' state=started

    - name: Add instance to ELB... will wait up to 5 minutes for healthy checks to pass
      local_action: ec2_elb
      args:
        instance_id:  "{{ ansible_ec2_instance_id }}"
        region:       "us-west-2"
        ec2_elbs:     "{{ aws_elb_webserver }}"
        wait_timeout: 300
        state:        'present'


#################
# Rolling deployment: application server cluster
################# 

# Roll out updates to the app server cluster 2 nodes at a time
- hosts: tag_Role_PROD_appserver
  become: yes  
  serial: 2

  # These are the tasks to run before applying updates:
  pre_tasks:    
    - name: Gather EC2 facts
      action: ec2_facts

    - name: disable the server in the loadbalancer
      local_action: ec2_elb
      args:
        instance_id: "{{ ansible_ec2_instance_id }}"
        region:      "us-west-2"
        ec2_elbs:    "{{ aws_elb_appserver }}"
        state:       'absent'

    - name: Disable service monitor
      service: name='zabbix-agent' state=stopped

  # Execute the deployment
  roles:  
    - application.appserver.deploy    

  # These tasks run after the roles:
  post_tasks:
    - name: Enable service monitor
      service: name='zabbix-agent' state=started

    - name: Add instance to ELB... will wait up to 5 minutes for healthy checks to pass
      local_action: ec2_elb
      args:
        instance_id:  "{{ ansible_ec2_instance_id }}"
        region:       "us-west-2"
        ec2_elbs:     "{{ aws_elb_appserver }}"
        wait_timeout: 300
        state:        'present'


#################
# Send a slack notification that the deployment is complete
################# 
- hosts: tag_Role_PROD_webserver
  tasks:
    - name: Send slack notification
      slack:
        token: "{{ slack_token }}"
        msg: "Production deployment complete."
        color: good
        icon_url: ''
      run_once: true
      delegate_to: localhost

```

## Conclusion

In this post I've briefly outlined some of the concepts and approaches to using Ansible for configuration management and orchestration. With a mature product, active community, and a focus on simplicity, Ansible is a great tooling choice to manage your cloud infrastructure and applications.

If you'd like to see working examples of some of these concepts, feel free to visit my GitHub repo: 
https://github.com/darrylanderson/ansible-aws

---

<p style="text-align: center;">Also published on <a href="https://dzone.com/articles/running-ansible-at-scale">DZone</a>.</p>

---