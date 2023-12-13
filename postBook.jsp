<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Reservation Success</title>
</head>
<body>
<%
    int nextTicketNumber = (int)(Math.random() * 1000000);
    out.println("<h2>Your ticket has been successfully booked.</h2>");
    out.println("<p>Your ticket number is: " + nextTicketNumber + ".</p>");
%>
</body>
</html>
