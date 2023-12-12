<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Ask Question</title>
</head>
<body>
	
    <%

    ApplicationDB db = null;
    Connection con = null;

    try {
    	
        db = new ApplicationDB();
        con = db.getConnection();
        
        
        String question = request.getParameter("ask");

        String str = "INSERT INTO QuestionAnswer VALUES (?, '(Question will be answered shortly by a Customer Representative)')";
        
        PreparedStatement pstmt = con.prepareStatement(str);
        pstmt.setString(1, question);
        pstmt.executeUpdate();
        
	%>
	
	<p>Question Submitted Successfully<p>
	<p>Your question has been submitted. You will be redirected to the FAQ page shortly.</p>

   <%
      response.setHeader("Refresh", "3; URL=faqs.jsp");
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



