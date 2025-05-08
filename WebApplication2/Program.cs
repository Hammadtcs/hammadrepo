var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

// Enable serving files from wwwroot
app.UseStaticFiles();

// Fallback so that any unknown route serves index.html
app.MapFallbackToFile("index.html");

app.Run();
