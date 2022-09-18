import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseAuth _auth;
  FirebaseUser _user;
  Firestore _store;
  QuerySnapshot _allMesseges;
  String message;
  TextEditingController _controller;
  bool updateExistingText;
  DocumentSnapshot documentSnapshot;
  @override
  void initState() {
    super.initState();
    updateExistingText = false;

    _controller = TextEditingController();
    _controller.text = '';
    getCurrentUser();
    getAllMessages();
  }

  void getCurrentUser() async {
    try {
      _auth = FirebaseAuth.instance;
      _store = Firestore.instance;
      _user = await _auth.currentUser();
      if (_user == null) {
        print("user not signed in");
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  void getAllMessages() async {
    _allMesseges = await _store.collection('messeges').getDocuments();
    print('-' * 200);
    print(_allMesseges.documents);
    print(_allMesseges.documents.length);
    print(_allMesseges.documents.first);

    print(_allMesseges.documents.first.data);

    print(_allMesseges.documents.first.data['text']);

    _allMesseges.documents.forEach((e) {
      print(e.data['text']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 20),
            child: IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  //Implement logout functionality
                  _auth.signOut();
                  Navigator.pop(context);
                }),
          ),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder(
              stream: _store
                  .collection('messeges')
                  .orderBy('sent_date', descending: true)
                  .snapshots(),
              builder: ((context, snapshot) {
                if (snapshot.hasError) {
                  return CircularProgressIndicator();
                } else if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  QuerySnapshot data = snapshot.data;
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 20.0),
                      children: [
                        // ignore: sdk_version_ui_as_code
                        for (DocumentSnapshot document in data?.documents)
                          TextBubble(
                            message: document['text'],
                            sender: document['sender'],
                            messageColor: document['sender'] == _user.email
                                ? Colors.lightBlueAccent
                                : Colors.grey[850],
                            messageAlign: document['sender'] == _user.email
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            canDelete: document['sender'] == _user.email
                                ? () async {
                                    //Delete this message
                                    await _store
                                        .collection('/messeges')
                                        .document(document.documentID)
                                        .delete();
                                  }
                                : null,
                            onEdit: document['sender'] == _user.email
                                ? () async {
                                    setState(() {
                                      documentSnapshot = document;
                                      updateExistingText = true;
                                      _controller.text = document['text'];
                                    });
                                  }
                                : null,
                          )
                      ],
                    ),
                  );
                } else {
                  return Text("do shit");
                }
              }),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Material(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.lightBlueAccent,
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        onChanged: (value) {
                          //Do something with the user input.
                          setState(() {
                            message = value;
                          });
                        },
                        onSubmitted: (string) {
                          if (!updateExistingText) {
                            _store.collection('messeges').add({
                              'sender': _user.email,
                              "text": message,
                              'sent_date': DateTime.now(),
                            });
                          } else {
                            //Update the document
                            _store
                                .collection('/messeges')
                                .document(documentSnapshot.documentID)
                                .updateData({'text': _controller.text});
                            setState(() {
                              updateExistingText = false;
                              documentSnapshot = null;
                              _controller.text = '';
                            });
                          }
                          setState(() {
                            _controller.text = '';
                          });
                        },
                        decoration: kMessageTextFieldDecoration.copyWith(
                          suffixIcon: updateExistingText
                              ? IconButton(
                                  icon: Icon(Icons.cancel),
                                  color: Colors.black54,
                                  onPressed: () {
                                    setState(() {
                                      updateExistingText = false;
                                      documentSnapshot = null;
                                      _controller.text = '';
                                    });
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      if (!updateExistingText) {
                        _store.collection('messeges').add({
                          'sender': _user.email,
                          "text": message,
                          'sent_date': DateTime.now(),
                        });
                      } else {
                        //Update the document
                        _store
                            .collection('/messeges')
                            .document(documentSnapshot.documentID)
                            .updateData({'text': _controller.text});
                        setState(() {
                          updateExistingText = false;
                          documentSnapshot = null;
                          _controller.text = '';
                        });
                      }
                      setState(() {
                        _controller.text = '';
                      });
                    },
                    child: Text(
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

class TextBubble extends StatefulWidget {
  String message;
  String sender;
  CrossAxisAlignment messageAlign;
  Color messageColor;
  Function canDelete;
  Function onEdit;

  TextBubble({
    @required this.message,
    @required this.sender,
    @required this.messageAlign,
    @required this.messageColor,
    @required this.canDelete,
    @required this.onEdit,
  });

  @override
  State<TextBubble> createState() => _TextBubbleState();
}

class _TextBubbleState extends State<TextBubble> {
  bool isDeleteIconVisible;
  @override
  void initState() {
    super.initState();
    isDeleteIconVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: widget.messageAlign,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7.0),
          child: Text(
            widget.sender,
            style: TextStyle(color: Colors.black54),
            softWrap: true,
          ),
        ),
        Row(
          mainAxisAlignment: widget.messageAlign == CrossAxisAlignment.end
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Visibility(
              child: IconButton(
                onPressed: () {
                  setState(() {
                    isDeleteIconVisible = false;
                  });
                  widget.canDelete();
                },
                icon: Icon(Icons.delete),
              ),
              visible: isDeleteIconVisible,
            ),
            Visibility(
              child: IconButton(
                onPressed: () {
                  setState(() {
                    isDeleteIconVisible = false;
                  });
                  widget.onEdit();
                },
                icon: Icon(Icons.edit),
              ),
              visible: isDeleteIconVisible,
            ),
            Flexible(
              child: TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateColor.resolveWith(
                      (states) => Colors.transparent),
                ),
                onPressed: () {
                  print(widget.canDelete);
                  if (widget.canDelete != null) {
                    setState(() {
                      isDeleteIconVisible = !isDeleteIconVisible;
                    });
                  } else {
                    setState(() {
                      isDeleteIconVisible = false;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                        topLeft: widget.messageAlign == CrossAxisAlignment.end
                            ? Radius.circular(30)
                            : Radius.circular(0),
                        topRight: widget.messageAlign != CrossAxisAlignment.end
                            ? Radius.circular(30)
                            : Radius.circular(0)),
                    color: widget.messageColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 100,
                        softWrap: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
