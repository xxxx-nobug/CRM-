package com.yang.crm.workbench.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class WorkBenchIndexController {

    /**
     * 登陆后进入的业务初始界面
     * @return 业务初始界面
     */
    @RequestMapping("workbench/index.do")
    public String index() {
        return "workbench/index";
    }
}
