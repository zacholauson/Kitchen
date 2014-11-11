include_recipe "java"

jar_file ="#{node[:leiningen][:jar_dir]}/leiningen-#{node[:leiningen][:version]}-standalone.jar"

remote_file "/usr/local/bin/lein" do
  source node[:leiningen][:install_script]
  owner node[:leiningen][:user]
  group node[:leiningen][:group]
  mode 0755
  notifies :create, "ruby_block[lein-system-wide]", :immediately
  not_if "grep -qx 'export LEIN_VERSION=\"#{node[:leiningen][:version]}\"' /usr/local/bin/lein"
end

ruby_block "lein-system-wide" do
  block do
    rc = Chef::Util::FileEdit.new("/usr/local/bin/lein")
    rc.search_file_replace_line(/^LEIN_JAR=.*/, "LEIN_JAR=#{jar_file}")
    rc.write_file
  end
  action :nothing
end

directory node[:leiningen][:jar_dir] do
  owner node[:leiningen][:user]
  group node[:leiningen][:group]
  mode "0744"
  action :create
end

execute "lein_self_install" do
  command "export LEIN_ROOT=1; lein self-install"
  user   node[:leiningen][:user]
  group  node[:leiningen][:group]
  not_if{ File.exists?(jar_file) }
end
