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
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<style type="text/css">
	.legal-check {
		position: relative;
		left: 360px;
		bottom: 30px;
		color: red;
	} 
	 #center{
		margin: 0 auto;
		display: table;
	} 
	/*body{*/
	/*	!*background: url(微信图片_20220119214551.jpg) no-repeat fixed center;*!*/
	/*	width: 100%;*/
	/*	height: 100%;*/
	/*	background-size: cover;*/
	/*}*/
</style>
<script type="text/javascript">
	$(function(){
		// 对登录账号进行验证
		var loginActRule = null;
		$("#loginAct").blur(function () { // 鼠标失焦后执行判断
			var loginAct = $.trim($("#loginAct").val()); // 获取用户名
			// 获取正则表达式对象，正则表达式规则为：只能为数字和字母，长度为2~10；
			var loginActRegExp = /^[0-9a-zA-Z]{2,10}$/;
			// 判断用户名是否合法
			loginActRule = loginActRegExp.test(loginAct);
			// 如果用户名为空或者全为空格或者不符合正则表达式，错误
			if (!loginAct || !loginActRule) {
				$("#userMsg").text("用户名格式错误");
			}
		})
		$("#loginAct").focus(function () { // 重新获取焦点
			if (!loginActRule) {
				$("#loginAct").val(""); // 清空不合法账号
			}
			$("#userMsg").text(""); // 提示信息清空
		});

		// 对密码进行验证
		var loginPwdRule = null;
		$("#loginPwd").blur(function () { // 鼠标失焦后执行判断
			var loginPwd = $.trim($("#loginPwd").val());
			// 规定密码长度为6~10位，前三位为字母，后面只能为数字或者字母
			var passwordRegExp = /^[A-Za-z]{1,3}[A-Za-z0-9]{4,10}$/;
			loginPwdRule = passwordRegExp.test(loginPwd);
			if (!loginPwdRule) { // 密码格式不正确
				$("#pwdMsg").text("密码格式错误");
			}
		});
		$("#loginPwd").focus(function () { // 重新获取焦点
			if (!loginPwdRule) {
				$("#loginPwd").val(""); // 清空不合法账号
			}
			$("#pwdMsg").text(""); // 提示信息清空
		});

		// 对确认密码进行验证
		var checkLoginPwdRule = null;
		var loginPwdRule = null;
		$("#checkLoginPwd").blur(function () {
			checkLoginPwdRule = $.trim($("#checkLoginPwd").val());
			loginPwdRule = $.trim($("#loginPwd").val());
			if (checkLoginPwdRule != loginPwdRule || checkLoginPwdRule == null) {
				$("#checkPwdMsg").text("密码不一致");
			}
		});
		$("#checkLoginPwd").focus(function () {
			if (checkLoginPwdRule != loginPwdRule || checkLoginPwdRule == null) {
				// 清空确认密码
				$("#checkLoginPwd").val("");
				$("#checkPwdMsg").text("");
			}
		});

		// 验证姓名
		var nameRule = null;
		$("#name").blur(function () {
			var name = $.trim($("#name").val());
			var nameRegExp = /^[\u4E00-\u9FA5\uf900-\ufa2d·s]{2,20}$/; // 姓名验证正则表达式
			nameRule = nameRegExp.test(name);
			if (!nameRule) {
				$("#nameMsg").text("姓名格式错误");
			}
		});
		$("#name").focus(function () {
			if (!nameRule) {
				$("#name").val("");
				$("#nameMsg").text("");
			}
		});

		// 验证邮箱
		var emailRule = null;
		$("#email").blur(function () {
			var email = $.trim($("#email").val());
			var emailRegExp = /^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/; // 邮件验证正则表达式
			emailRule = emailRegExp.test(email);
			if (!emailRule) {
				$("#emailMsg").text("邮箱格式错误");
			}
		});
		$("#email").focus(function () {
			if (!emailRule) {
				$("#email").val("");
				$("#emailMsg").text("");
			}
		});

		// 验证部门编号
		var deptnoRule = null;
		$("#deptno").blur(function () {
			var deptno = $.trim($("#deptno").val());
			var deptnoRegExp = /^[A-Z]{1}[0-9]{2,4}$/; // 第一位只能是大写字母，后最多有三个数字
			deptnoRule = deptnoRegExp.test(deptno);
			if (!deptnoRule) {
				$("#deptnoMsg").text("部门编号格式错误");
			}
		});
		$("#deptno").focus(function () {
			if (!deptnoRule) {
				$("#deptno").val("");
				$("#deptnoMsg").text("");
			}
		});

		// 给注册按钮添加单击事件
		$("#registerBtn").click(function(){
			// 收集参数
			var loginAct = $.trim($("#loginAct").val());
			var name = $.trim($("#name").val());
			var loginPwd = $.trim($("#loginPwd").val());
			//var checkLoginPwd = $.trim($("#checkLoginPwd").val());
			var email = $.trim($("#email").val());
			var deptno = $.trim($("#deptno").val());
			// 表单验证
			if (loginAct == "") {
				alert("用户名不能为空");
				return;
			}
			if (loginPwd == "") {
				alert("密码不能为空");
				return;
			}
			if (name == "") {
				alert("真实姓名不能为空");
				return;
			}
			if (email == "") {
				alert("邮箱不能为空");
				return;
			}
			if (deptno == "") {
				alert("部门编号不能为空");
				return;
			}
			if (!loginActRule || !deptnoRule || !emailRule || !nameRule || !checkLoginPwdRule || !loginPwdRule) {
				alert("用户信息存在问题");
				return;
			}
			// 给创造者字段赋值（这里直接把本人赋值到创造者上了，实际应该由其他人创造）
			var createBy = name;
			// 发送请求
			$.ajax({
				url:'settings/qx/user/register.do',
				data:{
					loginAct:loginAct,
					name:name,
					loginPwd:loginPwd,
					email:email,
					deptno:deptno,
					createBy:createBy
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") { // 保存成功
						alert("注册成功！！");
						window.location.href = "settings/qx/user/toLogin.do"; // 跳转到登录界面
					} else {
						// 输出提示信息
						alert(data.message);
					}
				}
			});
		});

	})
</script>
</head>
<body>
	<!-- <div style="position: absolute; top: 0px; left: 0px; width: 60%;">
		<img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
	</div> -->
	<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
		<div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">CRM &nbsp;<span style="font-size: 12px;">&copy;2022&nbsp;ylx</span></div>
	</div>
	
	<!-- <div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;solid #D5D5D5"> -->
		<div id="center">
			<div class="page-header">
				<h1>注册</h1>
			</div>
			<form action="" class="form-horizontal" role="form">
				<div class="form-group form-group-lg">

					<div style="width: 350px;">
						<input class="form-control" type="text" id="loginAct" placeholder="用户名" >
						 <div class="legal-check">
							 <span id="userMsg" style="position:absolute"></span>
							 <br>
						</div>
						<!-- <span id="userMsg" style="color: red">用户名不合法</span> -->
					</div>
					
					<div style="width: 350px; position: relative;"><!-- 删除了top：20px； -->
						<input class="form-control" type="password" id="loginPwd" placeholder="密码">
					</div>
					<div class="legal-check" id="passwordDiv">
						 <span id="pwdMsg" style="position:absolute"></span>
						<br>
					</div>
					<span id="passwordMsg" style="color: red"></span>
					<br />
					<div style="width: 350px; position: relative;bottom: 20px;">
						<input class="form-control" type="password" id="checkLoginPwd" placeholder="确认密码">
						<div class="legal-check" >
							 <span id="checkPwdMsg" style="position:absolute"></span>
							<br>
						</div>
					</div>
					
					<br>
					<div style="width: 350px; position: relative;bottom: 40px;">
						<input class="form-control" type="text" id="name" placeholder="真实姓名">
						<div class="legal-check" >
							 <span id="nameMsg" style="position:absolute"></span>
							<br>
						</div>
					</div>
					
					<br>
					<div style="width: 350px; position: relative;bottom: 60px;">
						<input class="form-control" type="text" id="email" placeholder="邮件地址">
						<div class="legal-check" >
							 <span id="emailMsg" style="position:absolute"></span>
							<br>
						</div>
					</div>
					
					<br>
					<div style="width: 350px; position: relative;bottom: 80px;">
						<input class="form-control" type="text" id="deptno" placeholder="部门编号">
						<div class="legal-check" >
						 <span id="deptnoMsg" style="position:absolute"></span>
							<br>
						</div>
					</div>
					
					<span id="passwordMsg02" style="color: red"></span>
					<br />
					<button type="button" class="btn btn-primary btn-lg btn-block" id="registerBtn" style="width: 350px; position: relative;top: -80px;">注册</button><!-- 45px -->
					<br />
					<button type="reset" class="btn btn-primary btn-lg btn-block" id="resetBtn" style="width: 350px; position: relative;top: -80px;">清空</button>
				</div>
			</form>
		</div>
	<!-- </div> -->
</body>
</html>