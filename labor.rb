class Labor
  STOP_ACTION = 'stop'
  START_ACTION = 'start'
  START_TASK_ACTION = 'start-task'
  STOP_TASK_ACTION = 'stop-task'
  
  attr_reader :date_time, :action, :task_name
  
  def initialize(date_time, action, task_name = '')
    raise Exception.new("Invalid action #{action}") unless valid_action? action
    
    @date_time = date_time
    @action = action
    @task_name = task_name
  end
  
  # Return true if Labor's action is related to task
  def is_a_task_action?
    return (@action != START_TASK_ACTION && action != STOP_TASK_ACTION)
  end
  
  private
  
  def valid_action?(action)
    return (
      action == START_ACTION ||
      action == STOP_ACTION ||
      action == START_TASK_ACTION ||
      action == STOP_TASK_ACTION
    )
  end
end