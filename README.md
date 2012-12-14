nodejs-process-monitor
======================

process-monitor will 
1) spawn a child process to run the provided executable
2) Monitors it and respawns the child if the process gets terminated
3) It can watch a config file for that executable. If any changes in the file, it sends SIGHUP to the child to resync the config.
4) If the config file is renamed or deleted, it kills the child.


Refer to examples directory for sample usage



