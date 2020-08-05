module ExternalService
  class << self
    def service(url, method)
      uri = URI(url)
      http = Net::HTTP.new(uri.host)
      method = "Net::HTTP::#{method}".constantize
      req = method.new(uri.path)
      res = http.request(req)
      res
    end
  
    def change_service(url, attrs, method)
      uri = URI(url)
      headers = { 'Content-Type' => 'application/json; charset=UTF-8' }
      http = Net::HTTP.new(uri.host)
      method = "Net::HTTP::#{method}".constantize
      req = method.new(uri.path, headers)
      req.body = attrs.to_json
      res = http.request(req)
      res
    end
  end
end