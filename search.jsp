<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Search Questions</title>
</head>
<body>
<a href='faqs.jsp'>[Return to FAQs]</a>

	
    <%

    ApplicationDB db = null;
    Connection con = null;

    try {
    	
        db = new ApplicationDB();
        con = db.getConnection();
        
        
        String search = request.getParameter("search");

        String str = "SELECT * FROM QuestionAnswer WHERE question LIKE ?;";
        
        PreparedStatement preparedstatement = con.prepareStatement(str);
        preparedstatement.setString(1, "%" + search + "%");
        ResultSet result = preparedstatement.executeQuery();
        
	%>
	
	<p style="font-size: 30px;">Search Results:</p>
	
	
		<table>
	
		<tr>    
			<td><u>Question</u></td>
			<td><u>Answer</u></td>
			
			
		</tr>
		
	<%
		
	while (result.next()) {
			
		String question = result.getString("question");
		String answer = result.getString("answer");
				
			
	%>
			    
			<tr>
		        <td><%= question %></td>
		        <td><%= answer %></td>

			</tr>
				
	<% 
			
	}

	%>
	
	<%
	
    } catch (Exception e) {
        out.print(e);
    } finally {
        db.closeConnection(con);
    }
    
    %>

</body>
</html>



