# Scraper for WikiLeaks Global Intelligence Files
require 'nokogiri'

# Gets the URLs of all Global Intelligence File releases
def getReleaseURL
  html = ScraperWiki::scrape("http://wikileaks.org/gifiles/releases.html")
  p html
  doc = Nokogiri::HTML html
  url = Array.new

  doc.css('a').each do |link|
    links = link.class
    if link['href'].include? "/gifiles/releasedate/"
      if url.last != "http://wikileaks.org"+link['href']
        url.push("http://wikileaks.org"+link['href'])
      end
    end  
  end
  return url
end

# Gets URLs and data for gifiles emails
def getAllEmails(url)
  url.each do |u|
    getEmailURL(u) 
  end
end

# Gets the URLs of all emails on a release page
def getEmailURL(url)
  emailurl = Array.new
  html = ScraperWiki::scrape(url)
  doc = Nokogiri::HTML html

  doc.css('a').each do |link|
    if link['href'].include? "/gifiles/docs/"
      fullurl = "http://wikileaks.org"+link['href']
      if emailurl.last != fullurl
       emailurl.push(fullurl)
      end
    end
  end
  
  emailurl.each do |u|
    getEmail(u)
  end
end

# Gets individual emails and their data
def getEmail(url)
  html = ScraperWiki::scrape(url)
  doc = Nokogiri::HTML html

  emaildata = {
    subject: getEmailSubject(doc),
    id: getEmailID(doc),
    date: getEmailDate(doc),
    body: getEmailContent(doc)
  }
  ScraperWiki::save_sqlite(['id'], emaildata)
end

# Gets the subject of the email
def getEmailSubject(doc)
  return (doc.css('h2')[0]).content
end

# Gets the ID of the email
def getEmailID(doc)
  return (doc.css('table.cable tr td')[0]).content
end

# Gets the send date of the email
def getEmailDate(doc)
  return (doc.css('table.cable tr td')[1]).content
end

# Gets the email content
def getEmailContent(doc)
  return (doc.css('div#doc-description')[0]).content
end

#To get all emails:
#getAllEmails(getReleaseURL)

#To get all emails for a single gifiles release:
#getEmailURL(paste URL for gifiles release here)

#To scrape a single email:
#getEmail(paste email URL here)
