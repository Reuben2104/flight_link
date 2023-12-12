<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Reservation Success</title>
</head>
<body>

<%

    // Retrieve session attributes
    String fname = (String) session.getAttribute("fname");
    String lname = (String) session.getAttribute("lname");
    String passengerID = (String) session.getAttribute("passengerID");
    String classType = (String) session.getAttribute("classType");
    String flightNum = (String) session.getAttribute("flightNum");
    Double bookingFee = (Double) session.getAttribute("bookingFee");
    String totalFare = (String) session.getAttribute("totalFare");
    String dateTimeString = (String) session.getAttribute("dateTimeString");
    String airlineID = (String) session.getAttribute("airlineID");
    String username = (String) session.getAttribute("user");


    

    Connection conn = null;
    PreparedStatement pstmtTicket = null;
    PreparedStatement pstmtFlightCap = null;
    PreparedStatement pstmtWaitlist = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/users", "root", "LogMe@2021");

        // Assuming flightNumber is passed from previous page
        String flightNumber = request.getParameter("flightNumber");

        // Check Flight Capacity
        String query = "SELECT COUNT(*) AS ticketCount FROM FlightCapacity WHERE flight_number = " + flightNum;
        Statement stmt = conn.createStatement();
        rs = stmt.executeQuery(query);
        int ticketCount = 0;
        if (rs.next()) {
            ticketCount = rs.getInt("ticketCount");
        }
        stmt.close();

        final int FLIGHT_CAPACITY = 10; // Define the flight capacity

        int nextTicketNumber;
        boolean isUnique;
        do {
            nextTicketNumber = (int)(Math.random() * 1000000); // Generate a random ticket number

            String checkTicketNumberSQL = "SELECT COUNT(*) FROM Ticket WHERE ticket_number = ?";
            PreparedStatement checkTicketStmt = conn.prepareStatement(checkTicketNumberSQL);
            checkTicketStmt.setInt(1, nextTicketNumber);
            ResultSet checkTicketRs = checkTicketStmt.executeQuery();
            isUnique = !checkTicketRs.next() || checkTicketRs.getInt(1) == 0;
            checkTicketRs.close();
            checkTicketStmt.close();
        } while (!isUnique);


        if (ticketCount < FLIGHT_CAPACITY) {
            String insertTicketSQL = "INSERT INTO Ticket (ticket_number, fname, lname, purchase_date_time, passenger_id, booking_fee, total_fare) VALUES (?, ?, ?, NOW(), ?, ?, ?)";
            pstmtTicket = conn.prepareStatement(insertTicketSQL);

            //Insert into Ticket
            pstmtTicket.setInt(1, nextTicketNumber); // Ticket number
            pstmtTicket.setString(2, fname); // First name
            pstmtTicket.setString(3, lname); // Last name
            // The fourth placeholder is for 'purchase_date_time', which is set to NOW() in the SQL
            pstmtTicket.setString(4, passengerID); // Passenger ID
            pstmtTicket.setDouble(5, bookingFee); // Booking fee
            pstmtTicket.setDouble(6, Double.parseDouble(totalFare)); // Total fare

            pstmtTicket.executeUpdate();

            // Insert into FlightCapacity table
            String insertFlightCapSQL = "INSERT INTO FlightCapacity (ticket_number, flight_number, airline_ID, class, seat_number) VALUES (?, ?, ?, ?, ?)";
            pstmtFlightCap = conn.prepareStatement(insertFlightCapSQL);

            pstmtFlightCap.setInt(1, nextTicketNumber);
            pstmtFlightCap.setString(2, flightNum); // Flight number from session
            pstmtFlightCap.setString(3, airlineID);            
            pstmtFlightCap.setString(4, classType); // Class from session
            pstmtFlightCap.setString(5, "12A"); // Seat number (modify as needed)

            pstmtFlightCap.executeUpdate();

            // Insert into Bookings table
            String insertBookingSQL = "INSERT INTO Bookings (username, ticket_number) VALUES (?, ?)";
            PreparedStatement pstmtBooking = conn.prepareStatement(insertBookingSQL);

            pstmtBooking.setString(1, username); // Username of the customer
            pstmtBooking.setInt(2, nextTicketNumber); // The generated ticket number

            pstmtBooking.executeUpdate();

            out.println("<h2>Your ticket has been successfully booked.</h2>");
            out.println("<p>Your ticket number is: " + nextTicketNumber + ".</p>");
        } else {
           
           String insertWaitlistSQL = "INSERT INTO Waitlist (username, flight_number) VALUES (?,?)";
           pstmtWaitlist = conn.prepareStatement(insertWaitlistSQL);

           pstmtWaitlist.setString(1,username);
           pstmtWaitlist.setInt(2, Integer.parseInt(flightNum));

           pstmtWaitlist.executeUpdate();


            out.println("<h2>Flight is full. You have been placed on the waiting list.</h2>");
        }

    } catch (Exception e) {
        out.print(e);
    } 
%>

</body>
</html>