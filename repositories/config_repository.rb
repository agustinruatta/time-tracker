class ConfigRepository
  CONFIG_FILE = 'config.json'
  
  def save_config(config)
    file = File.new(CONFIG_FILE, 'w')
    file.puts(config.to_json)
    file.close
  end

  def current_config
    begin
      config_file = File.read(CONFIG_FILE)
      
      return JSON.parse(config_file)
    rescue JSON::ParserError, Errno::ENOENT
      return Hash.new
    end
  end
end