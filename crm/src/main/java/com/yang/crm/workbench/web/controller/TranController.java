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
import com.yang.crm.workbench.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

@Controller
public class TranController {
    @Autowired
    private UserService userService;

    @Autowired
    private DicValueService dicValueService;

    @Autowired
    private TranService tranService;

    @Autowired
    private ActivityService activityService;

    @Autowired
    private ContactsService contactsService;

    @Autowired
    private CustomerService customerService;

    @Autowired
    private TranRemarkService tranRemarkService;

    @Autowired
    private TranHistoryService tranHistoryService;

        @RequestMapping("/workbench/transaction/index.do")
    public String index(HttpServletRequest request) {
        List<DicValue> stageList = dicValueService.queryDicValueByTypeCode("stage");
        List<DicValue> transactionTypeList = dicValueService.queryDicValueByTypeCode("transactionType");
        List<DicValue> sourceList = dicValueService.queryDicValueByTypeCode("source");
        request.setAttribute("stageList", stageList);
        request.setAttribute("transactionTypeList", transactionTypeList);
        request.setAttribute("sourceList", sourceList);
        return "workbench/transaction/index";
    }

    @RequestMapping("/workbench/transaction/queryTransactionByConditionForPage.do")
    @ResponseBody
    public Object queryTransactionByConditionForPage(String owner, String name, String customerId, String stage, String type,
                                                     String source, String contactsId, int pageNo, int pageSize) {
        // 封装参数
        Map<String, Object> map = new HashMap<>();
        map.put("owner", owner);
        map.put("name", name);
        map.put("customerId", customerId);
        map.put("source", source);
        map.put("stage", stage);
        map.put("type", type);
        map.put("contactsId", contactsId);
        map.put("beginNo", (pageNo - 1) * pageSize);
        map.put("pageSize", pageSize);
        // 查询
        List<Tran> tranList = tranService.queryTransactionByConditionForPage(map);
        int totalRows = tranService.queryCountOfTransactionByCondition(map);
        // 封装查询参数，传给前端操作
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("tranList", tranList);
        resultMap.put("totalRows", totalRows);
        return resultMap;
    }

    @RequestMapping("/workbench/transaction/toSavePage.do")
    public String toSavePage(HttpServletRequest request) {
        List<User> userList = userService.queryAllUsers();
        List<DicValue> stageList = dicValueService.queryDicValueByTypeCode("stage");
        List<DicValue> transactionTypeList = dicValueService.queryDicValueByTypeCode("transactionType");
        List<DicValue> sourceList = dicValueService.queryDicValueByTypeCode("source");
        request.setAttribute("userList",userList);
        request.setAttribute("stageList",stageList);
        request.setAttribute("transactionTypeList",transactionTypeList);
        request.setAttribute("sourceList",sourceList);
        return "workbench/transaction/save";
    }

    @RequestMapping("/workbench/transaction/queryActivityByFuzzyName.do")
    @ResponseBody
    public Object queryActivityByFuzzyName(String activityName) {
        List<Activity> activityList = activityService.queryActivityByFuzzyName(activityName);
        return activityList;
    }

    @RequestMapping("/workbench/transaction/queryContactsByFuzzyName.do")
    @ResponseBody
    public Object queryContactsByFuzzyName(String contactsName) {
        List<Contacts> contactsList = contactsService.queryContactsByFuzzyName(contactsName);
        return contactsList;
    }

    @RequestMapping("/workbench/transaction/getPossibilityByStage.do")
    @ResponseBody
    public Object getPossibilityByStage(String stageValue){
        // 解析properties配置文件，根据阶段获取可能性
        ResourceBundle bundle = ResourceBundle.getBundle("possibility");
        String possibility = bundle.getString(stageValue);
        // 返回响应信息
        return possibility;
    }

    @RequestMapping("/workbench/transaction/queryCustomerNameByFuzzyName.do")
    @ResponseBody
    public Object queryCustomerNameByFuzzyName(String customerName) {
        List<String> customerNames = customerService.queryCustomerNameByFuzzyName(customerName);
        return customerNames;
    }

    @RequestMapping("/workbench/transaction/saveCreateTransaction.do")
    @ResponseBody
    public Object saveCreateTransaction(Tran tran, HttpSession session) {
         User user = (User) session.getAttribute(Constants.SESSION_USER);
        // 封装参数
        tran.setId(UUIDUtils.getUUID());
        tran.setCreateTime(DateUtils.formatDateTime(new Date()));
        tran.setCreateBy(user.getId());
        ReturnObject returnObject = new ReturnObject();
        try {
            tranService.saveCreateTransaction(tran);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后重试....");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/transaction/toEditPage.do")
    public String toEditPage(String id, HttpServletRequest request) {
        List<User> userList = userService.queryAllUsers();
        List<DicValue> stageList = dicValueService.queryDicValueByTypeCode("stage");
        List<DicValue> transactionTypeList = dicValueService.queryDicValueByTypeCode("transactionType");
        List<DicValue> sourceList = dicValueService.queryDicValueByTypeCode("source");
        Tran tran = tranService.queryTransactionById(id);
        // 解析properties配置文件，根据阶段获取可能性
        ResourceBundle bundle = ResourceBundle.getBundle("possibility");
        String possibility = bundle.getString(dicValueService.queryDicValueById(tran.getStage()).getValue());
        // 存入request域中
        request.setAttribute("userList",userList);
        request.setAttribute("stageList",stageList);
        request.setAttribute("transactionTypeList",transactionTypeList);
        request.setAttribute("sourceList",sourceList);
        request.setAttribute("tran", tran);
        request.setAttribute("possibility", possibility);
        return "workbench/transaction/edit";
    }

    @RequestMapping("/workbench/transaction/saveEditTransaction.do")
    @ResponseBody
    public Object saveEditTransaction(Tran tran, HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        // 封装参数
        tran.setEditTime(DateUtils.formatDateTime(new Date()));
        tran.setEditBy(user.getId());
        ReturnObject returnObject = new ReturnObject();
        try {
            tranService.saveEditTransaction(tran);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后重试....");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/transaction/deleteTranByIds.do")
    @ResponseBody
    public Object deleteTranByIds(String[] id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            tranService.deleteTranByIds(id); // 通过联系人id数组删除所有对应的线索以及该线索的所有信息
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) { // 发生了某些异常，捕获后返回信息
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙，请稍后重试...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/transaction/toDetailPage.do")
    public String toDetailPage(String id, HttpServletRequest request) {
        // 调用service层方法，查询数据
        Tran tran = tranService.queryTranForDetailById(id);
        List<TranRemark> remarkList = tranRemarkService.queryTranRemarkForDetailByTranId(id);
        List<TranHistory> historyList = tranHistoryService.queryTranHistoryForDetailByTranId(id);
        //根据tran所处阶段名称查询可能性
        ResourceBundle bundle = ResourceBundle.getBundle("possibility");
        String possibility = bundle.getString(tran.getStage());
        // 获取当前阶段阶段的stageNo
        String stageOrderNo = dicValueService.queryDicValueById(tranService.queryTransactionById(id).getStage()).getOrderNo();
        //把数据保存到request中
        request.setAttribute("tran",tran);
        request.setAttribute("remarkList",remarkList);
        request.setAttribute("historyList",historyList);
        request.setAttribute("possibility",possibility);
        request.setAttribute("stageOrderNo", stageOrderNo);
        // 调用service方法，查询交易所有的阶段
        List<DicValue> stageList = dicValueService.queryDicValueByTypeCode("stage");
        request.setAttribute("stageList",stageList);
        //请求转发
        return "workbench/transaction/detail";
    }

}
