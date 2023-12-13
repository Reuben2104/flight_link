<%@ page import="java.io.*,java.util.*,java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<%
// Database connection setup
Connection con = null;
Class.forName("com.mysql.jdbc.Driver");
con = DriverManager.getConnection("jdbc:mysql://localhost:3306/users", "root", "LogMe@2021");


PreparedStatement pstmtTicket = null, pstmtFlightCapacity = null, pstmtBooking = null, pstmtWaitlist = null;
ResultSet rs = null;
String username = (String) session.getAttribute("user");
String action = request.getParameter("action");
String notificationID = "";
String waitlist_ID = "";
boolean bookingSuccessful = false;
int newTicketNumber = 0;

// If the 'Book' button was clicked

// Retrieve and display notifications
String notificationQuery = "SELECT notification_ID, message FROM Notifications WHERE username = ?";
try (PreparedStatement notificationStmt = con.prepareStatement(notificationQuery)) {
    notificationStmt.setString(1, username);
    ResultSet rs1 = notificationStmt.executeQuery();

    while (rs1.next()) {
        int listedNotificationId = rs1.getInt("notification_ID");
        String message = rs1.getString("message");

        out.println("<p>" + message + "</p>");

        // Display 'Book' button next to the message
        out.println("<form action='postBook.jsp' method='post'>");
        out.println("<input type='hidden' name='notificationID' value='" + listedNotificationId + "'>");
        out.println("<input type='hidden' name='action' value='book'>");
        out.println("<button type='submit'>Book</button>");
        out.println("</form>");
    } 



    out.println("<p>End of your notifications!</p>");

} catch (Exception e) {
    out.println("<p>Error retrieving notifications: " + e.getMessage() + "</p>");
}

if ("book".equals(action) && !notificationID.equals("")) {
    try {
        notificationID = request.getParameter("notificationID");
        String waitlistIDQuery = "SELECT waitlist_ID from Notifications WHERE notification_ID = ?";
        PreparedStatement waitlistIDps = con.prepareStatement(waitlistIDQuery);
        waitlistIDps.setInt(1,Integer.parseInt(notificationID));
        ResultSet waitlistrs = waitlistIDps.executeQuery();


        if(waitlistrs.next()){
            waitlist_ID = waitlistrs.getString("waitlist_ID");
        }
        String waitlistQuery = "SELECT * FROM Waitlist WHERE waitlist_ID = ?";
        pstmtWaitlist = con.prepareStatement(waitlistQuery);
        pstmtWaitlist.setInt(1, Integer.parseInt(waitlist_ID));
        rs = pstmtWaitlist.executeQuery();

        if (rs.next()) {
            int flightNumber = rs.getInt("flight_number");
            String airlineID = rs.getString("airline_ID");
            String classType = rs.getString("class");
            String fname = rs.getString("fname");
            String lname = rs.getString("lname");
            int passengerId = rs.getInt("passenger_id");

            // Generate a new ticket number
            newTicketNumber = (int)(Math.random() * 1000000);

            // Insert into Ticket
            String insertTicketSQL = "INSERT INTO Ticket (ticket_number, fname, lname, purchase_date_time, passenger_id) VALUES (?, ?, ?, NOW(), ?)";
            pstmtTicket = con.prepareStatement(insertTicketSQL);
            pstmtTicket.setInt(1, newTicketNumber);
            pstmtTicket.setString(2, fname);
            pstmtTicket.setString(3, lname);
            pstmtTicket.setInt(4, passengerId);
            pstmtTicket.executeUpdate();

            // Insert into FlightCapacity
            String insertFlightCapacitySQL = "INSERT INTO FlightCapacity (ticket_number, flight_number, airline_ID, class) VALUES (?, ?, ?, ?)";
            pstmtFlightCapacity = con.prepareStatement(insertFlightCapacitySQL);
            pstmtFlightCapacity.setInt(1, newTicketNumber);
            pstmtFlightCapacity.setInt(2, flightNumber);
            pstmtFlightCapacity.setString(3, airlineID);
            pstmtFlightCapacity.setString(4, classType);
            pstmtFlightCapacity.executeUpdate();

            // Insert into Bookings
            String insertBookingSQL = "INSERT INTO Bookings (username, ticket_number) VALUES (?, ?)";
            pstmtBooking = con.prepareStatement(insertBookingSQL);
            pstmtBooking.setString(1, username);
            pstmtBooking.setInt(2, newTicketNumber);
            pstmtBooking.executeUpdate();

            // Delete from Waitlist
            String deleteWaitlistSQL = "DELETE FROM Waitlist WHERE waitlist_ID = ?";
            pstmtWaitlist = con.prepareStatement(deleteWaitlistSQL);
            pstmtWaitlist.setInt(1, Integer.parseInt(notificationID));
            pstmtWaitlist.executeUpdate();

            bookingSuccessful = true;
        }
    } catch (Exception e) {
        // Handle exceptions
        out.println("<p>Error during booking: " + e.getMessage() + "</p>");
    }
}



// Display booking confirmation
if (bookingSuccessful) {

    out.println("<p>Your ticket has been booked. Here is your ticket number: " + newTicketNumber + "</p>");
}
%>