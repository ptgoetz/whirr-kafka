package org.apache.whirr.service.kafka;

import org.apache.commons.configuration.Configuration;
import org.apache.whirr.ClusterSpec;
import org.apache.whirr.service.ClusterActionEvent;
import org.apache.whirr.service.ClusterActionHandlerSupport;
import org.jclouds.scriptbuilder.domain.Statements;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import static org.jclouds.scriptbuilder.domain.Statements.call;

public class KafkaClusterActionHandler extends ClusterActionHandlerSupport {
    public static final String ROLE = "kafka";

    @Override
    public String getRole() {
        return ROLE;
    }

    @Override
    protected void beforeBootstrap(ClusterActionEvent event) throws IOException, InterruptedException {
        super.beforeBootstrap(event);
        ClusterSpec clusterSpec = event.getClusterSpec();
        Configuration conf = clusterSpec.getConfiguration();
        addStatement(event, call("retry_helpers"));
        addStatement(event, call("configure_hostnames"));

        addStatement(event, call(getInstallFunction(conf, "java", "install_openjdk")));

        addStatement(event, call("install_kafka"));
    }

    @Override
    protected void beforeConfigure(ClusterActionEvent event) throws IOException, InterruptedException {
        super.beforeConfigure(event);
        List<String> kafkaInit = new ArrayList<String>();
        InputStream scriptIn = getClass().getResourceAsStream("/kafka.sh");
        InputStreamReader isr = new InputStreamReader(scriptIn);
        BufferedReader reader = new BufferedReader(isr);
        String line = null;
        while((line = reader.readLine()) != null){
            kafkaInit.add(line);
        }
        reader.close();
        addStatement(event, Statements.createOrOverwriteFile("/etc/init.d/kafka", kafkaInit));


        addStatement(event, call("configure_kafka"));

        Properties props = new Properties();
        InputStream in = getClass().getResourceAsStream("/kafka_defaults.properties");
        props.load(in);

        List<String> kafkaConfig = new ArrayList<String>();

        for(Object key : props.keySet()){
            kafkaConfig.add(String.format("%s=%s", key, props.get(key)));
        }

        // TODO pull in overrides prefixed with "whirr-kafka"
        // TODO if zk is enabled, poke appropriate holes in the firewall
        // TODO auto-configure zk and bark if the user tried to set it with a "whirr-kafka" property

        addStatement(event, Statements.createOrOverwriteFile("/etc/kafka/server.properties", kafkaConfig));


    }


    @Override
    protected void beforeStart(ClusterActionEvent event) {
        addStatement(event, call("start_kafka"));
    }

    @Override
    protected void beforeStop(ClusterActionEvent event) {
        addStatement(event, call("stop_kafka"));
    }
}
