def prevent_multiple_executions(&block)
  JustOneLock::prevent_multiple_executions(ARGV[0], &block)
end
