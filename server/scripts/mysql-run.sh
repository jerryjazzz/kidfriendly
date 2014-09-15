
docker run -d -p 3306:3306 -e MYSQL_PASS=`cat ~/.mysql_pass` -v /data/mysql:/var/lib/mysql tutum/mysql
