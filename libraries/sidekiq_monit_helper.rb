module SidekiqMonitHelper
  def self.sidekiq_param(name, value)
    return nil unless value

    Array(value).map { |val| "--#{name} #{value}" }.join(' ')
  end
end
