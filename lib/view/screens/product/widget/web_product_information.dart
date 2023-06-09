
import 'package:flutter/material.dart';
import 'package:djr_shopping/data/model/response/product_model.dart';
import 'package:djr_shopping/helper/price_converter.dart';
import 'package:djr_shopping/localization/language_constrants.dart';
import 'package:djr_shopping/provider/cart_provider.dart';
import 'package:djr_shopping/provider/product_provider.dart';
import 'package:djr_shopping/utill/color_resources.dart';
import 'package:djr_shopping/utill/dimensions.dart';
import 'package:djr_shopping/utill/styles.dart';
import 'package:djr_shopping/view/base/custom_snackbar.dart';
import 'package:djr_shopping/view/base/rating_bar.dart';
import 'package:djr_shopping/view/base/wish_button.dart';
import 'package:djr_shopping/view/screens/product/widget/variation_view.dart';
import 'package:provider/provider.dart';

import 'product_title_view.dart';

class WebProductInformation extends StatelessWidget {
  final Product product;
  final int stock;
  final int cartIndex;
  final  double priceWithQuantity;
  WebProductInformation({@required this.product, @required this.stock, @required this.cartIndex, @required this.priceWithQuantity});

  @override
  Widget build(BuildContext context) {

    double _startingPrice;
    double _startingPriceWithDiscount;
    double _startingPriceWithCategoryDiscount;
    double _endingPrice;
    double _endingPriceWithDiscount;
    double _endingPriceWithCategoryDiscount;
    if(product.variations.length != 0) {
      List<double> _priceList = [];
      product.variations.forEach((variation) => _priceList.add(variation.price));
      _priceList.sort((a, b) => a.compareTo(b));
      _startingPrice = _priceList[0];
      if(_priceList[0] < _priceList[_priceList.length-1]) {
        _endingPrice = _priceList[_priceList.length-1];
      }
    }else {
      _startingPrice = product.price;
    }


    if(product.categoryDiscount != null) {
      _startingPriceWithCategoryDiscount = PriceConverter.convertWithDiscount(
        _startingPrice, product.categoryDiscount.discountAmount, product.categoryDiscount.discountType,
        maxDiscount: product.categoryDiscount.maximumAmount,
      );

      if(_endingPrice != null){
        _endingPriceWithCategoryDiscount = PriceConverter.convertWithDiscount(
          _endingPrice, product.categoryDiscount.discountAmount, product.categoryDiscount.discountType,
          maxDiscount: product.categoryDiscount.maximumAmount,
        );
      }
    }
    _startingPriceWithDiscount = PriceConverter.convertWithDiscount(_startingPrice, product.discount, product.discountType);

    if(_endingPrice != null) {
      _endingPriceWithDiscount = PriceConverter.convertWithDiscount(_endingPrice, product.discount, product.discountType);
    }

    if(_startingPriceWithCategoryDiscount != null
        && _startingPriceWithCategoryDiscount > 0 &&
        _startingPriceWithCategoryDiscount < _startingPriceWithDiscount) {
      _startingPriceWithDiscount = _startingPriceWithCategoryDiscount;
      _endingPriceWithDiscount = _endingPriceWithCategoryDiscount;
    }




    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.start,
        children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              product.name ?? '',
              style: poppinsBold.copyWith(fontSize: Dimensions.FONT_SIZE_MAX_LARGE, color: ColorResources.getProductDescriptionColor(context)),
              maxLines: 2,
            ),
          ),

          WishButton(product: product),
        ],
      ),
     SizedBox(height: 5),

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        product.rating != null ? RatingBar(
          rating: product.rating.length > 0 ? double.parse(product.rating[0].average) : 0.0,
          size: Dimensions.PADDING_SIZE_DEFAULT,
        ) : SizedBox(),

        Container(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_SIZE_LARGE),
            color: product.totalStock > 0
                ?  Theme.of(context).primaryColor
                : Theme.of(context).primaryColor.withOpacity(0.3),
          ),
          child: Text(
            '${ getTranslated(product.totalStock > 0
                ? 'in_stock' : 'stock_out', context)}',
            style: poppinsMedium.copyWith(color: Colors.white),
          ),
        ),
      ]),

      const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
      Text(
        '${product.capacity} ${product.unit}',
        style: poppinsRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.FONT_SIZE_LARGE),
      ),
      const SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

      //Product Price
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${PriceConverter.convertPrice(context, _startingPriceWithDiscount)}'
                '${_endingPriceWithDiscount!= null ? ' - ${PriceConverter.convertPrice(context, _endingPriceWithDiscount)}' : ''}',
            style: poppinsBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.FONT_SIZE_OVER_LARGE),
          ),
          const SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
          if(_startingPriceWithDiscount < _startingPrice )
            Text('${PriceConverter.convertPrice(context, _startingPrice)}'
                '${_endingPrice!= null ? ' - ${PriceConverter.convertPrice(context, _endingPrice)}' : ''}',
            style: poppinsRegular.copyWith(
              fontSize: Dimensions.FONT_SIZE_DEFAULT,
              color: ColorResources.RED_COLOR,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ),


      VariationView(product: product),


      const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

      const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE ),

      Builder(
        builder: (context) {
          return Row(children: [
            QuantityButton(isIncrement: false, quantity: Provider.of<ProductProvider>(context, listen: false).quantity, stock: stock, cartIndex: cartIndex, maxOrderQuantity: product.maximumOrderQuantity),
            SizedBox(width: 30),

            Consumer<ProductProvider>(builder: (context, product, child) {
              return Consumer<CartProvider>(builder: (context, cart, child) {
                return Text(cartIndex != null ? cart.cartList[cartIndex].quantity.toString() : product.quantity.toString(), style: poppinsSemiBold);
              });
            }),
            SizedBox(width: 30),

            QuantityButton(isIncrement: true, quantity: Provider.of<ProductProvider>(context, listen: false).quantity, stock: stock, cartIndex: cartIndex, maxOrderQuantity: product.maximumOrderQuantity),
          ]);
        }
      ),

      const SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
          Row(children: [
            Text('${getTranslated('total_amount', context)}:', style: poppinsMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
            SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            Text(PriceConverter.convertPrice(context, priceWithQuantity), style: poppinsBold.copyWith(
              color: Theme.of(context).primaryColor, fontSize: Dimensions.FONT_SIZE_LARGE,
            )),
          ]),
          SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE),


    ]);
  }
}


