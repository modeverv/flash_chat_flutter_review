import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat_flutter_review/constants.dart';
import 'package:flutter/material.dart';

// https://zenn.dev/namioto/articles/026077bdee5eaa

final _store = FirebaseFirestore.instance;
User? user;

class ChatScreen extends StatefulWidget {
  static String id = "chat_screen";

  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  String message = "";

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    messageStream();
  }

  void getCurrentUser() {
    final u = _auth.currentUser;
    print(u);
    user = u;
    if (user != null) {
      print(user!.email);
    }
  }

  void messageStream() async {
    await for (var messages in _store.collection('messages').snapshots()) {
      for (var message in messages.docs) {
        print(message.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                await _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MyStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      messageTextController.clear();
                      print(DateTime.now().toUtc().millisecondsSinceEpoch);
                      try {
                        await _store.collection("messages").add({
                          'message': message,
                          'sender': user!.email,
                          'created_at':
                              DateTime.now().toUtc().millisecondsSinceEpoch,
                        });
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      builder: (context, snapshot) {
        print(snapshot);
        if (!snapshot.hasData) {
          print(1);
          return Column(
            children: const [
              CircularProgressIndicator(
                backgroundColor: Colors.lightBlue,
              )
            ],
          );
        }
        final messages = snapshot.data!.docs.reversed;
        List<MessageBubble> messageWidgets = [];
        for (var message in messages) {
          final Map<String, dynamic> m = message.data() as Map<String, dynamic>;
          final messageText = m['message'];
          final messageSender = m['sender'];
          messageWidgets.add(MessageBubble(
            text: messageText,
            sender: messageSender,
          ));
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageWidgets,
          ),
        );
      },
      stream: _store
          .collection('messages')
          .orderBy('created_at', descending: false)
          .snapshots(),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final text;
  final sender;
  MessageBubble({this.text, this.sender});
  bool isMe = false;

  @override
  Widget build(BuildContext context) {
    print(user!.email);
    print(sender);
    if (sender == user!.email) {
      isMe = true;
    }
    print(isMe);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            !isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            '$sender',
            style: const TextStyle(color: Colors.black54, fontSize: 12.0),
          ),
          Material(
            borderRadius: !isMe
                ? const BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: !isMe ? Colors.white : Colors.lightBlueAccent,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                '$text',
                style: TextStyle(
                    fontSize: 15.0,
                    color: !isMe ? Colors.black54 : Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
