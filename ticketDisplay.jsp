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
        
        ArrayList flight_info_list = (ArrayList<String>) session.getAttribute("flight_info_list");

        // String departingFlightNumber = (String) session.getAttribute("departingFlightNumber");
        // String departingAirlineID = (String) session.getAttribute("departingAirlineID");
        // String returningFlightNumber = (String) session.getAttribute("returningFlightNumber");
        // String returningAirlineID = (String) session.getAttribute("returningAirlineID");
       
        String fname = request.getParameter("fname");
        String lname = request.getParameter("lname");
        
        
        String ssn = request.getParameter("ssn");
        String passengerID = ssn.replace("-", "");

        Date currentDate = new Date();
        String dateTimeString = dateFormat.format(currentDate);
        session.setAttribute("dateTimeString", dateTimeString);
        String oneOrRound = (String) session.getAttribute("oneOrRound"); 
        
        for(ArrayList<String> flight: flight_info_list){
            String flight_airline_id = flight.get(0);
            String flight_number = flight.get(1);

            String flightQuery = "SELECT * FROM Flight WHERE flight_number = ? AND airline_ID = ?";
            PreparedStatement flightStmt = con.prepareStatement(flightQuery);
            flightStmt.setString(1, flight_number);
            flightStmt.setString(2, flight_airline_id);
            ResultSet flightResult = flightStmt.executeQuery();

            if (flightResult.next()) {
                String flight_price = flightResult.getString("price");
                String is_domestic = flightResult.getString("is_domestic");
                flight.add(flight_price); // Flight price at index 2
                flight.add(is_domestic); // Flight domestic/international status at index 3
                String flightDetailsString = "Departing Flight: " +
                    "Flight Number - " + flightResult.getString("flight_number") +
                    ", Departure Date - " + flightResult.getString("departure_date") +
                    ", Airline - " + flightResult.getString("airline_ID") +
                    ", Departure Airport - " + flightResult.getString("departure_airport") +
                    ", Arrival Airport - " + flightResult.getString("destination_airport") +
                    ", Departure Time - " + flightResult.getString("departure_time") +
                    ", Arrival Time - " + flightResult.getString("arrival_time") +
                    ", Price - $" + flightResult.getString("price");

                out.println("<p>" + flightDetailsString + "</p>");
            }
        }

        //DONE: Move Initializing variables here (booking fee, price, classType, oneOrRound...)
        //DONE: Populate these variables after querying for them (departing | returning)
        //DONE: Add to session attributes
        //DONE: Refactor logic of bookingfee/revenue/classtype/totalprice to reflect new variables and names
        //Refactor display to show Flight details
        //Send the flight details string created after query into successful reservation. 
        //Show this string after confirmation and not only ticket number!

        //DONE: Good to have: instead of structuring the info as departing and returning, 
        //DONE: we can save session info to contain a list of flights and make everything quicker 
        //DONE: instead of maintaining so many variables

        
        
        // String departingFlightQuery = "SELECT * FROM Flight WHERE flight_number = ? AND airline_ID = ? ";
        // PreparedStatement departingFlightStmt = con.prepareStatement(departingFlightQuery);
        // departingFlightStmt.setString(1, departingFlightNumber);
        // departingFlightStmt.setString(2, departingAirlineID);
        // ResultSet departingFlightResult = departingFlightStmt.executeQuery();

        // if (departingFlightResult.next()) {
        //     // String airlineID = departingFlightResult.getString("airline_ID");
        //     // session.setAttribute("airlineID", airlineID);
        //     String departingFlightDetails = "Departing Flight: " +
        //         "Flight Number - " + departingFlightResult.getString("flight_number") +
        //         ", Departure Date - " + departingFlightResult.getString("departure_date") +
        //         ", Airline - " + departingFlightResult.getString("airline_ID") +
        //         ", Departure Airport - " + departingFlightResult.getString("departure_airport") +
        //         ", Arrival Airport - " + departingFlightResult.getString("destination_airport") +
        //         ", Departure Time - " + departingFlightResult.getString("departure_time") +
        //         ", Arrival Time - " + departingFlightResult.getString("arrival_time") +
        //         ", Price - $" + departingFlightResult.getString("price");

        //     out.println("<p>" + departingFlightDetails + "</p>");
        // }

        // // Retrieve returning flight details
        // String returningFlightQuery = "SELECT * FROM Flight WHERE flight_number = ? AND airline_ID = ? ";
        // PreparedStatement returningFlightStmt = con.prepareStatement(returningFlightQuery);
        // returningFlightStmt.setString(1, returningFlightNumber);
        // departingFlightStmt.setString(2, returningAirlineID);
        // ResultSet returningFlightResult = returningFlightStmt.executeQuery();

        // if (returningFlightResult.next()) {
        //     // String airlineID2 = returningFlightResult.getString("airline_ID");
        //     // session.setAttribute("airlineID2", airlineID2);
        //     String returningFlightDetails = "Returning Flight: " +
        //         "Flight Number - " + returningFlightResult.getString("flight_number") +
        //         ", Departure Date - " + returningFlightResult.getString("departure_date") +
        //         ", Airline - " + returningFlightResult.getString("airline_ID") +
        //         ", Departure Airport - " + returningFlightResult.getString("departure_airport") +
        //         ", Arrival Airport - " + returningFlightResult.getString("destination_airport") +
        //         ", Departure Time - " + returningFlightResult.getString("departure_time") +
        //         ", Arrival Time - " + returningFlightResult.getString("arrival_time") +
        //         ", Price - $" + returningFlightResult.getString("price");

        //     out.println("<p>" + returningFlightDetails + "</p>");
        // }
        
        
 


           
        

        
        // String str = "SELECT * FROM Flight WHERE flight_number = ?";
        // PreparedStatement preparedStatement = con.prepareStatement(str);
		// preparedStatement.setString(1, departingFlightNumber);
		// ResultSet result = preparedStatement.executeQuery();
		
		// String priceString = "0";
		// String isDomestic = "";
		
		// if (result.next()) {
		//     priceString = result.getString("price");
		//     isDomestic = result.getString("is_domestic");
		// }

        ArrayList<String> flight_1 = flight_info_list.get(0);
		double price = Double.parseDouble(flight_1.get(2));
		double classFee = 0.0;
        String classType = request.getParameter("class_type");
        flight_1.add(class_type); // Flight class at index 4
        //Computing class upcharge
		if (classType.compareTo("Business") == 0) {
			classFee = price * 0.05;
		}
		else if (classType.compareTo("First Class") == 0) {
			classFee = price * 0.10;
		}
		//Computing booking fee based on domestic/international
		double bookingFee = 0.0;
		if (flight_1.get(3).equals("1")) {
			bookingFee = 25;
		}
		else{
			bookingFee = 50;
		}

        double price2 = 0.0;
        String classType2 = "";
        double classFee2 = 0.0;
        double bookingFee2 = 0.0;
        if(flight_info_list.size()>1){ // This list will only be longer than 1 when it is roundtrip
            ArrayList<String> flight_2 = flight_info_list.get(1);
            price2 = Double.parseDouble(flight_2.get(2));
        
		    classType2 = request.getParameter("class_type2");
            flight_2.add(class_type2);
			// price2 = Double.parseDouble(flight_2.get(2));
            if (flight_2.get(3).equals("1")) {
                bookingFee2 = 25;
            }
            else{
                bookingFee2 = 50;
            }
			if (classType2.compareTo("Business") == 0) {
				classFee2 += price2 * 0.05;
			}
			
			if (classType2.compareTo("First Class") == 0) {
				classFee2 += price2 * 0.10;
			}
		}
		String totalBookingFee = "" + (bookingFee + bookingFee2);
		String totalFare = "" + (price + bookingFee + classFee + price2 + classFee2 + bookingFee2);
		
		session.setAttribute("totalBookingFee", totalBookingFee);
        session.setAttribute("totalFare", totalFare);
        session.setAttribute("fname", fname);
        session.setAttribute("lname", lname);
        session.setAttribute("passengerID", passengerID);
        // session.setAttribute("classType", classType);
        // session.setAttribute("flightNum", departingFlightNumber);
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