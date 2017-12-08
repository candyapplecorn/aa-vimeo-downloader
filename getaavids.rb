require 'open-uri'
require 'io/console'
require 'pty'
# No installation! Wew!
require 'youtube-dl'

class GitRaw
  attr_reader :body
  def initialize(url)
    @body = open(url).map(&:chomp)
  end
end

class LinkParser
  attr_reader :links

  def initialize(raw, creds)
    unparsed_links = narrow_to_week_section(raw.body.dup, creds.day)
    to_hash(unparsed_links)
  end

  private

  def narrow_to_week_section(body, target)
    links = []

    unless target =~ /all/i
      body.shift until body.first =~ Regexp.new("[^\\[#]#{target}", 'i')
      links << body.shift until body.first =~ /homeworks|additional resources|projects/i
    end

    body = links.select! { |l| l =~ /vimeo/ }
  end

  def to_hash(unparsed_links)
    @links = Hash.new do |h, k|
      k =~ /(\[.*\]).*(http.*)/
      h["#{h.count + 1}: #{$1}"] = $2
    end

    unparsed_links.each { |unparsed| @links[unparsed] }
  end
end

# should be able to remove this once binding works correctly
def has_youtube_dl?
  if `which youtube-dl` =~ /^$/
    print <<~HEREDOC
    The dependency 'youtube_dl' is not installed.
    To install this program, see
    https://rg3.github.io/youtube-dl/download.html

    Are you using OSX or Linux and would like to
    install youtube_dl automatically?
    HEREDOC

    print "[Y/N]: "

    if STDIN.gets =~ /y/i
      raise "Install failed; please install manually" unless install_youtube_dl
      return true
    else
      abort('Install youtube_dl to use this program')
    end
  end
end

def install_youtube_dl
  `sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl`
  `sudo chmod a+rx /usr/local/bin/youtube-dl`
  `which youtube-dl` =~ /^$/
end

class Credentials
  attr_reader :day, :url, :vimeo_password
  def initialize
    @day = ARGV.find { |a| a =~ /w\d+d\d+|all/i }
    @url = ARGV.find { |a| a =~ /raw.githubusercontent/ }

    abort("Must provide a URL to a README.md RAW") unless @url
    abort("Must provide a day like 'w4d1' OR '--all'") unless @day

    @day = @day.upcase
    @vimeo_password = get_vimeo_password
    p ''
  end

  private

  def get_vimeo_password
    print "Please enter the password to access these Vimeo videos:\n> "
    STDIN.noecho(&:gets).chomp
  end
end

def make_video_dir(creds, links)
  vdirname = "#{creds.day}_videos"
  Dir.mkdir vdirname unless Dir.exists?(vdirname)
  Dir.chdir  vdirname
  p "Created the directory #{vdirname}"

  links.each do |name, link|
    if Dir.entries('.').find { |e| e.index name }
      puts "#{name} already exists; continuing to next video"
    else
      get_video(name, link, creds.vimeo_password)
    end
  end

  p "#{vdirname} successfully created with #{Dir.entries('.').reject { |e| e =~ /^\./ }.count} videos"

  print `ls -1`
end

# Replace this with ruby binding
def get_video(name, link, pass)
  title = "#{name}.%(ext)s"
  command = %{youtube-dl --video-password "#{pass}" -o "#{title}" #{link}}

	YoutubeDL.download link, {
					"video-password": pass,
					"o": title
	}

#  begin
#    PTY.spawn(command) do |stdout, _stdin, _pid|
#      begin
#         stdout.each { |line| print line }
#       rescue Errno::EIO
#       end
#    end
#  rescue PTY::ChildExited
#    puts "The child process exited!"
#  end
end

if $PROGRAM_NAME == __FILE__
  #has_youtube_dl? # This will go since ruby binding should work
  creds = Credentials.new
  raw = GitRaw.new creds.url
  links = LinkParser.new(raw, creds)
  make_video_dir(creds, links.links)
end
