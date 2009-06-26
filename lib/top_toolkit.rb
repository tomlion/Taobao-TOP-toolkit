require 'digest/md5'
require 'net/http'
require 'open-uri'
require 'iconv'

module TopToolkit
  #生成签名
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
  
  #组装请求参数
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
  
  #把str的编码转化为GBK编码
  def to_gbk(str)
    Iconv.iconv("GBK//IGNORE","UTF-8//IGNORE",str).to_s
  end
  
  module ClassMethods
    def request_top(options)
      #组装参数
      paramArray = {
        #组装协议参数
        'app_key'=>'test',
        'method'=>'taobao.taobaoke.items.get',
        'format'=>'xml',
        'v'=>'1.0',
        'timestamp'=>Time.new.strftime("%Y-%m-%d %H:%M:%S"),
          #组装应用参数
        'fields'=>'iid,title,nick,pic_url,price,click_url',
        'pid' => 'mm_5410_0_0',
        'cid' => '1512',
        'page_no' => '1',
        'page_size' => '6'
      }
      if options.is_a?(Hash)
        hash = {}
        options.each{|k,v| hash[k.to_s] = v}
        paramArray.merge!(hash) 
      end
      url = 'http://gw.sandbox.taobao.com/router/rest?'
      url = url + createRequestParam(paramArray)+'sign=' + sign(paramArray,'test')
      parsedURL = URI.parse(URLEncode(url))
      
      #请求生成的URL，把结果输出
      Net::HTTP.version_1_2
      open(parsedURL)do|http|
        return http.read
      end
    end
  end
  
end


ActionController::Base.class_eval { include TopToolkit::ClassMethods }