package com.yang.crm.commons.constants;

/**
 * 存放常量
 */
public class Constants {
    // 保存ReturnObject中的code属性值（注意：如果修改了这些参数一定要在对应 前端界面 手动修改相应的参数）
    public static final String RETURN_OBJECT_CODE_SUCCESS = "1"; // 成功
    public static final String RETURN_OBJECT_CODE_FAIL = "0"; // 失败

    // 存放当前User的Session的key值（注意：如果修改了这些参数一定要在对应 前端界面 手动修改相应的参数）
    public static final String SESSION_USER = "sessionUser";

    // 登录时所需创建的Cookie对象name值（注意：如果修改了这些参数一定要在对应 前端界面 手动修改相应的参数）
    public static final String COOKIE_NAME_ACT = "loginAct";
    public static final String COOKIE_NAME_PWD = "loginPwd";
    public static final String COOKIE_NAME_ID = "userId";

    // 登录时创建的Cookie最大存活时间
    public static final int COOKIE_MAX_ALIVE_TIME = 10 * 24 * 60 * 60; // Cookie存活时间十天

    // 设置导出市场活动文件名（注意：只能为excel文件，加上拓展名：.xsl）
    public static final String FILE_NAME_ACTIVITY = "activity.xls";

    // 注册账号的一些信息
    public static final String ACT_LOCK_STATE_FALSE = "1"; // 非锁定状态
    public static final String ACT_LOCK_STATE_TRUE = "0"; // 锁定状态

    // 市场活动备注是否修改过
    public static final String REMARK_EDIT_FLAG_FALSE = "0"; // 没有修改过
    public static final String REMARK_EDIT_FLAG_TRUE = "1"; // 修改过
}
