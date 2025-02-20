import 'package:adaptivex/adaptivex.dart';
import 'package:flutter/material.dart';
import 'datatable_header.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

enum ExportAction { print, pdf, excel, csv }

class ResponsiveDatatable extends StatefulWidget {
  final bool showSelect;
  final List<DatatableHeader> headers;
  final List<Map<String, dynamic>>? source;
  final List<Map<String, dynamic>>? selecteds;
  final Widget? title;
  final List<Widget>? actions;
  final List<Widget>? footers;
  final Decoration? footerDecoration;
  final double? footerHeight;
  final List<ExportAction>? exports;
  final Function(bool? value)? onSelectAll;
  final Function(bool? value, Map<String, dynamic> data)? onSelect;
  final Function(Map<String, dynamic> value)? onTabRow;
  final Function(dynamic value)? onSort;
  final String? sortColumn;
  final bool? sortAscending;
  final bool isLoading;
  final bool autoHeight;
  final bool hideUnderline;
  final bool commonMobileView;
  final bool isExpandRows;
  final List<bool>? expanded;
  final Widget Function(Map<String, dynamic> value)? dropContainer;
  final Function(Map<String, dynamic> value, DatatableHeader header)?
      onChangedRow;
  final Function(Map<String, dynamic> value, DatatableHeader header)?
      onSubmittedRow;
  final List<ScreenSize> reponseScreenSizes;

  /// `headerDecoration`
  ///
  /// allow to decorate the header row
  final BoxDecoration? headerDecoration;

  /// `rowDecoration`
  ///
  /// allow to decorate the data row
  final BoxDecoration? rowDecoration;

  /// `selectedDecoration`
  ///
  /// allow to decorate the selected data row
  final BoxDecoration? selectedDecoration;

  /// `selectedTextStyle`
  ///
  /// allow to styling the header row
  final TextStyle? headerTextStyle;

  /// `selectedTextStyle`
  ///
  /// allow to styling the data row
  final TextStyle? rowTextStyle;

  /// `selectedTextStyle`
  ///
  /// allow to styling the selected data row
  final TextStyle? selectedTextStyle;

  int rowLenght = 0;

  double rowHeight;
  bool skipFocusNode;

  ResponsiveDatatable(
      {Key? key,
      this.showSelect = false,
      this.onSelectAll,
      this.onSelect,
      this.onTabRow,
      this.onSort,
      this.headers = const [],
      this.source,
      this.exports,
      this.selecteds,
      this.title,
      this.actions,
      this.footers,
      this.sortColumn,
      this.sortAscending,
      this.isLoading = false,
      this.autoHeight = true,
      this.hideUnderline = true,
      this.commonMobileView = false,
      this.isExpandRows = true,
      this.expanded,
      this.dropContainer,
      this.onChangedRow,
      this.onSubmittedRow,
      this.reponseScreenSizes = const [
        ScreenSize.xs,
        ScreenSize.sm,
        ScreenSize.md
      ],
      this.headerDecoration,
      this.rowDecoration,
      this.selectedDecoration,
      this.headerTextStyle,
      this.rowTextStyle,
      this.selectedTextStyle,
      this.rowHeight = 40,
      this.footerDecoration,
      this.footerHeight,
      this.skipFocusNode = false})
      : super(key: key);

  @override
  _ResponsiveDatatableState createState() => _ResponsiveDatatableState();
}

class _ResponsiveDatatableState extends State<ResponsiveDatatable> {
  Widget mobileHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Checkbox(
          value: widget.selecteds!.length == widget.source!.length &&
              widget.source != null &&
              widget.source!.isNotEmpty,
          onChanged: (value) {
            if (widget.onSelectAll != null) widget.onSelectAll!(value);
          },
        ),
        PopupMenuButton(
            tooltip: "SORT BY",
            initialValue: widget.sortColumn,
            itemBuilder: (_) => widget.headers
                .where(
                    (header) => header.show == true && header.sortable == true)
                .toList()
                .map((header) => PopupMenuItem(
                      value: header.value,
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            header.text,
                            textAlign: header.textAlign,
                          ),
                          if (widget.sortColumn != null &&
                              widget.sortColumn == header.value)
                            widget.sortAscending!
                                ? const Icon(Icons.arrow_downward, size: 15)
                                : const Icon(Icons.arrow_upward, size: 15)
                        ],
                      ),
                    ))
                .toList(),
            onSelected: (dynamic value) {
              if (widget.onSort != null) widget.onSort!(value);
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              child: const Text("SORT BY"),
            ))
      ],
    );
  }

  List<Widget> mobileList() {
    final decoration = BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)));
    final rowDecoration = widget.rowDecoration ?? decoration;
    final selectedDecoration = widget.selectedDecoration ?? decoration;
    return widget.source!.map((data) {
      return InkWell(
        onTap: () => widget.onTabRow?.call(data),
        child: Container(
          /// TODO:
          decoration: widget.selecteds!.contains(data)
              ? selectedDecoration
              : rowDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(),
                  if (widget.showSelect && widget.selecteds != null)
                    Checkbox(
                        value: widget.selecteds!.contains(data),
                        onChanged: (value) {
                          if (widget.onSelect != null) {
                            widget.onSelect!(value, data);
                          }
                        }),
                ],
              ),
              if (widget.commonMobileView && widget.dropContainer != null)
                widget.dropContainer!(data),
              if (!widget.commonMobileView)
                ...widget.headers
                    .where((header) => header.show == true)
                    .toList()
                    .map(
                  (header) {
                    ///2 satırda 1 renk ataması yapılıyor.
                    widget.rowLenght += 1;

                    return Container(
                      color: (widget.rowLenght % 2 == 0)
                          ? Colors.grey.shade100
                          : null,
                      padding: const EdgeInsets.all(11),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          header.headerBuilder != null
                              ? header.headerBuilder!(header.value)
                              : Text(
                                  header.text,
                                  overflow: TextOverflow.clip,
                                  style: widget.selecteds!.contains(data)
                                      ? widget.selectedTextStyle
                                      : widget.rowTextStyle,
                                ),
                          const Spacer(),
                          header.sourceBuilder != null
                              ? header.sourceBuilder!(data[header.value], data)
                              : header.editable
                                  ? TextEditableWidget(
                                      data: data,
                                      header: header,
                                      textAlign: TextAlign.end,
                                      onChanged: widget.onChangedRow,
                                      onSubmitted: widget.onSubmittedRow,
                                      hideUnderline: widget.hideUnderline,
                                    )
                                  : Text(
                                      "${data[header.value]}",
                                      style: widget.selecteds!.contains(data)
                                          ? widget.selectedTextStyle
                                          : widget.rowTextStyle,
                                    )
                        ],
                      ),
                    );
                  },
                ).toList()
            ],
          ),
        ),
      );
    }).toList();
  }

  static Alignment headerAlignSwitch(TextAlign? textAlign) {
    switch (textAlign) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.left:
        return Alignment.centerLeft;
      case TextAlign.right:
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }

  Widget desktopHeader() {
    final headerDecoration = widget.headerDecoration ??
        BoxDecoration(
            border:
                Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)));
    return Container(
      decoration: headerDecoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showSelect && widget.selecteds != null)
            Checkbox(
                value: widget.selecteds!.length == widget.source!.length &&
                    widget.source != null &&
                    widget.source!.isNotEmpty,
                onChanged: (value) {
                  if (widget.onSelectAll != null) widget.onSelectAll!(value);
                }),
          ...widget.headers
              .where((header) => header.show == true)
              .map(
                (header) => Expanded(
                    flex: header.flex,
                    child: InkWell(
                      focusNode: FocusNode(skipTraversal: true),
                      onTap: () {
                        if (widget.onSort != null && header.sortable) {
                          widget.onSort!(header.value);
                        }
                      },
                      child: header.headerBuilder != null
                          ? header.headerBuilder!(header.value)
                          : Container(
                              ///Header background renk
                              //   color: Colors.blue,
                              padding: const EdgeInsets.all(11),
                              alignment: headerAlignSwitch(header.textAlign),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    header.text,
                                    textAlign: header.textAlign,
                                    style: widget.headerTextStyle,
                                  ),
                                  if (widget.sortColumn != null &&
                                      widget.sortColumn == header.value)
                                    widget.sortAscending!
                                        ? const Icon(Icons.arrow_downward,
                                            size: 15)
                                        : const Icon(Icons.arrow_upward,
                                            size: 15)
                                ],
                              ),
                            ),
                    )),
              )
              .toList()
        ],
      ),
    );
  }

  List<Widget> desktopList() {
    final decoration = BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)));
    final rowDecoration = widget.rowDecoration ?? decoration;
    final selectedDecoration = widget.selectedDecoration ?? decoration;
    List<Widget> widgets = [];

    for (var index = 0; index < widget.source!.length; index++) {
      //kaynaktaki liste içinde Map veriyor tek tek döngüde
      final data = widget.source![index];
      widgets.add(Column(
        children: [
          InkWell(
            focusNode: FocusNode(skipTraversal: widget.skipFocusNode),
            onTap: () {
              widget.onTabRow?.call(data);
              setState(() {
                widget.expanded![index] = !widget.expanded![index];
              });
            },
            child: Container(
              height: widget.rowHeight,
              // padding: EdgeInsets.symmetric(vertical: 11),
              padding:
                  EdgeInsets.symmetric(vertical: widget.showSelect ? 0 : 11),
              decoration: widget.selecteds!.contains(data)
                  ? selectedDecoration
                  : rowDecoration,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showSelect && widget.selecteds != null)
                    Row(
                      children: [
                        Checkbox(
                            value: widget.selecteds!.contains(data),
                            onChanged: (value) {
                              if (widget.onSelect != null) {
                                widget.onSelect!(value, data);
                              }
                            }),
                      ],
                    ),
                  ...widget.headers
                      .where((header) => header.show == true)
                      .map(
                        (header) => Expanded(
                          flex: header.flex,
                          child: header.sourceBuilder != null
                              ? header.sourceBuilder!(data[header.value], data)

                              ///data[header.value] o satırdaki kolon bulunanismini veriyor
                              : header.editable
                                  ? TextEditableWidget(
                                      data: data,
                                      header: header,
                                      textAlign: header.textAlign,
                                      onChanged: widget.onChangedRow,
                                      onSubmitted: widget.onSubmittedRow,
                                      hideUnderline: widget.hideUnderline,
                                    )

                                  //Satırda Eğer Editable Seçili değil ise Burası çalışıyor
                                  : Text(
                                      "${data[header.value]}",
                                      textAlign: header.textAlign,
                                      style: widget.selecteds!.contains(data)
                                          ? widget.selectedTextStyle
                                          : widget.rowTextStyle,
                                    ),
                        ),
                      )
                      .toList()
                ],
              ),
            ),
          ),
          if (widget.isExpandRows &&
              widget.expanded![index] &&
              widget.dropContainer != null)
            widget.dropContainer!(data)
        ],
      ));
    }
    return widgets;
  }

  ///PDF ekleme
  printPDF() {
    Printing.layoutPdf(onLayout: ((format) {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          maxPages: 100,
          build: (pw.Context context) => [
            pw.Center(
                heightFactor: 2.0,
                child: pw.Text('Responsive Table Data',
                    style: const pw.TextStyle(fontSize: 16))),
            pw.Table(
              defaultColumnWidth: const pw.FixedColumnWidth(120.0),
              border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#8E8E8E'), width: 0.5),
              children: [
                pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey,
                    ),
                    children: [
                      for (var column in widget.headers)
                        pw.Container(
                            margin: const pw.EdgeInsets.all(2.0),
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text(column.text,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)))
                    ]),
                for (int index = 0; index < widget.source!.length; index++)
                  pw.TableRow(
                    verticalAlignment: pw.TableCellVerticalAlignment.middle,
                    decoration: pw.BoxDecoration(
                        color: index % 2 == 1
                            ? PdfColors.grey200
                            : PdfColors.white),
                    children: [
                      for (var column in widget.headers)
                        pw.Container(
                            margin: const pw.EdgeInsets.all(2.0),
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text(widget.source![index][column.value]
                                .toString())),
                    ],
                  )
              ],
            ),
          ],
        ),
      );
      return pdf.save();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return widget.reponseScreenSizes.isNotEmpty &&
            widget.reponseScreenSizes.contains(context.screenSize)
        ?
        /**-------------------TELEFON-------------------- */
        ///Print ekrana çıkabilmesi için Action veya Title birinin dolu olması gerek.
        /// for small screen
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              /// title and actions (Tablo üstünde bulunan yer)
              if (widget.title != null || widget.actions != null)
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Colors.grey[300]!))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //if (widget.title != null) widget.title!,
                      Row(
                        children: [
                          if (widget.title != null) widget.title!,
                          if (widget.exports != null &&
                              widget.exports!.contains(ExportAction.print))
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                    onPressed: () => printPDF(),
                                    color: Theme.of(context).primaryColor,
                                    icon: const Icon(Icons.print)),
                              ),
                            ),
                        ],
                      ),

                      if (widget.actions != null) ...widget.actions!,
                    ],
                  ),
                ),

              if (widget.autoHeight)
                Column(
                  children: [
                    if (widget.showSelect && widget.selecteds != null)
                      mobileHeader(),
                    if (widget.isLoading) const LinearProgressIndicator(),
                    ...mobileList(),
                  ],
                ),
              if (!widget.autoHeight)
                Expanded(
                  child: ListView(
                    /// itemCount: source.length,
                    children: [
                      if (widget.showSelect && widget.selecteds != null)
                        mobileHeader(),
                      if (widget.isLoading) const LinearProgressIndicator(),
                      if (widget.source != null && widget.source!.isNotEmpty)
                        ...mobileList(),
                      if (widget.source == null || widget.source!.isEmpty)
                        const Center(
                          child: Text(""),
                        )
                    ],
                  ),
                ),

              /// footer
              if (widget.footers != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(5),
                  decoration: widget.footerDecoration,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [...widget.footers!],
                  ),
                )
            ],
          )
        /**
          * for large screen
          */
        : Column(
            children: [
              //title and actions
              if (widget.title != null || widget.actions != null)
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Colors.grey[300]!))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // if (widget.title != null) widget.title!,
                      Row(
                        children: [
                          if (widget.title != null) widget.title!,
                          if (widget.exports != null &&
                              widget.exports!.contains(ExportAction.print))
                            IconButton(
                                onPressed: () => printPDF(),
                                color: Theme.of(context).primaryColor,
                                icon: const Icon(Icons.print)),
                        ],
                      ),
                      if (widget.actions != null) ...widget.actions!
                    ],
                  ),
                ),

              /// desktopHeader
              if (widget.headers.isNotEmpty) desktopHeader(),

              if (widget.isLoading) const LinearProgressIndicator(),

              if (widget.autoHeight) Column(children: desktopList()),

              if (!widget.autoHeight)
                // desktopList

                if (widget.source != null && widget.source!.isNotEmpty)
                  Expanded(child: ListView(children: desktopList())),
              if (widget.source == null || widget.source!.isEmpty)
                const Expanded(
                    child: Center(
                  child: Text(""),
                )),

              //footer
              if (widget.footers != null)
                Container(
                  width: double.infinity,
                  height: widget.footerHeight,
                  padding: const EdgeInsets.all(5),
                  decoration: widget.footerDecoration,
                  alignment: Alignment.centerRight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [...widget.footers!],
                    ),
                  ),
                )
            ],
          );
  }
}

/// `TextEditableWidget`
///
/// use to display when user allow any header columns to be editable
class TextEditableWidget extends StatelessWidget {
  /// `data`
  ///
  /// current data as Map
  final Map<String, dynamic> data;

  /// `header`
  ///
  /// current editable text header
  final DatatableHeader header;

  /// `textAlign`
  ///
  /// by default textAlign will be center
  final TextAlign textAlign;

  /// `hideUnderline`
  ///
  /// allow use to decorate hideUnderline false or true
  final bool hideUnderline;

  /// `onChanged`
  ///
  /// trigger the call back update when user make any text change
  final Function(Map<String, dynamic> vaue, DatatableHeader header)? onChanged;

  /// `onSubmitted`
  ///
  /// trigger the call back when user press done or enter
  final Function(Map<String, dynamic> vaue, DatatableHeader header)?
      onSubmitted;

  const TextEditableWidget({
    Key? key,
    required this.data,
    required this.header,
    this.textAlign = TextAlign.center,
    this.hideUnderline = false,
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.all(0),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          border: hideUnderline
              ? InputBorder.none
              : const UnderlineInputBorder(borderSide: BorderSide(width: 1)),
          alignLabelWithHint: true,
        ),
        textAlign: textAlign,
        controller: TextEditingController.fromValue(
          TextEditingValue(text: "${data[header.value]}"),
        ),
        onChanged: (newValue) {
          data[header.value] = newValue;
          onChanged?.call(data, header);
        },
        onSubmitted: (x) => onSubmitted?.call(data, header),
      ),
    );
  }
}
