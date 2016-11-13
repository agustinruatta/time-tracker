require 'json'

require_relative '../repositories/config_repository'
require_relative '../time_tracker_exception'

class ConfigService
  CURRENT_PROJECT_OPTION = 'current_project'
  
  def initialize
    @config_repository = ConfigRepository.new
  end
  
  def set_project(project_name)
    unless project_name.nil?
      config = @config_repository.current_config
    
      # Set new current project
      config[CURRENT_PROJECT_OPTION] = project_name
      
      @config_repository.save_config config
    else
      raise TimeTrackerException.new 'Project name was not sent'
    end
  end

  def current_project
    return @config_repository.current_config[CURRENT_PROJECT_OPTION]
  end
  
end