import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/userProvider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _profileInfoController;

  @override
  void initState() {
    super.initState();
    _profileInfoController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch the current user when the screen is first built
      Provider.of<UserProvider>(context, listen: false).fetchCurrentUser();
      _profileInfoController.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch the current user every time dependencies change
    Provider.of<UserProvider>(context).fetchCurrentUser();
  }

  @override
  void dispose() {
    _profileInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (userProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: 200,
                  height: 20,
                  color: Colors.grey[200],
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Text(
            'Please log in to view your profile.',
            style: TextStyle(fontSize: 18, color: Colors.red[600]),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.edit, color: Colors.red),
            onPressed: () {
              Navigator.of(context).pushNamed('/editProfile');
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _profileInfoController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _profileInfoController,
            child: ScaleTransition(
              scale: _profileInfoController,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  child: InteractiveViewer(
                                    child: Image.network(
                                      user['image']?['url'] ?? '',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Hero(
                            tag: 'profileImage',
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red[800],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 4),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                  BoxShadow(
                                    color: Colors.white38,
                                    offset: Offset(0, -4),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: user['image']?['url'] != null
                                    ? CircleAvatar(
                                        radius: 75,
                                        backgroundImage: NetworkImage(user['image']['url']),
                                        onBackgroundImageError: (error, stackTrace) {
                                          print('Error loading image: $error');
                                        },
                                      )
                                    : Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 90,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '${user['firstName'] ?? 'N/A'} ${user['lastName'] ?? 'N/A'}',
                        style: GoogleFonts.dancingScript(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        user['email'] ?? 'N/A',
                        style: GoogleFonts.dancingScript(
                          fontSize: 18,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: Colors.white38,
                              offset: Offset(0, -4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: FaIcon(FontAwesomeIcons.phone, color: Colors.red),
                                title: Text(
                                  'Phone Number',
                                  style: GoogleFonts.dancingScript(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[800],
                                  ),
                                ),
                                subtitle: Text(
                                  user['phoneNumber'] ?? 'N/A',
                                  style: GoogleFonts.dancingScript(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Divider(color: Colors.grey[700]),
                              ListTile(
                                leading: FaIcon(FontAwesomeIcons.locationArrow, color: Colors.red),
                                title: Text(
                                  'Address',
                                  style: GoogleFonts.dancingScript(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[800],
                                  ),
                                ),
                                subtitle: Text(
                                  user['address'] ?? 'N/A',
                                  style: GoogleFonts.dancingScript(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red[800]!, Colors.red[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: Colors.white38,
                              offset: Offset(0, -4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Provider.of<UserProvider>(context, listen: false).logout(context);
                          },
                          child: Text(
                            'Logout',
                            style: GoogleFonts.dancingScript(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
