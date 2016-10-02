class Labor
  STOP_ACTION = 'stop'
  START_ACTION = 'start'
  
  attr_reader :time, :action
  
  def initialize(time, action)
    @time = time
    @action = action
  end
end