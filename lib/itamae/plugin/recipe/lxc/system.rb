create_args = %w(lxc create template)
template_name = node.dig(*create_args, 'name')
options = node.dig(*create_args, 'options')&.map{|key, value| "--#{key.to_s} #{value}" }&.join(' ')
name = node[:lxc][:name]

node.dig('lxc', 'create')&.tap do |_create|
  execute "lxc-create -t #{template_name} -n #{name} -- #{options}" do
    command "lxc-create -t #{template_name} -n #{name} -- #{options}"
    not_if "lxc-ls | grep #{name}"
  end
end

master = node.dig('lxc', 'clone', 'master')
copy = node.dig('lxc', 'clone', 'copy')

node.dig('lxc', 'clone')&.tap do |_clone|
  execute "lxc-clone #{master} #{copy}" do
    command "lxc-clone #{master} #{copy}"
    not_if "lxc-ls | grep #{copy}"
  end
end

node.dig('lxc', 'start')&.tap do |start|
  execute "lxc-start -n #{name}" do
    command "lxc-start -n #{name}"
    not_if "test -z #{start}"
  end
end

node.dig('lxc', 'stop')&.tap do |stop|
  execute "lxc-stop -n #{name}" do
    command "lxc-stop -n #{name}"
    not_if "test -z #{stop}"
  end
end

node.dig('lxc', 'destroy')&.tap do |destroy|
  execute "lxc-destroy -n #{name}" do
    command "lxc-destroy -n #{name}"
    not_if "lxc-ls | grep #{name}" && "test -z #{destroy}"
  end
end
