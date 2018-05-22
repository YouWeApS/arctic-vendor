module URI
  # Merges the `new_params` with the existing query parameters from the `url`
  def self.replace_params(url, new_params)
    uri = parse url
    params = params_hash(uri).merge new_params
    new_url = "#{uri.scheme}://#{uri.host}#{uri.path}?#{new_params.to_query}##{uri.fragment}"
    parse new_url
  end

  # Extracts a ruby hash from the URI query string
  def self.params_hash(uri)
    Hash[CGI.parse(uri.query).collect { |k, v| [k, v.join('')] }]
  end
end
