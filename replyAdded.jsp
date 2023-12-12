<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Reply Added</title>
</head>
<body>	
    <%

    ApplicationDB db = null;
    Connection con = null;

    try {
    	
        db = new ApplicationDB();
        con = db.getConnection();
        
        String reply = request.getParameter("reply");
        String question = request.getParameter("question");

        String str = "UPDATE QuestionAnswer SET answer = ? WHERE question = ?";
        PreparedStatement pstmt = con.prepareStatement(str);
        pstmt.setString(1, reply);
        pstmt.setString(2, question);
        pstmt.executeUpdate();
        
	%>
	
	<p>Reply Submitted Successfully<p>
	<p>Your reply has been submitted. You will be redirected Answer FAQ page shortly.</p>

   <%
      response.setHeader("Refresh", "3; URL=reply.jsp");
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



