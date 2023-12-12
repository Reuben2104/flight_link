<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
</head>
<body>
    <h1>Admin Dashboard</h1>
        <!-- Logout link -->
    <a href="adminAction.jsp?action=logout">Logout</a>
    


    <!-- Form to add a new customer -->
    <h2>Add Customer/Representative</h2>
    <form action="adminAction.jsp" method="post">
        Username: <input type="text" name="username" required /><br />
        Password: <input type="password" name="password" required /><br />
        <input type="hidden" name="action" value="add" />
        <input type="submit" value="Add" />
    </form>

    <!-- Form to show most active flights -->
    <h2>Most Active Flights</h2>
    <form action="adminAction.jsp" method="post">
        <input type="hidden" name="action" value="mostActiveFlights" />
        <input type="submit" value="Show Most Active Flights" />
    </form>

    <!-- Form to get sales report for a particular month -->
    <h2>Sales Report for a Month</h2>
    <form action="adminAction.jsp" method="post">
        <input type="hidden" name="action" value="salesReport" />
        Select Month:
        <select name="month">
            <option value="01">January</option>
            <option value="02">February</option>
            <!-- Add options for all months -->
            <option value="12">December</option>
        </select>
        <input type="submit" value="Get Sales Report" />
    </form>


    <h2>Manage Customers/Representatives</h2>
    
    <table border="1">
        <tr>
            <th>Username</th>
            <th>Password</th>
            <th>Action</th>
        </tr>
        <%
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/users", "root", "LogMe@2021");
            Statement stmt = con.createStatement();
            String query = "SELECT username, password FROM Customer";
            ResultSet rs = stmt.executeQuery(query);

        while (rs.next()) {
            String username = rs.getString("username");
            String password = rs.getString("password"); 
    %>
        <tr>
            <td><%= username %></td>
            <td><%= password %></td> 
            <td>
                <!-- edit user -->
                <form action="adminAction.jsp" method="post" style="display: inline;">
                    <input type="hidden" name="username" value="<%= username %>" />
                    <input type="hidden" name="action" value="showEditForm" />
                    <input type="submit" value="Edit" />
                </form> |            
                 <!-- delete user -->
                <form action="adminAction.jsp" method="post" style="display: inline;" onsubmit="return confirm('Are you sure?');">
                    <input type="hidden" name="username" value="<%= username %>" />
                    <input type="hidden" name="action" value="delete" />
                    <input type="submit" value="Delete" />
                </form>
            </td>
        </tr>
    <%
        }
        rs.close();
        stmt.close();
        con.close();
    %>
</table>
</body>
