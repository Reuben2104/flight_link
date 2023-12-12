<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Customer Representative Dashboard</title>
</head>
<body>
<a href='logout.jsp'>[Log out]</a>

	<h1>Customer Representative Dashboard</h1>
	
	<!-- 
		Make flight reservations on behalf of users
		Edit flight reservations for a customer
		Add, Edit, Delete information for aircrafts, airports, and flights
		Retrieve a list of all the passengers who are on the waiting list of a particular flight
		Produce a list of all flights for a given airport (departing and arriving)
		Reply to user’s questions DONE
	 -->
	
	<a href='reply.jsp'>[Reply to Customer's Questions]</a>
	
	<br>
	<br>
	
	<a href='crMakeReservation.jsp'>[Make Flight Reservations for User]</a>
	
	<br>
	<br>
	
	<a href='crEditReservation.jsp'>[Edit Flight Reservations for User]</a>
	
	<br>
	<br>
	
	<a href='crViewWaitlist'>[View Waiting Lists]</a>
	
	<br>
	<br>
	
	<a href='crEditAirportInfo.jsp'>[Edit Info for Aircrafts, Airports, and Flights]</a>
	
	<br>
	<br>
	
	<a href='crlistFlights.jsp'>[List of all Flights for a given Airport]</a>

</body>
</html>