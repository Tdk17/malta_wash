import 'package:malta_wash/Src/Core/auth/session_storage.dart';
import 'package:malta_wash/Src/Core/http/http_manager.dart';

class WashDiscoveryRepository {
  WashDiscoveryRepository(this.http, this.session);
  final HttpManager http;
  final SessionStorage session;

  Future<List<Map<String,dynamic>>> nearby({String? city,double? latitude,double? longitude,double radiusKm=30}) async {
    final raw=await http.cloudFunction(name:'v1-cormex-washes-nearby',authenticated:false,parameters:{if(city!=null&&city.trim().isNotEmpty)'city':city.trim(),if(latitude!=null)'latitude':latitude,if(longitude!=null)'longitude':longitude,'radiusKm':radiusKm});
    final list=raw is List?raw:const [];
    return list.whereType<Map>().map((e)=>e.map((k,v)=>MapEntry(k.toString(),v))).toList();
  }

  Future<Map<String,dynamic>> selectWash(String tenantId) async {
    final raw=await http.cloudFunction(name:'v1-client-select-wash',parameters:{'tenantId':tenantId});
    final map=raw is Map?raw.map((k,v)=>MapEntry(k.toString(),v)):<String,dynamic>{};
    final tenant=map['tenant'];
    final id=tenant is Map?(tenant['id']??'').toString():tenantId;
    await session.selectTenant(id);
    return map;
  }
}
