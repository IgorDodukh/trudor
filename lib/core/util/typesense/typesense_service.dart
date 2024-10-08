import 'package:spoto/domain/usecases/product/get_product_usecase.dart';
import 'package:typesense/typesense.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class TypesenseService {
  late final Client client;
  final String _collectionName = 'products';

  TypesenseService(){
    final host = dotenv.env["TYPESENSE_URL"], protocol = Protocol.https;
    final config = Configuration(
      dotenv.env["TYPESENSE_API_KEY"]!,
      nodes: {
        Node(
          protocol,
          host!,
        ),
      },
      numRetries: 3,
      connectionTimeout: const Duration(seconds: 5),
    );
    client = Client(config);
  }

  Future<void> createCollection() async {
    final schema = Schema(
      _collectionName,
      {
        Field('_id', type: Type.string),
        Field('productId', type: Type.string),
        Field('isNew', type: Type.bool),
        Field('status', type: Type.string),
        Field('ownerId', type: Type.string),
        Field('name', type: Type.string, ),
        Field('description', type: Type.string),
        Field('images', type: Type.auto),
        Field('categories', type: Type.auto),
        Field('category', type: Type.string),
        Field('priceTags', type: Type.auto),
        Field('createdAt', type: Type.string, sort: true),
        Field('updatedAt', type: Type.string),
      },
      defaultSortingField: Field('createdAt', type: Type.string),
    );
    final collections = await client.collections.retrieve();
    bool collectionExists = collections.any((collection) => collection.name == schema.name);
    if (!collectionExists) {
      await client.collections.create(schema);
    }
  }

  Future<void> createDocument(Map<String, dynamic> productData) async {
    await client.collection(_collectionName).documents.create(productData);
  }

  Future<Map<String, dynamic>> updateDocument(Map<String, dynamic> productData) async {
    final searchParameters = {
      'q': productData['_id'],
      'query_by': '_id',
    };
    final querySnapshot = await client.collection(_collectionName).documents.search(searchParameters);
    final document = querySnapshot['hits'][0]['document'];

    return await client.collection(_collectionName).document(document['id']).update(productData);
  }

  Future<Map<String, dynamic>> searchProducts(FilterProductParams params) async {
    final searchName = params.keyword;
    final searchCategory = params.categories.isEmpty ? [] : params.categories.map((category) => category.name).toList();
    final searchStatus = params.status!.isEmpty ? "active" : params.status;

    final searchParameters = {
      'q': searchName,
      'infix': 'always',
      'query_by': params.searchField,
      'pre_segmented_query': 'true',
      'sort_by': 'createdAt:desc',
      'page': '${params.limit}',
      // 'filter_by': 'status:active',
      'per_page': '${params.pageSize}'
    };
    if (searchCategory.isNotEmpty) {
      searchParameters.addAll({'filter_by': 'category:[${searchCategory.join(",")}]'});
    }
    if (searchStatus!.isNotEmpty) {
      searchParameters.addAll({'filter_by': 'status:$searchStatus'});
    }

    print("Search params: $searchParameters");
    final querySnapshot = await client.collection(_collectionName).documents.search(searchParameters);
    return querySnapshot;
  }
}