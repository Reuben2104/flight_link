<%@ page import ="java.sql.*" %>
<%
String userid = request.getParameter("username");
String pwd = request.getParameter("password");

if ("admin".equals(userid) && "adminpass".equals(pwd)) {

    response.sendRedirect("adminDash.jsp");
    return;
}

Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/users","root","LogMe@2021");

Statement st = con.createStatement();

ResultSet rs;
rs = st.executeQuery("select * from Customer where username='" + userid + "' and password='" + pwd + "'");

if (rs.next()) {  
	session.setAttribute("user", userid); // the username will be stored in the session
	out.println("welcome " + userid);
	out.println("<a href='logout.jsp'>Log out</a>");
			
	String accountType = rs.getString("account_type"); 

    if ("customer representative".equals(accountType)) {
        response.sendRedirect("customerRep.jsp");
        return;
    } else {
        response.sendRedirect("success.jsp");
    }
	
} else {
	out.println("Invalid password <a href='login.jsp'>try again</a>");
}
%>