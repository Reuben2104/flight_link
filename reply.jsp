<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>FAQs</title>
</head>
<body>
<a href='customerRep.jsp'>[Return to Customer Representive Dashboard]</a>

	<p style="font-size: 30px;">Answer FAQs</p>
	
    <%

    ApplicationDB db = null;
    Connection con = null;

    try {
    	
        db = new ApplicationDB();
        con = db.getConnection();
        
        
        String str = "SELECT * FROM QuestionAnswer WHERE answer = '(Question will be answered shortly by a Customer Representative)';";
        PreparedStatement preparedStatement = con.prepareStatement(str);
		ResultSet result = preparedStatement.executeQuery();
		
	%>
	
		<table>
	
		<tr>    
			<td><u>Question</u></td>
			<td><u>Submit Answer</u></td>
			
			
		</tr>
		
	<%
		
	while (result.next()) {
			
		String question = result.getString("question");
		String answer = result.getString("answer");

	%>
			    
			<tr>
		        <td><%= question %></td>
		        <td>		    
	    			<form action="replyAdded.jsp" method="POST">
						
						<input type="hidden" name="question" value="<%= question %>">
				        <input type="text" name="reply" id="reply" required style="width: 300px;">
				
				        <input type="submit" value="Reply">       
	         
	    			</form> 
		        </td>
			</tr>
				
	<% 
			
	}

	%>
			
	</table>
	
	<%
	
    } catch (Exception e) {
        out.print(e);
    } finally {
        db.closeConnection(con);
    }
    
    %>
    
	
</body>
</html>