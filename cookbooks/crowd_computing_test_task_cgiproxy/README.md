crowd_computing_test_task_cgiproxy
==========================
When this cookbook applied on the node you actually will get the following:
 - nginx http server as service
 - cgiproxy with fast_cgi thru socket file as service
 - monit to monitor both 'nginx' and 'cgiproxy' as service

When the cookbook applied on the node you will be able navigate to 'https://NODEFQDN/proxy' and use you new proxy service without any restrictions.

Implementation
--------------
Following HTTP redirects/rewrites implemented to insure secure usage:
- 'http://NODEFQDN' -> 'https://NODEFQDN/proxy'
- 'https://NODEFQDN' -> 'https://NODEFQDN/proxy'
- 'http://NODEFQDN/proxy/ANYTHING' -> 'https://NODEFQDN/proxy/ANYTHING'

For monitoring 'monit' service is included in this cookbook. 
'monit' monitoring can be access on 2812 port: 'http://NODEFQDN:2812'.
User: admin
Password: monit

What monit is monitoring:
1. 'nginx' service. Will restart 'nginx' if 80 or 443 ports are failed or no '/var/run/nginx.pid' file is presend
2. 'perl-fcgi-pm' file (cgiproxy service). Will restart 'cgiproxy' if no '/var/run/cgiproxy.pid' file is presend
3. 'perl-fcgi' files count. Will execute 'killall -2 perl-fcgi' if more then 30 processes detected. By default I configured 'cgiproxy' to         handle only 20 child processes.


'cgiproxy' deployed in '/opt/cgiproxy' directory. This perl script is customized and that is why it included in cookbook.
What is implemented:
- HTTPS support enabled
- Number of childs reduced to '20'
- X-Frame-Options header is ommited for all responces
- Javascript executions prevented

Structure
---------
Solution consists of the following files:

####./files/default/cgiproxy
This is startup script for 'cgiproxy' service. Placed in '/etc/init.d'. Following commands implemented: 'start','stop','restart','status'.

####./files/default/nph-proxy.cgi
This is core of the solution. This is customized perl script that do all the work.
Following is changed:
- HTTPS support enabled
- Number of childs reduced to '20'
- X-Frame-Options header is ommited for all responces
- Javascript executions prevented
This perl script placed in '/opt/cgiproxy' directory. Not sure if this is best approach, but I like when all custom soft not provided from repositories are stored in '/opt' directory
    
####./files/default/perlmon
This is tiny helper script to get count of 'perl-fcgi' processes on the server. I configured 'monit' to monit this number. In some cases I expireneced strange behavior when not all 'perl-fcgi' processes correctly removed.
    
####./libraries/provider_ssl_certificate.rb
####./libraries/provider_ssl_certificate.rb
This is only one 'third-party' implementation I used to generate and manage SSL self-signed certificates.
    
####./recipes/defaul.rb
Recipe file that is doing all deployment work. PLEASE BE AWARE! I've been asked to deploy all dependancies as packages. This is working file on ubuntu_14.04 but not on ubuntu_12.04 or debian_7. Package in question is 'libio-compress-lzma-perl' which is not presented on mantioned systems. That is why recipe will beploy this perl module using 'cpan' utility if no 'libio-compress-lzma-perl' is presented in repositories.

####./templates/default/monit-config.erb
My custom 'monit' template.

####./templates/default/nginx-config.erb
My custom 'nginx' config file template. Decided to write my own template for better customizations.

My Thoughts
-----------
This cookbook implemented to cover custom 'test task' requerements.
I know at least two ways how this task could be done.

First one. That I actually implemented here
Use as less dependancies as possible. That means that I have only base resource and providers.

Why I decided to go with this approach:
1. No expierence. So I simply do not trust anybody but myself
2. I do not know environment where cookbook will be deployed. It could be restrictions on using third-party cookbooks

Now, when my expierence increased I could try 'Second' alternate approach.
This approach will utilize as mush cookbooks provided by community as possible. I can see only one big advantage of this - Do not Repeat Yourself. Also because contributers spending more time on their cookbooks, potencially they have less bugs in them.
