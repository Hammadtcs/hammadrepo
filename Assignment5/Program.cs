using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

var builder = WebApplication.CreateBuilder(args);

// Required for Azure Linux Web Apps
builder.WebHost.UseUrls("http://+:80");

// Add services
builder.Services.AddControllersWithViews();

var app = builder.Build();

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

// 🔐 Fetch secret from Azure Key Vault
try
{
    string keyVaultUrl = "https://keyvaultassignmnet5.vault.azure.net/";
    var secretClient = new SecretClient(new Uri(keyVaultUrl), new DefaultAzureCredential());

    var secret = await secretClient.GetSecretAsync("Secret1");
    string dbConnectionString = secret.Value;

    Console.WriteLine($"Secret Retrieved: {dbConnectionString}");

    // Optionally inject into configuration
    // app.Configuration["ConnectionStrings:DefaultConnection"] = dbConnectionString;
}
catch (Exception ex)
{
    Console.WriteLine($"Key Vault access error: {ex.Message}");
}

await app.RunAsync();
