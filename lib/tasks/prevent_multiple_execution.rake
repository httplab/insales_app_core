def prevent_multiple_executions(&block)
  scope_name = ARGV[0].gsub(':', '_')
  lock_file = Rails.root.join('tmp', scope_name + "_lock.txt")

  if File.exist?(lock_file)
    pid = File.read(lock_file).try(:to_i)
    is_already_running = `ps -a | grep #{pid}`.split(' ').first.to_i == pid

    if is_already_running
      puts "Другой процесс <rake #{ARGV[0]}> уже запущен"
      exit(1)
    end
  end

  File.open(lock_file, 'w') do |f|
    f.puts Process.pid
  end

  block.call

  File.delete lock_file
end
