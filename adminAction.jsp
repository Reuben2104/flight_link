
<%@ page import="java.sql.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.format.DateTimeParseException" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>



<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Actions</title>
</head>
<body>
    <%
        String action = request.getParameter("action");
        String username = request.getParameter("username");

        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;


        try {
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/users", "root", "LogMe@2021");



           
            if ("showEditForm".equals(action)) {
                pstmt = con.prepareStatement("SELECT * FROM Customer WHERE username = ?");
                pstmt.setString(1, username);
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    String currentPassword = rs.getString("password"); // Assuming password column exists
                    out.println("<h2>Edit User: " + username + "</h2>");
                    out.println("<form action='adminAction.jsp' method='post'>");
                    out.println("<input type='hidden' name='action' value='edit' />");
                    out.println("<input type='hidden' name='oldUsername' value='" + username + "' />");
                    out.println("New Username: <input type='text' name='newUsername' value='" + username + "' /><br>");
                    out.println("New Password: <input type='password' name='newPassword' value='" + currentPassword + "' /><br>");
                    out.println("<input type='submit' value='Update' />");
                    out.println("</form>");
                } else {
                    out.println("<p>User not found.</p>");
                }
            } 
            else if ("add".equals(action)) {
                String new_username = request.getParameter("username");
                String password = request.getParameter("password"); // Password for the new user

                // Check if username already exists
                pstmt = con.prepareStatement("SELECT COUNT(*) FROM Customer WHERE username = ?");
                pstmt.setString(1, new_username);
                rs = pstmt.executeQuery();
                rs.next();
                if (rs.getInt(1) > 0) {
                    out.println("<p>Error: Username already exists.</p>");
                } else {
                    // Insert new user
                    String sql = "INSERT INTO Customer (username, password) VALUES (?, ?)";
                    pstmt = con.prepareStatement(sql);
                    pstmt.setString(1, new_username);
                    pstmt.setString(2, password); // In a real-world application, hash this password
                    pstmt.executeUpdate();
                    out.println("<p>User added successfully.</p>");
                }
            } 
            
            
           else if ("edit".equals(action)) {
                String oldUsername = request.getParameter("oldUsername");
                String newUsername = request.getParameter("newUsername");
                String newPassword = request.getParameter("newPassword");

                boolean updateUsername = newUsername != null && !newUsername.isEmpty() && !newUsername.equals(oldUsername);
                if (updateUsername) {
                    // Check if new username already exists
                    pstmt = con.prepareStatement("SELECT COUNT(*) FROM Customer WHERE username = ?");
                    pstmt.setString(1, newUsername);
                    rs = pstmt.executeQuery();
                    rs.next();
                    if (rs.getInt(1) > 0) {
                        out.println("<p>Error: New username already exists.</p>");
                        return; // Stop further processing
                    }
                }
                if (updateUsername) {
                    // Transaction start
                    con.setAutoCommit(false);

                    try {
                        pstmt = con.prepareStatement("UPDATE Customer SET username = ? WHERE username = ?");
                        pstmt.setString(1, newUsername);
                        pstmt.setString(2, oldUsername);
                        pstmt.executeUpdate();

                        // Update other tables where username is a foreign key
                        // Example for the Bookings table
                        pstmt = con.prepareStatement("UPDATE Bookings SET username = ? WHERE username = ?");
                        pstmt.setString(1, newUsername);
                        pstmt.setString(2, oldUsername);
                        pstmt.executeUpdate();

                        // Add similar update statements for other related tables
                        pstmt = con.prepareStatement("UPDATE Waitlist SET username = ? WHERE username = ?");
                        pstmt.setString(1, newUsername);
                        pstmt.setString(2, oldUsername);
                        pstmt.executeUpdate();

                        con.commit(); // Commit transaction
                        out.println("<p>User edited successfully.</p>");
                    } catch (SQLException e) {
                        con.rollback(); // Rollback in case of error
                        out.println("<p>Error updating user.</p>");
                    } finally {
                        con.setAutoCommit(true);
                    }
                }

                // Update password if provided
                if (newPassword != null && !newPassword.isEmpty()) {
                    pstmt = con.prepareStatement("UPDATE Customer SET password = ? WHERE username = ?");
                    pstmt.setString(1, newPassword); // Ideally, hash the password
                    pstmt.setString(2, newUsername.isEmpty() ? oldUsername : newUsername);
                    pstmt.executeUpdate();
                }

                out.println("<p>User edited successfully.</p>");
            } 
            
            else if ("delete".equals(action)) {
                String usernameToDelete = username; // Username of the user to be deleted

                // Start transaction
                con.setAutoCommit(false);

                try {
                    // Delete from Waitlist table
                    pstmt = con.prepareStatement("DELETE FROM Waitlist WHERE username = ?");
                    pstmt.setString(1, usernameToDelete);
                    pstmt.executeUpdate();

                    // Retrieve and delete from Bookings table, while collecting ticket numbers
                    List<String> ticketNumbers = new ArrayList<>();
                    pstmt = con.prepareStatement("SELECT ticket_number FROM Bookings WHERE username = ?");
                    pstmt.setString(1, usernameToDelete);
                    rs = pstmt.executeQuery();
                    while (rs.next()) {
                        ticketNumbers.add(rs.getString("ticket_number"));
                    }

                    pstmt = con.prepareStatement("DELETE FROM Bookings WHERE username = ?");
                    pstmt.setString(1, usernameToDelete);
                    pstmt.executeUpdate();

                    // Delete from FlightCapacity table using the ticket numbers
                    for (String ticketNumber : ticketNumbers) {
                        pstmt = con.prepareStatement("DELETE FROM FlightCapacity WHERE ticket_number = ?");
                        pstmt.setString(1, ticketNumber);
                        pstmt.executeUpdate();
                    }

                    // Delete from Ticket table using the ticket numbers
                    for (String ticketNumber : ticketNumbers) {
                        pstmt = con.prepareStatement("DELETE FROM Ticket WHERE ticket_number = ?");
                        pstmt.setString(1, ticketNumber);
                        pstmt.executeUpdate();
                    }

                    // Finally, delete the user from the Customer table
                    pstmt = con.prepareStatement("DELETE FROM Customer WHERE username = ?");
                    pstmt.setString(1, usernameToDelete);
                    pstmt.executeUpdate();

                    // Commit transaction
                    con.commit();
                    out.println("<p>User and associated data deleted successfully.</p>");
                } catch (SQLException e) {
                    // Rollback in case of error
                    con.rollback();
                    e.printStackTrace(); // Print the stack trace for debugging
                    out.println("<p>Error deleting user: " + e.getMessage() + "</p>"); // Show a more detailed error message
                } finally {
                    // Set auto-commit back to true
                    con.setAutoCommit(true);
                }
            }

            else if ("salesReport".equals(action)) {
                String selectedMonth = request.getParameter("month");
                String year = "2023"; // You might want to dynamically determine the year or allow the admin to select it

                String query = "SELECT SUM(revenue) AS total_revenue FROM Sales WHERE MONTH(sale_date) = ? AND YEAR(sale_date) = ?";

                try {
                    pstmt = con.prepareStatement(query);
                    pstmt.setString(1, selectedMonth);
                    pstmt.setString(2, year);
                    rs = pstmt.executeQuery();

                    if (rs.next()) {
                        BigDecimal totalRevenue = rs.getBigDecimal("total_revenue");
                        out.println("<h2>Sales Report for Month: " + selectedMonth + "</h2>");
                        out.println("<p>Total Revenue: $" + (totalRevenue != null ? totalRevenue : "0.00") + "</p>");
                    } else {
                        out.println("<p>No sales data found for the selected month.</p>");
                    }
                } catch (SQLException e) {
                    out.println("SQL Error: " + e.getMessage());
                }
            }

            
            else if ("mostActiveFlights".equals(action)) {
                String query = "SELECT flight_number, COUNT(*) as ticket_count " +
                            "FROM FlightCapacity " +
                            "GROUP BY flight_number " +
                            "ORDER BY ticket_count DESC";

                try {
                    pstmt = con.prepareStatement(query);
                    rs = pstmt.executeQuery();

                    out.println("<h2>Most Active Flights</h2>");
                    out.println("<table border='1'>");
                    out.println("<tr><th>Flight Number</th><th>Tickets Sold</th></tr>");

                    while (rs.next()) {
                        out.println("<tr>");
                        out.println("<td>" + rs.getString("flight_number") + "</td>");
                        out.println("<td>" + rs.getInt("ticket_count") + "</td>");
                        out.println("</tr>");
                    }
                    out.println("</table>");
                } catch (SQLException e) {
                    out.println("SQL Error: " + e.getMessage());
                }
            }
            
            else if("resByFlight".equals(action)){
                String requested_flight_num = request.getParameter("flight_num");
                String requested_airline_ID = request.getParameter("airline");
                String query = "SELECT F.ticket_number, T.fname, T.lname, T.purchase_date_time, T.booking_fee, T.total_fare " +
                            "FROM FlightCapacity as F, Ticket as T " +
                            "WHERE  F.flight_number  = ? and F.airline_ID = ? and F.ticket_number = T.ticket_number ";
                pstmt = con.prepareStatement(query);
                pstmt.setString(1, requested_flight_num);
                pstmt.setString(2, requested_airline_ID);
                rs = pstmt.executeQuery();

                if (rs != null) {
                    %>
                    <table border="1">
                        <tr>
                            <th>Ticket Number</th>
                            <th>First Name</th>
                            <th>Last Name</th>
                            <th>Purchase Date & Time</th>
                            <th>Booking Fee</th>
                            <th>Total Fare</th>
                        </tr>
                        <% 
                            while (rs.next()) {
                                out.println("<tr>");
                                out.println("<td>" + rs.getString("ticket_number") + "</td>");
                                out.println("<td>" + rs.getString("fname") + "</td>");
                                out.println("<td>" + rs.getString("lname") + "</td>");
                                // out.println("<td>" + rs.getString("passenger_ID") + "</td>");
                                Timestamp dateString = rs.getTimestamp("purchase_date_time"); // Your original date string
                                DateTimeFormatter dbFormat = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                                DateTimeFormatter newFormat = DateTimeFormatter.ofPattern("MM/dd/yyyy HH:mm:ss");
                                try {
                                    // LocalDateTime dateTime = LocalDateTime.parse(dateString, dbFormat);
                                    LocalDateTime dateTime = dateString.toLocalDateTime();
                                    String formattedDate = dateTime.format(newFormat);
                                    out.println("<td>" + formattedDate + "</td>");
                                } catch (DateTimeParseException e) {
                                    out.println("<td>Error formatting date</td>");
                                }
                                out.println("<td>" + rs.getDouble("booking_fee") + "</td>");
                                out.println("<td>" + rs.getDouble("total_fare") + "</td>");
                                out.println("</tr>");
                            } 
                        %>
                    </table>
                <% }
            }
            else if("resByCustomer".equals(action)){
                String customer_username = request.getParameter("customer_username");
                String query = "SELECT B.username, T.ticket_number, T.fname, T.lname, T.passenger_ID, T.purchase_date_time, T.booking_fee, T.total_fare " +
                            "FROM Bookings as B, Ticket as T " +
                            "WHERE B.ticket_number = T.ticket_number AND B.username = ? ";
                pstmt = con.prepareStatement(query);
                pstmt.setString(1, customer_username);
                rs = pstmt.executeQuery();

                if (rs != null) {
                    %>
                    <table border="1">
                        <tr>
                            <th>Customer</th>
                            <th>Ticket Number</th>
                            <th>First Name</th>
                            <th>Last Name</th>
                            <th>Passenger ID</th>
                            <th>Purchase Date & Time</th>
                            <th>Booking Fee</th>
                            <th>Total Fare</th>
                        </tr>
                        <% 
                            while (rs.next()) {
                                out.println("<tr>");
                                out.println("<td>" + rs.getString("username") + "</td>");
                                out.println("<td>" + rs.getString("ticket_number") + "</td>");
                                out.println("<td>" + rs.getString("fname") + "</td>");
                                out.println("<td>" + rs.getString("lname") + "</td>");
                                out.println("<td>" + rs.getString("passenger_ID") + "</td>");
                                Timestamp dateString = rs.getTimestamp("purchase_date_time"); // Your original date string
                                DateTimeFormatter dbFormat = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                                DateTimeFormatter newFormat = DateTimeFormatter.ofPattern("MM/dd/yyyy HH:mm:ss");
                                try {
                                    // LocalDateTime dateTime = LocalDateTime.parse(dateString, dbFormat);
                                    LocalDateTime dateTime = dateString.toLocalDateTime();
                                    String formattedDate = dateTime.format(newFormat);
                                    out.println("<td>" + formattedDate + "</td>");
                                } catch (DateTimeParseException e) {
                                    out.println("<td>Error formatting date</td>");
                                }
                                out.println("<td>" + rs.getDouble("booking_fee") + "</td>");
                                out.println("<td>" + rs.getDouble("total_fare") + "</td>");
                                out.println("</tr>");
                            } 
                        %>
                    </table>
                <% }
            }

            else if("revenueMetricsByFlight".equals(action)){

                String query = "SELECT F.airline_ID, F.flight_number, SUM(CASE WHEN T.is_one_way = false THEN T.booking_fee / 2 ELSE T.booking_fee END) as revenue " + 
                                    "FROM FlightCapacity as F, Ticket as T " +
                                    "WHERE F.ticket_number = T.ticket_number " + 
                                    "GROUP BY F.airline_ID, F.flight_number ";
                


                // String flight_num = request.getParameter("flight_num");
                // String req_airline = request.getParameter("airline");

                // String query = "SELECT F.airline_ID, F.flight_number, SUM(T.booking_fee) as revenue " + 
                //                     "FROM FlightCapacity as F, Ticket as T " +
                //                     "WHERE F.ticket_number = T.ticket_number AND F.flight_number = ? AND F.airline_ID = ? ";
                pstmt = con.prepareStatement(query);
                // pstmt.setString(1, flight_num);
                // pstmt.setString(2, req_airline);
                rs = pstmt.executeQuery();

                out.println("<h2>Revenue Metrics By Flight</h2>");
                out.println("<table border='1'>");
                out.println("<tr><th>Airline</th><th>Flight</th><th>Revenue</th></tr>");

                while(rs.next()) {
                    out.println("<tr>");
                    out.println("<td>" + rs.getString("airline_ID") + "</td>");
                    out.println("<td>" + rs.getString("flight_number") + "</td>");
                    out.println("<td>" + rs.getDouble("revenue") + "</td>");
                    out.println("</tr>");
                }
                out.println("</table>");
            }
            else if("revenueMetricsByAirline".equals(action)){
                String query = "SELECT F.airline_ID, SUM(CASE WHEN T.is_one_way = false THEN T.booking_fee / 2 ELSE T.booking_fee END) as revenue " + 
                                    "FROM FlightCapacity as F, Ticket as T " +
                                    "WHERE F.ticket_number = T.ticket_number " + 
                                    "GROUP BY F.airline_ID ";
                // String req_airline = request.getParameter("airline");
                // String query = "SELECT F.airline_ID, SUM(T.booking_fee) as revenue " + 
                //                     "FROM FlightCapacity as F, Ticket as T " +
                //                     "WHERE F.ticket_number = T.ticket_number AND F.airline_ID = ? ";
                pstmt = con.prepareStatement(query);
                // pstmt.setString(1, req_airline);
                rs = pstmt.executeQuery();
                out.println("<h2>Revenue Metrics By Airline</h2>");
                out.println("<table border='1'>");
                out.println("<tr><th>Airline</th><th>Revenue</th></tr>");

                while(rs.next()) {
                    out.println("<tr>");
                    out.println("<td>" + rs.getString("airline_ID") + "</td>");
                    out.println("<td>" + rs.getDouble("revenue") + "</td>");
                    out.println("</tr>");
                }
                out.println("</table>");
            }
            else if("revenueMetricsByCustomer".equals(action)){
                String query = "SELECT B.username, SUM(T.booking_fee) as revenue " + 
                                    "FROM Bookings as B, Ticket as T " +
                                    "WHERE B.ticket_number = T.ticket_number " +
                                    "GROUP BY B.username ";
                // String query = "SELECT B.username, SUM(T.booking_fee) as revenue " + 
                //                     "FROM Bookings as B, Ticket as T " +
                //                     "WHERE B.ticket_number = T.ticket_number and B.username = ? ";
                pstmt = con.prepareStatement(query);
                // pstmt.setString(1, analysis_input);
                rs = pstmt.executeQuery();
                out.println("<h2>Revenue Metrics By Customer</h2>");
                out.println("<table border='1'>");
                out.println("<tr><th>Username</th><th>Revenue</th></tr>");

                while(rs.next()) {
                    out.println("<tr>");
                    out.println("<td>" + rs.getString("username") + "</td>");
                    out.println("<td>" + rs.getDouble("revenue") + "</td>");
                    out.println("</tr>");
                }
                out.println("</table>");
            }
            else if("mostProfitableCustomer".equals(action)){
                String query = "SELECT B.username, SUM(T.booking_fee) as revenue " + 
                                    "FROM Bookings as B, Ticket as T " +
                                    "WHERE B.ticket_number = T.ticket_number " +
                                    "GROUP BY B.username " + 
                                    "ORDER BY revenue DESC " + 
                                    "LIMIT 2 ";
                pstmt = con.prepareStatement(query);
                rs = pstmt.executeQuery();

                out.println("<h2>Most Profitable Customer</h2>");
                out.println("<table border='1'>");
                out.println("<tr><th>Username</th><th>Revenue</th></tr>");

                while(rs.next()) {
                    out.println("<tr>");
                    out.println("<td>" + rs.getString("username") + "</td>");
                    out.println("<td>" + rs.getDouble("revenue") + "</td>");
                    out.println("</tr>");
                }
                out.println("</table>");
                
            }



            else if ("logout".equals(action)) {
                session.invalidate();
                response.sendRedirect("login.jsp");
            } else {
                out.println("<p>Invalid action.</p>");
            }
        } catch (SQLException e) {
            out.println("Database error: " + e.getMessage());
        } finally {
            if (pstmt != null) pstmt.close();
            if (con != null) con.close();
        }
    %>
    <a href="adminDash.jsp">Back to Admin Dashboard</a>

</body>
</html>