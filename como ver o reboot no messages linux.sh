Why does Red Hat Enterprise Linux Server reboot with "signal 15" messages in /var/log/messages?
 SOLUTION VERIFIED - Updated April 10 2014 at 5:41 PM - English
Issue

Server rebooted with "signal 15."
Server automatically rebooted.
Server unexpectedly rebooted.
What does exiting on signal 15 mean in /var/log/messages?
Raw
     shutdown: shutting down for system reboot
     init: Switching to runlevel: 6
    [...]
     exiting on signal 15
     syslogd 1.4.1: restart.
     syslog: syslogd startup succeeded
Server Rebooted unexpectedly with the shutdown message in /var/log/messages.
Raw
   <hostname> shutdown[7180]: shutting down for system reboot <--- This log shows manual REBOOT triggered by someone
   <hostname> snmpd[4058]: cmaX: subMIB 18 handler has disconnected
   <hostname> sshd[7113]: Transferred: sent 5192, received 3424 bytes
   <hostname> snmpd[4058]: cmaX: subMIB 1 handler has disconnected
   <hostname> .
   <hostname> .
   <hostname> .
   <hostname> snmpd[4058]: cmaX: subMIB 21 handler has disconnected
   <hostname> snmpd[4058]: cmaX: subMIB 22 handler has disconnected
   <hostname> snmpd[4058]: cmaX: subMIB 23 handler has disconnected
   <hostname> hpasmxld[4551]: Process has been instructed to stop from the user interface. Stopping hpasmxld process. . .
   <hostname> xinetd[4114]: Exiting...
   <hostname> vasd[25173]: vasd IPC handler (PID 25173) exiting
   <hostname> vasd[11150]: vasd parent process (PID 11150) exiting
   <hostname> kernel: ACPI: PCI interrupt for device 0000:01:04.6 disabled
   <hostname> ntpd[4129]: ntpd exiting on signal 15
   <hostname> vasproxyd[11280]: 11280: Got SIGTERM/SIGINT. Shutting down...
   <hostname> rpc.statd[3730]: Caught signal 15, un-registering and exiting.
   <hostname> portmap[9171]: connect from 127.0.0.1 to unset(status): request from unprivileged port
   <hostname> kernel: Kernel logging (proc) stopped.
   <hostname> kernel: Kernel log daemon terminating.
   <hostname> exiting on signal 15
   <hostname> syslogd 1.4.1: restart.

