include_recipe "nginx"
include_recipe "lein"
include_recipe "git"

git node[:tenkai_suru_api][:location] do
  repository node[:tenkai_suru_api][:git_repo]
  reference  node[:tenkai_suru_api][:git_branch]
  action     :sync
end

cookbook_file "/etc/init/tenkai_suru_api.conf" do
  source "tenkai_suru_api.conf"
  mode "0644"
end

cookbook_file "/etc/nginx/sites-available/default" do
  source "nginx.conf"
  mode "0644"
end

service 'tenkai_suru_api' do
  provider Chef::Provider::Service::Upstart
  action :restart
end

service 'nginx' do
  action :restart
end
