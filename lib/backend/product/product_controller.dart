import 'package:club_model/club_model.dart';

import '../../configs/constants.dart';
import 'product_provider.dart';
import 'product_repository.dart';

class ProductController {
  late ProductRepository _productRepository;
  late ProductProvider _productProvider;

  ProductController({
    required ProductProvider? provider,
    ProductRepository? repository,
  }) {
    _productRepository = repository ?? ProductRepository();
    _productProvider = provider ?? ProductProvider();
  }

  ProductRepository get productRepository => _productRepository;
  ProductProvider get productProvider => _productProvider;

  Future<List<ProductModel>> getProductsPaginatedList({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("ProductController().getProductsPaginatedList called with isRefresh:$isRefresh, isFromCache:$isFromCache", tag: tag);

    ProductProvider provider = productProvider;

    if(!isRefresh && isFromCache && provider.productsLength > 0) {
      MyPrint.printOnConsole("Returning Cached Data", tag: tag);
      return provider.products.getList(isNewInstance: true);
    }

    if (isRefresh) {
      MyPrint.printOnConsole("Refresh", tag: tag);
      provider.hasMoreProducts.set(value: true, isNotify: false); // flag for more products available or not
      provider.lastProductDocument.set(value: null, isNotify: false); // flag for last document from where next 10 records to be fetched
      provider.isProductsFirstTimeLoading.set(value: true, isNotify: false);
      provider.isProductsLoading.set(value: false, isNotify: false);
      provider.products.setList(list: <ProductModel>[], isNotify: isNotify);
    }

    try {
      if (!provider.hasMoreProducts.get()) {
        MyPrint.printOnConsole('No More Users', tag: tag);
        return provider.products.getList(isNewInstance: true);
      }
      if (provider.isProductsLoading.get()) return provider.products.getList(isNewInstance: true);

      provider.isProductsLoading.set(value: true, isNotify: isNotify);

      Query<Map<String, dynamic>> query = FirebaseNodes.productsCollectionReference
          .limit(MyAppConstants.productsDocumentLimitForPagination)
          .orderBy("createdTime", descending: false);

      //For Last Document
      MyFirestoreDocumentSnapshot? snapshot = provider.lastProductDocument.get();
      if(snapshot != null) {
        MyPrint.printOnConsole("LastDocument not null", tag: tag);
        query = query.startAfterDocument(snapshot);
      }
      else {
        MyPrint.printOnConsole("LastDocument null", tag: tag);
      }

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
      MyPrint.printOnConsole("Documents Length in Firestore for Products:${querySnapshot.docs.length}", tag: tag);

      if (querySnapshot.docs.length < MyAppConstants.productsDocumentLimitForPagination) provider.hasMoreProducts.set(value: false, isNotify: false);

      if(querySnapshot.docs.isNotEmpty) provider.lastProductDocument.set(value: querySnapshot.docs[querySnapshot.docs.length - 1], isNotify: false);

      List<ProductModel> list = [];
      for (DocumentSnapshot<Map<String, dynamic>> documentSnapshot in querySnapshot.docs) {
        if((documentSnapshot.data() ?? {}).isNotEmpty) {
          ProductModel productModel = ProductModel.fromMap(documentSnapshot.data()!);
          list.add(productModel);
        }
      }
      provider.products.setList(list: list, isClear: false, isNotify: false);
      provider.isProductsFirstTimeLoading.set(value: false, isNotify: true);
      provider.isProductsLoading.set(value: false, isNotify: true);
      MyPrint.printOnConsole("Final Products Length From Firestore:${list.length}", tag: tag);
      MyPrint.printOnConsole("Final Products Length in Provider:${provider.productsLength}", tag: tag);
      return list;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in ProductController().getProductsPaginatedList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      provider.products.setList(list: [], isClear: true, isNotify: false);
      provider.hasMoreProducts.set(value: true, isNotify: false);
      provider.lastProductDocument.set(value: null, isNotify: false);
      provider.isProductsFirstTimeLoading.set(value: false, isNotify: false);
      provider.isProductsLoading.set(value: false, isNotify: true);
      return [];
    }
  }
}
