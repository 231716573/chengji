<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="gradenew.aspx.cs" Inherits="nwChengji.gradenew" %>


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
	<script language='javascript' src='JS/jquery.js'></script>
    <script language='javascript' src='JS/js.js'></script>
    <script language='javascript' src='Js/init.js' ></script>
    <script language='javascript' src='JS/plupload.full.js' type='text/javascript' charset='utf-8' defer='defer'></script>
    <script src="JS/jquery-ui-1.8.16.custom.min.js" type="text/javascript"></script>
    <!--引入jquery.form插件-->
    <script type="text/javascript" src="jquery.form.js"></script>
	<link rel="stylesheet" href="jquery-ui-1.8.16.custom.css" />
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
    #fileName { opacity: 0;filter: alpha(opacity=0);position: absolute;top: 0px;left: 0px;line-height: 30px;height: 30px;width: 140px;  }
    .countContent div { text-align: left; }
    </style>
</head>
<body>
<form id="form1" runat="server">
<asp:Literal ID="llScript" runat="server"></asp:Literal>
<script type="text/javascript">
    //全局变量
    //考试全局对象
    var reg = /id=(\d*)/i;
    var regErr = /err=(.*)/;
    //当前考试组的ID

    var examModel = {};

    // try{
    // var examGroupId = reg.exec(window.location.search)[1];

    // } catch(e) {
    // 	examGroupId = "0";
    // }
    if (window.navigator.userAgent.indexOf("MSIE")!=-1){
        alert("抱歉，本网站暂时不支持ie，请换个浏览器")
        window.opener=null; 
        window.open('','_self'); 
        window.close(); 
    }
    //?????
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

    // 获取模板
    var sendModelUrl = "setModel.js"

    var each = $.each;
    // alert(document.cookie)
    var errList = err.split(",");
    if (!Array.prototype.indexOf) {
        Array.prototype.indexOf = function (obj) {
            var len = this.length;
            for (var i = 0; i < len; i++) {
                if (this[i] == obj) {
                    return i;
                }
            }
            return -1;
        }
    }
    errList = errList.FindAll(function (obj) {
        if (obj) return obj;
    });
    errList = errList.ConvertAll(function (obj) {
        return decodeURI(obj);
    })
    $(function () {
        if (typeof JSON == "undefined") {
            var url = "http://libs.baidu.com/json/json2/json2.js";
            Nenglong.System.LoadJs(url, function () {
                $.each(onload, function (index, obj) {
                    if (obj != undefined && obj instanceof Function)
                        obj();
                });
            });
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
        // loadTable();  //正确
        initClass();  //正确
        initBase();      //正确
    }
    onload.push(function () {
        $("#chk_isUseIdentyCode").change(function () {
            isIdenty = this.checked;
            loadTable();
        });
    });

    var allDuty = ",";


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
        var mod = 8;

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
        $("#txt_custom").hide();

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

        if (examModel.ChildTypeName) {
            $("#txt_custom").val(examModel.ChildTypeName);
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
            $("#txt_custom").hide();
            $("option", $curSelector).appendTo($hideSelector);
            if (curSel == 1) {
                $curSelector.show();
                $("option[ref=unit]", $hideSelector).appendTo($curSelector);
            } else if (curSel == 2) {
                $curSelector.show();
                $("option[ref=month]", $hideSelector).appendTo($curSelector);
            } else if (curSel == 0) {
                $("#txt_custom").show();
            } else if (curSel == 3) {
                examModel.ChildType = 301;
            } else if (curSel == 4) {
                examModel.ChildType = 401;
            }
            getExamName();
        });
        $("#txt_custom").change(function () {
            examModel.ChildTypeName = this.value;
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

        return examModel.Subjects.FindAll(function (obj) { if (obj.IsIncludeExam) return obj; }).ConvertAll(function (obj) {
            return obj.SubjectId;

        });
    }

    //获得选到的班级列表
    function getClassList() {
        var classids = 0;
        $("#table_classes :input[type=radio]").each(function (i) {
            if ($(this).attr("checked") == true) {
                classids = $(this).attr("cid")
            }
        })
        return eval('(' + classids + ')');
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

            if(sendsms != "0") 
            {
                SendAll();
            }
            $(".nosend").click(function (){
                sendsms = 0;
            })
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
        if (errList.length > 0) {
            $("#tab_InputGrade").append("<tr><td width='20px'></td><td colspan='7'><font style='color:red'>使用导入后姓名后带*的表示没有匹配成功,成绩为\"0\"需要手动添加。</font></td></tr>");
        }


    }

    var saveexam = 0;

    // 发送短信
    function SendAll() {

        if(examGroupId == 0 || saveexam == 0) { 
            alert("请先保存成绩后再发送短信")
            return false;
        }else if(examGroupId !=0){
            // if(!duibi()) return false;


            $(".count_send").css({ "display": "table" })

            var $table_send = $(".countContent");

            var bodySend = getGradeSend();

            each(bodySend, function (index, _obj) {
                $table_send.append(_obj)
            })

            var $table_getSubCount = $(".sendContent td")

            $table_getSubCount.html("<input type='checkbox' id='allselect' name='全选' checked/>全选&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;总评：<input type='text' id='zp' style='width:500px;color:#666;' value='填写内容后按确定,将添加到短信最后(最多输入300字)' maxlength='300' />&nbsp;&nbsp;&nbsp;&nbsp;<input type='button' style='cursor:pointer;' id='surepush' value='确定添加' />&nbsp;&nbsp;&nbsp;&nbsp;<input type='button' style='cursor:pointer;' id='surepush_again' value='删除总评' disabled=true />")

             $("#allselect").click(function (){
                $(".countContent tr input[name='allsel']").attr("checked",this.checked)
            })

             $("#surepush").click(function (){

                if($("#zp").val()=="填写内容后按确定,将添加到短信最后(最多输入300字)"){
                    alert("请勿输入默认总评");
                    return false;
                }
                for(var n=0;n<$(".countContent div").length;n++){

                    var valHTML = $(".countContent div:eq("+n+")").html();

                    var valLast = valHTML.substring(valHTML.length-1,valHTML.length)

                    console.log("valHTML:"+valHTML + " valLast:"+valLast)

                    if(valLast!="。"&&valLast!=","&&valLast!=";"&&valLast!="；"&&valLast!="，"&&valLast!="."&&valLast!="、"){

                        $(".countContent div:eq("+n+")").append("。")

                    }

                    $(".countContent div:eq("+n+")").append($("#zp").val())
                }

                $("#surepush").val("已添加")
                $("#surepush_again").val("删除总评")

                $("#zp").attr("disabled",true)
                $("#surepush").attr("disabled",true)
                $("#surepush_again").attr("disabled",false)
             })

             $("#surepush_again").click(function (){

                $("#surepush").val("确定添加")
                $("#surepush_again").val("已删除")

                $("#zp").attr("disabled",false)
                $("#surepush").attr("disabled",false)
                $("#surepush_again").attr("disabled",true)

                for(var n=0;n<$(".countContent div").length;n++){
                    $(".countContent div:eq("+n+")").html($(".countContent div:eq("+n+")").html().substring(0,$(".countContent div:eq("+n+")").html().length-$("#zp").val().length))
                }
             })

             $("#zp").focus(function (){
                if($("#zp").val()=="填写内容后按确定,将添加到短信最后(最多输入300字)"){
                    $("#zp").val("")
                }
             })
             $("#zp").blur(function (){
                if($("#zp").val()==""){
                    $("#zp").val("填写内容后按确定,将添加到短信最后(最多输入300字)")
                 }
             })
             


            $("#close_alert").css("display", "block");
            $("#closebgg").css("display", "block")
        }
    }

    // 获取组合成绩时的科目名称
    function getSubjectName(_index) {

        var SubName = "";
        each(examModel.Subjects, function (index, obj) {

            if (obj.SubjectId == _index) {
                SubName = obj.SubjectName
            }

        })
        return SubName;
    }

    var _exam = "";
    // 组合发送短信
    function getGradeSend() {

        var trStr = "<tr studentid='{0}' classid='{6}' style='text-align:center;vertical-align:middle;margin-bottom:10px;'><td width='5px'><input type='checkbox' name='allsel' style='vertical-align:bottom;margin-bottom:2px;' checked='checked'/></td><td style='width:90px;white-space:nowrap;' class='headerName'>&nbsp;{4}&nbsp;</td><td width='100' style='white-space:nowrap;'>&nbsp;{3}&nbsp;</td></tr>";
        var i = 0;
        var result = [];

        var strListDuty = "[";

        var iii = 0;

        var tempListDuty = "";
        var xxxcom = "xxxxxxxx"

        $("#tab_InputGrade :input[type='text']").each(function (i) {

            var strexam = this.value
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


        
        _exam = {
            exam: strListDuty_on
        };

        // console.log("_exam111:"+JSON.stringify(_exam.exam))
        each(examModel.ClassGrades, function (index, obj) {
            var stus = obj.Students;

            var classid = obj.ClassId;

            if (classid > 0) {

                var className = examModel.Classes.Find(function (obj) { return obj.ClassId == classid }).ClassName;

                each(stus, function (_index, student) {

                    var temp = 0;
                    ++i;
                    var resultStr = string.Format(trStr, student.Sid, i, student.Code, className, student.Name, student.Sum, classid);
                    var $tr = $(resultStr);

                    var strsms = ""; //分数
                    var strcomment = ""
                    // console.log("length:"+JSON.stringify(examModel))
                    for (var j = 0; j < _exam.exam.length; j++) {
                    
                        if (student.Sid == _exam.exam[j].StudentNo) {
                            strcomment = _exam.exam[j].Comment
                            var strValue = _exam.exam[j].Value;
                            var strSubjectName = getSubjectName(_exam.exam[j].DutyNo);

                            strsms =  strsms + strSubjectName + strValue ;
                        }

                    };
                    if (strcomment.length > 0)
                    {
                        strsms = strsms + strcomment 
                    }
                    var gradeSend = $("<td><div class='gradeTxt' contenteditable='true' cols='100' sid='" + student.Sid + "' style='border:1px solid #e0e0e0;font-size:13px;width:650px;'>" + student.Name + "，" + $("#txt_examName").val() + "，" + strsms + "</div></td>");

                    $tr.append(gradeSend);

                    result.push($tr);
                });
            }

        });

        return result;
    }

    var strpy = "|评语|个人评语|个评|";
    var strpyid = 0;

    // 拿到头部列表
    function getSubjectHeader() {
        var $tr = $("<tr class='DataGrid_Header'><td width='50px' class='headerName'>姓名</td><td width='80'>班级</td><td>成绩</td><td style='display:none;' class='headerSum' >总分</td></tr>");
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

        var trStr = "<tr style='border-bottom:1px dotted #c9d1d1;'><td width='65px' class='headerName sendName'>{4}</td><td width='50'>{3}</td><td><input type='text' classid='{6}' studentid='{0}' onchange='javascript: saveexam = 0; return false;' subjectid='888888' style='width:680px;height:24px;' /></td><td width='100px' style='display:none;' class='headerSum'>{5}</td></tr>";
        // <td width='50'>{1}</td>
        var i = 0;
        var result = [];

        // console.log("examModel.ClassGrades:"+JSON.stringify(examModel.ClassGrades))
        each(examModel.ClassGrades, function (index, obj) {
            var stus = obj.Students;

            var classid = obj.ClassId;

            if (classid > 0) {

                var className = examModel.Classes.Find(function (obj) { return obj.ClassId == classid }).ClassName;

                each(stus, function (_index, student) {

                    var temp = 0;
                    ++i;
                    var resultStr = string.Format(trStr, student.Sid, i, student.Code, className, student.Name, student.Sum, classid);
                    var $tr = $(resultStr);

                    if (errList.indexOf(student.Name) > -1) {
                        $(".headerName", $tr).append("<font style='color:red'>*</font>");
                    }

                    var $td = $(".headerSum", $tr);
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
        var inputs = $("#tab_InputGrade input:text");
        if (examGroupId != 0) {
            for (var i = 0; i < examModel.exam.length; i++) {
                $("#tab_InputGrade input[subjectid=888888][studentid=" + examModel.exam[i].StudentNo + "]").val(examModel.exam[i].Comment)

            };
        }
        loading(false);

    }


    // 加载图的出现
    function loading(opt) {
        if (opt) {
            $("#shadowDiv").show();
            var img = $("#shadowDiv img")[0];
            var left = 0;
            var _top = 0;
            if (window.innerHeight) {
                left = (window.innerWidth - img.width) / 2;
                _top = (window.innerHeight - img.height) / 2;
            } else if (document.documentElement.clientHeight) {
                left = (document.documentElement.clientWidth - img.width) / 2;
                _top = (document.documentElement.clientHeight - img.height) / 2;
            }
            $(img).css({ "position": "fixed", left: left + "px", top: _top + "px" });
        } else {
            $("#shadowDiv").hide()
        }
    }


    // 发送短信后的提示
    function pushToServer(isSms, type) {
        if (!checkDatalegal()) return false;

        var url = examSend;

        var sendGrade = '[';

        var iiii = 0;

        $(".countContent div").each(function (i) {

            if($(".countContent input:eq("+i+")").attr("checked")==true){
                
                var studentss = $(this).attr("sid")
                var sendGrade_value = $(this).val()

                if (iiii > 0) {
                    sendGrade = sendGrade + ',';
                }

                sendGrade = sendGrade + '{';

                sendGrade = sendGrade + '"strSms":"' + sendGrade_value + '",';

                sendGrade = sendGrade + '"StudentNo":' + studentss;

                sendGrade = sendGrade + '}';

                iiii++;
            }
        })
        

        sendGrade = sendGrade + ']';

        sendGrade_on = eval('(' + sendGrade + ')')

        var Sendexam = {
            SchoolNo: School_No,
            TeacherNo: Teacher_No,
            ExamGroupId: examGroupId,
            SmsExam: sendGrade_on
        };

        var query = {
            request: JSON.stringify(Sendexam)
        };
        // console.log("query:"+JSON.stringify(query))
        $.post(url, query, function (data) {
            console.log("data:"+data)
            if (isNaN(data)) {
                alert("短信发送失败")
                return false;
            } else{
                var result = data;
                alert("温馨提示：短信已发送 " + data + " 条，您发给家长的留言，教师秘书会在24小时内审核并发送给家长，审核完毕会有短信通知您。敬请留意！")
            }
            loading(false);
        });
    } 

    // 拿到excel后让分数出现
    function sendExcel(obj){

        var result = JSON.parse(obj);
        // console.log("result:"+JSON.stringify(result))
        var reError = JSON.stringify(decodeURIComponent(result.error))

        var errorPD = reError.match(/\|[^\|]+\|/)
        var errorName = reError.split("|")

        if(errorPD != null) {
            alert("发现excel表格中含有班级不存在的名字："+errorName)
        }

        each(result,function (index,obj){

            for(var jj=0;jj<obj.length;jj++){
                $("#tab_InputGrade input[subjectid=888888][studentid="+obj[jj].studentID+"]").val(obj[jj].value)
            }

        })
        for(var i=0;i<$("#tab_InputGrade input").length;i++){

            if($("#tab_InputGrade input:eq("+i+")").val().indexOf("为空") >=0){
                // console.log("i:"+i + " value:"+$("#tab_InputGrade input:eq("+i+")").val())
                $("#tab_InputGrade tr:eq("+(i+1)+")").css("background","yellow")
            }
            if($("#tab_InputGrade input:eq("+i+")").val().indexOf("为空") < 0){
                // console.log("i:"+i + " value:"+$("#tab_InputGrade input:eq("+i+")").val())
                $("#tab_InputGrade tr:eq("+(i+1)+")").css("background","white")
            }
            if($("#tab_InputGrade input:eq("+i+")").val() == ""){
                $("#tab_InputGrade tr:eq("+(i+1)+")").css("background","yellow")
            }
        }

        $("#tab_InputGrade input").blur()
    }

    
    // 保存成绩按钮的操作
    function SendSms() {
        if (!checkDatalegal()) return false;
        var url = examSetUrl;

        for(var i=0;i<$("#tab_InputGrade input[type='text']").length;i++){

            if($("#tab_InputGrade input[type='text']:eq("+i+")").val()==""){

                if($("#tab_InputGrade input[type='text']:eq("+i+")").attr("studentid")==$("#tab_InputGrade input[type='text']:eq("+i+")").parent().parent().attr("studentid")){

                    if(confirm($("#tab_InputGrade input[type='text']:eq("+i+")").parent().parent().children("td").html()+"学生存在成绩为空白，是否显示为缺考？")){
                        $("#tab_InputGrade input[type='text']:eq("+i+")").val("缺考")
                    }else{
                        $("#tab_InputGrade input[type='text']:eq("+i+")").css("background","yellow")
                        return false;
                    }
                }
            }else if($("#tab_InputGrade input[type='text']:eq("+i+")").focus()){
                $("#tab_InputGrade input[type='text']:eq("+i+")").css("background","#fff")
            }
        }

        var strCLass = "";
        $("#tab_InputGrade :input[type='text']").each(function (i) {
            var stCLass = $(this).attr("classid")

            strCLass = Number(stCLass);
        })

        var strListDuty = "[";

        var iii = 0;

        var tempListDuty = "";
        var xxxcom = "xxxxxxxx"

        $("#tab_InputGrade :input[type='text']").each(function (i) {

            var strexam = this.value
            var strNo = $(this).attr("studentid")
            var strDuty = $(this).attr("subjectid")

            var strCom = "";

            // console.log("strDuty:"+strDuty +" strpyid:"+strpyid)

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
        
        _exam = {

            list: {
                Name: examModel.Name,
                Date: examModel.ExamDate,
                ID: examGroupId,
                ClassNo: strCLass,
                TeacherNo: Teacher_No,
                SchoolNo: School_No
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
        // _exam.StudentGradeContent = encodeURIComponent(_exam.StudentGradeContent);   //私自注释了
        var query = {
            request: JSON.stringify(_exam)
        };

        // console.log("_exam.exam:"+_exam.exam.length)

        $.post(url, query, function (data) {

            var result = JSON.parse(data);

            alert("保存成功，即将为您跳转到发送短信区域！")

            // window.location.href = string.Format("./grade.aspx?ExamId={0}&sendsms=1", result.examGroupId);

            examGroupId = result.examGroupId;

            saveexam = 1;

            SendAll()

            loading(false);

        })

    }

    //检查考试录入的数据是否正确
    function checkDatalegal() {
        // if ($("._chk:checked").length == 0) {
        //     alert("考试科目不能为空");
        //     return false;
        // }
        if ($(".examClass:checked").length == 0) {
            alert("没有选择考试班级");
            return false;
        }

        if (examModel.Type == 0 && $("#txt_custom").val().Trim() == "") {
            alert("自定义名称不能为空");
            $("#txt_custom")[0].focus();
            return false;
        }
        if($("#txt_examName").val()==""){
            alert("考试名称不能为空");
            return false;
        }
        if ($("#date_ExamDate").val()=="") {
            alert("考试时间不能为空");
            return false;
        }
        return true;
    }

    // 键盘方向键控制input框焦点
    function keyDown(event) { 
        var $input_key = $("#tab_InputGrade input");

        var $gradeTable = $(".DataGrid_Header");

        var rows = $gradeTable.find("td").length-3;

        var focus=document.activeElement; 

        if(!document.getElementById("tab_InputGrade").contains(focus)) return; 

        var event=window.event||event;

        var key=event.keyCode;

        for(var i=0; i<$input_key.length; i++) { 

            if ($input_key[i].type == "text") {
                $(this).focus();
            }
            if($input_key[i]===focus) break; 

        } 

        switch(key) { 
            case 38: 
                if(i-rows>=0){
                    $input_key[i-rows].focus();
                } 
                break; 
            case 40: 
                if(i+rows <$input_key.length){
                    $input_key[i+rows].focus();
                }
            break; 
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
        $("#tab_InputGrade input").click(function (){
            $(this).select()
        })

        $("#excel_tishi").css({"position":"fixed","z-index":"999","line-height":"31px","border-top":"3px solid red","background-color": "#fff","width":"600px","height":"300px","left":"50%","top":"50%","margin-left":"-300px","margin-top":"-200px","color":"#5f7779","display":"none"})
        $("#excel_tishi p ").css({"margin":"13px 20px"})
        $("#excel_tishi a").css({"display": "inline-block","background":"rgb(192,0,0)","-moz-border-radius":" 5px","-webkit-border-radius": "5px","border-radius": "5px","color": "#fcfcfc", "margin-left": "20px","width": "70px", "height": "30px","line-height": "30px", "text-align": "center"})
        $(".daoru2").click(function (){
            $("#closebgg").css("display", "block")
            $("#excel_tishi").css("display", "block")
        })
        $("#excel_tishi_a").click(function (){
            $("#closebgg").css("display", "none")
            $("#excel_tishi").css("display", "none")
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
    // cookie保存发送短信的时间
    function setCookie(sName,sValue,iDay){

        var oDate=new Date();
        oDate.setDate(oDate.getDate()+iDay);
        document.cookie=sName+"="+sValue+"; expires="+oDate;
    }

    function getCookie(sName){
        var sCookie=document.cookie;

        var arr=sCookie.split("; ");

        for (var i=0; i<arr.length; i++){

            var arr2=arr[i].split("=");
            if (arr2[0]==sName){
                return arr2[1];
            }
        }
    }

    function removeCookie(sName){

        setCookie(sName,".",-1);
    }

    $(function (){

        if(getCookie("examgroupId"+examGroupId)){
            $("#ynsend p").css("display","block")
            $("#cookie_time").html(getCookie("examgroupId"+examGroupId))
        }

        $(".yessend").click(function (){
            var aDate = new Date();

            var cookieTime = document.getElementById("cookie_time")

            cookieTime.innerHTML=aDate.getFullYear()+"年"+(aDate.getMonth()+1)+"月"+aDate.getDate()+"日"+aDate.getHours()+"时"+aDate.getMinutes()+"分"+aDate.getSeconds()+"秒";

            setCookie("examgroupId"+examGroupId,cookieTime.innerHTML,24*3600*1000);
        })
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
        jQuery('#pickfiles1 span').text('添加excel格式的文件');
        loading(false)
    }
    $(function (){
        $("#fileName").wrap('<form method="post" action="uploadnew.ashx?option=upload&sno='+School_No+'" id="myForm2"  enctype="multipart/form-data"></form>');
    })

    function loadUpfile(){ 
        var option =
            {
                type: 'post',
                data: { request: JSON.stringify(getssjson()) },
                dataType: 'text', //数据格式为json 
                resetForm: true,
                beforeSubmit: showRequest, //提交前事件
                uploadProgress: uploadProgress, //正在提交的时间
                success: showResponse//上传完毕的事件
            }
        jQuery('#fileName').change(function () {
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
            <div class="con_top">您当前位置：<span>成绩页</span><p class="ceshi1" style="display:inline-block;margin-left:30px;"></p></div>
				<div class="con_msg">
					<span>温馨提示：</span>
					<p>1.填/选完一下选项以及录入完成绩后,你可以点 "发送短信" 把成绩分发到学生家长手机上,也可以点 "保存成绩" ,待以后继续录入或进行成绩分发;</p>
					<p>2.若成绩保存至草稿箱,成绩只有录入人可编辑查看,其他人无法看到,保存草稿后不能再修改班别</p>
					<p>3.有学生未参加本次考试，可在成绩中输入或导入 "缺考" ,不会影响班级平均分及排名。</p>
				</div>

        <table width="98%" border="0" cellspacing="0" cellpadding="3">
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td height="200" valign="top" class="bgbody">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tbTitle3">
                                    <tr>
                                    	<td width="20px"></td>
                                        <td width="97%">
                                            <!--基本信息 begin-->
	
                                            <table style="margin-top: 0px;">
                                                <tr style="display:block;margin-bottom:20px;">
                                                    <td><span class="font_red">* </span></td>
                                                    <td align="left" class="new_left"> 考试日期 </td>
                                                    <td style="position:relative;">
                                                        <div NOWRAP="TRUE" BORDER="0" style="display:inline;border-style:none;">
                                                           <input name="date_ExamDate" type="text" id="date_ExamDate" onchange='javascript: saveexam = 0; return false;' ctrl="text_date_ExamDate" onfocus="this.select();" style="width:90px;padding:4px;border:1px solid #e0e0e0;color:#414141;" onblur="return void NengLong_WebControl_DateInput_OnChange();" />
                                                           <img src='images/datepicker.gif' border='0' style='cursor:pointer;position:absolute;right:40px;top:4px;' width='16' height='16' onclick="NengLong_WebControl_DateInput_PopCalendar(document.getElementById('date_ExamDate') , this);" />
                                                        </div>
                                                            <span controltovalidate="date_ExamDate" errormessage="必填" id="req_ExamData" ctrl="validator_date_ExamDate" evaluationfunction="http://jxpt.jxt189.comRequiredFieldValidatorEvaluateIsValid" initialvalue="" style="color:Red;visibility:hidden;">必填</span>
                                                    </td>
                                                    <td><span class="font_red">&nbsp; </span></td>
                                                    <td align="left" class="new_left" style="width:70px;"> 成绩类型 </td>
                                                    <td>
                                                        <select id="sel_examType" ref="examName"  style="padding:3px;border:1px solid #e0e0e0;color:#414141;">
                                                            <option value="0">自定义</option>
                                                            <option value="1">单元考试</option>
                                                            <option value="2">月考</option>
                                                            <option value="3">期中</option>
                                                            <option value="4">期末</option>
                                                        </select>
                                                        <select id="sel_childType" ref="examName" style="padding:3px;border:1px solid #e0e0e0;color:#414141;">
                                                        </select>
                                                        <input type="text" id="txt_custom" style="display: none" ref="examNameCustom" style="padding:3px;border:1px solid #e0e0e0;" />
                                                        <select id="sel_examType_Hide" style="display: none" style="padding:3px;border:1px solid #e0e0e0;">
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
                                                    <td><span class="font_red">&nbsp; </span></td>
                                                    <td align="left" class="new_left" style="width:45px;"> 学期 </td>
                                                    <td>
                                                        <select id="sel_examTerm" ref="examName" style="padding:3px;border:1px solid #e0e0e0;color:#414141;">
                                                            <option value="1">第一学期</option>
                                                            <option value="2">第二学期</option>
                                                        </select>
                                                    </td>
                                                </tr>
                                                <tr style="display:block;margin-bottom:20px;">
                                                	<td><span class="font_red">* </span></td>
                                                    <td align="left" class="new_left"> 考试名称 </td>
                                                    <td id="td_hover" width="300px">
                                                        <input type="text" id="txt_examName" onchange='javascript: saveexam = 0; return false;' style="width: 460px;padding:4px;border:1px solid #e0e0e0;color:#414141;" />
                                                    </td>
                                                </tr>

                                                
                                                <tr style="display:block;margin-bottom:20px;">
                                                	<td style="vertical-align:top;"><span class="font_red">* </span></td>
                                                    <td align="left" class="new_left" style="vertical-align:top;"> 班&nbsp;&nbsp;级 </td>
                                                    
                                                    <td>
                                                        <table id="table_classes">
                                                        </table>
                                                    </td>
                                                </tr>
                                                
                                                <tr style="display: none;">
                                                    <td>
                                                        <textarea name="txt_Description" rows="5" id="txt_Description" onkeypress="NengLong_WebControls_TextBox_CheckMaxLength(this , 200)" onblur="NengLong_WebControls_TextBox_SetMaxLength(this , 200)" onfocus="NengLong_WebControls_TextBox_SetMaxLength(this , 200)" onmouseover="NengLong_WebControls_TextBox_SetMaxLength(this , 200)" style="width:300px;"></textarea>
                                                    </td>
                                                </tr>

                                            </table>

                                            <!--基本信息 end-->
                                        </td>
                                    </tr>
                                </table>
                                <!-- 手动录入 成绩 begin -->
                                <p style="background:url(images/hr.gif); height:3px; width:99%; margin:0px auto 25px; margin-left:10px;"></p>
                                <div id="daoru">
                                    <div id="attaFilesControl" style="display:inline-block;">
                                        <p id="pickfiles1" onclick="loadUpfile();"><span>上传excel格式文件</span><input type="file" id="fileName" name="fileName" accept=".xlsx, .xls"  /></p>
                                        <a href="javascript:;" class="daoru2">帮助提示？</a>
                                        <div id="excel_tishi">
                                            <p>1、上传的excel附件的后缀为 “<em style="color:red;">xlsx</em>”或 “<em style="color:red;">xls</em>”格式，但必须放在 <em style="color:red;">sheet1</em> 处</p>
                                            <p>2、请按照图片格式在excel文件中填写成绩内容：<br /><img src="images/tishi.png" alt="成绩内容"></p>
                                            <a href="javascript:;" id="excel_tishi_a">确 认</a>
                                        </div>
                                    </div>
                                </div>
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
                                            <table>
                                                <tr>
                                                    <td>
                                                        <label></label>
                                                        <div id="attaFilesControl"><a href="javascript:;" id="pickfiles" class="uploadbtn"></a></div>
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

                    <div id="closebgg"></div>
                    <div id="close_alert">
                    	<div id="sendthis">
                            <a class="closeit"><img src="images/closeit.png" alt="关闭"></a>
	                    	<table width="100%" border="0" cellspacing="0" cellpadding="0" id="countSend" border-collapse="collapse" style="height:70px !important;overflow:hidden;">
		                        <tr class="sendContent">
		                            <td></td>
		                        </tr>
		                    </table>
                            <div class="countContent">
                            </div>
		                     <span class="sendspan"></span>
	                    </div>
                        <div id="yn_send">
                            <div id="ynsend">
                                <a onclick="pushToServer(true)" href="gradelist.aspx" class="yessend">确定发送</a><a class="nosend">取消</a>
                                <p id="cookie_p" style="display:none;color:#c2172a;margin-top:15px;">您已在<span id="cookie_time" style="font-weight:bold;"></span>时发送了短信</p>
                            </div>
                        </div>
                    </div>
                </td>
            </tr>
        </table>
    		<script type="text/javascript">
    		<!--
    		    var Page_Validators = new Array(document.getElementById("req_ExamData"));
    		// -->
    		</script>

    		<script type="text/javascript">
    		<!--

    		    var Page_ValidationActive = false;
    		    if (typeof (ValidatorOnLoad) == "function") {
    		        ValidatorOnLoad();
    		    }

    		    function ValidatorOnSubmit() {
    		        if (Page_ValidationActive) {
    		            return ValidatorCommonOnSubmit();
    		        }
    		        else {
    		            return true;
    		        }
    		    }
    		</script>

        	<div id="shadowDiv" style="display: none">
                <img src="images/loading2.gif" />
            </div>
            </td>
        </tr>
    </table>
	<div class="con_click">
		<a onclick="SendSms();" href="javascript:;" id="savetodraft" class="con_click_one">保存成绩</a><a onclick="SendAll()" href="javascript:;" class="con_click_two">发送短信</a>
	</div>

		</div>
	</div>

    <uc2:ucFoot ID="ucFoot1" runat="server" />
</div>
</form>
</body>
</html>