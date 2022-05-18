<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
	// 设置动态初始访问路径（这里本地是http://127.0.0.1:8080/crm/）
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css" type="text/css" rel="stylesheet">

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>

<script type="text/javascript">

	$(function(){
		queryTransactionByConditionForPage(1, 10);

		// 给全选按钮添加事件实现全选（全选按钮在交易数据被查出来之前已经生成了，所以直接给固有元素全选按钮添加事件即可）
		$("#checkAll").click(function () {
			// 如果全选按钮选中，则列表中所有按钮都选中（操作tBody下面的所有子标签input，设置为当前（this）全选按钮的状态）
			$("#tBody input[type='checkbox']").prop("checked", this.checked);
		});

		// 当交易标签不是全选时取消全选按钮
		$("#tBody").on("click", "input[type='checkbox']", function () {
			// 设置全选标签状态，如果当前所有标签数和选中标签数相等，则全选，否则不全选
			$("#checkAll").prop("checked",
					$("#tBody input[type='checkbox']").size()==$("#tBody input[type='checkbox']:checked").size());
		});

		// 清空查询按钮单机事件
		$("#clearTransactionBtn").click(function () {
			// 清空查询框内的信息
			$(".clear-control").val("");
			// 清空后返回初始查询信息
			queryTransactionByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));
		});

		// 给查询按钮添加单击事件
		$("#queryTransactionBtn").click(function() {
			// 查询所有符合条件数据的第一页以及所有符合条件数据的总条数
			queryTransactionByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));
		});

		// 给修改按钮添加单击事件
		$("#editTranBtn").click(function () {
			// 获取id值
			var checkIds = $("#tBody input[type='checkbox']:checked");
			if (checkIds.size() == 0) { // 如果没有选中的交易
				alert("请选择要修改的交易");
				return;
			}
			if (checkIds.size() > 1) { // 如果选中的交易数目大于1，则不能修改
				alert("每次只能修改一条交易");
				return;
			}
			// 获取选中的交易id
			var id = checkIds.val();
			// 发送请求
			window.location.href = "workbench/transaction/toEditPage.do?id="+id;
		});

        // 给删除按钮添加单击事件
        $("#deleteTranBtn").click(function () {
            // 收集参数
            var tranIds = $("#tBody input[type='checkbox']:checked"); // 获取所有选中的checkbox
            if (tranIds.size() == 0) { // 如果未选中交易
                alert("请选择要删除的交易");
                return;
            }
            if (window.confirm("确定删除吗？")) { // 判断是否确认删除
                var id = ""; // 所有id拼接成的字符串变量
                // 遍历数组
                $.each(tranIds, function () { // id的格式为：id=xxx&id=xxx&id=xxx&id=xxx&id=xxx..
                    // 这个this是checkbox选择框dom对象
                    id += "id=" + this.value + "&"; // 这个id是怎么获取到的：checkbox的value值，在查询数据时将id值赋给了checkbox
                });
                id = id.substr(0, id.length - 1);
                // 发送请求
                $.ajax({
                    url:'workbench/transaction/deleteTranByIds.do',
                    data:id, // ajax中这样传参数可以实现字符串数组的传递，需要以：key=xxx&key=xxx&key=xxx这样的形式实现
                    type:'post',
                    dataType:'json',
                    success:function (data) {
                        if (data.code == "1") {
                            // 刷新交易列表,显示第一页数据,保持每页显示条数不变
                            queryTransactionByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));
                        } else {
                            alert(data.message);
                        }
                    }
                });
            }
        });
		
	});

	/**
	 * 分页查询函数功能：封装参数并发送请求
	 * @param pageNo 起始页码
	 * @param pageSize 单页显示数据条数
	 */
	function queryTransactionByConditionForPage(pageNo, pageSize) {
		// 收集交易前端界面的相关参数（条件查询的一些信息，如果不需要条件查询，就默认null）
		var owner = $("#query-owner").val();
		var name = $("#query-name").val();
		var customerId = $("#query-customerId").val();
		var stage = $("#query-stage option:selected").text();
		var type = $("#query-type option:selected").text();
		var source = $("#query-source option:selected").text(); // 获取下拉框选中的交易来源
		var contactsId = $("#query-contactsId").val();
		// 前端向后端发送请求
		$.ajax({
			url: 'workbench/transaction/queryTransactionByConditionForPage.do',
			data: {
				owner:owner,
				name:name,
				customerId:customerId,
				stage:stage,
				type:type,
				source:source,
				contactsId:contactsId,
				pageNo:pageNo,
				pageSize:pageSize
			},
			type:'post',
			dataType:'json',
			success:function (data) {
				// 显示所有交易，遍历tranList，拼接所有行
				var htmlString = "";
				$.each(data.tranList, function (index, obj) {
					// checkbox中value存放了交易的id属性，用于删除和修改的调用
					htmlString += "<tr class=\"active\">";
					htmlString += "<td><input type=\"checkbox\" value=\""+obj.id+"\"/></td>";
					htmlString += "<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/transaction/toDetailPage.do?id="+obj.id+"'\">"+obj.name+"</a></td>";
					htmlString += "<td>"+obj.customerId+"</td>";
					htmlString += "<td>"+obj.stage+"</td>";
					htmlString += "<td>"+obj.type+"</td>";
					htmlString += "<td>"+obj.owner+"</td>";
					htmlString += "<td>"+obj.source+"</td>";
					htmlString += "<td>"+obj.contactsId+"</td>";
					htmlString += "</tr>";
				});
				$("#tBody").html(htmlString); // 写入页面
				$("#checkAll").prop("checked", false); // 换页时将全选按钮取消选中
				//计算总页数
				var totalPages = 1;
				if (data.totalRows % pageSize == 0) { // 总数据刚好可以整除页面
					totalPages = data.totalRows / pageSize;
				} else {
					totalPages = parseInt(data.totalRows / pageSize) + 1; // 页数不能是小数，将小数转换为整数
				}

				//对容器调用bs_pagination工具函数，显示翻页信息
				$("#page-master").bs_pagination({
					currentPage: pageNo, // 当前页号,相当于pageNo
					rowsPerPage: pageSize, // 每页显示条数,相当于pageSize
					totalRows: data.totalRows, // 总条数
					totalPages: totalPages,  // 总页数,必填参数.
					visiblePageLinks: 5, // 最多可以显示的卡片数
					showGoToPage: true, // 是否显示"跳转到"部分，默认true显示
					showRowsPerPage: true, // 是否显示"每页显示条数"部分，默认true显示
					showRowsInfo: true, // 是否显示记录的信息，默认true显示

					// 用户每次切换页号，都自动触发本函数;
					// 每次返回切换页号之后的pageNo和pageSize
					onChangePage: function (event, pageObj) { // returns page_num and rows_per_page after a link has clicked
						// 重写发送当前页数和每页显示的条数（这也就意味着每次换页都将向后端 发送请求 查询当页数据）
						queryTransactionByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
					}
				});
			}
		});
	}
</script>
</head>
<body>

	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>联系人列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control clear-control" type="text" id="query-owner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control clear-control" type="text" id="query-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">客户名称</div>
				      <input class="form-control clear-control" type="text" id="query-customerId">
				    </div>
				  </div>

				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">阶段</div>
					  <select class="form-control clear-control" id="query-stage">
					  	<option disabled selected></option>
					  	<c:forEach items="${stageList}" var="stage">
							<option value="${stage.id}">${stage.value}</option>
						</c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">类型</div>
					  <select class="form-control clear-control" id="query-type">
						  <option disabled selected></option>
						  <c:forEach items="${transactionTypeList}" var="transactionType">
							  <option value="${transactionType.id}">${transactionType.value}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">来源</div>
				      <select class="form-control clear-control" id="query-source">
						  <option disabled selected></option>
						  <c:forEach items="${sourceList}" var="source">
							  <option value="${source.id}">${source.value}</option>
						  </c:forEach>
						</select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">联系人名称</div>
				      <input class="form-control clear-control" type="text" id="query-contactsId">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="queryTransactionBtn">查询</button>
					&nbsp;
					<button type="button" class="btn btn-default" id="clearTransactionBtn">清空</button>
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" onclick="window.location.href='workbench/transaction/toSavePage.do';"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editTranBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteTranBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkAll" /></td>
							<td>名称</td>
							<td>客户名称</td>
							<td>阶段</td>
							<td>类型</td>
							<td>所有者</td>
							<td>来源</td>
							<td>联系人名称</td>
						</tr>
					</thead>
					<tbody id="tBody">
<%--						<tr>--%>
<%--							<td><input type="checkbox" /></td>--%>
<%--							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">动力节点-交易01</a></td>--%>
<%--							<td>动力节点</td>--%>
<%--							<td>谈判/复审</td>--%>
<%--							<td>新业务</td>--%>
<%--							<td>zhangsan</td>--%>
<%--							<td>广告</td>--%>
<%--							<td>李四</td>--%>
<%--						</tr>--%>
<%--                        <tr class="active">--%>
<%--                            <td><input type="checkbox" /></td>--%>
<%--                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">动力节点-交易01</a></td>--%>
<%--                            <td>动力节点</td>--%>
<%--                            <td>谈判/复审</td>--%>
<%--                            <td>新业务</td>--%>
<%--                            <td>zhangsan</td>--%>
<%--                            <td>广告</td>--%>
<%--                            <td>李四</td>--%>
<%--                        </tr>--%>
					</tbody>
				</table>
				<div id="page-master"></div>
			</div>
			
<%--			<div style="height: 50px; position: relative;top: 20px;">--%>
<%--				<div>--%>
<%--					<button type="button" class="btn btn-default" style="cursor: default;">共<b>50</b>条记录</button>--%>
<%--				</div>--%>
<%--				<div class="btn-group" style="position: relative;top: -34px; left: 110px;">--%>
<%--					<button type="button" class="btn btn-default" style="cursor: default;">显示</button>--%>
<%--					<div class="btn-group">--%>
<%--						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">--%>
<%--							10--%>
<%--							<span class="caret"></span>--%>
<%--						</button>--%>
<%--						<ul class="dropdown-menu" role="menu">--%>
<%--							<li><a href="#">20</a></li>--%>
<%--							<li><a href="#">30</a></li>--%>
<%--						</ul>--%>
<%--					</div>--%>
<%--					<button type="button" class="btn btn-default" style="cursor: default;">条/页</button>--%>
<%--				</div>--%>
<%--				<div style="position: relative;top: -88px; left: 285px;">--%>
<%--					<nav>--%>
<%--						<ul class="pagination">--%>
<%--							<li class="disabled"><a href="#">首页</a></li>--%>
<%--							<li class="disabled"><a href="#">上一页</a></li>--%>
<%--							<li class="active"><a href="#">1</a></li>--%>
<%--							<li><a href="#">2</a></li>--%>
<%--							<li><a href="#">3</a></li>--%>
<%--							<li><a href="#">4</a></li>--%>
<%--							<li><a href="#">5</a></li>--%>
<%--							<li><a href="#">下一页</a></li>--%>
<%--							<li class="disabled"><a href="#">末页</a></li>--%>
<%--						</ul>--%>
<%--					</nav>--%>
<%--				</div>--%>
<%--			</div>--%>
			
		</div>
		
	</div>
</body>
</html>