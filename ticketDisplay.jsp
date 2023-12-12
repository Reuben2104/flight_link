<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>

<%! SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"); %>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Ticket Information</title>
</head>
<body>

    <p style="font-size: 30px;">Selected flight(s):</p>

	<%
	
    ApplicationDB db = null;
    Connection con = null;

    try {

    	db = new ApplicationDB();
        con = db.getConnection();
        
        String flightNum = (String) session.getAttribute("departingFlightNumber");
        String flightNum2 = (String) session.getAttribute("returningFlightNumber");
        
        
        String departingFlightQuery = "SELECT * FROM Flight WHERE flight_number = ?";
        PreparedStatement departingFlightStmt = con.prepareStatement(departingFlightQuery);
        departingFlightStmt.setString(1, flightNum);
        ResultSet departingFlightResult = departingFlightStmt.executeQuery();

        if (departingFlightResult.next()) {
            String airlineID = departingFlightResult.getString("airline_ID");
            session.setAttribute("airlineID", airlineID);
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

        // Retrieve returning flight details
        String returningFlightQuery = "SELECT * FROM Flight WHERE flight_number = ?";
        PreparedStatement returningFlightStmt = con.prepareStatement(returningFlightQuery);
        returningFlightStmt.setString(1, flightNum2);
        ResultSet returningFlightResult = returningFlightStmt.executeQuery();

        if (returningFlightResult.next()) {
            String airlineID = departingFlightResult.getString("airline_ID");
            session.setAttribute("airlineID", airlineID);
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
        
        String fname = request.getParameter("fname");
        String lname = request.getParameter("lname");
        String classType = request.getParameter("class_type");
        
        String ssn = request.getParameter("ssn");
        String passengerID = ssn.replace("-", "");
 


           
        Date currentDate = new Date();
        String dateTimeString = dateFormat.format(currentDate);
        session.setAttribute("dateTimeString", dateTimeString);

        
        String str = "SELECT * FROM Flight WHERE flight_number = ?";
        PreparedStatement preparedStatement = con.prepareStatement(str);
		preparedStatement.setString(1, flightNum);
		ResultSet result = preparedStatement.executeQuery();
		
		String priceString = "0";
		String isDomestic = "";
		
		if (result.next()) {
		    priceString = result.getString("price");
		    isDomestic = result.getString("is_domestic");
		}
		double price = Double.parseDouble(priceString);
		
		double classFee = 0.0;
		
		if (classType.compareTo("Business") == 0) {
			classFee = price * 0.05;
			
		}
		if (classType.compareTo("First Class") == 0) {
			classFee = price * 0.10;
		}
		
		double bookingFee = 0.0;
						
		if (isDomestic.equals("1")) {
			bookingFee = 25;
		}
			
		if (isDomestic.equals("0")) {
			bookingFee = 50;
		}
		

		String oneOrRound = (String) session.getAttribute("oneOrRound"); 
		String classType2 = "";
		String priceString2 = "0";
		double price2 = 0.0;
		ResultSet result2;
		double classFee2 = 0.0;
		
 		if (oneOrRound.equals("0")) {
		    classType2 = request.getParameter("class_type2");

			String str2 = "SELECT * FROM Flight WHERE flight_number = ?";
	        PreparedStatement preparedStatement2 = con.prepareStatement(str2);
			preparedStatement2.setString(1, flightNum2);
			result2 = preparedStatement2.executeQuery();
		
			if (result2.next()) {
			    priceString2 = result2.getString("price");
			}
			
			price2 = Double.parseDouble(priceString2);
			
			if (classType2.compareTo("Business") == 0) {
				classFee2 += price2 * 0.05;
			}
			
			if (classType2.compareTo("First Class") == 0) {
				classFee2 += price2 * 0.10;
			}
			
		}
		
		String totalFare = "" + (price + bookingFee + classFee + price2 + classFee2);
		
		session.setAttribute("bookingFee", bookingFee);
        session.setAttribute("totalFare", totalFare);
        session.setAttribute("fname", fname);
        session.setAttribute("lname", lname);
        session.setAttribute("passengerID", passengerID);
        session.setAttribute("classType", classType);
        session.setAttribute("flightNum", flightNum);
   %> 
   
   <p style="font-size: 30px;">Confirm Ticket:</p>
    
    First name: <%= fname %>
    <br>
    Last name: <%= lname %>
    
    <% if (oneOrRound.equals("0")) { %>
    
    <br>
    Class (departing): <%= classType %>
    <br>
    Class (returning): <%= classType2 %>
    <br>
    	
    <% } else { %>
    
    <br>
    Class: <%= classType %>
    <br>
    
    <% }%>
    
    Date/Time: <%= dateTimeString %>
    <br>
    Price: $<%= price + price2 %>
    <br>
    Booking fee: $<%= bookingFee %>
    <br>
    Total fare: $<%= totalFare %>
    <br>
    <br>
        
	<form action="successfulReservation.jsp" method="POST">
		
        <input type="submit" value="Reserve Ticket">
        
         
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