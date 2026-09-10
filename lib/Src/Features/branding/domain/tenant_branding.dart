class TenantBranding {
  const TenantBranding({
    this.companyName = 'Malta Wash',
    this.logoUrl,
    this.primaryColor,
  });

  final String companyName;
  final String? logoUrl;
  final String? primaryColor;

  factory TenantBranding.fromAuthMe(Map<String, dynamic> json) {
    final tenant = json['tenant'] is Map<String, dynamic>
        ? json['tenant'] as Map<String, dynamic>
        : <String, dynamic>{};
    final branding = tenant['branding'] is Map<String, dynamic>
        ? tenant['branding'] as Map<String, dynamic>
        : <String, dynamic>{};
    return TenantBranding(
      companyName: 'Malta Wash',
      logoUrl: null,
      primaryColor: branding['primaryColor']?.toString(),
    );
  }
}
