#! /bin/sh

### BEGIN INIT INFO
# Provides:          juju-azure
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Should-Start:      $named 
# Default-Start:     2 3 4 5
# Default-Stop:      
# Short-Description: Implements redirect hostname in web page
# Description:       rsync is a program that allows files to be copied to and
#                    from remote machines in much the same way as rcp.
#                    This provides rsyncd daemon functionality.
### END INIT INFO

set -e

# /etc/init.d/rsync: start and stop the rsync daemon
