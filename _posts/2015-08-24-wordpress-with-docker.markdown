---
layout: post
title: "Wordpress with Docker"
date:   2015-08-24 10:27:07 -0500
categories: development
---
I have been trying to set up my Wordpress sites using Docker containers, partly as an effort to learn Docker, and to learn more about server setup, be more familiar with the command line interface rather than the GUI of cPanel. I was using <a href="https://asmallorange.com">ASmallOrange</a> as my hosting solution, and they were quite great. It was cheap. It was quite simple to set everything up using the cPanel (the GUI makes it quite easy to explore around), and their customer support is quite good. I'd recommend it.

For Docker, I'm choosing to host with <a href="https://www.digitalocean.com">DigitalOcean</a>. I created a droplet for 1GB of RAM and 30GB storage, picking from their pre-made Docker image. Of course you can set up an Ubuntu image, and then install Docker on it too, and should get the same thing. I just picked this for simplicity. I'd also recommend choosing the backup option during the creation of your droplet. It increases the hosting price of 25%, but really gives you a peace of mind.

Moving to Docker, the landscape is very much different. You will be the main architect of everything, from setting up your SQL database to phpmyadmin to WP, quite different from simply clicking around on cPanel to add a new database. So the learning curve is steep, not to mention frustrating and intimidating. But it's worth it.

I started out with the tutorial called Introduction to Docker for Wordpress Developers, and you can find it <a href="http://www.sitepoint.com/author/aleksanderkoko/">here</a>. There are also 4 other tutorials right after that one, covering the different ways to set things up. These will give you a good idea about Docker, and the different Dockerfiles needed. They also talk about using Docker Compose. Docker Compose is a way for you to create multiple dependent containers with a single script. This makes it easier to keep track of everything, and recreate containers easily. This was the approach that I tried initially. However, I realized that using Docker Compose in this set up means I will have to create a separate MySQL containers for each Wordpress site. While this is a viable option, since Docker containers are so lightweight, I opted for having just one MySQL containers, for ease of maintenance and backing up. <a href="https://www.digitalocean.com/community/tutorials/how-to-dockerise-and-deploy-multiple-wordpress-applications-on-ubuntu">Here</a> is another tutorial for setting up Docker on Ubuntu, and then Wordpress, written by DigitalOcean.

Note: before beginning with everything, and right after you set up your droplet, please enable swap on your droplet using <a href="https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-ubuntu-14-04">this tutorial</a>.

Besides creating the droplet, which has a really simple UI, everything else to be done beyond this point, including enabling swap requires SSH access, and doing everything via the command line. When you create the droplet, there's an option for you to upload your private key. If you didn't do that, here's the <a href="https://www.digitalocean.com/community/tutorials/how-to-connect-to-your-droplet-with-ssh">tutorial for SSH access</a>.

So we begin by SSH into the droplet, by simply typing in the command

<code>ssh root@droplet.ip.address</code>

The root user should be setup for you. There are articles advising against doing everything as root. So if you want, after getting in as root, you can create another user, and log out, and log in again as that user.

Assuming Docker is already installed, you can type <strong><em>docker -v</em></strong> to check the version of Docker you have. Mine is 1.7.1. Here's a break down of what we need to do:
<ol>
	<li><a href="#install-nginx">Install Nginx and use this as a reverse proxy.</a></li>
	<li><a href="#mysql-container">Set up MySQL container.</a></li>
	<li><a href="#phpmyadmin-container">Set up phpmyadmin container, which will provide us with phpmyadmin interface to work with MySQL. Otherwise, we can control MySQL through the command line interface.</a></li>
	<li><a href="#wordpress-container">Set up Wordpress container.</a></li>
	<li><a href="#misc-setup">Set up domain name, nginx, Wordpress permission, HTTPS, etc.</a></li>
</ol>
<span id="install-nginx"><strong>Installing Nginx</strong></span>

Run <code>apt-get update </code>to update apt-get, and then <code>apt-get install nginx </code>to install nginx onto your droplet. Once this is done, you can check if nginx is installed correctly at the folder <strong>/etc/nginx</strong>.

To start nginx, simply type <code>nginx</code>. If you don't get any errors, then it is running. Check the status of nginx by typing <code>service nginx status</code>.

<span id="mysql-container"><strong>Setting up MySQL container</strong></span>

We're just going to use the <a href="https://hub.docker.com/_/mysql/">standard mysql repository</a> available on Docker. Here's the command to create the container in the droplet.
<pre><code>docker run -d --name mysql -e MYSQL_DATABASE=database_name -e MYSQL_ROOT_PASSWORD=password -v /var/lib/mysql:/var/lib/mysql mysql</code></pre>
<em>Note: create the folder /var/lib/mysql on your droplet if it's not already there. </em>

This is just a standard docker run command, you can find more information about this on the Docker website. Here's a breakdown of the options just in case: <code>-d</code>means detached. <code>--name </code>specifies the name of the container, here it's just <strong>mysql</strong>. <code>-e</code> specifies the environment variables, which the variable name in caps followed by equal sign and value of the variable. In this case, the variable <code>MYSQL_DATABASE</code> just created a database called <strong>database_name </strong>for me after the container is created. It is optional, and you don't have to create a database at this step yet. The variable <code>MYSQL_ROOT_PASSWORD </code> is mandatory, however. It is required to set up the root user password, so that later, when you want to log into mysql, you can use the username <strong>root</strong> and the password specified here. More information about environment variable for mysql can be found <a href="https://github.com/docker-library/docs/blob/master/mysql/README.md">here</a>. You can check that the container is running properly using the command <code>docker ps</code>. If this container is not on the list, try <code>docker ps -a</code> to list all containers. If this happens, it's possible that there's an error during the creation of the container, try <code>docker logs mysql </code>to check the logs. One common error I have seen is memory exception. This would occur if you have a 500MB RAM droplet. Make sure you enable swap (see above) to prevent this.

If that does occur, you can remove the container and retry to process. Make sure to use <code>docker rm -vF mysql </code>to remove the container. The -v option will remove the mounted volume. Read <a href="https://docs.docker.com/userguide/dockervolumes/">here</a> for more information about volumes.Before creating another container, make sure /var/lib/mysql is empty. Otherwise, you will run into problems with an existing mysql instance.

Speaking of the volume, in the original docker run command, there's another option, <code>-v /var/lib/mysql:/var/lib/mysql</code>. This option mounts the folder /var/lib/mysql (left side of the colon) on the droplet machine to the folder /var/lib/mysql (right side of the colon) on the container machine. If this is confusing to you, don't sweat, it is confusing. Basically the container is like a separate machine, and the <a href="https://github.com/docker-library/mysql/blob/c402b76d72d0089d6e84a2e24c143e99c3cb2919/5.5/Dockerfile">dockerfile</a> tells Docker to install the MySQL instance onto the folder /var/lib/mysql on the container machine. By mounting, you can access this from the host machine. If there's any chance you'll have to recreate your mysql container, this folder will not be deleted, and the new container will have the same mysql instance, with all the data there.

<span id="phpmyadmin-container"><strong>Setting up phpmyadmin container</strong></span>

Next, we create a phpmyadmin container. Phpmyadmin provides the GUI to interact with MySQL. This container is not necessary, but it is helpful since I'm still not very comfortable with just using MySQL command line interface to talk to the MySQL instance. But if you want to try that out, all you need to do is attach to the mysql container, and run bash on it, using

<code>docker exec -it mysql bash</code>

For the phpmyadmin to be able to connect to MySQL instance, we need to link the two containers. The docker command to start the phpmyadmin container is
<pre><code>docker run -d -p 2000:443 --link mysql:mysql --name phpmyadmin marvambass/phpmyadmin</code></pre>
This command uses the<a href="https://github.com/MarvAmBass/docker-phpmyadmin"> marvambass/phpmyadmin image</a>. It is just an image I found online that has phpmyadmin using SSL. All you need to do is to link it to the mysql container, specify the mysql port if you need to (default is 3306. If you didn't change this when installing mysql container, then it is 3306). The new options we see here are <code>-p </code>and <code>--link</code>. <code>-p</code> exposes the port 443 on the container to port 2000 on the host, i.e. everything that will goes to port 2000 on the droplet will be linked to port 443 (ssl) of this container. So you can access phpmyadmin by going to <em>https://droplet.ip.address:2000</em>. Of course you don't have to use port 2000 here, you can use any port (I'd recommend against using 443). The <code>--link</code> option is self-explanatory, it links this container to the mysql container, so that phpmyadmin can talk to the MySQL instance through port 3306.

Once everything is set up, visit the phpmyadmin on https://droplet.ip.address:2000, login using root and the root password you specified when creating mysql container. You should be able to see the familiar phpmyadmin interface connecting to your newly created mysql instance! Well done. Before we begin, go ahead and create a database for the wordpress site you're about to create, and a separate login for that database. These will be used next.

<span id="wordpress-container"><strong>Setting up Wordpress container</strong></span>

You can probably guess by now that we're gonna use docker run command to create the wordpress container. Before you do, create a folder where you will mount the wordpress installation itself to. This will allow you to access wordpress files from the host machine. It will also persists the files in case the container has to be recreated.
<pre><code>docker run --name tinnguyenme_wp_web --link mysql:mysql -e WORDPRESS_DB_NAME=database_name -e WORDPRESS_DB_PASSWORD=password1 -e WORDPRESS_DB_USER=user1 -v /var/www/wordpress_site:/var/www/html -p 1000:80 -d wordpress</code></pre>
All of the options should be familiar at this point. We are using the <a href="https://hub.docker.com/_/wordpress/">standard wordpress image</a> available on docker. I have specified the three environment variables to be used to connect to the right database. The database and credentials you just created should be entered appropriately for these variables. I hope it is self-explanatory. Similar to phpmyadmin, by linking to the mysql container, it allows the wordpress install to talk to the database in the mysql container we created. Here, I'm exposing the standard port 80 on the container to port 1000 on the host droplet. I'm mounting var/www/wordpress_site folder on the host to /var/www/html on the container, as the wordpress install is placed at /var/www/html on the container. To check this, go to /var/www/wordpress_site on the host droplet and you should see the usual wordpress files. This allows us to replace the wp-content folder on the host with our custom one, maybe something from git. You're almost done. Now we have to set up the domain name so that we can navigate to our new wordpress site.

<span id="misc-setup"><strong>Set up domain name, nginx, Wordpress permission, HTTPS, etc.</strong></span>

The next step is to point the domain name you've registered (assuming you're using domain name) to the droplet ip address. The specific details vary based on where you register your domain name with, and which hosting service you're using. Since I'm assuming DigitalOcean, I point my domain name to the three domain name servers provided by DigitalOcean, ns1.digitalocean.com, ns2.digitalocean.com, ns3.digitalocean.com. Once I've done that, I can log into my DigitalOcean account, navigate to the DNS tab, and specify the domain names for the droplet. If you don't have any subdomains, then all you have to do is to create an A record, enter <b>@</b> for the name, and select the IP address of the droplet. That's it. If you have subdomains, then create additional A records, one for each subdomain.

Now, we will use nginx as a reverse proxy to handle the various domain names coming to the droplet. Go to the folder /etc/nginx and open up the file nginx.conf using VIM or whatever editor you want to use on the command line. (If VIM is not yet available, you can install it using apt-get too). Scroll to almost the bottom of the nginx.conf file, still in the http{} block, and you will see the following lines:

<code>include /etc/nginx/conf.d/*.conf;</code>

I have added after that line the following line

<code>include /etc/nginx/sites-enabled/*;</code>

I then create a new file, called reverse-proxy at /etc/nginx/sites-enabled/, so the whole path to the file is /etc/nginx/sites-enabled/reverse-proxy. This is where I will put all the sites I want to use. There's also a file called /etc/nginx/sites-enabled/default that show the examples for this. This is what I use as reference for my reverse-proxy file. You can modify the default file as well, I just wanted to create an additional file to keep it clean.

For each site that I want to route to, I create a new block as follows
<pre><code>#tinnguyen.me
server {
listen 80;
server_name tinnguyen.me www.tinnguyen.me;

location / {
proxy_pass http://0.0.0.0:1000;
proxy_redirect off;
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Host $server_name;
}
}</code></pre>
All this is doing is to tell nginx is to listen on port 80 (default port), and if there's a request for tinnguyen.me or www.tinnguyen.me, then pass the request to http://0.0.0.0:1000. This is a local IP address. Port 1000 is the port I mapped for my wordpress container earlier, which will then be mapped to port 80 of the wordpress container.

After adding this, save the file, and then use the following command to restart nginx <em><strong>service nginx restart</strong></em>. If everything is correct, the command will return the status OK. Otherwise, an error will be thrown, and if it's a syntax error, it will tell you where you got wrong. Fix it and restart nginx. If you run into the error that says <em>[emerg]: bind() to 0.0.0.0:80 failed (98: Address already in use), </em>it's likely that another nginx process is still running and using the port. Using the following two commands to check (these are something I found googling around)

<code>ps ax -o pid,ppid,%cpu,vsz,wchan,command|egrep '(nginx|PID)'</code>

<code>netstat -tunpl | grep 80</code>

If that is the case, you can kill those processes by using the command recommended <a href="https://rtcamp.com/tutorials/nginx/troubleshooting/emerg-bind-failed-98-address-already-in-use/">here</a>. After that, you can start nginx again by typing <em><strong>nginx</strong></em>.

What if you want to use SSL for your wordpress site? Well, you should. Here's how to do it given the set up we have. First, we need to create SSL certificates. You can create a self-signed one as shown in <a href="https://www.digitalocean.com/community/tutorials/how-to-create-an-ssl-certificate-on-nginx-for-ubuntu-14-04">this tutorial</a>. This method is free. However, when you navigate to the site, the browser will throw warning message, since it doesn't recognize the issuer of the cert. Here's a <a href="https://www.digitalocean.com/community/tutorials/how-to-install-an-ssl-certificate-from-a-commercial-certificate-authority">tutorial for creating a commercial cert.</a> Once you've done so, you're ready to use SSL. Make sure you know the locations of the cert and the key from the tutorials.

To accept HTTPS traffic, just add the following block to the /etc/nginx/sites-enabled/reverse-proxy file.
<pre><code>server {
listen 443 ssl;
server_name tinnguyen.me;
ssl_certificate /etc/nginx/ssl/nginx.crt;
ssl_certificate_key /etc/nginx/ssl/nginx.key;
ssl_session_timeout 5m;

location / {
proxy_pass http://0.0.0.0:1000;
proxy_redirect off;
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Host $server_name;
proxy_set_header X-Forwarded-Proto $scheme;
}
}</code></pre>
This is mostly similar to the previous block, but instead of listening on port 80, it is listening on port 443, the standard ssl port. This block also has one additional command, the last line of the location block <em><strong>proxy_set_header X-Forwarded-Proto $scheme;</strong></em>. We will use this in our wp-config.php file later. As you can see, all this does is handle all the https traffic and still pointing it to the usual http port 80. Is this safe? I think it is, since the traffic between the browser and the droplet is still encrypted. But don't quote me on this. I need to research this further. This will require additional settings in the wordpress container. Instead of having two separate blocks, you can combine it to a single server block as well (just use two listen commands: <strong>listen 80;</strong> and <strong>listen 443 ssl;</strong>). You can also rewrite all request on http to be https, by adding the following line <em><strong>rewrite ^/(.*) https://example.com/$1 permanent; </strong></em>as shown in the commercial SSL cert tutorial. I am not doing it for mine because I still want to keep http available, because I don't want to buy a proper commercial SSL cert, yet.

The last step is to add the following lines to your wordpress wp-config.php file.
<pre><code>define('FORCE_SSL_ADMIN', true);
if ($_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https')
  $_SERVER['HTTPS']='on';</code></pre>
Now, you can go to your site via the domain name, and wordpress should take you through the initial set up process. If you just added SSL to an existing wordpress site, make sure you change the site url to https, so that all the resources will be retrieve through https.

I hope this has been helpful. Leave me comments if you have any questions, or for anything else.

PS

Use this comment to make sure wordpress install has access to the file system for updates, uploading images, etc.

<pre><code>chown -R www-data:www-data .</code></pre>