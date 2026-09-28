import 'package:malta_wash/Src/Core/auth/session_storage.dart';
import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Core/http/http_manager.dart';
import 'package:malta_wash/Src/Core/http/http_method.dart';
import 'package:malta_wash/Src/Features/auth/domain/auth_repository.dart';
import 'package:malta_wash/Src/Features/auth/domain/user_session.dart';
class RemoteAuthRepository implements AuthRepository{
  RemoteAuthRepository({required this.httpManager,required this.sessionStorage}); final HttpManager httpManager; final SessionStorage sessionStorage;
  Map<String,dynamic> _map(dynamic raw){if(raw is Map<String,dynamic>)return raw;if(raw is Map)return raw.map((k,v)=>MapEntry(k.toString(),v));throw const FormatException('Resposta inesperada da API.');}
  Future<void> _save(UserSession s)=>sessionStorage.save(token:s.token,role:s.role,userId:s.userId,tenantId:s.tenantId);
  @override Future<UserSession> login({required String email,required String password}) async{final raw=await httpManager.cloudFunction(name:'v1-cormex-login',authenticated:false,parameters:{'email':email.trim(),'password':password});final s=UserSession.fromJson(_map(raw));if(s.token.isEmpty)throw const FormatException('Token ausente no login.');await _save(s);return s;}
  @override Future<UserSession> register({required String name,required String phone,required String email,required String password,String? tenantSlug}) async{final raw=await httpManager.cloudFunction(name:'v1-cormex-client-register',authenticated:false,parameters:{'name':name.trim(),'phone':phone.trim(),'email':email.trim(),'password':password});final s=UserSession.fromJson(_map(raw));if(s.token.isNotEmpty)await _save(s);return s;}
  @override Future<UserSession> registerCompany({required String companyName,required String ownerName,required String phone,required String email,required String password}) async{final raw=await httpManager.request(Endpoints.registerCompany,method:HttpMethod.post,authenticated:false,data:{'companyName':companyName.trim(),'ownerName':ownerName.trim(),'phone':phone.trim(),'email':email.trim(),'password':password,'timezone':'America/Sao_Paulo','planCode':'STARTER'});final s=UserSession.fromJson(_map(raw));if(s.token.isEmpty)throw const FormatException('Token ausente após o cadastro da empresa.');await _save(s);return s;}
  @override Future<Map<String,dynamic>> me() async{final role=(await sessionStorage.role())?.toUpperCase();if(role=='CLIENT')return _map(await httpManager.cloudFunction(name:'v1-cormex-client-me'));return _map(await httpManager.request(Endpoints.me));}
  @override Future<void> logout() async{try{await httpManager.request(Endpoints.logout,method:HttpMethod.post);}finally{await sessionStorage.clear();}}
  @override Future<void> requestPasswordReset(String email)=>httpManager.request(Endpoints.passwordReset,method:HttpMethod.post,authenticated:false,data:{'email':email.trim()}).then((_){});
}
