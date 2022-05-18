package com.yang.crm.commons.domain;

/**
 * // 返回给前端的 后端响应信息的封装类，用于发送给前端转为json字符串
 */
public class ReturnObject {
    private String code; // 登录后获取的成功或者失败的信息（0：失败 1：成功）
    private String message; // 提示信息
    private Object returnData; // 其他数据

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Object getReturnData() {
        return returnData;
    }

    public void setReturnData(Object returnData) {
        this.returnData = returnData;
    }
}
