package com.yang.crm.workbench.service;

import com.yang.crm.workbench.domain.Activity;
import com.yang.crm.workbench.domain.FunnelVO;

import java.util.List;
import java.util.Map;

public interface ActivityService {
    int saveCreateActivity(Activity activity);

    List<Activity> queryActivityByConditionForPage(Map<String, Object> map);

    int queryCountOfActivityByCondition(Map<String, Object> map);

    void deleteActivity(String[] ids);

    Activity queryActivityById(String id);

    int saveEditActivity(Activity activity);

    List<Activity> queryAllActivity();

    List<Activity> queryCheckedActivity(String[] id);

    int saveActivityByList(List<Activity> activityList);

    Activity queryActivityForDetailById(String id);

    List<Activity> queryActivityForDetailByClueId(String clueId);

    List<Activity> queryActivityForDetailByNameAndClueId(Map<String, Object> map);

    List<Activity> queryActivityForDetailByIds(String[] ids);

    List<Activity> queryActivityForConvertByNameAndClueId(Map<String, Object> map);

    List<Activity> queryActivityForDetailByContactsId(String contactsId);

    List<Activity> queryActivityForDetailByNameAndContactsId(Map<String, Object> map);

    List<Activity> queryActivityByFuzzyName(String activityName);

    List<FunnelVO> queryCountOfActivityGroupByOwner();
}
