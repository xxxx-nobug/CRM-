package com.yang.crm.workbench.service;

import com.yang.crm.workbench.domain.Customer;

import java.util.List;
import java.util.Map;

public interface CustomerService {
    List<Customer> queryCustomerByConditionForPage(Map<String, Object> map);

    int queryCountOfCustomerByCondition(Map<String, Object> map);

    int saveCreateCustomer(Customer customer);

    Customer queryCustomerById(String id);

    int saveEditCustomer(Customer customer);

    void deleteCustomer(String[] ids);

    Customer queryCustomerForDetailById(String id);

    List<String> queryCustomerNameByFuzzyName(String customerName);

    String queryCustomerIdByName(String customerName);
}
