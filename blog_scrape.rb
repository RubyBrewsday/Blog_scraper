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



print "Please enter number of pages to scrape: ".colorize(:yellow)
@pages_to_scrape = gets.chomp!.to_i


def blog_links_grabber(website)
	if website == 1
		naked_capitalism_blog_links_grabber(@pages_to_scrape)
	elsif website == 2
		big_picture_blog_links_grabber(@pages_to_scrape)
	elsif website == 3
		marginal_revolution_blog_links_grabber(@pages_to_scrape)
	elsif website == 4
		tax_prof_blog_links_grabber(@pages_to_scrape)
	elsif website == 5
		tim_worstall_blog_links_grabber(@pages_to_scrape)
	else
		raise "Invalid website choice"
	end
end

def marginal_revolution_blog_links_grabber(number_of_pages)
	blog_urls = []

	i = 1
	while i <= number_of_pages
		doc = open("http://www.marginalrevolution.com/page/#{i}") { |f| Hpricot(f)  }
		links = doc.search("h2[@class='entry-title']")

		(links/'a').each do |a|
			blog_urls.push(a.attributes[ 'href' ])
			puts a.attributes['href']
		end

		i += 1
	end
	blog_urls
end

def tax_prof_blog_links_grabber(number_of_pages)
	blog_urls = []

	i = 1
	while i <= number_of_pages
		doc = open("http://www.taxprof.typepad.com/taxprof_blog/page/#{i}") { |f| Hpricot(f)  }
		links = doc.search("div[@class='article']")

		(links/'h3'/'a').each do |a|
			blog_urls.push(a.attributes[ 'href' ])
			puts a.attributes['href']
		end
		i += 1
	end
	blog_urls
end

def tim_worstall_blog_links_grabber(number_of_pages)
	blog_urls = []

	i = 1
	while i <= number_of_pages
		doc = open("http://www.timworstall.com/page/#{i}") { |f| Hpricot(f)  }
		links = doc.search("h2[@class='entry-title'")

		(links/'a').each do |a|
			blog_urls.push(a.attributes[ 'href' ])
			puts a.attributes['href']
		end
		i += 1
	end
	blog_urls
end

def big_picture_blog_links_grabber(number_of_pages)
	blog_urls = []

	i = 1
	while i <= number_of_pages
		doc = open("http://www.ritholtz.com/blog/page/#{i}") { |f| Hpricot(f)  }
		links = doc.search("div[@class='headline']")

		(links/'h2'/'a').each do |a|
			blog_urls.push(a.attributes[ 'href' ] )
			puts a.attributes['href']
		end

		i += 1
	end
	blog_urls
end

def naked_capitalism_blog_links_grabber(number_of_pages)
	blog_urls = []

	i = 1
	while i <= number_of_pages
		doc = open("http://www.nakedcapitalism.com/page/#{i}") {|f| Hpricot(f)}
		links = doc.search("//h3[@class='post-title entry-title']")
	
		(links/"a").each do |a|
			 blog_urls.push(a.attributes[ 'href'])
			 puts a.attributes['href']
		end

		i += 1
	end
	blog_urls
end

def marginal_revolution_content_grabber(url)
	#grabs all of the content off of each blog article
	doc = open(url) {|f| Hpricot(f)}	
	content = doc.search("//div[@class='format_text entry-content']")

	link_extractor(content)
end

def tax_prof_content_grabber(url)
	#grabs all of the content off of each blog article
	doc = open(url) {|f| Hpricot(f)}	
	content = doc.search("//*[@id='main']/div/div/div[2]")

	link_extractor(content)
end

def tim_worstall_content_grabber(url)
	#grabs all of the content off of each blog article
	doc = open(url) {|f| Hpricot(f)}	
	content = doc.search("//div[@class='entry-content clearfix']")

	link_extractor(content)
end

def big_content_grabber(url)
	#grabs all of the content off of each blog article
	doc = open(url) {|f| Hpricot(f)}	
	content = doc.search("//div[@class='post-content']")

	link_extractor(content)

end

def naked_content_grabber(url)
	#grabs all of the content off of each blog article
	doc = open(url) {|f| Hpricot(f)}	
	content = doc.search("//div[@class='pf-content']")

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
				if @choice == 1
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
blog_entries = blog_links_grabber(@choice)
#puts blog_entries
puts "==================================================================".colorize(:green)
puts
puts "Preparing to extract links....".colorize(:yellow)
puts

number_of_entries = blog_entries.count 
i = 1
pbar = ProgressBar.new("Progress", number_of_entries)
while i <= number_of_entries
	
	blog_entries.each do |blog|
		if @choice == 1
			naked_content_grabber(blog).each do |link|
				total_external_links.push(link)
			end
		elsif @choice == 2
			big_content_grabber(blog).each do |link|
				total_external_links.push(link)
			end
		elsif @choice == 3
			marginal_revolution_content_grabber(blog).each do |link|
				total_external_links.push(link)
			end
		elsif @choice == 4
			tax_prof_content_grabber(blog).each do |link|
				total_external_links.push(link)
			end
		elsif @choice == 5
			tim_worstall_content_grabber(blog).each do |link|
				total_external_links.push(link)
			end
		end
		i+=1
		pbar.inc
	end
	pbar.finish
end

puts "==================================================================".colorize(:green)
puts 

print "What do you want to name the file? ".colorize(:yellow)
name = gets.chomp!

sorted_total_external_links = total_external_links.count2.sort_by {|x,y| [-Integer(y), x]}
CSV.open("#{name}.csv", "wb") { |csv| sorted_total_external_links.to_a.each {|elem| csv << elem}}

puts "All finished :)".colorize(:blue)
gets
system('clear')

