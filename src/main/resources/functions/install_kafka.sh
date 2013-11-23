function install_kafka(){
    apt-get install -y cronolog

    wget http://mirror.reverse.net/pub/apache/incubator/kafka/kafka-0.7.2-incubating/kafka-0.7.2-incubating-src.tgz

    tar -zxf kafka-0.7.2-incubating-src.tgz
    rm kafka-0.7.2-incubating-src.tgz
    cd kafka-0.7.2-incubating-src/

    ./sbt update
    ./sbt package


    groupadd kafka
    useradd --gid kafka --home-dir /home/kafka --create-home --shell /bin/bash kafka

    cd ../
    mv kafka-0.7.2-incubating-src /usr/share/kafka-0.7.2

    chown -R kafka:kafka /usr/share/kafka-0.7.2
    ln -s /usr/share/kafka-0.7.2 /usr/share/kafka
}