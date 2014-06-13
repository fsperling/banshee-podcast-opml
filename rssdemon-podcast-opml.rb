#!/usr/bin/env ruby
#
# Script to generate OPML of podcasts from RSSDemon
#
# Thanks to
# https://github.com/eddsteel/banshee-podcast-opml and
# http://blog.slashpoundbang.com/post/3385815540/how-to-generate-an-opml-file-with-ruby
#
# Public domain.

require 'rubygems'
require 'builder'
require 'sqlite3'

USER = 'username'
EMAIL = 'user@domain.de'
DB_FILE = "#{ENV['HOME']}/download/github/banshee-podcast-opml/Database.db"

class Podcast
  attr_reader :title, :htmlurl, :url, :type

  def initialize title, htmlurl, url, type
    @title = title
    @htmlurl = htmlurl
    @url = url
    @type = type
  end
end

podcasts = []
db = SQLite3::Database.new(DB_FILE)
db.execute 'select * from Feed ' do |row|
  podcasts << Podcast.new(row[6], row[9], row[4], row[3])
end

f = File.new("result.opml", "w")  

xml = Builder::XmlMarkup.new(:target => f, :indent => 2)
xml.instruct!
xml.opml(:version => 1.1) do
  xml.head do
    xml.title 'Podcasts'
    xml.dateCreated Time.new.httpdate
    xml.dateModified Time.now.httpdate
    xml.ownerName USER
    xml.ownerEmail EMAIL
  end
  xml.body do
    podcasts.each do |podcast|
      title = podcast.title
      xml.outline(:type => podcast.type, :version => 'RSS', 
                  :description => "",
                  :title => title, :text => title, 
                   :xmlUrl => podcast.url,
		   :htmlUrl => podcast.htmlurl)
      xml.text! "\n"

    end
  end
end

f.close()

