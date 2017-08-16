<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="gradelist.aspx.cs" Inherits="nwChengji.gradelist" %>

<%@ Register src="ucHead.ascx" tagname="ucHead" tagprefix="uc1" %>
<%@ Register src="ucFoot.ascx" tagname="ucFoot" tagprefix="uc2" %>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=8" />
	<title>互教通 成绩系统 成绩列表</title>
	<link rel="stylesheet" href="css/reset.css" />
  	<link rel="stylesheet" href="//apps.bdimg.com/libs/jqueryui/1.10.4/css/jquery-ui.min.css" />
  	<script src="//apps.bdimg.com/libs/jquery/1.10.2/jquery.min.js"></script>
  	<script src="//apps.bdimg.com/libs/jqueryui/1.10.4/jquery-ui.min.js"></script>
	<link rel="stylesheet" href="css/master.css" />
	<link rel="stylesheet" href="css/gradelist.css" />
	<style type="text/css">
	.datepicker_begin,.datepicker_end { background:url(images/datepicker.gif) 160px 7px no-repeat; }
	.ui-state-highlight, .ui-widget-content .ui-state-highlight, .ui-widget-header .ui-state-highlight { border-color:skyblue; }
	</style>
	<script type="text/javascript">
		jQuery(function($){   
		    $.datepicker.regional['zh-CN'] = {   
		        clearText: '清除',   
		        clearStatus: '清除已选日期',   
		        closeText: '关闭',   
		        closeStatus: '不改变当前选择',   
		        prevText: '上个月',   
		        prevStatus: '显示上个月',   
		        prevBigText: '<<',   
		        prevBigStatus: '显示上一年',   
		        nextText: '下个月',   
		        nextStatus: '显示下个月',   
		        nextBigText: '>>',   
		        nextBigStatus: '显示下一年',   
		        currentText: '今天',   
		        currentStatus: '显示本月',   
		        monthNames: ['一月','二月','三月','四月','五月','六月', '七月','八月','九月','十月','十一月','十二月'],   
		        monthNamesShort: ['一','二','三','四','五','六', '七','八','九','十','十一','十二'],   
		        monthStatus: '选择月份',   
		        yearStatus: '选择年份',   
		        weekHeader: '周',   
		        weekStatus: '年内周次',   
		        dayNames: ['星期日','星期一','星期二','星期三','星期四','星期五','星期六'],   
		        dayNamesShort: ['周日','周一','周二','周三','周四','周五','周六'],   
		        dayNamesMin: ['日','一','二','三','四','五','六'],   
		        dayStatus: '设置 DD 为一周起始',   
		        dateStatus: '选择 m月 d日, DD',   
		        dateFormat: 'yy-mm-dd',   
		        firstDay: 1,   
		        initStatus: '请选择日期',   
		        isRTL: false
		    };   
		    $.datepicker.setDefaults($.datepicker.regional['zh-CN']);
	    });  
		var old_goToToday = $.datepicker._gotoToday
		$.datepicker._gotoToday = function(id) {
		 	old_goToToday.call(this,id)
		 	this._selectDate(id)
		}
	    $(function () {
	        $(".datepicker_begin").datepicker({
	            showOn: "focus",
	            showButtonPanel: true,
	            gotoCurrent: true
	        });
	        $(".datepicker_begin").focus(function () {
	        	$(".datepicker_begin").select()
	            if ($(".datepicker_begin").val() == "请选择起始时间") {
	                $(".datepicker_begin").val("")
	            }
	        })
	        $(".datepicker_begin").blur(function () {
	            if ($(".datepicker_begin").val() == "") {
	                $(".datepicker_begin").val("请选择起始时间")
	            }
	        })
	    });
	    $(function () {
	        $(".datepicker_end").datepicker({
	            showOn: "focus",
	            showButtonPanel: true,
	            gotoCurrent: true
	        });
	        $(".datepicker_end").focus(function () {
	        	$(".datepicker_end").select()
	            if ($(".datepicker_end").val() == "请选择结束时间") {
	                $(".datepicker_end").val("")
	            }
	        })
	        $(".datepicker_end").blur(function () {
	            if ($(".datepicker_end").val() == "") {
	                $(".datepicker_end").val("请选择结束时间")
	            }
	        })
	        $("#cont_name p:last-child a").css({"display":"inline-block","padding":"2px 11px","background-color":"#c2172a","color":"#fefefe","border-radius":"5px"})
	    });
	    function keyClick(){
	    	if(event.keyCode==13){
	    		document.getElementById("lbSearch").click()
	    	}
	    }
	</script>
</head>
<body onkeydown="keyClick();">
<form id="form1" runat="server">
<div id="wrap">
	<uc1:ucHead ID="ucHead1" runat="server" />
	<div id="content_list">
		<img src="images/conbg_bottom.jpg" alt="" id="conbg_bottom" style="position:absolute;bottom:0px;">
		<div id="content_list_bg">
				<a id="getnew" runat="server">导入新成绩</a>
				<span id="getnew_xian"></span>
				<div id="getlist">
					<table>
						<tr style="display:block;margin-bottom:20px;">
	                        <td style="position:relative;">
	                            <div nowrap="TRUE" border="0" style="display:inline;border-style:none;">
	                               考试时间：<input runat="server" id="tbExamBeginDate"  name="date_ExamDate" type="text" value="请选择开始时间" class="datepicker_begin" ctrl="text_date_ExamDate" style="font-size: 14px;width:170px;padding:6px;border:1px solid #e0e0e0;color:#414141;" />
                                   &nbsp;到&nbsp;
                                   <input runat="server" id="tbExamEndDate"  name="date_ExamDate" type="text" value="请选择结束时间" class="datepicker_end" ctrl="text_date_ExamDate" style="font-size: 14px;width:170px;padding:6px;border:1px solid #e0e0e0;color:#414141;" />
	                            </div>
	                        </td>
	                        <td style="width:20px;"></td>
	                        <td>
	                        	班级：<select name="classname" id="selectclass" runat="server" style="margin-left:0px;">
	                        		<option value="请选择班级">请选择班级</option>
	                        		<option value="1">1</option>
	                        		<option value="2">2</option>
	                        		<option value="3">3</option>
	                        		<option value="4">4</option>
	                        		<option value="5">5</option>
	                        		<option value="6">6</option>
	                        		<option value="7">7</option>
	                        	</select>
	                        </td>
	                        <td>
	                        	<asp:LinkButton ID="lbSearch" 
                                    runat="server" onclick="lbSearch_Click" class="queding">筛选历史成绩</asp:LinkButton>
	                        </td>
	                    </tr>
	                    
					</table>
					<div class="headname">
	                   	<p>考试名称</p><p>考试时间</p><p>班级</p><p>操作</p>
	                </div>
	                <div id="cont">
	                	<div id="cont_name">
                            <asp:Literal ID="llListExam" runat="server"></asp:Literal>
	                	</div>
	                </div>

				</div>
                <!--
				<div id="listpage">
					<ul id="pagelist">
						<li><a href="#">上一页</a></li>
						<li style="background:#c2172a;color:#ffffff;"><a href="#">1</a></li>
						<li><a href="#">2</a></li>
						<li><a href="#">3</a></li>
						<li><a href="#">下一页</a></li>
					</ul>
				</div>
                -->
		</div>
	</div>

    <uc2:ucFoot ID="ucFoot1" runat="server" />
	
</div>
</form>
</body>
</html>