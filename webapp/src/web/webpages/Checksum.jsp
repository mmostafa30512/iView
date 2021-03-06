<!-- ***********************************************************************
*  provides network visibility for security, regulatory compliance and 
*  data confidentiality 
*  Copyright  (C ) 2009  Elitecore Technologies Ltd.
*  
*  This program is free software: you can redistribute it and/or modify 
*  it under the terms of the GNU General Public License as published by 
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
*  
*  This program is distributed in the hope that it will be useful, but 
*  WITHOUT ANY WARRANTY; without even the implied warranty of 
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
*  General Public License for more details.
*  
*  You should have received a copy of the GNU General Public License 
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*  
*  The interactive user interfaces in modified source and object code 
*  versions of this program must display Appropriate Legal Notices, as 
*  required under Section 5 of the GNU General Public License version 3.
*  
*  In accordance with Section 7(b) of the GNU General Public License 
*  version 3, these Appropriate Legal Notices must retain the display of
*   the "Cyberoam Elitecore Technologies Initiative" logo.
*********************************************************************** -->

<%@ page contentType="text/html; charset=UTF-8"%>
<%@page import="org.cyberoam.iview.utility.*"%>
<%@page import="org.cyberoam.iview.mlm.TranslationHelper"%>
<%@page import="org.cyberoam.iview.beans.iViewConfigBean"%>
<%@page import="org.cyberoam.iview.modes.ApplicationModes"%>

<%
	try{
		if(CheckSession.checkSession(request,response)<0){
			return;
		}
		
		String webusagechecksumval = iViewConfigBean.getValueByKey(iViewConfigBean.WEBUSAGE_CHECKSUM_VAL);
		String dhcpchecksumval= iViewConfigBean.getValueByKey(iViewConfigBean.DHCP_CHECKSUM_VAL);
		String strStatus = request.getParameter("status");
		int iStatus = -1;
		if(strStatus != null && !"null".equalsIgnoreCase(strStatus)){
			iStatus = Integer.parseInt(strStatus);
		}
		String appmode = request.getParameter("appmode");
		int iMode = -1;
		if(appmode != null && !"null".equalsIgnoreCase(appmode)){
			iMode = Integer.parseInt(appmode);
		}
		
		String pmessage = "";
		String nmessage = "";
		String msgType= "";
		if(iMode == ApplicationModes.CHECKSUM_REQUEST && iStatus > 0){
	pmessage = TranslationHelper.getTranslatedMessge("Configuration updated successfully.");
		} else if(iMode == ApplicationModes.CHECKSUM_REQUEST && iStatus <= 0){
	nmessage = TranslationHelper.getTranslatedMessge("Error in Configuration updation.");
		}
%>
<html>
<head>
<title><%= iViewConfigBean.TITLE %></title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/reports.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/container.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/tabs.css">
<link href="<%=request.getContextPath()%>/css/configuration.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" language="JavaScript" src="<%=request.getContextPath()%>/javascript/SearchData.js"></script>
<script type="text/javascript" language="JavaScript" src="<%=request.getContextPath()%>/javascript/utilities.js"></script>
<script type="text/javascript" language="javascript">
  	window.onload = function (evt) {
		setWidth();		
	}		
	function setWidth(){
		var main_div = document.getElementById("main_content");	
		main_div.style.width = (document.body.clientWidth - 217);	
	}
   	
		
</script>
</head>
<body>
<jsp:include page="menu.jsp" flush="true"></jsp:include>
<jsp:include page="pageheader.jsp" flush="true"></jsp:include>        
<div class="maincontent" id="main_content">
		<div class="reporttitlebar">
			<div class="reporttitlebarleft"></div>
			<div class="reporttitle"><%=TranslationHelper.getTranslatedMessge("Checksum Configuration")%>
			</div>
		</div>		
		<br><br>
<div style="float:left;margin-left:2px;margin-top:3px;width:100%;">
	<form  action="<%=request.getContextPath()%>/iview" method=post name=ftpsearchform>
	
	<input type=hidden name=appmode value="<%=ApplicationModes.CHECKSUM_REQUEST%>">
	<table cellspacing="0" cellpadding="2px" border="0" width="100%"  >
			
	
	<table border="0" cellpadding="2" cellspacing="2" class="TableData">
	
	<%
	if(!"".equals(pmessage)){
	%>
	<tr>
		<td  colspan="4" class="posimessage" >&nbsp;&nbsp;<%=pmessage%></td>
	</tr>
<%
	}
%>
<%
	if(!"".equals(nmessage)){
%>
	<tr>
		<td  colspan="4"  class="nagimessage">&nbsp;&nbsp;<%=nmessage%></td>
	</tr>
<%
	}
%>
	<tr>
	   <td align="left" class="tdhead"><%=TranslationHelper.getTranslatedMessge("Checksum Module")%></td>
	   <td align="left" class="tdhead"><%=TranslationHelper.getTranslatedMessge("")%></td>
	</tr>
		<TR align=left>
			<td  width="20%">
				<%= TranslationHelper.getTranslatedMessge("DHCP") %>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</td>
			
			<td align="left">
				<input type=radio name=dhcpchecksum value=0 <%=("0".equals(dhcpchecksumval))?"checked":""%> />
				<%= TranslationHelper.getTranslatedMessge("Disable") %>
			    <input type=radio name=dhcpchecksum value=1 <%=("1".equals(dhcpchecksumval))?"checked":""%> />
			    <%= TranslationHelper.getTranslatedMessge("Enable") %>			    
			</td>
		</TR>		
		<TR align=left>
			<td>
				<%= TranslationHelper.getTranslatedMessge("Web Usage") %>
			</td>
			
			<td align="left">
				<input type=radio name=webusagechecksum value=0  <%=("0".equals(webusagechecksumval))?"checked":""%>/>
				<%= TranslationHelper.getTranslatedMessge("Disable") %>
			    <input type=radio name=webusagechecksum value=1 <%=("1".equals(webusagechecksumval))?"checked":""%>/>
			    <%= TranslationHelper.getTranslatedMessge("Enable") %>
			</td>
		</TR>
		</table>
		<br>
		<tr>		
		    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
			<td align="left">		
			<input type=submit name=save  class=criButton value="Save">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</td>
		</tr>
	</table>	
	</form>
</div>
</div>
<jsp:include page="pagefooter.jsp" flush="true"></jsp:include>
</body>
<%
	} catch(Exception e) {
	}
%>
</html>
