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

USER = ''
EMAIL = ''
DB_FILE = "#{ENV['HOME']}/download/Dropbox/Database.db"

class Podcast
  attr_reader :title, :description, :url

  def initialize title, description, url
    @title = title
    @description = description
    @url = url
  end
end

podcasts = []
db = SQLite3::Database.new(DB_FILE)
db.execute 'select * from Feed ' do |row|
  podcasts << Podcast.new(row[6], row[9], row[4])
end

xml = Builder::XmlMarkup.new(:target => STDOUT)
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
      xml.outline(:type => 'rss', :version => 'RSS', 
                  :description => podcast.description,
                  :title => title, :text => title, 
                   :xmlUrl => podcast.url)

    end
  end
end

