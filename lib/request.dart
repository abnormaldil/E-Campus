import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _timeSlots = ['9-12', '12-4']; // Updated time slots
  String? _selectedVenue;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final List<String> _venues = [
    'CSE Seminar Hall',
    'Sopanam Auditorium',
    'EC Seminar Hall',
    'Mech Seminar Hall',
    'Fab Lab'
  ];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _selectedVenue = _venues.first;
  }

  Future<void> _bookSlot(String slot) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDay!);
      final docRef = _firestore
          .collection(_selectedVenue!.toLowerCase().replaceAll(' ', ''))
          .doc(dateStr);
      final user = FirebaseAuth.instance.currentUser!;

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        final existingSlots = doc.data()?['slots'] ?? {};

        if (existingSlots.containsKey(slot)) {
          throw 'This slot is already booked!';
        }

        transaction.set(
            docRef,
            {
              'date': dateStr,
              'slots': {...existingSlots, slot: user.email},
            },
            SetOptions(merge: true));
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking successful!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showRequestRoomDialog() {
    final TextEditingController reasonController = TextEditingController();
    final TextEditingController detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request Room',
              style: TextStyle(color: Color.fromARGB(255, 37, 232, 154))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Purpose of Request',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 37, 232, 154)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 37, 232, 154)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: detailsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Additional Details',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 37, 232, 154)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 37, 232, 154)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 37, 232, 154),
              ),
              child: const Text('Submit Request',
                  style: TextStyle(color: Colors.white)),
              onPressed: () {
                // Implement request submission logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Room request submitted!')),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showMonthYearPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Month and Year',
              style: TextStyle(color: Color.fromARGB(255, 37, 232, 154))),
          content: SizedBox(
            height: 300,
            width: 300,
            child: YearPicker(
              selectedDate: _focusedDay,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              onChanged: (DateTime dateTime) {
                Navigator.pop(context);

                // Show month picker after selecting year
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Select Month for ${dateTime.year}',
                          style: const TextStyle(
                              color: Color.fromARGB(255, 37, 232, 154))),
                      content: SizedBox(
                        height: 200,
                        width: 300,
                        child: GridView.count(
                          crossAxisCount: 3,
                          children: List.generate(12, (index) {
                            return InkWell(
                              onTap: () {
                                final newDate =
                                    DateTime(dateTime.year, index + 1, 1);
                                setState(() {
                                  _focusedDay = newDate;
                                  _selectedDay = newDate;
                                });
                                Navigator.pop(context);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: dateTime.year == _focusedDay.year &&
                                          index + 1 == _focusedDay.month
                                      ? const Color.fromARGB(255, 37, 232, 154)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color:
                                        const Color.fromARGB(255, 37, 232, 154),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    DateFormat('MMM')
                                        .format(DateTime(2023, index + 1)),
                                    style: TextStyle(
                                      color:
                                          dateTime.year == _focusedDay.year &&
                                                  index + 1 == _focusedDay.month
                                              ? Colors.white
                                              : const Color.fromARGB(
                                                  255, 37, 232, 154),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlotButton(String slot, bool isBooked) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: isBooked
              ? const LinearGradient(
                  colors: [Colors.redAccent, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 37, 232, 154),
                    Color.fromARGB(255, 42, 254, 169)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 12), // Reduced padding
          ),
          onPressed: isBooked ? null : () => _bookSlot(slot),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(slot,
                  style: const TextStyle(
                      fontSize: 13, // Smaller text
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 1), // Reduced spacing
              Text(
                isBooked ? 'Booked' : 'Available',
                style: TextStyle(
                  fontSize: 14, // Smaller text
                  color: isBooked ? Colors.red[100] : Colors.green[50],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 255, 245),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 37, 232, 154),
        title: DropdownButton<String>(
          dropdownColor: const Color.fromARGB(255, 37, 232, 154),
          value: _selectedVenue,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          underline: const SizedBox(),
          items: _venues.map((String venue) {
            return DropdownMenuItem<String>(
              value: venue,
              child: Text(venue,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedVenue = newValue!;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now()
                  .add(const Duration(days: 365 * 2)), // Extended to 2 years
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onHeaderTapped: (_) {
                // Show year/month picker on header tap
                _showMonthYearPicker();
              },
              // onFormatChanged: (format) {
              //   setState(() {
              //     _calendarFormat = format;
              //   });
              // },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  color: Color.fromARGB(255, 37, 232, 154),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: const Icon(Icons.chevron_left,
                    color: Color.fromARGB(255, 37, 232, 154)),
                rightChevronIcon: const Icon(Icons.chevron_right,
                    color: Color.fromARGB(255, 37, 232, 154)),
                headerMargin: const EdgeInsets.only(bottom: 10),
                formatButtonDecoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 37, 232, 154).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                formatButtonTextStyle: const TextStyle(
                  color: Color.fromARGB(255, 37, 232, 154),
                ),
              ),
              calendarStyle: CalendarStyle(
                cellMargin: const EdgeInsets.all(2),
                defaultDecoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 225, 255, 237)),
                  borderRadius: BorderRadius.circular(8),
                ),
                todayDecoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 37, 232, 154).withOpacity(0.3),
                  border: Border.all(
                      color: const Color.fromARGB(255, 37, 232, 154)),
                  borderRadius: BorderRadius.circular(8),
                ),
                selectedDecoration: BoxDecoration(
                  color: const Color.fromARGB(255, 37, 232, 154),
                  border: Border.all(
                      color: const Color.fromARGB(255, 37, 232, 154)),
                  borderRadius: BorderRadius.circular(8),
                ),
                weekendTextStyle: const TextStyle(color: Colors.red),
                defaultTextStyle: const TextStyle(
                  color: Color.fromARGB(255, 37, 232, 154),
                  fontWeight: FontWeight.w600,
                ),
                outsideTextStyle: TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                weekendStyle:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              rowHeight: 50,
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _selectedDay != null
                  ? _firestore
                      .collection(
                          _selectedVenue!.toLowerCase().replaceAll(' ', ''))
                      .doc(DateFormat('yyyy-MM-dd').format(_selectedDay!))
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 37, 232, 154)));
                }

                final bookedSlots =
                    (snapshot.data?.data() as Map?)?['slots'] ?? {};

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio:
                        2.5, // Increased aspect ratio for better fit
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                  ),
                  itemCount: _timeSlots.length,
                  itemBuilder: (context, index) {
                    final slot = _timeSlots[index];
                    return _buildSlotButton(
                        slot, bookedSlots.containsKey(slot));
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 120.0),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 37, 232, 154),
                    Color.fromARGB(255, 42, 254, 169)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                label: const Text('REQUEST ROOM',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _showRequestRoomDialog,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
