require 'open-uri'
require 'io/console'
require 'pty'

class GitRaw
	attr_reader :body
	def initialize(url)
		@body = open(url).map { |l| l.chomp }
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

		body.shift until body.first =~ Regexp.new("[^\\[#]#{target}", 'i')
		links << body.shift until body.first =~ /homeworks|additional resources|projects/i

		body = links.select!{|l| l =~ /vimeo/}
	end

	def to_hash(unparsed_links)
		@links = Hash.new do |h, k|
			k =~ /(\[.*\]).*(http.*)/
			h["#{h.count + 1}: #{$1}"] = $2
		end

		unparsed_links.each { |unparsed|  @links[unparsed] }
	end
end

def has_youtube_dl?
	if `which youtube-dl` =~ /^$/
		print <<~HEREDOC

				The dependancy 'youtube_dl' is not installed.
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
	return `which youtube-dl` =~ /^$/
end

class Credentials 
	attr_reader :day, :url, :vimeo_password
	def initialize
			@day = ARGV.find {|a| a =~ /w\d+d\d+/i}
			@url = ARGV.find {|a| a =~ /raw.githubusercontent/}

			abort("Must provide a URL to a README.md RAW") unless @url
			abort("Must provde a day") unless @day

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
		if Dir.entries('.').find {|e| e == name}
			puts "#{name} already exists; continuing to next video"
		else
			get_video(name, link, creds.vimeo_password)
		end
	end

	p "#{vdirname} successfully created with #{Dir.entries.count - 2} videos"

	`ls -1`
end

def get_video(name, link, pass)
				title = "#{name}.%(ext)s"
				command = %Q{youtube-dl --video-password "#{pass}" -o "#{title}" #{link}}

				begin
					PTY.spawn( command ) do |stdout, stdin, pid|
						begin
							stdout.each { |line| print line }
						rescue Errno::EIO
						end
					end
				rescue PTY::ChildExited
					puts "The child process exited!"
				end
end

if __FILE__ == $PROGRAM_NAME
	has_youtube_dl?
	creds = Credentials.new
	raw = GitRaw.new creds.url
	links = LinkParser.new(raw, creds)
	make_video_dir(creds, links.links)
end

