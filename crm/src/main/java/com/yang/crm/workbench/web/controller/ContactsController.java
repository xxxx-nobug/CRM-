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
public class ContactsController {
    @Autowired
    private DicValueService dicValueService;

    @Autowired
    private UserService userService;

    @Autowired
    private ContactsService contactsService;

    @Autowired
    private ContactsRemarkService contactsRemarkService;

    @Autowired
    private ActivityService activityService;

    @Autowired
    private ContactsActivityRelationService contactsActivityRelationService;

    @Autowired
    private CustomerService customerService;

    @RequestMapping("/workbench/contacts/index.do")
    public String index(HttpServletRequest request) {
        List<User> userList = userService.queryAllUsers();
        List<DicValue> appellationList = dicValueService.queryDicValueByTypeCode("appellation");
        List<DicValue> sourceList = dicValueService.queryDicValueByTypeCode("source");
        // 封装参数
        request.setAttribute("userList", userList);
        request.setAttribute("appellationList", appellationList);
        request.setAttribute("sourceList", sourceList);
        return "workbench/contacts/index";
    }

    @RequestMapping("/workbench/contacts/queryContactsByConditionForPage.do")
    @ResponseBody
    public Object queryContactsByConditionForPage(String owner, String fullname, String customerId,
                                                  String source, String job, int pageNo, int pageSize) {
        // 封装参数
        Map<String, Object> map = new HashMap<>();
        map.put("owner", owner);
        map.put("fullname", fullname);
        map.put("customerId", customerId);
        map.put("source", source);
        map.put("job", job);
        map.put("beginNo", (pageNo - 1) * pageSize);
        map.put("pageSize", pageSize);
        // 查询
        List<Contacts> contactsList = contactsService.queryContactsByConditionForPage(map);
        int totalRows = contactsService.queryCountOfContactsByCondition(map);
        // 封装查询参数，传给前端操作
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("contactsList", contactsList);
        resultMap.put("totalRows", totalRows);
        return resultMap;
    }

    @RequestMapping("/workbench/contacts/saveCreateContacts.do")
    @ResponseBody
    public Object saveCreateContacts(Contacts contacts, HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        // 封装参数
        contacts.setId(UUIDUtils.getUUID());
        contacts.setCreateBy(user.getId());
        contacts.setCreateTime(DateUtils.formatDateTime(new Date()));
        // 插入操作
        ReturnObject returnObject = new ReturnObject();
        try { // 新增联系人
            contactsService.saveCreateContacts(contacts);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙，请稍后重试...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/contacts/queryContactsById.do")
    @ResponseBody
    public Object queryContactsById(String id) {
        return contactsService.queryContactsById(id);
    }

    @RequestMapping("/workbench/contacts/saveEditContacts.do")
    @ResponseBody
    public Object saveEditContacts(Contacts contacts, HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        // 封装参数
        contacts.setEditBy(user.getId());
        contacts.setEditTime(DateUtils.formatDateTime(new Date()));
        ReturnObject returnObject = new ReturnObject();
        // 更新操作
        try {
            contactsService.saveEditContacts(contacts);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙，请稍后重试...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/contacts/deleteContacts.do")
    @ResponseBody
    public Object deleteContacts(String[] id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            contactsService.deleteContacts(id); // 通过联系人id数组删除所有对应的线索以及该线索的所有信息
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) { // 发生了某些异常，捕获后返回信息
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙，请稍后重试...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/contacts/detailContacts.do")
    public String detailContacts(String id, HttpServletRequest request) {
        // 查询对应id的联系人详细信息
        Contacts contacts = contactsService.queryContactsForDetailById(id);
        // 查询对应id的联系人所有备注
        List<ContactsRemark> contactsRemarkList = contactsRemarkService.queryContactsRemarkForDetailByContactsId(id);
        // 查询对应id的联系人所关联的市场活动
        List<Activity> activityList = activityService.queryActivityForDetailByContactsId(id);
        // 存到request域中
        request.setAttribute("contacts", contacts);
        request.setAttribute("contactsRemarkList", contactsRemarkList);
        request.setAttribute("activityList", activityList);
        return  "workbench/contacts/detail";
    }

    @RequestMapping("/workbench/contacts/queryActivityForDetailByNameAndContactsId.do")
    @ResponseBody
    public Object queryActivityForDetailByNameAndContactsId(String activityName, String contactsId) {
        // 封装参数
        Map<String, Object> map = new HashMap<>();
        map.put("activityName", activityName);
        map.put("contactsId", contactsId);
        List<Activity> activityList = activityService.queryActivityForDetailByNameAndContactsId(map);
        return activityList;
    }

    @RequestMapping("/workbench/contacts/saveBound.do")
    @ResponseBody
    public Object saveBound(String[] activityId, String contactsId) {
        // 封装参数
        ContactsActivityRelation contactsActivityRelation = null;
        List<ContactsActivityRelation> contactsActivityRelationList = new ArrayList<>();
        for (String actId : activityId) {
            contactsActivityRelation = new ContactsActivityRelation();
            contactsActivityRelation.setActivityId(actId);
            contactsActivityRelation.setContactsId(contactsId);
            contactsActivityRelation.setId(UUIDUtils.getUUID());
            contactsActivityRelationList.add(contactsActivityRelation);
        }
        ReturnObject returnObject = new ReturnObject();
        try {
            int res = contactsActivityRelationService.saveCreateContactsActivityRelationByList(contactsActivityRelationList);
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

    @RequestMapping("/workbench/contacts/saveUnbound.do")
    @ResponseBody
    public Object saveUnbound(ContactsActivityRelation contactsActivityRelation) {
        ReturnObject returnObject = new ReturnObject();
        try {
            int res = contactsActivityRelationService.deleteContactsActivityRelationByContactsIdAndActivityId(contactsActivityRelation);
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

    @RequestMapping("/workbench/contacts/queryCustomerNameByFuzzyName.do")
    @ResponseBody
    public Object queryCustomerNameByFuzzyName(String customerName) {
        List<String> customers = customerService.queryCustomerNameByFuzzyName(customerName);
        return customers;
    }
}
