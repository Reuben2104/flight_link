<%@ page import="java.io.*,java.util.*,java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<%
// Assuming ApplicationDB and other necessary classes are properly imported
Connection con = null;
boolean deletionSuccessful = false;


ArrayList<ArrayList<String>> deletedFlightRes = new ArrayList<ArrayList<String>>();
try {

    Class.forName("com.mysql.jdbc.Driver");
    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/users", "root", "LogMe@2021");
   
    String username = (String) session.getAttribute("user");
    int ticketNumber = Integer.parseInt(request.getParameter("delete")); // Get the ticket number to delete
    String deletedFlightsQuery = "SELECT airline_ID, flight_number FROM FlightCapacity WHERE ticket_number = ?";
    try (PreparedStatement flightNumberRetrievalStmt = con.prepareStatement(deletedFlightsQuery)) {
        flightNumberRetrievalStmt.setInt(1, ticketNumber);
        ResultSet rs = flightNumberRetrievalStmt.executeQuery();
        while (rs.next()) {
            ArrayList<String> deletedFlight = new ArrayList<String>();
            deletedFlight.add(rs.getString("airline_ID"));
            deletedFlight.add(rs.getString("flight_number"));
            deletedFlightRes.add(deletedFlight);
        }
    }
    // Check if the ticket is economy class
    String classCheckQuery = "SELECT class FROM FlightCapacity WHERE ticket_number = ?";

    boolean isEconomy = false;

    try (PreparedStatement classCheckStmt = con.prepareStatement(classCheckQuery)) {
        classCheckStmt.setInt(1, ticketNumber);
        ResultSet rs = classCheckStmt.executeQuery();
        if (rs.next() && "economy".equalsIgnoreCase(rs.getString("class"))) {
            isEconomy = true;
        }
    }

    // Perform cascade deletion
    String deleteFlightCapacityQuery = "DELETE FROM FlightCapacity WHERE ticket_number = ?";
    String deleteBookingsQuery = "DELETE FROM Bookings WHERE ticket_number = ?";
    String deleteTicketQuery = "DELETE FROM Ticket WHERE ticket_number = ?";

    try (PreparedStatement deleteFlightCapacityStmt = con.prepareStatement(deleteFlightCapacityQuery);
         PreparedStatement deleteBookingsStmt = con.prepareStatement(deleteBookingsQuery);
         PreparedStatement deleteTicketStmt = con.prepareStatement(deleteTicketQuery)) {

        con.setAutoCommit(false); // Start transaction

        // Delete from FlightCapacity
        deleteFlightCapacityStmt.setInt(1, ticketNumber);
        deleteFlightCapacityStmt.executeUpdate();

        // Delete from Bookings
        deleteBookingsStmt.setInt(1, ticketNumber);
        deleteBookingsStmt.executeUpdate();

        // Delete from Ticket
        deleteTicketStmt.setInt(1, ticketNumber);
        deleteTicketStmt.executeUpdate();

        con.commit(); // Commit transaction
    }

    // Handle economy class cancellation fee
    if (isEconomy) {
        // Generate new ticket number (ensure it is unique)
        int newTicketNumber = (int)(Math.random() * 1000000); // Implement logic to generate a unique ticket number

        // Insert new ticket with fee
        String insertTicketQuery = "INSERT INTO Ticket (ticket_number, booking_fee) VALUES (?, 25)";
        String insertBookingQuery = "INSERT INTO Bookings (username, ticket_number) VALUES (?, ?)";

        try (PreparedStatement insertTicketStmt = con.prepareStatement(insertTicketQuery);
             PreparedStatement insertBookingStmt = con.prepareStatement(insertBookingQuery)) {

            con.setAutoCommit(false); // Start transaction

            // Insert into Ticket
            insertTicketStmt.setInt(1, newTicketNumber);
            insertTicketStmt.executeUpdate();

            // Insert into Bookings
            insertBookingStmt.setString(1, username);
            insertBookingStmt.setInt(2, newTicketNumber);
            insertBookingStmt.executeUpdate();

            con.commit(); // Commit transaction
        }
        
    }
    deletionSuccessful = true;
} catch (SQLException e) {
    // Handle SQL exceptions
    out.println("SQL Error: " + e.getMessage());
    try {
        con.rollback();
    } catch (SQLException se) {
        out.println("Rollback Error: " + se.getMessage());
    }
} catch (Exception e) {
    // Handle other exceptions
    out.println("Error: " + e.getMessage());
} 

if (deletionSuccessful) {
    out.println("<p>Reservation deleted successfully.</p>");
    for(ArrayList<String> deletedFlight: deletedFlightRes){
        String del_airline_ID = deletedFlight.get(0);
        String del_flight_number = deletedFlight.get(1);
        String waitlistQuery = "SELECT username, waitlist_ID FROM Waitlist WHERE flight_number = ? and airline_ID = ? ";
            try (PreparedStatement waitlistStmt = con.prepareStatement(waitlistQuery)) {
                waitlistStmt.setString(1, del_flight_number);
                waitlistStmt.setString(2, del_airline_ID);
                ResultSet rs = waitlistStmt.executeQuery();

                while (rs.next()) {
                    String waitlistedUser = rs.getString("username");
                    String waitlist_ID = rs.getString("waitlist_ID");

                    // Add notification for each waitlisted user
                    String notificationQuery = "INSERT INTO Notifications (username, message, waitlist_ID) VALUES (?, ?, ?)";
                    try (PreparedStatement notificationStmt = con.prepareStatement(notificationQuery)) {
                        String notificationMessage = "There has been an opening in flight " + del_flight_number + " on " + del_airline_ID + " airline" + ". You can now book your ticket.";
                        notificationStmt.setString(1, waitlistedUser);
                        notificationStmt.setString(2, notificationMessage);
                        notificationStmt.setInt(3,Integer.parseInt(waitlist_ID));

                        notificationStmt.executeUpdate();
                    }
                }
            }
        throw new Exception (del_airline_ID + " " + del_flight_number);

    }


    

} else {
    out.println("<p>There was an issue deleting the reservation. Please try again.</p>");
}
%>