require 'json'
require 'date'

require_relative 'services/hours_service'
require_relative 'services/config_service'

class TimeTrackerCommand
  START_COMMAND = 'start'
  STOP_COMMAND = 'stop'
  WORKED_COMMAND = 'worked'
  HELP_COMMAND = 'help'
  SET_PROJECT_COMMAND = 'set-project'
  CURRENT_PROJECT_COMMAND = 'current-project'
  
  NOW_OPTION = 'now'
  TODAY_OPTION = 'today'
  
  def initialize
    @hours_service = HoursService.new
    @config_service = ConfigService.new
  end
  
  def execute(args)
    command = args[0]
    
    if(
      (@config_service.current_project.nil? || @config_service.current_project.strip.empty?) &&
      command != SET_PROJECT_COMMAND
    )
      puts 'No current project set. Please, set one.'
      
      return
    end

    case command
      when START_COMMAND
        if @hours_service.can_start?
          @hours_service.start
          puts 'Correct start'
        else
          puts "You can't start again!"
        end
    
      when STOP_COMMAND
        if @hours_service.can_stop?
          @hours_service.stop
          puts 'Correct stop'
        else
          puts "You can't stop again!"
        end
        
      when WORKED_COMMAND
        (puts 'No hours saved to calculate'; return) unless @hours_service.has_data?
        
        #begin
          from = from args
          
          unless has_used_now_option? args
            (puts 'Please, set the "stop"'; return) unless @hours_service.last_action_is_stop?
            
            to = to args
            
            raise Exception.new("'To' is not newer than 'from'\n\tFrom: #{from}\n\tTo: #{to}") if from > to

            total_seconds = @hours_service.seconds_worked(from, to)
          else
            to = DateTime.now
            
            total_seconds = @hours_service.seconds_worked_to_now(from)
          end
          
          seconds = total_seconds % 60
          minutes = (total_seconds / 60) % 60
          hours = total_seconds / (60 * 60)
          
          from_text = "From\t-> #{from.strftime('%m/%d/%Y %H:%M:%S')}"
          to_text = "To\t-> #{to.strftime('%m/%d/%Y %H:%M:%S')}"
          hours_worked_text = "Hours worked: #{format('%02d:%02d:%02d', hours, minutes, seconds)}"
          
          puts "#{from_text}\n#{to_text}\n\n#{hours_worked_text}"

        #rescue Exception => e
        #  puts "Error: #{e.message}"
        #end
        
      when SET_PROJECT_COMMAND
        project_name = args[1]
        
        unless project_name.nil?
          @config_service.set_project project_name
          
          puts "Project '#{project_name}' set!"
        else
          puts 'Project name was not sent'
        end
        
      when CURRENT_PROJECT_COMMAND
        current_project = @config_service.current_project
        
        unless current_project.nil?
          puts "Current project: #{current_project}"
        else
          puts 'There is not a current project set'
        end
        
      when HELP_COMMAND
        show_help
        
      else
        puts "Unknown command: #{command}"
    end
    
  end
  
  private
  
  def from(args)
    if args.length >= 2
      get_date_time(args[1], false)
    else
      today = Date.today
  
      return DateTime.new(today.year, today.month, today.day, 0, 0, 0,  DateTime.now.zone)
    end
  end
  
  def to(args)
    if args.length == 3
      get_date_time(args[2], true)
    else
      today = Date.today
      
      return DateTime.new(today.year, today.month, today.day, 23, 59, 59,  DateTime.now.zone)
    end
  end
  
  def has_used_now_option?(args)
    return args[2] == 'now'
  end
  
  def get_date_time(string, set_time_at_end_of_day)
    split = string.split('*')
    
    date = split[0]
    time = split[1]
    
    if date == TODAY_OPTION
      date = Date.today.strftime('%Y-%m-%d')
    end
    
    if time.nil?
      time = set_time_at_end_of_day ? '23:59:59' : '00:00:00'
    end
    
    return parse_date_time date, time
    
  end
  
  def parse_date_time(date, time)
    date_split = date.split('-')
    time_split = time.split(':')
  
    # There must be a year, month and day
    raise Exception.new("Incorrect date: #{date}. There must be a year, month and day") if date_split.length != 3
  
    year = date_split[0].to_i
    month = date_split[1].to_i
    day = date_split[2].to_i
  
    hours = time_split[0].nil? ? 0 : time_split[0].to_i
    minutes = time_split[1].nil? ? 0 : time_split[1].to_i
    seconds = time_split[2].nil? ? 0 : time_split[2].to_i
  
    return DateTime.new(year, month, day, hours, minutes, seconds, DateTime.now.zone)
  end
    
  def show_help
    message = <<-msg
Examples:

`$ ruby time_tracker.rb start`: set the start of your work.

`$ ruby time_tracker.rb stop`: set the stop of your work.

`$ ruby time_tracker.rb worked`: get the hours worked today.

`$ ruby time_tracker.rb worked 2016-10-02`: get the hours worked on 2016-10-02.

`$ ruby time_tracker.rb worked 2016-10-02 2016-10-03`: get worked hours between
 2016-10-02 00:00:00 and 2016-10-03 23:59:59.
 
`$ ruby time_tracker.rb worked 2016-10-02*01:02:03 2016-10-03`: get worked hours
between 2016-10-02 01:02:03 and 2016-10-03 23:59:59.

`$ ruby time_tracker.rb worked 2016-10-02 2016-10-03*12:25:23`:
get worked hours between 2016-10-02 00:00:00 and 2016-10-03 12:25:23.
 
`$ ruby time_tracker.rb worked 2016-10-02*01:02:03 2016-10-03*12:25:23`:
get worked hours between 2016-10-02 01:02:03 and 2016-10-03 12:25:23.

More info: https://github.com/agustinruatta/time-tracker
msg
    
    puts message
  end
  
  
end