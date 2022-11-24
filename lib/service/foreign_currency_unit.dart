import 'package:xml/xml.dart';
import 'package:xml2json/xml2json.dart';

import 'package:http/http.dart' as http;

class ServiceCurrencyUnit {
  var url_TCMB = Uri.parse("https://www.tcmb.gov.tr/kurlar/today.xml");
  List<XmlElement> getElementsInBody = [];
  double? _usdValue, _euroValue;

  double? get getUsdValue => _usdValue;
  double? get getEuroValue => _euroValue;
  set setUsdValue(double value) => _usdValue = value;
  set setEuroValue(double value) => _euroValue = value;

  Future fetchCurrencyUnit() async {
    final Xml2Json xml2json = Xml2Json();
    XmlDocument foreignCurrencyXml;
    var res = await http.get(url_TCMB);
    foreignCurrencyXml = XmlDocument.parse(res.body);
    getElementsInBody =
        foreignCurrencyXml.findAllElements('Currency').toList(growable: true);

    for (var element in getElementsInBody) {
      if (element.getAttribute('Kod') == 'USD') {
        setUsdValue = double.parse(element.getElement('BanknoteBuying')!.text);
      }

      if (element.getAttribute('Kod') == 'EUR') {
        setEuroValue = double.parse(element.getElement('BanknoteBuying')!.text);
      }
    }

    /*
    xml2json.parse(res.body);
    var jsonString = xml2json.toParker();
    var data = jsonDecode(jsonString);
    for (var element in data['Tarih_Date']['Currency']) {
      print(element);
      print("********");
    }
    */
  }
}
