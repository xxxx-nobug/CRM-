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
		
		//定制字段
		$("#definedColumns > li").click(function(e) {
			//防止下拉菜单消失
	        e.stopPropagation();
	    });

		// 客户页面加载完成后，查询所有数据第一页以及所有数据的总条数，默认每页显示10条数据
		queryCustomerByConditionForPage(1, 10);

		// 给查询按钮添加单击事件
		$("#queryCustomerBtn").click(function () {
			// 查询所有符合条件数据的第一页以及所有符合条件数据的总条数
			queryCustomerByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));
		});

		// 给清空按钮添加单击事件
		$("#clearCustomerBtn").click(function () {
			// 清空查询框内的信息
			$(".clear-control").val("");
			// 清空后返回初始查询信息
			queryCustomerByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));
		});

		// 给全选框添加单击事件
		$("#checkAll").click(function () {
			// 如果全选按钮选中，则列表中所有按钮都选中（操作tbody下面的所有子标签input，设置为当前（this）全选按钮的状态）
			$("#tBody input[type='checkbox']").prop("checked", this.checked);
		});
		// 当客户标签不是全选时取消全选按钮
		// 此时的客户数据未被查询出来，即input中的内容不存在
		// （因为异步请求向后端查询数据的过程相对于前端代码加载比较漫长，所以肯定前端代码执行完毕后动态数据才能加载出来）
		// 所以只能通过这种方式给动态元素添加事件
		$("tBody").on("click", "input[type='checkbox']", function () {
			// 设置全选标签状态，如果当前所有标签数和选中标签数相等，则全选，否则不全选
			$("#checkAll").prop("checked",
					$("#tBody input[type='checkbox']").size()==$("#tBody input[type='checkbox']:checked").size());
		});

		// 给创建客户添加单击事件
		$("#createCustomerBtn").click(function () {
			// 清空之前表单输入的的信息
			$("#createCustomerForm").get(0).reset();
			// 弹出创建客户的模态窗口
			$("#createCustomerModal").modal("show");
		});

		// 给保存客户添加单击事件
		$("#saveCreateCustomerBtn").click(function () {
			// 收集参数
			var owner = $("#create-customerOwner").val();
			var name = $("#create-customerName").val();
			var website = $("#create-website").val();
			var phone = $("#create-phone").val();
			var description = $("#create-description").val();
			var contactSummary = $("#create-contactSummary").val();
			var nextContactTime = $("#create-nextContactTime").val();
			var address = $("#create-address").val();
			// 表单验证
			if (name == "") {
				alert("名称不能为空");
				return;
			}
			if (website != "") {
				var websiteRegExp = /^(?:(http|https|ftp):\/\/)?((?:[\w-]+\.)+[a-z0-9]+)((?:\/[^/?#]*)+)?(\?[^#]+)?(#.+)?$/i;
				if (!websiteRegExp.test(website)) {
					alert("网站格式错误");
					return;
				}
			}
			if (phone != "") {
				var phoneRegExp = /0\d{2,3}-\d{7,8}/; // 国内座机电话号码验证："XXX-XXXXXXX"
				if (!phoneRegExp.test(phone)) {
					alert("座机号码格式错误");
					return;
				}
			}
			// 发送请求
			$.ajax({
				url: 'workbench/customer/saveCreateCustomer.do',
				data: {
					owner:owner,
					name:name,
					website:website,
					phone:phone,
					description:description,
					contactSummary:contactSummary,
					nextContactTime:nextContactTime,
					address:address
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") { // 保存成功
						// 关闭模态窗口
						$("#createCustomerModal").modal("hide");
						// 刷新客户列，显示第一页数据
						queryCustomerByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));
					} else {
						// 输出提示信息，模态窗口默认不关闭
						alert(data.message);
					}
				}
			});
		});

		// 日历实现：bootstrap的datetimepicker插件（给所有class含有my-date的标签赋予日历功能）
		$(".my-date").datetimepicker({
			language:'zh-CN', // 语言设为中文
			format:'yyyy-mm-dd', // 日期格式
			minView:'month', // 可以选择的最小视图
			initialDate:new Date(), // 初始化显示的日期
			autoclose:true, // 选择完日期后是否自动关闭
			todayBtn:true, // 显示‘今天’按钮
			clearBtn:true // 清空按钮
		});

		// 给修改按钮添加单击事件
		$("#editCustomerBtn").click(function () {
			// 获取选择的客户
			var checkIds = $("#tBody input[type='checkbox']:checked");
			if (checkIds.size() == 0) { // 如果没有选中的客户
				alert("请选择要修改的客户");
				return;
			}
			if (checkIds.size() > 1) { // 如果选中的客户数目大于1，则不能修改
				alert("每次只能修改一条客户");
				return;
			}
			// 获取选中的客户id
			var id = checkIds.val();
			// 发送请求
			$.ajax({
				url:'workbench/customer/queryCustomerById.do',
				data:{
					id:id
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					// 给修改的模态窗口写入数据
					$("#edit-id").val(data.id);
					$("#edit-customerOwner").val(data.owner); // 通过设置value值（owner的id）循环遍历出来owner
					$("#edit-customerName").val(data.name);
					$("#edit-website").val(data.website);
					$("#edit-phone").val(data.phone);
					$("#edit-contactSummary").val(data.contactSummary);
					$("#edit-nextContactTime").val(data.nextContactTime);
					$("#edit-description").val(data.description);
					$("#edit-address").val(data.address);
					// 显示模态窗口
					$("#editCustomerModal").modal("show");
				}
			});	
		});
		
		// 给更新按钮添加单击事件
		$("#saveEditCustomerBtn").click(function () {
			// 收集参数
			var id = $("#edit-id").val();
			var owner = $("#edit-customerOwner").val();
			var name = $("#edit-customerName").val();
			var website = $("#edit-website").val();
			var phone = $("#edit-phone").val();
			var description = $("#edit-description").val();
			var contactSummary = $("#edit-contactSummary").val();
			var nextContactTime = $("#edit-nextContactTime").val();
			var address = $("#edit-address").val();
			// 表单验证
			if (name == "") {
				alert("名称不能为空");
				return;
			}
			if (website != "") {
				var websiteRegExp = /^(?:(http|https|ftp):\/\/)?((?:[\w-]+\.)+[a-z0-9]+)((?:\/[^/?#]*)+)?(\?[^#]+)?(#.+)?$/i;
				if (!websiteRegExp.test(website)) {
					alert("网站格式错误");
					return;
				}
			}
			if (phone != "") {
				var phoneRegExp = /0\d{2,3}-\d{7,8}/; // 国内座机电话号码验证："XXX-XXXXXXX"
				if (!phoneRegExp.test(phone)) {
					alert("座机号码格式错误");
					return;
				}
			}
			// 发送请求
			$.ajax({
				url:'workbench/customer/saveEditCustomer.do',
				data:{
					id:id,
					owner:owner,
					name:name,
					website:website,
					phone:phone,
					description:description,
					contactSummary:contactSummary,
					nextContactTime:nextContactTime,
					address:address
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") { // 保存成功
						// 关闭模态窗口
						$("#editCustomerModal").modal("hide");
						// 刷新客户列，显示更新候的数据所在页面
						queryCustomerByConditionForPage($("#page-master").bs_pagination('getOption', 'currentPage'),
														$("#page-master").bs_pagination('getOption', 'rowsPerPage'));
					} else {
						// 输出提示信息，模态窗口默认不关闭
						alert(data.message);
					}
				}
			});
		});
		
		// 给删除按钮添加单击事件
		$("#deleteCustomerBtn").click(function () {
			// 收集参数（获取所有checkbox）
			var customerIds = $("#tBody input[type='checkbox']:checked");
			if (customerIds.size() == 0) { // 如果未选中客户
				alert("请选择要删除的客户");
				return;
			}
			if (window.confirm("确定删除吗？")) { // 判断是否确认删除
				var id = ""; // 所有id拼接成的字符串变量
				// 遍历数组
				$.each(customerIds, function () { // id的格式为：id=xxx&id=xxx&id=xxx&id=xxx&id=xxx..
					// 这个this是checkbox选择框dom对象
					id += "id=" + this.value + "&"; // 这个id是怎么获取到的：checkbox的value值，在查询数据时将id值赋给了checkbox
				});
				id = id.substr(0, id.length - 1);
				// 发送请求
				$.ajax({
					url:'workbench/customer/deleteCustomerByIds.do',
					data:id, // ajax中这样传参数可以实现字符串数组的传递，需要以：key=xxx&key=xxx&key=xxx这样的形式实现
					type:'post',
					dataType:'json',
					success:function (data) {
						if (data.code == "1") {
							//刷新市场活动列表,显示第一页数据,保持每页显示条数不变
							queryCustomerByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));
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
	function queryCustomerByConditionForPage(pageNo, pageSize) {
		// 收集客户前端界面的相关参数（条件查询的一些信息，如果不需要条件查询，就默认null）
		var name = $("#query-name").val();
		var owner = $("#query-owner").val();
		var phone = $("#query-phone").val();
		var website = $("#query-website").val();
		// var pageNo = 1;
		// var pageSize = 10;
		// 前端向后端发送请求
		$.ajax({
			url: 'workbench/customer/queryCustomerByConditionForPage.do',
			data: {
				name:name,
				owner:owner,
				phone:phone,
				website:website,
				pageNo:pageNo,
				pageSize:pageSize
			},
			type:'post',
			dataType:'json',
			success:function (data) {
				// 写入总行数
				// $("#totalRowsB").text(data.totalRows);
				// 显示所有客户，遍历customerList，拼接所有行
				var htmlString = "";
				$.each(data.customerList, function (index, obj) {
					htmlString += "<tr class=\"active\">";
					// checkbox中value存放了客户的id属性
					htmlString += "<td><input type=\"checkbox\" value=\""+obj.id+"\"/></td>";
					htmlString += "<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/customer/detailCustom.do?id="+obj.id+"'\"> " + obj.name + " </a></td>";
					htmlString += "<td>" + obj.owner + "</td>";
					htmlString += "<td>" + obj.phone + "</td>";
					htmlString += "<td>" + obj.website + "</td>";
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
						queryCustomerByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
					}
				});
			}
		});
	}

</script>
</head>
<body>

	<!-- 创建客户的模态窗口 -->
	<div class="modal fade" id="createCustomerModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建客户</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="createCustomerForm">
					
						<div class="form-group">
							<label for="create-customerOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-customerOwner">
									<c:forEach items="${userList}" var="user">
										<option value="${user.id}">${user.name}</option>
									</c:forEach>
								</select>
							</div>
							<label for="create-customerName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-customerName">
							</div>
						</div>
						
						<div class="form-group">
                            <label for="create-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-website">
                            </div>
							<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-phone">
							</div>
						</div>
						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                        <div style="position: relative;top: 15px;">
                            <div class="form-group">
                                <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control my-date" id="create-nextContactTime" readonly>
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveCreateCustomerBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改客户的模态窗口 -->
	<div class="modal fade" id="editCustomerModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">修改客户</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="editCustomerForm">
						<!--设置一个隐藏标签，用来存放id，供后面修改数据时操作-->
						<input type="hidden" id="edit-id">
						<div class="form-group">
							<label for="edit-customerOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-customerOwner">
									<c:forEach items="${userList}" var="user">
										<option value="${user.id}">${user.name}</option>
									</c:forEach>
								</select>
							</div>
							<label for="edit-customerName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-customerName" value="动力节点">
							</div>
						</div>
						
						<div class="form-group">
                            <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-website" value="http://www.bjpowernode.com">
                            </div>
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone" value="010-84846003">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                        <div style="position: relative;top: 15px;">
                            <div class="form-group">
                                <label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control my-date" id="edit-nextContactTime" readonly>
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address">北京大兴大族企业湾</textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveEditCustomerBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>客户列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control clear-control" type="text" id="query-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control clear-control" type="text" id="query-owner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司座机</div>
				      <input class="form-control clear-control" type="text" id="query-phone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司网站</div>
				      <input class="form-control clear-control" type="text" id="query-website">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="queryCustomerBtn">查询</button>
					&nbsp;
				  <button type="button" class="btn btn-default" id="clearCustomerBtn">清空</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createCustomerBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editCustomerBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteCustomerBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkAll"/></td>
							<td>名称</td>
							<td>所有者</td>
							<td>公司座机</td>
							<td>公司网站</td>
						</tr>
					</thead>
					<tbody id="tBody">
<%--						<tr>--%>
<%--							<td><input type="checkbox" /></td>--%>
<%--							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">动力节点</a></td>--%>
<%--							<td>zhangsan</td>--%>
<%--							<td>010-84846003</td>--%>
<%--							<td>http://www.bjpowernode.com</td>--%>
<%--						</tr>--%>
<%--                        <tr class="active">--%>
<%--                            <td><input type="checkbox" /></td>--%>
<%--                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">动力节点</a></td>--%>
<%--                            <td>zhangsan</td>--%>
<%--                            <td>010-84846003</td>--%>
<%--                            <td>http://www.bjpowernode.com</td>--%>
<%--                        </tr>--%>
					</tbody>
				</table>
				<div id="page-master"></div>
			</div>
			
<%--			<div style="height: 50px; position: relative;top: 30px;">--%>
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