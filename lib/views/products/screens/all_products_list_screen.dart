import 'package:club_model/club_model.dart';
import 'package:club_user/backend/product/product_controller.dart';
import 'package:club_user/backend/product/product_provider.dart';
import 'package:club_user/configs/constants.dart';
import 'package:flutter/material.dart';

class AllProductsListScreen extends StatefulWidget {
  const AllProductsListScreen({Key? key}) : super(key: key);

  @override
  State<AllProductsListScreen> createState() => _AllProductsListScreenState();
}

class _AllProductsListScreenState extends State<AllProductsListScreen> with MySafeState {
  late ProductProvider productProvider;
  late ProductController productController;

  Future<void> getData({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    await productController.getProductsPaginatedList(
      isRefresh: isRefresh,
      isFromCache: isFromCache,
      isNotify: isNotify,
    );
  }

  @override
  void initState() {
    super.initState();

    productProvider = context.read<ProductProvider>();
    productController = ProductController(provider: productProvider);

    if (productProvider.productsLength == 0 && productProvider.hasMoreProducts.get()) {
      getData(
        isRefresh: true,
        isFromCache: false,
        isNotify: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return Consumer<ProductProvider>(
      builder: (BuildContext context, ProductProvider productProvider, Widget? child) {
        return Scaffold(
          body: getProductsListWidget(productProvider: productProvider),
        );
      },
    );
  }

  Widget getProductsListWidget({required ProductProvider productProvider}) {
    if (productProvider.isProductsFirstTimeLoading.get()) {
      return const LoadingWidget(
        boxSize: 60,
        loaderSize: 40,
      );
    }

    if (!productProvider.isProductsLoading.get() && productProvider.productsLength == 0) {
      return RefreshIndicator(
        onRefresh: () async {
          await getData(
            isRefresh: true,
            isFromCache: false,
            isNotify: true,
          );
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            SizedBox(height: context.sizeData.height * 0.4),
            const Center(
              child: Text("No Products"),
            ),
          ],
        ),
      );
    }

    List<ProductModel> products = productProvider.products.getList(isNewInstance: false);

    return RefreshIndicator(
      onRefresh: () async {
        await getData(
          isRefresh: true,
          isFromCache: false,
          isNotify: true,
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: products.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if ((index == 0 && products.isEmpty) || (index == products.length)) {
            if (productProvider.isProductsLoading.get()) {
              // if(true) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: themeData.primaryColor,
                      size: 40,
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox();
            }
          }

          if (productProvider.hasMoreProducts.get() && index > (products.length - MyAppConstants.productsRefreshLimitForPagination)) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              productController.getProductsPaginatedList(isRefresh: false, isFromCache: false, isNotify: false);
            });
          }

          ProductModel productModel = products[index];

          return getProductWidget(productModel: productModel);
        },
      ),
    );
  }

  Widget getProductWidget({required ProductModel productModel}) {
    return Text(productModel.name);
  }
}
