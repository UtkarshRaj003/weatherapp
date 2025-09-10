import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/day5provider.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  TextEditingController query = TextEditingController();

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  String getCurrentDateTime() {
    final now = DateTime.now();
    String formattedDate =
        DateFormat('EEEE, MMM d').format(now); // Friday, Sep 6
    String formattedTime = DateFormat('h:mm a').format(now); // 10:45 AM
    return "$formattedDate • $formattedTime";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bci.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3), // dark overlay
            ),
            child: Column(
              children: [
                // 🔹 Floating Search Box
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: query,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Search city",
                            hintStyle: TextStyle(color: Colors.white70),
                            prefixIcon: Icon(Icons.search, color: Colors.white),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (query.text.isNotEmpty) {
                            Provider.of<WeatherProvider>(context, listen: false)
                                .fetchAll(query.text);
                          }
                        },
                        icon:
                            Icon(Icons.arrow_forward_ios, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Consumer<WeatherProvider>(
                    builder: (context, provider, child) {
                      if (provider.loading) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (provider.weather == null) {
                        return Center(
                          child: Text("Search for a city...",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        );
                      }

                      // ✅ AQI Data

                      final weather = provider.weather!;
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // 🔹 Location
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_pin, color: Colors.white),
                                Text(
                                  "${weather['name']}${weather['sys']['country'] != null ? ', ${weather['sys']['country']}' : ''}",
                                  style: GoogleFonts.laila(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              getCurrentDateTime(),
                              style: GoogleFonts.laila(
                                  color: Colors.white70, fontSize: 16),
                            ),

                            // 🔹 Temperature
                            SizedBox(height: 20),
                            Container(
                              width: 250,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    "${weather['main']['temp'].toInt()}",
                                    style: GoogleFonts.laila(
                                      fontSize: 125,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                  Positioned(
                                    top: 1,
                                    right: 0,
                                    child: Text(
                                      "°C",
                                      style: GoogleFonts.laila(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 🔹 Weather description
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  "https://openweathermap.org/img/wn/${weather['weather'][0]['icon']}@2x.png",
                                  width: 60,
                                  height: 60,
                                ),
                                Text(
                                  weather['weather'][0]['description'],
                                  style: GoogleFonts.laila(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ],
                            ),

                            // 🔹 Info Card
                            Container(
                              margin: EdgeInsets.all(16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(23),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(23),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildInfo("Min/Max",
                                            "${weather['main']['temp_min']}° / ${weather['main']['temp_max']}°"),
                                        _divider(),
                                        _buildInfo("Wind",
                                            "${weather['wind']['speed']} m/s"),
                                        _divider(),
                                        _buildInfo("Humidity",
                                            "${weather['main']['humidity']}%"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 🔹 Hourly Forecast
                            if (provider.hourlyForecast.isNotEmpty)
                              SizedBox(
                                height: 130,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: provider.hourlyForecast.length,
                                  itemBuilder: (context, index) {
                                    final item = provider.hourlyForecast[index];
                                    return _buildHourlyForecast(
                                      item['time'],
                                      item['temp'],
                                      "https://openweathermap.org/img/wn/${item['icon']}@2x.png",
                                    );
                                  },
                                ),
                              ),

                            // 🔹 Tomorrow Forecast
                            if (provider.tomorrowForecast != null)
                              Container(
                                margin: EdgeInsets.all(16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(23),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10, sigmaY: 10),
                                    child: Card(
                                      color: Colors.white.withOpacity(0.15),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  provider.tomorrowForecast![
                                                      'date'],
                                                  style: GoogleFonts.laila(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  provider.tomorrowForecast![
                                                      'description'],
                                                  style: GoogleFonts.laila(
                                                      color: Colors.white70),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Image.network(
                                                  "https://openweathermap.org/img/wn/${provider.tomorrowForecast!['icon']}@2x.png",
                                                  width: 50,
                                                  height: 50,
                                                ),
                                                Text(
                                                  "${provider.tomorrowForecast!['temp_max']}° / ${provider.tomorrowForecast!['temp_min']}°",
                                                  style: GoogleFonts.laila(
                                                      color: Colors.white,
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🔹 Reusable Widgets
Widget _buildInfo(String label, String value) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(label,
          style: GoogleFonts.laila(color: Colors.white70, fontSize: 14)),
      SizedBox(height: 5),
      Text(value,
          style: GoogleFonts.laila(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
    ],
  );
}

Widget _divider() => Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.5),
    );

Widget _buildHourlyForecast(String time, String temp, String image) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: Colors.white.withOpacity(0.15),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(image: NetworkImage(image), width: 40, height: 40),
        // SizedBox(height: 5),
        Text(time,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
        Text(temp,
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500)),
      ],
    ),
  );
}





// appBar: AppBar(
//           backgroundColor: Colors.blueAccent,
//           title: Text(
//             "Weather Forecasting",
//             style: GoogleFonts.laila(fontSize: 28, fontWeight: FontWeight.bold),
//           ),
//         ),