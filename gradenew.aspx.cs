using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace nwChengji
{
    public partial class gradenew : System.Web.UI.Page
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

                        string kf_name = "";
                        if (base.Request.QueryString["name"] != null)
                        {
                            kf_name = base.Request.QueryString["name"].Trim();
                        }
                        string kf_enname = "";
                        if (base.Request.QueryString["enname"] != null)
                        {
                            kf_enname = base.Request.QueryString["enname"].Trim();
                        }

                        llScript.Text = "<script type=\"text/javascript\">var Teacher_No=\"" + strTeacherNo + "\";var School_No=\"" + strSchoolNo + "\";var examGroupId=\"" + strExamId + "\";var sendsms=\"" + strsendsms + "\";var kf_name=\"" + kf_name + "\";var kf_enname=\"" + kf_enname + "\";" + "$(function (){$(\"#fileName\").wrap(\'<form method=\"post\" action=\"uploadnew.ashx?option=upload&sno=" + strSchoolNo + "\" id=\"myForm2\"  enctype=\"multipart/form-data\"></form>\');})" + " </script>";
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