#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$KCODE='u'

ENV['GEM_PATH'] = "/home/haya/.gem/ruby/1.8"

require 'cgi'
require 'rubygems'
require 'nokogiri'
require 'redcloth'
require 'bluecloth'
require 'kconv'
require 'uri'

$cgi = nil

def identity(x)
  x
end

class RequestDispatcher
  def do(params)
    @params = Hash.new
    
    params.each do |key, values|
      @params[key] = values.map{|val| URI.decode(val).toutf8}
    end

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
      @queries = []
      return
    else
      @alwaystrue = false
    end

    @queries = query.split.map{|q| Regexp.compile(q, Regexp::IGNORECASE)}
  end

  def match(text)
    return true if @alwaystrue

    @queries.inject(true){|ret, q| ret && (q =~ text)}
  end
end

class SearchAction < ResponseAction
  def publish(params)
    @query = Query.new(params['query'] && params['query'][0])
    @subquery = Query.new(params['subquery'] && params['subquery'][0])
    @limit = 100
    @limit = params['limit'][0].to_i if params['limit']

    self.entry_files.first(@limit).map{|e|
      self.filter_entry(e)
    }.select{|d| d}.join("\n")
  end

  # return HTML response or nil
  def filter_entry(entry_file)
    doc = get_doc(entry_file)
    return nil unless doc
    
    return nil unless @query.match(doc.content)
    doc.search(".subentry").each do |subentry|
      subentry.remove() unless @subquery.match(subentry.content)
    end
    doc.search("li").each do |subentry|
      subentry.remove() unless @subquery.match(subentry.content)
    end

    doc.to_html
  end

  def entry_files()
    dir = File.dirname(__FILE__)
    Dir.glob("#{dir}/entries/*.html") + Dir.glob("#{dir}/entries/*.markdown")
  end

  def get_doc(entry_file)
    case File.extname(entry_file)
    when /html?/
      Nokogiri::HTML(open(entry_file), nil, "UTF-8")
    when /markdown/
      html = BlueCloth.new(open(entry_file).read).to_html
      Nokogiri.make("<div class=\"entry\">#{html}</div>")
    else
      nil
    end
  end
end


if $0 == __FILE__
  $cgi = CGI.new
  RequestDispatcher.new.do($cgi.params)
end
