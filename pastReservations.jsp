<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>

<%! SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd"); %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Past Reservations</title>
</head>
<body>

<%-- 

    <%

    ApplicationDB db = null;
    Connection con = null;

    try {
    	
        db = new ApplicationDB();
        con = db.getConnection();
        
        Date currentDate = new Date();
        String currentDateString = dateFormat.format(currentDate);
        
        /* 
        
        String str = "SELECT * FROM Flight WHERE username = ? AND departure_date < ?;";
        
        PreparedStatement preparedstatement = con.prepareStatement(str);
        preparedstatement.setString(1, username);
        preparedstatement.setString(2, currentDateString);
        ResultSet result = preparedstatement.executeQuery(); 
        
        */
        
	%>
	
	<p style="font-size: 30px;">Past Reservations:</p>
	
	<!-- EDIT BASED ON TICKET INFO -->
	
<table>
	
		<tr>    
			<td><u>Flight Number</u></td>
			<td><u>Departure Date</u></td>
			<td><u>Airline</u></td>
			<td><u>Destination Airport</u></td>
			<td><u>Arrival Airport</u></td>
			<td><u>Departure Time</u></td>
			<td><u>Arrival Time</u></td>
			<td><u>Price</u></td>
			
		</tr>
		
			<%
		
			while (result.next()) {
			
				String flightNumber = result.getString("flight_number");
				String printDate = result.getString("departure_date");
				String printAirline = result.getString("airline_ID");
				String departure = result.getString("departure_airport");
			    String destination = result.getString("destination_airport");
			    String departureTime = result.getString("departure_time");
			    String arrivalTime = result.getString("arrival_time");
			    String priceString = result.getString("price");
			
			%>
			    
			<tr>
		        <td><%= flightNumber %></td>
		        <td><%= printDate %></td>
		        <td><%= printAirline %></td>
		        <td><%= departure %></td>
		        <td><%= destination %></td>
		        <td><%= departureTime %></td>
		        <td><%= arrivalTime %></td>
		        <td>$<%= priceString %></td>
		  
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
    
     --%>

</body>
</html>

