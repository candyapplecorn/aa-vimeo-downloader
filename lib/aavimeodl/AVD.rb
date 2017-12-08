require 'open-uri'
require 'io/console'
require 'pty'
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

	YoutubeDL.download link, {
					"video-password": pass,
					"o": title
	}
end

class Aavimeodl::AVD
  def initialize
    creds = Credentials.new
    raw = GitRaw.new creds.url
    links = LinkParser.new(raw, creds)
    make_video_dir(creds, links.links)
  end
end

if $PROGRAM_NAME == __FILE__
  Aavimeodl::AVD.new
end

