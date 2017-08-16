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
    public partial class login : System.Web.UI.Page
    {
        Config config = new Config();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                string text = "";
                string text2 = "";
                string text3 = "";
                string text4 = "";

                if (base.Request.QueryString["account"] != null)
                {
                    text = base.Request.QueryString["account"].Trim();
                }
                if (base.Request.QueryString["password"] != null)
                {
                    text2 = base.Request.QueryString["password"].Trim();
                }
                if (base.Request.QueryString["name"] != null)
                {
                    text3 = base.Request.QueryString["name"].Trim();
                }
                if (base.Request.QueryString["enname"] != null)
                {
                    text4 = base.Request.QueryString["enname"].Trim();
                }
                if (text.Length > 0 && text2.Length > 0 && text3.Length > 0 && text4.Length > 0)
                {
                    this.LoginIn(text, text2, true, "gradenew.aspx?name=" + text3 + "&enname=" + text4);
                }
                else if (text.Length > 0 && text2.Length > 0)
                {
                    this.LoginIn(text, text2, false, "");
                }
            }
        }

        private void LoginIn(string strUsername, string strPassword, bool blUrl, string strUrl)
        {
            string text;
            if (strUsername.Length == 6)
            {
                text = "SELECT TOP 1 * FROM [HJTSeed].[dbo].[AllTel] where flag = 1 and account = '" + strUsername + "' order by ID desc";
            }
            else
            {
                if (strUsername.Length <= 6)
                {
                    this.config.MsgStr("请输入6位数互教通账号或您的接收互教通短信手机号");
                    return;
                }
                text = "SELECT TOP 1 * FROM [HJTSeed].[dbo].[AllTel] where flag = 1 and tel = '" + strUsername + "' order by ID desc";
            }
            bool flag = false;
            string text2 = "";
            string text3 = "";
            string str = "";
            if (text.Length > 0)
            {
                this.config.OpenConn8100();
                SqlCommand sqlCommand = new SqlCommand(text, this.config.conn8100);
                SqlDataReader sqlDataReader = sqlCommand.ExecuteReader();
                if (sqlDataReader.Read())
                {
                    text2 = sqlDataReader["dbname"].ToString().Trim();
                    text3 = sqlDataReader["student_no"].ToString().Trim();
                    str = sqlDataReader["name"].ToString().Trim();
                }
                sqlDataReader.Close();
                sqlCommand.Dispose();
                this.config.conn8100.Close();
            }
            if (text2.Length == 10)
            {
                this.config.OpenConn8100();
                text = "select password from " + text2 + ".dbo.teacher_info where teacher_no = " + text3;
                SqlCommand sqlCommand = new SqlCommand(text, this.config.conn8100);
                SqlDataReader sqlDataReader = sqlCommand.ExecuteReader();
                if (sqlDataReader.Read())
                {
                    string a = sqlDataReader[0].ToString().Trim();
                    if (a == strPassword)
                    {
                        flag = true;
                    }
                }
                sqlDataReader.Close();
                sqlCommand.Dispose();
                this.config.conn8100.Close();
            }
            if (!flag)
            {
                this.config.MsgStr("抱歉，密码输入不正确，请您重试！");
            }
            else
            {
                HttpCookie newcookie = new HttpCookie("cj_gcihjt_com");
                newcookie["dbname"] = text2;
                newcookie["teachername"] = HttpUtility.UrlEncode(str);
                newcookie["teacherno"] = text3;
                newcookie.Expires = DateTime.Now.AddHours(3);
                Response.Cookies.Add(newcookie);

                if (blUrl)
                {
                    base.Response.Redirect(strUrl);
                }
                else
                {
                    base.Response.Redirect("gradenew.aspx");
                }
            }
        }

        protected void lbLogin_Click(object sender, EventArgs e)
        {
            string strUsername = this.inUsername.Value.Trim();
            string strPassword = this.inPassword.Value.Trim();
            this.LoginIn(strUsername, strPassword, false, "");
        }
    }
}