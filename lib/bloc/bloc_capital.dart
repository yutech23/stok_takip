import 'dart:async';
import 'package:intl/intl.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';
import '../utilities/share_func.dart';
import '../validations/format_upper_case_capital_text_format.dart';
import 'package:turkish/turkish.dart';

class BlocCapital {
  BlocCapital() {
    start();
  }

  start() async {
    await getCashBox();
    await getAllPartner();
  }

  Map<String, dynamic> _cashBox = {};

  String? _selectCashBalance = "+";
  String? _selectBankBalance = "+";

  get getterSelectCashBalance => _selectCashBalance;
  get getterSelectBankBalance => _selectBankBalance;
  set selectCashBalance(String? value) => _selectCashBalance = value;
  set selectBankBalance(String? value) => _selectBankBalance = value;

  final StreamController<Map<String, dynamic>> _streamControllerCashBox =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get getStreamCashBox =>
      _streamControllerCashBox.stream;

  List<Map<String, dynamic>> _allPartner = [];

  final StreamController<List<Map<String, dynamic>>>
      _streamControllerAllPartner =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get getStreamAllPartner =>
      _streamControllerAllPartner.stream;

  String? _selectedPartnerId;

  String? get getterSelectedPartnerId => _selectedPartnerId;
  set setterSelectedPartnerId(String? value) => _selectedPartnerId = value;

  String? _selectedPartnerIdPopup;

  String? get getterSelectedPartnerIdPopup => _selectedPartnerId;
  set setterSelectedPartnerIdPopup(String? value) =>
      _selectedPartnerIdPopup = value;

  final List<Map<String, dynamic>> _cariPartner = [
    {
      'saveTime': '',
      'totalLending': 0,
      'totalCredit': 0,
      'partnerName': '',
      'current_user_uuid': '',
    }
  ];

  List<bool> _expanded = [false];

  Map<String, num> _calculationRow = {
    'totalPrice': 0,
    'totalPayment': 0,
    'balance': 0
  };

  final StreamController<List<Map<String, String>>>
      _streamControllerCariPartner =
      StreamController<List<Map<String, String>>>.broadcast();

  Stream<List<Map<String, String>>> get getStreamCariPartner =>
      _streamControllerCariPartner.stream;

  ///KASA verilerini getiriyor.
  getCashBox() async {
    _cashBox = {'cash': '0', 'bank': '0', 'total': '0'};
    _streamControllerCashBox.sink.add(_cashBox);
    final temp = await db.fetchCashBox();

    ///tablo boş ve sorguda hata çıkarsa

    if (!temp.containsKey('Hata')) {
      num total = temp['cash'] + temp['bank'];

      _cashBox.addAll({
        'cash': FormatterConvert().currencyShow(temp['cash']),
        'bank': FormatterConvert().currencyShow(temp['bank']),
        'total': FormatterConvert().currencyShow(total)
      });
    }
    _streamControllerCashBox.sink.add(_cashBox);
  }

  /// Kasa verileri kaydediyor. Sadece satır oluyor.
  Future<String> saveCashBox(String? cashValue, String bankValue) async {
    num tempCash = FormatterConvert().commaToPointDouble(cashValue) *
        (getterSelectCashBalance == '-' ? -1 : 1);
    num tempBank = FormatterConvert().commaToPointDouble(bankValue) *
        (getterSelectBankBalance == '-' ? -1 : 1);
    String res = await db.upsertCashBox(tempCash, tempBank);
    getCashBox();
    return res;
  }

  ///Tün ortakları getirir.
  getAllPartner() async {
    final temp = await db.fetchAllPartner();
    for (var element in temp) {
      _allPartner.add({
        'uuid': element['user_uuid'],
        'name':
            "${element['name'].toString().toUpperCaseTr()} ${element['last_name'].toString().toUpperCaseTr()}"
      });
    }

    _streamControllerAllPartner.sink.add(_allPartner);
  }

  getSelectedPartnerName() async {}

  ///Seçilen Ortağın verileri getiriliyor.
  Future getSelectCariParter() async {
    _expanded.clear();
    _cariPartner.clear();
    _calculationRow = {'totalPrice': 0, 'totalPayment': 0, 'balance': 0};

    ///veritabanı arasında veri geliyor. bu gelen veri datatable header uyumlu değil
    ///bu yüzden aşağıdaki for döngüsü ile header uyumlu haline geliyor.
    final resCariPartner = await db.fetchSelectCariPartner(_selectedPartnerId!);

    //Sales tablosundan gelen veriler
    for (var element in resCariPartner) {
      String dateTime = DateFormat("dd/MM/yyyy HH:mm")
          .format(DateTime.parse(element['save_time']));

      num totalLending = element['lending_cash'] + element['lending_bank'];
      print(totalLending);

      num totalCredit = element['credit_cash'] + element['credit_bank'];

      _cariPartner.add({
        'saveTime': dateTime,
        'partnerName': '',
        'totalLending': totalLending,
        'totalCredit': totalCredit,
      });

      ///Buradaki sırası önemli çünkü aşağıda yapıldığında sayı olan veriler
      ///string döndürülüyor. TR para birimine göre ". ile ," ters oluyor.
      ///buda double döndürülemiyor özel olarak yazdığım Fonk. kullanılmalı.
      /*  _calculationRow['totalPrice'] =
          _calculationRow['totalPrice']! + totalPrice;
      _calculationRow['totalPayment'] =
          _calculationRow['totalPayment']! + totalPayment; */
    }

    ///kalan Tutar Burada Hesaplanıyor.
    _calculationRow['balance'] =
        _calculationRow['totalPrice']! - _calculationRow['totalPayment']!;

    ///List Map içinde Sort işlemi yapılıyor Tarih Saate göre (m1 ile m2 yeri değiştiğinde
    ///descending olarak)
    _cariPartner.sort((m1, m2) => DateFormat('dd/MM/yyyy HH:mm')
        .parse(m2['dateTime'])
        .compareTo(DateFormat('dd/MM/yyyy HH:mm').parse(m1['dateTime'])));

    _expanded = List.generate(_cariPartner.length, (index) => false);
    //_streamControllerCariPartner.sink.add(_cariPartner);
  }

  ///Cari getir tabloya

}
