package com.yang.crm.workbench.web.controller;

import com.yang.crm.commons.constants.Constants;
import com.yang.crm.commons.domain.ReturnObject;
import com.yang.crm.commons.utils.DateUtils;
import com.yang.crm.commons.utils.HSSFUtils;
import com.yang.crm.commons.utils.UUIDUtils;
import com.yang.crm.settings.domain.User;
import com.yang.crm.settings.service.UserService;
import com.yang.crm.workbench.domain.Activity;
import com.yang.crm.workbench.domain.ActivityRemark;
import com.yang.crm.workbench.service.ActivityRemarkService;
import com.yang.crm.workbench.service.ActivityService;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.InputStream;
import java.util.*;

@Controller
public class ActivityController {
    @Autowired
    private UserService userService;

    @Autowired
    private ActivityService activityService;

    @Autowired
    private ActivityRemarkService activityRemarkService;

    /**
     * 显示市场活动界面
     * @param request 存放查询用户的作用域
     * @return 市场活动界面
     */
    @RequestMapping("/workbench/activity/index.do")
    public String index(HttpServletRequest request) {
        // 查询所有用户（为了给创建修改等操作中“所有者”下拉框中设置动态数据）
        List<User> userList = userService.queryAllUsers();
        // 将所有用户存放到request域中(使用Model也可以，但是不灵活)
        request.setAttribute("userList", userList);
        return "workbench/activity/index";
    }

    /**
     * 保存新增的市场信息
     * @param activity 前端传来的填入的市场信息
     * @param session 前端已存在的session信息
     * @return 后端响应给前端的信息
     */
    @RequestMapping("/workbench/activity/saveCreateActivity.do")
    @ResponseBody
    public Object saveCreateActivity(Activity activity, HttpSession session) {
        // 获取存放在session域中的User对象
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        // 从前端只传来六个参数，实际需要九个参数，封装需要的参数
        activity.setId(UUIDUtils.getUUID()); // 主键id
        activity.setCreateTime(DateUtils.formatDateTime(new Date())); // 创建时间
        activity.setCreateBy(user.getId()); // 用户id（外键，一个用户可以创建多个市场活动）
        // 返回给前端的 后端响应信息的封装类
        ReturnObject returnObject = new ReturnObject();
        // 注意：查找一般不会出问题，但是增删改有可能会出问题，所以需要一个异常捕获机制，及时捕获异常
        try {
            // 保存创建的市场活动
            int res = activityService.saveCreateActivity(activity);
            if (res > 0) { // 保存成功
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            } else { // 保存失败，服务器端出了问题，为了不影响顾客体验，最好不要直接说出问题
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统繁忙，请稍后重试...");
            }
        } catch (Exception e) { // 发生了某些异常，捕获后返回信息
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙，请稍后重试...");
        }
        return returnObject;
    }

    /**
     * 分页查询市场活动数据响应到前端
     * @param name 名称
     * @param owner 所有者
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @param pageNo 当前页码
     * @param pageSize 分页大小（每页数据量）
     * @return 封装的查询参数
     */
    @RequestMapping("/workbench/activity/queryActivityByConditionForPage.do")
    @ResponseBody
    public Object queryActivityByConditionForPage(String name, String owner, String startDate, String endDate,
                                                  int pageNo, int pageSize) {
        // 封装前端传来的参数
        Map<String, Object> map = new HashMap<>();
        map.put("name", name);
        map.put("owner", owner);
        map.put("startDate", startDate);
        map.put("endDate", endDate);
        map.put("beginNo", (pageNo - 1) * pageSize); // 分页计算起始数据的位置
        map.put("pageSize", pageSize);
        // 由前端传来的条件查询数据
        List<Activity> activityList = activityService.queryActivityByConditionForPage(map); // 查询当前分页要显示数据集合
        int totalRows = activityService.queryCountOfActivityByCondition(map); // 查询总条数
        // 封装查询参数，传给前端操作
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("activityList", activityList);
        resultMap.put("totalRows", totalRows);
        return resultMap;
    }

    /**
     * 删除市场活动把执行信息响应到前端
     * @param id 删除的市场活动id数组
     * @return 封装的查询参数
     */
    @RequestMapping("/workbench/activity/deleteActivityByIds.do")
    @ResponseBody
    public Object deleteActivityByIds(String[] id) {
        ReturnObject returnObject = new ReturnObject();
        // 注意：查找一般不会出问题，但是增删改有可能会出问题，所以需要一个异常捕获机制，及时捕获异常
        try {
            activityService.deleteActivity(id); // 删除市场活动以及市场活动所绑定的所有信息
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) { // 发生了某些异常，捕获后返回信息
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙，请稍后重试...");
        }
        return returnObject;
    }

    /**
     * 通过id查询市场活动
     * @param id 市场活动id
     * @return 市场活动对象
     */
    @RequestMapping("/workbench/activity/queryActivityById.do")
    @ResponseBody
    public Object queryActivityById(String id) {
        return activityService.queryActivityById(id);
    }

    /**
     * 修改市场活动
     * @param activity 修改的市场活动参数
     * @param session 当前登录用户的session信息
     * @return 后端响应给前端的信息
     */
    @RequestMapping("/workbench/activity/saveEditActivity.do")
    @ResponseBody
    public Object saveEditActivity(Activity activity, HttpSession session) {
        // 获取当前用户的session对象
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        // 封装参数
        activity.setEditTime(DateUtils.formatDateTime(new Date()));
        activity.setEditBy(user.getId()); // 修改用户的id
        ReturnObject returnObject = new ReturnObject();
        try {
            // 保存更新的对应id的市场活动
            int res = activityService.saveEditActivity(activity);
            if (res > 0) { // 更新成功
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            } else { // 更新失败，服务器端出了问题，为了不影响顾客体验，最好不要直接说出问题
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统繁忙，请稍后重试...");
            }
        } catch (Exception e) { // 发生了某些异常，捕获后返回信息
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙，请稍后重试...");
        }
        return returnObject;
    }

    /**
     * 批量导出市场活动到excel表格
     * 该方法是跳转浏览器下载页面，所以不需要给前端返回信息
     * @param response 响应
     * @throws Exception 输出流异常
     */
    @RequestMapping("/workbench/activity/exportAllActivity.do")
    public void exportAllActivity(HttpServletResponse response) throws Exception {
        //调用service层方法，查询所有的市场活动
        List<Activity> activityList = activityService.queryAllActivity();
        //创建exel文件，并且把activityList写入到excel文件中
        HSSFUtils.createExcelByActivityList(activityList, Constants.FILE_NAME_ACTIVITY, response);
    }

    /**
     * 选择导出市场活动excel表格
     * @param id 选择的市场活动id
     * @param response 响应
     * @throws Exception 输出流异常
     */
    @RequestMapping("/workbench/activity/exportCheckedActivity.do")
    public void exportCheckedActivity(String[] id, HttpServletResponse response) throws Exception {
        // 调用service层方法，查询所有的市场活动
        List<Activity> activityList = activityService.queryCheckedActivity(id);
        // 创建excel文件，并且把activityList写入到excel文件中
        HSSFUtils.createExcelByActivityList(activityList, Constants.FILE_NAME_ACTIVITY, response);
    }

    /**
     * 实现文件导入市场活动功能
     * @param activityFile 导入的文件
     * @param session 当前用户的session对象
     * @return 后端响应给前端的信息
     */
    @RequestMapping("/workbench/activity/importActivity.do")
    @ResponseBody
    public Object importActivity(MultipartFile activityFile, HttpSession session){
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        ReturnObject returnObject = new ReturnObject();
        try {
            InputStream is = activityFile.getInputStream();
            HSSFWorkbook wb = new HSSFWorkbook(is);
            // 根据wb获取HSSFSheet对象，封装了一页的所有信息
            HSSFSheet sheet = wb.getSheetAt(0); // 页的下标，下标从0开始，依次增加
            // 根据sheet获取HSSFRow对象，封装了一行的所有信息
            HSSFRow row = null;
            HSSFCell cell = null;
            Activity activity = null;
            List<Activity> activityList = new ArrayList<>();
            for(int i = 1; i <= sheet.getLastRowNum(); i++) { // sheet.getLastRowNum()：最后一行的下标
                row = sheet.getRow(i); // 行的下标，下标从0开始，依次增加
                activity = new Activity();
                // 补充部分参数
                activity.setId(UUIDUtils.getUUID());
                activity.setOwner(user.getId());
                activity.setCreateTime(DateUtils.formatDateTime(new Date()));
                activity.setCreateBy(user.getId());
                for(int j = 0; j < row.getLastCellNum(); j++) { // row.getLastCellNum():最后一列的下标+1
                    // 根据row获取HSSFCell对象，封装了一列的所有信息
                    cell=row.getCell(j); // 列的下标，下标从0开始，依次增加
                    // 获取列中的数据
                    String cellValue = HSSFUtils.getCellValueForStr(cell);
                    if(j == 0) {
                        activity.setName(cellValue);
                    } else if(j == 1){
                        activity.setStartDate(cellValue);
                    } else if(j == 2){
                        activity.setEndDate(cellValue);
                    } else if(j == 3){
                        activity.setCost(cellValue);
                    } else if(j == 4){
                        activity.setDescription(cellValue);
                    }
                }
                //每一行中所有列都封装完成之后，把activity保存到list中
                activityList.add(activity);
            }
            // 调用service层方法，保存市场活动
            int res = activityService.saveActivityByList(activityList);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setReturnData(res);
        } catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙，请稍后重试...");
        }
        return returnObject;
    }

    /**
     * 跳转市场活动详细信息页面
     * @param id 选择跳转的市场活动id
     * @param request 请求
     * @return 跳转页面
     */
    @RequestMapping("/workbench/activity/detailActivity.do")
    public String detailActivity(String id, HttpServletRequest request) {
        // 查询数据
        // 对应id的市场活动
        Activity activity = activityService.queryActivityForDetailById(id);
        // 对应id的市场活动所有的备注
        List<ActivityRemark> activityRemarkList = activityRemarkService.queryActivityRemarkForDetailByActivityId(id);
        // 存入请求域中
        request.setAttribute("activity", activity);
        request.setAttribute("activityRemarkList", activityRemarkList);
        return "workbench/activity/detail";
    }
}
