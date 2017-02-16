---
layout: post
title: Setup Wire Bot
date: 2017-02-11 09:12:12 -0600
categories: development
tags: wire, java, digitalocean, ubuntu
---
Here's a step by step guide for setting up a wire bot using the 
[wire-bot-java repository](https://github.com/wireapp/wire-bot-java)
from Wire.

I'm hosting the application on an Ubuntu server hosted by 
[DigitalOcean](https://digitalocean.com). Since the Wire bot will be communicating
with the app via https requests, I have already set up my custom domain 
(tindnguyen.com) to point to DigitalOcean. I assume it will still work using just
the IP address of the VM, but this guide is assuming a working custom domain name.

1. Point domain name to your DigitalOcean account.
2. Create a new server (droplet) on DigitalOcean. I just use the minimum 
configuration. I selected the default Ubuntu server. During creation, upload 
a local SSH key from your computer so you can SSH to the server.
3. Point the domain name or a specific A record (for examplle 
wire.tindnguyen.com) to the created server. This is done 
at the Networking tab in DigitalOcean.
4. SSH to the server.
5. 

