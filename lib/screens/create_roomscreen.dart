import 'package:flutter/material.dart';
import 'package:type_racer/utils/socket_client.dart';
import 'package:type_racer/widgets/custom_button.dart';
import 'package:type_racer/widgets/custom_textfield.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final SocketClient _socketClient = SocketClient.instance;

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  testing(){
    _socketClient.socket!.emit('test', 'this is working');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 600
          ),
          child: Container(
            margin: const EdgeInsets.symmetric( horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Create Room', style: TextStyle(fontSize: 30),),
                SizedBox(height: size.height*0.08,),
                CustomTextField(controller: _nameController, 
                hintText: 'Enter your nickname'),
                const SizedBox(height: 30,), 
                CustomButton(
                  text: 'Create',  
                  onTap: testing)
              ],
            ),
          ),
          ),
      ),
    );
  }
}