require_relative 'hours_repository'

class HoursService
  
  def initialize
    @hours_repository = HoursRepository.new
  end
  
  def start
    @hours_repository.save_start Time.now
  end
  
  def stop
    @hours_repository.save_stop Time.now
  end
  
  def seconds_worked_in_day(date)
    labors = []
    
    @hours_repository.get_all.each do |labor|
      labors << labor if are_in_the_same_day labor.time, date
    end
    
    raise Exception.new('Invalid file. There are not an even quantity of times.') if labors.length.odd?
    
    total_seconds = 0

    labors.each_slice(2) do |start, stop|
      raise Exception.new('Invalid file. See the "start" and "stop" actions') if start.action != Labor::START_ACTION || stop.action != Labor::STOP_ACTION
      
      total_seconds += (stop.time - start.time)
    end
    
    return total_seconds.to_i
  end
  
  def can_start?
    return last_action_is_different Labor::START_ACTION
  end
  
  def can_stop?
    return last_action_is_different Labor::STOP_ACTION
  end

  def can_get_worked_hours?
    return @hours_repository.get_all.last.action != Labor::START_ACTION
  end
  
  private
  
  def are_in_the_same_day(time, date)
    return (
      time.year == date.year &&
      time.month == date.month &&
      time.day == date.day
    )
  end
  
  def last_action_is_different(action)
    all = @hours_repository.get_all
    
    if all.any?
      return all.last.action != action
    else
      #If file is empty, only the 'start' method is correct
      return action == Labor::START_ACTION
    end
    
  end
end