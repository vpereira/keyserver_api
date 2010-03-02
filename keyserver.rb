#
# Prototype to add and search keys in keyservers
# first one added: pgp.mit.edu
#
require 'rubygems'
require 'hpricot'
require 'mechanize'

MIT_SERVER = "http://pgp.mit.edu/"
class KeyServer
  attr_accessor :agent
  attr_accessor :server
  attr_accessor :keyfile
  
  def initialize
    @agent = WWW::Mechanize.new { |agent|
        agent.user_agent_alias = 'Mac Safari'
      }
    @server = MIT_SERVER
  end
  
  
  def search_key(search_str)
    if @server == MIT_SERVER
      ret = search_mitserver_key(search_str)
    else
      puts "not implemented"
      ret = nil
    end
    ret
  end
    
  def add_key(keyf)
    @keyfile = keyf if File.exist?(keyf)
    @keyfile.nil? ? nil : add_key_mitserver
  end
  
  protected
  def search_mitserver_key(search_str)
      url = "http://pgp.mit.edu:11371"
      page = @agent.get(@server)
      resp = page.form_with(:action=>"http://pgp.mit.edu:11371/pks/lookup") do |form|
        form['search'] = search_str
      end.submit
      doc =  resp.parser
      unless doc.nil?
        url +=  doc.at("a")['href']
        page = @agent.get(url)
        doc = page.parser
      end
      doc.at("pre").inner_text ? doc.at("pre").inner_text  : nil
  end
  def add_key_mitserver
    content = File.open(@keyfile) do |f|
      f.read
    end
    
    page = @agent.get(@server)
    resp = page.form_with(:action=>'http://pgp.mit.edu:11371/pks/add') do |form|
      form['keytext'] = content
    end.submit
    resp.body =~ /added succesfully/ ? true : false
  end
end

k = KeyServer.new
key = k.search_key('vpereira@web.de')
k.add_key("key.txt")
