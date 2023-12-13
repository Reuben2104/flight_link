<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Reservation Success</title>
</head>
<body>

<%

    /*
    When there is a deletion of a reservation/flight ticket, save the seat number of the deleted res.
    Use that seat to book the flight of the person coming off the waitlist.
    */


    /* Ticket Table in MySQL Attributes
    `ticket_number` integer, 
    `fname` varchar(50), 
    `lname` varchar(50), 
    `purchase_date_time` datetime, 
    `passenger_id` integer, 
    `booking_fee` float,
    `total_fare` float,
    `is_one_way` boolean,
    */

    /* SESSION ATTRIBUTES INSERTED INTO TICKET DISPLAY */
    // session.setAttribute("totalBookingFee", totalBookingFee);
    // session.setAttribute("totalFare", totalFare);
    // session.setAttribute("fname", fname);
    // session.setAttribute("lname", lname);
    // session.setAttribute("passengerID", passengerID);
    // session.setAttribute("dateTimeString", dateTimeString);


    // ADD ONE WAY OR ROUND TRIP ATTRIBUTE TO TICKET TABLE --> while doing reservation
    // Retrieve session attributes
    String fname = (String) session.getAttribute("fname");
    String lname = (String) session.getAttribute("lname");
    String passengerID = (String) session.getAttribute("passengerID");
    // String classType = (String) session.getAttribute("classType");
    // String flightNum = (String) session.getAttribute("flightNum");
    // Double bookingFee = (Double) session.getAttribute("bookingFee");
    String totalBookingFee = (String) session.getAttribute("totalBookingFee");
    String totalFare = (String) session.getAttribute("totalFare");
    String dateTimeString = (String) session.getAttribute("dateTimeString");
    // String airlineID = (String) session.getAttribute("airlineID");
    //TODO: get departing and returning info separately. 
    String username = (String) session.getAttribute("user");

    String oneOrRound = (String) session.getAttribute("oneOrRound"); 
    // String class_type2 = (String) session.getAttribute("classType2");
    ArrayList<ArrayList<String>> flight_info_list = (ArrayList<ArrayList<String>>) session.getAttribute("flight_info_list");
    

    Connection conn = null;
    PreparedStatement pstmtTicket = null;
    PreparedStatement pstmtFlightCap = null;
    PreparedStatement pstmtWaitlist = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/users", "root", "LogMe@2021");

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

        // do {
        //     nextTicketNumber = (int)(Math.random() * 1000000); // Generate a random ticket number

        //     String checkTicketNumberSQL = "SELECT COUNT(*) FROM Ticket WHERE ticket_number = ?";
        //     try (PreparedStatement checkTicketStmt = conn.prepareStatement(checkTicketNumberSQL)) {
        //         checkTicketStmt.setInt(1, nextTicketNumber);
        //         try (ResultSet checkTicketRs = checkTicketStmt.executeQuery()) {
        //             if (checkTicketRs.next()) {
        //                 int count = checkTicketRs.getInt(1);
        //                 isUnique = count == 0;
        //             } else {
        //                 // This means ResultSet didn't move to the first row, which is unexpected in this case
        //                 throw new Exception("Failed to move ResultSet cursor to the first row for ticket number validation");
        //             }
        //         } catch (SQLException e) {
        //             // Handle SQL exception
        //             throw new Exception("SQL Exception occurred during ticket number validation", e);
        //         }
        //     } catch (SQLException e) {
        //         // Handle SQL exception
        //         throw new Exception("SQL Exception occurred while preparing statement for ticket number validation", e);
        //     }
        // } while (!isUnique);

        // Assuming flightNumber is passed from previous page
        // String flightNumber = request.getParameter("flightNumber");
        ArrayList<String> flight_1 = flight_info_list.get(0);
        


        String requested_airline_ID = flight_1.get(1);
        String requested_flight_number = flight_1.get(0);
        String requested_class = flight_1.get(4);
        String query =  "SELECT \n" +
            "    (CASE \n" +
            "        WHEN ? = 'first' THEN Aircraft.first_seats\n" +
            "        WHEN ? = 'business' THEN Aircraft.business_seats\n" +
            "        WHEN ? = 'economy' THEN Aircraft.economy_seats\n" +
            "    END) AS total_capacity,\n" +
            "    COUNT(FlightCapacity.ticket_number) AS booked_seats,\n" +
            "    (CASE \n" +
            "        WHEN ? = 'first' THEN Aircraft.first_seats\n" +
            "        WHEN ? = 'business' THEN Aircraft.business_seats\n" +
            "        WHEN ? = 'economy' THEN Aircraft.economy_seats\n" +
            "    END) > COUNT(FlightCapacity.ticket_number) AS has_capacity\n" +
            "FROM Flight\n" +
            "JOIN Aircraft ON Flight.aircraft_ID = Aircraft.aircraft_ID\n" +
            "LEFT JOIN FlightCapacity ON Flight.flight_number = FlightCapacity.flight_number\n" +
            "                         AND Flight.airline_ID = FlightCapacity.airline_ID\n" +
            "                         AND FlightCapacity.class = ?\n" +
            "WHERE Flight.flight_number = ?\n" +
            "  AND Flight.airline_ID = ?\n" +
            "GROUP BY Aircraft.first_seats, Aircraft.business_seats, Aircraft.economy_seats;";
        
        PreparedStatement pstmt = conn.prepareStatement(query);

        // Assuming the types of requested_class, requested_flight_number, and requested_airline_ID are all String
        pstmt.setString(1, requested_class); // For the first class check
        pstmt.setString(2, requested_class); // For the second class check
        pstmt.setString(3, requested_class); // For the third class check
        pstmt.setString(4, requested_class); // For the fourth class check
        pstmt.setString(5, requested_class); // For the fifth class check
        pstmt.setString(6, requested_class); // For the sixth class check
        pstmt.setString(7, requested_class); // For the class in FlightCapacity join
        pstmt.setString(8, requested_flight_number); // For the flight number in WHERE clause
        pstmt.setString(9, requested_airline_ID); // For the airline ID in WHERE clause

        rs = pstmt.executeQuery();
        boolean flight_1_capacity_check = false;
        if(rs.next()){
            flight_1_capacity_check = rs.getBoolean("has_capacity");
            if(flight_1_capacity_check){
                flight_1.add(""+ rs.getInt("booked_seats")+1); // SEAT NUMBER AT INDEX 5
            }
        }
        else{
            throw new Exception("Gotcha");

        }


        ResultSet rs2 = null;
        if(flight_info_list.size()>1){
            ArrayList<String> flight_2 = flight_info_list.get(1);
            
            

            String requested_airline_ID_2 = flight_2.get(1);
            String requested_flight_number_2 = flight_2.get(0);
            String requested_class_2 = flight_2.get(4);
            String query2 =  "SELECT \n" +
                "    (CASE \n" +
                "        WHEN ? = 'first' THEN Aircraft.first_seats\n" +
                "        WHEN ? = 'business' THEN Aircraft.business_seats\n" +
                "        WHEN ? = 'economy' THEN Aircraft.economy_seats\n" +
                "    END) AS total_capacity,\n" +
                "    COUNT(FlightCapacity.ticket_number) AS booked_seats,\n" +
                "    (CASE \n" +
                "        WHEN ? = 'first' THEN Aircraft.first_seats\n" +
                "        WHEN ? = 'business' THEN Aircraft.business_seats\n" +
                "        WHEN ? = 'economy' THEN Aircraft.economy_seats\n" +
                "    END) > COUNT(FlightCapacity.ticket_number) AS has_capacity\n" +
                "FROM Flight\n" +
                "JOIN Aircraft ON Flight.aircraft_ID = Aircraft.aircraft_ID\n" +
                "LEFT JOIN FlightCapacity ON Flight.flight_number = FlightCapacity.flight_number\n" +
                "                         AND Flight.airline_ID = FlightCapacity.airline_ID\n" +
                "                         AND FlightCapacity.class = ?\n" +
                "WHERE Flight.flight_number = ?\n" +
                "  AND Flight.airline_ID = ?\n" +
                "GROUP BY Aircraft.first_seats, Aircraft.business_seats, Aircraft.economy_seats;";
            
            PreparedStatement pstmt2 = conn.prepareStatement(query2);

            // Assuming the types of requested_class_2, requested_flight_number_2, and requested_airline_ID_2 are all String
            pstmt2.setString(1, requested_class_2); // For the first class check
            pstmt2.setString(2, requested_class_2); // For the second class check
            pstmt2.setString(3, requested_class_2); // For the third class check
            pstmt2.setString(4, requested_class_2); // For the fourth class check
            pstmt2.setString(5, requested_class_2); // For the fifth class check
            pstmt2.setString(6, requested_class_2); // For the sixth class check
            pstmt2.setString(7, requested_class_2); // For the class in FlightCapacity join
            pstmt2.setString(8, requested_flight_number_2); // For the flight number in WHERE clause
            pstmt2.setString(9, requested_airline_ID_2); // For the airline ID in WHERE clause

            rs2 = pstmt2.executeQuery();
            if(rs2.next()){
                // throw new Exception("" + rs2.getInt("booked_seats") + " ------ " + rs2.getBoolean("has_capacity"));
            }
        }
        boolean flight_2_capacity_check = "0".equals(oneOrRound) ? rs2.getBoolean("has_capacity") : false;
        if(flight_2_capacity_check){
            ArrayList<String> flight_2 = flight_info_list.get(1);
            flight_2.add(""+ rs2.getInt("booked_seats")+1); // SEAT NUMBER AT INDEX 5
        }

        // if (ticketCount < FLIGHT_CAPACITY) {
        if ("1".equals(oneOrRound) && flight_1_capacity_check || "0".equals(oneOrRound) && flight_1_capacity_check && flight_2_capacity_check){
            String insertTicketSQL = "INSERT INTO Ticket (ticket_number, fname, lname, purchase_date_time, passenger_id, booking_fee, total_fare, is_one_way) VALUES (?, ?, ?, NOW(), ?, ?, ?, ?)";
            pstmtTicket = conn.prepareStatement(insertTicketSQL);
            // PreparedStatement pstmt3 = conn.prepareStatement(insertTicketSQL);

            //Insert into Ticket
            pstmtTicket.setInt(1, nextTicketNumber); // Ticket number
            pstmtTicket.setString(2, fname); // First name
            pstmtTicket.setString(3, lname); // Last name
            // The fourth placeholder is for 'purchase_date_time', which is set to NOW() in the SQL
            pstmtTicket.setString(4, passengerID); // Passenger ID
            // pstmtTicket.setDouble(5, totalBookingFee); // Booking fee
            pstmtTicket.setDouble(5, Double.parseDouble(totalBookingFee)); // Booking fee

            pstmtTicket.setDouble(6, Double.parseDouble(totalFare)); // Total fare
            pstmtTicket.setBoolean(7, "1".equals(oneOrRound));

            pstmtTicket.executeUpdate();

            for(ArrayList<String> flight_leg: flight_info_list){
            // Insert into FlightCapacity table
                String insertFlightCapSQL = "INSERT INTO FlightCapacity (ticket_number, flight_number, airline_ID, class, seat_number) VALUES (?, ?, ?, ?, ?)";
                pstmtFlightCap = conn.prepareStatement(insertFlightCapSQL);

                pstmtFlightCap.setInt(1, nextTicketNumber);
                pstmtFlightCap.setString(2, flight_leg.get(0));
                pstmtFlightCap.setString(3, flight_leg.get(1));            
                pstmtFlightCap.setString(4, flight_leg.get(4));
                pstmtFlightCap.setString(5, flight_leg.get(5));

                pstmtFlightCap.executeUpdate();
            }

            // Insert into Bookings table
            String insertBookingSQL = "INSERT INTO Bookings (username, ticket_number) VALUES (?, ?)";
            PreparedStatement pstmtBooking = conn.prepareStatement(insertBookingSQL);

            pstmtBooking.setString(1, username); // Username of the customer
            pstmtBooking.setInt(2, nextTicketNumber); // The generated ticket number

            pstmtBooking.executeUpdate();

            out.println("<h2>Your ticket has been successfully booked.</h2>");
            out.println("<p>Your ticket number is: " + nextTicketNumber + ".</p>");
        } else {
           if("0".equals(oneOrRound)){
                if(flight_1_capacity_check){
                    String insertWaitlistSQL = "INSERT INTO Waitlist (username, flight_number, airline_ID, class) VALUES (?,?, ?, ?)";
                    pstmtWaitlist = conn.prepareStatement(insertWaitlistSQL);

                    pstmtWaitlist.setString(1,username);
                    pstmtWaitlist.setInt(2, Integer.parseInt(flight_1.get(0)));
                    pstmtWaitlist.setString(3, flight_1.get(1));
                    pstmtWaitlist.setString(4, flight_1.get(4));

                    pstmtWaitlist.executeUpdate();


                    out.println("<h2>Flight is full. You have been placed on the waiting list.</h2>");
                }
                if(flight_2_capacity_check){
                    ArrayList flight_2 = flight_info_list.get(1);
                    String insertWaitlistSQL = "INSERT INTO Waitlist (username, flight_number, airline_ID, class) VALUES (?,?, ?, ?)";
                    pstmtWaitlist = conn.prepareStatement(insertWaitlistSQL);

                    pstmtWaitlist.setString(1,username);
                    // pstmtWaitlist.setInt(2, Integer.parseInt(flight_2.get(0)));
                    pstmtWaitlist.setInt(2, Integer.parseInt((String) flight_2.get(0)));

                    // pstmtWaitlist.setString(3, flight_2.get(1));
                    // pstmtWaitlist.setString(4, flight_2.get(4));
                    pstmtWaitlist.setString(3, (String) flight_2.get(1));
                    pstmtWaitlist.setString(4, (String) flight_2.get(4));

                    pstmtWaitlist.executeUpdate();


                    out.println("<h2>Flight is full. You have been placed on the waiting list.</h2>");
                }
           }
           else{
                
                String insertWaitlistSQL = "INSERT INTO Waitlist (username, flight_number, airline_ID, class) VALUES (?,?, ?, ?)";
                pstmtWaitlist = conn.prepareStatement(insertWaitlistSQL);

                pstmtWaitlist.setString(1,username);
                pstmtWaitlist.setInt(2, Integer.parseInt(flight_1.get(0)));
                pstmtWaitlist.setString(3, flight_1.get(1));
                pstmtWaitlist.setString(4, flight_1.get(4));

                pstmtWaitlist.executeUpdate();


                out.println("<h2>Flight is full. You have been placed on the waiting list.</h2>");
           }
           
        }

    } catch (Exception e) {
        out.print(e);
    } 
%>

</body>
</html>