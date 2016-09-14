#!/bin/bash  

#====================================================================================
# Example of scp/ssh interaction using expect.
# Source: http://www.tamas.io/automatic-scp-using-expect-and-bash/
#====================================================================================

#Setup a few static variables
HOST_IP="1.1.1.1"  
REMOTE_IP="2.2.2.2"

# Encrypted password
# obfuscating the server password in the way I've done below is not the best, however it's still better than just displaying it 
# in plain text - a regular user may not know how to interpret the result of the  
SCP\_PASSWORD\_E="eW91IGFyZSBjdXJpb3VzLCBhcmVuJ3QgeW91PyA6LSkK"  
SCP_PASSWORD=`echo "$SCP_PASSWORD_E" | base64 -di`

#Remote execution of a command that collects data and saves it to a file - you can do whatever you want here
ssh user@$REMOTE_IP 'for i in `find /var/lib/mysql/database/ -type f | egrep -vi ".trn|.frm|.trg"  | sort`; do e=`md5sum "$i"`; echo "$e" >> /tmp/my.file; done'

#And now transfer the file over
expect -c "  
   set timeout 1
   spawn scp user@$REMOTE_IP:/tmp/my.file user@$HOST_IP:/home/.
   expect yes/no { send yes\r ; exp_continue }
   expect password: { send $SCP_PASSWORD\r }
   expect 100%
   sleep 1
   exit
"  
if [ -f "/home/my.file" ]; then  
echo "Success"  
fi

#Carry on with the code ...
