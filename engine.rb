#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$KCODE='u'

require 'cgi'
require 'rubygems'
require 'nokogiri'
require 'RedCloth'
require 'kconv'

$cgi = nil

def identity(x)
  x
end

class RequestDispatcher
  def do(params)
    @params = params
    case params['mode'][0]
    when "search"
      run(SearchAction)
    else 
      $cgi.out("status" => "BAD_REQUEST"){
        ""
      }
    end
  end

  def run(klass)
    klass.new.respond(@params)
  end
end

class ResponseAction
  def initialize
    @response_params = {
      "type" => "text/html",
      "status" => "OK"}
  end
  
  def self.publish(params)
    raise Exception.new("ResponseAction#publis must be overridden in sub-class")
  end
  
  def respond(params)
    $cgi.out(@response_params){
      self.publish(params)
    }
  end
end

class Query
  #mock-up
  def initialize(query)
    if query == nil || query.empty?
      @alwaystrue = true
    else
      @alwaystrue = false
    end

    @query = query
  end

  def match(text)
    return true if @alwaystrue

    text.include?(@query)
  end
end

class SearchAction < ResponseAction
  # return HTML response or nil
  def filter_entry(entry_file)
    doc = get_doc(entry_file)
    return nil unless doc
    
    return nil unless @query.match(doc.content)
    doc.search("div.subentries > div.subentry").each do |subentry|
      subentry.remove() unless @subquery.match(subentry.content)
    end

    doc.to_html
  end

  def publish(params)
    @query = Query.new(params['query'][0])
    @subquery = Query.new(params['subquery'][0])

    self.entry_files.map{|e| self.filter_entry(e)}.select{|d| d}.join("\n")
  end

  def entry_files()
    dir = File.dirname(__FILE__)
    Dir.glob("#{dir}/entries/*.html")
  end

  def get_doc(entry_file)
    case File.extname(entry_file)
    when /html?/
      Nokogiri::HTML(open(entry_file), nil, "UTF-8")
    else
      nil
    end
  end
end


if $0 == __FILE__
  $cgi = CGI.new
  RequestDispatcher.new.do($cgi.params)
end
