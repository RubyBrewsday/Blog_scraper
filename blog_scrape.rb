require 'open-uri'
require 'Hpricot'
require 'csv'
require 'progressbar'
require 'colorize'

#helper method for array class to convert arrays of links into hashes for frequency later on
class Array 
	def count2
		k = Hash.new(0)
		self.each{|x| k[x] += 1}
		k
	end

end

system('clear')
puts "                           Greetings fair Scraper!".colorize(:green)
puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".colorize(:green)
puts "                Which site would you care to scrape today, Good Sir?".colorize(:green)
print "Enter: [1] => Naked Capitalism | [2] => Big Picture | [3] => Marginal Revolution\n".colorize(:green)
print "       [4] => Tax Prof | [5] => Tim Worstall\n        ".colorize(:green)


@choice = gets.chomp!.to_i

unless @choice =~ /[1..5]/ 
	raise "Not a valid website....yet!"
end


print "Please enter number of pages to scrape: ".colorize(:yellow)
@pages_to_scrape = gets.chomp!.to_i


def blog_links_grabber
	blog_urls = []

		i = 1
		

		while i <= @pages_to_scrape
		blog_links = [["http://www.nakedcapitalism.com/page/#{i}", "//h3[@class='post-title entry-title']"],["http://www.ritholtz.com/blog/page/#{i}", "div[@class='headline']", ],["http://www.marginalrevolution.com/page/#{i}", "h2[@class='entry-title']"],["http://www.taxprof.typepad.com/taxprof_blog/page/#{i}", "div[@class='article']"],["http://www.timworstall.com/page/#{i}", "h2[@class='entry-title']"]]
		
			individual_articles = open(blog_links[@choice-1][0]) { |f| Hpricot(f)  }
			links = individual_articles.search(blog_links[@choice-1][1])

			if (@choice == 1) || (@choice == 3 ) || (@choice == 5)
				(links/'a').each do |a|
					blog_urls.push(a.attributes[ 'href' ])
					puts a.attributes['href']
				end
			elsif @choice == 2
				(links/'h2'/'a').each do |a|
					blog_urls.push(a.attributes[ 'href' ] )
					puts a.attributes['href']
				end				
			elsif @choice == 4
				(links/'h3'/'a').each do |a|
					blog_urls.push(a.attributes[ 'href' ])
					puts a.attributes['href']
				end
			else
				raise "Invalide website choice"
			end
			i += 1
		end
		blog_urls
end

#xpaths for the article's content on the various blogs
@content_links = ["//div[@class='pf-content']", "//div[@class='post-content']", "//div[@class='format_text entry-content']", "//*[@id='main']/div/div/div[2]", "//div[@class='entry-content clearfix']"]

def content_grabber(url)
	#grabs all of the content off of each blog article
	doc = open(url) {|f| Hpricot(f)}	
	content = doc.search(@content_links[@choice - 1])

	link_extractor(content)
end

def link_extractor(content)

	#Empty array to hold links from individual sites
	external_links = []

	#extracts external links from content, puts them into array
	(content/"a").each do |a|
		links = []
		links.push(a.attributes['href'])
		links.each do |link|
			case link
			when /(.*)nakedcapitalism.com(.*)/ 
				if @choice== 1
					next
				else
					external_links.push(link.scan(/.*com\//))
				end
			when /(.*)ritholtz.com(.*)/ 
				if @choice == 2
					next
				else
					external_links.push(link.scan(/.*com\//))
				end
			when /(.*)marginalrevolution.com(.*)/
				if @choice == 3
					next
				else
					external_links.push(link.scan(/.com\//))
				end
			when /(.*)taxprof.typepad.com(.*)/
				if @choice == 4
					next
				else
					external_links.push(link.scan(/.com\//))
				end
			when /(.*)timworstall.com(.*)/
				if @choice == 5
					next
				else
					external_links.push(link.scan(/.com\//))
				end
			when /(.*)\.org\/(.*)/
				external_links.push(link.scan(/.*org\//))
			when /(.*)\.edu\/(.*)/
				external_links.push(link.scan(/.*edu\//))
			when /(.*)\.gov\/(.*)/
				external_links.push(link.scan(/.*gov\//))
			when /(.*)\.au\/(.*)/
				external_links.push(link.scan(/.*au\//))
			when /(.*)\.uk\/(.*)/
				external_links.push(link.scan(/.*uk\//))
			else
				external_links.push(link.scan(/.*com\//))
			end
		end
	end

	return external_links

end

#Empty array that will eventually hold external website links as a hash
total_external_links = Array.new


puts "Let the scraping commence!".colorize(:yellow)
puts "==================================================================".colorize(:green)
blog_entries = blog_links_grabber
puts "==================================================================".colorize(:green)
puts
puts "Preparing to extract links....".colorize(:yellow)
puts
 
number_of_entries = blog_entries.count 
i = 1
pbar = ProgressBar.new("Progress", number_of_entries)
while i <= number_of_entries
	
	blog_entries.each do |blog|
		content_grabber(blog).each do |link|
			total_external_links.push(link)
		end
	end
	i+=1
	pbar.inc
end

pbar.finish


puts "==================================================================".colorize(:green)
puts ""
print "What do you want to name the file? ".colorize(:yellow)
name = gets.chomp!

sorted_total_external_links = total_external_links.count2.sort_by {|x,y| [-Integer(y), x]}
CSV.open("#{name}.csv", "wb") { |csv| sorted_total_external_links.to_a.each {|elem| csv << elem}}

puts "All finished :)".colorize(:blue)
gets
system('clear')