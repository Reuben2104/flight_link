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
<title>Upcoming Reservations</title>
</head>
<body>
<a href='success.jsp'>[Return to Search Page]</a>


    <%

    ApplicationDB db = null;
    Connection con = null;

    try {
    	
        db = new ApplicationDB();
        con = db.getConnection();
        
        Date currentDate = new Date();
        String currentDateString = dateFormat.format(currentDate);
        
//    	session.setAttribute("user", userid); // the username will be stored in the session
        String username = (String) session.getAttribute("user");
        
         
        String str = "SELECT DISTINCT f.flight_number, fc.ticket_number " + 
        	"FROM Flight f " + 
	        "JOIN FlightCapacity fc ON f.flight_number = fc.flight_number AND f.airline_ID = fc.airline_ID " + 
	        "JOIN Bookings b ON fc.ticket_number = b.ticket_number " + 
	        "WHERE b.username = ? AND f.departure_date >= ?;";	      
        
        PreparedStatement preparedstatement = con.prepareStatement(str);
        preparedstatement.setString(1, username);
        preparedstatement.setString(2, currentDateString);
        ResultSet flightNumbersResult = preparedstatement.executeQuery(); 

        
	%>
	
	<p style="font-size: 30px;">Upcoming Reservations:</p>
	<form action="reservationEditDeleteHandler.jsp" method="post">
    <table>
        <tr>    
            <td><u>Action</u></td>
            <td><u>Ticket Number</u></td>
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
        while (flightNumbersResult.next()) {
            
            int flightNumber = flightNumbersResult.getInt("flight_number");
            int ticketNumber = flightNumbersResult.getInt("ticket_number");
        
            String flightInfoQuery = "SELECT * FROM Flight WHERE flight_number = ?";
            
            try (PreparedStatement flightInfoStatement = con.prepareStatement(flightInfoQuery)) {
                
                flightInfoStatement.setInt(1, flightNumber);
        
                ResultSet flightInfoResult = flightInfoStatement.executeQuery();
        
                while (flightInfoResult.next()) {
                    
                    String flightNumberPrint = flightInfoResult.getString("flight_number");
                    String printDate = flightInfoResult.getString("departure_date");
                    String printAirline = flightInfoResult.getString("airline_ID");
                    String departure = flightInfoResult.getString("departure_airport");
                    String destination = flightInfoResult.getString("destination_airport");
                    String departureTime = flightInfoResult.getString("departure_time");
                    String arrivalTime = flightInfoResult.getString("arrival_time");
                    String priceString = flightInfoResult.getString("price");
        %>
                    <tr>
                        <td>
                            <button type="submit" name="delete" value="<%= ticketNumber %>">Delete</button>
                        </td>
                        <td><%= ticketNumber %></td>
                        <td><%= flightNumberPrint %></td>
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
            }
        }
        %>
    </table>
</form>

<%
} catch (Exception e) {
    out.print(e);
} finally {
    db.closeConnection(con);
}
%>

</body>
</html>