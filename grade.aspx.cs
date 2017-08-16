using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace nwChengji
{
    public partial class grade : System.Web.UI.Page
    {
        Config config = new Config();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                string strExamId = "0";

                if (Request.QueryString["ExamId"] != null)
                {
                    strExamId = Request.QueryString["ExamId"].Trim();
                }

                string strsendsms = "0";
                if (Request.QueryString["sendsms"] != null)
                {
                    strsendsms = Request.QueryString["sendsms"].Trim();
                }

                HttpCookie cookie = Request.Cookies["cj_gcihjt_com"];
                if (cookie != null)
                {
                    string strdbName = cookie["dbname"].Trim();
                    string strTeacherNo = cookie["teacherno"].Trim();
                    if (strdbName.Length == 10)
                    {
                        string strSchoolNo = strdbName.Substring(7);

                        llScript.Text = "<script type=\"text/javascript\">var Teacher_No=" + strTeacherNo + ";var School_No=" + strSchoolNo + ";var examGroupId=\"" + strExamId + "\";var sendsms=\"" + strsendsms + "\"</script>";
                    }
                }
                else
                {
                    config.MsgRed("抱歉，登录已失效！", "http://cj.gcihjt.com/login.aspx");
                }
            }
        }
    }
}