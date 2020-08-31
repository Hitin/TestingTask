module PostService
  class << self
    def create_post(attrs)
      change_service(Rails.configuration.external_api_url, attrs, 'Post')
    end

    def get_post(id)
      request_service(current_url(id), 'Get')
    end

    def update_post(attrs, id)
      change_service(current_url(id), attrs, 'Put')
    end

    def delete_post(id)
      request_service(current_url(id), 'Delete')
    end

    def request_service(uri, method)
      uri = URI(uri)
      http = Net::HTTP.new(uri.host)
      method = "Net::HTTP::#{method}".constantize
      req = method.new(uri.path)
      res = http.request(req)
      res
    rescue StandardError => e
      logger_error(e)
    end

    def change_service(url, attrs, method)
      uri = URI(url)
      headers = { 'Content-Type' => 'application/json; charset=UTF-8' }
      http = Net::HTTP.new(uri.host)
      method = "Net::HTTP::#{method.capitalize}".constantize
      req = method.new(uri.path, headers)
      req.body = attrs.to_json
      res = http.request(req)
      res
    rescue StandardError => e
      logger_error(e)
    end

    def logger_error(e)
      Rails.logger.error { "#{e.message} #{e.backtrace.join("\n")}" }
      nil
    end

    def permitted_method?(method)
      ['get', 'put', 'post', 'update', 'delete'].include?(method.downcase)
    end

    def replace_key(hash, new, old)
      hash[new] = hash.delete(old)
      hash
    end

    def current_url(id)
      [Rails.configuration.external_api_url, id].join('/')
    end
  end
end
