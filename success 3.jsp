<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
if ((session.getAttribute("user") == null)) {
%>
You are not logged in<br/>
<a href="login.jsp">Please Login</a>
<%} else {
%>
Welcome <%=session.getAttribute("user")%>!
<a href='logout.jsp'>[Log out]</a>
<a href='faqs.jsp'>[FAQs]</a>

<p style="font-size: 30px;">Search Flights</p>

    <form action="flightResults2.jsp" method="POST">
        
        <label for="flexible_or_not">Select Flexibility:</label>
        <select name="flexible_or_not" id="flexible_or_not">
            <!-- 1 means flexible, 0 means not -->
            <option value="1">Flexible</option>
            <option value="0">Not flexible</option>
        </select>
        
        <br> 
        
        <label for="one_or_round">Select One-way or Round-trip:</label>
        <select name="one_or_round" id="one_or_round">
            <!-- 1 means one way, 0 means round trip -->
            <option value="1">One-way</option>
            <option value="0">Round-trip</option>
        </select>

        <br>

        <label for="departure_airport">Departure Airport:</label>
        <input type="text" name="departure_airport" id="departure_airport" required placeholder="(ex. JFK)">
        
        <br>

        <label for="arrival_airport">Arrival Airport:</label>
        <input type="text" name="arrival_airport" id="arrival_airport" required required placeholder="(ex. DFW)">

        <br>
        
        <label for="is_domestic">Domestic or International:</label>
        <select name="is_domestic" id="is_domestic">
            <!-- 1 means domestic, 0 means international -->
            <option value="1">Domestic</option>
            <option value="0">International</option>
        </select>

		<br>
		
        <label for="flight_date">Select Date:</label>
        <input type="date" name="flight_date" id="flight_date" required>
        
        <br>
        <br>
        
        <label for="sort">Sort by:</label>
        <select name="sort" id="sort">
            <!-- 1 means one way, 0 means round trip -->
            <option value="0">None</option>
            <option value="1">Price</option>
            <option value="2">Take-off time</option>
            <option value="3">Landing time</option>
            <option value="4">Duration of flight</option>
        </select>
        
        <br>
        <br>
		
		
		<!-- 
		filter the list of flights by various criteria 
		(price, number of stops, airline, take-off time, landing time)
		filter_price, filter_airline, filter_takeoff_time, filter_landing_time 
		-->
		
		<label for="filter_price">Filter by Price:</label>
		<input type="number" name="filter_price" id="filter_price" placeholder="Enter maximum price">
		
		<br>
		
		<label for="filter_airline">Filter by Airline:</label>
		<input type="text" name="filter_airline" id="filter_airline" placeholder="Enter airline name">
		
		<br>
		
		<label for="filter_takeoff_time">Filter by Take-off Time:</label>
		<input type="time" name="filter_takeoff_time" id="filter_takeoff_time">
		
		<br>
		
		<label for="filter_landing_time">Filter by Landing Time:</label>
		<input type="time" name="filter_landing_time" id="filter_landing_time">

		<br>
		<br>

        <input type="submit" value="Search Flights">
                
    </form>
    
    



	
<%
}
%>