# Time tracker

A command line time tracker, to save and track the hours worked.

# Requeriments
- Ruby > 1.9.2
- 'json' gem. To check if you have it:

```irb
require 'json'
 => true
```

# Commands
There are three commands

- 'start': when you start working.
- 'stop': when you stop working.
- 'worked': hours worked between dates.

See below for examples.

# Examples

`$ ruby time_tracker.rb start`: set the start of your work.

`$ ruby time_tracker.rb stop`: set the stop of your work.

`$ ruby time_tracker.rb worked`: get the hours worked today.

`$ ruby time_tracker.rb worked 2016-10-02`: get the hours worked on 2016-10-02.

`$ ruby time_tracker.rb worked 2016-10-02 2016-10-03`: get worked hours between
 **2016-10-02 00:00:00** and **2016-10-03 23:59:59**.
 
`$ ruby time_tracker.rb worked 2016-10-02*01:02:03 2016-10-03`: get worked hours
between **2016-10-02 01:02:03** and **2016-10-03 23:59:59**.

`$ ruby time_tracker.rb worked 2016-10-02 2016-10-03*12:25:23`:
get worked hours between **2016-10-02 00:00:00** and **2016-10-03 12:25:23**.
 
`$ ruby time_tracker.rb worked 2016-10-02*01:02:03 2016-10-03*12:25:23`:
get worked hours between **2016-10-02 01:02:03** and **2016-10-03 12:25:23**.

# Disclaimers

TimeTracker is just a draft project. Do not aim to find a Project
with good programming practices (Like dependencies injection) or 
correct files structure.

# Author

Agustín Ruatta - agustinruatta@gmail.com