package com.yang.crm.workbench.service.impl;

import com.yang.crm.workbench.domain.Activity;
import com.yang.crm.workbench.domain.FunnelVO;
import com.yang.crm.workbench.mapper.ActivityMapper;
import com.yang.crm.workbench.mapper.ActivityRemarkMapper;
import com.yang.crm.workbench.service.ActivityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service("activityService")
public class ActivityServiceImpl implements ActivityService {
    @Autowired
    private ActivityMapper activityMapper;

    @Autowired
    private ActivityRemarkMapper activityRemarkMapper;

    @Override
    public int saveCreateActivity(Activity activity) {
        return activityMapper.insertActivity(activity);
    }

    @Override
    public List<Activity> queryActivityByConditionForPage(Map<String, Object> map) {
        return activityMapper.selectActivityByConditionForPage(map);
    }

    @Override
    public int queryCountOfActivityByCondition(Map<String, Object> map) {
        return activityMapper.selectCountOfActivityByCondition(map);
    }

    /**
     * 通过市场活动id数组删除对应id的市场活动以及该市场活动中绑定的所有信息
     * @param ids 市场活动id数组
     */
    @Override
    public void deleteActivity(String[] ids) {
        // 先删除市场活动备注
        activityRemarkMapper.deleteActivityRemarkByActivityId(ids);
        // 再删除市场活动
        activityMapper.deleteActivityByIds(ids);
    }

    @Override
    public Activity queryActivityById(String id) {
        return activityMapper.selectActivityById(id);
    }

    @Override
    public int saveEditActivity(Activity activity) {
        return activityMapper.updateActivity(activity);
    }

    @Override
    public List<Activity> queryAllActivity() {
        return activityMapper.selectAllActivity();
    }

    @Override
    public List<Activity> queryCheckedActivity(String[] id) {
        return activityMapper.selectCheckedActivity(id);
    }

    @Override
    public int saveActivityByList(List<Activity> activityList) {
        return activityMapper.insertActivityByList(activityList);
    }

    @Override
    public Activity queryActivityForDetailById(String id) {
        return activityMapper.selectActivityForDetailById(id);
    }

    @Override
    public List<Activity> queryActivityForDetailByClueId(String clueId) {
        return activityMapper.selectActivityForDetailByClueId(clueId);
    }

    @Override
    public List<Activity> queryActivityForDetailByNameAndClueId(Map<String, Object> map) {
        return activityMapper.selectActivityForDetailByNameAndClueId(map);
    }

    @Override
    public List<Activity> queryActivityForDetailByIds(String[] ids) {
        return activityMapper.selectActivityForDetailByIds(ids);
    }

    @Override
    public List<Activity> queryActivityForConvertByNameAndClueId(Map<String, Object> map) {
        return activityMapper.selectActivityForConvertByNameAndClueId(map);
    }

    @Override
    public List<Activity> queryActivityForDetailByContactsId(String contactsId) {
        return activityMapper.selectActivityForDetailByContactsId(contactsId);
    }

    @Override
    public List<Activity> queryActivityForDetailByNameAndContactsId(Map<String, Object> map) {
        return activityMapper.selectActivityForDetailByNameAndContactsId(map);
    }

    @Override
    public List<Activity> queryActivityByFuzzyName(String activityName) {
        return activityMapper.selectActivityByFuzzyName(activityName);
    }

    @Override
    public List<FunnelVO> queryCountOfActivityGroupByOwner() {
        return activityMapper.selectCountOfActivityGroupByOwner();
    }
}
