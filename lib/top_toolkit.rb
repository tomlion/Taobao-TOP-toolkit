require 'digest/md5'
require 'net/http'
require 'open-uri'
require 'iconv'

module TopToolkit
  def sign(param,sercetCode)
    array = param.sort()
    i = 0
    str = sercetCode
    while i < param.length()
      temp = array[i]
      str = str + temp[0] + temp[1]
      i = i + 1    
    end
    str = Digest::MD5.hexdigest(str)
    return str.upcase()
  end
  
  def createRequestParam(paramArray)
    array = paramArray.sort()
    i = 0
    str = ''
    while i < paramArray.length()
      temp = array[i]
      str = str + temp[0] + '=' + temp[1] + '&'
      i = i + 1    
    end
    return str
  end
  
  #URL encode
  def URLEncode(str)
    return str.gsub!(/[^\w$&\-+.,\/:;=?@]/) { |x| x = format("%%%x", x[0])}  
  end
  
  def to_gbk(str)
    Iconv.iconv("GBK//IGNORE","UTF-8//IGNORE",str).to_s
  end
  
  module ClassMethods
    def request_top(options)
      paramArray = {
        'app_key'=>'12001200',                              
        #'app_key'=>'test',                              
        'format'=>'json',
        'v'=>'1.0',
        'timestamp'=>Time.new.strftime("%Y-%m-%d %H:%M:%S")
      }
      if options.is_a?(Hash)
        hash = {}
        options.each{|k,v| hash[k.to_s] = v}
        paramArray.merge!(hash) 
      end
      url = 'http://gw.api.taobao.com/router/rest?'
      url = url + createRequestParam(paramArray)+'sign=' + sign(paramArray,'d6c63786184be2dbd9c6c55e29d41e55')
      #p '---------------',URI.escape(url)
      parsedURL = URI.parse(URI.escape(url))
      
      Net::HTTP.version_1_2
      open(parsedURL)do|http|
        return http.read
      end
    end
  end
  
end


ActionController::Base.class_eval { include TopToolkit::ClassMethods }