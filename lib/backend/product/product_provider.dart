import 'package:club_model/backend/common/common_provider.dart';
import 'package:club_model/configs/typedefs.dart';
import 'package:club_model/models/product/data_model/product_model.dart';

class ProductProvider extends CommonProvider {
  ProductProvider() {
    products = CommonProviderListParameter<ProductModel>(
      list: [],
      notify: notify,
    );
    lastProductDocument = CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?>(
      value: null,
      notify: notify,
    );
    hasMoreProducts = CommonProviderPrimitiveParameter<bool>(
      value: true,
      notify: notify,
    );
    isProductsFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    isProductsLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
  }

  //region Products Paginated List
  late CommonProviderListParameter<ProductModel> products;
  int get productsLength => products.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?> lastProductDocument;
  late CommonProviderPrimitiveParameter<bool> hasMoreProducts;
  late CommonProviderPrimitiveParameter<bool> isProductsFirstTimeLoading;
  late CommonProviderPrimitiveParameter<bool> isProductsLoading;
  //endregion

  void reset({bool isNotify = true}) {
    products.setList(list: [], isNotify: false);
    lastProductDocument.set(value: null, isNotify: false);
    hasMoreProducts.set(value: true, isNotify: false);
    isProductsFirstTimeLoading.set(value: false, isNotify: false);
    isProductsLoading.set(value: false, isNotify: isNotify);
  }
}