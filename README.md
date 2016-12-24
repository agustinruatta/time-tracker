# Time tracker

A command line time tracker, to save and track worked hours.

# Requirements
- Ruby >= 1.9.2
- `readline` library. If you use RVM, please, visit 
http://stackoverflow.com/questions/4385549/no-such-file-to-load-readline.

# Commands
There are eight commands:

- `start`: when you start to work.
- `stop`: when you stop to work.
- `start-task`: when you start a task.
- `stop-task`: when you stop a task.
- `tasks`: list of tasks
- `worked`: hours worked between dates.
- `set-project`: set project which you are working.
- `current-project`: retrieve project which you are working.

See below for examples.

# Examples

`> start`: set the start of your work.

`> stop`: set the stop of your work.

`> start-task`: set the start of your task.

`> stop-task`: set the stop of your task.

`> worked`: get the hours worked today.

`> worked 2016-10-02`: get the hours worked on 2016-10-02.

`> worked 2016-10-02 2016-10-03`: get worked hours between
 **2016-10-02 00:00:00** and **2016-10-03 23:59:59**.
 
`> worked 2016-10-02*01:02:03 2016-10-03`: get worked hours
between **2016-10-02 01:02:03** and **2016-10-03 23:59:59**.

`> worked 2016-10-02 2016-10-03*12:25:23`:
get worked hours between **2016-10-02 00:00:00** and **2016-10-03 12:25:23**.
 
`> worked 2016-10-02*01:02:03 2016-10-03*12:25:23`:
get worked hours between **2016-10-02 01:02:03** and **2016-10-03 12:25:23**.

`> worked today 2016-10-03*12:25:23`:
get worked hours between **today at 00:00:00** and **2016-10-03 12:25:23**.

`> worked today*01:02:03 2016-10-03*12:25:23`:
get worked hours between **today at 01:02:03** and **2016-10-03 12:25:23**.

`> worked 2016-10-02*01:02:03 now`:
get worked hours between **2016-10-02 01:02:03** and **now**. Take care
that you **must not** set an *stop* action if you want to use *now*
option.

`> clear`: clear all saved hours from current project.

`> tasks`: display the tasks which you have worked today.

`> tasks 2016-10-02 2016-10-03`: displays the tasks which you have
worked between **2016-10-02 00:00:00** and **2016-10-03 23:59:59**.

`> tasks 2016-10-02*01:02:03 2016-10-03*12:25:23`: displays the tasks 
which you have worked between **2016-10-02 01:02:03** and 
**2016-10-03 12:25:23**.

`> set-project demo`: set `demo` as current project.

`> current-project`: displays current project.

`> exit`: exits program.

## Real life example

```bash
$ ruby time_tracker.rb
Welcome to time tracker!

> set-project demo
Project 'demo' set!

> current-project
Current project: demo

> start
Correct start on 'demo' project

> start-task taskA
Correct 'taskA' task start on 'demo' project

> stop-task
Correct task stop on 'demo' project

> start-task taskB
Correct 'taskB' task start on 'demo' project

> stop-task
Correct task stop on 'demo' project

> start-task taskA
Correct 'taskA' task start on 'demo' project

> stop-task
Correct task stop on 'demo' project

> stop
Correct stop on 'demo' project

> tasks
    *taskA
    *taskB

> worked
From	-> 11/13/2016 00:00:00
To	-> 11/13/2016 23:59:59

Hours worked: 03:50:30

Seconds worked in each task:
	Task 'taskA': 02:23:09
	Task 'taskB': 01:20:03
	Time without any task assigned: 00:07:18

> exit
Goodbye!
```

# Disclaimers

TimeTracker is just a draft project. Do not aim to find a project
with good programming practices (Like dependencies injection) or 
correct files structure.

# Author

Agustín Ruatta - agustinruatta@gmail.com