# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

desc "Moves all completed QBittorrent torrent files"
task :migrate_completed_torrents do
  puts "BEGINNING MIGRATION"
  QBitAPI::Torrent.migrate_completed_torrents
  puts "ALL FILES MOVED"
end
