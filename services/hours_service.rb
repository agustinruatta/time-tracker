require_relative '../repositories/hours_repository'
require_relative '../services/config_service'

class HoursService
  
  def initialize
    @hours_repository = HoursRepository.new
    @config_service = ConfigService.new
  end
  
  def start
    @hours_repository.save_start @config_service.current_project, DateTime.now
  end
  
  def stop
    @hours_repository.save_stop @config_service.current_project, DateTime.now
  end
  
  def seconds_worked(from, to)
    labors = get_all_labors_between from, to
    
    return 0 unless labors.any?

    raise Exception.new('The first action between "from" and "to" is not "start"') if labors.first.action != Labor::START_ACTION
    raise Exception.new('The last action between "from" and "to" is not "stop"') if labors.last.action != Labor::STOP_ACTION
    
    total_seconds = 0

    labors.each_slice(2) do |start, stop|
      raise Exception.new('Invalid file. There must not be two contiguous "start" or "stop" actions.') if start.action != Labor::START_ACTION || stop.action != Labor::STOP_ACTION
      
      total_seconds += ((stop.date_time - start.date_time) * 24 * 60 * 60).to_i
    end
    
    return total_seconds.to_i
  end
  
  def seconds_worked_to_now(from)
    labors = get_all_labors_between from, DateTime.now
  
    return 0 unless labors.any?
  
    raise Exception.new('The first action is not "start"') if labors.first.action != Labor::START_ACTION
    raise Exception.new('The last action is not "start"') if labors.last.action != Labor::START_ACTION
  
    total_seconds = 0
  
    labors.each_slice(2) do |start, stop|
      unless stop.nil?
        raise Exception.new('Invalid file. There must not be two contiguous "start" or "stop" actions.') if start.action != Labor::START_ACTION || stop.action != Labor::STOP_ACTION
        
        difference = stop.date_time - start.date_time
      else
        difference = DateTime.now - start.date_time
      end
      
      total_seconds += (difference * 60 * 60 * 24).to_i
    end
  
    return total_seconds.to_i
  end
  
  def can_start?
    return last_action_is_different Labor::START_ACTION
  end
  
  def can_stop?
    return last_action_is_different Labor::STOP_ACTION
  end
  
  def has_data?
    @hours_repository.get_all(@config_service.current_project).any?
  end

  def last_action_is_stop?
    return @hours_repository.get_all(@config_service.current_project).last.action ==
      Labor::STOP_ACTION
  end
  
  private
  
  def get_all_labors_between(from, to)
    labors = []
    
    @hours_repository.get_all(@config_service.current_project).each do |labor|
      labors << labor if labor.date_time >= from && labor.date_time <= to
    end
    
    return labors
  end
  
  def last_action_is_different(action)
    all = @hours_repository.get_all(@config_service.current_project)
    
    if all.any?
      return all.last.action != action
    else
      #If file is empty, only the 'start' method is correct
      return action == Labor::START_ACTION
    end
    
  end
  
  
end