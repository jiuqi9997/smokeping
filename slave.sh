#/bin/bash

kill -9 $(ps -ef|grep smokeping_cgi|awk '$0 !~/grep/ {print $2}' |tr -s '\n' ' ')
kill -9 $(ps -ef|grep 'smokeping/bin/smokeping'|awk '$0 !~/grep/ {print $2}' |tr -s '\n' ' ')

chown -R nginx:nginx /usr/local/smokeping/htdocs
/usr/local/smokeping/bin/smokeping --config=/usr/local/smokeping/etc/config &
/usr/local/smokeping/bin/smokeping --master-url=http://127.0.0.1:9008/ --cache-dir=/usr/local/smokeping/cache/ --shared-secret=/usr/local/smokeping/etc/secrets --slave-name=SLAVE_CODE &
/usr/bin/spawn-fcgi -a 127.0.0.1 -p 9007 -P /var/run/smokeping-fastcgi.pid -u nginx -f /usr/local/smokeping/htdocs/smokeping.fcgi
