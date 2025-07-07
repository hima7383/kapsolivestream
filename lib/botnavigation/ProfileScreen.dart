import 'package:flutter/material.dart';
import 'package:tikvid/entityclases/userdata.dart';
import 'package:tikvid/personalprofile.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Top Card (396x144)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: 396,
              height: 144,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile picture placeholder
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 16),
                    // Text column with constrained width
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: 250),
                            child: Text(
                              Userdata.userId ?? 'Username',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(height: 8),
                          Image.asset('images/lvl.png'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Three equally distributed PICTURES
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPicture('images/purchessvip.png'),
                _buildPicture('images/family.png'),
                _buildPicture('images/money.png'),
              ],
            ),
          ),
          
          // List of items with red dividers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildListTileWithDivider('Memories', Icons.access_time, onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => MemoriesScreen()));
                    // Navigate to memories screen
                  }),
                  _buildListTileWithDivider('Soon added 1', Icons.add),
                  _buildListTileWithDivider('Soon added 2', Icons.add),
                  _buildListTileWithDivider('Soon added 3', Icons.add),
                  _buildListTileWithDivider('Soon added 4', Icons.add),
                  _buildListTileWithDivider('Soon added 5', Icons.add),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPicture(String imagePath) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTileWithDivider(String title, IconData icon, {VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(title, style: TextStyle(color: Colors.white)),
          trailing: Icon(Icons.chevron_right, color: Colors.white),
          onTap: onTap,
        ),
        Divider(
          color: Colors.red,
          height: 1,
          thickness: 1,
          indent: 16,  // Matches ListTile leading padding
          endIndent: 16, // Matches ListTile trailing padding
        ),
      ],
    );
  }
}