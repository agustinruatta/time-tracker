# Time tracker

A command line time tracker, to save and track the hours worked.

# Requirements
- Ruby >= 1.9.2

# Commands
There are three commands

- 'start': when you start working.
- 'stop': when you stop working.
- 'worked': hours worked between dates.

See below for examples.

# Examples

`$ ruby time_tracker.rb start`: set the start of your work.

`$ ruby time_tracker.rb stop`: set the stop of your work.

`$ ruby time_tracker.rb start-task`: set the start of your task.

`$ ruby time_tracker.rb stop-task`: set the stop of your task.

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

`$ ruby time_tracker.rb worked today 2016-10-03*12:25:23`:
get worked hours between **today at 00:00:00** and **2016-10-03 12:25:23**.

`$ ruby time_tracker.rb worked today*01:02:03 2016-10-03*12:25:23`:
get worked hours between **today at 01:02:03** and **2016-10-03 12:25:23**.

`$ ruby time_tracker.rb worked 2016-10-02*01:02:03 now`:
get worked hours between **2016-10-02 01:02:03** and **now**. Take care
that you **must not** set an *stop* action if you want to use *now*
option.

`$ ruby time_tracker.rb clear`: clear all saved hours from current project.

## Real life example

```bash
$ ruby time_tracker.rb set-project demo
Project 'demo' set!

$ ruby time_tracker.rb current-project
Current project: demo

$ ruby time_tracker.rb start
Correct start on 'demo' project

$ ruby time_tracker.rb start-task taskA
Correct 'taskA' task start on 'demo' project

$ ruby time_tracker.rb stop-task
Correct task stop on 'demo' project

$ ruby time_tracker.rb start-task taskB
Correct 'taskB' task start on 'demo' project

$ ruby time_tracker.rb stop-task
Correct task stop on 'demo' project

$ ruby time_tracker.rb start-task taskA
Correct 'taskA' task start on 'demo' project

$ ruby time_tracker.rb stop-task
Correct task stop on 'demo' project

$ ruby time_tracker.rb stop
Correct stop on 'demo' project

$ ruby time_tracker.rb worked
From	-> 11/13/2016 00:00:00
To	-> 11/13/2016 23:59:59

Hours worked: 03:50:30

Seconds worked in each task:
	Task 'taskA': 02:23:09
	Task 'taskB': 01:20:03
	Time without any task assigned: 00:07:18


```

# Disclaimers

TimeTracker is just a draft project. Do not aim to find a project
with good programming practices (Like dependencies injection) or 
correct files structure.

# Author

Agustín Ruatta - agustinruatta@gmail.com