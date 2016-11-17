require 'json'
require 'date'
require 'readline'

require_relative 'services/hours_service'
require_relative 'services/config_service'
require_relative 'time_tracker_exception'

class TimeTrackerCommand
  START_COMMAND = 'start'
  STOP_COMMAND = 'stop'
  WORKED_COMMAND = 'worked'
  HELP_COMMAND = 'help'
  SET_PROJECT_COMMAND = 'set-project'
  CURRENT_PROJECT_COMMAND = 'current-project'
  CLEAR_COMMAND = 'clear'
  START_TASK = 'start-task'
  STOP_TASK = 'stop-task'
  
  NOW_OPTION = 'now'
  TODAY_OPTION = 'today'
  
  def initialize
    @hours_service = HoursService.new
    @config_service = ConfigService.new
  end
  
  def start_shell
    list = [
      START_COMMAND, STOP_COMMAND, WORKED_COMMAND,
      HELP_COMMAND, SET_PROJECT_COMMAND, CURRENT_PROJECT_COMMAND,
      CLEAR_COMMAND, START_TASK, START_TASK
    ]
    
    comp = proc { |s| list.grep(/^#{Regexp.escape(s)}/) }
  
    Readline.completion_append_character = " "
    Readline.completion_proc = comp
  
    while line = Readline.readline('> ', true)
      execute line.split(' ')
    end
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

    begin
      
      case command
        when START_COMMAND
          @hours_service.start
          puts "Correct start on '#{@config_service.current_project}' project"
      
        when STOP_COMMAND
          @hours_service.stop
          puts "Correct stop on '#{@config_service.current_project}' project"
  
        when START_TASK
          task = args[1]
          
          @hours_service.start_task task
          
          puts "Correct '#{task}' task start on '#{@config_service.current_project}' project"
  
        when STOP_TASK
          @hours_service.stop_task
          puts "Correct task stop on '#{@config_service.current_project}' project"
          
        when WORKED_COMMAND
          (puts 'No hours saved to calculate'; return) unless @hours_service.has_data?
          
          from = from args
          
          unless has_used_now_option? args
            to = to args
  
            total_seconds = @hours_service.seconds_worked(from, to)
          else
            to = DateTime.now
            
            total_seconds = @hours_service.seconds_worked_to_now(from)
          end
          
          from_text = "From\t-> #{from.strftime('%m/%d/%Y %H:%M:%S')}"
          to_text = "To\t-> #{to.strftime('%m/%d/%Y %H:%M:%S')}"
          hours_worked_text = "Hours worked: #{hour_format(total_seconds)}"
          
          puts "#{from_text}\n#{to_text}\n\n#{hours_worked_text}"
          
          unless has_used_now_option? args
            seconds_worked_in_each_task = @hours_service.seconds_worked_in_each_task from, to

            unless seconds_worked_in_each_task.empty?
              puts "\nSeconds worked in each task:\n"
              
              total_seconds_in_tasks = 0
              
              seconds_worked_in_each_task.each do |task_name, task_duration|
                total_seconds_in_tasks += task_duration
                puts "\tTask '#{task_name}': #{hour_format(task_duration)}"
              end
              
              puts "\tTime without any task assigned: #{hour_format(total_seconds - total_seconds_in_tasks)}\n\n"
            end
            
          end
          
        when SET_PROJECT_COMMAND
          project_name = args[1]
          
          @config_service.set_project project_name
          puts "Project '#{project_name}' set!"
          
        when CURRENT_PROJECT_COMMAND
          current_project = @config_service.current_project
          
          unless current_project.nil?
            puts "Current project: #{current_project}"
          else
            puts 'There is not a current project set'
          end
          
        when CLEAR_COMMAND
          print 'Are you sure to clear the data (y/N): '
          
          user_input = STDIN.gets()
          
          if user_input == "y\n"
            @hours_service.clear
            
            puts "Data from '#{@config_service.current_project}' project has been deleted"
          end
          
        when HELP_COMMAND
          show_help
          
        else
          puts "Unknown command: #{command}.\nWrite '#{HELP_COMMAND}' for help\n\n"
      end
    rescue TimeTrackerException => e
      puts "Error: #{e.message}"
    end
    
  end
  
  private
  
  
  def hour_format(total_seconds)
    seconds = total_seconds % 60
    minutes = (total_seconds / 60) % 60
    hours = total_seconds / (60 * 60)

    return format('%02d:%02d:%02d', hours, minutes, seconds)
  end
  
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

`$ ruby time_tracker.rb start-task`: set the start of your task.

`$ ruby time_tracker.rb stop-task`: set the stop of your task.

`$ ruby time_tracker.rb worked`: get the hours worked today.

`$ ruby time_tracker.rb worked 2016-10-02`: get the hours worked on 2016-10-02.

`$ ruby time_tracker.rb worked 2016-10-02 2016-10-03`: get worked hours between
 2016-10-02 00:00:00 and 2016-10-03 23:59:59.
 
`$ ruby time_tracker.rb worked 2016-10-02*01:02:03 2016-10-03`: get worked hours
between 2016-10-02 01:02:03 and 2016-10-03 23:59:59.

`$ ruby time_tracker.rb worked 2016-10-02 2016-10-03*12:25:23`:
  Get worked hours between 2016-10-02 00:00:00 and 2016-10-03 12:25:23.
 
`$ ruby time_tracker.rb worked 2016-10-02*01:02:03 2016-10-03*12:25:23`:
  Get worked hours between 2016-10-02 01:02:03 and 2016-10-03 12:25:23.

`$ ruby time_tracker.rb worked today 2016-10-03*12:25:23`:
  Get worked hours between today at 00:00:00 and 2016-10-03 12:25:23.

`$ ruby time_tracker.rb worked today*01:02:03 2016-10-03*12:25:23`:
  Get worked hours between today at 01:02:03 and 2016-10-03 12:25:23.

`$ ruby time_tracker.rb worked 2016-10-02*01:02:03 now`:
  Get worked hours between 2016-10-02 01:02:03 and now.
  Take care that you MUST NOT set an 'stop' action if you
  want to use 'now' option.

`$ ruby time_tracker.rb clear`: clear all saved hours from current project.

More info: https://github.com/agustinruatta/time-tracker
msg
    
    puts message
  end
  
end