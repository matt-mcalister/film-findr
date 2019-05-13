class Transcoder
  attr_accessor :file_path, :file_name, :destination_path
  @@handbrake = HandBrake::CLI.new(:bin_path => "../../../HandBrakeCLI",:trace => true)
  @@threads = []
  def initialize(origin: origin_file_path, destination: destination_path)
    @file_path = origin.gsub("~/", "../../../")
    @file_name = origin.split("/").last
    @destination_path = destination.gsub("~/", "../../../")
  end

  def self.files_from_folder(folder_path, destination_folder)
    Dir[folder_path.gsub("~/", "../../../")].map { |file_path| self.new(origin: file_path, destination: destination_folder) }
  end

  def self.handbrake
    @@handbrake
  end

  def self.threads
    @@threads
  end

  def transcode(from_extension: "mkv", to_extension: "m4v", preset: "Apple 1080p30 Surround")
    new_file_path = destination_path + file_name.gsub(from_extension,to_extension)
    self.class.handbrake.input(file_path).preset(preset).output(new_file_path)
  end

  def self.transcode_from_folder(origin_folder:, destination_folder:, from_extension: "mkv", to_extension: "m4v", preset: "Apple 1080p30 Surround")
    thread_pool = ThreadPool.new(5)
    self.files_from_folder(origin_folder + "*.#{from_extension}", destination_folder).each do |transcoder|
      thread_pool.schedule do
        transcoder.transcode(from_extension: from_extension, to_extension: to_extension, preset: preset)
        puts "Job #{transcoder.file_name}, finished by thread #{Thread.current[:id]}"
      end
    end
  end
end
