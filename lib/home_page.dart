import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterBlue ble = FlutterBlue.instance;
  bool isScanning = false;

  Stream<List<ScanResult>> scanDevices() async* {
    isScanning = false;
    if(await Permission.bluetoothScan.request().isGranted){
      if(await Permission.bluetoothConnect.request().isGranted){
        await ble.startScan(timeout: const Duration(seconds: 5));
        isScanning = true;
        await ble.stopScan();
        setState(() {});
      }
    }
    yield* ble.scanResults;
  }

  @override
  void initState() {
    scanDevices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 400,
            child: StreamBuilder<List<ScanResult>>(
                stream: scanDevices(),
                builder: (context, snapshot){
                  log("========");
                if(snapshot.hasData){
                  return isScanning ?const Center(
                    child: CircularProgressIndicator(),
                  ):ListView.builder(
                    itemCount: snapshot.data!.length,
                      itemBuilder: (context, index){
                        ScanResult data = snapshot.data![index];
                        return Card(
                          child: ListTile(
                            title: Text(data.device.name),
                            subtitle: Text(data.device.type.toString()),
                            trailing: Text(data.rssi.toString()),
                          ),
                        );
                      });
                }else{
                  return const Center(child: Text('No founnd Device'));
                }
                },
            ),
          ),
          const SizedBox(height: 30),

          ElevatedButton(
              onPressed: ()async{
                // await scanDevices();
              },
              child: const Text('Scan'),)
        ],
      ),
    );
  }
}
