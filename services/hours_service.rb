require_relative '../repositories/hours_repository'
require_relative '../services/config_service'
require_relative '../time_tracker_exception'

class HoursService
  
  def initialize
    @hours_repository = HoursRepository.new
    @config_service = ConfigService.new
  end
  
  def start
    if can_start?
      @hours_repository.save_start @config_service.current_project, DateTime.now
    else
      raise TimeTrackerException.new "You can't start again!"
    end
  end
  
  def stop
    if can_stop?
      @hours_repository.save_stop @config_service.current_project, DateTime.now
    else
      raise TimeTrackerException.new "You can't stop again!"
    end
  end

  def start_task(task)
    if task.nil?
      raise TimeTrackerException.new('You forgot task name!')
    end
    
    if can_start_action?
      @hours_repository.save_start_task @config_service.current_project, task
    else
      raise TimeTrackerException.new("You can't start task.")
    end
  end

  def stop_task
    if can_stop_action?
      @hours_repository.save_stop_task @config_service.current_project
    else
      raise TimeTrackerException.new("You can't stop task.")
    end
  end
  
  def clear
    @hours_repository.clear_data @config_service.current_project
  end
  
  def seconds_worked(from, to)
    unless last_action_is_equal? Labor::STOP_ACTION
      raise TimeTrackerException.new 'Please, set the "stop"'
    end

    raise TimeTrackerException.new("'To' is not newer than 'from'\n\tFrom: #{from}\n\tTo: #{to}") if from > to
    
    labors = get_all_labors_between from, to
    labors = filter_task_actions labors
    
    return 0 if labors.empty?

    #The first action must be START, and the last must be STOP
    raise TimeTrackerException.new('The first action between "from" and "to" is not "start"') if labors.first.action != Labor::START_ACTION
    raise TimeTrackerException.new('The last action between "from" and "to" is not "stop"') if labors.last.action != Labor::STOP_ACTION
    
    total_seconds = 0

    labors.each_slice(2) do |start, stop|
      raise TimeTrackerException.new('Invalid file. There must not be two contiguous "start" or "stop" actions.') if start.action != Labor::START_ACTION || stop.action != Labor::STOP_ACTION
      
      total_seconds += ((stop.date_time - start.date_time) * 24 * 60 * 60).to_i
    end
    
    return total_seconds.to_i
  end
  
  def seconds_worked_to_now(from)
    labors = get_all_labors_between from, DateTime.now
    labors = filter_task_actions labors
  
    return 0 if labors.empty?
  
    #The first action must be START, and the last must not be STOP
    raise TimeTrackerException.new('The first action is not "start"') if labors.first.action != Labor::START_ACTION
    raise TimeTrackerException.new('The last action is "stop"') if labors.last.action == Labor::STOP_ACTION
  
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
  
  # @param [DateTime] from
  # @param [DateTime] to
  # @return Hash
  def seconds_worked_in_each_task(from, to)
    labors = get_all_labors_between from, to
    labors = filter_project_actions labors
  
    tasks_duration_seconds = Hash.new(0)
    
    labors.each_slice(2) do |start_action, stop_action|
      raise TimeTrackerException.new('Invalid file. There must not be two contiguous "start-task" or "stop-task" actions.') if start_action.action != Labor::START_TASK_ACTION || stop_action.action != Labor::STOP_TASK_ACTION
  
      task = start_action.task
      
      previous_seconds = tasks_duration_seconds[task]
      
      tasks_duration_seconds[task] = previous_seconds + ((stop_action.date_time - start_action.date_time) * 24 * 60 * 60).to_i
    end

    return tasks_duration_seconds
  end
  
  def has_data?
    @hours_repository.get_all(@config_service.current_project).any?
  end

  private

  def can_start?
    return last_action_is_equal? Labor::STOP_ACTION
  end

  def can_stop?
    return (last_action_is_equal?(Labor::START_ACTION) || last_action_is_equal?(Labor::STOP_TASK_ACTION))
  end

  def can_start_action?
    return (last_action_is_equal?(Labor::START_ACTION) || last_action_is_equal?(Labor::STOP_TASK_ACTION))
  end

  def can_stop_action?
    return last_action_is_equal? Labor::START_TASK_ACTION
  end
  
  # Filter all labors related to task
  def filter_task_actions(labors)
    labors_without_tasks = labors.select do |labor|
      labor.is_a_task_action?
    end
    
    return labors_without_tasks
  end
  
  def filter_project_actions(labors)
    labors_without_project_actions = labors.select do |labor|
      labor.is_a_project_action?
    end
  
    return labors_without_project_actions
  end
  
  def get_all_labors_between(from, to)
    labors = []
    
    @hours_repository.get_all(@config_service.current_project).each do |labor|
      labors << labor if labor.date_time >= from && labor.date_time <= to
    end
    
    return labors
  end
  
  def last_action_is_equal?(action)
    all = @hours_repository.get_all(@config_service.current_project)
  
    if all.any?
      return all.last.action == action
    else
      #If file is empty, take 'stop' as the last action
      return action == Labor::STOP_ACTION
    end
  end
  
end