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

	$(function(){
		// 线索页面加载完成后，查询所有数据第一页以及所有数据的总条数，默认每页显示10条数据
		queryClueByConditionForPage(1, 10);

		// 给创建线索按钮添加单击事件
		$("#createClueBtn").click(function () {
			// 清空之前表单输入的的信息
			$("#createClueForm").get(0).reset();
			// 弹出创建线索的模态窗口
			$("#createClueModal").modal("show");
		});

		// 给保存线索按钮添加单击事件
		$("#saveCreateClueBtn").click(function () {
			// 收集参数
			var fullname = $.trim($("#create-fullname").val());
			var appellation = $("#create-appellation").val();
			var owner = $("#create-owner").val();
			var company = $.trim($("#create-company").val());
			var job = $.trim($("#create-job").val());
			var email = $.trim($("#create-email").val());
			var phone = $.trim($("#create-phone").val());
			var website = $.trim($("#create-website").val());
			var mphone = $.trim($("#create-mphone").val());
			var state = $("#create-state").val();
			var source = $("#create-source").val();
			var description = $.trim($("#create-description").val());
			var contactSummary = $.trim($("#create-contactSummary").val());
			var nextContactTime = $.trim($("#create-nextContactTime").val());
			var address = $.trim($("#create-address").val());

			// 表单验证
			// 带*的非空
			if (company == "") {
				alert("公司不能为空");
				return;
			}
			if (fullname == "") {
				alert("姓名不能为空");
				return;
			}
			// 正则表达式验证
			if (email != "") { // 如果邮箱非空开始验证
				var emailRegExp = /^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/; // 邮件验证正则表达式
				if (!emailRegExp.test(email)) {
					alert("邮箱格式错误");
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
			if (website != "") {
				var websiteRegExp = /^(?:(http|https|ftp):\/\/)?((?:[\w-]+\.)+[a-z0-9]+)((?:\/[^/?#]*)+)?(\?[^#]+)?(#.+)?$/i;
				if (!websiteRegExp.test(website)) {
					alert("网站格式错误");
					return;
				}
			}
			if (mphone != "") {
				var mphoneRegExp = /^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\d{8}$/;
				if (!mphoneRegExp.test(mphone)) {
					alert("手机号码格式错误");
					return;
				}
			}
			// 发送请求
			$.ajax({
				url:'workbench/clue/saveCreateClue.do',
				data:{
					fullname:fullname,
					appellation:appellation,
					owner:owner,
					company:company,
					job:job,
					email:email,
					phone:phone,
					website:website,
					mphone:mphone,
					state:state,
					source:source,
					description:description,
					contactSummary:contactSummary ,
					nextContactTime:nextContactTime,
					address:address
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if(data.code=="1"){
						// 关闭模态窗口
						$("#createClueModal").modal("hide");
						// 刷新线索列表，显示第一页数据，保持每页显示条数不变
						queryClueByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));
					} else {
						// 提示信息
						alert(data.message);
						// 模态窗口不关闭
						$("#createClueModal").modal("show");
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

		// 给全选按钮添加事件实现全选（全选按钮在线索数据被查出来之前已经生成了，所以直接给固有元素全选按钮添加事件即可）
		$("#checkAll").click(function () {
			// 如果全选按钮选中，则列表中所有按钮都选中（操作tBody下面的所有子标签input，设置为当前（this）全选按钮的状态）
			$("#tBody input[type='checkbox']").prop("checked", this.checked);
		});

		// 当线索标签不是全选时取消全选按钮
		$("#tBody").on("click", "input[type='checkbox']", function () {
			// 设置全选标签状态，如果当前所有标签数和选中标签数相等，则全选，否则不全选
			$("#checkAll").prop("checked",
					$("#tBody input[type='checkbox']").size()==$("#tBody input[type='checkbox']:checked").size());
		});

		// 给查询按钮添加单击事件
		$("#queryClueBtn").click(function() {
			// 查询所有符合条件数据的第一页以及所有符合条件数据的总条数
			queryClueByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));
		});

		// 清空查询按钮单机事件
		$("#clearClueBtn").click(function () {
			// 清空查询框内的信息
			$(".clear-control").val("");
			// 清空后返回初始查询信息
			queryClueByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));
		});
		
		// 给删除按钮添加单击事件
		$("#deleteClueBtn").click(function () {
			// 收集参数
			var clueIds = $("#tBody input[type='checkbox']:checked"); // 获取所有选中的checkbox
			if (clueIds.size() == 0) { // 如果未选中线索
				alert("请选择要删除的线索");
				return;
			}
			if (window.confirm("确定删除吗？")) { // 判断是否确认删除
				var id = ""; // 所有id拼接成的字符串变量
				// 遍历数组
				$.each(clueIds, function () { // id的格式为：id=xxx&id=xxx&id=xxx&id=xxx&id=xxx..
					// 这个this是checkbox选择框dom对象
					id += "id=" + this.value + "&"; // 这个id是怎么获取到的：checkbox的value值，在查询数据时将id值赋给了checkbox
				});
				id = id.substr(0, id.length - 1);
				// 发送请求
				$.ajax({
					url:'workbench/clue/deleteClueByIds.do',
					data:id, // ajax中这样传参数可以实现字符串数组的传递，需要以：key=xxx&key=xxx&key=xxx这样的形式实现
					type:'post',
					dataType:'json',
					success:function (data) {
						if (data.code == "1") {
							//刷新线索列表,显示第一页数据,保持每页显示条数不变
							queryClueByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));
						} else {
							alert(data.message);
						}
					}
				});
			}
		});

		// 给修改按钮添加单击事件
		$("#editClueBtn").click(function () {
			// 获取选中的线索checkbox
			var checkIds = $("#tBody input[type='checkbox']:checked");
			if (checkIds.size() == 0) { // 如果没有选中的线索
				alert("请选择要修改的线索");
				return;
			}
			if (checkIds.size() > 1) { // 如果选中的线索数目大于1，则不能修改
				alert("每次只能修改一条线索");
				return;
			}
			// 获取选中的线索id
			var id = checkIds.val();
			// 发送请求
			$.ajax({
				url:'workbench/clue/queryClueById.do',
				data:{
					id:id
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					// 给修改界面的模态窗口的标签赋值
					$("#edit-id").val(data.id);
					$("#edit-owner").val(data.owner); // 通过设置value值（owner的id）循环遍历出来owner
					$("#edit-company").val(data.company);
					$("#edit-appellation").val(data.appellation);
					$("#edit-fullname").val(data.fullname);
					$("#edit-job").val(data.job);
					$("#edit-email").val(data.email);
					$("#edit-phone").val(data.phone);
					$("#edit-website").val(data.website);
					$("#edit-mphone").val(data.mphone);
					$("#edit-state").val(data.state);
					$("#edit-source").val(data.source);
					$("#edit-description").val(data.description);
					$("#edit-contactSummary").val(data.contactSummary);
					$("#edit-nextContactTime").val(data.nextContactTime);
					$("#edit-address").val(data.address);
					// 显示模态窗口
					$("#editClueModal").modal("show");
				}
			});
		});

		// 给更新按钮添加单击事件
		$("#saveEditClueBtn").click(function () {
			// 收集参数
			var id = $("#edit-id").val(); // 隐藏input标签value值
			var fullname = $.trim($("#edit-fullname").val());
			var appellation = $("#edit-appellation").val();
			var owner = $("#edit-owner").val();
			var company = $.trim($("#edit-company").val());
			var job = $.trim($("#edit-job").val());
			var email = $.trim($("#edit-email").val());
			var phone = $.trim($("#edit-phone").val());
			var website = $.trim($("#edit-website").val());
			var mphone = $.trim($("#edit-mphone").val());
			var state = $("#edit-state").val();
			var source = $("#edit-source").val();
			var description = $.trim($("#edit-description").val());
			var contactSummary = $.trim($("#edit-contactSummary").val());
			var nextContactTime = $.trim($("#edit-nextContactTime").val());
			var address = $.trim($("#edit-address").val());

			// 表单验证
			// 带*的非空
			if (company == "") {
				alert("公司不能为空");
				return;
			}
			if (fullname == "") {
				alert("姓名不能为空");
				return;
			}
			// 正则表达式验证
			if (email != "") { // 如果邮箱非空开始验证
				var emailRegExp = /^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/; // 邮件验证正则表达式
				if (!emailRegExp.test(email)) {
					alert("邮箱格式错误");
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
			if (website != "") {
				var websiteRegExp = /^(?:(http|https|ftp):\/\/)?((?:[\w-]+\.)+[a-z0-9]+)((?:\/[^/?#]*)+)?(\?[^#]+)?(#.+)?$/i;
				if (!websiteRegExp.test(website)) {
					alert("网站格式错误");
					return;
				}
			}
			if (mphone != "") {
				var mphoneRegExp = /^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\d{8}$/;
				if (!mphoneRegExp.test(mphone)) {
					alert("手机号码格式错误");
					return;
				}
			}
			// 发送请求
			$.ajax({
				url:'workbench/clue/saveEditClue.do',
				data:{
					id:id,
					fullname:fullname,
					appellation:appellation,
					owner:owner,
					company:company,
					job:job,
					email:email,
					phone:phone,
					website:website,
					mphone:mphone,
					state:state,
					source:source,
					description:description,
					contactSummary:contactSummary ,
					nextContactTime:nextContactTime,
					address:address
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if(data.code=="1"){
						// 关闭模态窗口
						$("#editClueModal").modal("hide");
						// 刷新线索列表，显示第一页数据，保持每页显示条数不变
						queryClueByConditionForPage($("#page-master").bs_pagination('getOption', 'currentPage'), 
													$("#page-master").bs_pagination('getOption', 'rowsPerPage'));
					} else {
						// 提示信息
						alert(data.message);
						// 模态窗口不关闭
						$("#editClueModal").modal("show");
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
	function queryClueByConditionForPage(pageNo, pageSize) {
		// 收集线索前端界面的相关参数（条件查询的一些信息，如果不需要条件查询，就默认null）
		var fullname = $("#query-name").val();
		var company = $("#query-company").val();
		var phone = $("#query-phone").val();
		var source = $("#query-source option:selected").text(); // 获取下拉框选中的线索来源
		var owner = $("#query-owner").val();
		var mphone = $("#query-mphone").val();
		var state = $("#query-state option:selected").text(); // 获取下拉框选中的线索状态
		// 前端向后端发送请求
		$.ajax({
			url: 'workbench/clue/queryClueByConditionForPage.do',
			data: {
				fullname:fullname,
				company:company,
				phone:phone,
				source:source,
				owner:owner,
				mphone:mphone,
				state:state,
				pageNo:pageNo,
				pageSize:pageSize
			},
			type:'post',
			dataType:'json',
			success:function (data) {
				// 显示所有线索，遍历clueList，拼接所有行
				var htmlString = "";
				$.each(data.clueList, function (index, obj) {
					// checkbox中value存放了线索的id属性，用于删除和修改的调用
					htmlString += "<tr class=\"active\">";
					htmlString += "<td><input type=\"checkbox\" value=\""+obj.id+"\"/></td>";
					htmlString += "<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/clue/detailClue.do?id="+obj.id+"'\">"+obj.fullname+""+obj.appellation+"</a></td>";
					htmlString += "<td>"+obj.company+"</td>";
					htmlString += "<td>"+obj.phone+"</td>";
					htmlString += "<td>"+obj.mphone+"</td>";
					htmlString += "<td>"+obj.source+"</td>";
					htmlString += "<td>"+obj.owner+"</td>";
					htmlString += "<td>"+obj.state+"</td>";
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
						queryClueByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
					}
				});
			}
		});
	}

</script>
</head>
<body>

	<!-- 创建线索的模态窗口 -->
	<div class="modal fade" id="createClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">创建线索</h4>
				</div>
				<div class="modal-body">
					<form id="createClueForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">
									<c:forEach items="${userList}" var="user">
										<option value="${user.id}">${user.name}</option>
									</c:forEach>
								</select>
							</div>
							<label for="create-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-company">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-appellation">
									<option></option>
									<c:forEach items="${appellationList}" var="appellation">
										<option value="${appellation.id}">${appellation.value}</option>
									</c:forEach>
								</select>
							</div>
							<label for="create-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-fullname">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-phone">
							</div>
							<label for="create-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-website">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone">
							</div>
							<label for="create-state" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-state">
									<option></option>
									<c:forEach items="${clueStateList}" var="clueState">
										<option value="${clueState.id}">${clueState.value}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-source" class="col-sm-2 control-label">线索来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-source">
									<option></option>
									<c:forEach items="${sourceList}" var="source">
										<option value="${source.id}">${source.value}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						

						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">线索描述</label>
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
					<button type="button" class="btn btn-primary" id="saveCreateClueBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改线索的模态窗口 -->
	<div class="modal fade" id="editClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">修改线索</h4>
				</div>
				<div class="modal-body">

					<form class="form-horizontal" role="form">
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
							<label for="edit-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-company" value="动力节点">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-appellation">
									<option></option>
									<c:forEach items="${appellationList}" var="appellation">
										<option value="${appellation.id}">${appellation.value}</option>
									</c:forEach>
								</select>
							</div>
							<label for="edit-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-fullname" value="李四">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job" value="CTO">
							</div>
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email" value="lisi@bjpowernode.com">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone" value="010-84846003">
							</div>
							<label for="edit-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-website" value="http://www.bjpowernode.com">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone" value="12345678901">
							</div>
							<label for="edit-state" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-state">
									<option></option>
									<c:forEach items="${clueStateList}" var="clueState">
										<option value="${clueState.id}">${clueState.value}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-source" class="col-sm-2 control-label">线索来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-source">
									<option></option>
									<c:forEach items="${sourceList}" var="source">
										<option value="${source.id}">${source.value}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description">这是一条线索的描述信息</textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="edit-contactSummary">这个线索即将被转换</textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control  my-date" id="edit-nextContactTime" readonly value="2017-05-01">
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address">北京大兴区大族企业湾</textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveEditClueBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>线索列表</h3>
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
				      <div class="input-group-addon">公司</div>
				      <input class="form-control clear-control" type="text" id="query-company">
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
				      <div class="input-group-addon">线索来源</div>
					  <select class="form-control clear-control" id="query-source">
						  <option></option>
						  <c:forEach items="${sourceList}" var="source">
							  <option value="${source.id}">${source.value}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control clear-control" type="text" id="query-owner">
				    </div>
				  </div>
				  
				  
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">手机</div>
				      <input class="form-control clear-control" type="text" id="query-mphone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">线索状态</div>
					  <select class="form-control clear-control" id="query-state">
						  <option></option>
						  <c:forEach items="${clueStateList}" var="clueState">
							  <option value="${clueState.id}">${clueState.value}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>

				  <button type="button" class="btn btn-default" id="queryClueBtn">查询</button>
					&nbsp;
				  <button type="button" class="btn btn-default" id="clearClueBtn">清空</button>
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 40px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createClueBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editClueBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteClueBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 50px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkAll"/></td>
							<td>名称</td>
							<td>公司</td>
							<td>公司座机</td>
							<td>手机</td>
							<td>线索来源</td>
							<td>所有者</td>
							<td>线索状态</td>
						</tr>
					</thead>
					<tBody id="tBody">
<%--						<tr>--%>
<%--							<td><input type="checkbox" /></td>--%>
<%--							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">李四先生</a></td>--%>
<%--							<td>动力节点</td>--%>
<%--							<td>010-84846003</td>--%>
<%--							<td>12345678901</td>--%>
<%--							<td>广告</td>--%>
<%--							<td>zhangsan</td>--%>
<%--							<td>已联系</td>--%>
<%--						</tr>--%>
<%--                        <tr class="active">--%>
<%--                            <td><input type="checkbox" /></td>--%>
<%--                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">李四先生</a></td>--%>
<%--                            <td>动力节点</td>--%>
<%--                            <td>010-84846003</td>--%>
<%--                            <td>12345678901</td>--%>
<%--                            <td>广告</td>--%>
<%--                            <td>zhangsan</td>--%>
<%--                            <td>已联系</td>--%>
<%--                        </tr>--%>
					</tBody>
				</table>
				<div id="page-master"></div>
			</div>
			
<%--			<div style="height: 50px; position: relative;top: 60px;">--%>
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