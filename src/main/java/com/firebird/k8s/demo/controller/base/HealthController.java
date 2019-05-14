package com.firebird.k8s.demo.controller.base;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;



/**
 * @Author: 火鸟FireBird
 * @Email: yangchenhui@yixia.com
 * @Description:
 * @Date: 2018/7/6 上午11:05
 * @Version:
 * @FunctionDesc:
 */
@Controller
@EnableAutoConfiguration
@ResponseBody
@RequestMapping("/")
public class HealthController {

    private Logger logger = LoggerFactory.getLogger(HealthController.class);

    @RequestMapping(path = "/health",method = RequestMethod.GET)
    public String health() {
        logger.info(" server is health! ");
        return "ok";
    }

}
