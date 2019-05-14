package com.firebird.k8s.demo.application;

import io.undertow.Undertow;
import io.undertow.server.ConnectorStatistics;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.web.embedded.undertow.UndertowServletWebServer;
import org.springframework.boot.web.servlet.context.ServletWebServerApplicationContext;
import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextClosedEvent;
import org.springframework.stereotype.Component;

import java.lang.reflect.Field;
import java.util.List;


@Component
public class GracefulShutdownUndertow implements ApplicationListener<ContextClosedEvent> {

    private Logger logger = LoggerFactory.getLogger(GracefulShutdownUndertow.class);

    @Autowired
    private GracefulShutdownUndertowWrapper gracefulShutdownUndertowWrapper;

    @Autowired
    private ServletWebServerApplicationContext context;

    @Override
    public void onApplicationEvent(ContextClosedEvent contextClosedEvent){
        gracefulShutdownUndertowWrapper.getGracefulShutdownHandler().shutdown();
        try {
            UndertowServletWebServer webServer = (UndertowServletWebServer)context.getWebServer();
            Field field = webServer.getClass().getDeclaredField("undertow");
            field.setAccessible(true);
            Undertow undertow = (Undertow) field.get(webServer);
            List<Undertow.ListenerInfo> listenerInfo = undertow.getListenerInfo();
            Undertow.ListenerInfo listener = listenerInfo.get(0);
            ConnectorStatistics connectorStatistics = listener.getConnectorStatistics();
            while (connectorStatistics.getActiveConnections() > 0){}
        }catch (Exception e){
            // Application Shutdown
            logger.info("GracefulShutdownUndertow error = {} " , e.getMessage());
        }
    }
}
