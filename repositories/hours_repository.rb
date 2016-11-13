require 'csv'
require_relative '../labor'

class HoursRepository
  DATA_FOLDER = 'data'
  
  DATETIME_COLUMN = 'datetime'
  ACTION_COLUMN = 'action'
  TASK_NAME_COLUMN = 'task-name'
  
  def save_start(project_name, time = Time.now)
    CSV.open(get_data_file_path(project_name), 'a') do |csv|
      csv << [time, Labor::START_ACTION, '']
    end
  end

  def save_stop(project_name, time = Time.now)
    CSV.open(get_data_file_path(project_name), 'a') do |csv|
      csv << [time, Labor::STOP_ACTION, '']
    end
  end
  
  # Save the start of the task
  def save_start_task(project_name, task, time = Time.now)
    CSV.open(get_data_file_path(project_name), 'a') do |csv|
      csv << [time, Labor::START_TASK_ACTION, task]
    end
  end

  # Stop the last task
  def save_stop_task(project_name, time = Time.now)
    CSV.open(get_data_file_path(project_name), 'a') do |csv|
      csv << [time, Labor::STOP_TASK_ACTION, '']
    end
  end
  
  # Return all the labors
  # @return Labors[]
  def get_all(project_name)
    times = []
    
    CSV.foreach(get_data_file_path(project_name), headers: true) do |row|
      times  << Labor.new(DateTime.parse(row[DATETIME_COLUMN]), row[ACTION_COLUMN], row[TASK_NAME_COLUMN])
    end
    
    return times
  end

  def clear_data(project_name)
    File.delete get_data_file_path project_name
  end
  
  
  private
  
  # Get the data file. If the file does not exist,
  # the method will create it.
  def get_data_file_path(project_name)
    data_file_path = data_file_path(project_name)
    
    create_data_file project_name unless File.exists? data_file_path
    
    return data_file_path
  end

  def create_data_file(project_name)
    # Create folder if it does not exists
    Dir.mkdir(DATA_FOLDER) unless File.exists?(DATA_FOLDER)
    
    data_file = File.new(data_file_path(project_name), 'w')
  
    # Write headers
    data_file.puts('"datetime","action"')
  
    data_file.close
  end

  def data_file_path(project_name)
    data_file_name = project_name + '_data.csv'
  
    return 'data/' + data_file_name
  end
  
end