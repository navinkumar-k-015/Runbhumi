import 'package:Runbhumi/services/EventService.dart';
import 'package:Runbhumi/services/chatroomServices.dart';
import 'package:Runbhumi/utils/Constants.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import '../widget/widgets.dart';
import 'conversation.dart';

/*
  Code For Network Page
*/
class Network extends StatefulWidget {
  @override
  _NetworkState createState() => _NetworkState();
}

class _NetworkState extends State<Network> {
  // for Title
  Widget _buildTitle(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: const Text(
        'Network',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(context),
        automaticallyImplyLeading: false,
      ),
      body: /*DefaultTabController(
        length: 3,
        child:*/
          Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Text(
                'Schedule',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            //schedule
            Schedule(), //scheduleList: scheduleList)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Text(
                'Chats',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.start,
              ),
            ),
            // ChatsTabs(),
            // TODO: replace placeholders with actual UI
            Expanded(
              // child: TabBarView(
              //   children: [
              //     PlaceholderWidget(),
              //     PlaceholderWidget(),
              //     PlaceholderWidget(),
              //   ],
              // ),
              child: DirectChats(),
            ),
          ],
        ),
      ),
      // ),
    );
  }
}

class DirectChats extends StatefulWidget {
  @override
  _DirectChatsState createState() => _DirectChatsState();
}

class _DirectChatsState extends State<DirectChats> {
  Stream userDirectChats;
  TextEditingController friendsSearch;
  String searchQuery = "";
  void initState() {
    getUserChats(); //Getting the chats of the particular user
    super.initState();
    friendsSearch = new TextEditingController();
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
    print("searched " + newQuery);
  }

  getUserChats() async {
    print("got here");
    ChatroomService().getUsersDirectChats().then((snapshots) {
      setState(() {
        print("got here");
        userDirectChats = snapshots;
        print("we got the data + ${userDirectChats.toString()} ");
      });
    });
  }

  Widget getDirectChats() {
    return StreamBuilder(
      stream: userDirectChats,
      builder: (context, asyncSnapshot) {
        print("Working");
        return asyncSnapshot.hasData
            ? asyncSnapshot.data.documents.length > 0
                ? ListView.builder(
                    itemCount: asyncSnapshot.data.documents.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                        //TODO: UI for the list of chats.
                        onTap: () {
                          //Sending the user to the chat room
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Conversation(
                                        chatRoomId: asyncSnapshot
                                            .data.documents[index]
                                            .get('chatRoomId'),
                                      )));
                        },
                        leading: Icon(Icons.person),
                        trailing: Icon(Icons.send),
                      );
                    })
                : //if you have no friends you will get this illustration
                Container(
                    child: Center(
                      child: Image.asset("assets/add-friends.png"),
                    ),
                  )
            : Loader();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Container(
              child: TextField(
                onTap: () {
                  showSearch(context: context, delegate: UserSearchDirect());
                },
                controller: friendsSearch,
                decoration: const InputDecoration(
                  hintText: 'Search friends...',
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    borderSide: BorderSide(color: Color(00000000)),
                  ),
                  prefixIcon: Icon(Feather.search),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    borderSide: BorderSide(color: Color(00000000)),
                  ),
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(fontSize: 16.0),
                onChanged: updateSearchQuery,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: <Widget>[getDirectChats()],
            ),
          ),
        ],
      ),
    );
  }
}

class UserSearchDirect extends SearchDelegate<ListView> {
  getUser(String query) {
    print("getUser");
    return FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: query)
        .limit(1)
        .snapshots();
  }

  getUserFeed(String query) {
    print("getUserFeed");
    return FirebaseFirestore.instance
        .collection("users")
        .where("userSearchParam", arrayContains: query)
        .limit(5)
        .snapshots();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Feather.x),
        onPressed: () {
          query = '';
        },
      ),
    ];
    // throw UnimplementedError();
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        });
    // throw UnimplementedError();
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder(
        stream: getUser(query),
        builder: (context, asyncSnapshot) {
          return asyncSnapshot.hasData
              ? ListView.builder(
                  itemCount: asyncSnapshot.data.documents.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 16.0),
                      child: GestureDetector(
                        onTap: () {},
                        child: Card(
                          shadowColor: Color(0x44393e46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          elevation: 20,
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image(
                                image: NetworkImage(
                                  asyncSnapshot.data.documents[index]
                                      .get('profileImage'),
                                ),
                              ),
                            ),
                            title: Text(
                              asyncSnapshot.data.documents[index].get('name'),
                            ),
                            subtitle: Text(
                              asyncSnapshot.data.documents[index]
                                  .get('username'),
                            ),
                          ),
                        ),
                      ),
                    );
                  })
              : Container(
                  child: Center(
                    child: Image(
                      image: AssetImage("assets/search-illustration.png"),
                    ),
                  ),
                );
        });
  }

  createChatRoom(String userId, BuildContext context, String username) {
    print(userId);
    print(Constants.prefs.getString('userId'));
    if (userId != Constants.prefs.getString('userId')) {
      List<String> users = [userId, Constants.prefs.getString('userId')];
      String chatRoomId =
          getUsersInvolved(userId, Constants.prefs.getString('userId'));

      Map<String, dynamic> chatRoom = {
        "users": users,
        "chatRoomId": chatRoomId,
      };
      ChatroomService().addChatRoom(chatRoom, chatRoomId);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Conversation(
                    chatRoomId: chatRoomId,
                  )));
    } else {
      print("Cannot do that");
    }
  }

  getUsersInvolved(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder(
        stream: getUserFeed(query),
        builder: (context, asyncSnapshot) {
          print("Working");
          return asyncSnapshot.hasData
              ? ListView.builder(
                  itemCount: asyncSnapshot.data.documents.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          print("creating a chat room");
                          //Creating a chatroom for the user he searched for
                          // Can get any information of that other user here.
                          createChatRoom(
                              asyncSnapshot.data.documents[index].get('userId'),
                              context,
                              asyncSnapshot.data.documents[index]
                                  .get('username'));
                        },
                        child: Card(
                          shadowColor: Color(0x44393e46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          elevation: 20,
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image(
                                image: NetworkImage(asyncSnapshot
                                    .data.documents[index]
                                    .get('profileImage')
                                    .toString()),
                              ),
                            ),
                            title: Text(asyncSnapshot.data.documents[index]
                                .get('name')),
                            subtitle: Text(
                              asyncSnapshot.data.documents[index]
                                  .get('username'),
                            ),
                          ),
                        ),
                      ),
                    );
                  })
              : Container(
                  child: Center(
                    child: Image(
                      image: AssetImage("assets/search-illustration.png"),
                    ),
                  ),
                );
        });
    // throw UnimplementedError();
  }
}

class Schedule extends StatefulWidget {
  // const Schedule({
  //   Key key,
  //   @required this.scheduleList,
  // }) : super(key: key);

  // final List scheduleList;

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  Stream currentFeed;
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
    getUserInfoEvents();
  }

  getUserInfoEvents() async {
    EventService().getCurrentUserFeed().then((snapshots) {
      setState(() {
        currentFeed = snapshots;
        print("we got the data + ${currentFeed.toString()} ");
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget feed() {
    return StreamBuilder(
      stream: currentFeed,
      builder: (context, asyncSnapshot) {
        print("Working");
        return asyncSnapshot.hasData
            ? asyncSnapshot.data.documents.length > 0
                ? ListView.builder(
                    itemCount: asyncSnapshot.data.documents.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        child: Card(
                          shadowColor: Color(0x44393e46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          elevation: 5,
                          child: Container(
                            width: 300,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    isThreeLine: true,
                                    title: Text(
                                      asyncSnapshot.data.documents[index].get(
                                          'eventName'), // widget.scheduleList[index][],
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Icon(
                                          Feather.map_pin,
                                          size: 16.0,
                                        ),
                                        Text(
                                          asyncSnapshot.data.documents[index]
                                              .get('location'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                      ],
                                    ),
                                    trailing: Column(
                                      children: [
                                        //time
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(DateFormat('E\ndd/MM\nkk:mm')
                                                .format(asyncSnapshot
                                                    .data.documents[index]
                                                    .get('dateTime')
                                                    .toDate())
                                                .toString()),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : //if you have no events you will get this illustration
                Container(
                    child: Center(
                      child: Image.asset("assets/events.png", height: 200),
                    ),
                  )
            : Loader();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height / 5,
        child: Stack(
          children: <Widget>[feed()],
        ));

    //   ListView.builder(
    //     scrollDirection: Axis.horizontal,
    //     itemBuilder: (context, index) {
    //       return Padding(
    //         padding: const EdgeInsets.symmetric(
    //           horizontal: 8.0,
    //         ),
    //         child: Card(
    //           shadowColor: Color(0x44393e46),
    //           shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.all(Radius.circular(20)),
    //           ),
    //           elevation: 5,
    //           child: Container(
    //             width: 300,
    //             child: Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   ListTile(
    //                     isThreeLine: true,
    //                     title: Text(
    //                       // widget.scheduleList[index][],
    //                       style: Theme.of(context).textTheme.headline6,
    //                     ),
    //                     subtitle: Row(
    //                       children: [
    //                         Icon(
    //                           Feather.map_pin,
    //                           size: 16.0,
    //                         ),
    //                         Text(
    //                           "Bahrain",
    //                           style: Theme.of(context).textTheme.subtitle1,
    //                         ),
    //                       ],
    //                     ),
    //                     trailing: Column(
    //                       children: [
    //                         //time
    //                         Row(
    //                           mainAxisSize: MainAxisSize.min,
    //                           children: [
    //                             Text(DateTime.now().hour.toString()),
    //                             Text(":"),
    //                             Text(DateTime.now().minute.toString()),
    //                           ],
    //                         ),
    //                         //day
    //                         // Text(DateTime.now().weekday.toString()),
    //                         if (DateTime.now().weekday == 1) Text("MON"),
    //                         if (DateTime.now().weekday == 2) Text("TUE"),
    //                         if (DateTime.now().weekday == 3) Text("WED"),
    //                         if (DateTime.now().weekday == 4) Text("THU"),
    //                         if (DateTime.now().weekday == 5) Text("FRI"),
    //                         if (DateTime.now().weekday == 6) Text("SAT"),
    //                         if (DateTime.now().weekday == 7) Text("SUN"),
    //                       ],
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //       );
    //     },
    //     itemCount: widget.scheduleList.length,
    //   ),
    // );
  }
}

class ChatsTabs extends StatelessWidget {
  const ChatsTabs({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 6,
            offset: Offset(0, -1),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(child: Text("Direct")),
            Tab(child: Text("Team")),
            Tab(child: Text("B/W Teams")),
          ],
          indicator: new BubbleTabIndicator(
            indicatorHeight: 30.0,
            indicatorColor: Theme.of(context).primaryColor,
            tabBarIndicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
      ),
    );
  }
}
