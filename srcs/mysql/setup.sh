service mysql start
echo "CREATE DATABASE testdb;" | mysql -u root
echo "CREATE USER 'testuser'@'localhost' IDENTIFIED BY 'testpw';" | mysql -u root
echo "GRANT USAGE ON *.* TO 'testuser'@'localhost' IDENTIFIED BY 'testpw';" | mysql -u root
echo "GRANT ALL privileges ON testdb.* TO 'testuser'@localhost;" | mysql -u root
echo "FLUSH PRIVILEGES;" | mysql -u root