<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="grade.aspx.cs" Inherits="nwChengji.grade" %>


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
    var examGetUrl = "http://cj.gcihjt.com/action.ashx?cmd=ExamGet";
    // 获取学生成绩url
    var examDetailGetUrl = "http://cj.gcihjt.com/action.ashx?cmd=StudentDetailGet";
    //设置考试
    var examSetUrl = "http://cj.gcihjt.com/action.ashx?cmd=ExamSet";
    //发送短信
    var examSend = "http://cj.gcihjt.com/action.ashx?cmd=ExamSend";
    // 添加科目
    var examAddSubjectUrl = "http://cj.gcihjt.com/action.ashx?cmd=SubjectAdd";

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

        // console.log("getExamData->query: " + JSON.stringify(query))
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
        
        initSubjects();  //正确
        initBase();      //正确
    }
    //<label for='_chk" + index + "' >" + obj.SubjectName / ?? + "</label>
    onload.push(function () {
        $("#chk_isUseIdentyCode").change(function () {
            isIdenty = this.checked;
            loadTable();
        });
    });

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
            // $tr.css({ "border": "1px solid #e0e0e0", "border-bottom": "1px dotted #e0e0e0", "border-top": "1px dotted #e0e0e0" });
            $tr.css({ "border-left": "2px solid #e0e0e0","width":"189px","border-bottom":"2px dotted #e0e0e0","overflow":"hidden" });
            var examType = Number(obj.ExamImportType);
            obj.IsIncludeExam = false;

            // 限制科目名称长度
            if(obj.SubjectName.length>9){
                obj.SubjectName=obj.SubjectName.substring(0,9)+".."
            }
            var str = "<td style='width:180px;'><input type='checkbox' class='_chk'  " + (obj.IsIncludeExam ? "checked" : "") + " value='"+obj.SubjectName+"' /> " + obj.SubjectName + "</td><td style='display:none;'><input type='checkbox' id='chk_mark' value='1' class='_chkType'    " +
                    ((obj.IsIncludeExam && obj.ExamImportType == 0) || (obj.IsIncludeExam & examType == 1) || (obj.IsIncludeExam & examType == 3) || (obj.IsIncludeExam & examType == 5) || (obj.IsIncludeExam & examType == 7) ? "checked='checked'" : "") + " />"
                + "分数<input type='checkbox' class='_chkType' id='chk_level'  " + (examType == 2 || examType == 3 || examType == 6 || examType == 7 ? "checked='checked'" : "") + "  value='2' /> " +
                "等级 <input type='checkbox' class='_chkType' id='chk_order'  " + (examType == 4 || examType == 5 || examType == 6 || examType == 7 ? "checked='checked'" : "") + "  value='4'/>排名</td><td  style='display:none;'> <input type='checkbox' class='_chkCount'  " + (obj.IsCount ? "checked" : "") + "/>计入总分" + (!obj.IsLock ? " &nbsp; <a style='cursor:pointer'   class='btn_removeSubject' > 删除</a>" : "") + "</td>";
            $tr.append(str);
            $table.append($tr);
            if (obj.IsIncludeExam && obj.ExamImportType == 0) {
                obj.ExamImportType = 1;
            }
        });
        //选择考试范围   多少科目
        $("._chk").live("click", function () {
            // if ($("._chk:checked").length == 0) {
            //     alert("至少要有一科考试科目");
            //     return false;
            // }

            var _chk = $(this).attr("checked");

            var $tr = $(this).parent().parent();
            var subjectid = $tr.attr("subjectid");
            $tr.find("._chkCount").attr("checked", _chk ? "checked" : "");
            var subject = examModel.Subjects.Find(function (obj) { return obj.SubjectId == subjectid });
            subject.IsIncludeExam = _chk;
            subject.IsCount = _chk;
            subject.ExamImportType = 0;
            $($tr).find("td").eq(1).children().each(function () {
                if ($(this).attr("checked") == true) {
                    subject.ExamImportType += Number($(this).attr("value"));
                }
            });
            if (subject.ExamImportType == 0) {
                $($tr).find("td").eq(1).children().each(function () {
                    if ($(this).val() == "1") {
                        $(this).attr("checked", "checked");
                        subject.ExamImportType = 1;
                        allDuty = allDuty + subjectid + ","
                    }
                });
            }
            if (!_chk) {
                $($tr).find("td").eq(1).children().each(function () {
                    $(this).attr("checked", "");
                    allDuty = allDuty.replace(","+subjectid+",",",")
                });
                subject.ExamImportType = 0;
            }
            loadExam();
        });

        if(examGroupId!=0){
            examModel.exam.Each(function (obj) {
                $(".gradeSubjects tr[subjectid=" + obj.DutyNo + "]").find("._chk").click()
                if(examModel.exam.Comment!=0){
                    $(".gradeSubjects tr:last-child").find("._chk").click()
                    $(".gradeSubjects tr:last-child").find("._chk").attr("checked",true)
                }
                if ($(".gradeSubjects tr[subjectid=" + obj.DutyNo + "]").find("._chk").attr("checked", "checked")) {
                    // loadTable()
                }
            })

        }

        //科目添加
        $("#btn_saveUserSubject").unbind("click").bind("click", function () {
            var name = $("#txt_AddSubjectName").val();
            for(var k=1;k<$(".gradeSubjects tr").length;k++){
                if(name == $(".gradeSubjects tr:eq("+(k+1)+") input").attr("value")){
                
                    // console.log( "name" +name+ " k:"+k + " length:"+$(".gradeSubjects tr:eq("+(k+1)+") input").attr("value"))
                    $(".gradeSubjects tr:eq("+(k+1)+")").find("._chk").attr("checked","checked")
                    $(".gradeSubjects tr:eq("+(k+1)+")").find("._chk").click()
                    $(".gradeSubjects tr:eq("+(k+1)+")").find("._chk").attr("checked","checked")
                    console.log("checked:"+$(".gradeSubjects tr:eq("+(k+1)+")").find("._chk").attr("checked"))
                    return false;
                }

            }
            if (!name.Trim()) {
                return alert("请输入要添加的科目");
            }
            var url = examAddSubjectUrl;
            var query = {
                request: JSON.stringify({
                    SubjectName: name
                })
            };
            // console.log("SubjectName:"+JSON.stringify(query))
            $.post(url, query, function (data) {
                // console.log("data:"+data)
                
                var result = JSON.parse(data);
                if (result.Success) {
                    examModel.Subjects.push({
                        SubjectName: name,
                        FullMark: "100",
                        SubjectId: result.ResultId,
                        ExamImportType:0,
                        IsIncludeExam: false,
                        IsCount: "true",
                        SubjectType: "1",
                        IsLock: "true"
                        
                    });
                    // console.log("examModel.Subjects:"+JSON.stringify(examModel.Subjects))
                    var $tr = $($table[0].insertRow());
                    $tr.attr("subjectid", result.ResultId);
                    $tr.css({ "border-left": "2px solid #e0e0e0","width":"189px","border-bottom":"2px dotted #e0e0e0","overflow":"hidden" });
                    var str = "<td style='width:180px;'><input type='checkbox' class='_chk chkCheck' value='"+name+"' checked='checked' /> " + name + "</td><td style='display:none;'><input type='checkbox' id='chk_mark' value='1' />分数 <input type='checkbox' id='chk_level' value='2' />等级 <input type='checkbox' id='chk_order' value='4'/>排名</td><td style='display:none;'><input type='checkbox' class='_chkCount' checked  />计入总分</td>";
                    $tr.append(str);
                    $table.append($tr);
                    $(".chkCheck").click()
                    $(".chkCheck").attr("checked","checked")
                } else {
                    alert(result.Tip);
                }
                // window.location.reload();
            });
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
        // console.log("examModel.Name:"+examModel.Name)
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
            console.log("examModel.list:"+examModel.list)
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
        // each(allSubject,function (index,obj){
        //     console.log("index:"+index + "obj:"+obj.SubjectName + " obj.id:"+obj.SubjectId)
        // })

        examModel.Subjects = allSubject

        // console.log("examModel.Subjects888888:"+JSON.stringify(examModel.Subjects))

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
        // alert(body)
        var $table = $("#tab_InputGrade");
        $("tr", $table).remove();
        $table.append(header);
        // $(".ceshi1").append(" ---each(body, function (index, obj) {---")
        each(body, function (index, obj) {
            $table.append(obj);

        });
        initStaticInfo($table);
        initStudentGradeTable();
        if (errList.length > 0) {
            $("#tab_InputGrade").append("<tr><td width='20px'></td><td colspan='7'><font style='color:red'>使用导入后姓名后带*的表示没有匹配成功,成绩为\"0\"需要手动添加。</font></td></tr>");
        }
    }

    // 修改考试名称后提示
    function duibimingzi(){
        if(examGroupId !=0){
            var inputName = document.getElementById("txt_examName").value;
            if(inputName == document.getElementById("txt_examName").value){
                alert("考试名称已修改，请记得保存成绩后再发送短信")
                return false;
            }
        }
    }
    // 修改日期后提示
    function duibiriqi(){
        if(examGroupId !=0){
            var inputDate = document.getElementById("date_ExamDate").value;
            if(inputDate == document.getElementById("date_ExamDate").value){
                alert("考试时间已修改，请记得保存成绩后再发送短信")
                return false;
            }
        }
    }



    // function duibi(){
    //     for (var i = 0; i < examModel.exam.length; i++) {
    //         if(examModel.exam[i].Value!=document.getElementById("tab_InputGrade").getElementsByTagName("input")[i].value){
    //             console.log("examModel.exam[i].Value:"+examModel.exam[i].Value)
    //             console.log("document:"+document.getElementById("tab_InputGrade").getElementsByTagName("input")[i].value)
    //             alert("修改成绩后，请先保存成绩后再发送短信")
    //             return false;
    //         }
    //     }
    //     return true;
    // }

    // 发送短信
    function SendAll() {

        if(examGroupId == 0) { 
            alert("请先保存成绩后再发送短信")
            return false;
        }else if(examGroupId !=0){
            // “立即发送”显示---table布局，所以要用table
            // if(!duibi()) return false;
            

            $(".count_send").css({ "display": "table" })

            var $table_send = $(".countContent");

            var bodySend = getGradeSend();
            console.log("examGroupId:"+examGroupId+" sendsms:"+sendsms)
            each(bodySend, function (index, _obj) {
                $table_send.append(_obj)
            })

            var $table_getSubCount = $(".sendContent td")

            var resultOne = examModel.Subjects.FindAll(function (ob) { return ob.IsIncludeExam }).ConvertAll(function (ob) { return "&nbsp;&nbsp;&nbsp;<input type='checkbox' name='" + ob.SubjectName + "' class='findsub' " + (ob.IsIncludeExam ? "checked" : "") + " /> " + ob.SubjectName + "&nbsp;&nbsp;&nbsp;"; }).join("\t");

            $table_getSubCount.html("<input type='checkbox' id='allselect' name='全选' checked/>学生&nbsp;&nbsp;&nbsp;&nbsp;<span>请选择发送科目: </span>&nbsp;" + resultOne + "\t" + "")
            
            // 发送短信区域上方的input按钮
            for(var i =1;i<$(".sendContent input").length;i++){
                
                $(".sendContent input").eq(0).click(function (){
                    $(".countContent tr input[name='allsel']").attr("checked",this.checked)
                })
                $(".sendContent input").eq(i).click(function (){
                    var coninput = "|";
                    for(var i=0;i<=$(".sendContent input").length;i++){

                        if($(".sendContent input").eq(i).attr("checked")==true){

                            coninput = coninput + $(".sendContent input").eq(i).attr("name") + "|";
                        }
                    }

                    each(examModel.ClassGrades, function (index, obj) {
                        var stus = obj.Students;

                        var classid = obj.ClassId;

                        if (classid > 0) {

                            var className = examModel.Classes.Find(function (obj) { return obj.ClassId == classid }).ClassName;

                            each(stus, function (_index, student) {
                                // console.log("student:"+student.Sid + " coninput:"+coninput)

                                var strallsms = zuhesms(student, coninput);

                                // console.log("strallsms:"+strallsms)
                               
                                gradeSend = $("<td><textarea class='gradeTxt' cols='100' sid='" + student.Sid + "' style='border:1px solid #e0e0e0;resize:none;font-size:13px;' rows='1'>" + $("#txt_examName").val() + "，" + student.Name + "同学" + strallsms + "</textarea></td>");
                                
                                for (var i = 0; i < $(".countContent tr").length; i++) {
                                     // console.log("examModel.exam[i].StudentNo :"+$(".countContent tr:eq("+i+")").attr("studentid") + " student.Sid:"+student.Sid)
                                     // $(".countContent textarea[sid=" + examModel.exam[i].StudentNo + "]").val(gradeSend.text())

                                    if ($(".countContent tr:eq("+i+")").attr("studentid") == student.Sid) {

                                        $(".countContent textarea[sid=" + $(".countContent tr:eq("+i+")").attr("studentid") + "]").val(gradeSend.text())

                                    }
                                }
                            });
                        }
                    })
                    
                })
            }
            $(".sendContent input").eq(0).click();
            $(".sendContent input").eq(0).attr("checked",true);
            $(".sendContent input:last-child").attr("disabled",true)
            $("#close_alert").css("display", "block");
            $("#closebgg").css("display", "block")
        }
    }


    // 组合短信方法
    function zuhesms(student, subtxt)
    {
        var strsms = ""; //分数

        // console.log("subtxt:"+subtxt)
        // var strAll = ""; //总分
        // console.log("exam.length:"+examModel.exam.length)
        var sttrcom1 = "";
        for (var j = 0; j < _exam.exam.length; j++) {
            console.log("_exam.exam="+_exam.exam[j].DutyNo)
            if (student.Sid == _exam.exam[j].StudentNo) {
                var strValue = _exam.exam[j].Value;

                var strSubjectName = getSubjectName(_exam.exam[j].DutyNo);
                sttrcom1 ="，" + _exam.exam[j].Comment;
                if(subtxt == "sms" || subtxt.indexOf("|" + strSubjectName + "|") >= 0)
                {
                     strsms = strsms +"，"+ strSubjectName + strValue ; 
                }
            }

        };

        strsms = strsms + sttrcom1;

        return strsms;
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

        var trStr = "<tr studentid='{0}' classid='{6}' style='text-align:center;'><td width='5px'><input type='checkbox' name='allsel' style='vertical-align:bottom;margin-bottom:2px;' checked='checked'/></td><td style='width:90px;white-space:nowrap;' class='headerName'>&nbsp;{4}&nbsp;</td><td width='100' style='white-space:nowrap;'>&nbsp;{3}&nbsp;</td></tr>";
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

        console.log("_exam111:"+JSON.stringify(_exam.exam))
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
                    console.log("length:"+JSON.stringify(examModel))
                    for (var j = 0; j < _exam.exam.length; j++) {
                    
                        if (student.Sid == _exam.exam[j].StudentNo) {
                            strcomment = _exam.exam[j].Comment
                            var strValue = _exam.exam[j].Value;
                            var strSubjectName = getSubjectName(_exam.exam[j].DutyNo);

                            strsms =  strsms + strSubjectName + strValue +"，" ;
                        }

                    };
                    if (strcomment.length > 0)
                    {
                        strsms = strsms + strcomment 
                    }
                    var gradeSend = $("<td><textarea class='gradeTxt' cols='100' sid='" + student.Sid + "' style='border:1px solid #e0e0e0;resize:none;font-size:13px;' rows='1'>" + $("#txt_examName").val() + "，" + student.Name + "同学，" + strsms + "</textarea></td>");

                    $tr.append(gradeSend);

                    result.push($tr);
                });
            }

        });

        return result;
    }

    // 平均分跟总分
    function initStaticInfo($table) {

        var arr = [];

        var tdHTML = "<td></td>";
        $("#tab_InputGrade [studentid]").each(function () {

            var tds = $(this).children();

            tds.each(function () {

                if ($(this).children().size() > 0 && $(this).children().attr("importtype") == "mark") {
                    var idx = $(this).index();

                    if (!arr.Exists(function (obj) { return obj == idx })) {
                        arr.push(idx);
                    }
                }
            });

        });

        var sum = 0, number = 0, avg = 0;

        for (var i = 0; i < arr.length; i++) {

            if (i == 0) {

                var trs = $("#tab_InputGrade [studentid]");
                trs.each(function () {
                    var td = $(this).children("td").eq(arr[i]);
                    if ($(td).children().size() > 0 && $(td).children().attr("importtype") == "mark") {
                        var t = 0;
                        if ($(td).children().val() != "缺考")
                            t = Number($(td).children().val());
                        sum += t;
                        number++;
                    }
                });
                avg = sum / number;
                tdHTML += "<td style='width:70px;'>平均分:<label _avg='" + (arr[i]) + "'>" + avg.toFixed(2) + "</label>" +
                        "</br>  总分:<label _sum='" + ((arr[i])) + "'>" + sum.toFixed(2) + "</label></td>"
                sum = 0;
                avg = 0;
                number = 0;

            }
            else {
                var tdCols = (arr[i] - arr[i - 1]) - 1;
                for (var k = 0; k < tdCols; k++) {
                    tdHTML += "<td></td>";
                }
                var trs = $("#tab_InputGrade [studentid]");
                trs.each(function () {
                    var td = $(this).children("td").eq(arr[i]);
                    if ($(td).children().size() > 0 && $(td).children().attr("importtype") == "mark") {
                        var t = 0;
                        if ($(td).children().val() != "缺考")
                            t = Number($(td).children().val());
                        sum += t;
                        number++;
                    }
                });
                avg = sum / number;
                tdHTML += "<td style='width:70px;'>平均分:<label _avg='" + (arr[i]) + "'>" + avg.toFixed(2) + "</label>" +
                        "</br>总分:<label _sum='" + ((arr[i])) + "'>" + sum.toFixed(2) + "</label></td>"
                sum = 0;
                avg = 0;
                number = 0;

            }
        }
        var $td = $("<tr><td>学生人数："+eval($("#tab_InputGrade tr").length-1)+"</td>" + tdHTML + "</tr>")
        $td.appendTo($table);
    }

    var strpy = "|评语|个人评语|个评|";
    var strpyid = 0;

    // 拿到头部列表
    function getSubjectHeader() {
        var $tr = $("<tr class='DataGrid_Header'><td width='50px' class='headerName'>姓名</td><td width='80'>班级</td><td width='100px' style='display:none;' class='headerSum'>总分</td></tr>");
        // <td width='50'>编号</td>
        var $hName = $(".headerSum", $tr);
        var importheader = "姓名" + "\t";
        var i = 0;

        

        // each(allSubject, function (index, obj) {
        //     console.log("allSubject obj:"+index)
        //     console.log("allSubject obj.SubjectId:"+obj.SubjectId)
        // })

        each(examModel.Subjects, function (index, obj) {
            if (obj.IsIncludeExam) {
                var sid = obj.SubjectId;
                var unit = getSubjectHeaderUnit(sid, i++);
                var tempSubject = examModel.Subjects.Find(function (obj) { return obj.SubjectId == sid });
                // console.log("tempSubject:"+tempSubject)

                // each(tempSubject,function (_obj,_index){
                //     console.log("_index:"+_index)
                // })

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
                if (unitLevel != '') {
                    $hName.before(unitLevel);
                    importheader = (importheader + string.Format("{0}(等级)", obj.SubjectName) + '\t'); // obj.SubjectName
                }
                if (unitOrder != '') {
                    $hName.before(unitOrder);
                    importheader = (importheader + string.Format("{0}(排名)", obj.SubjectName) + '\t'); // obj.SubjectName
                }
            }
        });
        // importheader = (importheader + (isIdenty ? "评语\t学号\t家长手机\n" : "评语\n"));
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

        var trStr = "<tr studentid='{0}' classid='{6}' style='border-bottom:1px dotted #c9d1d1;'><td width='60px' class='headerName sendName'>{4}</td><td width='50'>{3}</td><td width='100px' style='display:none;' class='headerSum'>{5}</td></tr>";
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
                            // console.log("student.Grade.subid:"+gradeItem.SubjectId + " student.Grade.name:" +gradeItem.SubjectName)
                            // console.log("gradeItem:"+JSON.stringify(gradeItem))
                            var maxMark = 0;
                            // examModel.Subjects.Find(function (obj) { return obj.SubjectId == gradeItem.SubjectId }).FullMark
                            // console.log(" gradeItem.SubjectId:"+gradeItem.SubjectId)
                            switch (gradeItem.ImportType) {
                                case 1:
                                    var grade = $("<td><input importType='mark' onclick='select()'  classid='" + classid + "' subjectid='" + gradeItem.SubjectId + "' studentid='" + student.Sid + "' max='" + maxMark + "' type='text' index='" + _index + "' cols='" + (temp + 2) + "' rows='" + i + "' style='width:30px;padding:4px;border:1px solid #d0d0d0; color:#666666; ' value='' /></td>");
                                    if(gradeItem.SubjectId==strpyid){
                                        // console.log("strpyid:"+strpyid + " gradeItem.SubjectId:"+gradeItem.SubjectId)
                                        grade = $("<td><input importType='mark' onclick='select()'  classid='" + classid + "' subjectid='" + gradeItem.SubjectId + "' studentid='" + student.Sid + "' max='" + maxMark + "' type='text' index='" + _index + "' cols='" + (temp + 2) + "' rows='" + i + "' style='width:100px;padding:4px;border:1px solid #d0d0d0; color:#666666; ' value='' /></td>");
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
                $("#tab_InputGrade input[subjectid=" + examModel.exam[i].DutyNo + "][studentid=" + examModel.exam[i].StudentNo + "]").val(examModel.exam[i].Value)

            };
            for(var j=1; j<$("#tab_InputGrade tr").length-1;j++){
                // console.log("j:"+j)
                for (var k = 0; k < examModel.exam.length; k++) {

                    // console.log("studentid:"+$("#tab_InputGrade tr:eq("+j+") td:eq("+($("#tab_InputGrade tr:eq("+j+") td").length-2)+")").find("input").attr("studentid")+ " examModel.exam[k].StudentNo:"+examModel.exam[k].StudentNo)
                    // console.log("subjectid:"+$("#tab_InputGrade tr:eq("+j+") td:eq("+($("#tab_InputGrade tr:eq("+j+") td").length-2)+")").find("input").attr("subjectid")+ " strpyid:"+strpyid)

                    if($("#tab_InputGrade tr:eq("+j+") td:eq("+($("#tab_InputGrade tr:eq("+j+") td").length-2)+")").find("input").attr("subjectid")==strpyid && $("#tab_InputGrade tr:eq("+j+") td:eq("+($("#tab_InputGrade tr:eq("+j+") td").length-2)+")").find("input").attr("studentid")==examModel.exam[k].StudentNo){

                        $("#tab_InputGrade tr:eq("+j+") td:eq("+($("#tab_InputGrade tr:eq("+j+") td").length-2)+")").find("input").val(examModel.exam[k].Comment)
                    }
                }
            }
        }
  


        inputs.unbind("focus").bind("focus", function () {
            if ($(this).attr("importtype") == "mark") {
                if (this.value == "0") this.value = "";

                var cols = this.getAttribute("cols");
                var rows = this.getAttribute("rows");
                currentCol = parseInt(cols);
                currentLine = parseInt(rows);
            }

        });


        inputs.unbind("blur").bind("blur", function () {
            var val = this.value;
            if ($(this).attr("importtype") == "mark") {
                var $tr = $(this).parent().parent();
                var classid = $tr.attr("classid");
                var studentid = $tr.attr("studentid");
                var index = parseInt(this.getAttribute("index"));
                var max = $(this).attr("max");
                var re = /[\u4e00-\u9fa5]/;
                // console.log("value:"+re.test(val))
                if (val == "缺考") {
                    this.value = "缺考";
                } else if (re.test(val)){
                    this.value = val;
                }
                // else {
                //     if (isNaN(this.value)) 
                //     {
                //         alert('输入不正确，若学生没参加考试，请填写‘缺考’');
                //         $(this).val("0");
                //     }
                //     else {
                //         // if (Number(this.value) > max) this.value = max;
                //         if (Number(this.value) < 0 || this.value == "") this.value = 0;
                //     }
                // }

                var sum = getSum(this);
                var number = 0;
                var avg = 0;
                // if (isNaN(sum)) return;
                $(".headerSum", $tr).text(sum);
                sum = 0;
                var idx = $(this).parent().index();
                var trs = $("#tab_InputGrade tr");
                trs.each(function () {
                    var td = $(this).children("td").eq(idx);
                    if ($(td).children().size() > 0 && $(td).children().attr("importtype") == "mark") {
                        var t = 0;
                        var reg=/[\u4e00-\u9fa5]/;
                        if (reg.test($(td).children().val())==false)
                            t = Number($(td).children().val());
                        sum += t;
                        number++;
                    }
                });
                avg = sum / number;
                if (isNaN(avg)) avg = 0;
                avg = (avg).toFixed(2);
                $("label[_avg=" + idx + "]").text(avg.toString());
                $("label[_sum=" + idx + "]").text(sum.toString());
            } else if ($(this).attr("importtype") == "order") {
                if (val == "缺考") {
                    this.value = "缺考";
                } else {
                    var m = 0;
                    examModel.ClassGrades.Each(function (o) { m += o.Students.length; });
                    if (val == "" || !parseFloat(val)) {
                        this.value = 0;

                    }

                    //if (Number(this.value) > m) this.value = m;
                    if (Number(this.value) < 0 || this.value == "") this.value = 0;
                }

            } else if ($(this).attr("importtype") == "level") {
                if (this.value == "" || Number(this.value) < 0) {
                    this.value = 0;
                }
            }

        });

        inputs.blur()

        loading(false);

    }

    // 拿到总分
    function getSum(input) {
        var result = 0;
        var temp = 0;
        var $tr = $(input).parent().parent();
        var reg = /[\u4e00-\u9fa5]/;
        var inputs = $("input", $tr).each(function (index, obj) {
            if ($(obj).attr("importType") == "mark") {
                if (obj.value == "缺考")
                    temp = 0;
                else
                    temp = parseFloat(obj.value);
                var index = $(obj).parent().index()
                var sub = $(".DataGrid_Header").children("td").eq(index);

                if (sub.attr("iscount") == "true" || sub.size() == 0)
                    if (!isNaN(temp)) result += temp;
                //result += parseInt(obj.value);
            }
        });

        return result;
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

        $(".countContent textarea").each(function (i) {

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

        // if (!_exam.ExcelName && !_exam.StudentGradeContent) {
        //     return;
        // }
        // if (_exam.StudentGradeContent === false) {
        //     return;
        // }

        // loading(true);   //已私自注释

        // console.log("query:"+JSON.stringify(query))

        $.post(url, query, function (data) {
            // console.log("data:"+data)
            if (isNaN(data)) {
                alert("短信发送失败")
                return false;
            } else{
                var result = data;
                alert("温馨提示：短信已发送 " + data + " 条，您发给家长的留言，教师秘书会在24小时内审核并发送给家长，审核完毕会有短信通知您。敬请留意！")
            }
            loading(false);

            //下面内容私自注释了
            // if (result.ResultState != 1) {
            //     var err = JSON.parse(result.Msg);
            //     return alert(err[0].Message);
            // }


            if (result.Success) {

                if (isSms) {
                    // 点击下一步时触发
                    window.location.href = string.Format("./ExamModiStepSendSms.aspx?examgroupId={0}", result.examGroupId);
                }
                else if ($("#tag3").is(":visible")) {
                    var url = string.Format("./ExamSet.aspx?examgroupId={0}", result.examGroupId);
                    window.location.href = url;
                }
                else {
                    // 点击完成时触发
                    window.opener.location.href = window.opener.location.href;
                    window.opener = null
                    window.open("", "_self")
                    window.close();
                }
            } else {
                if ($("#tag3").is(":visible") && result.ErrorMsg && result.ErrorMsg.split("\t").length > 1) {
                    var url = string.Format("./ExamSet.aspx?examgroupId={0}", result.ExamGroupId);   //  /index.html替换了./ExamSet.aspx?examgroupId=0
                    // var url = string.Format("./ExamSet.aspx?examgroupId={0}", ExamGroup_Id); 
                    var errStr = getErrMsg(result.ErrorMsg);
                    if (errStr) {
                        url += "&err=" + errStr;
                        alert("班上存在同名:[" + errStr + "]!");
                    }
                    window.location.href = url;

                    return;
                }
                if (!result.ErrorMsg) {
                    //弹出undefined的地方
                    // alert(result.Tip);

                    return;
                }
                if (!result.ErrorMsg || result.ErrorMsg.split("\t").length == 1) {

                    // alert(result.Tip);
                }
                showTag2();
                if (result.ErrorMsg.split("\t").length > 1) {
                    $("#txt_Content").val(result.ErrorMsg);
                    if (result.ErrorMsg.indexOf("班上存在同名,请手动删除或继续操作") > -1) {
                        if (confirm("班上存在同名，点击“取消”则手动删除或用学号家长号码加以区分，点击“确定”继续导入同名成绩将默认为“0”！")) {
                            pushToServer(isSms, "ignore");
                        }

                    } else if (confirm("部分用户不存在于目标班级或格式错误，点击“确定”继续导入，点击“取消”返回修正")) {
                        $("#txt_Content").val(result.ErrorMsg);
                        pushToServer(isSms, "ignore");
                    }
                }
            }
        });
    } 

    // 拿到excel后让分数出现
    function sendExcel(obj){

        var result = JSON.parse(obj);

        var reError = JSON.stringify(result.error)
        var errorName = reError.match(/\|[^\|]+\|/)

        if(errorName != null) {
            alert("发现excel表格中含有班级不存在的名字："+errorName)
        }

        each(result,function (index,obj){

            for(var jj=0;jj<obj.length;jj++){
                $("#tab_InputGrade input[subjectid="+obj[jj].subjectID+"][studentid="+obj[jj].studentID+"]").val(obj[jj].value)
            }

        })

        $("#tab_InputGrade input").blur()
    }

    function replaceAll(str, find, replace) {
        return str.replace(new RegExp(find, 'g'), replace);
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

            // console.log("_exam:"+JSON.stringify(_exam.exam))
            examGroupId = result.examGroupId;

            sendsms = 1;

            SendAll()

            loading(false);

        })

    }

    function getErrMsg(msg) {
        var list = msg.split("\n");
        var result = "";
        var arr = [];
        for (var i = 0; i < list.length; i++) {
            var item = list[i];
            if (item.indexOf("存在同名") > -1 || item.indexOf("数据格式") > -1) {
                arr.push(item.split('\t')[0]);
            }
        }
        return arr.join(",");
    }

    //检查考试录入的数据是否正确
    function checkDatalegal() {
        if ($("._chk:checked").length == 0) {
            alert("考试科目不能为空");
            return false;
        }
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


    function showTag1() {
        $('#tag2').hide();
        $('#tag1').show();
        $('#tag3').hide();
    }
    function showTag2() {
        $('#tag1').hide();
        $('#tag2').show();
        $('#tag3').hide();
    }

    function showTag3() {
        $('#tag1').hide();
        $('#tag2').hide();
        $('#tag3').show();
    }

    function getExcelName() {
        var len = $("#ExcelNameList li a").length;
        if (len > 0) {
            return $("#ExcelNameList li a").first().attr("newflename");
        }
        return "";
    }

    var currentLine = 1;
    var currentCol = 1;
    var $preinput;


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
            case 37: 
                if(i>0) {
                    $input_key[i-1].focus();
                }; 
                break; 
            case 38: 
                if(i-rows>=0){
                    $input_key[i-rows].focus();
                } 
                break; 
            case 39: 
                if(i<$input_key.length-1){
                    $input_key[i+1].focus(); 
                }
                break; 
            case 40: 
                if(i+rows <$input_key.length){
                    $input_key[i+rows].focus();
                }
            break; 
        } 
       
    } 
    function inputFocusin(obj) {
        var $this = $(obj);
        $this.attr("old", $this.val());
        $preinput = $this;
        if ($this.val() == "0") {
            $this.val("");
        }
    }
    //文本框失去焦点 计算总分
    function inputFocusout(obj) {
        var $this = $(obj);
        var isDefault = (arguments[1] != undefined && arguments[1]);
        $this.blur();
    }
    /***
    *功能：隐藏和显示div  
    *参数divDisplay：html标签id  
    ***/
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
        var inputContent = document.getElementById("shengluohao").getElementsByTagName("input")
        for(var p=0;p<inputContent.length;p++){
            alert("inputContent:"+inputContent[i].innerHTML.length);
        }

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
        // console.log("document.cookie:"+document.cookie)
        // console.log("getCookie:"+getCookie("examgroupId"+examGroupId))
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

        // 科目
        var subli = '[';
        var gg=0;
        examModel.Subjects.Each(function (obj) {
            if(gg>0){
                subli = subli + ',';
            }
            subli = subli + '{';

            subli = subli + '"subName":"'+obj.SubjectName+'",';

            subli = subli + '"subId":'+obj.SubjectId;

            subli = subli + '}';
            gg++;
        })
        subli = subli + ']';

        subli_on = eval('(' + subli + ')')

        var myssjson = {
            stuList: stuli_on,
            subList: subli_on
        }

        return myssjson;

    }
            
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
        jQuery('#fileName').wrap(
            '<form method="post" action="upload.ashx?option=upload" id="myForm2"  enctype="multipart/form-data"></form>');
        jQuery('#fileName').change(function () {
            $('#myForm2').ajaxSubmit(option);
        });
    }


    //上传中 
    var uploadProgress = function (event, position, total, percentComplete) {
        jQuery('#pickfiles1 span').text('请检查名字是否出错');
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
        jQuery('#pickfiles1 span').text('添加xlsx格式的文件');
        loading(false)
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
                                                <tr style="display:block;margin-bottom:20px;">
                                                    <td><span class="font_red">* </span></td>
                                                    <td align="left" class="new_left"> 考试日期 </td>
                                                    <!-- onchange="duibiriqi()" -->
                                                    <td style="position:relative;">
                                                        <div NOWRAP="TRUE" BORDER="0" style="display:inline;border-style:none;">
                                                           <input name="date_ExamDate" type="text" id="date_ExamDate" onchange="duibiriqi();" ctrl="text_date_ExamDate" onfocus="this.select();" style="width:90px;padding:4px;border:1px solid #e0e0e0;color:#414141;" onblur="return void NengLong_WebControl_DateInput_OnChange();" />
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
                                                        <input type="text" id="txt_examName" onchange="duibimingzi();" style="width: 460px;padding:4px;border:1px solid #e0e0e0;color:#414141;" />
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
                                                    <td align="right">备&nbsp;&nbsp;&nbsp;&nbsp;注：</td>
                                                    <td>&nbsp;</td>
                                                    <td>
                                                        <textarea name="txt_Description" rows="5" id="txt_Description" onkeypress="NengLong_WebControls_TextBox_CheckMaxLength(this , 200)" onblur="NengLong_WebControls_TextBox_SetMaxLength(this , 200)" onfocus="NengLong_WebControls_TextBox_SetMaxLength(this , 200)" onmouseover="NengLong_WebControls_TextBox_SetMaxLength(this , 200)" style="width:300px;"></textarea>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <p style="margin-bottom:15px;"><span class="font_red" style="display:inline-block;line-height:31px;vertical-align:middle;">* </span>考试科目&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                        <input type="text" width="100px" id="txt_AddSubjectName" value="自定义添加科目" style="color:#666666;" onclick="select();" /><a id="btn_saveUserSubject" href="javascript:;"> 添加</a></p>
                                                        <div id="Layer1">
                                                            <table width="100%" border="0" cellspacing="0" cellpadding="0" class="gradeSubjects" id="shengluohao">
                                                            </table>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>

                                            <!--基本信息 end-->
                                        </td>
                                        <!-- <td style="position:relative;vertical-align:top;"> -->
                                            <!--考试科目 begin-->
<!--                                             <table style="float:right;">
                                                <tr>
                                                    
                                                    <td>
                                                    	<p><span class="font_red" style="display:inline-block;line-height:31px;">* </span> 考试科目 </p>
                                                        <div id="Layer1">
                                                            <table width="100%" border="0" cellspacing="0" cellpadding="0" class="gradeSubjects" id="shengluohao">
                                                            </table>
                                                        </div>
                                                    </td>
                                                    <td><input type="text" width="100px" id="txt_AddSubjectName" /><a id="btn_saveUserSubject" href="javascript:;">添加</a></td>
                                                </tr>
                                            </table> -->
                                            <!--考试科目 end-->
                                        <!-- </td> -->
                                    </tr>
                                </table>
                                <!-- 手动录入 成绩 begin -->
                                <p style="background:url(images/hr.gif); height:3px; width:99%; margin:39px auto 25px; margin-left:10px;"></p>
                                <div id="daoru">
                                    <p id="attaFilesControl" style="display:inline-block;">
                                        <p id="pickfiles1" onclick="loadUpfile();"><span>上传xlsx格式文件</span><input type="file" id="fileName" name="fileName" accept=".xlsx" /></p>
                                        <a href="javascript:;" class="daoru2">帮助提示？</a>
                                        <div id="excel_tishi">
                                            <p>1、上传的excel附件的后缀必须为 “<em style="color:red;">xlsx</em>” 格式，并且必须放在 <em style="color:red;">sheet1</em> 处</p>
                                            <p>2、请按照图片格式在excel文件中填写成绩内容：<br /><img src="images/tishi.png" alt="成绩内容"></p>
                                            <a href="javascript:;" id="excel_tishi_a">确 认</a>
                                        </div>
                                    </p>
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
                                <a onclick="pushToServer(true)" href="javascript:;" class="yessend">确定发送</a><a class="nosend">取消</a>
                                <p id="cookie_p" style="display:none;">您已在<span id="cookie_time"></span>时发送了短信</p>
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