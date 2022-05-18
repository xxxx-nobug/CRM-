package com.yang.crm.workbench.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class MainController {
    /**
     * 显示工作台界面
     * @return 工作台界面
     */
    @RequestMapping("/workbench/main/index.do")
    public String index() {
        return "workbench/main/index";
    }
}
