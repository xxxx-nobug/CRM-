package com.yang;

import com.yang.crm.commons.utils.DateUtils;
import com.yang.crm.commons.utils.UUIDUtils;
import com.yang.crm.settings.domain.User;
import com.yang.crm.workbench.domain.Customer;
import com.yang.crm.workbench.mapper.CustomerMapper;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Date;

public class AllTest {

    public static void test01() {
        User user = new User();
        System.out.println(user.hashCode());
    }
    @Test
    public void staticTest() {
        AllTest.test01();
        AllTest.test01();
        AllTest.test01();
    }
}
