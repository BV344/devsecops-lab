# Week 1 Notes — Linux Fundamentals

## chmod — File Permissions
Permissions are split into three groups: Owner, Group, and Others.
Each group gets a number built from adding: Read (4) + Write (2) + Execute (1).

For example:
- chmod 755 — Owner gets rwx (7), Group gets r-x (5), Others get r-x (5)
- chmod 600 — Owner gets rw- (6), nobody else gets anything
- chmod 644 — Owner gets rw- (6), Group and Others get r-- (4)

A good way to verify permissions is with: ls -la

## chown — Change Ownership
chown user filename — changes only the user owner, group stays the same

chown user:group filename — changes both the user owner and the group owner at the same time.
This is what you'll use 90% of the time.

## What is a Process?
A process is a program that is currently running on your system.
Every running program — your terminal, your browser, your scripts — is a process.
Each process gets a unique PID (Process ID) assigned by the kernel.

## What does ps aux do?
Displays a snapshot of every process currently running on the system.
- a = show processes from all users
- u = show the user who owns each process
- x = include processes not attached to a terminal

## What is Load Average?
Load average tells you how many processes are waiting for CPU time.
It shows three numbers representing the last 1, 5, and 15 minutes.

To know if your system is under pressure, compare the load average to your core count (nproc).
- Under your core count = system is fine
- Equal to your core count = fully saturated but coping
- Over your core count = processes are waiting, system is struggling

Example: load average of 2.16 on a 6 core machine = 36% load. No pressure.

## #!/bin/bash — The Shebang
The first line of every bash script. Tells the system to use bash to interpret
and run the script. Without it the system doesn't know what language the script is written in.

## What does $1 mean in a script?
$1 refers to the first argument passed to the script when running it.

Example:
./setup_user.sh john
Inside the script, $1 would equal "john"

This makes scripts reusable — instead of hardcoding a username you pass it in at runtime.

## What does tee -a do?
tee reads from standard input and writes to two places at once:
- The terminal (so you can see it)
- A file (so it gets logged)

The -a flag means append — it adds to the file instead of overwriting it.

Example: echo "hello" | tee -a logfile.txt
Prints "hello" to the terminal AND adds it to logfile.txt

## Biggest Takeaway This Week
Learning how to find and inspect processes through the terminal was
extremely useful — especially for managing a Linux server where there
is no GUI to fall back on.

Also finally understanding chmod properly. I had run those commands
before without knowing what the numbers actually meant. Now I can
read and set permissions confidently instead of just copying commands.
