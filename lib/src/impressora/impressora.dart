import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class Impressora {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  imprimir(List<Uint8List> textoimagem) async {
    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT

//     var response = await http.get("IMAGE_URL");
//     Uint8List bytes = response.bodyBytes;
    bluetooth.isConnected.then((isConnected) {
      if (isConnected!) {
        textoimagem.forEach((element) {
          bluetooth.printImageBytes(element);
        });

        bluetooth.paperCut();
      }
    });
  }
}
