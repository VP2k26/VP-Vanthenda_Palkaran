/// User roles in the Vanthenda Paalkaran system.
enum UserRole {
  /// Manager / Admin — Dairy Owner who manages customers, staff, billing, and settings.
  manager,

  /// Vendor — Delivery Boy / Supplier who delivers milk and handles routes.
  vendor,

  /// Customer — Household consumer who views daily milk card and pays bills.
  customer,

  /// Legacy alias for vendor.
  staff,

  /// Role not yet determined.
  unknown,
}
