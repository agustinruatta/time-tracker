class Labor
  STOP_ACTION = 'stop'
  START_ACTION = 'start'
  
  attr_reader :date_time, :action
  
  def initialize(date_time, action)
    @date_time = date_time
    
    raise Exception.new("Invalid action #{action}") if action != START_ACTION && action != STOP_ACTION
    
    @action = action
  end
end