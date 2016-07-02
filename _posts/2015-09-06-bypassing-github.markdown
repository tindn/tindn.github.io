---
layout: post
title: "Bypassing Github when using Git"
date:   2015-09-06 10:27:07 -0500
categories: ideas
---
Overheard on the internet (paraphrased):
<blockquote>"Although Git is a distributed system, everybody ends up pushing to GitHub"</blockquote>
When I read this, I was stumped. I do the same thing. And I suspect many developers use the same workflow out there too: Create local repo/Create github repo -&gt; Have github as origin remote -&gt; Make local changes -&gt; Push to origin -&gt; Pull from origin to deployment. In this way GitHub acts as more than just a versioning system. It is also a file-sharing system where I can go and get my code (sort of like Dropbox or Box for code versioning). And it also acts as an external backup for your code, in case, you know, both your local and production goes down for some reason.

Nothing wrong with this workflow. It works, and it helps keeping your projects updated on GitHub to show the world. However, just for the purpose for versioning and deployment, such workflow is not necessary when using Git. So recently, my genius brother <a href="http://tridnguyen.com/">Tri</a> taught me how to set up my repos so that I can do push directly from my local repo to deployment repo, skipping GitHub.

So Git uses ssh to connect to repos, and in order to push directly to your deployment repo (or anywhere that you want to have your code at), you just have to specify the IP address that Git has to connect to, and the path to your git repo on that remote. So for example, if my staging site is located on a DigitalOcean droplet, and the path to the git repo is <em>path/to/repo, </em>all I have to do is to add a remote on my local repo as follows

<code>git remote add staging ssh://ip.to.digitalocean/path/to/repo</code>

So now, your local repo is aware of a remote called staging, and you can push or pull from that remote just as you would with the common "origin" i.e. GitHub remote. Next, we need to configure the repo on the staging remote to accept our push. I don't know much about Git and Git config, but apparently when you initialize a Git repo, it is configure to reject push from overwriting the current branch (makes a lot of sense). So, go to your remote repo ( I'd assume by ssh to the remote using the ip address and then navigate to the path/to/repo), and do the following:

<code>git config receive.denyCurrentBranch updateInstead</code>

All that's left to do is to make some changes on your local repo, add and commit the changes as you normally would, push to your new staging remote instead of origin, and see the magic happens. Before you do this, or maybe after if you get an error, make sure your remote Git is of version 2.5.* or higher. Go to your remote Git repo, and use the following command to check your Git version

<code>git --version</code>

If you don't have the right Git version, use the following command to update your Git
<pre><code>sudo add-apt-repository ppa:git-core/ppa
apt-get update
apt-get install git
</code></pre>
As a bonus for this post (I love giving out bonus stuff), here's how you can configure your SSH so you don't have to type in the IP address every single time you use it. This part assumes that you already have SSH working, and able to connect to your remote, and you know where your .ssh folder is. For mine, it is located under <code>~/tinnguyen/.ssh</code>

Go to the .ssh folder, if there isn't already a file named config, create one by

<code>vim config</code>

Of course you can use any editor you'd like. If this is on your local machine, you can even use TextEditor. Add the following lines
<pre><code>Host nameOfRemote 
  HostName 100.000.000.00 
  User root 

Host * 
  IdentitiesOnly yes </code></pre>
Of course you should replace the nameOfRemote to whatever you desire, and the right IP address. Here, I specify the User as <em>root</em>, but this is not necessary. Please use the user that is set up for ssh on your remote. There are advices out there against using root for ssh, so please set this up appropriately.

So with this set up, if you need to ssh to your remote, all you have to do is

<code>ssh nameOfRemote</code>

And when you need to set up your Git remote, you can just use

<code>git remote add staging ssh://nameOfRemote/path/to/repo</code>

That's all. I have found this quite useful for my workflow. Hope it will help you as well.

All of this knowledge is definitely not mine. I learned this from my generous and too smart brother, Tri. You can check out <a href="http://tridnguyen.com/">his site</a> for more cool stuff.

Happy developing.