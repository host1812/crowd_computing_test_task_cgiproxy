#
# Cookbook Name:: crowd_computing_test_task_cgiproxy
# Recipe:: default
#
# Copyright 2014, host1812@yandex.ru
#
# All rights reserved - Do Not Redistribute
#
package 'nginx' do
    action :install
end

package 'libnet-ssleay-perl' do
    action :install
end

package 'libjson-perl' do
    action :install
end

package 'liblzma-dev' do
    action :install
end

# package 'libio-compress-lzma-perl' do
#   action :install
# end

package 'libfcgi-perl' do
    action :install
end

# execute 'install_lzma' do
#     command "perl -MCPAN -e 'install IO::Compress::Lzma'"
# end

bash "install_lzma_from_cpan" do
    user "root"
    cwd "/tmp"
    code "echo 'yes' | perl -MCPAN -e 'install IO::Compress::Lzma'"
end

# cpan_client 'Compress::Raw::Lzma' do
#     action 'install'
#     install_type 'cpan_module'
#     user 'root'
#     group 'root'
# end
# 
# cpan_client 'IO::Compress::Lzma' do
#     action 'install'
#     install_type 'cpan_module'
#     force true
#     user 'root'
#     group 'root'
# end

package 'libfcgi-procmanager-perl' do
    action :install
end

service 'nginx' do
    action [ :enable, :start ]
    supports :status => true, :restart => true, :reload => true
end

cert = ssl_certificate node['hostname'] do
    namespace node["my-webapp"]
end

nginx_fastcgi '/etc/nginx/sites-available/default' do
    socket '/tmp/cgiproxy.fcgi.socket'
    servers [
        {
            :server_name => "#{node['hostname']}",
            :ssl => true,
            :ssl_file => "#{cert.cert_path}",
            :ssl_key => "#{cert.key_path}",
            :location => '/proxy'
            # :redirect => 'https'
        }
    ]
    simple_servers [
        {
            :port => '80',
            :server_name => "#{node['hostname']}",
            :location => '/',
            :redirect => 'https://$server_name/proxy'
        }
    ]
end

directory '/opt/cgiproxy' do
end

cookbook_file '/opt/cgiproxy/nph-proxy.cgi' do
	source "nph-proxy.cgi"
	mode 0755
end

cookbook_file '/etc/init.d/cgiproxy' do
	source "cgiproxy"
	mode 0755
	notifies :restart, "service[cgiproxy]", :immediately
end

service 'cgiproxy' do
  action [ :enable, :start ]
  supports :status => true, :restart => true
end

# log "WebApp1 certificate is here: #{cert.cert_path}"
# log "WebApp1 private key is here: #{cert.key_path}"
# log "WebApp1 private key is here: #{node['hostname']}"