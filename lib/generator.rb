require 'net/http'
require 'uri'
require 'nokogiri'
require './lib/radiocloud'

class GeneratorApp
  include RadioCloud
  def call(env)
    req = Rack::Request.new(env)
    if req.path.rpartition('/')[-1].rpartition('.')[-1].downcase == 'mp3' then
      url = req['tuneid']
      ref = req['refsite']
      if url.nil? or ref.nil? then
        return [404, {}, ["Not Found"]]
      end
      range = req.env['HTTP_RANGE'] # partial content request
      dom, cookie = get_dom_ref(url, ref)
      src = get_tune_src(dom)
      url = 'https:' + src
      adp = cookie['AD-P']
      if src.nil? or adp.nil? then
        return [404, {}, ["Not Found"]]
      end
      Rack::Response.new do |res|
        res.set_cookie('AD-P', cookie['AD-P'])
        res.redirect(url)
      end
    else
      [404, {}, ["Not Found"]]
    end
  end
end

