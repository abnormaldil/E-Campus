import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

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
        title: Center(
          child: Text(
            "Help With Your Project!",
            style: TextStyle(
              fontSize: 30,
              color: Colors
                  .white, 
              fontFamily: 'Gilroy',
            ),
          ),
        ),
        backgroundColor:
            Color.fromARGB(255, 37, 232, 154), 
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
                      borderRadius: BorderRadius.circular(30), 
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          width: 0.3), 
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
                          width: 0.3), 
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
                        MainAxisSize.min, 
                    mainAxisAlignment: MainAxisAlignment
                        .center, 
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(
                              30), 
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
                              .white, 
                          icon: Icon(Icons.arrow_drop_down,
                              color: Colors.black), 
                          style: TextStyle(
                            color: Colors.black, 
                            fontFamily: 'Gilroy',
                          ),
                          underline:
                              Container(), 
                        ),
                      ),
                      SizedBox(
                          width:
                              75), 
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 74),
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
                    bool matchesAvailability = !showOnlyAvailable ||
                        doc['Availability'] != 'lent'; 
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
                      String currentUserId =
                          FirebaseAuth.instance.currentUser?.uid ?? '';
                      String allotUserId =
                          doc['allot'] ?? ''; 
                      bool isCurrentUser = doc['Availability'] == currentUserId;
                      bool isPending = isCurrentUser && doc['flag'] == 0;
                      bool isApproved = isCurrentUser && doc['flag'] == 1;
                      bool isLent = doc['Availability'] == 'lent';

                      
                      if (isApproved && doc['allot'] != currentUserId) {
                        FirebaseFirestore.instance
                            .collection('hardwares')
                            .doc(doc.id)
                            .update({"allot": currentUserId}).catchError(
                                (error) => print("Failed to update: $error"));
                      }

                      
                      bool showApprovedBadge = allotUserId == currentUserId;
                      
                      bool showUnavailableBadge =
                          allotUserId != currentUserId && isLent;

                      return GestureDetector(
                        onTap: () => _showDetailsDialog(context, doc),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(30), 
                            border: Border.all(
                              color: Colors.grey, 
                              width: 0.3, 
                            ),
                            color: isLent ? Colors.grey[300] : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.1), 
                                blurRadius: 2, 
                                spreadRadius: 1, 
                                offset: Offset(0, 0), 
                              ),
                            ], 
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          30), 
                                      child: ColorFiltered(
                                        colorFilter: isLent
                                            ? ColorFilter.mode(Colors.grey,
                                                BlendMode.saturation)
                                            : ColorFilter.mode(
                                                Colors.transparent,
                                                BlendMode.multiply),
                                        child: Image.asset(
                                          hardwareImages[doc['Title']] ??
                                              "assets/default.png",
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
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
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
                                              : (isPending
                                                  ? 0.5
                                                  : 0.0), 
                                          backgroundColor: Colors.grey[300],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            isApproved
                                                ? Color.fromARGB(
                                                    255, 37, 232, 154)
                                                : Colors.orange,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          isApproved
                                              ? "Approved"
                                              : (isPending
                                                  ? "Pending Approval"
                                                  : ""),
                                          style: TextStyle(
                                            color: isApproved
                                                ? Color.fromARGB(
                                                    255, 37, 232, 154)
                                                : Colors.orange,
                                            fontFamily: 'Gilroy',
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              if (showApprovedBadge)
                                Center(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: Text(
                                      "Approved",
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 37, 232, 154),
                                        fontSize: 20,
                                        fontFamily: 'Gilroy',
                                        shadows: [
                                          Shadow(
                                            offset:
                                                Offset(0, 0), 
                                            blurRadius:
                                                25, 
                                            color: Colors.black.withOpacity(
                                                0.7), 
                                          ),
                                        ],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              if (showUnavailableBadge)
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
                                                Offset(0, 0), 
                                            blurRadius:
                                                25, 
                                            color: Colors.black.withOpacity(
                                                0.7), 
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
        backgroundColor: Colors.white, 
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
                borderRadius: BorderRadius.circular(20), 
                border: Border.all(
                  color: const Color.fromARGB(0, 0, 0, 0), 
                  width: 0.3, 
                ),
                color: const Color.fromARGB(255, 255, 255, 255),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.1), 
                    blurRadius: 15, 
                    spreadRadius: 5, 
                    offset: Offset(0, 0), 
                  ),
                ], 
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
            
            Center(
              child: Row(
                mainAxisSize:
                    MainAxisSize.min, 
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15), 
                      border: Border.all(
                        color: Colors.black, 
                        width: 0.3, 
                      ),
                      color: Colors.transparent, 
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8), 
                    child: Text(
                      "Year of Contribution: ${doc['Year']}",
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 15), 
                  
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15), 
                      border: Border.all(
                        color: Colors.black, 
                        width: 0.3, 
                      ),
                      color: Colors.transparent, 
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8), 
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
              onPressed: null, 
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
                Navigator.pop(context); 
                _showRequestFormDialog(
                    context, doc); 
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
                    "Request",
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
                  
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30), 
                      border: Border.all(
                        color: Colors.grey, 
                        width: 0.3, 
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
                  
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30), 
                      border: Border.all(
                        color: Colors.grey, 
                        width: 0.3, 
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

                    
                    final hardwareQuery = await FirebaseFirestore.instance
                        .collection('hardwares')
                        .where('Title', isEqualTo: hardwareTitle)
                        .get();

                    if (hardwareQuery.docs.isNotEmpty) {
                      final hardwareDoc = hardwareQuery.docs.first;

                      
                      await FirebaseFirestore.instance
                          .collection('hardwares')
                          .doc(hardwareDoc.id)
                          .update({'Availability': user.uid});

                      
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
