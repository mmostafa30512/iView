package org.apache.jsp.webpages;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;
import org.cyberoam.iview.utility.CheckSession;
import org.cyberoam.iview.audit.CyberoamLogger;
import org.cyberoam.iview.beans.iViewConfigBean;

public final class accessdenied_jsp extends org.apache.jasper.runtime.HttpJspBase
    implements org.apache.jasper.runtime.JspSourceDependent {

  private static java.util.List _jspx_dependants;

  public Object getDependants() {
    return _jspx_dependants;
  }

  public void _jspService(HttpServletRequest request, HttpServletResponse response)
        throws java.io.IOException, ServletException {

    JspFactory _jspxFactory = null;
    PageContext pageContext = null;
    HttpSession session = null;
    ServletContext application = null;
    ServletConfig config = null;
    JspWriter out = null;
    Object page = this;
    JspWriter _jspx_out = null;
    PageContext _jspx_page_context = null;


    try {
      _jspxFactory = JspFactory.getDefaultFactory();
      response.setContentType("text/html; charset=UTF-8");
      pageContext = _jspxFactory.getPageContext(this, request, response,
      			null, true, 8192, true);
      _jspx_page_context = pageContext;
      application = pageContext.getServletContext();
      config = pageContext.getServletConfig();
      session = pageContext.getSession();
      out = pageContext.getOut();
      _jspx_out = out;

      out.write("<!-- ***********************************************************************\n*  Cyberoam iView - The Intelligent logging and reporting solution that \n*  provides network visibility for security, regulatory compliance and \n*  data confidentiality \n*  Copyright  (C ) 2009  Elitecore Technologies Ltd.\n*  \n*  This program is free software: you can redistribute it and/or modify \n*  it under the terms of the GNU General Public License as published by \n*  the Free Software Foundation, either version 3 of the License, or\n*  (at your option) any later version.\n*  \n*  This program is distributed in the hope that it will be useful, but \n*  WITHOUT ANY WARRANTY; without even the implied warranty of \n*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU \n*  General Public License for more details.\n*  \n*  You should have received a copy of the GNU General Public License \n*  along with this program.  If not, see <http://www.gnu.org/licenses/>.\n*  \n*  The interactive user interfaces in modified source and object code \n");
      out.write("*  versions of this program must display Appropriate Legal Notices, as \n*  required under Section 5 of the GNU General Public License version 3.\n*  \n*  In accordance with Section 7(b) of the GNU General Public License \n*  version 3, these Appropriate Legal Notices must retain the display of\n*   the \"Cyberoam Elitecore Technologies Initiative\" logo.\n*********************************************************************** -->\n\n\n\n\n<html>\n\n<html>\n");

	if(CheckSession.checkSession(request,response) < 0) return;
	try{

      out.write("\n\n<head>\n<TITLE>");
      out.print(iViewConfigBean.TITLE);
      out.write("</TITLE>\n<link href=\"");
      out.print(request.getContextPath());
      out.write("/css/container.css\" rel=\"stylesheet\" type=\"text/css\" />\n<link rel=\"stylesheet\" href=\"");
      out.print(request.getContextPath());
      out.write("/css/reports.css\">\n<link href=\"");
      out.print(request.getContextPath());
      out.write("/css/configuration.css\" rel=\"stylesheet\" type=\"text/css\" />\n</head>\n<body>\n\t");
      org.apache.jasper.runtime.JspRuntimeLibrary.include(request, response, "menu.jsp", out, true);
      out.write("\n    ");
      org.apache.jasper.runtime.JspRuntimeLibrary.include(request, response, "pageheader.jsp", out, true);
      out.write("\n\t<div class=\"maincontent\" id=\"main_content\">\n\t<table width=\"100%\" border=\"0\">\n\t<tr>\n\t\t<td align=\"center\" style=\"height: 100px;\"></td>\n\t</tr>\n\t<tr>\n\t\t<td align=\"center\" style=\"height: 100px;color:#D42A1D;font-size:60px;\">Access Denied</td>\n\t</tr>\n\t<tr>\n\t\t<td align=\"center\" style=\"height: 50px;color:#D42A1D;font-size:20px;\">You are not allowed to view this page.</td>\n\t</tr>\n\t<tr>\n\t\t<td align=\"center\" style=\"height: 50px;color:#D42A1D;font-size:20px;\">For more information contact iView administrator.</td>\n\t</tr>\n\t</table>\n\t</div>\n\t");
      org.apache.jasper.runtime.JspRuntimeLibrary.include(request, response, "pagefooter.jsp", out, true);
      out.write("\n</body>\n</html>\n");

	}catch(Exception  e){
	CyberoamLogger.appLog.debug("Exception in iviewconfig.jsp : "+e,e);
}

      out.write('\n');
    } catch (Throwable t) {
      if (!(t instanceof SkipPageException)){
        out = _jspx_out;
        if (out != null && out.getBufferSize() != 0)
          out.clearBuffer();
        if (_jspx_page_context != null) _jspx_page_context.handlePageException(t);
      }
    } finally {
      if (_jspxFactory != null) _jspxFactory.releasePageContext(_jspx_page_context);
    }
  }
}
