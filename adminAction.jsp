
<%@ page import="java.sql.*" %>
<%@ page import="java.math.BigDecimal" %>

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
                String password = request.getParameter("password"); // Password for the new user
                String sql = "INSERT INTO Customer (username, password) VALUES (?, ?)";
                pstmt = con.prepareStatement(sql);
                pstmt.setString(1, username);
                pstmt.setString(2, password); // In a real-world application, hash this password
                pstmt.executeUpdate();
                out.println("<p>User added successfully.</p>");
            } 
            
            
           else if ("edit".equals(action)) {
                String oldUsername = request.getParameter("oldUsername");
                String newUsername = request.getParameter("newUsername");
                String newPassword = request.getParameter("newPassword");

                // Update username if it has changed
                if (newUsername != null && !newUsername.isEmpty() && !newUsername.equals(oldUsername)) {
                    pstmt = con.prepareStatement("UPDATE Customer SET username = ? WHERE username = ?");
                    pstmt.setString(1, newUsername);
                    pstmt.setString(2, oldUsername);
                    pstmt.executeUpdate();
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
                String sql = "DELETE FROM Customer WHERE username = ?";
                pstmt = con.prepareStatement(sql);
                pstmt.setString(1, username);
                pstmt.executeUpdate();
                out.println("<p>User deleted successfully.</p>");
            
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