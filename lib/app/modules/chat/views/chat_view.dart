import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tedangle/app/app_service.dart';
import 'package:tedangle/app/modules/chat/models/message.dart';

class ChatModel {
  final String message;
  final bool isFromSender;

  ChatModel(this.message, this.isFromSender);
}

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  TextEditingController messageController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> _submit(AppService appService) async {
    isLoading = true;
    setState(() {});
    final text = messageController.text;
    if (text.isEmpty) {
      return;
    }
    if (_formkey.currentState != null && _formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      await appService.saveMessage(text);
      messageController.text = '';
    }
    isLoading = false;
    setState(() {});
  }

  // List<ChatModel> chats = [
  //   ChatModel('message', true),
  //   ChatModel('message', false),
  //   ChatModel('message', true),
  //   ChatModel('message', false)
  // ];

  @override
  Widget build(BuildContext context) {
    final appService = Get.put(AppService());

    return GetX<AppService>(builder: (model) {
      return Scaffold(
        backgroundColor: const Color(0xFF142F43),
        // appBar: AppBar(
        //   title: const Text('ChatView'),
        //   centerTitle: true,
        // ),
        body: Column(
          children: [
            Container(
              height: 100.0,
              color: Colors.transparent,
              child: Container(
                  decoration: const BoxDecoration(
                      color: Color(0xFF00569E),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40.0),
                        bottomRight: Radius.circular(40.0),
                      )),
                  child: Center(
                    child: Text(
                      "${appService.appName.value}Java, Python",
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  )),
            ),
            SizedBox(
              height: Get.height / 1.4,
              child: StreamBuilder<List<Message>>(
                stream: appService.getMessages(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final messages = snapshot.data!;
                    return ListView.builder(
                        shrinkWrap: true,
                        reverse: true,
                        itemCount: messages.length,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        itemBuilder: (BuildContext context, int index) {
                          final message = messages[index];
                          // return Text(message.content);
                          return ChatBubble(
                            message: message,
                          );
                        });
                  }
                  return const Center(
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: Colors.grey,
                    ),
                  );
                },
              ),
              //  ListView.builder(
              //     shrinkWrap: true,
              //     itemCount: chats.length,
              //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              //     itemBuilder: (BuildContext context, int index) {
              //       return ChatBubble(
              //           text: chats[index].message,
              //           isFromSender: chats[index].isFromSender);
              //     }),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, bottom: 16, top: 12),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: Get.width / 1.38,
                    child: Form(
                      key: _formkey,
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        controller: messageController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          filled: true,
                          hintStyle: const TextStyle(color: Color(0xFFA6A6A6)),
                          hintText: "Type in your text",
                          fillColor: const Color(0xFF004AAD),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      color: Color(0xFF004AAD),
                    ),
                    height: 60.0,
                    width: 60.0,
                    child: IconButton(
                      onPressed: isLoading
                          ? () {}
                          : () {
                              // chats.add(ChatModel(messageController.text, true));
                              _submit(appService);
                              // setState(() {});
                            },
                      icon: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Color(0xFFFFC331),
                              ),
                            )
                          : const Icon(Icons.bolt, color: Color(0xFFFFC331)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({Key? key, required this.message}) : super(key: key);
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 16),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: Color(0xFF00569E),
                ),
                // height: 70.0,
                // width: 70.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    message.content,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  DateFormat('dd-MM-yyyy').format(message.createAt).toString(),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 5),
                MarkAsRead(
                  message: message,
                ),
              ],
            )
          ],
        ),
      ],
    );
  }
}

class MarkAsRead extends StatelessWidget {
  final Message message;
  const MarkAsRead({Key? key, required this.message}) : super(key: key);

  final _markRead = const Icon(
    Icons.mark_chat_read,
    color: Colors.green,
    size: 18.0,
  );

  final _markUnRead = const Icon(
    Icons.mark_chat_unread,
    color: Colors.grey,
    size: 18.0,
  );

  Future<Widget> _getMark(BuildContext context) async {
    if (message.isMine == false) {
      if (message.markAsRead == false) {
        final appService = Get.put(AppService());
        await appService.markAsRead(message.id);
      }

      return const SizedBox.shrink();
    }

    if (message.isMine == true) {
      if (message.markAsRead == true) {
        return _markRead;
      } else {
        return _markUnRead;
      }
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getMark(context),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data as Widget;
        }

        return const SizedBox.shrink();
      },
    );
  }
}
