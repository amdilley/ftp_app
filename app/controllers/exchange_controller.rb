require 'net/ftp'

class ExchangeController < ApplicationController
	def get_season
		key  = '2b34d786765270e3ff74e895a2f1884d'
		root = 'http://api.trakt.tv/show/season.json/' + key

		show = format_show_name params[:show]

		uri = URI(root + "/#{show}/#{params[:season]}")
		res = Net::HTTP.get_response(uri)
		
		case res
		when Net::HTTPResponse then
			switch_titles JSON.parse(res.body)
		end
	end

	def switch_titles episodes
		root = 'amdilley.asuscomm.com'
		path = '/MY_BOOK/Video/TV/' + params[:show] + '/Season ' + params[:season]

		username = 'admin'
		password = 'adsd1234'

		ftp = Net::FTP.new(root)

		ftp.login(username, password)
		files = ftp.chdir(path)
		files = ftp.nlst()

		files.each do |file|
			regex = Regexp.new('s\d{1,2}e(\d{1,2})', Regexp::IGNORECASE)
			matches = regex.match(file)
			ext = file.split('.').last
			
			if matches
				episode = matches[1]
				
				title = fetch_title(episodes, episode)
				new_file = path + '/Episode ' + episode + ' - ' + title + '.' + ext

				ftp.rename(file, new_file)
			end 
		end

		ftp.close
	end

	def fetch_title(episodes, episode)
		episode = Integer(episode.sub(/^0/, ""))

		episodes.each do |ep|
			if ep['episode'] == episode
				return ep['title'].gsub("?", "").gsub("/", "")
			end
		end
	end

	def format_show_name show
		show = show.downcase.gsub("-", "").gsub(" ", "-");
	end

	def format_num num
		num = Integer(num) < 10 ? '0' + num : num
	end

end
