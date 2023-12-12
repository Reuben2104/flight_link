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
<a href='success.jsp'>[Return to Home]</a>

	<p style="font-size: 30px;">FAQs</p>
	
	<form action="ask.jsp" method="POST">

        <label for="ask">Ask a question:</label>
        <input type="text" name="ask" id="ask" required style="width: 340px;">

        <input type="submit" value="Ask" style="width: 53px;">       
         
    </form>
    
    	<form action="search.jsp" method="POST">

        <label for="search">Search for a question:</label>
        <input type="text" name="search" id="search" required style="width: 300px;">

        <input type="submit" value="Search">       
         
    </form>
    
    <br>
    <br>
    
    <%

    ApplicationDB db = null;
    Connection con = null;

    try {
    	
        db = new ApplicationDB();
        con = db.getConnection();
        
        
        String str = "SELECT * FROM QuestionAnswer;";
        PreparedStatement preparedStatement = con.prepareStatement(str);
		ResultSet result = preparedStatement.executeQuery();
       
	%>
	
		<table>
	
		<tr>    
			<td><u>Questionnn</u></td>
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