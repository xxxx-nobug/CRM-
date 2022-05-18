package com.yang.crm.workbench.web.controller;

import com.yang.crm.commons.constants.Constants;
import com.yang.crm.commons.domain.ReturnObject;
import com.yang.crm.commons.utils.DateUtils;
import com.yang.crm.commons.utils.UUIDUtils;
import com.yang.crm.settings.domain.DicValue;
import com.yang.crm.settings.domain.User;
import com.yang.crm.settings.service.DicValueService;
import com.yang.crm.settings.service.UserService;
import com.yang.crm.workbench.domain.*;
import com.yang.crm.workbench.service.ActivityService;
import com.yang.crm.workbench.service.ClueActivityRelationService;
import com.yang.crm.workbench.service.ClueRemarkService;
import com.yang.crm.workbench.service.ClueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

@Controller
public class ClueController {
    @Autowired
    private UserService userService;

    @Autowired
    private DicValueService dicValueService;

    @Autowired
    private ClueService clueService;

    @Autowired
    private ClueRemarkService clueRemarkService;

    @Autowired
    private ActivityService activityService;

    @Autowired
    private ClueActivityRelationService clueActivityRelationService;

    /**
     * 跳转到线索界面
     * @param request 当前页面请求
     * @return 跳转界面
     */
    @RequestMapping("/workbench/clue/index.do")
    public String index(HttpServletRequest request) {
        // 查询线索模块中所有下拉列表中的动态数据
        List<User> userList = userService.queryAllUsers();
        List<DicValue> appellationList = dicValueService.queryDicValueByTypeCode("appellation");
        List<DicValue> clueStateList = dicValueService.queryDicValueByTypeCode("clueState");
        List<DicValue> sourceList = dicValueService.queryDicValueByTypeCode("source");

        // 封装到request域中
        request.setAttribute("userList", userList);
        request.setAttribute("appellationList", appellationList);
        request.setAttribute("clueStateList", clueStateList);
        request.setAttribute("sourceList", sourceList);
        return "workbench/clue/index";
    }

    /**
     * 保存创建的线索
     * @param clue 前端传来的参数
     * @param session 当前页面session对象
     * @return 发送给前端解析信息
     */
    @RequestMapping("/workbench/clue/saveCreateClue.do")
    @ResponseBody
    public Object saveCreateClue(Clue clue, HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER); // 获取当前用户
        // 封装参数
        clue.setId(UUIDUtils.getUUID());
        clue.setCreateBy(user.getId());
        clue.setCreateTime(DateUtils.formatDateTime(new Date()));

        ReturnObject returnObject = new ReturnObject();
        try { // 新增线索
            int res = clueService.saveCreateClue(clue);
            if (res > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            } else {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统繁忙，请稍后重试...");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙，请稍后重试...");
        }
        return returnObject;
    }

    /**
     * 由条件查询线索
     * @param fullname 姓名
     * @param company 公司
     * @param phone 公司号码
     * @param source 来源
     * @param owner 所有者
     * @param mphone 手机号
     * @param state 状态
     * @param pageNo 起始页
     * @param pageSize 每个页面显示条数
     * @return 发送给前端解析信息
     */
    @RequestMapping("/workbench/clue/queryClueByConditionForPage.do")
    @ResponseBody
    public Object queryClueByConditionForPage(String fullname, String company, String phone, String source,
                                              String owner, String mphone, String state, int pageNo, int pageSize) {
        // 封装前端传来的参数
        Map<String, Object> map = new HashMap<>();
        map.put("fullname", fullname);
        map.put("company", company);
        map.put("phone", phone);
        map.put("source", source);
        map.put("owner", owner);
        map.put("mphone", mphone);
        map.put("state", state);
        map.put("beginNo", (pageNo - 1) * pageSize);
        map.put("pageSize", pageSize);
        // 查询数据
        List<Clue> clueList = clueService.queryClueByConditionForPage(map);
        int totalRows = clueService.queryCountOfClueByCondition(map);
        // 封装查询参数，传给前端操作
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("clueList", clueList);
        resultMap.put("totalRows", totalRows);
        return resultMap;
    }

    /**
     * 由id删除线索
     * @param id 线索id数组
     * @return 发送给前端解析信息
     */
    @RequestMapping("/workbench/clue/deleteClueByIds.do")
    @ResponseBody
    public Object deleteClueByIds(String[] id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            clueService.deleteClue(id); // 通过线索id数组删除所有对应的线索以及该线索的所有信息
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) { // 发生了某些异常，捕获后返回信息
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙，请稍后重试...");
        }
        return returnObject;
    }

    /**
     * 通过id查询线索
     * @param id 线索id
     * @return 发送给前端解析信息
     */
    @RequestMapping("/workbench/clue/queryClueById.do")
    @ResponseBody
    public Object queryClueById(String id) {
        return clueService.queryClueById(id);
    }

    /**
     * 保存编辑的线索
     * @param clue 前端传来的线索参数
     * @param session 当前页面session对象
     * @return 发送给前端解析信息
     */
    @RequestMapping("/workbench/clue/saveEditClue.do")
    @ResponseBody
    public Object saveEditClue(Clue clue, HttpSession session) {
        // 获取当前用户的session对象
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        // 封装参数
        clue.setEditBy(user.getId());
        clue.setEditTime(DateUtils.formatDateTime(new Date()));
        ReturnObject returnObject = new ReturnObject();
        try {
            // 保存更新的对应id的线索
            int res = clueService.saveEditClue(clue);
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
     * 跳转到线索详情界面
     * @param id 线索id
     * @param request 发送的请求
     * @return 跳转界面
     */
    @RequestMapping("/workbench/clue/detailClue.do")
    public String detailClue(String id, HttpServletRequest request) {
        // 查询对应id的线索详细信息
        Clue clue = clueService.queryClueForDetailById(id);
        // 查询对应id的线索的所有备注
        List<ClueRemark> clueRemarkList = clueRemarkService.queryClueRemarkForDetailByClueId(id);
        // 查询对应id的线索的所有关联市场活动
        List<Activity> activityList = activityService.queryActivityForDetailByClueId(id);
        // 存到request域中
        request.setAttribute("clue", clue);
        request.setAttribute("clueRemarkList", clueRemarkList);
        request.setAttribute("activityList", activityList);
        return  "workbench/clue/detail";
    }

    /**
     * 在线索详情页面绑定市场活动中通过市场活动名模糊查询市场活动
     * @param activityName 市场活动名
     * @param clueId 当前线索id
     * @return 查询到的市场活动集合
     */
    @RequestMapping("/workbench/clue/queryActivityForDetailByNameAndClueId.do")
    @ResponseBody
    public Object queryActivityForDetailByNameAndClueId(String activityName, String clueId) {
        // 封装参数
        Map<String, Object> map = new HashMap<>();
        map.put("activityName", activityName);
        map.put("clueId", clueId);
        System.err.println(clueId);
        List<Activity> activityList = activityService.queryActivityForDetailByNameAndClueId(map);
        return activityList;
    }

    /**
     * 保存市场活动和线索的绑定
     * @param activityId 市场活动id数组
     * @param clueId 线索id
     * @return 发送给前端解析信息
     */
    @RequestMapping("/workbench/clue/saveBound.do")
    @ResponseBody
    public Object saveBound(String[] activityId, String clueId) {
        // 封装参数
        ClueActivityRelation clueActivityRelation = null;
        List<ClueActivityRelation> clueActivityRelationList = new ArrayList<>();
        for (String actId : activityId) {
            clueActivityRelation = new ClueActivityRelation();
            clueActivityRelation.setActivityId(actId);
            clueActivityRelation.setClueId(clueId);
            clueActivityRelation.setId(UUIDUtils.getUUID());
            clueActivityRelationList.add(clueActivityRelation);
        }
        ReturnObject returnObject = new ReturnObject();
        try {
            int res = clueActivityRelationService.saveCreateClueActivityRelationByList(clueActivityRelationList);
            if (res > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                // 保存成功后查询所有市场活动id对应的市场活动，用于动态响应到前台页面
                List<Activity> activityList = activityService.queryActivityForDetailByIds(activityId);
                returnObject.setReturnData(activityList);
            } else {
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
     * 解除线索和市场活动的绑定
     * @param clueActivityRelation
     * @return
     */
    @RequestMapping("/workbench/clue/saveUnbound.do")
    @ResponseBody
    public Object saveUnbound(ClueActivityRelation clueActivityRelation) {
        ReturnObject returnObject = new ReturnObject();
        try {
            int res = clueActivityRelationService.deleteClueActivityRelationByClueIdAndActivityId(clueActivityRelation);
            if (res > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            } else {
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
     * 跳转到转换界面
     * @param id 当前线索id
     * @param request 请求
     * @return 前端界面
     */
    @RequestMapping("/workbench/clue/toConvert.do")
    public String toConvert(String id, HttpServletRequest request) {
        // 查询convert页面所需的数据
        Clue clue = clueService.queryClueForDetailById(id);
        List<DicValue> stageList = dicValueService.queryDicValueByTypeCode("stage"); // 查询stage的字典值
        // 存入request域中
        request.setAttribute("clue", clue);
        request.setAttribute("stageList", stageList);
        return "workbench/clue/convert";
    }

    /**
     * 模糊查询市场活动
     * @param clueId 当前线索id
     * @param activityName 模糊查询市场活动名
     * @return 查询到的市场活动集合
     */
    @RequestMapping("/workbench/clue/queryActivityForConvertByNameAndClueId.do")
    @ResponseBody
    public Object queryActivityForConvertByNameAndClueId(String clueId, String activityName) {
        // 封装参数
        Map<String, Object> map = new HashMap<>();
        map.put("clueId", clueId);
        map.put("activityName", activityName);
        // 查询市场活动
        List<Activity> activityList = activityService.queryActivityForConvertByNameAndClueId(map);
        return activityList;
    }

    @RequestMapping("/workbench/clue/convertClue.do")
    @ResponseBody
    public Object convertClue(String clueId, String money, String name, String expectedDate, String stage,
                                  String activityId, String isCreateTran, HttpSession session) {
        // 封装参数
        Map<String, Object> map = new HashMap<>();
        map.put("clueId", clueId);
        map.put("money", money);
        map.put("name", name);
        map.put("expectedDate", expectedDate);
        map.put("stage", stage);
        map.put("activityId", activityId);
        map.put("isCreateTran", isCreateTran);
        map.put(Constants.SESSION_USER, session.getAttribute(Constants.SESSION_USER));
        ReturnObject returnObject = new ReturnObject();
        try {
            // 保存线索转换
            clueService.saveConvertClue(map);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙，请稍后重试...");
        }
        return returnObject;
    }
}
