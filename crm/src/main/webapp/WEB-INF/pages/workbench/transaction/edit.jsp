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
<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>

<script type="text/javascript">

	$(function () {

		// 给"阶段"下拉框添加change事件
		$("#edit-stage").change(function () {
			// 收集参数
			// alert($(this).find("option:selected").text());
			var stageValue = $("#edit-stage option:selected").text();
			// 表单验证
			if(stageValue == ""){
				// 清空可能性输入框
				$("#edit-possibility").val("");
				return;
			}
			// 发送请求
			$.ajax({
				url:'workbench/transaction/getPossibilityByStage.do',
				data:{
					stageValue:stageValue
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					// 把可能性显示在输入框中
					$("#edit-possibility").val(data);
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

		// 当容器加载完成之后，对容器调用工具函数
		$("#edit-customerName").typeahead({
			source:function (jquery,process) {
				// 每次键盘弹起，都自动触发本函数；向后台送请求，查询客户表中所有的名称，把客户名称以[]字符串形式返回前台，赋值给source
				// process：是个函数，能够将['xxx','xxxxx','xxxxxx',.....]字符串赋值给source，从而完成自动补全
				// jquery：在容器中输入的关键字
				// 发送查询请求
				$.ajax({
					url:'workbench/transaction/queryCustomerNameByFuzzyName.do',
					data:{
						customerName:jquery
					},
					type:'post',
					dataType:'json',
					success:function (data) {//['xxx','xxxxx','xxxxxx',.....]
						process(data); // 将后端查询的名称字符串通过process传给source
					}
				});
			}
		});

		// 给市场活动源搜索按钮添加单击事件
		$("#searchActivityBtn").click(function () {
			// 初始化工作
			// 清空搜索框
			$("#searchActivityTxt").val("");
			// 清空搜索列表
			$("#tBody-activity").html("");
			// 弹出搜索市场活动的模态窗口
			$("#searchActivityModal").modal("show");
		});

		// 给市场活动源搜索框添加键盘弹起事件
		$("#searchActivityTxt").keyup(function () {
			// 收集参数
			var activityName = $("#searchActivityTxt").val();
			// 发送请求
			$.ajax({
				url:'workbench/transaction/queryActivityByFuzzyName.do',
				data:{
					activityName:activityName,
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					// 遍历data,显示所有搜索的市场活动
					var htmlStr = "";
					$.each(data,function (index,obj) {
						htmlStr += "<tr>";
						htmlStr += "<td><input type=\"radio\" value=\""+obj.id+"\" activityName=\""+obj.name+"\" name=\"activity\"/></td>";
						htmlStr += "<td>"+obj.name+"</td>";
						htmlStr += "<td>"+obj.startDate+"</td>";
						htmlStr += "<td>"+obj.endDate+"</td>";
						htmlStr += "<td>"+obj.owner+"</td>";
						htmlStr += "</tr>";
					});
					$("#tBody-activity").html(htmlStr);
				}
			});
		});

		// 给所有市场活动的单选按钮添加单击事件
		$("#tBody-activity").on("click","input[type='radio']",function () {
			// 获取市场活动的id和name
			var id = this.value;
			var activityName = $(this).attr("activityName"); // attr获取自定义属性值
			// 把市场活动的id写到隐藏域，把name写到输入框中
			$("#activityId").val(id);
			$("#edit-activityName").val(activityName);
			// 关闭搜索市场活动的模态窗口
			$("#searchActivityModal").modal("hide");
		});

		// 模糊查询联系人操作
		$("#searchContactsBtn").click(function () {
			// 初始化工作
			// 清空搜索框
			$("#searchContactsTxt").val("");
			// 清空搜索列表
			$("#tBody-contacts").html("");
			// 弹出搜索联系人的模态窗口
			$("#searchContactsModal").modal("show");
		});

		$("#searchContactsTxt").keyup(function () {
			// 收集参数
			var contactsName = $("#searchContactsTxt").val();
			// 发送请求
			$.ajax({
				url:'workbench/transaction/queryContactsByFuzzyName.do',
				data:{
					contactsName:contactsName,
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					// 遍历data,显示所有搜索的市场活动
					var htmlStr = "";
					$.each(data,function (index,obj) {
						htmlStr += "<tr>";
						htmlStr += "<td><input type=\"radio\" value=\""+obj.id+"\" contactsName=\""+obj.fullname+"\" name=\"contacts\"/></td>";
						htmlStr += "<td>"+obj.fullname+"</td>";
						htmlStr += "<td>"+obj.email+"</td>";
						htmlStr += "<td>"+obj.mphone+"</td>";
						htmlStr += "</tr>";
					});
					$("#tBody-contacts").html(htmlStr);
				}
			});
		});

		// 给所有联系人的单选按钮添加单击事件
		$("#tBody-contacts").on("click","input[type='radio']",function () {
			// 获取联系人的id和name
			var id = this.value;
			var contactsName = $(this).attr("contactsName"); // attr获取自定义属性值
			// 把联系人的id写到隐藏域，把name写到输入框中
			$("#contactsId").val(id);
			$("#edit-contactsName").val(contactsName);
			// 关闭搜索联系人的模态窗口
			$("#searchContactsModal").modal("hide");
		});
		
		// 给保存按钮添加单击事件
		$("#saveEditTranBtn").click(function () {
			// 收集参数
			var id = $("#edit-id").val();
			var owner = $("#edit-owner").val();
			var money = $.trim($("#edit-money").val());
			var name = $.trim($("#edit-name").val());
			var expectedDate = $("#edit-expectedDate").val();
			var customerName = $.trim($("#edit-customerName").val());
			var stage = $("#edit-stage").val();
			var type = $("#edit-type").val();
			var source = $("#edit-source").val();
			var activityId = $("#activityId").val();
			var contactsId = $("#contactsId").val();
			var description = $.trim($("#edit-description").val());
			var contactSummary = $.trim($("#edit-contactSummary").val());
			var nextContactTime = $("#edit-nextContactTime").val();
			//表单验证
			if(name == "") {
				alert("名称不能为空")
				return;
			}
			if(expectedDate == "") {
				alert("预计成交日期不能为空")
				return;
			}
			if(customerName == "") {
				alert("客户名称不能为空")
				return;
			}
			if(stage == "" || stage == null) {
				alert("阶段不能为空")
				return;
			}
			//发送请求
			$.ajax({
				url:'workbench/transaction/saveEditTransaction.do',
				data:{
					id:id,
					owner:owner,
					money:money,
					name:name,
					expectedDate:expectedDate,
					customerId:customerName,
					stage:stage,
					type:type,
					source:source,
					activityId:activityId,
					contactsId:contactsId,
					description:description,
					contactSummary:contactSummary,
					nextContactTime:nextContactTime
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if(data.code=="1"){
						// 跳转到交易主页面
						window.location.href="workbench/transaction/index.do";
					}else{
						// 提示信息
						alert(data.message);
					}
				}
			});
		});

		// 给取消按钮添加单击事件
		$("#cancelEditTranBtn").click(function () {
			window.location.href="workbench/transaction/index.do";
		});
	});
</script>

</head>
<body>

	<!-- 查找市场活动 -->	
	<div class="modal fade" id="searchActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" style="width: 300px;" id="searchActivityTxt" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable3" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
							</tr>
						</thead>
						<tbody id="tBody-activity">
<%--							<tr>--%>
<%--								<td><input type="radio" name="activity"/></td>--%>
<%--								<td>发传单</td>--%>
<%--								<td>2020-10-10</td>--%>
<%--								<td>2020-10-20</td>--%>
<%--								<td>zhangsan</td>--%>
<%--							</tr>--%>
<%--							<tr>--%>
<%--								<td><input type="radio" name="activity"/></td>--%>
<%--								<td>发传单</td>--%>
<%--								<td>2020-10-10</td>--%>
<%--								<td>2020-10-20</td>--%>
<%--								<td>zhangsan</td>--%>
<%--							</tr>--%>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>

	<!-- 查找联系人 -->	
	<div class="modal fade" id="searchContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找联系人</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" id="searchContactsTxt" style="width: 300px;" placeholder="请输入联系人名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>邮箱</td>
								<td>手机</td>
							</tr>
						</thead>
						<tbody id="tBody-contacts">
<%--							<tr>--%>
<%--								<td><input type="radio" name="activity"/></td>--%>
<%--								<td>李四</td>--%>
<%--								<td>lisi@bjpowernode.com</td>--%>
<%--								<td>12345678901</td>--%>
<%--							</tr>--%>
<%--							<tr>--%>
<%--								<td><input type="radio" name="activity"/></td>--%>
<%--								<td>李四</td>--%>
<%--								<td>lisi@bjpowernode.com</td>--%>
<%--								<td>12345678901</td>--%>
<%--							</tr>--%>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
	
	
	<div style="position:  relative; left: 30px;">
		<h3>修改交易</h3>
	  	<div style="position: relative; top: -40px; left: 70%;">
			<button type="button" class="btn btn-primary" id="saveEditTranBtn">保存</button>
			<button type="button" class="btn btn-default" id="cancelEditTranBtn">取消</button>
		</div>
		<hr style="position: relative; top: -40px;">
	</div>
	<form class="form-horizontal" role="form" style="position: relative; top: -30px;">
		<!--设置一个隐藏标签，用来存放id，供后面修改数据时操作-->
		<input type="hidden" id="edit-id">
		<div class="form-group">
			<label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="edit-owner">
					<c:forEach items="${userList}" var="user">
						<option value="${user.id}">${user.name}</option>
					</c:forEach>
				</select>
			</div>
			<label for="edit-money" class="col-sm-2 control-label">金额</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-money">
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-name">
			</div>
			<label for="edit-expectedDate" class="col-sm-2 control-label">预计成交日期<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control my-date" id="edit-expectedDate" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-customerName" class="col-sm-2 control-label">客户名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-customerName" placeholder="支持自动补全，输入客户不存在则新建">
			</div>
			<label for="edit-stage" class="col-sm-2 control-label">阶段<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="edit-stage">
					<option disabled selected></option>
					<c:forEach items="${stageList}" var="stage">
						<option value="${stage.id}">${stage.value}</option>
					</c:forEach>
				</select>
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-type" class="col-sm-2 control-label">类型</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="edit-type">
					<option disabled selected></option>
					<c:forEach items="${transactionTypeList}" var="transactionType">
						<option value="${transactionType.id}">${transactionType.value}</option>
					</c:forEach>
				</select>
			</div>
			<label for="edit-possibility" class="col-sm-2 control-label">可能性</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-possibility" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-source" class="col-sm-2 control-label">来源</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="edit-source">
					<option disabled selected></option>
					<c:forEach items="${sourceList}" var="source">
						<option value="${source.id}">${source.value}</option>
					</c:forEach>
				</select>
			</div>
			<label for="edit-activityName" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" id="searchActivityBtn"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="hidden" id="activityId">
				<input type="text" class="form-control" id="edit-activityName" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="javascript:void(0);" id="searchContactsBtn"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="hidden" id="contactsId">
				<input type="text" class="form-control" id="edit-contactsName" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-description" class="col-sm-2 control-label">描述</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="edit-description"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control my-date" id="edit-nextContactTime" readonly>
			</div>
		</div>
		
	</form>

	<script type="text/javascript">
		// 初始化参数
		$("#edit-id").val('${tran.id}');
		$("#edit-owner").val('${tran.owner}');
		$("#edit-money").val('${tran.money}');
		$("#edit-name").val('${tran.name}');
		$("#edit-expectedDate").val('${tran.expectedDate}');
		$("#edit-customerName").val('${tran.customerId}');
		$("#edit-stage").val('${tran.stage}');
		$("#edit-type").val('${tran.type}');
		$("#edit-source").val('${tran.source}');
		$("#edit-activityName").val('${tran.activityId}');
		$("#edit-contactsName").val('${tran.contactsId}');
		$("#edit-description").val('${tran.description}');
		$("#edit-contactSummary").val('${tran.contactSummary}');
		$("#edit-nextContactTime").val('${tran.nextContactTime}');
		$("#edit-possibility").val('${possibility}');
	</script>
</body>
</html>