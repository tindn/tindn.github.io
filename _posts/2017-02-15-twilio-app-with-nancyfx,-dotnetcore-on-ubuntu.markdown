---
layout: post
title: Twilio App with NancyFx, DotNetCore on Ubuntu
date: 2017-02-15 21:52:33 -0600
categories: development
tags: twilio, dotnet, nancy, nancyfx, dotnetcore, ubuntu
---
I want to build a Twilio messaging application and host it myself. The motivation is 
to build the application using C# and open source tools and 
frameworks. So I started out with a [DigitalOcean](https://digitalocean.com) Ubuntu 
droplet and [dotnet core](https://www.microsoft.com/net/core). I was going to use 
the usual WebApi that .NET provides. However, as I was going through the template 
options avaialble fromt the yeoman .NET generator, I saw [NancyFx](http://nancyfx.org) 
and got curious. While I'm still not sure if this is a good idea, I am tired of the
"messy" files and folder structure that WebApi comes with, so I took the plunge. 
Here is how I got started.

The application is called Lily, and is hosted on my 
[github repo](https://github.com/tindn/lily). Below are the setup steps

1. Create a DigitalOcean Ubuntu droplet, or any cloud service provider
2. SSH into the server
3. Install dotnetcore on the server. The step-by-step instructions can be found 
[here](https://www.microsoft.com/net/core#linuxubuntu). To save you a click, 
assuming you're using Ubunto 16.04, the steps are
    
    sudo sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list'

    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893

    sudo apt-get update

    sudo apt-get install dotnet-dev-1.0.0-preview2.1-003177

Please check with the website to get the latest information as dotnetcore is changing
quite rapidly. The dotnetcore package mentioned above is the .NET Core 1.1, as listed 
[here](https://www.microsoft.com/net/download/linux)

4. Once you have installed dotnet, you can check the version by running 
'dotnet --version'. The version being used is **1.0.0-preview2-1-003177**.
5. Cloning the application code from github to the server. I put my code in the folder
'/home'. A simple 'git clone https://github.com/tindn/lily.git' will do the trick.
6. You can restore packages for the app by running 'dotnet restore'
7. With all the packages restored, let's compile the app by running 'dotnet build'
8. And finally, run the app with 'dotnet run'. If everything works, it should tell you 
the port the app is running on.