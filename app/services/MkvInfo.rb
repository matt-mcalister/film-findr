class MkvInfo
  attr_reader :path, :output_string, :formatted_output, :uhd

  def initialize(path)
    raise Errno::ENOENT, "the file '#{path}' does not exist" unless File.exists?(path)
    @path = path
    @output_string = `mkvinfo #{path}`
    @uhd = !!@output_string.match(/HEVC/)
  end

end
