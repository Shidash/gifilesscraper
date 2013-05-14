# Scraper for WikiLeaks Global Intelligence Files
require 'nokogiri'

def getReleaseURL
  html = ScraperWiki::scrape("http://wikileaks.org/gifiles/releases.html")
  p html
  doc = Nokogiri::HTML html
  url = Array.new

  doc.css('a').each do |link|
    links = link.class
    if link['href'].include? "/gifiles/releasedate/"
      if url.last != link['href']
        url.push(link['href'])
      end
    end  
  end
  return url
end

def getEmailURL(url)
  url.each do |u|
    emailurl = Array.new
    fullurl = "http://wikileaks.org"+u
    html = ScraperWiki::scrape(fullurl)
    doc = Nokogiri::HTML html

    doc.css('a').each do |link|
     if link['href'].include? "/gifiles/docs/"
      if emailurl.last != link['href']
       emailurl.push(link['href'])
      end
     end
    end

    getEmail(emailurl)
  end
end

def getEmail(url)
  url.each do |u|
    fullurl = "http://wikileaks.org"+u
    html = ScraperWiki::scrape(fullurl)
    doc = Nokogiri::HTML html

    emaildata = {
      subject: getEmailSubject(doc),
      id: getEmailID(doc),
      date: getEmailDate(doc),
      body: getEmailContent(doc)
    }
    ScraperWiki::save_sqlite(['subject'], emaildata)
  end
end

def getEmailSubject(doc)
  return (doc.css('h2')[0]).content
end

def getEmailID(doc)
  return (doc.css('table.cable tr td')[0]).content
end

def getEmailDate(doc)
  return (doc.css('table.cable tr td')[1]).content
end

def getEmailContent(doc)
  return (doc.css('div#doc-description')[0]).content
end

getEmailURL(getReleaseURL)
