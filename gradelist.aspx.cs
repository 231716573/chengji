using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.Data;
using System.Data.SqlClient;

namespace nwChengji
{
    public partial class gradelist : System.Web.UI.Page
    {
        Config config = new Config();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.Page.IsPostBack)
            {
                this.getnew.HRef = "gradenew.aspx";
                if (base.Request["name"] != null && base.Request["enname"] != null)
                {
                    this.getnew.HRef = "gradenew.aspx?name=" + base.Request["name"].Trim() + "&enname=" + HttpUtility.UrlEncode(base.Request["enname"].Trim());
                }
                HttpCookie cookie = Request.Cookies["cj_gcihjt_com"];
                if (cookie != null)
                {
                    string strdbName = cookie["dbname"].Trim();
                    string strTeacherNo = cookie["teacherno"].Trim();
                    if (strdbName.Length == 10)
                    {
                        this.tbExamBeginDate.Value = "";
                        this.tbExamEndDate.Value = "";
                        this.LoadClass(strdbName, strTeacherNo);
                        this.LoadExamList("", strdbName, strTeacherNo);
                    }
                }
                else
                {
                    this.config.MsgRed("抱歉，登录已失效了！", "login.aspx");
                }
            }
        }

        void LoadClass(string strdbname, string strTeacherNo)
        {
            selectclass.Items.Clear();

            Config ccc = new Config();
            ccc.OpenConn8100();
            string sql = "select b.class_no, b.classname from " + strdbname + ".dbo.teacher_class a inner join " + strdbname + ".dbo.class_info b on (a.class_no = b.class_no) where a.teacher_no = " + strTeacherNo;
            SqlCommand cmd = new SqlCommand(sql, ccc.conn8100);
            SqlDataReader dr = cmd.ExecuteReader();
            if (dr.Read())
            {
                ListItem li = new ListItem(dr[1].ToString().Trim(), dr[0].ToString());
                selectclass.Items.Add(li);
            }
            dr.Close();
            cmd.Dispose();
            ccc.conn8100.Close();
        }

        void LoadExamList(string newsql, string strdbname, string strTeacherNo)
        {
            string strSchoolNo = strdbname.Substring(7);
            config.OpenConn8100();
            //string sql = "SELECT TOP 50 * FROM [Exam].[dbo].[e_List] where school_no = " + strSchoolNo + " and teacher_no = " + strTeacherNo + " and e_flag = 1 and class_no in (select class_no from " + strdbname + ".dbo.teacher_class where teacher_no = " + strTeacherNo + ") order by id desc";
            string sql = "SELECT TOP 50 * FROM [Exam].[dbo].[e_List] where school_no = " + strSchoolNo + " and teacher_no = " + strTeacherNo + " and e_flag = 1 and class_no in (select class_no from " + strdbname + ".dbo.teacher_class where teacher_no = " + strTeacherNo + " and level in (3,4) union select class_no from " + strdbname + ".dbo.class_info where grade_id = (select grade_no from " + strdbname + ".dbo.teacher_class where teacher_no = " + strTeacherNo + " and level = 2)) order by id desc";
            if (newsql.Length > 0)
            {
                sql = newsql;
            }
            SqlCommand cmd = new SqlCommand(sql, config.conn8100);
            SqlDataReader dr = cmd.ExecuteReader();
            llListExam.Text = "";
            while (dr.Read())
            {
                string strExamId = dr["ID"].ToString();
                string strExamName = dr["e_Name"].ToString().Trim();
                string strExamDate = Convert.ToDateTime(dr["e_ExamDate"].ToString()).ToString("yyyy-MM-dd");
                string strClassNo = getClassName(strdbname, dr["class_no"].ToString());

                llListExam.Text = llListExam.Text + "<div><p><a href=\"gradenew.aspx?ExamId=" + strExamId + "\" target=\"_blank\" class=\"text_bian\">" + strExamName + "</a></p>";
                llListExam.Text = llListExam.Text + "<p>" + strExamDate + "</p><p>" + strClassNo + "</p>";
                llListExam.Text = llListExam.Text + "<p><a href=\"gradenew.aspx?ExamId=" + strExamId + "&sendsms=1\" target=\"_blank\">发送短信</a></p></div>";
            }
            dr.Close();
            cmd.Dispose();
            config.conn8100.Close();
        }

        string getClassName(string strdbname, string strClassNo)
        {
            string strClassname = "";

            Config ccc = new Config();
            ccc.OpenConn8100();
            string sql = "select classname from " + strdbname + ".dbo.class_info where class_no = " + strClassNo;
            SqlCommand cmd = new SqlCommand(sql, ccc.conn8100);
            SqlDataReader dr = cmd.ExecuteReader();
            if (dr.Read())
            {
                strClassname = dr[0].ToString().Trim();
            }
            dr.Close();
            cmd.Dispose();
            ccc.conn8100.Close();

            return strClassname;
        }

        protected void lbSearch_Click(object sender, EventArgs e)
        {
            HttpCookie cookie = Request.Cookies["cj_gcihjt_com"];
            if (cookie != null)
            {
                string strBeginDate = tbExamBeginDate.Value.Trim();
                string strEndDate = tbExamEndDate.Value.Trim();

                if (strBeginDate.Length <= 0 || strEndDate.Length <= 0)
                {
                    config.MsgStr("温馨提示：起止日期必填！");
                    return;
                }

                string strdbName = cookie["dbname"].Trim();
                string strTeacherNo = cookie["teacherno"].Trim();
                string strClassNo = selectclass.Items[selectclass.SelectedIndex].Value.Trim();

                string strSchoolNo = strdbName.Substring(7);
                string sql = "SELECT TOP 50 * FROM [Exam].[dbo].[e_List] where school_no = " + strSchoolNo + " and teacher_no = " + strTeacherNo + " and e_flag = 1 and e_ExamDate between '" + strBeginDate + "' and '" + strEndDate + "' and class_no in (select class_no from " + strdbName + ".dbo.teacher_class where teacher_no = " + strTeacherNo + ") order by id desc";
                LoadExamList(sql, strdbName, strTeacherNo);
            }
        }

    }
}