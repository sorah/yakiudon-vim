# yakiudon.rb - wrapper of yakiudon api written in ruby.
#
# Author: Shota Fukumori (sora_h)
# Licence: The MIT Licence {{{
#     Permission is hereby granted, free of charge, to any person obtaining a copy
#     of this software and associated documentation files (the "Software"), to deal
#     in the Software without restriction, including without limitation the rights
#     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#     copies of the Software, and to permit persons to whom the Software is
#     furnished to do so, subject to the following conditions:
# 
#     The above copyright notice and this permission notice shall be included in
#     all copies or substantial portions of the Software.
# 
#     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#     THE SOFTWARE.
# }}}

require "rubygems"
require "json"
require "open-uri"
require "net/http"

module YakiudonAPI
  class << self
    def list(root)
      j = open("#{root.gsub(/\/$/,"")}/all.json") do |io|
        JSON.parse(io.read)
      end
      j["days"]
    end

    def get(root,id)
      open("#{root.gsub(/\/$/,"")}/#{id.gsub(/[^\d]/,"")}.json") do |io|
        JSON.parse(io.read)
      end
    end

    def post(root,id,user,pass,title,body)
      uri = URI.parse("#{root.gsub(/\/$/,"")}/edit/#{id.gsub(/[^\d]/,"")}")
      data = {"title" => title, "body" => body}
      Net::HTTP.start(uri.host, uri.port) do |http| 
        req = Net::HTTP::Post.new(uri.path)
        req.set_form_data data,";"
        req.basic_auth user,pass
        res = http.request(req)
        if res.kind_of?(Net::HTTPRedirection)
          res['location']
        else
          res.body || nil
        end
      end
    end
  end
end

cmd, root = ARGV[0..1]

case cmd
when "edit"
  user,pass,id = ARGV[2..4]
  body = $stdin.read.split(/\r?\n/)
  title = body.shift
  !((_=body.shift).empty?) && body.unshift(_)
  body = body.join("\n")
  puts YakiudonAPI.post(root,id,user,pass,title,body)
when "get"
  id = ARGV[2]
  y = YakiudonAPI.get(root,id)
  puts "#{y["title"]}"
  puts ""
  puts y["markdown"]
when "list"
  y = YakiudonAPI.list(root)
  puts y.map{|d| "#{d["id"]}: #{d["title"]}" }.join("\n")
end
