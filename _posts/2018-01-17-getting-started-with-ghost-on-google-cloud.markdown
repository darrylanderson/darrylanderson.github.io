---
layout: post
title: Getting Started With Ghost on Google Cloud
author: darryl
date: '2018-01-17 14:59:56'
cover: assets/images/cover-gce-ghost.jpeg
navigation: True
class: post-template
tags: [google cloud]
---

A while back I started looking for a blogging platform. In my previous companies, when we were just starting up I was often asked "we need a quick blog site for marketing... can you get something up quickly?". The usual choice was WordPress, which always started out great, but over time became more and more of a headache to operate. Especially since I wanted a completely hands-off solution. I decided there had to be something better. Enter [Ghost](http://ghost.org).

With a tech stack consisting of Node.js, Ember.js, and Handlebars, Ghost is a pleasure to install and operate. In less than 30 minutes I had everything running and ready to go.

I also wanted to learn more about Google Cloud. Having created large scale architectures on AWS and Azure, I was familiar with their offerings but hadn't yet explored Google Cloud. This was a perfect opportunity to set up a real service using GCE.

---
## Google Cloud Infrastructure
After creating your Google Cloud free tier account, you should be able to log in to the [console](https://console.cloud.google.com) and see your dashboard.

For the purposes of this guide, we'll keep things simple and use the `default` VPC network. For more advanced configurations (HA, test/staging, etc) you'll want to create separate VPCs and subnets.


### Create VM

Open the Google Cloud console and go to the `Compute Engine -> VM instances` page. Click on `Create Instance`.

Choose a VM name, select a zone (here we've chosen us-central1-a), and change the machine type. Since we're trying to stay in the free tier, we use the `f1.micro` instance type.

Ghost is supported on Ubuntu 16.04, so be sure to change the boot disk type to that image. 

Enable HTTP and HTTPS traffic, then create the instance.

![gce-vm](/content/images/2018/01/gce-vm.png)


### Create SSH Key

On your local workstation, create an SSH key using a command similar to the following:
`ssh-keygen -t rsa -b 4096 -C "myemail@mydomain.com"`

This will create a private/public key pair in the location you choose.

To associate this key with your VM, go to the `Compute Engine -> Metadata -> SSH Keys` page in the Google Cloud console. Add a new key, and paste in the public key value.

You should now be able to ssh to your instance from your local workstation.
`ssh -i [private-key-location] [user]@[ip]`


### Assign Static IP

After the VM creation is complete, our instance will have an ephemeral public IP address assigned. We want to promote this address to a static IP address so that we can make the instance available to the public internet at a fixed location.

From the Google Cloud Console, go to `VPC network -> External IP addresses`.

The external IP address assigned to your VM instance should be listed. Change the type from `Ephemeral` to `Static`.

![gce-static-ip](/content/images/2018/01/gce-static-ip.png)



### Create DNS Entry

Now that we have a static IP address, we can create a DNS entry for our new blog. The process for adding DNS entries will vary depending on your domain registrar.

Let's say your domain name is `mydomain.com`, and you want to host your blog at `blog.mydomain.com`. You need to add an A record which ties the subdomain name `blog` to the static IP address above. An example of this is shown here:

![dns-a-record-1](/content/images/2018/01/dns-a-record-1.png)


---

## Installing Ghost

> In order to squeeze everything into our tiny f1.micro instance, we opt for the sqlite3 database instead of MySQL. For a production site we should instead use the Google Cloud MySQL service (known as Google Cloud SQL).

The [Ghost installation instructions](http://https://docs.ghost.org/v1.0.0/docs/install) are very easy to follow. However, since I had to deviate from them a bit in order to account for sqlite3 as well as the low memory on the f1.micro instance, I'll outline the steps I followed below.

1. Create a swap file to give us more working memory:
```dd if=/dev/zero of=/var/swap bs=1k count=1024k
mkswap /var/swap
swapon /var/swap
echo '/var/swap swap swap default 0 0' >> /etc/fstab
```

2. Install nginx and Node.js:
```sudo apt-get update
sudo apt-get upgrade
sudo apt-get install nginx 
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash 
sudo apt-get install nodejs
```

3. Install ghost-cli:
```sudo npm i -g ghost-cli```

4. Install sqlite3:
```sudo npm i -g sqlite3```

5. Install Ghost:
```sudo mkdir -p /var/www/ghost
sudo chown [user]:[user] /var/www/ghost
cd /var/www/ghost
ghost install --db sqlite3 --dbpath ./content/data/ghost.db
```

---
## Enable SSL 
![le-logo-standard](/content/images/2018/01/le-logo-standard.png)

With the Let's Encrypt service and EFF's certbot, it's easier than ever to obtain and install a free SSL certificate signed by a trusted CA.

First install [certbot](https://certbot.eff.org/#ubuntuxenial-nginx):
```sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python-certbot-nginx 
```

Then run certbot to request and install the certificate into nginx:
`sudo certbot --authenticator webroot --installer nginx`

After restarting nginx (`sudo service nginx restart`), your site should now redirect to https and use a valid certificate.

---
## Next Steps

While this setup is suitable for a low-traffic blog, it doesn't offer many of the characteristics we would expect of an enterprise level service. 

The simplest approach to add some 'enterpriseness' to our blog is to outsource hosting to [Ghost Pro](https://ghost.org/pricing/). While I don't have any personal experience with their service, it certainly looks attractive. Relatively low cost, automated backups, CDN, and we would be helping to support the efforts of the team behind the Ghost software.

But since we're tinkerers and want to see what it would take to do this on our own, let's explore some of the next steps if we want to continue operating the site ourselves...

#### Monitoring

[Pingdom](http://pingdom.com) offers a free basic uptime monitoring service which can alert you if your blog is not available from any part of the globe. While the free version only offers email and push notifications, upgrading to the basic service adds SMS notifications.

For proactive monitoring, paid APM services such as [New Relic](http://newrelic.com), [AppDynamics](http://www.appdynamics.com), or [Dynatrace](http://www.dynatrace.com) can be used. 

Also, Google Cloud offers built-in monitoring through Stackdriver. I'm still looking into this approach.


#### Security

The basic configuration outlined in this post doesn't separate the web tier from the data tier. One of the first steps should be to deploy MySQL in a private subnet with firewall rules that only allow traffic from the web tier.

Additionally, the web tier currently exposes SSH to the public internet. To avoid this, we should utilize a VPN tunnel. Then we can restrict SSH traffic to only flow from the VPN. I will be writing a future post where I describe how to deploy OpenVPN along with Google Authenticator to support a secure, low-cost VPN service.


#### Disaster Recovery

Given our cost comprimise of running sqlite3 directly on the same VM running Ghost, backing up our data can be done by creating a VM snapshot. While we could automate this process, a better approach is to use MySQL.

With MySQL through Google Cloud SQL we can configure a [failover replica](https://cloud.google.com/sql/docs/mysql/high-availability). This replica runs in a different zone than the master. If an outage occurs, a failover will automatically occur to the replica.

Google Cloud SQL also offers a [robust backup facility](https://cloud.google.com/sql/docs/mysql/backup-recovery/backups). While the failover replica provides data protection in the event of a single instance failure, if the entire cluster corrupts our data we need to restore from a backup.


#### Performance

The `f1.micro` instance type is inadequate for anything other than a test site. The `n1-standard-1` with 3.75GB of RAM and 1 VCPU would be a better choice. Assuming it's running an entire month, the cost would be around $25/month.

Using a CDN is an easy way to accelerate content delivery and reduce load on our server(s). Like other cloud providers, Google Cloud offers a robust CDN. Pricing is similar to AWS CloudFront. 


---

## Wrapping Up
Now that we have Ghost up and running on Google Cloud, it's time to start configuring our blog and creating content. Visit the official Ghost Blog for a lot of great ideas:

[Ghost Blog](https://blog.ghost.org/)

Going further, I'd like to set up an Ansible role to install and configure Ghost, and either use Ansible or something like Terraform to orchestrate creation of the Google Cloud infrastructure. But from a build/buy perspective, moving to Ghost Pro's hosting service is probably a better move.


