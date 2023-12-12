<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Ticket Information</title>
</head>
<body>

    <p style="font-size: 30px;">Selected flight(s):</p>

    <%

    String departingFlightNumber = request.getParameter("departingFlightNumber");
    String returningFlightNumber = request.getParameter("returningFlightNumber");
    
    session.setAttribute("departingFlightNumber", departingFlightNumber);
    session.setAttribute("returningFlightNumber", returningFlightNumber);

    ApplicationDB db = null;
    Connection con = null;

    try {
        db = new ApplicationDB();
        con = db.getConnection();
        
        String departingFlightQuery = "SELECT * FROM Flight WHERE flight_number = ?";
        PreparedStatement departingFlightStmt = con.prepareStatement(departingFlightQuery);
        departingFlightStmt.setString(1, departingFlightNumber);
        ResultSet departingFlightResult = departingFlightStmt.executeQuery();

        if (departingFlightResult.next()) {
            String departingFlightDetails = "Departing Flight: " +
                "Flight Number - " + departingFlightResult.getString("flight_number") +
                ", Departure Date - " + departingFlightResult.getString("departure_date") +
                ", Airline - " + departingFlightResult.getString("airline_ID") +
                ", Departure Airport - " + departingFlightResult.getString("departure_airport") +
                ", Arrival Airport - " + departingFlightResult.getString("destination_airport") +
                ", Departure Time - " + departingFlightResult.getString("departure_time") +
                ", Arrival Time - " + departingFlightResult.getString("arrival_time") +
                ", Price - $" + departingFlightResult.getString("price");

            out.println("<p>" + departingFlightDetails + "</p>");
        }

        String returningFlightQuery = "SELECT * FROM Flight WHERE flight_number = ?";
        PreparedStatement returningFlightStmt = con.prepareStatement(returningFlightQuery);
        returningFlightStmt.setString(1, returningFlightNumber);
        ResultSet returningFlightResult = returningFlightStmt.executeQuery();

        if (returningFlightResult.next()) {
            String returningFlightDetails = "Returning Flight: " +
                "Flight Number - " + returningFlightResult.getString("flight_number") +
                ", Departure Date - " + returningFlightResult.getString("departure_date") +
                ", Airline - " + returningFlightResult.getString("airline_ID") +
                ", Departure Airport - " + returningFlightResult.getString("departure_airport") +
                ", Arrival Airport - " + returningFlightResult.getString("destination_airport") +
                ", Departure Time - " + returningFlightResult.getString("departure_time") +
                ", Arrival Time - " + returningFlightResult.getString("arrival_time") +
                ", Price - $" + returningFlightResult.getString("price");

            out.println("<p>" + returningFlightDetails + "</p>");
        }  
        
   %>   
   
   <p style="font-size: 30px;">Fill out ticket information:</p>
    
        
	<form action="ticketDisplay.jsp" method="POST">

        <label for="fname">First name:</label>
        <input type="text" name="fname" id="fname" required>

        <br>
        
        <label for="lname">Last name:</label>
        <input type="text" name="lname" id="lname" required>
                
        <br>

        <%
            String oneOrRound = (String) session.getAttribute("oneOrRound");
            if ("0".equals(oneOrRound)) {
        %>
        
        	<label for="class_type">Class (departing):</label>
	        <select name="class_type" id="class_type">
	            <option value="Economy">Economy</option>
	            <option value="Business">Business (5% up-charge)</option>
	            <option value="First Class">First Class (10% up-charge)</option>
	        </select>
			
			<br>
			
            <label for="class_type2">Class (returning):</label>
            <select name="class_type2" id="class_type2">
                <option value="Economy">Economy</option>
                <option value="Business">Business (5% up-charge)</option>
                <option value="First Class">First Class (10% up-charge)</option>
            </select>

        <%
            } else {
        %>
        
        	<label for="class_type">Class:</label>
	        <select name="class_type" id="class_type">
	            <option value="Economy">Economy</option>
	            <option value="Business">Business (5% up-charge)</option>
	            <option value="First Class">First Class (10% up-charge)</option>
	        </select>
        
        <%
            }
        %>
        
        <br>
        
        <label for="ssn">SSN (###-##-####):</label>
        <input type="password" name="ssn" id="ssn" required>
        
        <br>
        <br>
      
        <input type="submit" value="Submit">
        
         
    </form>
        
	
	<%
    } catch (Exception e) {
        out.print(e);
    } finally {
        // close the connection in a finally block to ensure it happens regardless of exceptions
        db.closeConnection(con);
    }
    %>

</body>
</html>
