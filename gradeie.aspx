<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="gradeie.aspx.cs" Inherits="nwChengji.gradeie" %>

<%@ Register src="ucHead.ascx" tagname="ucHead" tagprefix="uc1" %>
<%@ Register src="ucFoot.ascx" tagname="ucFoot" tagprefix="uc2" %>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <META HTTP-EQUIV="Pragma" CONTENT="no-cache" />
    <META HTTP-EQUIV="Cache-Control" CONTENT="no-cache" />
    <META HTTP-EQUIV="Expires" CONTENT="0" />
    <meta http-equiv="X-UA-Compatible" content="IE=8" />
    <title>互教通 成绩系统 成绩页面</title>
    <link rel="stylesheet" href="css/reset.css" />
    <link rel="stylesheet" href="//apps.bdimg.com/libs/jqueryui/1.10.4/css/jquery-ui.min.css" />
    <script language='javascript' src='JS/jquery-1.11.3.min.js'></script>
    <script src="//apps.bdimg.com/libs/jqueryui/1.10.4/jquery-ui.min.js"></script>
    <script language='javascript' src='Js/init1.js' ></script>
    <script language='javascript' src='JS/plupload.full.js' type='text/javascript' charset='utf-8' defer='defer'></script>
    <!--引入jquery.form插件-->
    <script type="text/javascript" src="jquery.form.js"></script>
    <link rel="stylesheet" href="css/master.css" />
    <link rel="stylesheet" href="css/grade.css">
    <style type="text/css">
    #daoru { display: none; }
    #pickfiles1 { position: relative;background-color: #fff;width: 130px;text-align: center;font-size: 12px;color:orange; margin-right:15px;line-height: 32px;height: 33px;border-radius: 15px; border:1px solid orange; display:inline-block;}
    #pickfiles1 span:hover{ cursor: pointer; }
    #pickfiles1 input:hover{ cursor: pointer; }
    #pickfiles1 form:hover{ cursor: pointer; }
    #fileName:hover { cursor: pointer; }
    #pickfiles1:hover{ cursor: pointer; }
    #fileName { opacity: 0;filter: alpha(opacity=0);position: absolute;top: 0px;left: 0px;line-height: 30px;height: 30px;width: 100%; height:100%;  }
    .countContent div { text-align: left; }
    .yangshi { width:680px;height:24px;line-height:24px;  }
    #txt_examName { width: 460px;padding:4px;border:1px solid #e0e0e0;color:#414141; }
    #myForm2 { width: 133px; height: 33px; position: absolute; top: 0px; }
    #myForm2 input { width: 203px; height: 33px;  position: absolute; left: -70px;}
    .yangshi { width:822px; height:auto; }
    #tab_InputGrade { padding-left: 8px; }
    #tab_InputGrade tr{ padding-left:8px; }
    .con_top { margin:0px 20px; }
    .con_click input { vertical-align: middle; cursor: pointer; color: #fefefe; border:none; display: inline-block;-moz-border-radius: 5px;-webkit-border-radius: 5px;border-radius: 5px;font-size: 17px;margin: 0px 17px;width: 130px;height: 44px;text-align: center; }
    .zr_zp,.zr_ks { color: #10b6cf; border:1px solid #10b6cf; background-color:#fefefe; padding: 4px; }
    input[type="checkbox"] { background-color: #439bfc; }
    .con_msg { font-size: 14px; }
    .daoru2 { text-decoration: underline;  }
    textarea,input[type="text"],select { font-size: 14px; }
    #pickfiles1 i{ display:inline-block;position:absolute;top:0px;left:0px;width:134px;height:40px;z-index:999; }
    #scrolltop2{clear:both;position:fixed;bottom:2%;right:10px;}
    #scrolltop2 .service{width:76px;height:70px;background: url(http://www.9mingxiao.com/resource/pcsite/hjt/images/service.png) no-repeat;cursor:pointer;margin-bottom:10px;}
    </style>
</head>
<body>
<form id="form1" runat="server">
<asp:Literal ID="llScript" runat="server"></asp:Literal>
<script type="text/javascript">
    jQuery(function($){   
        $.datepicker.regional['zh-CN'] = {   
            closeText: '关闭',   
            prevText: '上个月',   
            prevBigText: '<<',    
            nextText: '下个月',   
            nextBigText: '>>',    
            currentText: '今天',   
            monthNames: ['一月','二月','三月','四月','五月','六月', '七月','八月','九月','十月','十一月','十二月'],    
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
        $(".date_ExamDate_class").datepicker({
            showOn: "focus",
            showButtonPanel: true,
            gotoCurrent: true
        });
        $(".con_click_two").css("background-color","gray")

        $("#zp").keyup(function (){
            if($("#zp").val().length>200){
                $(this).val($(this).val().substring(0,200));
                alert("总评字数超过限制！")
            }
        })
        var ss = document.getElementById("zp")
        ss.onkeyup=function(){
           var s=document.getElementById("zp").value.length ;
           if(s>200){
                document.getElementById("zp").value=document.getElementById("zp").value.substr(0,200-1)
           }else{ 
                document.getElementById("a").innerHTML="已输入："+s+"/200 字"
           }
        }
    });
</script>
<script type="text/javascript">
    //全局变量
    //考试全局对象
    var reg = /id=(\d*)/i;
    var regErr = /err=(.*)/;

    var examModel = {};

    if (window.navigator.userAgent.indexOf("MSIE 6")!=-1){
        alert("抱歉，本网站暂时不支持ie6，请换个浏览器")
        window.opener=null; 
        window.open('','_self'); 
        window.close(); 
    }
    if (window.navigator.userAgent.indexOf("MSIE 7")!=-1){
        alert("抱歉，本网站暂时不支持ie7，请换个浏览器")
        window.opener=null; 
        window.open('','_self'); 
        window.close(); 
    }
    //?????
    var saveexam = 1;

    try {
        var err = regErr.exec(window.location.search)[1];
    } catch (e) {
        err = "";
    }
    //加载完页面调用的数组
    var onload = [];
    //是否添加家长手机和学号
    var isIdenty = false;
    //获取考试url
    var examGetUrl = "action.ashx?cmd=ExamGet";
    // 获取学生成绩url
    var examDetailGetUrl = "action.ashx?cmd=StudentDetailGet";
    //设置考试
    var examSetUrl = "action.ashx?cmd=ExamSet";
    //发送短信
    var examSend = "action.ashx?cmd=ExamSend";
    // console.log("document.cookie:"+document.cookie)

    var each = $.each;
    
    $(function () {
        if (typeof JSON == "undefined") {
            var url = "http://libs.baidu.com/json/json2/json2.js";

        } else {
            $.each(onload, function (index, obj) {
                if (obj != undefined && obj instanceof Function)
                    obj();
            });
        }

        $("#date_ExamDate").removeAttr("onfocus").removeAttr("onblur").datepicker({
            showOn: "focus",
            dateFormat: "yy-mm-dd",
            showButtonPanel: true,
            gotoCurrent: true
        }).next().removeAttr("onclick").unbind("click").bind("click", function () {
            $("#date_ExamDate").datepicker("show");
        });


    });


    onload.push(getExamData);
    function getExamData() {
        loading(true);
        var url = examGetUrl;
        var query = {
            request: JSON.stringify({
                ExamGroupId: examGroupId
            })
        };
        $.post(url, query, function (data) {
            try {
                // console.log("getExamData-》data: " + data)
                loading(false);
                examModel = $.parseJSON(data)
                examModel.setExam = function (obj) {

                    this.ClassGrades = obj;

                }
                loadExamBase();
            } catch (e) {
            }
        });

    }


    //加载考试完调用的方法
    function loadExamBase() {
        initClass();  //正确
        initSubjects();  //正确
        initBase();      //正确
    }

    var allDuty = ",";

    //初始化科目
    function initSubjects() {
        var $table = $(".gradeSubjects");
        var $tr0 = $($table[0].insertRow());

        $tr0.css("background-color", "#F7F7F7");
        $table.append($tr0);

        each(examModel.Subjects, function (index, obj) {

            var $tr = $($table[0].insertRow());
            $tr.attr("subjectid", obj.SubjectId);
            $tr.css({ "border-left": "2px solid #e0e0e0","width":"189px","border-bottom":"2px dotted #e0e0e0","overflow":"hidden" });
            var examType = Number(obj.ExamImportType);
            obj.IsIncludeExam = false;
            if (obj.IsIncludeExam && obj.ExamImportType == 0) {
                obj.ExamImportType = 1;
            }
        });

    }

    function getExamName() {
        var year = new Date().getFullYear();
        var term = $("#sel_examTerm option:selected").text();
        var type = $("#sel_examType option:selected").text();
        var childType = "";
        var isCustomName = $("#sel_examType option:selected").val() == "0";
        if (isCustomName) {
            type = "";
            childType = $("#txt_custom").val();
            if (childType == "") {
                $("#txt_custom").focus();
            }
        } else {
            childType = $("#sel_childType option:selected").text();
        }
        var ral = "{0}{1}{2}{3}" + (isCustomName ? "" : "考试");

        var name = string.Format(ral, year, term, type, childType);
        $("#txt_examName").val(name);
        examModel.Name = $("#txt_examName").val();
        examModel.Term = parseInt($("#sel_examTerm").val());
        examModel.Type = parseInt($("#sel_examType").val());
        examModel.ChildType = parseInt($("#sel_childType").val()) || 101;
    }


    //初始化班级(参考对象)
    function initClass() {
        var classes = examModel.Classes;
        var classesLen = classes.length;
        var $table = $("#table_classes");
        var mod = 6;

        for (var i = 0; i < Math.ceil(classesLen / mod); i++) {
            var $tr = $("<tr></tr>");
            for (var j = 0; j < mod; j++) {
                var index = i * mod + j;
                var tempObj = classes[index];
                if (!tempObj) {
                    continue;
                }
                var tdhtml = "<td><input type='radio' name='classname' class='examClass' cid='" + tempObj.ClassId + "' id='chk_class_" + tempObj.ClassId + "' " + (tempObj.IsIncludeExam ? "checked" : "") + " /><label for='chk_class_" + tempObj.ClassId + "'>" + tempObj.ClassName + "</label></td>";

                $tr.append(tdhtml)
            }
            $table.append($tr);
        }

        $(".examClass").click(function () {

            var isInClude = this.checked;
            var cid = this.getAttribute("cid");
            var curClass = examModel.Classes.Find(function (obj) { return obj.ClassId == cid });

            curClass.IsIncludeExam = isInClude;

            if (examGroupId != 0) {
                $("#table_classes :input[type=radio]").attr("disabled", true);
            }
            $(this).attr("disabled", false);

            $("#daoru").css("display","block")
            loadExam();
            
        });


    }

    function initBase() {
        //考试名

        examModel.Name = $("#txt_examName").val()

        $("#txt_examName").change(function () {
            var tempName = $("#txt_examName").val();
        });
        // console.log("examModel:"+JSON.stringify(examModel))
        $("#sel_childType").hide();

        //学期
        $("#sel_examTerm").val(examModel.Term);
        $("#sel_examTerm").change(function () {
            examModel.Term = parseInt(this.value, 10);
            getExamName();
        });
        if (examModel.Type == 2 || examModel.Type == 1 || examModel.Type == 0) {
            if (examModel.Type == 0) {
                $("#txt_custom").show();
                $("#txt_custom").val(examModel.ChildTypeName);
            }
            if (examModel.Type == 1) {
                $("#sel_childType").show();
                $("option[ref=unit]", $("#sel_examType_Hide")).appendTo($("#sel_childType"));
                $("#sel_childType").val(examModel.ChildType);
            }
            if (examModel.Type == 2) {
                $("#sel_childType").show();
                $("option[ref=month]", $("#sel_examType_Hide")).appendTo($("#sel_childType"));
                $("#sel_childType").val(examModel.ChildType);
            }
        }
        //考试类型
        $("#sel_childType").change(function () {
            examModel.ChildType = parseInt(this.value, 10);
            getExamName();
        });
        $("#sel_examType").change(function () {
            var curSel = this.value;
            examModel.Type = parseInt(curSel, 10);
            var $curSelector = $("#sel_childType");
            var $hideSelector = $("#sel_examType_Hide");
            $curSelector.hide();
            $("option", $curSelector).appendTo($hideSelector);
            if (curSel == 1) {
                $curSelector.show();
                $("option[ref=unit]", $hideSelector).appendTo($curSelector);
            } else if (curSel == 2) {
                $curSelector.show();
                $("option[ref=month]", $hideSelector).appendTo($curSelector);
            }else if (curSel == 3) {
                examModel.ChildType = 301;
            } else if (curSel == 4) {
                examModel.ChildType = 401;
            }
            getExamName();
        });
        $("#sel_examType").val(examModel.Type);



        //考试时间
        var $date = $("#date_ExamDate");
        $date.val(examModel.ExamDate);
        $date.change(function () {
            examModel.ExamDate = $date.val();

        });



        if (examGroupId != 0) {
            //自己获取data
            var new_list = examModel.list;
            // console.log("examModel.list:"+examModel.list)
            examModel.ExamDate = new_list.Date;

            $date.val(new_list.Date)

            examModel.Name = new_list.Name;

            $("#txt_examName").change(function () {
                var tempName = $("#txt_examName").val();
                new_list.Name = tempName;
                examModel.Name = tempName;
            });
            // console.log("new_list.Name:"+new_list.Name+" examModel.Name:"+JSON.stringify(examModel.list))
            $("#txt_examName").val(new_list.Name);

            $("#table_classes input[cid=" + new_list.ClassNo + "]").attr("checked", "checked");

            if ($("#table_classes input[cid=" + new_list.ClassNo + "]").attr("checked")) {
                $("#table_classes input[cid=" + new_list.ClassNo + "]").click()
            }

            if(new_list.Comment != "" ){
                $("#zp").val(new_list.Comment);
            }
        }
        
    }

    //获得选到的科目列表
    function getSubjectList() {

        
        var allSubject = [];

        var pySubject = null;

        var eachDuty = allDuty.split(",")
        for(var j=0;j<eachDuty.length;j++){
            if (eachDuty[j].length > 0)
            {
                // console.log("eachDuty:"+eachDuty[j])
                each(examModel.Subjects, function (index, obj) 
                {
                    if (obj.SubjectId == eachDuty[j])
                    {
                        if (strpy.indexOf("|" + obj.SubjectName + "|") >= 0)
                        {
                            pySubject = obj
                            // console.log("pySubject:"+pySubject.SubjectId)
                        }
                        else
                        {
                            allSubject.push(obj)
                        }
                    }
                })
            }
        }

        if (pySubject != null)
        {
            strpyid = pySubject.SubjectId
            allSubject.push(pySubject);
        }

        each(examModel.Subjects, function (index, obj) 
        {
            if (allSubject.indexOf(obj) < 0)
            {
                allSubject.push(obj)
            }
        })

        examModel.Subjects = allSubject

        // console.log("examModel.Subjects888888:"+JSON.stringify(examModel.Subjects))

        return examModel.Subjects.FindAll(function (obj) { if (obj.IsIncludeExam) return obj; }).ConvertAll(function (obj) {
            return obj.SubjectId;

        });
    }

    //获得选到的班级列表
    function getClassList() {
        var classids = 0;
        for(var i=0;i<$("#table_classes :input[type=radio]").length;i++){
            if($("#table_classes input:eq("+i+")").parent().find("input:checked").attr("cid") == $("#table_classes input:eq("+i+")").parent().find("input").attr("cid")){
                // console.log("$(this):"+$("#table_classes input:eq("+i+")").parent().find("input").attr("cid")+" checked:"+$("#table_classes input:eq("+i+")").parent().find("input:checked").attr("cid"))
                classids = $("#table_classes input:eq("+i+")").parent().find("input").attr("cid")
            }

        }
        return classids;
    }

    //加载考试对象
    function loadExam(src) {
        var classids = getClassList();

        var subjectids = getSubjectList();

        var url = examDetailGetUrl;

        var query = {
            request: JSON.stringify({
                ExamGroupId: examGroupId,
                SubjectIds: subjectids, 
                ClasseIds: classids 
            })
        };
        // console.log("query:"+JSON.stringify(query))


        if (examGroupId == 0) {
            if (examModel.ClassGrades) {
                examModel.ClassGrades.Each(function (obj) {

                    obj.Students.Each(function (_obj) {

                        for (var i = 0; i < _obj.Grade.length; i++) {

                            if (Number(_obj.Grade[i].ImportType) == 1 || Number(_obj.Grade[i].ImportType) == 3 ||
                                    Number(_obj.Grade[i].ImportType) == 5 || Number(_obj.Grade[i].ImportType) == 7
                                    ) {
                                _obj.Grade[i].ImportValue = "0";
                            } else {
                                _obj.Grade[i].ImportValue = "";

                            }
                        }

                    });

                });
            }

            // loading(false);
            // return loadTable();     //私自注释了

        }

        loading(true);

        $.post(url, query, function (data) {
            loading(false);

            var temp = JSON.parse(data);
            // console.log("data999999:"+data)
            examModel.setExam(temp.ClassGradeList);

            loadTable();
        });

    }

    //生成table(生成成绩输出)
    function loadTable() {
        var result = getSubjectHeader();

        var header = result[0];
        $("#txt_Content").val(result[1]);

        var body = getStudentLines();

        var $table = $("#tab_InputGrade");
        $("tr", $table).remove();
        $table.append(header);

        each(body, function (index, obj) {
            $table.append(obj);

        });
        initStudentGradeTable();
        $("#allselect").click(function (){
            if($("#allselect").is(':checked')){
                $("#tab_InputGrade :input[name='allsel']").click();
                $("#tab_InputGrade :input[name='allsel']").attr("checked",true);
            }else{
                $("#tab_InputGrade :input[name='allsel']").attr("checked",false);
            }
        })

        $(".yangshi").bind("DOMSubtreeModified",function(){
            $(".con_click_two").css("background-color","gray");
            $(".con_click_one").css("background-color","#3abe8b");
            $(".con_click_two").attr("disabled",true);
            $(".con_click_one").attr("disabled",false);
        })

    }
    var zongP = "";

    var _exam = "";

    var strpy = "|评语|个人评语|个评|";
    var strpyid = 0;

    // 拿到头部列表
    function getSubjectHeader() {
        var $tr = $("<tr class='DataGrid_Header'><td width='50px' class='headerName'><input type='checkbox' id='allselect' style='margin-left:5px;vertical-align:bottom;margin-top:4px;float:left;' name='全选' checked/> 姓名</td><td width='80'>班级</td><td>成绩</td><td style='display:none;' class='headerSum' >总分</td></tr>");
        // <td width='50'>编号</td>

        var $hName = $(".headerSum", $tr);
        var importheader = "姓名" + "\t";
        var i = 0;

        each(examModel.Subjects, function (index, obj) {
            if (obj.IsIncludeExam) {
                var sid = obj.SubjectId;
                var unit = getSubjectHeaderUnit(sid, i++);
                var tempSubject = examModel.Subjects.Find(function (obj) { return obj.SubjectId == sid });

                var name = tempSubject.SubjectName;
                var fullmark = tempSubject.FullMark;
                var unitLevel = "";
                var unitOrder = "";
                switch (obj.ExamImportType) {
                    case 2:
                    case 3:
                        unitLevel = $("<td  max='" + fullmark + "' subjectid='" + obj.SubjectId + "'>" + string.Format("{0}(等级)", name) + "</td>");
                        break;
                    default:
                        break;
                }

                if (obj.ExamImportType == 3 || obj.ExamImportType == 5 ||
                        obj.ExamImportType == 7 || obj.ExamImportType == 1) {
                    importheader = (importheader + obj.SubjectName) + '\t';

                }

                $hName.before(unit);

            }
        });
        var result = [$tr, importheader];
        return result;
    }

    //生成每一科的表头
    function getSubjectHeaderUnit(subjectid, index) {
        var tempSubject = examModel.Subjects.Find(function (obj) { return obj.SubjectId == subjectid });

        var name = tempSubject.SubjectName;

        var fullmark = tempSubject.FullMark;

        switch (tempSubject.ExamImportType) {
            case 1:
                return $("<td id='index_" + index + "' max='" + fullmark + "' iscount='" + tempSubject.IsCount + "' subjectid='" + subjectid + "'>" + string.Format("{0}", name) + "</td>");
                break;
            case 3:
                return $("<td id='index_" + index + "' max='" + fullmark + "' iscount='" + tempSubject.IsCount + "' subjectid='" + subjectid + "'>" + string.Format("{0}", name) + "</td>");
                break;
            case 5:
                return $("<td id='index_" + index + "' max='" + fullmark + "' iscount='" + tempSubject.IsCount + "' subjectid='" + subjectid + "'>" + string.Format("{0}", name) + "</td>");
                break;
            case 7:
                return $("<td id='index_" + index + "' max='" + fullmark + "' iscount='" + tempSubject.IsCount + "' subjectid='" + subjectid + "'>" + string.Format("{0}", name) + "</td>");
                break;
            default:
                return "";
                break;
        }
    }

    // 获取成绩的input框
    function getStudentLines() {

        var trStr = "<tr style='border-bottom:1px dotted #c9d1d1;margin-bottom:8px;'><td width='85px' class='headerName sendName'><input type='checkbox' name='allsel' style='vertical-align:bottom;margin-top:3px;float:left;margin-left:5px;' checked='checked' /> {4}</td><td width='50'>{3}</td><td><div class='yangshi' classid='{6}' studentid='{0}' contenteditable='true' onchange='javascript: saveexam = 0; return false;' subjectid='888888' style=' padding:0px 5px;border:1px solid #c0c0c0;text-align:left;margin-bottom:10px;margin-top:10px;'></div></td><td width='100px' style='display:none;' class='headerSum'>{5}</td></tr>";
        var i = 0;
        var result = [];
        // console.log("examModel.ClassGrades:"+JSON.stringify(examModel.ClassGrades))


        each(examModel.ClassGrades, function (index, obj) {
            var stus = obj.Students;

            var classid = obj.ClassId;
            // console.log("classid:"+classid)
            if (classid >= 0) {
                // console.log("examModel.Classes:"+JSON.stringify(examModel.Classes))
                // console.log("className:"+className)
                var className = examModel.Classes.Find(function (obj) { return obj.ClassId == classid }).ClassName;


                each(stus, function (_index, student) {

                    var temp = 0;
                    ++i;
                    var resultStr = string.Format(trStr, student.Sid, i, student.Code, className, student.Name, student.Sum, classid);
                    var $tr = $(resultStr);

                    var $td = $(".headerSum");
                    //分数

                    if (student.Grade.length > 0) {

                        each(student.Grade, function (__index, gradeItem) {
                            var maxMark = 0;
                            switch (gradeItem.ImportType) {
                                case 1:
                                    var grade = $("<td><input  importType='mark' onclick='select()'  classid='" + classid + "' subjectid='" + gradeItem.SubjectId + "' studentid='" + student.Sid + "' max='" + maxMark + "' type='text' index='" + _index + "' cols='" + (temp + 2) + "' rows='" + i + "' style='width:30px;padding:4px;border:1px solid #d0d0d0; color:#666666; ' value='' /></td>");
                                    if(gradeItem.SubjectId==strpyid){
                                        grade = $("<td><input  importType='mark' onclick='select()'  classid='" + classid + "' subjectid='" + gradeItem.SubjectId + "' studentid='" + student.Sid + "' max='" + maxMark + "' type='text' index='" + _index + "' cols='" + (temp + 2) + "' rows='" + i + "' style='width:100px;padding:4px;border:1px solid #d0d0d0; color:#666666; ' value='' /></td>");
                                    }
                                    $td.before(grade);
                                    temp++;
                                    break;
                                default:
                                break;
                            }
                        });
                    }
                    result.push($tr);
                });
            }

        });
        
        return result;

    }

    // 成绩input框的各种操作
    function initStudentGradeTable() {
        var inputs = $("#tab_InputGrade div");
        if (examGroupId != 0) {

            for (var i = 0; i < examModel.exam.length; i++) {
                // console.log("examModel.exam[i]"+examModel.exam[i].Comment)
                $("#tab_InputGrade div[subjectid=888888][studentid=" + examModel.exam[i].StudentNo + "]").html(examModel.exam[i].Comment)

            };
        }

        loading(false);

    }


    // 加载图的出现
    function loading(opt) {
        if (opt) {
            $("#shadowDiv").show();
            var left = 0;
            var _top = 0;
            if (window.innerHeight) {
                left = (window.innerWidth - $("#shadowDiv img").width()) / 2;
                _top = (window.innerHeight - $("#shadowDiv img").height()) / 2;
            } else if (document.documentElement.clientHeight) {
                left = (document.documentElement.clientWidth - $("#shadowDiv img").width()) / 2;
                _top = (document.documentElement.clientHeight - $("#shadowDiv img").height()) / 2;
            }
            $("#shadowDiv img").css({ "position": "fixed", left: left + "px", top: _top + "px" });
        } else {
            $("#shadowDiv").hide()
        }
    }



    // 发送短信后的提示
    function pushToServer(isSms, type) {
        if(examGroupId == 0 || saveexam == 0) { 
            alert("请先保存成绩后再发送短信")
            return false;
        }else if(examGroupId !=0){
            if (!checkDatalegal()) return false;

            var url = examSend;
            // console.log("examid:"+examGroupId)
            if(kf_name != "" && kf_enname != ""){
                url = url + "&ExamId=" + examGroupId +"&name=" + kf_name + "&enname=" + encodeURIComponent(kf_enname) ;
            }else{
                url = url + "&ExamId=" + examGroupId;
            }

            var sendGrade = '[';

            var iiii = 0;

            var confirm_on = "";

            $("#tab_InputGrade div").each(function (i) {
                if($("#tab_InputGrade input:eq("+(i+1)+")").is(':checked')){
                    var studentss = $(this).attr("studentid")
                    var sendGrade_value = $(this).html()

                    var regNbsp=/&nbsp;/g;

                    sendGrade_value = sendGrade_value.replace(regNbsp," ");

                    var studentNN = $(this).parent().parent().find("td:eq(0)").text()
                    var classNN = $("#txt_examName").val()
                    var zpNN = $("#zp").val()

                    var dianPD = "";

                    if (iiii > 0) {
                        sendGrade = sendGrade + ',';
                    }

                    var htmlLAST_on = sendGrade_value.substring(sendGrade_value.length-1,sendGrade_value.length)

                    var indexOf_htmlLAST_on = "。,;；，.、";

                    if(indexOf_htmlLAST_on.indexOf(htmlLAST_on)){
                        dianPD = "。";
                    }

                    var regyinhao=/\u0022/g;

                    sendGrade_value = sendGrade_value.replace(regyinhao,"”")

                    zpNN = zpNN.replace(regyinhao,"”")

                    sendGrade = sendGrade + '{';

                    sendGrade = sendGrade + '"strSms":"' + studentNN + "，" + classNN + "，" + sendGrade_value + dianPD + zpNN + '",';

                    confirm_on = studentNN + "，" + classNN + "，" + sendGrade_value + dianPD + zpNN 

                    sendGrade = sendGrade + '"StudentNo":' + studentss;

                    sendGrade = sendGrade + '}';

                    iiii++;
                }
                
            })
            sendGrade = sendGrade + ']';



            // var sendGrade_on = eval(sendGrade)
            var sendGrade_on = JSON.parse(sendGrade);

            // (new Function('return ' + sendGrade_on))()
            

            var Sendexam = {
                SchoolNo: School_No,
                TeacherNo: Teacher_No,
                ExamGroupId: examGroupId,
                SmsExam: sendGrade_on
            };

            var query = {
                request: JSON.stringify(Sendexam)
            };
            console.log("Sendexam:"+JSON.stringify(Sendexam))
            return false;
            

            if(confirm("发送短信示例如下：\n" + confirm_on + "\n\n是否立即发送短信？")){
                $.post(url, query, function (data) {
                    // console.log("data:"+data)
                    data = JSON.parse(data)
                    if (isNaN(data.result)) {
                        alert("短信发送失败")
                        return false;
                    }else if(data.result==0){
                        alert("短信发送失败，条数为0")
                        return false;
                    } else{
                        var aDate = new Date();

                        var cookieTime = document.getElementById("cookie_time")

                        cookieTime.innerHTML=aDate.getFullYear()+"年"+(aDate.getMonth()+1)+"月"+aDate.getDate()+"日"+aDate.getHours()+"时"+aDate.getMinutes()+"分"+aDate.getSeconds()+"秒";

                        setCookie("examgroupId"+examGroupId,cookieTime.innerHTML, 7);

                        alert("温馨提示：短信已发送 " + data.result + " 条，您发给家长的留言，教师秘书会尽快审核出去并发送给家长，审核完毕会有短信通知您。敬请留意！")
                        window.location.href= "./gradelist.aspx";
                    }
                    loading(false);
                });
            }else{
                return false;
            }
        }
    } 

    // 拿到excel后让分数出现
    function sendExcel(obj){

        var result = JSON.parse(obj);
        // console.log("result:"+JSON.stringify(result))
        var reError = JSON.stringify(decodeURIComponent(result.error))

        var errorPD = reError.match(/\|[^\|]+\|/)
        var errorName = reError.split("|")

        errorName = eval("'" + errorName + "'");

        if(errorPD != null) {
            alert("发现excel表格中含有班级不存在的名字："+errorName)

        }

        each(result,function (index,obj){

            for(var jj=0;jj<obj.length;jj++){
                $("#tab_InputGrade div[subjectid=888888][studentid="+obj[jj].studentID+"]").html(obj[jj].value)
            }

        })
        for(var i=0;i<$("#tab_InputGrade div").length;i++){

            if($("#tab_InputGrade div:eq("+i+")").html().indexOf("为空") < 0){
                // console.log("i:"+i + " htmlue:"+$("#tab_InputGrade div:eq("+i+")").html())
                $("#tab_InputGrade tr:eq("+(i+1)+")").css("background","white")
            }
            if($("#tab_InputGrade div:eq("+i+")").html() == ""){
                $("#tab_InputGrade tr:eq("+(i+1)+")").css("background","yellow")
            }

        }

        // 发现存在完全为空的人，取消打勾
        $("#tab_InputGrade div").each(function (i) {
            var csValue = $(this).html();
            var csStudentid = $(this).attr("studentid")
            if(csValue == ""){
                $("#tab_InputGrade input:eq("+(i+1)+")").attr("checked",false)
            }else{
                $("#tab_InputGrade input:eq("+(i+1)+")").attr("checked",true)
            }

        })
        
    }

    var bcSms = null;
    // 保存成绩按钮的操作
    function SendSms() {
        if (!checkDatalegal()) return false;
        var url = examSetUrl;

        var strCLass = "";
        $("#tab_InputGrade div").each(function (i) {
            var stCLass = $(this).attr("classid")

            strCLass = Number(stCLass);
        })

        var strListDuty = "[";

        var iii = 0;

        var tempListDuty = "";
        var xxxcom = "xxxxxxxx"

        $("#tab_InputGrade div").each(function (i) {

            var strexam = $(this).html()
            var strNo = $(this).attr("studentid")
            var strDuty = $(this).attr("subjectid")

            var strCom = "";

            if (strDuty == strpyid)
            {
                strCom = strexam
                var eachDuty = allDuty.split(",")
                for(var j=0;j<eachDuty.length;j++){
                    if (eachDuty[j].length > 0)
                    {
                        tempListDuty = tempListDuty.replace(xxxcom, strCom)
                    }
                }
                strListDuty = strListDuty + tempListDuty
                tempListDuty = ""
            }
            else
            {
                if (iii > 0) {
                    tempListDuty = tempListDuty + ',';
                }

                tempListDuty = tempListDuty + '{';

                tempListDuty = tempListDuty + '"ID":"' + examGroupId + '",';

                tempListDuty = tempListDuty + '"StudentNo":' + strNo + ',';

                tempListDuty = tempListDuty + '"DutyNo":' + strDuty + ',';

                tempListDuty = tempListDuty + '"Value":"' + strexam + '",';

                if (strpyid == ""){
                    tempListDuty = tempListDuty + '"Comment":""';
                }
                else
                {
                    tempListDuty = tempListDuty + '"Comment":"' + xxxcom + '"';
                }

                tempListDuty = tempListDuty + '}';
                // console.log("tempListDuty:"+tempListDuty)
                iii++;
            }
        })
        
        if (strpyid == ""){
            strListDuty = strListDuty + tempListDuty + ']';
        }
        else{
            strListDuty = strListDuty + ']';
        }
        // console.log("strListDuty:"+strListDuty)

        strListDuty_on = eval('(' + strListDuty + ')')

        examModel.Name = $("#txt_examName").val()

        var comment = $("#zp").val()
        // console.log("comment:"+typeof(comment))
        
        _exam = {

            list: {
                Name: examModel.Name,
                Date: examModel.ExamDate,
                ID: examGroupId,
                ClassNo: strCLass,
                TeacherNo: Teacher_No,
                SchoolNo: School_No,
                Comment:comment
            },
            exam: strListDuty_on
        };

        // console.log("_exam:"+JSON.stringify(_exam))
        if ($("#tag1").is(":visible")) {
            _exam.InputType = 1;
        } else if ($("#tag2").is(":visible")) {
            _exam.InputType = 2;
        } else if ($("#tag3").is(":visible")) {
            _exam.InputType = 3;
        }
        var query = {
            request: JSON.stringify(_exam)
        };

        bcSms = _exam;
        // console.log("JSON.stringify(_exam):"+JSON.stringify(_exam))
        $.post(url, query, function (data) {

            var result = JSON.parse(data);
            // console.log("data:"+data)
            alert("保存成功！")

            examGroupId = result.examGroupId;

            saveexam = 1;

            loading(false);

            pushToServer(true);

        })

        $(".con_click_two").css("background-color","#c2172a")
        $(".con_click_two").attr("disabled",false);

        $("#tab_InputGrade div").each(function (i) {
            var csValue = $(this).html();
            var csStudentid = $(this).attr("studentid")
            if(csValue == ""){
                $("#tab_InputGrade input:eq("+(i+1)+")").prop("checked",false)
                $("#tab_InputGrade tr:eq("+(i+1)+")").css("background-color","yellow")
            }else{
                $("#tab_InputGrade tr:eq("+(i+1)+")").css("background-color","white")
                $("#tab_InputGrade input:eq("+(i+1)+")").prop("checked",true)
            }

        })
    }

    //检查考试录入的数据是否正确
    function checkDatalegal() {
        if (examModel.Type == 0 && $("#txt_custom").val().Trim() == "") {
            alert("自定义名称不能为空");
            $("#txt_custom")[0].focus();
            return false;
        }
        if($("#txt_examName").val()==""){
            alert("考试名称不能为空");
            $("#txt_examName").focus()
            return false;
        }
        if ($("#date_ExamDate").val()=="") {
            alert("考试时间不能为空");
            $("#date_ExamDate").focus()
            return false;
        }
        return true;
    }
    var currentLine = 1;
    var currentCol = 1;
    var $preinput;


    // 键盘方向键控制input框焦点
    function keyDown(event) { 
        var $input_key = $("#tab_InputGrade div");

        var $gradeTable = $(".DataGrid_Header");

        var rows = $gradeTable.find("td").length-3;

        var focus=document.activeElement; 

        if(!document.getElementById("tab_InputGrade").contains(focus)) return; 

        var event=window.event||event;

        var key=event.keyCode;

        for(var i=0; i<$input_key.length; i++) { 

            if($input_key[i]==focus) break; 

        } 

        switch(key) { 
            // case 37: 
            //     if(i>0) {
            //         $input_key[i-1].focus();
            //     }; 
            //     break; 
            case 38: 
                if(i-rows>=0){
                    $input_key[i-rows].focus();
                } 
                break; 
            // case 39: 
            //     if(i<$input_key.length-1){
            //         $input_key[i+1].focus(); 
            //     }
            //     break; 
            case 40: 
                if(i+rows <$input_key.length){
                    $input_key[i+rows].focus();
                }
            break; 
        } 
       
    } 
    function click_a(divDisplay) {
        if (document.getElementById(divDisplay).style.display == "none") {
            //document.getElementById(divDisplay).style.display = "block";
            javascript: $('.tbTitle3 tr:eq(0)').show();
        }
        else {
            javascript: $('.tbTitle3 tr:eq(0)').hide();
        }
    }

    $(function () {
        
        $(".closeit").click(function () {
            $("#close_alert").css("display", "none");
            $("#closebgg").css("display", "none")
            $(".countContent").empty();
        })
        $(".nosend").click(function () {
            $("#close_alert").css("display", "none");
            $("#closebgg").css("display", "none")
            $(".countContent").empty()
        })

        $("#excel_tishi").css({"position":"fixed","z-index":"999","line-height":"27px","border-top":"3px solid red","background-color": "#fff","width":"600px","left":"50%","top":"50%","margin-left":"-300px","margin-top":"-300px","color":"#5f7779","padding-bottom":"20px","display":"none"})
        $("#excel_tishi p ").css({"margin":"5px 20px"})
        $("#excel_tishi a").css({"display": "inline-block","background":"rgb(192,0,0)","-moz-border-radius":" 5px","-webkit-border-radius": "5px","border-radius": "5px","color": "#fcfcfc", "margin-left": "20px","width": "70px", "height": "30px","line-height": "30px", "text-align": "center"})
        $(".excel_tishi_sc").css({"position":"fixed","z-index":"999","line-height":"27px","border-top":"3px solid red","background-color": "#fff","width":"600px","left":"50%","top":"50%","margin-left":"-300px","margin-top":"-300px","color":"#5f7779","padding-bottom":"20px","display":"none"})
        $(".excel_tishi_sc p ").css({"margin":"5px 20px"})
        $(".excel_tishi_sc a").css({"display": "inline-block","background":"rgb(192,0,0)","-moz-border-radius":" 5px","-webkit-border-radius": "5px","border-radius": "5px","color": "#fcfcfc", "margin-left": "20px","width": "70px", "height": "30px","line-height": "30px", "text-align": "center"})
        $(".daoru2").click(function (){
            $("#closebgg").css("display", "block")
            $("#excel_tishi").css("display", "block")
        })
        $("#excel_tishi_a").click(function (){
            $("#closebgg").css("display", "none")
            $("#excel_tishi").css("display", "none")


        })
        $("#excel_tishi_a_sc").click(function (){
            $("#closebgg").css("display", "none")
            $(".excel_tishi_sc").css("display", "none")
            $("#pickfiles1 i").css("display","none")
        })
        $("#pickfiles1 i").click(function (){
            $("#closebgg").css("display", "block")
            $(".excel_tishi_sc").css("display", "block")            
        })
    })

    $(function () {
        var client_height = window.screen.height - 300;
        var countheight = client_height - 240;
        client_height = Number(client_height);
        countheight = Number(countheight);
        $("#close_alert").css({ "height": client_height, "margin-top": -client_height / 2 })
        $(".countContent").css({ "height": countheight + "px", "-webkit-max-height": countheight + "px", "overflow-y": "scroll" })

    })

    function setExpiration(cookieLife){
        var today = new Date();
        var expr = new Date(today.getTime() + cookieLife * 24 * 60 * 60 * 1000);
        return  expr.toGMTString();
    }

        // cookie保存发送短信的时间
    function setCookie(sName,sValue,iDay){
        // console.log("setCookie"+setExpiration(iDay))
        var oDate=new Date();

        oDate.setDate(oDate.getDate()+iDay);

        var doMain = window.location.host

        var path = "/"
        cookieStr = sName + "=" + sValue + "; " + "domain=" + doMain + "; path=" + path + "; max-age=3000000; ";

        document.cookie=cookieStr+"expires="+setExpiration(iDay);
    }

    function getCookie(sName){
        var sCookie=document.cookie;

        // console.log("sCookie:"+ sCookie)
        var arr=sCookie.split("; ");

        for (var i=0; i<arr.length; i++){

            var arr2=arr[i].split("=");
            if (arr2[0]==sName){
                return arr2[1];
            }
        }

    }

    // 取得url参数
    function GetString(name){

        var reg = new RegExp("(^|&)"+ name +"=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if(r!=null)return  unescape(r[2]); return null;
    }

    $(function (){
        $(".con_click p").css("display","none")

        if(getCookie("examgroupId"+examGroupId)){

            $(".con_click p").css("display","block")

            $(".con_click_two").attr("disabled","disabled")

            $("#cookie_time").html(getCookie("examgroupId"+examGroupId))
        }

        var txtExamName = document.getElementById("txt_examName");
        var zongPing = document.getElementById("zp");

        $(".con_click_one").click(function (){
            var oDate = new Date()

            setCookie("txt_examName",txtExamName.value,7)

            if(zongPing.value != ""){
                setCookie("zongping",zongPing.value,7)
            }

        })

        if(kf_name != "" && kf_enname != ""){
            setCookie("kf_name",kf_name,0.1)
            setCookie("kf_enname",kf_enname,0.1)
        }else{

            if(window.location.search != "" && getCookie("kf_name") != "undefined" ){
                window.location.href = "gradeie.aspx" + window.location.search + "&name=" + getCookie("kf_name") + "&enname=" + getCookie("kf_enname")
            // return false
            }
        }



        $(".zr_ks").css("display","none")
        $(".zr_zp").css("display","none")

        // 载入考试名称   
        if(getCookie("txt_examName")){
            $(".zr_ks").css("display","inline-block")

            $(".zr_ks").click(function (){
                $("#txt_examName").val(getCookie("txt_examName"))
            })
        }else{
            $(".daoru2").click()
            $("#pickfiles1 i").css("display","inline-block")
        }

        // 载入总评
        if(getCookie("zongping")){
            $(".zr_zp").css("display","inline-block")
            
            $(".zr_zp").click(function (){
                $("#zp").val(getCookie("zongping"))
            })
        }

    })


    function excelSub(){

        var subname = '[';

        // console.log("123:"+JSON.stringify(examModel))
        each(examModel.Subjects, function (index, obj) {
            // console.log("321:"+examModel.Subjects)
            var subno = obj.SubjectId;
            var tempSubject = examModel.Subjects.Find(function (obj) { return obj.SubjectId == sid });
            var subna = tempSubject.SubjectName;

            subname= subname+'{';

            subname= subname + '"subName":"'+subna+'",';

            subname= subname + '"subId":"'+subno+'"';

            subname= subname+"}";

        })

        subname = subname + ']'

        return eval('('+subname+')');
    }

    // 传json获取excel数据
    function getssjson(){

        // 学生
        var stuli = '[';
        var mm=0;

        examModel.ClassGrades.Each(function (obj) {

            obj.Students.Each(function (_obj) {

                if(mm>0){
                    stuli = stuli + ',';
                }
                stuli = stuli + '{';

                stuli = stuli + '"stuName":"'+_obj.Name+'",';

                stuli = stuli + '"stuId":'+_obj.Sid;

                stuli = stuli + '}';
                mm++;

            })
        })
        stuli = stuli + ']';
        
        stuli_on = eval('(' + stuli + ')')


        var myssjson = {
            stuList: stuli_on
        }


        return myssjson;

    }
            



    //上传中 
    var uploadProgress = function (event, position, total, percentComplete) {
        jQuery('#pickfiles1 span').text('上传中..');
    }
    //开始提交
    function showRequest(formData, jqForm, options) {
        jQuery('#pickfiles1 span').text('开始上传..');
        var queryString = $.param(formData);
        loading(true)
    }
    //上传完成
    var showResponse = function (responseText, statusText, xhr, $form) {
        // console.log("responseText:"+responseText)

        sendExcel(responseText);
        jQuery('#pickfiles1 span').text('上传完成');
        jQuery('#pickfiles1 span').text('上传excel文件');
        loading(false)
    }
    $(function (){
        $("#fileName").wrap('<form method="post" action="uploadnew.ashx?option=upload&sno='+School_No+'" id="myForm2"  enctype="multipart/form-data"></form>');
    })

    var option ="";
    function loadUpfile(){ 

        option =
            {
                type: 'post',
                data: { request: JSON.stringify(getssjson()) },
                dataType: 'text', //数据格式为json 
                resetForm: true,
                beforeSubmit: showRequest, //提交前事件
                uploadProgress: uploadProgress, //正在提交的时间
                success: showResponse//上传完毕的事件
            }

        jQuery('#fileName').unbind("change").change(function () {

            $('#myForm2').ajaxSubmit(option);

        });

    }

    </script>
<div id="wrap">
    <uc1:ucHead ID="ucHead1" runat="server" />
    <!-- 内容 -->
    <div id="content">
        <img src="images/conbg_bottom.jpg" alt="" id="conbg_bottom" style="position:absolute;bottom:0px;">
        <div id="content_bg">
    <table id="tab_masterContent" width="1003" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
        <tr>
            <td  valign="top">
            <div class="con_top">您当前位置：<a href="gradelist.aspx" style="color:red;text-decoration:underline;">成绩列表</a> -> <span id="chengjiceshi">成绩页</span><p class="ceshi1" style="display:inline-block;margin-left:30px;"></p></div>
                <div class="con_msg">
                    <p><a href="javascript:;" class="daoru2">操作指南</a>（必看）；发送成绩过程中，若有疑问，请致电客服热线34135333转 0</p>
                    <div id="excel_tishi">
                        <p>1、请按照模板上传学生成绩，上传的excel附件的后缀为 “<em style="color:red;">xlsx</em>”或 2003版本的 “<em style="color:red;">xls</em>”格式，而且 <em style="color:red;">sheet</em> 必须放在第一位</p>
                        <p>2、请按照图片格式在excel文件中填写成绩内容：<br /><img src="images/tishi.png" alt="成绩内容"></p>
                        <p>3、总评字数不超过 <em style="color:red;">200字</em> ，超过的字数将不会显示。</p>
                        <p>4、如上传资料中名字与互教通系统中名字不相符的，系统会提示<em style="color:red;">黄色</em>，成绩上传不成功，请修改excel表格中的名字或者致电 <em style="color:red;">34135333</em> 转<em style="color:red;"> 0 </em>修改系统中的名字。</p>
                        <p>5、若有学生成绩为空，系统上传时该科目不显示，如果学生成绩缺考，系统上传时会显示：<em style="color:red;"> XXX，数学缺考</em>。</p>
                        <p>6、成绩上传成功后请保存，保存完毕系统自动提示发送，如果不需要发送，在成绩保存成功出现预览时，关闭预览即可。</p>
                        <a href="javascript:;" id="excel_tishi_a">关 闭</a>
                    </div>
                    <div class="excel_tishi_sc" style="display:none;">
                        <p>请务必确保上传格式严格按照下面两点：</p>
                        <p>1、请按照模板上传学生成绩，上传的excel附件的后缀为 “<em style="color:red;">xlsx</em>”或 2003版本的 “<em style="color:red;">xls</em>”格式，而且 <em style="color:red;">sheet</em> 必须放在第一位</p>
                        <p>2、请按照图片格式在excel文件中填写成绩内容：<br /><img src="images/tishi.png" alt="成绩内容"></p>
                        <a href="javascript:;" id="excel_tishi_a_sc">关 闭</a>
                    </div>
                </div>
        <table width="98%" border="0" cellspacing="0" cellpadding="3">
            <tr>
                <td>
                    <div id="div_Message">
                        
                    </div>

                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td height="200" valign="top" class="bgbody">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tbTitle3">
                                    <tr>
                                        <td width="20px"></td>
                                        <td width="97%">
                                            <!--基本信息 begin-->
    
                                            <table style="margin-top: 0px;">
                                                <tr style="display:none;height:45px;"> <!-- none替换了block -->
                                                    <td><span class="font_red">* </span></td>
                                                    <td class="new_left"> 考试日期 </td>
                                                    <td>
                                                        <div NOWRAP="TRUE" BORDER="0" >
                                                           <input name="date_ExamDate" type="text" id="date_ExamDate" />
                                                           <img src='images/datepicker.gif' />
                                                        </div>
                                                    </td>
                                                    <td><span class="font_red">&nbsp; </span></td>
                                                    <td align="left" class="new_left"> 成绩类型 </td>
                                                    <td colspan='1' style="display:none;">
                                                        <select id="sel_examType" ref="examName">
                                                            <option value="0">自定义</option>
                                                            <option value="1">单元考试</option>
                                                            <option value="2">月考</option>
                                                            <option value="3">期中</option>
                                                            <option value="4">期末</option>
                                                        </select>
                                                        <select id="sel_childType" ref="examName">
                                                        </select>
                                                        <select id="sel_examType_Hide" style="display: none">
                                                            <option value="201" ref="month">一月</option>
                                                            <option value="202" ref="month">二月</option>
                                                            <option value="203" ref="month">三月</option>
                                                            <option value="204" ref="month">四月</option>
                                                            <option value="205" ref="month">五月</option>
                                                            <option value="206" ref="month">六月</option>
                                                            <option value="207" ref="month">七月</option>
                                                            <option value="208" ref="month">八月</option>
                                                            <option value="209" ref="month">九月</option>
                                                            <option value="210" ref="month">十月</option>
                                                            <option value="211" ref="month">十一月</option>
                                                            <option value="212" ref="month">十二月</option>
                                                            <option value="101" ref="unit">第一单元</option>
                                                            <option value="102" ref="unit">第二单元</option>
                                                            <option value="103" ref="unit">第三单元</option>
                                                            <option value="104" ref="unit">第四单元</option>
                                                            <option value="105" ref="unit">第五单元</option>
                                                            <option value="106" ref="unit">第六单元</option>
                                                            <option value="107" ref="unit">第七单元</option>
                                                            <option value="108" ref="unit">第八单元</option>
                                                            <option value="109" ref="unit">第九单元</option>
                                                            <option value="110" ref="unit">第十单元</option>
                                                            <option value="111" ref="unit">第十一单元</option>
                                                            <option value="112" ref="unit">第十二单元</option>
                                                            <option value="113" ref="unit">第十三单元</option>
                                                            <option value="114" ref="unit">第十四单元</option>
                                                            <option value="115" ref="unit">第十五单元</option>
                                                        </select>
                                                    </td>
                                                    <td style="width:33px;"></td>
                                                    <td style="display:none;"><span class="font_red">&nbsp; </span></td>
                                                    <td align="left" class="new_left"> 学期 </td>
                                                    <td style="display:none;">
                                                        <select id="sel_examTerm" ref="examName">
                                                            <option value="1">第一学期</option>
                                                            <option value="2">第二学期</option>
                                                        </select>
                                                    </td>
                                                </tr>
                                                <tr style="display:block;height:35px;">
                                                    <td><span class="font_red">* </span></td>
                                                    <td align="left" class="new_left"> 考试名称 </td>
                                                    <td id="td_hover" width="700px" colspan='14'>
                                                        <input type="text" id="txt_examName" onchange='javascript: saveexam = 0; return false;' />&nbsp;&nbsp;&nbsp;&nbsp;<input class="zr_ks"  type="button" value="载入最后一次考试名称" />
                                                    </td>
                                                    
                                                </tr>

                                                
                                                <tr style="display:block;line-height:45px;">
                                                    <td style="vertical-align:top;"><span class="font_red">* </span></td>
                                                    <td align="left" class="new_left" style="vertical-align:top;"> 班&nbsp;&nbsp;级 </td>
                                                    
                                                    <td colspan='7'>
                                                        <table id="table_classes">
                                                        </table>
                                                    </td>
                                                </tr>
                                                <tr style="display:block;height:65px;line-height:65px;margin-bottom:20px;">
                                                    <td style="vertical-align:top;"><span class="font_red">&nbsp; </span></td>
                                                    <td align="left" class="new_left" style="vertical-align:top;color:#414141;" > 总&nbsp;&nbsp;评 </td>
                                                    <td colspan='14' style="position:relative;">
                                                        <textarea name="总评" id='zp'  onchange='javascript: saveexam = 0; return false;' style='margin-left:2px;height:75px;width:460px;color:#414141;border: 1px solid #e0e0e0;padding: 4px;'></textarea>
                                                        <span id="a" style="position:absolute;left:489px; top:44px;display:block;width:130px;">已输入：0/200 字</span>
                                                        <input class="zr_zp" type="button" style="vertical-align:top;margin-left:13px;" value="载入最后一次总评">
                                                    </td>
                                                </tr>
                                                <tr style="display: none;">
                                                    <td>
                                                        <textarea name="txt_Description" rows="5" id="txt_Description" onkeypress="NengLong_WebControls_TextBox_CheckMaxLength(this , 200)" onblur="NengLong_WebControls_TextBox_SetMaxLength(this , 200)" onfocus="NengLong_WebControls_TextBox_SetMaxLength(this , 200)" onmouseover="NengLong_WebControls_TextBox_SetMaxLength(this , 200)"></textarea>
                                                    </td>
                                                </tr>
                                                <tr style="display:none;">
                                                    <td>
                                                        <div id="Layer1" style="display:none;">
                                                            <table width="100%" border="0" cellspacing="0" cellpadding="0" class="gradeSubjects" id="shengluohao" >
                                                            </table>
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr style="clear:both;"></tr>
                                            </table>

                                            <!--基本信息 end-->
                                        </td>
                                    </tr>
                                </table>
                                <!-- 手动录入 成绩 begin -->
                                <p style="background:url(images/hr.gif); height:3px; width:99%; margin:20px auto 25px; margin-left:10px;"></p>
                                <div id="daoru">
                                    <div id="attaFilesControl" style="display:inline-block;">
                                        <p id="pickfiles1" onclick="loadUpfile();"><span>上传excel文件</span><input type="file" id="fileName" name="fileName" accept=".xlsx, .xls"  /><i style="display:none;"></i></p>
                                    </div>
                                </div>
                                <div id="closebgg"></div>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0" id="tag1">
                                    <tr>
                                        <td>
                                            <table width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="#FFFFFF"
                                                style="text-align: center;" id="tab_InputGrade" onkeydown="keyDown(event)">
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                                <span id="hide_Grades"></span>
                                <!-- 手动录入 成绩 end -->
                                <!--模板导入 成绩 begin-->
                                <table width="100%" border="0" cellspacing="0" cellpadding="0" id="tag3" style="display: none">
                                    <tr>
                                        <td>
                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                    <td>&nbsp;
                                                    </td>
                                                    <td colspan="2">
                                                        <label style="margin-left: 72px">选择文档(上传完后点击完成或者是下一步)</label>

                                                        <div id="attaFilesControl" style="display: inline-block"><a href="javascript:;" id="pickfiles" class="uploadbtn">浏览<span></span></a></div>
                                                        <ul id="ExcelNameList">
                                                            <li></li>
                                                        </ul>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="3">
                                                        <input type="button" style="margin-left: 70px; margin-top: 20px; padding: 5px; width: 80px; display: none;" name="name" value="确定导入" />
                                                    </td>
                                                </tr>
                                            </table>
                                            <div class="fenge_div_10px">
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                                <!-- 批量导入 成绩 end -->
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
            <div id="shadowDiv" style="display: none">
                <img src="images/loading2.gif" />
            </div>
            </td>
        </tr>
    </table>
    <div class="con_click">
        <p id="cookie_p" style="color:#c2172a;margin-bottom: 30px;">您已在<span id="cookie_time" style="font-weight:bold;"></span>时发送了短信</p>
        <input type="button" onclick="SendSms();" id="savetodraft" value="保存成绩" class="con_click_one" /><input type="button" onclick="pushToServer(true)" value="发送短信" class="con_click_two" />
        <input type="button" onclick="window.location.href='gradelist.aspx'" style="color:#333;background:#fefefe;" value="查看历史成绩" />
        
    </div>

        </div>
    </div>

    <ul id="scrolltop2">
        <a href="http://gz.gcihjt.com/dialog_1.php" target="_blank">
        <li class="service"></li>
        </a>
    </ul>

    <uc2:ucFoot ID="ucFoot1" runat="server" />
</div>
</form>
</body>
</html>
