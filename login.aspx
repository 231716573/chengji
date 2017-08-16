<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="login.aspx.cs" Inherits="nwChengji.login" %>


<%@ Register src="ucHead.ascx" tagname="ucHead" tagprefix="uc1" %>
<%@ Register src="ucFoot.ascx" tagname="ucFoot" tagprefix="uc2" %>


<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=8" />
	<title>互教通 成绩系统 登陆页面</title>
	<script language='javascript' src='JS/jquery.js'></script>
	<link rel="stylesheet" href="css/reset.css">
	<link rel="stylesheet" href="css/master.css">
	<link rel="stylesheet" href="css/login.css">
    <style type="text/css">
    input { outline: none; }
    input:-webkit-autofill {-webkit-box-shadow: 0 0 0px 1000px white inset;}
    </style>
<script type="text/javascript">
    $(function () {
        var tips = "请您填写互教通账号或手机号码";
        $(".vip_two input").val(tips)
        $(".vip_two input").focus(function () {
            if ($(".vip_two input").val() == tips) {
                $(".vip_two input").val("")
            }
            $(".vip_two input").css("color", "black")

        })
        $(".vip_two input").blur(function () {
            if ($(".vip_two input").val() == "") {
                $(".vip_two input").val(tips)
                $(".vip_two input").css("color", "#b0b0b0")
            }

        })
        $(".vip_three input").focus(function () {
            $(".vip_three input").css("color","black")
        })
    })
    function keyLogin(){  
        if (event.keyCode==13){                     
            document.getElementById("lbLogin").click(); 
        }
    }  
</script>
</head>
<body onkeydown="keyLogin();">
<form id="form1" runat="server" name="Form1">
<div id="wrap">
	<uc1:ucHead ID="ucHead1" runat="server" />
	<div id="content_login">
		<img src="images/conbg_bottom.jpg" alt="" id="conbg_bottom" style="position:absolute;bottom:0px;"/>
		<div id="content_login_bg">
				<div id="viplogin">
					<p class="vip_one">老师登录</p>
					<p class="vip_two"><input runat="server" id="inUsername" type="text" title="用户名" placeholder="请您填写互教通账号或手机号码"/><img src="images/login_zh.jpg" alt="用户名"/></p>
					<p class="vip_three"><input runat="server" id="inPassword" type="password" title="密码" placeholder="请输入密码"/><img src="images/login_mm.jpg" alt="密码"/></p>
					<!--<p class="vip_four"><a href="#">获取密码？</a> <input type="checkbox"> 记住密码 </p>-->
                    <asp:LinkButton
                        ID="lbLogin" runat="server" name="btnsubmit" CssClass="vip_five" onclick="lbLogin_Click">登录成绩系统</asp:LinkButton>
             </div>
		</div>
	</div>
	
	<uc2:ucFoot ID="ucFoot1" runat="server" />
</div>	
</form>
</body>
</html>
