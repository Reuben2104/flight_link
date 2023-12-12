<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalTime" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Flight Results</title>
	</head>
	<body>
	
	<form action="reserve.jsp" method="post"> <!-- Added form for submitting selected values -->
	
		<% 
		
		ApplicationDB db = null;
	    Connection con = null;
		
			try {
	
			//Get the database connection
			db = new ApplicationDB();	
			con = db.getConnection();		

			//Create a SQL statement
			Statement stmt = con.createStatement();
			
			//Get the selected radio button from the index.jsp
			String flexibleOrNot = request.getParameter("flexible_or_not");
		    String oneOrRound = request.getParameter("one_or_round");
		    String departureAirport = request.getParameter("departure_airport");
		    String arrivalAirport = request.getParameter("arrival_airport");
		    String flightDateStr = request.getParameter("flight_date");
		    String isDomestic = request.getParameter("is_domestic");
		    	
		    session.setAttribute("isDomestic", isDomestic);
		    session.setAttribute("oneOrRound", oneOrRound);
		    
		    String sortOption = request.getParameter("sort");
		    String sortString = "";
		    
		    if (sortOption.equals("1")) { // sort by Price
		        sortString += " ORDER BY price ASC"; 
		    } else if (sortOption.equals("2")) {
		    	sortString += " ORDER BY departure_time";
		    } else if (sortOption.equals("3")) {
		    	sortString += " ORDER BY arrival_time";
		    } else if (sortOption.equals("4")) { // sort by duration of flight
		    	sortString += " ORDER BY TIMESTAMPDIFF(MINUTE, departure_time, arrival_time)";
		    }
	
			String filter_price = request.getParameter("filter_price");
			String filter_airline = request.getParameter("filter_airline");
			String filter_takeoff_time = request.getParameter("filter_takeoff_time");
			String filter_landing_time = request.getParameter("filter_landing_time");
			
	
			DateTimeFormatter inputFormatter = DateTimeFormatter.ofPattern("H:mm");
			DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("HH:mm:ss");

			if (filter_takeoff_time != null && !filter_takeoff_time.isEmpty()) {
			    LocalTime takeoffTime = LocalTime.parse(filter_takeoff_time, inputFormatter);
			    filter_takeoff_time = takeoffTime.format(outputFormatter);
			}

			if (filter_landing_time != null && !filter_landing_time.isEmpty()) {
			    LocalTime landingTime = LocalTime.parse(filter_landing_time, inputFormatter);
			    filter_landing_time = landingTime.format(outputFormatter);
			}


			String filterString = "";
			
			if (filter_price != null && !filter_price.isEmpty()) {
				filterString += " AND price <= ?";
			}

			if (filter_airline != null && !filter_airline.isEmpty()) {
				filterString += " AND airline_id = ?";
			}

			if (filter_takeoff_time != null && !filter_takeoff_time.isEmpty()) {
				filterString += " AND departure_time = ?";
			}

			if (filter_landing_time != null && !filter_landing_time.isEmpty()) {
				filterString += " AND arrival_time = ?";
			}
			
			
		    String threeDaysBeforeStr = null;
		    String threeDaysAfterStr = null;
			
			
			String str = "SELECT * FROM Flight WHERE ";
	
			if (flexibleOrNot.equals("1")) { // + or - 3 days
				DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
				LocalDate flightDate = LocalDate.parse(flightDateStr, formatter);

				LocalDate threeDaysBefore = flightDate.minusDays(3);
				LocalDate threeDaysAfter = flightDate.plusDays(3);

				threeDaysBeforeStr = threeDaysBefore.format(formatter);
				threeDaysAfterStr = threeDaysAfter.format(formatter);

				str += "departure_airport = ? AND destination_airport = ? AND is_domestic = ? AND departure_date BETWEEN ? AND ?" + filterString + sortString;
				
			} else {
				
				str += "departure_airport = ? AND destination_airport = ? AND is_domestic = ? AND departure_date = ?" + filterString + sortString;
				
			}


			PreparedStatement preparedStatement = con.prepareStatement(str);
			preparedStatement.setString(1, departureAirport);
			preparedStatement.setString(2, arrivalAirport);
			preparedStatement.setString(3, isDomestic);
			
			
			int counter = 5;
			
			if (flexibleOrNot.equals("1")) { // + or - 3 days
				preparedStatement.setString(4, threeDaysBeforeStr);
				preparedStatement.setString(5, threeDaysAfterStr);
				counter++;
			} else {
				preparedStatement.setString(4, flightDateStr);
			}
			
			
			if (filter_price != null && !filter_price.isEmpty()) {
			    preparedStatement.setString(counter, filter_price);
			    counter++;
			}

			if (filter_airline != null && !filter_airline.isEmpty()) {
			    preparedStatement.setString(counter, filter_airline);
			    counter++;
			}

			if (filter_takeoff_time != null && !filter_takeoff_time.isEmpty()) {
			    preparedStatement.setString(counter, filter_takeoff_time);
			    counter++;
			}

			if (filter_landing_time != null && !filter_landing_time.isEmpty()) {
			    preparedStatement.setString(counter, filter_landing_time);
			    counter++;
			}


			ResultSet result = preparedStatement.executeQuery();
			
			ResultSet result2 = null;
			
			if (oneOrRound.equals("0")) {
				
				String str2 = "SELECT * FROM Flight WHERE ";

				if (flexibleOrNot.equals("1")) { // + or - 3 days
					DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
					LocalDate flightDate = LocalDate.parse(flightDateStr, formatter);

					LocalDate threeDaysBefore = flightDate.minusDays(3);
					LocalDate threeDaysAfter = flightDate.plusDays(3);

					threeDaysBeforeStr = threeDaysBefore.format(formatter);
					threeDaysAfterStr = threeDaysAfter.format(formatter);

					str2 += "departure_airport = ? AND destination_airport = ? AND is_domestic = ? AND departure_date BETWEEN ? AND ?" + filterString + sortString;
				} else {
					str2 += "departure_airport = ? AND destination_airport = ? AND is_domestic = ? AND departure_date = ?" + filterString + sortString;
				}

				PreparedStatement preparedStatement2 = con.prepareStatement(str2);
				preparedStatement2.setString(1, arrivalAirport);
				preparedStatement2.setString(2, departureAirport);
				preparedStatement2.setString(3, isDomestic);
				
				int counter2 = 5;
				
				if (flexibleOrNot.equals("1")) { // + or - 3 days
					preparedStatement2.setString(4, threeDaysBeforeStr);
					preparedStatement2.setString(5, threeDaysAfterStr);
					counter2++;
				} else {
					preparedStatement2.setString(4, flightDateStr);
				}
				
				
				if (filter_price != null && !filter_price.isEmpty()) {
				    preparedStatement2.setString(counter2, filter_price);
				    counter2++;
				}

				if (filter_airline != null && !filter_airline.isEmpty()) {
				    preparedStatement2.setString(counter2, filter_airline);
				    counter2++;
				}

				if (filter_takeoff_time != null && !filter_takeoff_time.isEmpty()) {
				    preparedStatement2.setString(counter2, filter_takeoff_time);
				    counter2++;
				}

				if (filter_landing_time != null && !filter_landing_time.isEmpty()) {
				    preparedStatement2.setString(counter2, filter_landing_time);
				    counter2++;
				}

				result2 = preparedStatement2.executeQuery();
				
			}
		
			
		%>
		
	<p><b>Departing Flight:</b><p>
	
<%--
	<%= filter_price %>
	<%= filter_airline %>
	<%= filter_takeoff_time %>
	<%= filter_landing_time %> 
--%>

	<table>
	
		<tr>    
			<td><u>Select</u></td>
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
		        <td><input type="radio" name=departingFlightNumber value="<%= flightNumber %>"></td> <!-- Added radio button -->
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
			if (oneOrRound.equals("1")) {
		
		%>
		
		<br>
		
		<b>Reserve Flight:</b><input type="submit" value="Reserve"> <!-- Added submit button -->
			
		<%
			}
		
			if (oneOrRound.equals("0")) {
		
		%>
		
		<p><b>Returning Flight:</b><p>
		
		<table>
	
		<tr>    
			<td><u>Select</u></td>
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
		
			while (result2.next()) {
			
				String flightNumber = result2.getString("flight_number");
				String printDate = result2.getString("departure_date");
				String printAirline = result2.getString("airline_ID");
				String departure = result2.getString("departure_airport");
			    String destination = result2.getString("destination_airport");
			    String departureTime = result2.getString("departure_time");
			    String arrivalTime = result2.getString("arrival_time");
			    String priceString = result2.getString("price");
			
			%>
			    
			<tr>
		        <td><input type="radio" name="returningFlightNumber" value="<%= flightNumber %>"></td> <!-- Added radio button -->
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
	
	<br>
	<br>
	
	<b>Reserve Flight(s):</b><input type="submit" value="Reserve"> <!-- Added submit button -->

    </form> 

		<%	
			}

		
		} catch (Exception e) {
		    out.print(e);
		} finally {
			// close the connection in a finally block to ensure it happens regardless of exceptions
			db.closeConnection(con);
		}
		
		%>
	

	</body>
</html>