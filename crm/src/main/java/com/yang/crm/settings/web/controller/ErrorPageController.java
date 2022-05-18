package com.yang.crm.settings.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class ErrorPageController {
    @RequestMapping("/settings/error/to404Page.do")
    public String to404Page() {
        return "settings/error/404page";
    }
}
