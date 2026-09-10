class TenantBranding {
  const TenantBranding({
    this.companyName = 'Clinicar',
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
      companyName: (tenant['name'] ?? branding['companyName'] ?? 'Clinicar').toString(),
      logoUrl: branding['logoUrl']?.toString(),
      primaryColor: branding['primaryColor']?.toString(),
    );
  }
}
