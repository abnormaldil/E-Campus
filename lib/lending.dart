import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LendingPage extends StatefulWidget {
  @override
  _LendingPageState createState() => _LendingPageState();
}

class _LendingPageState extends State<LendingPage> {
  final Map<String, String> hardwareImages = {
    "Raspberry pi 4 model b": "assets/raspberrypi.png",
    "ESP8266": "assets/esp8266.png",
    "Cutter": "assets/cutter.png",
    "Welding Unit": "assets/welding_unit.png",
    "OLED Display": "assets/oleddisplay.png",
    "Concrete Mixer": "assets/cement.png"
  };

  List<String> selectedDepartments = [];
  bool showOnlyAvailable = false;
  List<String> allDepartments = [];
  String searchQuery = "";
  String sortBy = "Title";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text("Lending"),
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: "Search by name",
                    labelStyle: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontFamily: 'Gilroy',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded border
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          width: 0.3), // Border style
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          width: 0.3),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          width: 0.3), // Highlight when focused
                    ),
                    prefixIcon: Icon(Icons.search,
                        color: const Color.fromARGB(255, 0, 0, 0)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('hardwares')
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData)
                          return CircularProgressIndicator();

                        allDepartments = snapshot.data!.docs
                            .map((doc) => doc['Department'].toString())
                            .toSet()
                            .toList();
                        allDepartments.insert(0, "All");

                        return Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: allDepartments.map((dept) {
                                bool isSelected =
                                    selectedDepartments.contains(dept) ||
                                        selectedDepartments.contains("All");

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (dept == "All") {
                                        selectedDepartments.clear();
                                        selectedDepartments.add("All");
                                      } else {
                                        if (selectedDepartments
                                            .contains(dept)) {
                                          selectedDepartments.remove(dept);
                                        } else {
                                          selectedDepartments.remove("All");
                                          selectedDepartments.add(dept);
                                        }
                                      }
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 100),
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 34, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              colors: [
                                                Color.fromARGB(
                                                    255, 37, 232, 154),
                                                Color.fromARGB(
                                                    255, 42, 254, 169),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color: isSelected
                                          ? null
                                          : Colors.transparent,
                                      border: Border.all(
                                          color: isSelected
                                              ? Colors.transparent
                                              : const Color.fromARGB(
                                                  255, 0, 0, 0),
                                          width: 0.3),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      dept,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : const Color.fromARGB(
                                                255, 0, 0, 0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Center(
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min, // Ensures it takes minimal space
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Center align the row content
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // Set background color to white
                          borderRadius: BorderRadius.circular(
                              30), // Optional: Add rounded corners
                        ),
                        child: DropdownButton<String>(
                          value: sortBy,
                          onChanged: (newValue) {
                            setState(() {
                              sortBy = newValue!;
                            });
                          },
                          items: ["Title", "Department", "Availability"]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                "Sort by $value",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Gilroy',
                                ),
                              ),
                            );
                          }).toList(),
                          dropdownColor: Colors
                              .white, // Set dropdown menu background color to white
                          icon: Icon(Icons.arrow_drop_down,
                              color: Colors.black), // Customize dropdown icon
                          style: TextStyle(
                            color: Colors.black, // Set text color
                            fontFamily: 'Gilroy',
                          ),
                          underline:
                              Container(), // Remove the default underline
                        ),
                      ),
                      SizedBox(
                          width:
                              75), // Adds spacing between dropdown and checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: showOnlyAvailable,
                            onChanged: (value) {
                              setState(() {
                                showOnlyAvailable = value!;
                              });
                            },
                            activeColor: Color.fromARGB(255, 37, 232, 154),
                          ),
                          Text(
                            "Available only",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontFamily: 'Gilroy',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('hardwares')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs.where((doc) {
                  bool matchesSearch = doc['Title']
                      .toString()
                      .toLowerCase()
                      .contains(searchQuery);
                  bool matchesDepartment = selectedDepartments.isEmpty ||
                      selectedDepartments.contains("All") ||
                      selectedDepartments.contains(doc['Department']);
                  bool matchesAvailability =
                      !showOnlyAvailable || doc['Availability'] != 'lent';
                  return matchesSearch &&
                      matchesDepartment &&
                      matchesAvailability;
                }).toList();

                docs.sort((a, b) =>
                    a[sortBy].toString().compareTo(b[sortBy].toString()));

                return GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    bool isLent = doc['Availability'] == 'lent';
                    String imagePath =
                        hardwareImages[doc['Title']] ?? "assets/default.png";
                    String currentUserId =
                        FirebaseAuth.instance.currentUser?.uid ?? '';
                    bool isCurrentUser = doc['Availability'] == currentUserId;
                    bool isApproved = isCurrentUser && doc['flag'] == 1;

                    // Update Firestore when approved
                    if (isApproved && doc['Availability'] != 'lent') {
                      FirebaseFirestore.instance
                          .collection('hardwares')
                          .doc(doc.id)
                          .update({"Availability": "lent"}).catchError(
                              (error) => print("Failed to update: $error"));
                    }

                    return GestureDetector(
                      onTap: () => _showDetailsDialog(context, doc),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(30), // Curved border
                          border: Border.all(
                            color: Colors.grey, // Border color
                            width: 0.3, // Border width
                          ),
                          color: isLent ? Colors.grey[300] : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(0.1), // Shadow color
                              blurRadius: 2, // Blur radius
                              spreadRadius: 1, // Spread radius
                              offset: Offset(0, 0), // Shadow offset (x, y)
                            ),
                          ], // Background color
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        30), // Adds rounded corners
                                    child: ColorFiltered(
                                      colorFilter: isLent
                                          ? ColorFilter.mode(
                                              Colors.grey, BlendMode.saturation)
                                          : ColorFilter.mode(Colors.transparent,
                                              BlendMode.multiply),
                                      child: Image.asset(
                                        imagePath,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    doc['Title'],
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontFamily: 'Gilroy',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                if (isCurrentUser)
                                  Column(
                                    children: [
                                      LinearProgressIndicator(
                                        value: isApproved
                                            ? 1.0
                                            : 0.5, // Progress value
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          isApproved
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        isApproved
                                            ? "Approved"
                                            : "Pending Approval",
                                        style: TextStyle(
                                          color: isApproved
                                              ? Colors.green
                                              : Colors.orange,
                                          fontFamily: 'Gilroy',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            if (isLent)
                              Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: Text(
                                    "Unavailable",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: 'Gilroy',
                                      shadows: [
                                        Shadow(
                                          offset:
                                              Offset(0, 0), // Shadow position
                                          blurRadius: 25, // Shadow blur effect
                                          color: Colors.black
                                              .withOpacity(0.7), // Shadow color
                                        ),
                                      ],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void _showDetailsDialog(BuildContext context, QueryDocumentSnapshot doc) {
  bool isLent = doc['Availability'] == 'lent';

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white, // Set background color to white
        title: Center(
          child: Text(
            doc['Title'],
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 24,
              color: Colors.black,
            ),
          ),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // Curved border
                border: Border.all(
                  color: const Color.fromARGB(0, 0, 0, 0), // Black border color
                  width: 0.3, // Border width
                ),
                color: const Color.fromARGB(255, 255, 255, 255),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.1), // Shadow color with opacity
                    blurRadius: 15, // Blur radius
                    spreadRadius: 5, // Spread radius
                    offset: Offset(0, 0), // Shadow offset (x, y)
                  ),
                ], // Transparent background
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                doc['Description'] ?? "No description available",
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 40),
            // Year and Department in a single row
            Center(
              child: Row(
                mainAxisSize:
                    MainAxisSize.min, // Ensures it takes minimal space
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Year inside a curved rectangle border
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15), // Curved border
                      border: Border.all(
                        color: Colors.black, // Black border color
                        width: 0.3, // Border width
                      ),
                      color: Colors.transparent, // Transparent background
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8), // Padding inside the container
                    child: Text(
                      "Year of Contribution: ${doc['Year']}",
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 15), // Spacing between Year and Department
                  // Department inside a curved rectangle border
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15), // Curved border
                      border: Border.all(
                        color: Colors.black, // Black border color
                        width: 0.3, // Border width
                      ),
                      color: Colors.transparent, // Transparent background
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8), // Padding inside the container
                    child: Text(
                      "${doc['Department']}",
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          if (isLent)
            ElevatedButton(
              onPressed: null, // Disables the button
              child: Text(
                "Unavailable",
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
              ),
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the current dialog
                _showRequestFormDialog(
                    context, doc); // Open the request form dialog
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero, // Remove default padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                elevation: 0, // Remove default elevation
                shadowColor: Colors.transparent, // Remove shadow
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 37, 232, 154), // Start color
                      Color.fromARGB(255, 42, 254, 169), // End color
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    "Request",
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

void _showRequestFormDialog(BuildContext context, QueryDocumentSnapshot doc) {
  final _formKey = GlobalKey<FormState>();
  String projectName = '';
  String projectAbstract = '';

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        title: Center(
          child: Text(
            "Request Form",
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 24,
              color: Colors.black,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Project Name Field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30), // Curved border
                      border: Border.all(
                        color: Colors.grey, // Border color
                        width: 0.3, // Border width
                      ),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Project Name",
                        labelStyle: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a project name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        projectName = value!;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Project Abstract Field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30), // Curved border
                      border: Border.all(
                        color: Colors.grey, // Border color
                        width: 0.3, // Border width
                      ),
                    ),
                    constraints: BoxConstraints(minHeight: 150),
                    child: TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: "Project Abstract",
                        labelStyle: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a project abstract';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        projectAbstract = value!;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                // Retrieve the current logged-in user's details
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final studentDoc = await FirebaseFirestore.instance
                      .collection('students')
                      .doc(user.uid)
                      .get();

                  if (studentDoc.exists) {
                    final studentName = studentDoc['name'];
                    final studentDepartment = studentDoc['department'];
                    final hardwareTitle = doc['Title'];

                    // Save the request to Firestore
                    await FirebaseFirestore.instance
                        .collection('requests')
                        .add({
                      'projectName': projectName,
                      'projectAbstract': projectAbstract,
                      'studentName': studentName,
                      'studentDepartment': studentDepartment,
                      'hardwareTitle': hardwareTitle,
                      'requestDate': DateTime.now(),
                    });

                    // Find the document in 'hardwares' collection that matches the hardware title
                    final hardwareQuery = await FirebaseFirestore.instance
                        .collection('hardwares')
                        .where('Title', isEqualTo: hardwareTitle)
                        .get();

                    if (hardwareQuery.docs.isNotEmpty) {
                      final hardwareDoc = hardwareQuery.docs.first;

                      // Update the 'Availability' field with the logged-in user ID
                      await FirebaseFirestore.instance
                          .collection('hardwares')
                          .doc(hardwareDoc.id)
                          .update({'Availability': user.uid});

                      // Close the dialog and show success message
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Request submitted successfully!")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Hardware not found!")),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Student details not found!")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("User not logged in!")),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 37, 232, 154),
                    Color.fromARGB(255, 42, 254, 169),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  "Submit",
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
