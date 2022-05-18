package com.yang.crm.commons.utils;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * 对Date类型数据进行处理的工具类
 */
public class DateUtils {
    /**
     * 对指定的Date对象进行格式化：yyyy-MM-dd HH:mm:ss
     * @param date Date对象
     * @return 格式化后的日期字符串
     */
    public static String formatDateTime(Date date) {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        return simpleDateFormat.format(date);
    }
    /**
     * 对指定的Date对象进行格式化：yyyy-MM-dd
     * @param date Date对象
     * @return 格式化后的日期字符串
     */
    public static String formatDate(Date date) {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
        return simpleDateFormat.format(date);
    }
    /**
     * 对指定的Date对象进行格式化：HH:mm:ss
     * @param date Date对象
     * @return 格式化后的日期字符串
     */
    public static String formatTime(Date date) {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("HH:mm:ss");
        return simpleDateFormat.format(date);
    }
}
