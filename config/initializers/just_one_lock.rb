shared_root = if Rails.env.production?
  File.join(Rails.root.to_s.split('releases').first, 'shared')
else
  Rails.root.to_s
end

JustOneLock.world.directory = File.join(shared_root, 'tmp')

