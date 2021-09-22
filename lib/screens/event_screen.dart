import 'package:events/screens/login_screen.dart';
import 'package:events/shared/authentication.dart';
import 'package:events/shared/firestore_helper.dart';
import 'package:flutter/material.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import "package:events/models/event_detail.dart";

class EventScreen extends StatelessWidget {
  final String uid;

  EventScreen(this.uid);

  @override
  Widget build(BuildContext context) {
    final Authentication auth = new Authentication();
    return Scaffold(
      appBar: AppBar(
        title: Text("Event"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              auth.signOut().then((result) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              });
            },
          ),
        ],
      ),
      body: EventList(uid),
    );
  }
}

class EventList extends StatefulWidget {
  final String uid;

  EventList(this.uid);

  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  final Firestore db = Firestore.instance;
  List<EventDetail> details = [];
  List<Favorite> favorites = [];

  void toggleFavorite(EventDetail ed) async {
    if (isUserFavorite(ed.id)){
      Favorite favorite = favorites.firstWhere((Favarite f) => (f.eventId == ed.id));
      String favId = favorite.id;
      await FirestoreHelper.deleteFavorite(favId);
    }else{
      await FirestoreHelper.addFavorite(ed, uid);
    }
    List<Favorite> updateFavorites = await FirestoreHelper.getUserFavorites(uid);
    setState((){
      favorites = updateFavorites;
    });
    FirestoreHelper.addFavorite(ed, widget.uid);
  }

  bool isUserFovorite (String evenId){
    Favorite favorite = favorites.firstWhere((Favorite f) => (f.evenId == eventId), orElse: () => null);
    if (favorite == null)
      return false;
    else
      return true;
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      getDetailsList().then((data) {
        setState(() {
          details = data;
        });
      });
    }

    FirestoreHelper.getUserFavorites(uid).then((data){
      setState((){
        favorites = data;
      });
    });
  }

  Future<List<EventDetail>> getDetailsList() async {
    var data = await db.collection("event_details").getDocuments();
    if (data != null) {
      details = data.documents.map((document) {
        return EventDetail.fromMap(document);
      }).toList();
      int i = 0;
      details.forEach((detail) {
        detail.id = data.documents[i].documentID;
        i++;
      });
    }
    return details;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: (details != null) ? details.length : 0,
      itemBuilder: (context, position) {
        Color starColor = (isUserFavorite(details[position].id) ? Colors.amber : Colors.grey);
        String sub =
            "Date: ${details[position].date} - Start: ${details[position].startTime} - End: ${details[position].endTime}";
        return ListTile(
          title: Text(details[position].description),
          subtitle: Text(sub),
          trailing: IconButton(
            icon: Icon(Icons.star, color: startColor),
            onPressed: () {
              toggleFavorite(details[position]);
            },
          ),
        );
      },
    );
  }
}
