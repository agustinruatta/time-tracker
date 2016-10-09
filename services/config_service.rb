require 'json'

require_relative '../repositories/config_repository'

class ConfigService
  CURRENT_PROJECT_OPTION = 'current_project'
  
  def initialize
    @config_repository = ConfigRepository.new
  end
  
  def set_project(project_name)
    config = @config_repository.current_config
  
    # Set new current project
    config[CURRENT_PROJECT_OPTION] = project_name
    
    @config_repository.save_config config
  end

  def current_project
    return @config_repository.current_config[CURRENT_PROJECT_OPTION]
  end
  
end