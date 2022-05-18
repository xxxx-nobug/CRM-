package com.yang.crm.commons.utils;

import com.yang.crm.workbench.domain.Activity;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;

import javax.servlet.http.HttpServletResponse;
import java.io.OutputStream;
import java.util.List;

public class HSSFUtils {
    /**
     * 创建市场活动Excel文件
     * @param activityList 市场活动集合
     * @param fileName 导出文件名
     * @param response 响应
     * @throws Exception 输出流异常
     */
    public static void createExcelByActivityList(List<Activity> activityList, String fileName, HttpServletResponse response) throws Exception {
        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("市场活动列表");
        HSSFRow row = sheet.createRow(0);
        // 设置每一列字段
        HSSFCell cell = row.createCell(0);
        cell.setCellValue("ID");
        cell = row.createCell(1);
        cell.setCellValue("所有者");
        cell = row.createCell(2);
        cell.setCellValue("名称");
        cell = row.createCell(3);
        cell.setCellValue("开始日期");
        cell = row.createCell(4);
        cell.setCellValue("结束日期");
        cell = row.createCell(5);
        cell.setCellValue("成本");
        cell = row.createCell(6);
        cell.setCellValue("描述");
        cell = row.createCell(7);
        cell.setCellValue("创建时间");
        cell = row.createCell(8);
        cell.setCellValue("创建者");
        cell = row.createCell(9);
        cell.setCellValue("修改时间");
        cell = row.createCell(10);
        cell.setCellValue("修改者");
        // 遍历activityList，创建HSSFRow对象，生成所有的数据行
        if (activityList != null && activityList.size() > 0) {
            Activity activity = null;
            for (int i = 0; i < activityList.size(); i++) {
                activity = activityList.get(i); // 获取每一个市场活动
                // 每遍历出一个activity，生成一行
                row = sheet.createRow(i+1);
                // 每一行创建11列，每一列的数据从activity中获取
                cell = row.createCell(0);
                cell.setCellValue(activity.getId());
                cell = row.createCell(1);
                cell.setCellValue(activity.getOwner());
                cell = row.createCell(2);
                cell.setCellValue(activity.getName());
                cell = row.createCell(3);
                cell.setCellValue(activity.getStartDate());
                cell = row.createCell(4);
                cell.setCellValue(activity.getEndDate());
                cell = row.createCell(5);
                cell.setCellValue(activity.getCost());
                cell = row.createCell(6);
                cell.setCellValue(activity.getDescription());
                cell = row.createCell(7);
                cell.setCellValue(activity.getCreateTime());
                cell = row.createCell(8);
                cell.setCellValue(activity.getCreateBy());
                cell = row.createCell(9);
                cell.setCellValue(activity.getEditTime());
                cell = row.createCell(10);
                cell.setCellValue(activity.getEditBy());
            }
        }
        // 把生成的excel文件下载到客户端
        response.setContentType("application/octet-stream;charset=UTF-8");
        response.addHeader("Content-Disposition","attachment;filename=" + fileName);
        OutputStream out = response.getOutputStream();
        wb.write(out); // 将wb对象内存中的所有市场活动数据直接转入输出流内存中
        wb.close(); // 关闭资源
        out.flush(); // 刷新资源
    }

    /**
     * 从指定的HSSFCell对象中获取列的值
     * @return 列中的数据
     */
    public static String getCellValueForStr(HSSFCell cell) {
        String ret = "";
        if(cell.getCellType() == HSSFCell.CELL_TYPE_STRING) {
            ret = cell.getStringCellValue();
        } else if(cell.getCellType() == HSSFCell.CELL_TYPE_NUMERIC) {
            ret = cell.getNumericCellValue() + "";
        } else if(cell.getCellType() == HSSFCell.CELL_TYPE_BOOLEAN) {
            ret = cell.getBooleanCellValue() + "";
        } else if(cell.getCellType() == HSSFCell.CELL_TYPE_FORMULA) {
            ret = cell.getCellFormula();
        } else {
            ret = "";
        }
        return ret;
    }
}
