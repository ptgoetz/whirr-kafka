function configure_kafka(){

chmod +x /etc/init.d/kafka
update-rc.d kafka defaults
mkdir /etc/kafka

}