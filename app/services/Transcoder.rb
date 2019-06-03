class Transcoder
  attr_accessor :file_path, :file_name, :destination_path, :new_file_path
  @@handbrake = HandBrake::CLI.new(:bin_path => "/Users/MattMcAlister/HandBrakeCLI",:trace => false)
  @@threads = []
  def initialize(origin: origin_file_path, destination: destination_path)
    @file_path = origin.gsub("~/", "/Users/MattMcAlister/")
    @file_name = origin.split("/").last
    @destination_path = destination.gsub("~/", "/Users/MattMcAlister/")
  end

  def self.files_from_folder(folder_path, destination_folder)
    Dir[folder_path.gsub("~/", "/Users/MattMcAlister/")].map { |file_path| self.new(origin: file_path, destination: destination_folder) }
  end

  def self.handbrake
    @@handbrake
  end

  def self.threads
    @@threads
  end

  def transcode(from_extension: "mkv", to_extension: "mp4", preset: "Apple 1080p30 Surround")
    new_file_name = file_name.gsub(from_extension,to_extension)
    puts "***********************"
    puts "BEGINNING TRANSCODE FOR: #{new_file_name}"
    puts "***********************"
    @new_file_path = destination_path + new_file_name
    self.class.handbrake.input(file_path).preset(preset).output(new_file_path)
    puts "***********************"
    puts new_file_name + " SUCCESFFULLY CREATED"
    self.move_to_plex
  end

  def move_to_plex
    puts "MOVING TO PLEX"
    plex_file_path = new_file_path.gsub("/Users/MattMcAlister/Movies/HandBroken/", "/Volumes/plexserv/")
    begin
      FileUtils.mv(new_file_path, plex_file_path)
    rescue Errno::ENOENT => e
      FileUtils.makedirs(plex_file_path.split("/")[0...-1].join("/"))
      puts "new folder made"
      FileUtils.mv(new_file_path, plex_file_path)
    end
    puts "***********************"
    puts "#{file_name} FILE SUCCESSFULLY MOVED"
    puts "***********************"
  end

  def self.transcode_from_folder(origin_folder:, destination_folder:, from_extension: "mkv", to_extension: "mp4", preset: "Apple 1080p30 Surround")
    thread_pool = ThreadPool.new(5)
    self.files_from_folder(origin_folder + "*.#{from_extension}", destination_folder).each do |transcoder|
      thread_pool.schedule do
        transcoder.transcode(from_extension: from_extension, to_extension: to_extension, preset: preset)
        puts "Job #{transcoder.file_name}, finished by thread #{Thread.current[:id]}"
      end
    end
    thread_pool.run!
  end
end
