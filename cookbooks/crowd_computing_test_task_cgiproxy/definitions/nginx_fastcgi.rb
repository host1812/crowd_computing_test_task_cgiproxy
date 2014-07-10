define :nginx_fastcgi, :servers => [], :root => nil, :static => [], :fastcgi_param => [], :error_page => [], :fastcgi_intercept_errors => false do

    if (params[:socket].nil? || params[:socket].empty?)  and (params[:inet_socket].nil? || params[:inet_socket].empty?)
        message = 'you should setup either socket or inet_socket param. '
        raise message
    end

    params[:servers].each do |s|
        s[:server_alias] ||= []
        s[:ssl] ||= false
        s[:port] ||= (s[:ssl] == true ? 443 : 80)
        s[:location] ||= '/'

        if s[:server_name].nil? || s[:server_name].empty?
            message = 'you should setup server_name for your virtual host. '
            message << "virtual host string passed : #{s.inspect}"
            raise message
        end
        s[:static] ||= []
    end

    params[:simple_servers].each do |s|
        s[:server_alias] ||= []
        s[:ssl] ||= false
        s[:port] ||= (s[:ssl] == true ? 443 : 80)
        s[:location] ||= '/'

        if s[:server_name].nil? || s[:server_name].empty?
            message = 'you should setup server_name for your virtual host. '
            message << "virtual host string passed : #{s.inspect}"
            raise message
        end
        s[:static] ||= []
    end

    template params[:name] do
        source 'nginx-site.erb'
        notifies :restart, "service[nginx]", :immediately
        mode 0664
        variables({
            :static => ( (params[:static].is_a? Hash) ? [params[:static]] : params[:static] ),
            :root => params[:root],
            :socket => params[:socket],
            :inet_socket => params[:inet_socket],
            :servers => params[:servers],
            :simple_servers => params[:simple_servers],
    		:ssl_key => params[:ssl_key],
    		:ssl_file => params[:ssl_file],
            :fastcgi_param => params[:fastcgi_param],
            :site_name => File.basename(params[:name]).chomp(File.extname(params[:name])),
            :error_page => params[:error_page],
            :fastcgi_intercept_errors => params[:fastcgi_intercept_errors],
            :fastcgi_read_timeout => params[:fastcgi_read_timeout]
        })
        
    end
end
