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
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>

<script type="text/javascript">

	$(function() {
		// 给创建按钮添加单机事件
		$("#createActivityBtn").click(function () {
			// 清空之前表单输入的的信息
			$("#createActivityForm").get(0).reset();
			// 弹出创建市场活动的模态窗口
			$("#createActivityModal").modal("show");
		});

		// 给保存按钮添加单机事件
		$("#saveCreateActivityBtn").click(function () {
			// 收集保存信息相关参数
			var owner = $("#create-marketActivityOwner").val(); // 注意这里获取的是id值，在下面所有者选择栏中value值是id
			var name = $.trim($("#create-marketActivityName").val());
			var startDate = $("#create-startDate").val(); // 此处为日历界面供用户选择
			var endDate = $("#create-endDate").val(); // 此处为日历界面供用户选择
			var cost = $.trim($("#create-cost").val());
			var description = $.trim($("#create-description").val());
			// 表单验证
			if (owner == "") {
				alert("所有者不能为空");
				return;
			}
			if (name == "") {
				alert("名称不能为空");
				return;
			}
			if (startDate != "" && endDate != "") {
				// 使用字符串大小进行日期比较
				if (startDate > endDate) {
					alert("开始日期不能大于结束日期");
					return;
				}
			}
			// 正则表达式验证成本：成本只能为非负整数
			var regExp = /^(([1-9]\d*)|0)$/;
			if (!regExp.test(cost)) {
				alert("成本只能为非负整数");
				return;
			}
			// 发送请求
			$.ajax({
				url:'workbench/activity/saveCreateActivity.do',
				data:{
					owner:owner,
					name:name,
					startDate:startDate,
					endDate:endDate,
					cost:cost,
					description:description
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") { // 保存成功
						// 关闭模态窗口
						$("#createActivityModal").modal("hide");
						// 刷新市场活动列，显示第一页数据
						queryActivityByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));
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

		// 市场活动页面加载完成后，查询所有数据第一页以及所有数据的总条数，默认每页显示10条数据
		queryActivityByConditionForPage(1, 10);

		// 通过查询按钮信息查询数据
		// 给查询按钮绑定单击事件
		$("#queryActivityBtn").click(function() {
			// 查询所有符合条件数据的第一页以及所有符合条件数据的总条数
			queryActivityByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));
		});

		// 清空查询按钮单机事件
		$("#clearActivityBtn").click(function () {
			// 清空查询框内的信息
			$(".clear-control").val("");
			// 清空后返回初始查询信息
			queryActivityByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));
		});
		// 此处暂时不能添加，因为页码跳转占用了回车键
		// 给浏览器窗口添加键盘按下事件（回车键）
		// $(window).keydown(function (event) {
		// 	if (event.keyCode == 13) {
		// 		$("#queryActivityBtn").click(); // 通过该代码自动执行查询单击事件
        //         // $("#saveCreateActivityBtn").click(); // 模态窗口保存创建市场活动的按钮
		// 	}
		// });

		// 给全选按钮添加事件实现全选（全选按钮在市场数据被查出来之前已经生成了，所以直接给固有元素全选按钮添加事件即可）
		$("#checkAll").click(function () {
			// 如果全选按钮选中，则列表中所有按钮都选中（操作tbody下面的所有子标签input，设置为当前（this）全选按钮的状态）
			$("#tBody input[type='checkbox']").prop("checked", this.checked);
		});
		// 当市场活动标签不是全选时取消全选按钮
		// 此时的市场数据未被查询出来，即input中的内容不存在
		// （因为异步请求向后端查询数据的过程相对于前端代码加载比较漫长，所以肯定前端代码执行完毕后动态数据才能加载出来）
		// 所以只能通过这种方式给动态元素添加事件
		$("tBody").on("click", "input[type='checkbox']", function () {
			// 设置全选标签状态，如果当前所有标签数和选中标签数相等，则全选，否则不全选
			$("#checkAll").prop("checked",
						$("#tBody input[type='checkbox']").size()==$("#tBody input[type='checkbox']:checked").size());
		});

		// 给删除按钮添加单机事件
		$("#deleteActivityBtn").click(function () {
			// 收集参数（获取所有checkbox）
			var activityIds = $("#tBody input[type='checkbox']:checked");
			if (activityIds.size() == 0) { // 如果未选中市场活动
				alert("请选择要删除的市场活动");
				return;
			}
			if (window.confirm("确定删除吗？")) { // 判断是否确认删除
				var id = ""; // 所有id拼接成的字符串变量
				// 遍历数组
				$.each(activityIds, function () { // id的格式为：id=xxx&id=xxx&id=xxx&id=xxx&id=xxx..
					// 这个this是checkbox选择框dom对象
					id += "id=" + this.value + "&"; // 这个id是怎么获取到的：checkbox的value值，在查询数据时将id值赋给了checkbox
				});
				id = id.substr(0, id.length - 1);
				$.ajax({
					url:'workbench/activity/deleteActivityByIds.do',
					data:id, // ajax中这样传参数可以实现字符串数组的传递，需要以：key=xxx&key=xxx&key=xxx这样的形式实现
					type:'post',
					dataType:'json',
					success:function (data) {
						if (data.code == "1") {
							//刷新市场活动列表,显示第一页数据,保持每页显示条数不变
							queryActivityByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));
						} else {
							alert(data.message);
						}
					}
				});
			}
		});

		// 给修改按钮添加单击事件
		$("#editActivityBtn").click(function () {
			// 获取选中的市场活动checkbox
			var checkIds = $("#tBody input[type='checkbox']:checked");
			if (checkIds.size() == 0) { // 如果没有选中的市场活动
				alert("请选择要修改的市场活动");
				return;
			}
			if (checkIds.size() > 1) { // 如果选中的市场活动数目大于1，则不能修改
				alert("每次只能修改一条市场活动");
				return;
			}
			// 获取选中的市场活动id
			var id = checkIds.val();
			// 发送请求
			$.ajax({
				url:'workbench/activity/queryActivityById.do',
				data:{
					id:id
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					// 给修改界面的模态窗口的标签赋值
					$("#edit-id").val(data.id);
					$("#edit-marketActivityOwner").val(data.owner); // 通过设置value值（owner的id）循环遍历出来owner
					$("#edit-marketActivityName").val(data.name);
					$("#edit-startDate").val(data.startDate);
					$("#edit-endDate").val(data.endDate);
					$("#edit-cost").val(data.cost);
					$("#edit-description").val(data.description);
					// 显示模态窗口
					$("#editActivityModal").modal("show");
				}
			});
		});

		// 给更新按钮添加单击事件
		$("#saveEditActivityBtn").click(function () {
			// 收集参数
			var id = $("#edit-id").val(); // 隐藏input标签value值
			var owner = $("#edit-marketActivityOwner").val();
			var name = $("#edit-marketActivityName").val();
			var startDate = $("#edit-startDate").val();
			var endDate = $("#edit-endDate").val();
			var cost = $("#edit-cost").val();
			var description = $("#edit-description").val();
			// 表单验证（和保存事件一样）
			if (owner == "") {
				alert("所有者不能为空");
				return;
			}
			if (name == "") {
				alert("名称不能为空");
				return;
			}
			if (startDate != "" && endDate != "") {
				// 使用字符串大小进行日期比较
				if (startDate > endDate) {
					alert("开始日期不能大于结束日期");
					return;
				}
			}
			// 正则表达式验证成本：成本只能为非负整数
			var regExp = /^(([1-9]\d*)|0)$/;
			if (!regExp.test(cost)) {
				alert("成本只能为非负整数");
				return;
			}
			// 发送请求
			$.ajax({
				url:'workbench/activity/saveEditActivity.do',
				data:{
					id:id,
					owner:owner,
					name:name,
					startDate:startDate,
					endDate:endDate,
					cost:cost,
					description:description
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") { // 保存成功
						// 关闭模态窗口
						$("#editActivityModal").modal("hide");
						// 刷新市场活动列，显示更新候的数据所在页面
						queryActivityByConditionForPage($("#page-master").bs_pagination('getOption', 'currentPage'),
														$("#page-master").bs_pagination('getOption', 'rowsPerPage'));
					} else {
						// 输出提示信息，模态窗口默认不关闭
						alert(data.message);
						$("#importActivityModal").modal("show"); // 不写也行
					}
				}
			});
		});

		// 给批量导出按钮添加事件
		$("#exportActivityAllBtn").click(function () {
			// 发送同步请求
			window.location.href="workbench/activity/exportAllActivity.do";
		});

		// 给选择导出按钮添加事件
		$("#exportActivityCheckedBtn").click(function () {
			// 收集参数（获取所有checkbox）
			var activityIds = $("#tBody input[type='checkbox']:checked");
			if (activityIds.size() == 0) { // 如果未选中市场活动
				alert("请选择要导出的市场活动");
				return;
			}
			var id = "?"; // 所有id拼接成的字符串变量
			// 遍历数组
			$.each(activityIds, function () { // id的格式为：id=xxx&id=xxx&id=xxx&id=xxx&id=xxx..
				// 这个this是checkbox选择框dom对象
				id += "id=" + this.value + "&"; // 这个id是怎么获取到的：checkbox的value值，在查询数据时将id值赋给了checkbox
			});
			id = id.substr(0, id.length - 1);
			window.location.href="workbench/activity/exportCheckedActivity.do" + id; // 同步请求
		});

		// 给导入按钮添加单击事件
		$("#importActivityBtn").click(function () {
			// 收集参数
			var activityFileName = $("#activityFile").val();
			// 截取导入文件的类型
			var suffix = activityFileName.substr(activityFileName.lastIndexOf(".") + 1).toLocaleLowerCase();
			if(suffix != "xls"){
				alert("只支持xls文件");
				return;
			}
			var activityFile = $("#activityFile").get(0).files[0];
			if(activityFile.size > 5 * 1024 * 1024){
				alert("文件大小不超过5MB");
				return;
			}
			// FormData是ajax提供的接口,可以模拟键值对向后台提交参数;
			// FormData最大的优势是不但能提交文本数据，还能提交二进制数据
			var formData = new FormData();
			formData.append("activityFile", activityFile);
			//发送请求
			$.ajax({
				url:'workbench/activity/importActivity.do',
				data:formData,
				processData:false, // 设置ajax向后台提交参数之前，是否把参数统一转换成字符串：true--是,false--不是,默认是true
				contentType:false, // 设置ajax向后台提交参数之前，是否把所有的参数统一按urlencoded编码：true--是,false--不是，默认是true
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1"){
						// 提示成功导入记录条数
						alert("成功导入" + data.returnData + "条记录");
						// 关闭模态窗口
						$("#importActivityModal").modal("hide");
						// 刷新市场活动列表,显示第一页数据,保持每页显示条数不变
						queryActivityByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));
					} else {
						// 提示信息
						alert(data.message);
						// 模态窗口不关闭
						$("#importActivityModal").modal("show");
					}
				}
			});
		});

	});
	/**
	 * 分页查询函数功能：封装参数并发送请求
	 * @param pageNo 起始页码
	 * @param pageSize 单页显示数据条数
	 */
	function queryActivityByConditionForPage(pageNo, pageSize) {
		// 收集市场活动前端界面的相关参数（条件查询的一些信息，如果不需要条件查询，就默认null）
		var name = $("#query-name").val();
		var owner = $("#query-owner").val();
		var startDate = $("#query-startDate").val();
		var endDate = $("#query-endDate").val();
		// var pageNo = 1;
		// var pageSize = 10;
		// 前端向后端发送请求
		$.ajax({
			url: 'workbench/activity/queryActivityByConditionForPage.do',
			data: {
				name:name,
				owner:owner,
				startDate:startDate,
				endDate:endDate,
				pageNo:pageNo,
				pageSize:pageSize
			},
			type:'post',
			dataType:'json',
			success:function (data) {
				// 写入总行数
				// $("#totalRowsB").text(data.totalRows);
				// 显示所有市场活动，遍历activityList，拼接所有行
				var htmlString = "";
				$.each(data.activityList, function (index, obj) {
					htmlString += "<tr class=\"active\">";
					// checkbox中value存放了市场活动的id属性（注意：之前删除市场活动出错根本原因就在这里，就是因为value前后多加了个空格）
					htmlString += "<td><input type=\"checkbox\" value=\""+obj.id+"\"/></td>";
					htmlString += "<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/activity/detailActivity.do?id="+obj.id+"'\"> " + obj.name + " </a></td>";
					htmlString += "<td>" + obj.owner + "</td>";
					htmlString += "<td>" + obj.startDate + "</td>";
					htmlString += "<td>" + obj.endDate + "</td>";
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
						queryActivityByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
					}
				});
			}
		});
	}
</script>
</head>
<body>

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form id="createActivityForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">
								  <c:forEach items="${userList}" var="user">
									  <option value="${user.id}">${user.name}</option>
								  </c:forEach>
								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startDate" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control my-date" id="create-startDate" readonly>
							</div>
							<label for="create-endDate" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control my-date" id="create-endDate" readonly>
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal" id="closeCreateActivityBtn">关闭</button>
					<button type="button" class="btn btn-primary" id="saveCreateActivityBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">
						<!--设置一个隐藏标签，用来存放id，供后面修改数据时操作-->
						<input type="hidden" id="edit-id">
						<div class="form-group">
							<label for="edit-marketActivityOwner" id="owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-marketActivityOwner">
									<c:forEach items="${userList}" var="user">
										<option value="${user.id}">${user.name}</option>
									</c:forEach>
								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName" value="发传单">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startDate" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control my-date" id="edit-startDate" value="2020-10-10">
							</div>
							<label for="edit-endDate" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control my-date" id="edit-endDate" value="2020-10-20">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost" value="5,000">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description">市场活动Marketing，是指品牌主办或参与的展览会议与公关市场活动，包括自行主办的各类研讨会、客户交流会、演示会、新产品发布会、体验会、答谢会、年会和出席参加并布展或演讲的展览会、研讨会、行业交流会、颁奖典礼等</textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveEditActivityBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 导入市场活动的模态窗口 -->
    <div class="modal fade" id="importActivityModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">导入市场活动</h4>
                </div>
                <div class="modal-body" style="height: 350px;">
                    <div style="position: relative;top: 20px; left: 50px;">
                        请选择要上传的文件：<small style="color: gray;">[仅支持.xls]</small>
                    </div>
                    <div style="position: relative;top: 40px; left: 50px;">
                        <input type="file" id="activityFile">
						<br>
						<a href="file/activity.xls" download="activity-mode.xls" style="text-decoration:none;color: #2a6496" ><b>下载导入文件模板</b></a>
                    </div>
                    <div style="position: relative; width: 400px; height: 320px; left: 45% ; top: -40px;" >
                        <h3>重要提示</h3>
                        <ul>
                            <li>操作仅针对Excel，仅支持后缀名为XLS的文件。</li>
                            <li>给定文件的第一行将视为字段名。</li>
                            <li>请确认您的文件大小不超过5MB。</li>
                            <li>日期值以文本形式保存，必须符合yyyy-MM-dd格式。</li>
                            <li>日期时间以文本形式保存，必须符合yyyy-MM-dd HH:mm:ss的格式。</li>
                            <li>默认情况下，字符编码是UTF-8 (统一码)，请确保您导入的文件使用的是正确的字符编码方式。</li>
                            <li>建议您在导入真实数据之前用测试文件测试文件导入功能。</li>
                        </ul>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button id="importActivityBtn" type="button" class="btn btn-primary">导入</button>
                </div>
            </div>
        </div>
    </div>
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
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
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control my-date clear-control" type="text" id="query-startDate" readonly/>
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control my-date clear-control" type="text" id="query-endDate" readonly>
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="queryActivityBtn">查询</button>
					&nbsp;
				  <button type="button" class="btn btn-default" id="clearActivityBtn">清空</button>
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createActivityBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editActivityBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteActivityBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				<div class="btn-group" style="position: relative; top: 18%;">
                    <button type="button" class="btn btn-default" data-toggle="modal" data-target="#importActivityModal" ><span class="glyphicon glyphicon-import"></span> 上传列表数据（导入）</button>
                    <button id="exportActivityAllBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（批量导出）</button>
                    <button id="exportActivityCheckedBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（选择导出）</button>
                </div>
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkAll"/></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="tBody">
<%--						<tr class="active">--%>
<%--							<td><input type="checkbox" /></td>--%>
<%--							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">发传单</a></td>--%>
<%--                            <td>zhangsan</td>--%>
<%--							<td>2020-10-10</td>--%>
<%--							<td>2020-10-20</td>--%>
<%--						</tr>--%>
<%--                        <tr class="active">--%>
<%--                            <td><input type="checkbox" /></td>--%>
<%--                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">发传单</a></td>--%>
<%--                            <td>zhangsan</td>--%>
<%--                            <td>2020-10-10</td>--%>
<%--                            <td>2020-10-20</td>--%>
<%--                        </tr>--%>
					</tbody>
				</table>
				<div id="page-master"></div>
			</div>
			
<%--			<div style="height: 50px; position: relative;top: 30px;">--%>
<%--				<div>--%>
<%--					<button type="button" class="btn btn-default" style="cursor: default;">共<b id="totalRowsB"></b>条记录</button>--%>
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