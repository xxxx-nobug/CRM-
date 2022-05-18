package com.yang.crm.commons.utils;

import com.yang.crm.commons.constants.Constants;
import com.yang.crm.settings.domain.User;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;

/**
 * cookie相关的工具类
 */
public class CookieUtils {
    /**
     * 销毁 用户登录 过程产生的cookie
     * @param response 响应信息
     */
    public static void destroyLoginCookie(HttpServletResponse response) {
        // 清空cookie
        // 定义一个同名的cookie对象来覆盖之前的cookie对象，value值可以是任意值，默认写1了
        Cookie cookieAct = new Cookie(Constants.COOKIE_NAME_ACT, "1");
        cookieAct.setMaxAge(0);
        response.addCookie(cookieAct);
        Cookie cookiePwd = new Cookie(Constants.COOKIE_NAME_PWD, "1");
        cookiePwd.setMaxAge(0);
        response.addCookie(cookiePwd);
        Cookie cookieUserId = new Cookie(Constants.COOKIE_NAME_ID, "1");
        cookieUserId.setMaxAge(0);
        response.addCookie(cookieUserId);
    }
    /**
     * 创建 用户登录 过程需要的cookie
     * @param user 登录的用户
     * @param response 响应信息
     */
    public static void createLoginCookie(User user, HttpServletResponse response) {
        Cookie cookieAct = new Cookie(Constants.COOKIE_NAME_ACT, user.getLoginAct());
        cookieAct.setMaxAge(Constants.COOKIE_MAX_ALIVE_TIME);
        response.addCookie(cookieAct);
        Cookie cookiePwd = new Cookie(Constants.COOKIE_NAME_PWD, user.getLoginPwd());
        cookiePwd.setMaxAge(Constants.COOKIE_MAX_ALIVE_TIME);
        response.addCookie(cookiePwd);
        // 新建一个存放用户id的cookie，代表该用户的唯一标识，用于登录时用户判断
        Cookie cookieUserId = new Cookie(Constants.COOKIE_NAME_ID, user.getId());
        cookieUserId.setMaxAge(Constants.COOKIE_MAX_ALIVE_TIME);
        response.addCookie(cookieUserId);
    }

    /**
     * 通过cookie的value值从cookie数组中查找cookie
     * @param cookies 查找的cookie数组
     * @param value 被查找的cookie的value值
     * @return 找到返回true，没找到返回false
     */
    public static boolean findCookieByValue(Cookie[] cookies, String value) {
        for (Cookie cookie : cookies) {
            if (cookie.getValue().equals(value)) {
                return true;
            }
        }
        return false;
    }

    /**
     * 通过cookie的name值从cookie数组中查找cookie
     * @param cookies 查找的cookie数组
     * @param name 被查找的cookie的name值
     * @return 找到返回true，没找到返回false
     */
    public static boolean findCookieByName(Cookie[] cookies, String name) {
        for (Cookie cookie : cookies) {
            if (cookie.getName().equals(name)) {
                return true;
            }
        }
        return false;
    }
}
