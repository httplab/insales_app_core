def prevent_multiple_executions(&block)
  scope_name = ARGV[0].gsub(':', '_')
  shared_root = if Rails.env.production?
    File.join(Rails.root.to_s.split('releases').first, 'shared')
  else
    Rails.root.to_s
  end
  lock_dir = File.join(shared_root, 'tmp')

  JustOneLock::NonBlocking.prevent_multiple_executions(lock_dir, scope_name, output: $stdout, &block)
end
