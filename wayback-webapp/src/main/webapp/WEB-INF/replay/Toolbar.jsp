<%@
 page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8"
 %><%@
 page import="java.util.Iterator"
 %><%@
 page import="java.util.ArrayList"
 %><%@
 page import="java.util.Date"
 %><%@
 page import="java.util.Calendar"
 %><%@
 page import="java.util.List"
 %><%@
 page import="java.text.ParseException"
 %><%@
 page import="org.archive.wayback.ResultURIConverter"
 %><%@
 page import="org.archive.wayback.WaybackConstants"
 %><%@
 page import="org.archive.wayback.core.CaptureSearchResult"
 %><%@
 page import="org.archive.wayback.core.CaptureSearchResults"
 %><%@
 page import="org.archive.wayback.core.UIResults"
 %><%@
 page import="org.archive.wayback.core.WaybackRequest"
 %><%@
 page import="org.archive.wayback.partition.CaptureSearchResultPartitionMap"
 %><%@
 page import="org.archive.wayback.partition.PartitionPartitionMap"
 %><%@
 page import="org.archive.wayback.partition.PartitionsToGraph"
 %><%@
 page import="org.archive.wayback.partition.ToolBarData"
 %><%@
 page import="org.archive.wayback.util.graph.Graph"
 %><%@
 page import="org.archive.wayback.util.graph.GraphEncoder"
 %><%@
 page import="org.archive.wayback.util.graph.GraphRenderer"
 %><%@
 page import="org.archive.wayback.util.partition.Partition"
 %><%@
 page import="org.archive.wayback.util.partition.Partitioner"
 %><%@
 page import="org.archive.wayback.util.partition.PartitionSize"
 %><%@
 page import="org.archive.wayback.util.StringFormatter"
 %><%@
 page import="org.archive.wayback.util.url.UrlOperations"
 %><%
UIResults results = UIResults.extractReplay(request);
WaybackRequest wbRequest = results.getWbRequest();
ResultURIConverter uriConverter = results.getURIConverter();
StringFormatter fmt = wbRequest.getFormatter();

String staticPrefix = results.getStaticPrefix();
String queryPrefix = results.getQueryPrefix();
String replayPrefix = results.getReplayPrefix();

String graphJspPrefix = results.getContextConfig("graphJspPrefix");
if(graphJspPrefix == null) {
	graphJspPrefix = queryPrefix;
}
ToolBarData data = new ToolBarData(results);

String searchUrl = 
	UrlOperations.stripDefaultPortFromUrl(wbRequest.getRequestUrl());
String searchUrlSafe = fmt.escapeHtml(searchUrl);
String searchUrlJS = fmt.escapeJavaScript(searchUrl);
Date firstYearDate = data.yearPartitions.get(0).getStart();
Date lastYearDate = data.yearPartitions.get(data.yearPartitions.size()-1).getEnd();

int resultIndex = 1;
int imgWidth = 375;
int imgHeight = 27;
int monthWidth = 2;
int yearWidth = 25;
String yearFormatKey = "PartitionSize.dateHeader.yearGraphLabel";
String encodedGraph = data.computeGraphString(yearFormatKey,imgWidth,imgHeight);
String graphImgUrl = graphJspPrefix + "jsp/graph.jsp?graphdata=" + encodedGraph;
// TODO: this is archivalUrl specific:
String starLink = fmt.escapeHtml(queryPrefix + "*/" + searchUrl);
%>
<!-- BEGIN WAYBACK TIMELINE DISCLAIMER INSERT -->
<script type="text/javascript" src="<%= staticPrefix %>js/graph-calc.js" ></script>
<script type="text/javascript">
var firstDate = <%= firstYearDate.getTime() %>;
var lastDate = <%= lastYearDate.getTime() %>;
var wbPrefix = "<%= replayPrefix %>";
var wbCurrentUrl = "<%= searchUrlJS %>";

var curYear = -1;
var curMonth = -1;
var yearCount = 15;
var firstYear = 1996;
var imgWidth=<%= imgWidth %>;
var yearImgWidth = <%= yearWidth %>;
var monthImgWidth = <%= monthWidth %>;
var trackerVal = "none";
var displayDay = "<%= fmt.format("ToolBar.curDayText",data.curResult.getCaptureDate()) %>";
var displayMonth = "<%= fmt.format("ToolBar.curMonthText",data.curResult.getCaptureDate()) %>";
var displayYear = "<%= fmt.format("ToolBar.curYearText",data.curResult.getCaptureDate()) %>";
var prettyMonths = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

function showTrackers(val) {
	if(val == trackerVal) {
		return;
	}
	if(val == "inline") {
		document.getElementById("displayYearEl").style.color = "#f00";
		document.getElementById("displayMonthEl").style.color = "#f00";
		document.getElementById("displayDayEl").style.color = "#f00";		
	} else {
		document.getElementById("displayYearEl").innerHTML = displayYear;
		document.getElementById("displayYearEl").style.color = "#ff0";
		document.getElementById("displayMonthEl").innerHTML = displayMonth;
		document.getElementById("displayMonthEl").style.color = "#ff0";
		document.getElementById("displayDayEl").innerHTML = displayDay;
		document.getElementById("displayDayEl").style.color = "#ff0";
	}
    document.getElementById("wbMouseTrackYearImg").style.display = val;
    document.getElementById("wbMouseTrackMonthImg").style.display = val;
    trackerVal = val;
}

function trackMouseMove(event,element) {

    var eventX = getEventX(event);
    var elementX = getElementX(element) + 6; // why 6?!?
    var xOff = eventX - elementX;

    var monthOff = xOff % yearImgWidth;

    var year = Math.floor(xOff / yearImgWidth);
	var yearStart = year * yearImgWidth;
    var monthOfYear = Math.floor(monthOff / monthImgWidth);
    if(monthOfYear > 11) {
        monthOfYear = 11;
    }
    // 1 extra border pixel at the left edge of the year:
    var month = (year * 12) + monthOfYear;
    var day = 1;
	if(monthOff % 2 == 1) {
		day = 15;
	}
	var dateString = 
		zeroPad(year + firstYear) + 
		zeroPad(monthOfYear+1,2) +
		zeroPad(day,2) + "000000";

	var monthString = prettyMonths[monthOfYear];
	document.getElementById("displayYearEl").innerHTML = year + 1996;
	document.getElementById("displayMonthEl").innerHTML = monthString;
	// looks too jarring when it changes..
	//document.getElementById("displayDayEl").innerHTML = day;

	var url = wbPrefix + dateString + '/' +  wbCurrentUrl;
	document.getElementById('wm-graph-anchor').href = url;

    //document.getElementById("wmtbURL").value="xO("+xOff+") y("+year+") m("+month+") monthOff("+monthOff+") DS("+dateString+") Moy("+monthOfYear+") ms("+monthString+")";
    if(curYear != year) {
        document.getElementById("wbMouseTrackYearImg").style.left = year * yearImgWidth;
        curYear = year;
    }
    if(curMonth != month) {
        document.getElementById("wbMouseTrackMonthImg").style.left = year + (month * monthImgWidth) + 1;
        curMonth = month;
    }
}

</script>


<style type="text/css">body{margin-top:0!important;padding-top:0!important;min-width:800px!important;}#wm-ipp a:hover{text-decoration:underline!important;}</style>
<div id="wm-ipp" style="display:none; position:relative;padding:0 5px;min-height:70px;min-width:800px;">
<div id="wm-ipp-inside" style="position:fixed;padding:0!important;margin:0!important;width:97%;min-width:780px;border:5px solid #000;border-top:none;background-image:url(<%= staticPrefix %>images/toolbar/wm_tb_bk_trns.png);text-align:center;-moz-box-shadow:1px 1px 3px #333;-webkit-box-shadow:1px 1px 3px #333;box-shadow:1px 1px 3px #333;font-size:11px!important;font-family:'Lucida Grande','Arial',sans-serif!important;">
    <table style="border-collapse:collapse;margin:0;padding:0;width:100%;"><tbody><tr>
    <td style="padding:10px;vertical-align:top;min-width:140px;">
    <a href="<%= queryPrefix %>" title="Wayback Machine home page"><img src="<%= staticPrefix %>images/toolbar/wayback-toolbar-logo.png" alt="Wayback Machine" width="110" height="39" border="0"/></a>
    </td>
    <td style="padding:0!important;text-align:center;vertical-align:top;width:100%;">

        <table style="border-collapse:collapse;margin:0 auto;padding:0;width:570px;"><tbody><tr>
        <td style="padding:3px 0;" colspan="2">
        <form method="get" action="<%= queryPrefix %>jsp/bounceToReplay.jsp" name="wmtb" id="wmtb" style="margin:0!important;padding:0!important;"><input type="text" name="wmtbURL" id="wmtbURL" value="<%= searchUrlSafe %>" style="width:400px;font-size:11px;font-family:'Lucida Grande','Arial',sans-serif;"/><input type="submit" value="Go" style="font-size:11px;font-family:'Lucida Grande','Arial',sans-serif;margin-left:5px;"/><span id="wm_tb_options" style="display:block;"></span></form>
        </td>
        <td style="vertical-align:bottom;padding:5px 0 0 0!important;" rowspan="2">
            <table style="border-collapse:collapse;width:110px;color:#99a;font-family:'Helvetica','Lucida Grande','Arial',sans-serif;"><tbody>
            <tr>
                <td style="padding-right:9px;text-align:right;">
                <%
                	if(data.prevResult == null) {
                        %>
                        <img src="<%= staticPrefix %>images/toolbar/wm_tb_prv_on.png" alt="Previous capture" width="14" height="16" border="0"/>
                        <%
                	} else {
		                %>
		                <a href="<%= data.makeReplayURL(data.prevResult) %>" title="<%= fmt.format("ToolBar.prevTitle",data.prevResult.getCaptureDate()) %>"><img src="<%= staticPrefix %>images/toolbar/wm_tb_prv_on.png" alt="Previous capture" width="14" height="16" border="0"/></a>
		                <%
                	}
                %>
                </td>
                <td id="displayDayEl" style="background:#000;color:#ff0;width:34px;height:24px;padding:2px 0 0 0;text-align:center;font-size:22px;" title="<%= fmt.format("ToolBar.curDayTitle",data.curResult.getCaptureDate()) %>"><%= fmt.format("ToolBar.curDayText",data.curResult.getCaptureDate()) %></td>
				<td style="padding-left:9px;white-space:nowrap;overflow:visible;" nowrap="nowrap">
                <%
                	if(data.nextResult == null) {
                        %>
                        <img src="<%= staticPrefix %>images/toolbar/wm_tb_nxt_on.png" alt="Next capture" width="14" height="16" border="0"/>
                        <%
                	} else {
		                %>
		                <a href="<%= data.makeReplayURL(data.nextResult) %>" title="<%= fmt.format("ToolBar.nextTitle",data.nextResult.getCaptureDate()) %>"><img src="<%= staticPrefix %>images/toolbar/wm_tb_nxt_on.png" alt="Next capture" width="14" height="16" border="0"/></a>
		                <%
                	}
                %>
			</td>
            </tr>
            <tr style="width:110px;height:16px;font-size:10px!important;">
            	<td style="padding-right:9px;text-align:right;white-space:nowrap;overflow:visible;" nowrap="nowrap">
                <%
                	if(data.monthPrevResult == null) {
                        %>
                        <%= fmt.format("ToolBar.noPrevMonthText",data.addMonth(data.curResult.getCaptureDate(),-1)) %>
                        <%
                	} else {
		                %>
		                <a href="<%= data.makeReplayURL(data.monthPrevResult) %>" style="text-decoration:none;color:#33f;" title="<%= fmt.format("ToolBar.prevMonthTitle",data.monthPrevResult.getCaptureDate()) %>"><%= fmt.format("ToolBar.prevMonthText",data.monthPrevResult.getCaptureDate()) %></a>
		                <%
                	}
                %>
                </td>
                <td id="displayMonthEl" style="background:#000;color:#ff0;font-size:12px!important;width:34px;height:15px;padding-top:1px;text-align:center;" title="<%= fmt.format("ToolBar.curMonthTitle",data.curResult.getCaptureDate()) %>"><%= fmt.format("ToolBar.curMonthText",data.curResult.getCaptureDate()) %></td>
				<td style="padding-left:9px;white-space:nowrap;overflow:visible;" nowrap="nowrap">
                <%
                	if(data.monthNextResult == null) {
                        %>
                        <%= fmt.format("ToolBar.noNextMonthText",data.addMonth(data.curResult.getCaptureDate(),1)) %>
                        <%
                	} else {
		                %>
		                <a href="<%= data.makeReplayURL(data.monthNextResult) %>" style="text-decoration:none;color:#33f;" title="<%= fmt.format("ToolBar.nextMonthTitle",data.monthNextResult.getCaptureDate()) %>"><%= fmt.format("ToolBar.nextMonthText",data.monthNextResult.getCaptureDate()) %></a>
		                <%
                	}
                %>
                </td>
            </tr>

            <tr style="width:110px;height:13px;font-size:9px!important;">
				<td style="padding-right:9px;text-align:right;white-space:nowrap;overflow:visible;" nowrap="nowrap">
                <%
                	if(data.yearPrevResult == null) {
                        %>
                        <%= fmt.format("ToolBar.noPrevYearText",data.addYear(data.curResult.getCaptureDate(),-1)) %>
                        <%
                	} else {
		                %>
		                <a href="<%= data.makeReplayURL(data.yearPrevResult) %>" style="text-decoration:none;color:#33f;" title="<%= fmt.format("ToolBar.prevYearTitle",data.yearPrevResult.getCaptureDate()) %>"><%= fmt.format("ToolBar.prevYearText",data.yearPrevResult.getCaptureDate()) %></a>
		                <%
                	}
                %>
                </td>
                <td id="displayYearEl" style="background:#000;color:#ff0;font-size:10px!important;padding-top:1px;width:34px;height:13px;text-align:center;" title="<%= fmt.format("ToolBar.curYearTitle",data.curResult.getCaptureDate()) %>"><%= fmt.format("ToolBar.curYearText",data.curResult.getCaptureDate()) %></td>
				<td style="padding-left:9px;white-space:nowrap;overflow:visible;" nowrap="nowrap">
                <%
                	if(data.yearNextResult == null) {
                        %>
                        <%= fmt.format("ToolBar.noNextYearText",data.addYear(data.curResult.getCaptureDate(),1)) %>
                        <%
                	} else {
		                %>
		                <a href="<%= data.makeReplayURL(data.yearNextResult) %>" style="text-decoration:none;color:#33f;" title="<%= fmt.format("ToolBar.nextYearTitle",data.yearNextResult.getCaptureDate()) %>"><%= fmt.format("ToolBar.nextYearText",data.yearNextResult.getCaptureDate()) %></a>
		                <%
                	}
                %>
				</td>
            </tr>
            </tbody></table>
        </td>

        </tr>
        <tr>
        <td style="vertical-align:middle;padding:0!important;">
            <a href="<%= starLink %>" style="color:#33f;font-size:11px;" title="<%= fmt.format("ToolBar.numCapturesTitle") %>"><strong><%= fmt.format("ToolBar.numCapturesText",data.getResultCount()) %></strong></a>
            <div style="margin:0!important;padding:0!important;color:#666;font-size:9px;padding-top:2px!important;white-space:nowrap;" title="<%= fmt.format("ToolBar.captureRangeTitle") %>"><%= fmt.format("ToolBar.captureRangeText",data.getFirstResultDate(),data.getLastResultDate()) %></div>
        </td>
        <td style="padding:0!important;">
        <a style="position:relative; white-space:nowrap; width:<%= imgWidth %>px;height:<%= imgHeight %>px;" href="" id="wm-graph-anchor">
        <div id="wm-ipp-sparkline" style="position:relative; white-space:nowrap; width:<%= imgWidth %>px;height:<%= imgHeight %>px;background-color:#fff;cursor:pointer;" title="<%= fmt.format("ToolBar.sparklineTitle") %>">
			<img style="position:absolute; z-index:12; top:0px; left:0px;"
				onmouseover="showTrackers('inline');" 
				onmouseout="showTrackers('none');"
				onmousemove="trackMouseMove(event,this)"
				alt="sparklines"
				width="<%= imgWidth %>"
				height="<%= imgHeight %>"
				border="0"
				src="<%= graphImgUrl %>"></img>
			<img id="wbMouseTrackYearImg" 
				style="display:none; position:absolute; z-index:10;"
				width="<%= yearWidth %>" 
				height="<%= imgHeight %>"
				border="0"
				src="<%= staticPrefix %>images/toolbar/transp-yellow-pixel.png"></img>
			<img id="wbMouseTrackMonthImg"
				style="display:none; position:absolute; z-index:11; " 
				width="<%= monthWidth %>"
				height="<%= imgHeight %>" 
				border="0"
				src="<%= staticPrefix %>images/toolbar/transp-red-pixel.png"></img>
        </div>
		</a>

        </td>
        </tr></tbody></table>
    </td>
    <td style="text-align:right;padding:5px;width:65px;font-size:11px!important;">
        <a href="javascript:;" onclick="document.getElementById('wm-ipp').style.display='none';" style="display:block;padding-right:18px;background:url(<%= staticPrefix %>images/toolbar/wm_tb_close.png) no-repeat 100% 0;color:#33f;font-family:'Lucida Grande','Arial',sans-serif;margin-bottom:23px;" title="<%= fmt.format("ToolBar.closeTitle") %>"><%= fmt.format("ToolBar.closeText") %></a>
        <a href="FAQ" style="display:block;padding-right:18px;background:url(<%= staticPrefix %>images/toolbar/wm_tb_help.png) no-repeat 100% 0;color:#33f;font-family:'Lucida Grande','Arial',sans-serif;" title="<%= fmt.format("ToolBar.helpTitle") %>"><%= fmt.format("ToolBar.helpText") %></a>
    </td>
    </tr></tbody></table>

</div>
</div>

<script type="text/javascript" src="<%= staticPrefix %>js/disclaim-element.js" ></script>
<script type="text/javascript">
  var wmDisclaimBanner = document.getElementById("wm-ipp");
  if(wmDisclaimBanner != null) {
    disclaimElement(wmDisclaimBanner);
  }
</script>
<!-- END WAYBACK TIMELINE DISCLAIMER INSERT -->




















