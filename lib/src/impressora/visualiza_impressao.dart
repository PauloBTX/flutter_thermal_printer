import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thermalprinter/src/common/utils.dart';
import 'package:thermalprinter/src/impressora/Impressora.dart';
import 'package:thermalprinter/src/widgets/widget_to_image.dart';

class VisualizacaoImpressao extends StatefulWidget {
  final BuildContext? menuScreenContext;
  final Function? onScreenHideButtonPressed;
  final bool hideStatus;
  const VisualizacaoImpressao({Key? key, this.menuScreenContext, this.onScreenHideButtonPressed, this.hideStatus = false}) : super(key: key);

  @override
  VisualizacaoImpressaoState createState() {
    return new VisualizacaoImpressaoState();
  }
}

class VisualizacaoImpressaoState extends State<VisualizacaoImpressao> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  Impressora? impressora;
  GlobalKey? key1;
  List<Uint8List>? listaImpressao;
  double _tamanhoContainer = 190;

  @override
  void initState() {
    //_impressora = Impressora();
    initPlatformState();
    impressora = Impressora();
    permissoes().then((value) => {});
  }

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      // TODO - Error
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected!) {
      setState(() {
        _connected = true;
      });
    }
  }

  Future<Map<Permission, PermissionStatus>> permissoes() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.locationAlways,
    ].request();
    return statuses;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: DropdownButton(
                                          hint: const Text("Selecione a impressora"),
                                          items: _getDeviceItems(),
                                          onChanged: (value) => setState(() => _device = value as BluetoothDevice),
                                          value: _device,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(primary: Colors.brown),
                                      onPressed: () {
                                        initPlatformState();
                                      },
                                      child: const Text(
                                        'Atualizar Lista',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(primary: _connected ? Colors.red : Colors.green),
                                      onPressed: _connected ? _disconnect : _connect,
                                      child: Text(
                                        _connected ? 'Desconectar' : 'Conectar',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WidgetToImage(
                      builder: (key) {
                        key1 = key;
                        return Container(
                          width: _tamanhoContainer,
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: const [
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Impressora Thermal via Bluetooth + Flutter",
                                style: TextStyle(backgroundColor: Colors.white, color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Este é um projeto de teste. Nesta aula temos a intenção de testar a impressora com caracteres especiais como â ç á é í ó ú ù % @ \$ ",
                                style: TextStyle(backgroundColor: Colors.white, color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              Divider(
                                color: Colors.black,
                              ),
                              Text(
                                "FIM",
                                style: TextStyle(backgroundColor: Colors.white, color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 40,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.red.shade900),
                        onPressed: () async {
                          if (_connected) {
                            listaImpressao = [];
                            Utils.capture(key1!).then((value) {
                              listaImpressao!.add(value);
                              impressora?.imprimir(listaImpressao!);
                            });
                          } else {
                            show('Impressora não conectada');
                          }
                        },
                        child: const Text('IMPRIMIR', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(const DropdownMenuItem(
        child: Text('EM BRANCO'),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name!),
          value: device,
        ));
      });
    }
    return items;
  }

  void _connect() {
    if (_device == null) {
      show('Impressora não selecionada.');
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected!) {
          bluetooth.connect(_device!).catchError((error) {
            setState(() => _connected = false);
          });
          setState(() => _connected = true);
        }
      });
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _connected = false);
  }

  Future show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }
}
