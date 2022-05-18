package com.yang.crm.commons.utils;

import java.util.UUID;

/**
 * 获取UUID工具类
 */
public class UUIDUtils {
    public static String getUUID() {
        return UUID.randomUUID().toString().replaceAll("-", "");
    }
}
