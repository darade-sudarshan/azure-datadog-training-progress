output "sql_server_id" {
  description = "ID of the SQL Server"
  value       = azurerm_mssql_server.mssqldb.id
}

output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.mssqldb.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.mssqldb.fully_qualified_domain_name
}

output "database_id" {
  description = "ID of the SQL Database"
  value       = azurerm_mssql_database.mssqldb.id
}

output "database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.mssqldb.name
}

output "connection_string" {
  description = "Connection string for the database"
  value       = "Server=tcp:${azurerm_mssql_server.mssqldb.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.mssqldb.name};Persist Security Info=False;User ID=${var.admin_username};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive   = true
}