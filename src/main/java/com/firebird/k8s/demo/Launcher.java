package com.firebird.k8s.demo;

import com.firebird.k8s.demo.application.GracefulShutdownUndertowWrapper;
import io.undertow.UndertowOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.embedded.undertow.UndertowServletWebServerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.ImportResource;
import org.springframework.context.support.ClassPathXmlApplicationContext;

/**
 * 项目启动
 */
@SpringBootApplication
@Configuration
@ImportResource(locations = {"classpath:application-context.xml"})
@ComponentScan({"com.firebird.k8s.demo"})
public class Launcher {
    private static Logger logger = LoggerFactory.getLogger(Launcher.class);

    public static void main(String [] args){
        SpringApplication.run(Launcher.class, args);
    }


    @Autowired
    private GracefulShutdownUndertowWrapper gracefulShutdownUndertowWrapper;
    @Bean
    public UndertowServletWebServerFactory servletWebServerFactory() {
        UndertowServletWebServerFactory factory = new UndertowServletWebServerFactory();
        factory.addDeploymentInfoCustomizers(deploymentInfo -> deploymentInfo.addOuterHandlerChainWrapper(gracefulShutdownUndertowWrapper));
        factory.addBuilderCustomizers(builder -> builder.setServerOption(UndertowOptions.ENABLE_STATISTICS, true));
        return factory;
    }



}
