node.dig('lxc')&.tap do |lxc|
  name = lxc.dig('name')
  lxc.dig('create')&.tap do |create|
    template_name = create.dig('template', 'os')
    options = create.dig('template', 'options')&.map{|key, value| "--#{key.to_s} #{value}" }.join(' ')
    execute "lxc-create -t #{template_name} -n #{name} -- #{options}" do
      command "lxc-create -t #{template_name} -n #{name} -- #{options}"
      not_if "lxc-ls | grep #{name}"
    end
  end

  master = lxc.dig('clone', 'master') || name
  copy = lxc.dig('clone', 'copy')

  lxc.dig('clone')&.tap do |_clone|
    execute "lxc-clone #{master} #{copy}" do
      command "lxc-clone #{master} #{copy}"
      not_if "lxc-ls | grep #{copy}"
    end
  end

  lxc.dig('start')&.tap do |start|
    execute "lxc-start -n #{name}" do
      command "lxc-start -n #{name}"
      not_if "test -z #{start}"
    end
  end

  lxc.dig('stop')&.tap do |stop|
    execute "lxc-stop -n #{name}" do
      command "lxc-stop -n #{name}"
      not_if "test -z #{stop}"
    end
  end

  lxc.dig('destroy')&.tap do |destroy|
    execute "lxc-destroy -n #{name}" do
      command "lxc-destroy -n #{name}"
      not_if "lxc-ls | grep #{name}" && "test -z #{destroy}"
    end
  end
end
