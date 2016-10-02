require 'csv'
require 'time'
require_relative 'labor'

class HoursRepository
  CSV_FILE = 'data.csv'
  
  DATETIME_COLUMN = 'datetime'
  ACTION_COLUMN = 'action'
  
  def save_start(time = Time.now)
    
    CSV.open(CSV_FILE, 'a') do |csv|
      csv << [time, Labor::START_ACTION]
    end
    
  end
  
  def save_stop(time = Time.now)
    
    CSV.open(CSV_FILE, 'a') do |csv|
      csv << [time, Labor::STOP_ACTION]
    end
    
  end
  
  
  def get_all
    times = []
    
    CSV.foreach(CSV_FILE, headers: true) do |row|
      times  << Labor.new(Time.parse(row[DATETIME_COLUMN]), row[ACTION_COLUMN])
    end
    
    return times
  end
end