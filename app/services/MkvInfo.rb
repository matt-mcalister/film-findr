class MkvInfo
  attr_reader :path, :output_string, :uhd, :size

  def initialize(path)
    raise Errno::ENOENT, "the file '#{path}' does not exist" unless File.exists?(path)
    @path = path
    @output_string = `mkvinfo "#{path}"`
    @size = @output_string.split("Pixel height: ")[1].split("\n").first.to_i
    @uhd = !!@output_string.match(/HEVC/)
  end

end
