import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2d_amap/flutter_2d_amap.dart';
import 'package:flutter_deer/res/resources.dart';
import 'package:flutter_deer/routers/fluro_navigator.dart';
import 'package:flutter_deer/shop/shop_router.dart';
import 'package:flutter_deer/store/store_router.dart';
import 'package:flutter_deer/util/other_utils.dart';
import 'package:flutter_deer/util/theme_utils.dart';
import 'package:flutter_deer/widgets/my_app_bar.dart';
import 'package:flutter_deer/widgets/my_button.dart';
import 'package:flutter_deer/widgets/my_scroll_view.dart';
import 'package:flutter_deer/widgets/selected_image.dart';
import 'package:flutter_deer/widgets/selected_item.dart';
import 'package:flutter_deer/widgets/text_field_item.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

/// design/2Shop review/index.html
class StoreAuditPage extends StatefulWidget {
  const StoreAuditPage({super.key});

  @override
  _StoreAuditPageState createState() => _StoreAuditPageState();
}

class _StoreAuditPageState extends State<StoreAuditPage> {
  final GlobalKey<SelectedImageState> _imageGlobalKey =
      GlobalKey<SelectedImageState>();
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText3 = FocusNode();
  final ImagePicker picker = ImagePicker();
  String _address =
      "No. 201, Gaoxin 6th Road, Yanta District, Xi'an City, Shaanxi Province";

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: ThemeUtils.getKeyboardActionsColor(context),
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
          displayDoneButton: false,
        ),
        KeyboardActionsItem(
          focusNode: _nodeText2,
          displayDoneButton: false,
        ),
        KeyboardActionsItem(
          focusNode: _nodeText3,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child:
                      Text(Utils.getCurrLocale() == 'zh' ? 'closure' : 'Close'),
                ),
              );
            },
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        centerTitle: 'Store audit information',
      ),
      body: MyScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        keyboardConfig: _buildConfig(context),
        tapOutsideToDismiss: true,
        bottomButton: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          child: MyButton(
            onPressed: () {
              debugPrint(
                  'file path: ${_imageGlobalKey.currentState?.pickedFile?.path}');
              NavigatorUtils.push(context, StoreRouter.auditResultPage);
            },
            text: 'submit',
          ),
        ),
        children: _buildBody(),
      ),

      /// When there are bottom buttons and keyboardConfig configurations at the same time, to ensure that the pop-up height of the soft keyboard on the Android and iOS platforms is normal, add the following code.
      resizeToAvoidBottomInset: defaultTargetPlatform != TargetPlatform.iOS,
    );
  }

  List<Widget> _buildBody() {
    return [
      Gaps.vGap5,
      const Padding(
        padding: EdgeInsets.only(left: 16.0),
        child: Text('Store information', style: TextStyles.textBold18),
      ),
      Gaps.vGap16,
      Center(
        child: SelectedImage(
          key: _imageGlobalKey,
        ),
      ),
      Gaps.vGap10,
      Center(
        child: Text(
          'Shopkeeper holding ID card or business license',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontSize: Dimens.font_sp14),
        ),
      ),
      Gaps.vGap16,
      TextFieldItem(
          focusNode: _nodeText1,
          title: 'Store Name',
          hintText: 'Fill in the store name'),
      SelectedItem(
          title: 'Main scope',
          content: _sortName,
          onTap: () => _showBottomSheet()),
      SelectedItem(
          title: 'shop address',
          content: _address,
          onTap: () {
            NavigatorUtils.pushResult(context, ShopRouter.addressSelectPage,
                (result) {
              setState(() {
                final PoiSearch model = result as PoiSearch;
                _address =
                    '${model.provinceName.nullSafe} ${model.cityName.nullSafe} ${model.adName.nullSafe} ${model.title.nullSafe}';
              });
            });
          }),
      Gaps.vGap32,
      const Padding(
        padding: EdgeInsets.only(left: 16.0),
        child: Text('owner information', style: TextStyles.textBold18),
      ),
      Gaps.vGap16,
      TextFieldItem(
          focusNode: _nodeText2,
          title: "owner's name",
          hintText: "Fill in the owner's name"),
      TextFieldItem(
          focusNode: _nodeText3,
          keyboardType: TextInputType.phone,
          title: 'contact number',
          hintText: "Fill in the owner's contact number")
    ];
  }

  String _sortName = '';
  final List<String> _list = [
    'fresh fruit',
    'household appliances',
    'Snack foods',
    'tea drink',
    'Beauty Personal Care',
    'Grain and oil seasoning',
    'household cleaning',
    'Kitchenware',
    'kids toys',
    'bed linings'
  ];

  void _showBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        // Slidable ListView closes BottomSheet
        return DraggableScrollableSheet(
          key: const Key('goods_sort'),
          initialChildSize: 0.7,
          minChildSize: 0.65,
          expand: false,
          builder: (_, scrollController) {
            return ListView.builder(
              controller: scrollController,
              itemExtent: 48.0,
              itemBuilder: (_, index) {
                return InkWell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.centerLeft,
                    child: Text(_list[index]),
                  ),
                  onTap: () {
                    setState(() {
                      _sortName = _list[index];
                    });
                    NavigatorUtils.goBack(context);
                  },
                );
              },
              itemCount: _list.length,
            );
          },
        );
      },
    );
  }
}
