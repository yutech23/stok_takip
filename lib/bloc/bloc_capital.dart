import 'dart:async';
import 'package:intl/intl.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/cari_partner.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';
import '../utilities/share_func.dart';
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

  final List<Map<String, dynamic>> _allPartner = [];

  List<Map<String, dynamic>> get getterAllParter => _allPartner;

  final StreamController<List<Map<String, dynamic>>>
      _streamControllerAllPartner =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get getStreamAllPartner =>
      _streamControllerAllPartner.stream;

  String? _selectedPartnerId;

  String? get getterSelectedPartnerId => _selectedPartnerId;
  set setterSelectedPartnerId(String? value) => _selectedPartnerId = value;

  String? _selectedLeadingAndCredit = "+";
  String? _selectedPartnerIdPopup;

  String? get getterSelectedPartnerIdPopup => _selectedPartnerIdPopup;
  set setterSelectedPartnerIdPopup(String? value) =>
      _selectedPartnerIdPopup = value;

  set setterSelectedLeadingAndBorrow(String? value) =>
      _selectedLeadingAndCredit = value;

  final List<Map<String, String>> _cariPartner = [];

  List<bool> _expanded = [false];

  List<bool> get getterExpanded => _expanded;

  Map<String, num> _calculationRow = {
    'totalLend': 0,
    'totalBorrow': 0,
    'balance': 0
  };

  get getterCalculationRow => _calculationRow;

  final StreamController<List<Map<String, dynamic>>>
      _streamControllerCariPartner =
      StreamController<List<Map<String, String>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get getStreamCariPartner =>
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
        'uuid': element['id'],
        'name':
            "${element['name'].toString().toUpperCaseTr()} ${element['last_name'].toString().toUpperCaseTr()}"
      });
    }

    _streamControllerAllPartner.sink.add(_allPartner);
    return _allPartner;
  }

  ///Seçilen Ortağın verileri getiriliyor.
  Future getSelectCariParter() async {
    _expanded.clear();
    _cariPartner.clear();
    _calculationRow = {'totalLend': 0, 'totalBorrow': 0, 'balance': 0};

    ///veritabanı arasında veri geliyor. bu gelen veri datatable header uyumlu değil
    ///bu yüzden aşağıdaki for döngüsü ile header uyumlu haline geliyor.
    final resCariPartner = await db.fetchSelectCariPartner(_selectedPartnerId!);

    //Sales tablosundan gelen veriler
    for (var element in resCariPartner) {
      String dateTime = DateFormat("dd/MM/yyyy HH:mm")
          .format(DateTime.parse(element['save_time']));

      num totalLend = element['lend_cash'] + element['lend_bank'];
      num totalBorrow = element['borrow_cash'] + element['borrow_bank'];

      _cariPartner.add({
        'id': element['id'].toString(),
        'saveTime': dateTime,
        'partnerName': element['name'],
        'totalLend':
            totalLend != 0 ? FormatterConvert().currencyShow(totalLend) : '-',
        'totalBorrow': totalBorrow != 0
            ? FormatterConvert().currencyShow(totalBorrow)
            : '-',
      });

      ///Buradaki sırası önemli çünkü aşağıda yapıldığında sayı olan veriler
      ///string döndürülüyor. TR para birimine göre ". ile ," ters oluyor.
      ///buda double döndürülemiyor özel olarak yazdığım Fonk. kullanılmalı.
      _calculationRow['totalLend'] = _calculationRow['totalLend']! + totalLend;
      _calculationRow['totalBorrow'] =
          _calculationRow['totalBorrow']! + totalBorrow;
    }

    ///kalan Tutar Burada Hesaplanıyor.
    _calculationRow['balance'] =
        _calculationRow['totalLend']! - _calculationRow['totalBorrow']!;

    ///List Map içinde Sort işlemi yapılıyor Tarih Saate göre (m1 ile m2 yeri değiştiğinde
    ///descending olarak)
    _cariPartner.sort((m1, m2) => DateFormat('dd/MM/yyyy HH:mm')
        .parse(m2['saveTime']!)
        .compareTo(DateFormat('dd/MM/yyyy HH:mm').parse(m1['saveTime']!)));

    _expanded = List.generate(_cariPartner.length, (index) => false);
    _streamControllerCariPartner.sink.add(_cariPartner);
  }

  ///Cari getir tabloya
  Future<String> saveLeadingAndCreditPartner(
      String uuid, String? cashValue, String bankValue) async {
    CariPartner cariPartner = CariPartner();
    cariPartner.parterId = uuid;
    cariPartner.currentUserId = shareFunc.getCurrentUserId();
    if (_selectedLeadingAndCredit == '+') {
      cariPartner.lendCash = FormatterConvert().commaToPointDouble(cashValue);
      cariPartner.lendBank = FormatterConvert().commaToPointDouble(bankValue);
    } else {
      cariPartner.borrowCash = FormatterConvert().commaToPointDouble(cashValue);
      cariPartner.borrowBank = FormatterConvert().commaToPointDouble(bankValue);
    }
    /*  print(cariPartner.parterId);
    print(cariPartner.currentUserId);
    print(cariPartner.lendCash);
    print(cariPartner.lendBank);
    print(cariPartner.creditCash);
    print(cariPartner.creditBank); */
    String res = await db.saveLeadingAndBorrow(cariPartner);
    return res;
  }

  ///Seçilen Satırı siliyor
  Future<String> deleteSelectedRow(String cariCapitalId) async {
    for (var i = 0; i < _cariPartner.length; i++) {
      if (_cariPartner[i]['id'] == cariCapitalId) {
        _cariPartner.removeAt(i);
        break;
      }
    }
    return await db.deleteCariCapitalRow(cariCapitalId);
  }
}
