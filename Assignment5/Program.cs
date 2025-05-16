using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

var builder = WebApplication.CreateBuilder(args);

// ------------------------
// 🔐 Connect to Azure Key Vault
// ------------------------
string keyVaultUrl = "https://keyvaultassignmnet5.vault.azure.net/";
var secretClient = new SecretClient(new Uri(keyVaultUrl), new DefaultAzureCredential());

// Fetch the secret
KeyVaultSecret secret = secretClient.GetSecret("Secret1");
string dbConnectionString = secret.Value;

// You can store this in configuration if needed:
builder.Configuration["ConnectionStrings:DefaultConnection"] = dbConnectionString;

// ------------------------
// 🧩 Add services
// ------------------------
builder.Services.AddControllersWithViews();

// Example: if using EF Core, add DbContext like this:
// builder.Services.AddDbContext<MyDbContext>(options =>
//     options.UseMySql(dbConnectionString, ServerVersion.AutoDetect(dbConnectionString)));

var app = builder.Build();

// ------------------------
// 🌐 Configure middleware
// ------------------------
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

app.Run();
