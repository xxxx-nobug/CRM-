package com.yang.crm.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class IndexController {
    // 初始界面，只作为一个转发媒介
    @RequestMapping("/")
    public String index() {
        return "index";
    }
}
