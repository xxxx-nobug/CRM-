package com.yang.crm.workbench.service.impl;

import com.yang.crm.commons.utils.DateUtils;
import com.yang.crm.commons.utils.UUIDUtils;
import com.yang.crm.workbench.domain.Contacts;
import com.yang.crm.workbench.domain.Customer;
import com.yang.crm.workbench.domain.FunnelVO;
import com.yang.crm.workbench.mapper.ContactsActivityRelationMapper;
import com.yang.crm.workbench.mapper.ContactsMapper;
import com.yang.crm.workbench.mapper.ContactsRemarkMapper;
import com.yang.crm.workbench.mapper.CustomerMapper;
import com.yang.crm.workbench.service.ContactsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Map;

@Service("contactsService")
public class ContactsServiceImpl implements ContactsService {
    @Autowired
    private ContactsMapper contactsMapper;

    @Autowired
    private ContactsRemarkMapper contactsRemarkMapper;

    @Autowired
    private ContactsActivityRelationMapper contactsActivityRelationMapper;

    @Autowired
    private CustomerMapper customerMapper;

    @Override
    public List<Contacts> queryContactsByConditionForPage(Map<String, Object> map) {
        return contactsMapper.selectContactsByConditionForPage(map);
    }

    @Override
    public int queryCountOfContactsByCondition(Map<String, Object> map) {
        return contactsMapper.selectCountOfContactsByCondition(map);
    }

    @Override
    public void saveCreateContacts(Contacts contacts) {
        // 获取前端传来的用户对应的id（前端传来的是用户名称：contacts.getCustomerId()，而数据库需要存放该用户的id）
        String customerId = customerMapper.selectCustomerIdByName(contacts.getCustomerId());
        // 如果存在该用户，则将contacts中的用户名改为对应的用户id
        if (customerId != null) {
            contacts.setCustomerId(customerId);
        } else {
            // 不存在该用户，则新创建用户，并将contacts中的用户名改为新创建的用户id
            Customer customer = new Customer();
            customer.setOwner(contacts.getCreateBy());
            customer.setName(contacts.getCustomerId());
            customer.setId(UUIDUtils.getUUID());
            customer.setCreateTime(DateUtils.formatDateTime(new Date()));
            customer.setCreateBy(contacts.getCreateBy());
            customerMapper.insertCustomer(customer); // 新增用户
            contacts.setCustomerId(customer.getId()); // 修改联系人的用户为该用户id
        }
        contactsMapper.insertContacts(contacts);
    }

    @Override
    public Contacts queryContactsById(String id) {
        Contacts contacts = contactsMapper.selectContactsById(id);
        // 将contacts中的customerId值换成对应的名称
        Customer customer = customerMapper.selectCustomerById(contacts.getCustomerId());
        if (customer == null) { // 如果该用户已经删除为空，则赋予空值
            contacts.setCustomerId("");
        } else { // 如果不为空，则换为客户名称
            contacts.setCustomerId(customer.getName());
        }
        return contacts;
    }

    @Override
    public void saveEditContacts(Contacts contacts) {
        // 获取前端传来的用户对应的id（前端传来的是用户名称：contacts.getCustomerId()，而数据库需要存放该用户的id）
        String customerId = customerMapper.selectCustomerIdByName(contacts.getCustomerId());
        // 如果存在该用户，则将contacts中的用户名改为对应的用户id
        if (customerId != null) {
            contacts.setCustomerId(customerId);
        } else {
            // 不存在该用户，则新创建用户，并将contacts中的用户名改为新创建的用户id
            Customer customer = new Customer();
            customer.setOwner(contacts.getEditBy());
            customer.setName(contacts.getCustomerId());
            customer.setId(UUIDUtils.getUUID());
            customer.setCreateTime(DateUtils.formatDateTime(new Date()));
            customer.setCreateBy(contacts.getEditBy());
            customerMapper.insertCustomer(customer); // 新增用户
            contacts.setCustomerId(customer.getId()); // 修改联系人的用户为该用户id
        }
        contactsMapper.updateContacts(contacts);
    }

    @Override
    public void deleteContacts(String[] contactsIds) {
        // 删除备注
        contactsRemarkMapper.deleteContactsRemarkByContactsId(contactsIds);
        // 删除关联关系
        contactsActivityRelationMapper.deleteContactsActivityRelationByContactsIds(contactsIds);
        // 删除联系人
        contactsMapper.deleteContactsByIds(contactsIds);
    }

    @Override
    public Contacts queryContactsForDetailById(String id) {
        return contactsMapper.selectContactsForDetailById(id);
    }

    @Override
    public List<Contacts> queryContactsByFuzzyName(String contactsName) {
        return contactsMapper.selectContactsByFuzzyName(contactsName);
    }

    @Override
    public List<FunnelVO> queryCountOfCustomerAndContactsGroupByCustomer() {
        return contactsMapper.selectCountOfCustomerAndContactsGroupByCustomer();
    }
}
