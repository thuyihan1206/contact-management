module ApiHelper
  # parsed body (expecting json format)
  def parsed_body
    JSON.parse(response.body)
  end

  # automates the passing of payload bodies as json
  ['post', 'put', 'patch', 'get', 'head', 'delete'].each do |http_method_name|
    define_method("j#{http_method_name}") do |path, params = {}, headers = {}|
      if ['post', 'put', 'patch'].include? http_method_name
        headers = headers.merge('content-type' => 'application/json') unless params.empty?
        params = params.to_json
      end
      send(http_method_name, path, params, headers)
    end
  end

  # check if two arrays contain the same contents
  def same_set?(a, b)
    ((a - b) + (b - a)).blank?
  end
end