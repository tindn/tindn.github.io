---
layout: post
title: Twilio app with NancyFx and .Net Core on Ubuntu
date: 2017-02-15 21:52:33 -0600
categories: development
tags: twilio, dotnet, nancy, nancyfx, dotnetcore, ubuntu
---
I want to build a Twilio messaging application and host it myself. The motivation is 
to build the application using C# and open source tools and 
frameworks. So I started out with a 
[DigitalOcean](https://digitalocean.com){:target="_blank"} Ubuntu droplet and 
[dotnet core](https://www.microsoft.com/net/core){:target="_blank"}. 
I was going to use the usual WebApi that .NET provides. However, as I was going 
through the template options avaialble fromt the yeoman .NET generator, I saw 
[NancyFx](http://nancyfx.org){:target="_blank"} and got curious. 
While I'm still not sure if this is a good idea, I am tired of the "messy" files 
and folder structure that WebApi comes with, so I took the plunge. Here is how I 
got started.

The application is called Lily, and is hosted on my 
[github repo](https://github.com/tindn/lily-nancyfx){:target="_blank"}. 
Below are the setup steps

1. Create a DigitalOcean Ubuntu droplet, or any cloud service provider
2. SSH into the server
3. Install dotnetcore on the server. The step-by-step instructions can be found 
[here](https://www.microsoft.com/net/core#linuxubuntu){:target="_blank"}. 
To save you a click, assuming you're using Ubuntu 16.04, the steps are
    <pre><code>
    sudo sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list'

    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893

    sudo apt-get update

    sudo apt-get install dotnet-dev-1.0.0-preview2.1-003177
    </code></pre>
    Please check with the website to get the latest information as dotnetcore is changing
    quite rapidly. The dotnetcore package mentioned above is the .NET Core 1.1, as listed 
    [here](https://www.microsoft.com/net/download/linux){:target="_blank"}

4. Once you have installed dotnet, you can check the version by running 
`dotnet --version`. The version being used is **1.0.0-preview2-1-003177**.
5. Cloning the application code from github to the server. I put my code in the folder
'/home'. A simple `git clone https://github.com/tindn/lily-nancyfx.git` will do the trick.
6. You can restore packages for the app by running `dotnet restore`
7. With all the packages restored, let's compile the app by running `dotnet build`
8. And finally, run the app with `dotnet run`. If everything works, it should tell you 
the port the app is running on. The default port is 5000, so you can test your service by 
trying `curl http://localhost:5000`. You will get a welcome message back, indicating the 
application is running.
9. With the app running, we have two more things to do. First is to set up Nginx as a 
reverse proxy. Once that is working correctly, we will need to point Twilio to the right
url of the DigitalOcean droplet. 
10. Installing nginx is as simple as running the command `apt-get install nginx` on your 
Ubuntu server. The easiest way to do this is to add the following block  to your nginx
file `/etc/nginx/sites-avaialble/default`. You can use vim to edit this file
    <pre><code>
    server {
        listen 80;
        server_name <your url, for ex. lily.tindnguyen.com>;
        location / {
                proxy_pass http://localhost:5000;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection keep-alive;
                proxy_set_header Host $host;
                proxy_cache_bypass $http_upgrade;
        }
    }
    </code></pre>   
    I have configured my own domain name to point to DigitalOcean, and set up an A record
    for the subdomain lily.tindnguyen.com, so I can use this to map to the Nancy app.
    If you can just not specify this and use the IP address instead. 
11. Save the nginx file, stop the nancy app, and restart nginx service by running
`service nginx restart`, if you're not logged in as *root*, you might have to use *sudo* 
with that command. Start the nancy app again, and you can test this by hitting the 
endpoint from your local computer. I used `curl http://lily.tindnguyen.com`, but if you
did not use a custom domain, you can use `curl http://<dropletIp>:5000` or whichever 
port you configured with nginx.
12. Go to your twilio account page, go to **Phone Numbers** page, and select the phone 
number you want to use with this app. Under **Messaging**, there's an option to specify 
the url for when a message comes in. In my case, it was `http://lily.tindnguyen.com/twilio`. 
13. And there you have it, a working .NET app talking to and listening to Twilio, written 
on the lightweight NancyFx. From this basic app, the sky is the limit with what you can do.

As extra, I have included below a sample request you would be receiving from Twilio when
a message comes in to help you with your development.

<pre><code>
{
  "ClientCertificate": null,
  "ProtocolVersion": "HTTP/1.1",
  "UserHostAddress": "127.0.0.1",
  "Method": "POST",
  "Url": {
    "Scheme": "http",
    "HostName": "lily.tindnguyen.com",
    "Port": null,
    "BasePath": "",
    "Path": "/twilio",
    "Query": "",
    "SiteBase": "http://lily.tindnguyen.com",
    "IsSecure": false
  },
  "Path": "/twilio",
  "Query": {},
  "Body": {
    "CanRead": true,
    "CanSeek": true,
    "CanTimeout": false,
    "CanWrite": true,
    "Length": 414,
    "IsInMemory": true,
    "Position": 0
  },
  "Cookies": {},
  "Session": [],
  "Files": [],
  "Form": {
    "ToCountry": {},
    "ToState": {},
    "SmsMessageSid": {},
    "NumMedia": {},
    "ToCity": {},
    "FromZip": {},
    "SmsSid": {},
    "FromState": {},
    "SmsStatus": {},
    "FromCity": {},
    "Body": {},
    "FromCountry": {},
    "To": {},
    "ToZip": {},
    "NumSegments": {},
    "MessageSid": {},
    "AccountSid": {},
    "From": {},
    "ApiVersion": {}
  },
  "Headers": [
    {
      "Key": "Cache-Control",
      "Value": [
        "max-age=259200"
      ]
    },
    {
      "Key": "Connection",
      "Value": [
        "keep-alive"
      ]
    },
    {
      "Key": "Content-Length",
      "Value": [
        "414"
      ]
    },
    {
      "Key": "Content-Type",
      "Value": [
        "application/x-www-form-urlencoded"
      ]
    },
    {
      "Key": "Accept",
      "Value": [
        "*/*;q=1"
      ]
    },
    {
      "Key": "Host",
      "Value": [
        "lily.tindnguyen.com"
      ]
    },
    {
      "Key": "User-Agent",
      "Value": [
        "TwilioProxy/1.1"
      ]
    },
    {
      "Key": "X-Twilio-Signature",
      "Value": [
        "GPO8RJKBNVJPW93X2Q**********"
      ]
    }
  ]
}
</code></pre>

Specific message details
<pre><code>
ToCountry: US
ToState: NY
SmsMessageSid: SMdedfd9a253443fbef927ef29eabf4172
NumMedia: 0
ToCity: NEW YORK
FromZip: 02769
SmsSid: SMdedfd9a253443fbef927ef29eabf4172
FromState: MA
SmsStatus: received
FromCity: BROCKTON
Body: Hello Nancy
FromCountry: US
To: +16464614040
ToZip: 10014
NumSegments: 1
MessageSid: SMdedfd9a253443fbef927ef29eabf4172
AccountSid: AC79edd9571e4967d07e24eaf4c4acdea9
From: +19999999999
ApiVersion: 2010-04-01
</code></pre>

*** *NOTE* *** Obviously, this is content getting transfered over the wire with HTTP,
which is **INSECURE**. Therefore, please configure your server to use HTTPS. 
The guide to do so can be found 
[here](https://www.digitalocean.com/community/tutorials/how-to-create-an-ssl-certificate-on-nginx-for-ubuntu-14-04){:target="_blank"}.
There are many options for an SSL Cert, such as [Let's Encrypt](https://letsencrypt.org){:target="_blank"}.

Happy coding.   