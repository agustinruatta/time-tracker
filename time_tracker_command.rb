require_relative 'hours_service'

class TimeTrackerCommand
  START_COMMAND = 'start'
  STOP_COMMAND = 'stop'
  WORKED_COMMAND = 'worked'
  HELP_COMMAND = 'help'
  
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
        
        begin
          from = from args
          to = to args
  
          raise Exception.new("'To' is not newer than 'from'\n\tFrom: #{from}\n\tTo: #{to}") if from > to
  
          total_seconds = @hours_service.seconds_worked_in_day(from(args), to(args))

          seconds = total_seconds % 60
          minutes = (total_seconds / 60) % 60
          hours = total_seconds / (60 * 60)
          
          from_text = "From\t-> #{from.strftime('%m/%d/%Y %H:%M:%S')}"
          to_text = "To\t-> #{to.strftime('%m/%d/%Y %H:%M:%S')}"
          hours_worked_text = "Hours worked: #{format('%02d:%02d:%02d', hours, minutes, seconds)}"
          
          puts "#{from_text}\n#{to_text}\n\n#{hours_worked_text}"

        rescue Exception => e
          puts "Error: #{e.message}"
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
  
  def get_date_time(string, set_time_at_end_of_day)
    split = string.split('*')
    
    date = split[0]
    
    if split[1].nil?
      time = set_time_at_end_of_day ? '23:59:59' : '00:00:00'
    else
      time = split[1]
    end
    
    date_split = date.split('-')
    time_split = time.split(':')
    
    # There must be a year, month and day
    raise Exception.new("Incorrect date: #{date}") if date_split.length != 3
    
    year = date_split[0].to_i
    month = date_split[1].to_i
    day = date_split[2].to_i
    
    hours = time_split[0].nil? ? 0: time_split[0].to_i
    minutes = time_split[1].nil? ? 0: time_split[1].to_i
    seconds = time_split[2].nil? ? 0: time_split[2].to_i
    
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