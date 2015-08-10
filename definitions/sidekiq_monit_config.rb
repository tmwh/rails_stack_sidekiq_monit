define :sidekiq_monit_config do
  default_pid_name = 'sidekiq.pid'
  params[:name].each do |application_options|
    sidekiq_options = application_options['sidekiq']
    next unless sidekiq_options

    sidekiq_processes_count = sidekiq_options['processes'] || 1
    sidekiq_processes_count.times do |i|
      app_path = File.join(node['rails-stack']['data_path'],
                           'apps',
                           application_options[:name],
                           'current')

      tmp_path = File.join(node['rails-stack']['data_path'],
                           'apps',
                           application_options[:name],
                           'shared',
                           'tmp')

      pid_name = if (i.zero? && sidekiq_processes_count <= 1)
        default_pid_name
      else
        default_pid_name.gsub(/\.pid$/, "-#{i}.pid")
      end
      pid_path = File.join(tmp_path, 'pids', pid_name)

      options = {
        user: node['rails-stack']['deployer'],
        app_name: application_options[:name],
        rails_env: application_options[:rails_env],
        app_path: app_path,
        tmp_path: tmp_path,
        pid_path: pid_path,
        sidekiq_env: application_options[:rails_env],
        sidekiq_name: "#{application_options[:name]}_sidekiq_#{i+1}",
        index: i,
        sidekiq_config: SidekiqMonitHelper.sidekiq_param('config', sidekiq_options[:config]),
        sidekiq_concurrency: SidekiqMonitHelper.sidekiq_param('concurrency', sidekiq_options[:concurrency]),
        sidekiq_logfile: SidekiqMonitHelper.sidekiq_param('logfile', sidekiq_options[:logfile]),
        sidekiq_queues: SidekiqMonitHelper.sidekiq_param('queue', sidekiq_options[:queues]),
      }.merge(sidekiq_options)

      monitrc options[:sidekiq_name] do
        template_source 'sidekiq.monitrc.erb'
        template_cookbook 'rails_stack_sidekiq_monit'
        variables options
      end
    end
  end
end
