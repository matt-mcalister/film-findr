# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

desc "Moves all .mp4 files from /Movies/Bit/auto-added/ folder to plex/movies folder"
task :move_downloaded_files do
  puts "BEGINNING ADD"
  queue = Dir["/Users/MattMcAlister/Movies/Bit/auto-added/**/*.mp4"]
  destination_path = "/Volumes/plexserv/test"
  puts "EXECUTING"
  queue.each do |original_path|
    puts "ORIGINAL PATH: #{original_path}"
    file_name = original_path.split("/").last
    puts "FILE NAME: #{file_name}"
    new_path = "#{destination_path}/#{file_name}"
    puts "NEW PATH: #{new_path}"
    puts "MOVING"
    FileUtils.mv(original_path, new_path)
    puts "MOVED"
    puts "*********************"
  end
  puts "ALL PATHS MOVED"
end
