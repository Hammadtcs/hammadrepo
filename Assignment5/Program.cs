using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

var builder = WebApplication.CreateBuilder(args);

// Add services before building
builder.Services.AddControllersWithViews();

var app = builder.Build();

// 🔐 Access Azure Key Vault after building the app
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

// 🔐 Fetch secret from Key Vault
try
{
    string keyVaultUrl = "https://keyvaultassignmnet5.vault.azure.net/";
    var secretClient = new SecretClient(new Uri(keyVaultUrl), new DefaultAzureCredential());

    KeyVaultSecret secret = secretClient.GetSecret("Secret1");
    string dbConnectionString = secret.Value;

    // You can log or assign it here if needed
    Console.WriteLine($"Secret Retrieved: {dbConnectionString}");

    // Optional: store in config or use directly
    // app.Configuration["ConnectionStrings:DefaultConnection"] = dbConnectionString;
}
catch (Exception ex)
{
    Console.WriteLine($"Key Vault access error: {ex.Message}");
}

app.Run();
