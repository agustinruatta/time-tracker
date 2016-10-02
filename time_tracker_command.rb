require_relative 'hours_service'

class TimeTrackerCommand
  START_COMMAND = 'start'
  STOP_COMMAND = 'stop'
  WORKED_COMMAND = 'worked'
  
  def initialize
    @hours_service = HoursService.new
  end
  
  def execute(args)
    command = args[0]

    case command
      when START_COMMAND
        if @hours_service.can_start?
          @hours_service.start
          puts 'Correct start'
        else
          puts "You can't start"
        end
    
      when STOP_COMMAND
        if @hours_service.can_stop?
          @hours_service.stop
          puts 'Correct stop'
        else
          puts "You can't stop"
        end
        
      when WORKED_COMMAND
        unless @hours_service.can_get_worked_hours?
          puts 'Please, set the "stop"'
          
          return
        end
        
        date = args.length > 1 ? get_day(args[1]) : Date.today
        
        unless date.nil?
          seconds = @hours_service.seconds_worked_in_day(date)
          
          puts "Hours worked on #{date}: #{Time.at(seconds).utc.strftime("%H:%M:%S")}"
        else
          puts "Incorrect date '#{args[1]}'"
        end
        
      else
        puts "Unknown command: #{command}"
    end
    
  end
  
  private
  
  def get_day(string)
    split = string.split('-')
    
    if split.length == 3
      return Date.new(split[0].to_i, split[1].to_i, split[2].to_i)
    else
      return nil
    end
    
  end
  
  
end